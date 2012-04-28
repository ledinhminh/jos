	.file	"init.c"
	.stabs	"kern/init.c",100,0,2,.Ltext0
	.text
.Ltext0:
	.stabs	"gcc2_compiled.",60,0,0,0
	.stabs	"int:t(0,1)=r(0,1);-2147483648;2147483647;",128,0,0,0
	.stabs	"char:t(0,2)=r(0,2);0;127;",128,0,0,0
	.stabs	"long int:t(0,3)=r(0,3);-2147483648;2147483647;",128,0,0,0
	.stabs	"unsigned int:t(0,4)=r(0,4);0;4294967295;",128,0,0,0
	.stabs	"long unsigned int:t(0,5)=r(0,5);0;4294967295;",128,0,0,0
	.stabs	"long long int:t(0,6)=r(0,6);-0;4294967295;",128,0,0,0
	.stabs	"long long unsigned int:t(0,7)=r(0,7);0;-1;",128,0,0,0
	.stabs	"short int:t(0,8)=r(0,8);-32768;32767;",128,0,0,0
	.stabs	"short unsigned int:t(0,9)=r(0,9);0;65535;",128,0,0,0
	.stabs	"signed char:t(0,10)=r(0,10);-128;127;",128,0,0,0
	.stabs	"unsigned char:t(0,11)=r(0,11);0;255;",128,0,0,0
	.stabs	"float:t(0,12)=r(0,1);4;0;",128,0,0,0
	.stabs	"double:t(0,13)=r(0,1);8;0;",128,0,0,0
	.stabs	"long double:t(0,14)=r(0,1);12;0;",128,0,0,0
	.stabs	"_Decimal32:t(0,15)=r(0,1);4;0;",128,0,0,0
	.stabs	"_Decimal64:t(0,16)=r(0,1);8;0;",128,0,0,0
	.stabs	"_Decimal128:t(0,17)=r(0,1);16;0;",128,0,0,0
	.stabs	"void:t(0,18)=(0,18)",128,0,0,0
	.stabs	"./inc/stdio.h",130,0,0,0
	.stabs	"./inc/stdarg.h",130,0,0,0
	.stabs	"va_list:t(2,1)=(2,2)=*(0,2)",128,0,0,0
	.stabn	162,0,0,0
	.stabn	162,0,0,0
	.stabs	"./inc/string.h",130,0,0,0
	.stabs	"./inc/types.h",130,0,0,0
	.stabs	"bool:t(4,1)=(0,1)",128,0,0,0
	.stabs	"int8_t:t(4,2)=(0,10)",128,0,0,0
	.stabs	"uint8_t:t(4,3)=(0,11)",128,0,0,0
	.stabs	"int16_t:t(4,4)=(0,8)",128,0,0,0
	.stabs	"uint16_t:t(4,5)=(0,9)",128,0,0,0
	.stabs	"int32_t:t(4,6)=(0,1)",128,0,0,0
	.stabs	"uint32_t:t(4,7)=(0,4)",128,0,0,0
	.stabs	"int64_t:t(4,8)=(0,6)",128,0,0,0
	.stabs	"uint64_t:t(4,9)=(0,7)",128,0,0,0
	.stabs	"intptr_t:t(4,10)=(4,6)",128,0,0,0
	.stabs	"uintptr_t:t(4,11)=(4,7)",128,0,0,0
	.stabs	"physaddr_t:t(4,12)=(4,7)",128,0,0,0
	.stabs	"ppn_t:t(4,13)=(4,7)",128,0,0,0
	.stabs	"size_t:t(4,14)=(4,7)",128,0,0,0
	.stabs	"ssize_t:t(4,15)=(4,6)",128,0,0,0
	.stabs	"off_t:t(4,16)=(4,6)",128,0,0,0
	.stabn	162,0,0,0
	.stabn	162,0,0,0
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"kernel warning at %s:%d: "
.LC1:
	.string	"\n"
	.text
	.p2align 4,,15
	.stabs	"_warn:F(0,18)",36,0,0,_warn
	.stabs	"file:p(0,19)=*(0,2)",160,0,0,8
	.stabs	"line:p(0,1)",160,0,0,12
	.stabs	"fmt:p(0,19)",160,0,0,16
.globl _warn
	.type	_warn, @function
_warn:
	.stabn	68,0,93,.LM0-.LFBB1
.LM0:
.LFBB1:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$20, %esp
	.stabn	68,0,97,.LM1-.LFBB1
.LM1:
	movl	12(%ebp), %eax
	movl	$.LC0, (%esp)
	.stabn	68,0,92,.LM2-.LFBB1
.LM2:
	leal	20(%ebp), %ebx
	.stabn	68,0,97,.LM3-.LFBB1
