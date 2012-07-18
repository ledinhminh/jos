
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
  800058:	c7 44 24 04 11 23 80 	movl   $0x802311,0x4(%esp)
  80005f:	00 
  800060:	c7 04 24 e0 22 80 00 	movl   $0x8022e0,(%esp)
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
  800078:	c7 44 24 04 f0 22 80 	movl   $0x8022f0,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  800087:	e8 3d 06 00 00       	call   8006c9 <cprintf>
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	3b 06                	cmp    (%esi),%eax
  800090:	75 13                	jne    8000a5 <check_regs+0x65>
  800092:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  800099:	e8 2b 06 00 00       	call   8006c9 <cprintf>
  80009e:	bf 00 00 00 00       	mov    $0x0,%edi
  8000a3:	eb 11                	jmp    8000b6 <check_regs+0x76>
  8000a5:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  8000ac:	e8 18 06 00 00       	call   8006c9 <cprintf>
  8000b1:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000b6:	8b 46 04             	mov    0x4(%esi),%eax
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8000c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c4:	c7 44 24 04 12 23 80 	movl   $0x802312,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  8000d3:	e8 f1 05 00 00       	call   8006c9 <cprintf>
  8000d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8000db:	3b 46 04             	cmp    0x4(%esi),%eax
  8000de:	75 0e                	jne    8000ee <check_regs+0xae>
  8000e0:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  8000e7:	e8 dd 05 00 00       	call   8006c9 <cprintf>
  8000ec:	eb 11                	jmp    8000ff <check_regs+0xbf>
  8000ee:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  8000f5:	e8 cf 05 00 00       	call   8006c9 <cprintf>
  8000fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000ff:	8b 46 08             	mov    0x8(%esi),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 43 08             	mov    0x8(%ebx),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	c7 44 24 04 16 23 80 	movl   $0x802316,0x4(%esp)
  800114:	00 
  800115:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  80011c:	e8 a8 05 00 00       	call   8006c9 <cprintf>
  800121:	8b 43 08             	mov    0x8(%ebx),%eax
  800124:	3b 46 08             	cmp    0x8(%esi),%eax
  800127:	75 0e                	jne    800137 <check_regs+0xf7>
  800129:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  800130:	e8 94 05 00 00       	call   8006c9 <cprintf>
  800135:	eb 11                	jmp    800148 <check_regs+0x108>
  800137:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  80013e:	e8 86 05 00 00       	call   8006c9 <cprintf>
  800143:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800148:	8b 46 10             	mov    0x10(%esi),%eax
  80014b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014f:	8b 43 10             	mov    0x10(%ebx),%eax
  800152:	89 44 24 08          	mov    %eax,0x8(%esp)
  800156:	c7 44 24 04 1a 23 80 	movl   $0x80231a,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  800165:	e8 5f 05 00 00       	call   8006c9 <cprintf>
  80016a:	8b 43 10             	mov    0x10(%ebx),%eax
  80016d:	3b 46 10             	cmp    0x10(%esi),%eax
  800170:	75 0e                	jne    800180 <check_regs+0x140>
  800172:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  800179:	e8 4b 05 00 00       	call   8006c9 <cprintf>
  80017e:	eb 11                	jmp    800191 <check_regs+0x151>
  800180:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  800187:	e8 3d 05 00 00       	call   8006c9 <cprintf>
  80018c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800191:	8b 46 14             	mov    0x14(%esi),%eax
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	8b 43 14             	mov    0x14(%ebx),%eax
  80019b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019f:	c7 44 24 04 1e 23 80 	movl   $0x80231e,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  8001ae:	e8 16 05 00 00       	call   8006c9 <cprintf>
  8001b3:	8b 43 14             	mov    0x14(%ebx),%eax
  8001b6:	3b 46 14             	cmp    0x14(%esi),%eax
  8001b9:	75 0e                	jne    8001c9 <check_regs+0x189>
  8001bb:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  8001c2:	e8 02 05 00 00       	call   8006c9 <cprintf>
  8001c7:	eb 11                	jmp    8001da <check_regs+0x19a>
  8001c9:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  8001d0:	e8 f4 04 00 00       	call   8006c9 <cprintf>
  8001d5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001da:	8b 46 18             	mov    0x18(%esi),%eax
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	8b 43 18             	mov    0x18(%ebx),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	c7 44 24 04 22 23 80 	movl   $0x802322,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  8001f7:	e8 cd 04 00 00       	call   8006c9 <cprintf>
  8001fc:	8b 43 18             	mov    0x18(%ebx),%eax
  8001ff:	3b 46 18             	cmp    0x18(%esi),%eax
  800202:	75 0e                	jne    800212 <check_regs+0x1d2>
  800204:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  80020b:	e8 b9 04 00 00       	call   8006c9 <cprintf>
  800210:	eb 11                	jmp    800223 <check_regs+0x1e3>
  800212:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  800219:	e8 ab 04 00 00       	call   8006c9 <cprintf>
  80021e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800223:	8b 46 1c             	mov    0x1c(%esi),%eax
  800226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022a:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	c7 44 24 04 26 23 80 	movl   $0x802326,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  800240:	e8 84 04 00 00       	call   8006c9 <cprintf>
  800245:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800248:	3b 46 1c             	cmp    0x1c(%esi),%eax
  80024b:	75 0e                	jne    80025b <check_regs+0x21b>
  80024d:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  800254:	e8 70 04 00 00       	call   8006c9 <cprintf>
  800259:	eb 11                	jmp    80026c <check_regs+0x22c>
  80025b:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  800262:	e8 62 04 00 00       	call   8006c9 <cprintf>
  800267:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80026c:	8b 46 20             	mov    0x20(%esi),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 43 20             	mov    0x20(%ebx),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	c7 44 24 04 2a 23 80 	movl   $0x80232a,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  800289:	e8 3b 04 00 00       	call   8006c9 <cprintf>
  80028e:	8b 43 20             	mov    0x20(%ebx),%eax
  800291:	3b 46 20             	cmp    0x20(%esi),%eax
  800294:	75 0e                	jne    8002a4 <check_regs+0x264>
  800296:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  80029d:	e8 27 04 00 00       	call   8006c9 <cprintf>
  8002a2:	eb 11                	jmp    8002b5 <check_regs+0x275>
  8002a4:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  8002ab:	e8 19 04 00 00       	call   8006c9 <cprintf>
  8002b0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002b5:	8b 46 24             	mov    0x24(%esi),%eax
  8002b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bc:	8b 43 24             	mov    0x24(%ebx),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 04 2e 23 80 	movl   $0x80232e,0x4(%esp)
  8002ca:	00 
  8002cb:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  8002d2:	e8 f2 03 00 00       	call   8006c9 <cprintf>
  8002d7:	8b 43 24             	mov    0x24(%ebx),%eax
  8002da:	3b 46 24             	cmp    0x24(%esi),%eax
  8002dd:	75 0e                	jne    8002ed <check_regs+0x2ad>
  8002df:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  8002e6:	e8 de 03 00 00       	call   8006c9 <cprintf>
  8002eb:	eb 11                	jmp    8002fe <check_regs+0x2be>
  8002ed:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  8002f4:	e8 d0 03 00 00       	call   8006c9 <cprintf>
  8002f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002fe:	8b 46 28             	mov    0x28(%esi),%eax
  800301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800305:	8b 43 28             	mov    0x28(%ebx),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	c7 44 24 04 35 23 80 	movl   $0x802335,0x4(%esp)
  800313:	00 
  800314:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  80031b:	e8 a9 03 00 00       	call   8006c9 <cprintf>
  800320:	8b 43 28             	mov    0x28(%ebx),%eax
  800323:	3b 46 28             	cmp    0x28(%esi),%eax
  800326:	75 25                	jne    80034d <check_regs+0x30d>
  800328:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  80032f:	e8 95 03 00 00       	call   8006c9 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033b:	c7 04 24 39 23 80 00 	movl   $0x802339,(%esp)
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
  80034d:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
  800354:	e8 70 03 00 00       	call   8006c9 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	c7 04 24 39 23 80 00 	movl   $0x802339,(%esp)
  800367:	e8 5d 03 00 00       	call   8006c9 <cprintf>
  80036c:	eb 0e                	jmp    80037c <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  80036e:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  800375:	e8 4f 03 00 00       	call   8006c9 <cprintf>
  80037a:	eb 0c                	jmp    800388 <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80037c:	c7 04 24 08 23 80 00 	movl   $0x802308,(%esp)
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
  80039d:	e8 ea 11 00 00       	call   80158c <set_pgfault_handler>

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
  800466:	c7 04 24 a0 23 80 00 	movl   $0x8023a0,(%esp)
  80046d:	e8 57 02 00 00       	call   8006c9 <cprintf>
	after.eip = before.eip;
  800472:	a1 20 40 80 00       	mov    0x804020,%eax
  800477:	a3 a0 40 80 00       	mov    %eax,0x8040a0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80047c:	c7 44 24 04 4e 23 80 	movl   $0x80234e,0x4(%esp)
  800483:	00 
  800484:	c7 04 24 5f 23 80 00 	movl   $0x80235f,(%esp)
  80048b:	b9 80 40 80 00       	mov    $0x804080,%ecx
  800490:	ba 47 23 80 00       	mov    $0x802347,%edx
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
  8004bf:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  8004c6:	00 
  8004c7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 65 23 80 00 	movl   $0x802365,(%esp)
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
  80053d:	c7 44 24 04 76 23 80 	movl   $0x802376,0x4(%esp)
  800544:	00 
  800545:	c7 04 24 84 23 80 00 	movl   $0x802384,(%esp)
  80054c:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800551:	ba 47 23 80 00       	mov    $0x802347,%edx
  800556:	b8 00 40 80 00       	mov    $0x804000,%eax
  80055b:	e8 e0 fa ff ff       	call   800040 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800560:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800567:	00 
  800568:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80056f:	00 
  800570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800577:	e8 7e 0e 00 00       	call   8013fa <sys_page_alloc>
  80057c:	85 c0                	test   %eax,%eax
  80057e:	79 20                	jns    8005a0 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800580:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800584:	c7 44 24 08 8b 23 80 	movl   $0x80238b,0x8(%esp)
  80058b:	00 
  80058c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800593:	00 
  800594:	c7 04 24 65 23 80 00 	movl   $0x802365,(%esp)
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
  8005b6:	e8 e9 0e 00 00       	call   8014a4 <sys_getenvid>
  8005bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005c8:	a3 b0 40 80 00       	mov    %eax,0x8040b0

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
  8005fa:	e8 1a 15 00 00       	call   801b19 <close_all>
	sys_env_destroy(0);
  8005ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800606:	e8 d4 0e 00 00       	call   8014df <sys_env_destroy>
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
  800621:	e8 7e 0e 00 00       	call   8014a4 <sys_getenvid>
  800626:	8b 55 0c             	mov    0xc(%ebp),%edx
  800629:	89 54 24 10          	mov    %edx,0x10(%esp)
  80062d:	8b 55 08             	mov    0x8(%ebp),%edx
  800630:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800634:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800638:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063c:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  800643:	e8 81 00 00 00       	call   8006c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800648:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064c:	8b 45 10             	mov    0x10(%ebp),%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 11 00 00 00       	call   800668 <vcprintf>
	cprintf("\n");
  800657:	c7 04 24 10 23 80 00 	movl   $0x802310,(%esp)
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
  8006bc:	e8 92 0e 00 00       	call   801553 <sys_cputs>

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
  800710:	e8 3e 0e 00 00       	call   801553 <sys_cputs>
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
  8007ad:	e8 be 18 00 00       	call   802070 <__udivdi3>
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
  800808:	e8 93 19 00 00       	call   8021a0 <__umoddi3>
  80080d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800811:	0f be 80 1f 24 80 00 	movsbl 0x80241f(%eax),%eax
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
  8008f5:	ff 24 95 00 26 80 00 	jmp    *0x802600(,%edx,4)
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
  8009c8:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  8009cf:	85 d2                	test   %edx,%edx
  8009d1:	75 20                	jne    8009f3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8009d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d7:	c7 44 24 08 30 24 80 	movl   $0x802430,0x8(%esp)
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
  8009f7:	c7 44 24 08 a3 28 80 	movl   $0x8028a3,0x8(%esp)
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
  800a31:	b8 39 24 80 00       	mov    $0x802439,%eax
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
  800c75:	c7 44 24 0c 54 25 80 	movl   $0x802554,0xc(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 08 a3 28 80 	movl   $0x8028a3,0x8(%esp)
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
  800ca3:	c7 44 24 0c 8c 25 80 	movl   $0x80258c,0xc(%esp)
  800caa:	00 
  800cab:	c7 44 24 08 a3 28 80 	movl   $0x8028a3,0x8(%esp)
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
  801247:	c7 44 24 08 a0 27 80 	movl   $0x8027a0,0x8(%esp)
  80124e:	00 
  80124f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801256:	00 
  801257:	c7 04 24 bd 27 80 00 	movl   $0x8027bd,(%esp)
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

00801272 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801278:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80127f:	00 
  801280:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801287:	00 
  801288:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80128f:	00 
  801290:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801297:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129a:	ba 01 00 00 00       	mov    $0x1,%edx
  80129f:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012a4:	e8 53 ff ff ff       	call   8011fc <syscall>
}
  8012a9:	c9                   	leave  
  8012aa:	c3                   	ret    

