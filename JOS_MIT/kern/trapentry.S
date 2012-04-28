/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(trap_ex_divide, T_DIVIDE)
TRAPHANDLER_NOEC(trap_ex_debug, T_DEBUG)
TRAPHANDLER_NOEC(trap_ex_nmi, T_NMI)
TRAPHANDLER_NOEC(trap_ex_break_point, T_BRKPT)
TRAPHANDLER_NOEC(trap_ex_overflow, T_OFLOW)
TRAPHANDLER_NOEC(trap_ex_bound, T_BOUND)
TRAPHANDLER_NOEC(trap_ex_iop, T_ILLOP)
TRAPHANDLER_NOEC(trap_ex_device, T_DEVICE)
TRAPHANDLER(trap_ex_db_fault, T_DBLFLT)
TRAPHANDLER(trap_ex_tss, T_TSS)
TRAPHANDLER(trap_ex_segnp, T_SEGNP)
TRAPHANDLER(trap_ex_stack, T_STACK)
TRAPHANDLER(trap_ex_gp_fault, T_GPFLT)
TRAPHANDLER(trap_ex_pg_fault, T_PGFLT)
TRAPHANDLER_NOEC(trap_ex_fp_error, T_FPERR)
TRAPHANDLER(trap_ex_align, T_ALIGN)
TRAPHANDLER_NOEC(trap_ex_mcheck, T_MCHK)
TRAPHANDLER_NOEC(trap_ex_simderr, T_SIMDERR)
TRAPHANDLER_NOEC(trap_ex_syscall, T_SYSCALL)
 
#.globl sysenter_handler;
#.type sysenter_handler, @function;
#.align 2;
#sysenter_handler:
#	pushl $0x0 /* parameters to syscall */
#	pushl %edi
#	pushl %ebx
#	pushl %ecx
#	pushl %edx
#	pushl %eax
#	call syscall
#	addl $0x18, %esp /* kill all the parameters */
#	movl %esi, %edx
#	movl %ebp, %ecx
#	sysexit
/*
 * Lab 3: Your code here for system call handling
 */


/*
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
        # fill trap frame
        pushl %ds
        pushl %es
        pushal

        # set up segment (wrong here)
	movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es
        #movw GD_KD, %ds
        #movw GD_KD, %es

	pushl %esp
	movl $0x0, %ebp
        
# call trap(tf), where tf=%esp
	call trap
	addl $0x4, %esp
	popal
	popl %es
	popl %ds

	addl $0x8, %esp /* skip tf_trapno and tf_errcode */
	iret