.LM3:
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	call	cprintf
	.stabn	68,0,98,.LM4-.LFBB1
.LM4:
	movl	16(%ebp), %eax
	movl	%ebx, 4(%esp)
	movl	%eax, (%esp)
	call	vcprintf
	.stabn	68,0,99,.LM5-.LFBB1
.LM5:
	movl	$.LC1, (%esp)
	call	cprintf
	.stabn	68,0,101,.LM6-.LFBB1
.LM6:
	addl	$20, %esp
	popl	%ebx
	popl	%ebp
	ret
	.size	_warn, .-_warn
	.stabs	"file:r(0,19)",64,0,0,0
	.stabs	"line:r(0,1)",64,0,0,0
	.stabs	"fmt:r(0,19)",64,0,0,0
.Lscope1:
	.section	.rodata.str1.1
.LC2:
	.string	"kernel panic at %s:%d: "
	.text
	.p2align 4,,15
	.stabs	"_panic:F(0,18)",36,0,0,_panic
	.stabs	"file:p(0,19)",160,0,0,8
	.stabs	"line:p(0,1)",160,0,0,12
	.stabs	"fmt:p(0,19)",160,0,0,16
.globl _panic
	.type	_panic, @function
_panic:
	.stabn	68,0,68,.LM7-.LFBB2
.LM7:
.LFBB2:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%esi
	pushl	%ebx
	subl	$16, %esp
	.stabn	68,0,68,.LM8-.LFBB2
.LM8:
	movl	16(%ebp), %ebx
	.stabn	68,0,71,.LM9-.LFBB2
.LM9:
	cmpl	$0, panicstr
	je	.L8
	.p2align 4,,7
	.p2align 3
.L6:
	.stabn	68,0,87,.LM10-.LFBB2
.LM10:
	movl	$0, (%esp)
	call	monitor
	jmp	.L6
.L8:
	.stabn	68,0,73,.LM11-.LFBB2
.LM11:
	movl	%ebx, panicstr
	.stabn	68,0,76,.LM12-.LFBB2
.LM12:
#APP
# 76 "kern/init.c" 1
	cli; cld
# 0 "" 2
	.stabn	68,0,79,.LM13-.LFBB2
.LM13:
#NO_APP
	movl	12(%ebp), %eax
	.stabn	68,0,67,.LM14-.LFBB2
.LM14:
	leal	20(%ebp), %esi
	.stabn	68,0,79,.LM15-.LFBB2
.LM15:
	movl	$.LC2, (%esp)
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	call	cprintf
	.stabn	68,0,80,.LM16-.LFBB2
.LM16:
	movl	%esi, 4(%esp)
	movl	%ebx, (%esp)
	call	vcprintf
	.stabn	68,0,81,.LM17-.LFBB2
.LM17:
	movl	$.LC1, (%esp)
	call	cprintf
	jmp	.L6
	.size	_panic, .-_panic
	.stabs	"file:r(0,19)",64,0,0,0
	.stabs	"line:r(0,1)",64,0,0,0
	.stabs	"fmt:r(0,19)",64,0,0,3
.Lscope2:
	.section	.rodata.str1.1
.LC3:
	.string	"entering test_backtrace %d\n"
.LC4:
	.string	"leaving test_backtrace %d\n"
	.text
	.p2align 4,,15
	.stabs	"test_backtrace:F(0,18)",36,0,0,test_backtrace
	.stabs	"x:p(0,1)",160,0,0,8
.globl test_backtrace
	.type	test_backtrace, @function
test_backtrace:
	.stabn	68,0,13,.LM18-.LFBB3
.LM18:
.LFBB3:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$20, %esp
	.stabn	68,0,13,.LM19-.LFBB3
.LM19:
	movl	8(%ebp), %ebx
	.stabn	68,0,14,.LM20-.LFBB3
.LM20:
	movl	$.LC3, (%esp)
	movl	%ebx, 4(%esp)
	call	cprintf
	.stabn	68,0,15,.LM21-.LFBB3
.LM21:
	testl	%ebx, %ebx
	jle	.L10
	.stabn	68,0,16,.LM22-.LFBB3
.LM22:
	leal	-1(%ebx), %eax
	movl	%eax, (%esp)
	call	test_backtrace
.L11:
	.stabn	68,0,19,.LM23-.LFBB3
.LM23:
	movl	%ebx, 4(%esp)
	movl	$.LC4, (%esp)
	call	cprintf
	.stabn	68,0,20,.LM24-.LFBB3
.LM24:
	addl	$20, %esp
	popl	%ebx
	popl	%ebp
	ret
	.p2align 4,,7
	.p2align 3
.L10:
	.stabn	68,0,18,.LM25-.LFBB3