008012ab <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8012b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012b8:	00 
  8012b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ca:	89 04 24             	mov    %eax,(%esp)
  8012cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012da:	e8 1d ff ff ff       	call   8011fc <syscall>
}
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8012e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012ee:	00 
  8012ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012f6:	00 
  8012f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012fe:	00 
  8012ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801302:	89 04 24             	mov    %eax,(%esp)
  801305:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801308:	ba 01 00 00 00       	mov    $0x1,%edx
  80130d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801312:	e8 e5 fe ff ff       	call   8011fc <syscall>
}
  801317:	c9                   	leave  
  801318:	c3                   	ret    

00801319 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80131f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801326:	00 
  801327:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80132e:	00 
  80132f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801336:	00 
  801337:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133a:	89 04 24             	mov    %eax,(%esp)
  80133d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801340:	ba 01 00 00 00       	mov    $0x1,%edx
  801345:	b8 0a 00 00 00       	mov    $0xa,%eax
  80134a:	e8 ad fe ff ff       	call   8011fc <syscall>
}
  80134f:	c9                   	leave  
  801350:	c3                   	ret    

00801351 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801357:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80135e:	00 
  80135f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801366:	00 
  801367:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80136e:	00 
  80136f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801372:	89 04 24             	mov    %eax,(%esp)
  801375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801378:	ba 01 00 00 00       	mov    $0x1,%edx
  80137d:	b8 09 00 00 00       	mov    $0x9,%eax
  801382:	e8 75 fe ff ff       	call   8011fc <syscall>
}
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80138f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801396:	00 
  801397:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80139e:	00 
  80139f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013a6:	00 
  8013a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013aa:	89 04 24             	mov    %eax,(%esp)
  8013ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b0:	ba 01 00 00 00       	mov    $0x1,%edx
  8013b5:	b8 07 00 00 00       	mov    $0x7,%eax
  8013ba:	e8 3d fe ff ff       	call   8011fc <syscall>
}
  8013bf:	c9                   	leave  
  8013c0:	c3                   	ret    

008013c1 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  8013c7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013ce:	00 
  8013cf:	8b 45 18             	mov    0x18(%ebp),%eax
  8013d2:	0b 45 14             	or     0x14(%ebp),%eax
  8013d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8013dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e3:	89 04 24             	mov    %eax,(%esp)
  8013e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e9:	ba 01 00 00 00       	mov    $0x1,%edx
  8013ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8013f3:	e8 04 fe ff ff       	call   8011fc <syscall>
}
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801400:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801407:	00 
  801408:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80140f:	00 
  801410:	8b 45 10             	mov    0x10(%ebp),%eax
  801413:	89 44 24 04          	mov    %eax,0x4(%esp)
  801417:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141a:	89 04 24             	mov    %eax,(%esp)
  80141d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801420:	ba 01 00 00 00       	mov    $0x1,%edx
  801425:	b8 05 00 00 00       	mov    $0x5,%eax
  80142a:	e8 cd fd ff ff       	call   8011fc <syscall>
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801437:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80143e:	00 
  80143f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801446:	00 
  801447:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80144e:	00 
  80144f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801456:	b9 00 00 00 00       	mov    $0x0,%ecx
  80145b:	ba 00 00 00 00       	mov    $0x0,%edx
  801460:	b8 0c 00 00 00       	mov    $0xc,%eax
  801465:	e8 92 fd ff ff       	call   8011fc <syscall>
}
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801472:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801479:	00 
  80147a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801481:	00 
  801482:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801489:	00 
  80148a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148d:	89 04 24             	mov    %eax,(%esp)
  801490:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801493:	ba 00 00 00 00       	mov    $0x0,%edx
  801498:	b8 04 00 00 00       	mov    $0x4,%eax
  80149d:	e8 5a fd ff ff       	call   8011fc <syscall>
}
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8014aa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014b1:	00 
  8014b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b9:	00 
  8014ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014c1:	00 
  8014c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d3:	b8 02 00 00 00       	mov    $0x2,%eax
  8014d8:	e8 1f fd ff ff       	call   8011fc <syscall>
}
  8014dd:	c9                   	leave  
  8014de:	c3                   	ret    

008014df <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8014e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014ec:	00 
  8014ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014f4:	00 
  8014f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014fc:	00 
  8014fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801504:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801507:	ba 01 00 00 00       	mov    $0x1,%edx
  80150c:	b8 03 00 00 00       	mov    $0x3,%eax
  801511:	e8 e6 fc ff ff       	call   8011fc <syscall>
}
  801516:	c9                   	leave  
  801517:	c3                   	ret    

00801518 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80151e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801525:	00 
  801526:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80152d:	00 
  80152e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801535:	00 
  801536:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801542:	ba 00 00 00 00       	mov    $0x0,%edx
  801547:	b8 01 00 00 00       	mov    $0x1,%eax
  80154c:	e8 ab fc ff ff       	call   8011fc <syscall>
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801559:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801560:	00 
  801561:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801568:	00 
  801569:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801570:	00 
  801571:	8b 45 0c             	mov    0xc(%ebp),%eax
  801574:	89 04 24             	mov    %eax,(%esp)
  801577:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80157a:	ba 00 00 00 00       	mov    $0x0,%edx
  80157f:	b8 00 00 00 00       	mov    $0x0,%eax
  801584:	e8 73 fc ff ff       	call   8011fc <syscall>
}
  801589:	c9                   	leave  
  80158a:	c3                   	ret    
	...

0080158c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801592:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801599:	75 54                	jne    8015ef <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  80159b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015a2:	00 
  8015a3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015aa:	ee 
  8015ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b2:	e8 43 fe ff ff       	call   8013fa <sys_page_alloc>
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	79 20                	jns    8015db <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8015bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015bf:	c7 44 24 08 cb 27 80 	movl   $0x8027cb,0x8(%esp)
  8015c6:	00 
  8015c7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8015ce:	00 
  8015cf:	c7 04 24 e3 27 80 00 	movl   $0x8027e3,(%esp)
  8015d6:	e8 35 f0 ff ff       	call   800610 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  8015db:	c7 44 24 04 fc 15 80 	movl   $0x8015fc,0x4(%esp)
  8015e2:	00 
  8015e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ea:	e8 f2 fc ff ff       	call   8012e1 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8015ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f2:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  8015f7:	c9                   	leave  
  8015f8:	c3                   	ret    
  8015f9:	00 00                	add    %al,(%eax)
	...

008015fc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8015fc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8015fd:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  801602:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801604:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  801607:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80160b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80160e:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  801612:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801616:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  801618:	83 c4 08             	add    $0x8,%esp
	popal
  80161b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  80161c:	83 c4 04             	add    $0x4,%esp
	popfl
  80161f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801620:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801621:	c3                   	ret    
	...