.LM25:
	movl	$0, 8(%esp)
	movl	$0, 4(%esp)
	movl	$0, (%esp)
	call	mon_backtrace
	jmp	.L11
	.size	test_backtrace, .-test_backtrace
	.stabs	"x:r(0,1)",64,0,0,3
.Lscope3:
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align 4
.LC5:
	.string	"6828 decimal is %o octal!%n\n%n"
	.section	.rodata.str1.1
.LC6:
	.string	"chnum1: %d chnum2: %d\n"
.LC7:
	.string	"%n"
.LC8:
	.string	"%s%n"
.LC9:
	.string	"chnum1: %d\n"
	.text
	.p2align 4,,15
	.stabs	"i386_init:F(0,18)",36,0,0,i386_init
.globl i386_init
	.type	i386_init, @function
i386_init:
	.stabn	68,0,24,.LM26-.LFBB4
.LM26:
.LFBB4:
	pushl	%ebp
	.stabn	68,0,27,.LM27-.LFBB4
.LM27:
	movl	$64, %ecx
	.stabn	68,0,24,.LM28-.LFBB4
.LM28:
	movl	%esp, %ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	subl	$300, %esp
	.stabn	68,0,24,.LM29-.LFBB4
.LM29:
	movl	%gs:20, %eax
	movl	%eax, -28(%ebp)
	xorl	%eax, %eax
	.stabn	68,0,27,.LM30-.LFBB4
.LM30:
	leal	-284(%ebp), %edx
	movl	%edx, %edi
	.stabn	68,0,38,.LM31-.LFBB4
.LM31:
	leal	-285(%ebp), %esi
	.stabn	68,0,27,.LM32-.LFBB4
.LM32:
	movb	$0, -285(%ebp)
	.stabn	68,0,41,.LM33-.LFBB4
.LM33:
	leal	-284(%ebp), %ebx
	.stabn	68,0,27,.LM34-.LFBB4
.LM34:
	movb	$0, -286(%ebp)
	rep stosl
	.stabn	68,0,32,.LM35-.LFBB4
.LM35:
	movl	$end, %eax
	subl	$edata, %eax
	movl	%eax, 8(%esp)
	movl	$0, 4(%esp)
	movl	$edata, (%esp)
	call	memset
	.stabn	68,0,36,.LM36-.LFBB4
.LM36:
	call	cons_init
	.stabn	68,0,38,.LM37-.LFBB4
.LM37:
	leal	-286(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	%esi, 8(%esp)
	movl	$6828, 4(%esp)
	movl	$.LC5, (%esp)
	call	cprintf
	.stabn	68,0,39,.LM38-.LFBB4
.LM38:
	movsbl	-286(%ebp),%eax
	movl	$.LC6, (%esp)
	movl	%eax, 8(%esp)
	movsbl	-285(%ebp),%eax
	movl	%eax, 4(%esp)
	call	cprintf
	.stabn	68,0,40,.LM39-.LFBB4
.LM39:
	movl	$0, 4(%esp)
	movl	$.LC7, (%esp)
	call	cprintf
	.stabn	68,0,41,.LM40-.LFBB4
.LM40:
	movl	$255, 8(%esp)
	movl	$13, 4(%esp)
	movl	%ebx, (%esp)
	call	memset
	.stabn	68,0,42,.LM41-.LFBB4
.LM41:
	movl	%esi, 8(%esp)
	movl	%ebx, 4(%esp)
	movl	$.LC8, (%esp)
	call	cprintf
	.stabn	68,0,43,.LM42-.LFBB4
.LM42:
	movsbl	-285(%ebp),%eax
	movl	$.LC9, (%esp)
	movl	%eax, 4(%esp)
	call	cprintf
	.stabn	68,0,48,.LM43-.LFBB4
.LM43:
	movl	$5, (%esp)
	call	test_backtrace
	.p2align 4,,7
	.p2align 3
.L14:
	.stabn	68,0,52,.LM44-.LFBB4
.LM44:
	movl	$0, (%esp)
	call	monitor
	jmp	.L14
	.size	i386_init, .-i386_init
	.stabs	"chnum1:(0,2)",128,0,0,-285
	.stabs	"chnum2:(0,2)",128,0,0,-286
	.stabs	"ntest:(0,20)=ar(0,21)=r(0,21);0;-1;;0;255;(0,2)",128,0,0,-284
	.stabn	192,0,0,.LFBB4-.LFBB4
	.stabn	224,0,0,.Lscope4-.LFBB4
.Lscope4:
	.local	panicstr
	.comm	panicstr,4,4
	.stabs	"panicstr:S(0,19)",40,0,0,panicstr
	.stabs	"",100,0,0,.Letext0
.Letext0:
	.ident	"GCC: (Ubuntu/Linaro 4.4.4-14ubuntu5.1) 4.4.5"
	.section	.note.GNU-stack,"",@progbits