00801630 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	8b 45 08             	mov    0x8(%ebp),%eax
  801636:	05 00 00 00 30       	add    $0x30000000,%eax
  80163b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801646:	8b 45 08             	mov    0x8(%ebp),%eax
  801649:	89 04 24             	mov    %eax,(%esp)
  80164c:	e8 df ff ff ff       	call   801630 <fd2num>
  801651:	05 20 00 0d 00       	add    $0xd0020,%eax
  801656:	c1 e0 0c             	shl    $0xc,%eax
}
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	57                   	push   %edi
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801664:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801669:	a8 01                	test   $0x1,%al
  80166b:	74 36                	je     8016a3 <fd_alloc+0x48>
  80166d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801672:	a8 01                	test   $0x1,%al
  801674:	74 2d                	je     8016a3 <fd_alloc+0x48>
  801676:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80167b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801680:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801685:	89 c3                	mov    %eax,%ebx
  801687:	89 c2                	mov    %eax,%edx
  801689:	c1 ea 16             	shr    $0x16,%edx
  80168c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80168f:	f6 c2 01             	test   $0x1,%dl
  801692:	74 14                	je     8016a8 <fd_alloc+0x4d>
  801694:	89 c2                	mov    %eax,%edx
  801696:	c1 ea 0c             	shr    $0xc,%edx
  801699:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80169c:	f6 c2 01             	test   $0x1,%dl
  80169f:	75 10                	jne    8016b1 <fd_alloc+0x56>
  8016a1:	eb 05                	jmp    8016a8 <fd_alloc+0x4d>
  8016a3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8016a8:	89 1f                	mov    %ebx,(%edi)
  8016aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016af:	eb 17                	jmp    8016c8 <fd_alloc+0x6d>
  8016b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016bb:	75 c8                	jne    801685 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016bd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8016c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8016c8:	5b                   	pop    %ebx
  8016c9:	5e                   	pop    %esi
  8016ca:	5f                   	pop    %edi
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	83 f8 1f             	cmp    $0x1f,%eax
  8016d6:	77 36                	ja     80170e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016d8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8016dd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	c1 ea 16             	shr    $0x16,%edx
  8016e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016ec:	f6 c2 01             	test   $0x1,%dl
  8016ef:	74 1d                	je     80170e <fd_lookup+0x41>
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	c1 ea 0c             	shr    $0xc,%edx
  8016f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016fd:	f6 c2 01             	test   $0x1,%dl
  801700:	74 0c                	je     80170e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801702:	8b 55 0c             	mov    0xc(%ebp),%edx
  801705:	89 02                	mov    %eax,(%edx)
  801707:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80170c:	eb 05                	jmp    801713 <fd_lookup+0x46>
  80170e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	89 04 24             	mov    %eax,(%esp)
  801728:	e8 a0 ff ff ff       	call   8016cd <fd_lookup>
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 0e                	js     80173f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801731:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801734:	8b 55 0c             	mov    0xc(%ebp),%edx
  801737:	89 50 04             	mov    %edx,0x4(%eax)
  80173a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	56                   	push   %esi
  801745:	53                   	push   %ebx
  801746:	83 ec 10             	sub    $0x10,%esp
  801749:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80174c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80174f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801754:	b8 04 30 80 00       	mov    $0x803004,%eax
  801759:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80175f:	75 11                	jne    801772 <dev_lookup+0x31>
  801761:	eb 04                	jmp    801767 <dev_lookup+0x26>
  801763:	39 08                	cmp    %ecx,(%eax)
  801765:	75 10                	jne    801777 <dev_lookup+0x36>
			*dev = devtab[i];
  801767:	89 03                	mov    %eax,(%ebx)
  801769:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80176e:	66 90                	xchg   %ax,%ax
  801770:	eb 36                	jmp    8017a8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801772:	be 74 28 80 00       	mov    $0x802874,%esi
  801777:	83 c2 01             	add    $0x1,%edx
  80177a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80177d:	85 c0                	test   %eax,%eax
  80177f:	75 e2                	jne    801763 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801781:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801786:	8b 40 48             	mov    0x48(%eax),%eax
  801789:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80178d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801791:	c7 04 24 f4 27 80 00 	movl   $0x8027f4,(%esp)
  801798:	e8 2c ef ff ff       	call   8006c9 <cprintf>
	*dev = 0;
  80179d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	5b                   	pop    %ebx
  8017ac:	5e                   	pop    %esi
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	53                   	push   %ebx
  8017b3:	83 ec 24             	sub    $0x24,%esp
  8017b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	89 04 24             	mov    %eax,(%esp)
  8017c6:	e8 02 ff ff ff       	call   8016cd <fd_lookup>
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	78 53                	js     801822 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d9:	8b 00                	mov    (%eax),%eax
  8017db:	89 04 24             	mov    %eax,(%esp)
  8017de:	e8 5e ff ff ff       	call   801741 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 3b                	js     801822 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8017e7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ef:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8017f3:	74 2d                	je     801822 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ff:	00 00 00 
	stat->st_isdir = 0;
  801802:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801809:	00 00 00 
	stat->st_dev = dev;
  80180c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801815:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801819:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80181c:	89 14 24             	mov    %edx,(%esp)
  80181f:	ff 50 14             	call   *0x14(%eax)
}
  801822:	83 c4 24             	add    $0x24,%esp
  801825:	5b                   	pop    %ebx
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    

00801828 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	53                   	push   %ebx
  80182c:	83 ec 24             	sub    $0x24,%esp
  80182f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801832:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801835:	89 44 24 04          	mov    %eax,0x4(%esp)
  801839:	89 1c 24             	mov    %ebx,(%esp)
  80183c:	e8 8c fe ff ff       	call   8016cd <fd_lookup>
  801841:	85 c0                	test   %eax,%eax
  801843:	78 5f                	js     8018a4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801845:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184f:	8b 00                	mov    (%eax),%eax
  801851:	89 04 24             	mov    %eax,(%esp)
  801854:	e8 e8 fe ff ff       	call   801741 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801859:	85 c0                	test   %eax,%eax
  80185b:	78 47                	js     8018a4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80185d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801860:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801864:	75 23                	jne    801889 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801866:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80186b:	8b 40 48             	mov    0x48(%eax),%eax
  80186e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801872:	89 44 24 04          	mov    %eax,0x4(%esp)
  801876:	c7 04 24 14 28 80 00 	movl   $0x802814,(%esp)
  80187d:	e8 47 ee ff ff       	call   8006c9 <cprintf>
  801882:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801887:	eb 1b                	jmp    8018a4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801889:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188c:	8b 48 18             	mov    0x18(%eax),%ecx
  80188f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801894:	85 c9                	test   %ecx,%ecx
  801896:	74 0c                	je     8018a4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801898:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189f:	89 14 24             	mov    %edx,(%esp)
  8018a2:	ff d1                	call   *%ecx
}
  8018a4:	83 c4 24             	add    $0x24,%esp
  8018a7:	5b                   	pop    %ebx
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    

008018aa <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 24             	sub    $0x24,%esp
  8018b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bb:	89 1c 24             	mov    %ebx,(%esp)
  8018be:	e8 0a fe ff ff       	call   8016cd <fd_lookup>
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 66                	js     80192d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d1:	8b 00                	mov    (%eax),%eax
  8018d3:	89 04 24             	mov    %eax,(%esp)
  8018d6:	e8 66 fe ff ff       	call   801741 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	78 4e                	js     80192d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018e2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8018e6:	75 23                	jne    80190b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018e8:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8018ed:	8b 40 48             	mov    0x48(%eax),%eax
  8018f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f8:	c7 04 24 38 28 80 00 	movl   $0x802838,(%esp)
  8018ff:	e8 c5 ed ff ff       	call   8006c9 <cprintf>
  801904:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801909:	eb 22                	jmp    80192d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80190b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801911:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801916:	85 c9                	test   %ecx,%ecx
  801918:	74 13                	je     80192d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80191a:	8b 45 10             	mov    0x10(%ebp),%eax
  80191d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801921:	8b 45 0c             	mov    0xc(%ebp),%eax
  801924:	89 44 24 04          	mov    %eax,0x4(%esp)
  801928:	89 14 24             	mov    %edx,(%esp)
  80192b:	ff d1                	call   *%ecx
}
  80192d:	83 c4 24             	add    $0x24,%esp
  801930:	5b                   	pop    %ebx
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    

00801933 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	53                   	push   %ebx
  801937:	83 ec 24             	sub    $0x24,%esp
  80193a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80193d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801940:	89 44 24 04          	mov    %eax,0x4(%esp)
  801944:	89 1c 24             	mov    %ebx,(%esp)
  801947:	e8 81 fd ff ff       	call   8016cd <fd_lookup>
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 6b                	js     8019bb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801950:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801953:	89 44 24 04          	mov    %eax,0x4(%esp)
  801957:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195a:	8b 00                	mov    (%eax),%eax
  80195c:	89 04 24             	mov    %eax,(%esp)
  80195f:	e8 dd fd ff ff       	call   801741 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801964:	85 c0                	test   %eax,%eax
  801966:	78 53                	js     8019bb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801968:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80196b:	8b 42 08             	mov    0x8(%edx),%eax
  80196e:	83 e0 03             	and    $0x3,%eax
  801971:	83 f8 01             	cmp    $0x1,%eax
  801974:	75 23                	jne    801999 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801976:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80197b:	8b 40 48             	mov    0x48(%eax),%eax
  80197e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801982:	89 44 24 04          	mov    %eax,0x4(%esp)
  801986:	c7 04 24 55 28 80 00 	movl   $0x802855,(%esp)
  80198d:	e8 37 ed ff ff       	call   8006c9 <cprintf>
  801992:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801997:	eb 22                	jmp    8019bb <read+0x88>
	}
	if (!dev->dev_read)
  801999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199c:	8b 48 08             	mov    0x8(%eax),%ecx
  80199f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019a4:	85 c9                	test   %ecx,%ecx
  8019a6:	74 13                	je     8019bb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b6:	89 14 24             	mov    %edx,(%esp)
  8019b9:	ff d1                	call   *%ecx
}
  8019bb:	83 c4 24             	add    $0x24,%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5d                   	pop    %ebp
  8019c0:	c3                   	ret    

008019c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	57                   	push   %edi
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
  8019c7:	83 ec 1c             	sub    $0x1c,%esp
  8019ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
  8019df:	85 f6                	test   %esi,%esi
  8019e1:	74 29                	je     801a0c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019e3:	89 f0                	mov    %esi,%eax
  8019e5:	29 d0                	sub    %edx,%eax
  8019e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019eb:	03 55 0c             	add    0xc(%ebp),%edx
  8019ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019f2:	89 3c 24             	mov    %edi,(%esp)
  8019f5:	e8 39 ff ff ff       	call   801933 <read>
		if (m < 0)
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 0e                	js     801a0c <readn+0x4b>
			return m;
		if (m == 0)
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	74 08                	je     801a0a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a02:	01 c3                	add    %eax,%ebx
  801a04:	89 da                	mov    %ebx,%edx
  801a06:	39 f3                	cmp    %esi,%ebx
  801a08:	72 d9                	jb     8019e3 <readn+0x22>
  801a0a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a0c:	83 c4 1c             	add    $0x1c,%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5f                   	pop    %edi
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    

00801a14 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	83 ec 28             	sub    $0x28,%esp
  801a1a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a1d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a20:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a23:	89 34 24             	mov    %esi,(%esp)
  801a26:	e8 05 fc ff ff       	call   801630 <fd2num>
  801a2b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a32:	89 04 24             	mov    %eax,(%esp)
  801a35:	e8 93 fc ff ff       	call   8016cd <fd_lookup>
  801a3a:	89 c3                	mov    %eax,%ebx
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 05                	js     801a45 <fd_close+0x31>
  801a40:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a43:	74 0e                	je     801a53 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801a45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a49:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4e:	0f 44 d8             	cmove  %eax,%ebx
  801a51:	eb 3d                	jmp    801a90 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5a:	8b 06                	mov    (%esi),%eax
  801a5c:	89 04 24             	mov    %eax,(%esp)
  801a5f:	e8 dd fc ff ff       	call   801741 <dev_lookup>
  801a64:	89 c3                	mov    %eax,%ebx
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 16                	js     801a80 <fd_close+0x6c>
		if (dev->dev_close)
  801a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6d:	8b 40 10             	mov    0x10(%eax),%eax
  801a70:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a75:	85 c0                	test   %eax,%eax
  801a77:	74 07                	je     801a80 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801a79:	89 34 24             	mov    %esi,(%esp)
  801a7c:	ff d0                	call   *%eax
  801a7e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a80:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a8b:	e8 f9 f8 ff ff       	call   801389 <sys_page_unmap>
	return r;
}
  801a90:	89 d8                	mov    %ebx,%eax
  801a92:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a95:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a98:	89 ec                	mov    %ebp,%esp
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aac:	89 04 24             	mov    %eax,(%esp)
  801aaf:	e8 19 fc ff ff       	call   8016cd <fd_lookup>
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	78 13                	js     801acb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801ab8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801abf:	00 
  801ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac3:	89 04 24             	mov    %eax,(%esp)
  801ac6:	e8 49 ff ff ff       	call   801a14 <fd_close>
}
  801acb:	c9                   	leave  
  801acc:	c3                   	ret    

00801acd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	83 ec 18             	sub    $0x18,%esp
  801ad3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ad6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ae0:	00 
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae4:	89 04 24             	mov    %eax,(%esp)
  801ae7:	e8 78 03 00 00       	call   801e64 <open>
  801aec:	89 c3                	mov    %eax,%ebx
  801aee:	85 c0                	test   %eax,%eax
  801af0:	78 1b                	js     801b0d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af9:	89 1c 24             	mov    %ebx,(%esp)
  801afc:	e8 ae fc ff ff       	call   8017af <fstat>
  801b01:	89 c6                	mov    %eax,%esi
	close(fd);
  801b03:	89 1c 24             	mov    %ebx,(%esp)
  801b06:	e8 91 ff ff ff       	call   801a9c <close>
  801b0b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b0d:	89 d8                	mov    %ebx,%eax
  801b0f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b12:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b15:	89 ec                	mov    %ebp,%esp
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 14             	sub    $0x14,%esp
  801b20:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b25:	89 1c 24             	mov    %ebx,(%esp)
  801b28:	e8 6f ff ff ff       	call   801a9c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b2d:	83 c3 01             	add    $0x1,%ebx
  801b30:	83 fb 20             	cmp    $0x20,%ebx
  801b33:	75 f0                	jne    801b25 <close_all+0xc>
		close(i);
}
  801b35:	83 c4 14             	add    $0x14,%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    

00801b3b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	83 ec 58             	sub    $0x58,%esp
  801b41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b47:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b4a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b4d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b50:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b54:	8b 45 08             	mov    0x8(%ebp),%eax
  801b57:	89 04 24             	mov    %eax,(%esp)
  801b5a:	e8 6e fb ff ff       	call   8016cd <fd_lookup>
  801b5f:	89 c3                	mov    %eax,%ebx
  801b61:	85 c0                	test   %eax,%eax
  801b63:	0f 88 e0 00 00 00    	js     801c49 <dup+0x10e>
		return r;
	close(newfdnum);
  801b69:	89 3c 24             	mov    %edi,(%esp)
  801b6c:	e8 2b ff ff ff       	call   801a9c <close>

	newfd = INDEX2FD(newfdnum);
  801b71:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801b77:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801b7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b7d:	89 04 24             	mov    %eax,(%esp)
  801b80:	e8 bb fa ff ff       	call   801640 <fd2data>
  801b85:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801b87:	89 34 24             	mov    %esi,(%esp)
  801b8a:	e8 b1 fa ff ff       	call   801640 <fd2data>
  801b8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801b92:	89 da                	mov    %ebx,%edx
  801b94:	89 d8                	mov    %ebx,%eax
  801b96:	c1 e8 16             	shr    $0x16,%eax
  801b99:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ba0:	a8 01                	test   $0x1,%al
  801ba2:	74 43                	je     801be7 <dup+0xac>
  801ba4:	c1 ea 0c             	shr    $0xc,%edx
  801ba7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bae:	a8 01                	test   $0x1,%al
  801bb0:	74 35                	je     801be7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801bb2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bb9:	25 07 0e 00 00       	and    $0xe07,%eax
  801bbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801bc2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801bc5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bc9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bd0:	00 
  801bd1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bdc:	e8 e0 f7 ff ff       	call   8013c1 <sys_page_map>
  801be1:	89 c3                	mov    %eax,%ebx
  801be3:	85 c0                	test   %eax,%eax
  801be5:	78 3f                	js     801c26 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801be7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bea:	89 c2                	mov    %eax,%edx
  801bec:	c1 ea 0c             	shr    $0xc,%edx
  801bef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bf6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801bfc:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c00:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c04:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c0b:	00 
  801c0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c17:	e8 a5 f7 ff ff       	call   8013c1 <sys_page_map>
  801c1c:	89 c3                	mov    %eax,%ebx
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	78 04                	js     801c26 <dup+0xeb>
  801c22:	89 fb                	mov    %edi,%ebx
  801c24:	eb 23                	jmp    801c49 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c31:	e8 53 f7 ff ff       	call   801389 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c44:	e8 40 f7 ff ff       	call   801389 <sys_page_unmap>
	return r;
}
  801c49:	89 d8                	mov    %ebx,%eax
  801c4b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c4e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c51:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c54:	89 ec                	mov    %ebp,%esp
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 18             	sub    $0x18,%esp
  801c5e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c61:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c64:	89 c3                	mov    %eax,%ebx
  801c66:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c68:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801c6f:	75 11                	jne    801c82 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c71:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c78:	e8 a3 02 00 00       	call   801f20 <ipc_find_env>
  801c7d:	a3 ac 40 80 00       	mov    %eax,0x8040ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c82:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c89:	00 
  801c8a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c91:	00 
  801c92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c96:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801c9b:	89 04 24             	mov    %eax,(%esp)
  801c9e:	e8 c1 02 00 00       	call   801f64 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ca3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801caa:	00 
  801cab:	89 74 24 04          	mov    %esi,0x4(%esp)
  801caf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb6:	e8 18 03 00 00       	call   801fd3 <ipc_recv>
}
  801cbb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cbe:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cc1:	89 ec                	mov    %ebp,%esp
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cce:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801cde:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce3:	b8 02 00 00 00       	mov    $0x2,%eax
  801ce8:	e8 6b ff ff ff       	call   801c58 <fsipc>
}
  801ced:	c9                   	leave  
  801cee:	c3                   	ret    

00801cef <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf8:	8b 40 0c             	mov    0xc(%eax),%eax
  801cfb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d00:	ba 00 00 00 00       	mov    $0x0,%edx
  801d05:	b8 06 00 00 00       	mov    $0x6,%eax
  801d0a:	e8 49 ff ff ff       	call   801c58 <fsipc>
}
  801d0f:	c9                   	leave  
  801d10:	c3                   	ret    

00801d11 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d17:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1c:	b8 08 00 00 00       	mov    $0x8,%eax
  801d21:	e8 32 ff ff ff       	call   801c58 <fsipc>
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	53                   	push   %ebx
  801d2c:	83 ec 14             	sub    $0x14,%esp
  801d2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d32:	8b 45 08             	mov    0x8(%ebp),%eax
  801d35:	8b 40 0c             	mov    0xc(%eax),%eax
  801d38:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d42:	b8 05 00 00 00       	mov    $0x5,%eax
  801d47:	e8 0c ff ff ff       	call   801c58 <fsipc>
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	78 2b                	js     801d7b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d50:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d57:	00 
  801d58:	89 1c 24             	mov    %ebx,(%esp)
  801d5b:	e8 aa f0 ff ff       	call   800e0a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d60:	a1 80 50 80 00       	mov    0x805080,%eax
  801d65:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d6b:	a1 84 50 80 00       	mov    0x805084,%eax
  801d70:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d7b:	83 c4 14             	add    $0x14,%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    

00801d81 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	83 ec 18             	sub    $0x18,%esp
  801d87:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d8a:	8b 55 08             	mov    0x8(%ebp),%edx
  801d8d:	8b 52 0c             	mov    0xc(%edx),%edx
  801d90:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801d96:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  801d9b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801da0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801da5:	0f 47 c2             	cmova  %edx,%eax
  801da8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801daf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801dba:	e8 36 f2 ff ff       	call   800ff5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801dbf:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc4:	b8 04 00 00 00       	mov    $0x4,%eax
  801dc9:	e8 8a fe ff ff       	call   801c58 <fsipc>
}
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    

00801dd0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	53                   	push   %ebx
  801dd4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dda:	8b 40 0c             	mov    0xc(%eax),%eax
  801ddd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801de2:	8b 45 10             	mov    0x10(%ebp),%eax
  801de5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801dea:	ba 00 00 00 00       	mov    $0x0,%edx
  801def:	b8 03 00 00 00       	mov    $0x3,%eax
  801df4:	e8 5f fe ff ff       	call   801c58 <fsipc>
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	78 17                	js     801e16 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801dff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e03:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e0a:	00 
  801e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0e:	89 04 24             	mov    %eax,(%esp)
  801e11:	e8 df f1 ff ff       	call   800ff5 <memmove>
  return r;	
}
  801e16:	89 d8                	mov    %ebx,%eax
  801e18:	83 c4 14             	add    $0x14,%esp
  801e1b:	5b                   	pop    %ebx
  801e1c:	5d                   	pop    %ebp
  801e1d:	c3                   	ret    

00801e1e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	53                   	push   %ebx
  801e22:	83 ec 14             	sub    $0x14,%esp
  801e25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e28:	89 1c 24             	mov    %ebx,(%esp)
  801e2b:	e8 90 ef ff ff       	call   800dc0 <strlen>
  801e30:	89 c2                	mov    %eax,%edx
  801e32:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801e37:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801e3d:	7f 1f                	jg     801e5e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e43:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e4a:	e8 bb ef ff ff       	call   800e0a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801e4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e54:	b8 07 00 00 00       	mov    $0x7,%eax
  801e59:	e8 fa fd ff ff       	call   801c58 <fsipc>
}
  801e5e:	83 c4 14             	add    $0x14,%esp
  801e61:	5b                   	pop    %ebx
  801e62:	5d                   	pop    %ebp
  801e63:	c3                   	ret    

00801e64 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	83 ec 28             	sub    $0x28,%esp
  801e6a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e6d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e70:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801e73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e76:	89 04 24             	mov    %eax,(%esp)
  801e79:	e8 dd f7 ff ff       	call   80165b <fd_alloc>
  801e7e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801e80:	85 c0                	test   %eax,%eax
  801e82:	0f 88 89 00 00 00    	js     801f11 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801e88:	89 34 24             	mov    %esi,(%esp)
  801e8b:	e8 30 ef ff ff       	call   800dc0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801e90:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801e95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e9a:	7f 75                	jg     801f11 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801e9c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ea7:	e8 5e ef ff ff       	call   800e0a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801eac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eaf:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801eb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801eb7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebc:	e8 97 fd ff ff       	call   801c58 <fsipc>
  801ec1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	78 0f                	js     801ed6 <open+0x72>
  return fd2num(fd);
  801ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eca:	89 04 24             	mov    %eax,(%esp)
  801ecd:	e8 5e f7 ff ff       	call   801630 <fd2num>
  801ed2:	89 c3                	mov    %eax,%ebx
  801ed4:	eb 3b                	jmp    801f11 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801ed6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801edd:	00 
  801ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee1:	89 04 24             	mov    %eax,(%esp)
  801ee4:	e8 2b fb ff ff       	call   801a14 <fd_close>
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	74 24                	je     801f11 <open+0xad>
  801eed:	c7 44 24 0c 7c 28 80 	movl   $0x80287c,0xc(%esp)
  801ef4:	00 
  801ef5:	c7 44 24 08 91 28 80 	movl   $0x802891,0x8(%esp)
  801efc:	00 
  801efd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801f04:	00 
  801f05:	c7 04 24 a6 28 80 00 	movl   $0x8028a6,(%esp)
  801f0c:	e8 ff e6 ff ff       	call   800610 <_panic>
  return r;
}
  801f11:	89 d8                	mov    %ebx,%eax
  801f13:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f16:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f19:	89 ec                	mov    %ebp,%esp
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    
  801f1d:	00 00                	add    %al,(%eax)
	...

00801f20 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f26:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801f2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f31:	39 ca                	cmp    %ecx,%edx
  801f33:	75 04                	jne    801f39 <ipc_find_env+0x19>
  801f35:	b0 00                	mov    $0x0,%al
  801f37:	eb 0f                	jmp    801f48 <ipc_find_env+0x28>
  801f39:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f3c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801f42:	8b 12                	mov    (%edx),%edx
  801f44:	39 ca                	cmp    %ecx,%edx
  801f46:	75 0c                	jne    801f54 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f48:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f4b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801f50:	8b 00                	mov    (%eax),%eax
  801f52:	eb 0e                	jmp    801f62 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f54:	83 c0 01             	add    $0x1,%eax
  801f57:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f5c:	75 db                	jne    801f39 <ipc_find_env+0x19>
  801f5e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    

00801f64 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	57                   	push   %edi
  801f68:	56                   	push   %esi
  801f69:	53                   	push   %ebx
  801f6a:	83 ec 1c             	sub    $0x1c,%esp
  801f6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f70:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f76:	85 db                	test   %ebx,%ebx
  801f78:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f7d:	0f 44 d8             	cmove  %eax,%ebx
  801f80:	eb 29                	jmp    801fab <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801f82:	85 c0                	test   %eax,%eax
  801f84:	79 25                	jns    801fab <ipc_send+0x47>
  801f86:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f89:	74 20                	je     801fab <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801f8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8f:	c7 44 24 08 b1 28 80 	movl   $0x8028b1,0x8(%esp)
  801f96:	00 
  801f97:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801f9e:	00 
  801f9f:	c7 04 24 cf 28 80 00 	movl   $0x8028cf,(%esp)
  801fa6:	e8 65 e6 ff ff       	call   800610 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801fab:	8b 45 14             	mov    0x14(%ebp),%eax
  801fae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fb6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fba:	89 34 24             	mov    %esi,(%esp)
  801fbd:	e8 e9 f2 ff ff       	call   8012ab <sys_ipc_try_send>
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	75 bc                	jne    801f82 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801fc6:	e8 66 f4 ff ff       	call   801431 <sys_yield>
}
  801fcb:	83 c4 1c             	add    $0x1c,%esp
  801fce:	5b                   	pop    %ebx
  801fcf:	5e                   	pop    %esi
  801fd0:	5f                   	pop    %edi
  801fd1:	5d                   	pop    %ebp
  801fd2:	c3                   	ret    

00801fd3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	83 ec 28             	sub    $0x28,%esp
  801fd9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801fdc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801fdf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801fe2:	8b 75 08             	mov    0x8(%ebp),%esi
  801fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801feb:	85 c0                	test   %eax,%eax
  801fed:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ff2:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801ff5:	89 04 24             	mov    %eax,(%esp)
  801ff8:	e8 75 f2 ff ff       	call   801272 <sys_ipc_recv>
  801ffd:	89 c3                	mov    %eax,%ebx
  801fff:	85 c0                	test   %eax,%eax
  802001:	79 2a                	jns    80202d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  802003:	89 44 24 08          	mov    %eax,0x8(%esp)
  802007:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200b:	c7 04 24 d9 28 80 00 	movl   $0x8028d9,(%esp)
  802012:	e8 b2 e6 ff ff       	call   8006c9 <cprintf>
		if(from_env_store != NULL)
  802017:	85 f6                	test   %esi,%esi
  802019:	74 06                	je     802021 <ipc_recv+0x4e>
			*from_env_store = 0;
  80201b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802021:	85 ff                	test   %edi,%edi
  802023:	74 2d                	je     802052 <ipc_recv+0x7f>
			*perm_store = 0;
  802025:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80202b:	eb 25                	jmp    802052 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  80202d:	85 f6                	test   %esi,%esi
  80202f:	90                   	nop
  802030:	74 0a                	je     80203c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  802032:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802037:	8b 40 74             	mov    0x74(%eax),%eax
  80203a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80203c:	85 ff                	test   %edi,%edi
  80203e:	74 0a                	je     80204a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  802040:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802045:	8b 40 78             	mov    0x78(%eax),%eax
  802048:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80204a:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80204f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  802052:	89 d8                	mov    %ebx,%eax
  802054:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802057:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80205a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80205d:	89 ec                	mov    %ebp,%esp
  80205f:	5d                   	pop    %ebp
  802060:	c3                   	ret    
	...

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	57                   	push   %edi
  802074:	56                   	push   %esi
  802075:	83 ec 10             	sub    $0x10,%esp
  802078:	8b 45 14             	mov    0x14(%ebp),%eax
  80207b:	8b 55 08             	mov    0x8(%ebp),%edx
  80207e:	8b 75 10             	mov    0x10(%ebp),%esi
  802081:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802084:	85 c0                	test   %eax,%eax
  802086:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802089:	75 35                	jne    8020c0 <__udivdi3+0x50>
  80208b:	39 fe                	cmp    %edi,%esi
  80208d:	77 61                	ja     8020f0 <__udivdi3+0x80>
  80208f:	85 f6                	test   %esi,%esi
  802091:	75 0b                	jne    80209e <__udivdi3+0x2e>
  802093:	b8 01 00 00 00       	mov    $0x1,%eax
  802098:	31 d2                	xor    %edx,%edx
  80209a:	f7 f6                	div    %esi
  80209c:	89 c6                	mov    %eax,%esi
  80209e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8020a1:	31 d2                	xor    %edx,%edx
  8020a3:	89 f8                	mov    %edi,%eax
  8020a5:	f7 f6                	div    %esi
  8020a7:	89 c7                	mov    %eax,%edi
  8020a9:	89 c8                	mov    %ecx,%eax
  8020ab:	f7 f6                	div    %esi
  8020ad:	89 c1                	mov    %eax,%ecx
  8020af:	89 fa                	mov    %edi,%edx
  8020b1:	89 c8                	mov    %ecx,%eax
  8020b3:	83 c4 10             	add    $0x10,%esp
  8020b6:	5e                   	pop    %esi
  8020b7:	5f                   	pop    %edi
  8020b8:	5d                   	pop    %ebp
  8020b9:	c3                   	ret    
  8020ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c0:	39 f8                	cmp    %edi,%eax
  8020c2:	77 1c                	ja     8020e0 <__udivdi3+0x70>
  8020c4:	0f bd d0             	bsr    %eax,%edx
  8020c7:	83 f2 1f             	xor    $0x1f,%edx
  8020ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020cd:	75 39                	jne    802108 <__udivdi3+0x98>
  8020cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8020d2:	0f 86 a0 00 00 00    	jbe    802178 <__udivdi3+0x108>
  8020d8:	39 f8                	cmp    %edi,%eax
  8020da:	0f 82 98 00 00 00    	jb     802178 <__udivdi3+0x108>
  8020e0:	31 ff                	xor    %edi,%edi
  8020e2:	31 c9                	xor    %ecx,%ecx
  8020e4:	89 c8                	mov    %ecx,%eax
  8020e6:	89 fa                	mov    %edi,%edx
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	5e                   	pop    %esi
  8020ec:	5f                   	pop    %edi
  8020ed:	5d                   	pop    %ebp
  8020ee:	c3                   	ret    
  8020ef:	90                   	nop
  8020f0:	89 d1                	mov    %edx,%ecx
  8020f2:	89 fa                	mov    %edi,%edx
  8020f4:	89 c8                	mov    %ecx,%eax
  8020f6:	31 ff                	xor    %edi,%edi
  8020f8:	f7 f6                	div    %esi
  8020fa:	89 c1                	mov    %eax,%ecx
  8020fc:	89 fa                	mov    %edi,%edx
  8020fe:	89 c8                	mov    %ecx,%eax
  802100:	83 c4 10             	add    $0x10,%esp
  802103:	5e                   	pop    %esi
  802104:	5f                   	pop    %edi
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    
  802107:	90                   	nop
  802108:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80210c:	89 f2                	mov    %esi,%edx
  80210e:	d3 e0                	shl    %cl,%eax
  802110:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802113:	b8 20 00 00 00       	mov    $0x20,%eax
  802118:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80211b:	89 c1                	mov    %eax,%ecx
  80211d:	d3 ea                	shr    %cl,%edx
  80211f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802123:	0b 55 ec             	or     -0x14(%ebp),%edx
  802126:	d3 e6                	shl    %cl,%esi
  802128:	89 c1                	mov    %eax,%ecx
  80212a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80212d:	89 fe                	mov    %edi,%esi
  80212f:	d3 ee                	shr    %cl,%esi
  802131:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802135:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802138:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80213b:	d3 e7                	shl    %cl,%edi
  80213d:	89 c1                	mov    %eax,%ecx
  80213f:	d3 ea                	shr    %cl,%edx
  802141:	09 d7                	or     %edx,%edi
  802143:	89 f2                	mov    %esi,%edx
  802145:	89 f8                	mov    %edi,%eax
  802147:	f7 75 ec             	divl   -0x14(%ebp)
  80214a:	89 d6                	mov    %edx,%esi
  80214c:	89 c7                	mov    %eax,%edi
  80214e:	f7 65 e8             	mull   -0x18(%ebp)
  802151:	39 d6                	cmp    %edx,%esi
  802153:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802156:	72 30                	jb     802188 <__udivdi3+0x118>
  802158:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80215b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80215f:	d3 e2                	shl    %cl,%edx
  802161:	39 c2                	cmp    %eax,%edx
  802163:	73 05                	jae    80216a <__udivdi3+0xfa>
  802165:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802168:	74 1e                	je     802188 <__udivdi3+0x118>
  80216a:	89 f9                	mov    %edi,%ecx
  80216c:	31 ff                	xor    %edi,%edi
  80216e:	e9 71 ff ff ff       	jmp    8020e4 <__udivdi3+0x74>
  802173:	90                   	nop
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	31 ff                	xor    %edi,%edi
  80217a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80217f:	e9 60 ff ff ff       	jmp    8020e4 <__udivdi3+0x74>
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80218b:	31 ff                	xor    %edi,%edi
  80218d:	89 c8                	mov    %ecx,%eax
  80218f:	89 fa                	mov    %edi,%edx
  802191:	83 c4 10             	add    $0x10,%esp
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
	...

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	57                   	push   %edi
  8021a4:	56                   	push   %esi
  8021a5:	83 ec 20             	sub    $0x20,%esp
  8021a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8021ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8021b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021b4:	85 d2                	test   %edx,%edx
  8021b6:	89 c8                	mov    %ecx,%eax
  8021b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021bb:	75 13                	jne    8021d0 <__umoddi3+0x30>
  8021bd:	39 f7                	cmp    %esi,%edi
  8021bf:	76 3f                	jbe    802200 <__umoddi3+0x60>
  8021c1:	89 f2                	mov    %esi,%edx
  8021c3:	f7 f7                	div    %edi
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	31 d2                	xor    %edx,%edx
  8021c9:	83 c4 20             	add    $0x20,%esp
  8021cc:	5e                   	pop    %esi
  8021cd:	5f                   	pop    %edi
  8021ce:	5d                   	pop    %ebp
  8021cf:	c3                   	ret    
  8021d0:	39 f2                	cmp    %esi,%edx
  8021d2:	77 4c                	ja     802220 <__umoddi3+0x80>
  8021d4:	0f bd ca             	bsr    %edx,%ecx
  8021d7:	83 f1 1f             	xor    $0x1f,%ecx
  8021da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8021dd:	75 51                	jne    802230 <__umoddi3+0x90>
  8021df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8021e2:	0f 87 e0 00 00 00    	ja     8022c8 <__umoddi3+0x128>
  8021e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021eb:	29 f8                	sub    %edi,%eax
  8021ed:	19 d6                	sbb    %edx,%esi
  8021ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f5:	89 f2                	mov    %esi,%edx
  8021f7:	83 c4 20             	add    $0x20,%esp
  8021fa:	5e                   	pop    %esi
  8021fb:	5f                   	pop    %edi
  8021fc:	5d                   	pop    %ebp
  8021fd:	c3                   	ret    
  8021fe:	66 90                	xchg   %ax,%ax
  802200:	85 ff                	test   %edi,%edi
  802202:	75 0b                	jne    80220f <__umoddi3+0x6f>
  802204:	b8 01 00 00 00       	mov    $0x1,%eax
  802209:	31 d2                	xor    %edx,%edx
  80220b:	f7 f7                	div    %edi
  80220d:	89 c7                	mov    %eax,%edi
  80220f:	89 f0                	mov    %esi,%eax
  802211:	31 d2                	xor    %edx,%edx
  802213:	f7 f7                	div    %edi
  802215:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802218:	f7 f7                	div    %edi
  80221a:	eb a9                	jmp    8021c5 <__umoddi3+0x25>
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	83 c4 20             	add    $0x20,%esp
  802227:	5e                   	pop    %esi
  802228:	5f                   	pop    %edi
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    
  80222b:	90                   	nop
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802234:	d3 e2                	shl    %cl,%edx
  802236:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802239:	ba 20 00 00 00       	mov    $0x20,%edx
  80223e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802241:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802244:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802248:	89 fa                	mov    %edi,%edx
  80224a:	d3 ea                	shr    %cl,%edx
  80224c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802250:	0b 55 f4             	or     -0xc(%ebp),%edx
  802253:	d3 e7                	shl    %cl,%edi
  802255:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802259:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80225c:	89 f2                	mov    %esi,%edx
  80225e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802261:	89 c7                	mov    %eax,%edi
  802263:	d3 ea                	shr    %cl,%edx
  802265:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802269:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80226c:	89 c2                	mov    %eax,%edx
  80226e:	d3 e6                	shl    %cl,%esi
  802270:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802274:	d3 ea                	shr    %cl,%edx
  802276:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80227a:	09 d6                	or     %edx,%esi
  80227c:	89 f0                	mov    %esi,%eax
  80227e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802281:	d3 e7                	shl    %cl,%edi
  802283:	89 f2                	mov    %esi,%edx
  802285:	f7 75 f4             	divl   -0xc(%ebp)
  802288:	89 d6                	mov    %edx,%esi
  80228a:	f7 65 e8             	mull   -0x18(%ebp)
  80228d:	39 d6                	cmp    %edx,%esi
  80228f:	72 2b                	jb     8022bc <__umoddi3+0x11c>
  802291:	39 c7                	cmp    %eax,%edi
  802293:	72 23                	jb     8022b8 <__umoddi3+0x118>
  802295:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802299:	29 c7                	sub    %eax,%edi
  80229b:	19 d6                	sbb    %edx,%esi
  80229d:	89 f0                	mov    %esi,%eax
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	d3 ef                	shr    %cl,%edi
  8022a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022a7:	d3 e0                	shl    %cl,%eax
  8022a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022ad:	09 f8                	or     %edi,%eax
  8022af:	d3 ea                	shr    %cl,%edx
  8022b1:	83 c4 20             	add    $0x20,%esp
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	39 d6                	cmp    %edx,%esi
  8022ba:	75 d9                	jne    802295 <__umoddi3+0xf5>
  8022bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8022bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022c2:	eb d1                	jmp    802295 <__umoddi3+0xf5>
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	39 f2                	cmp    %esi,%edx
  8022ca:	0f 82 18 ff ff ff    	jb     8021e8 <__umoddi3+0x48>
  8022d0:	e9 1d ff ff ff       	jmp    8021f2 <__umoddi3+0x52>
