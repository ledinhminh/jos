/* See COPYRIGHT for copyright information. */

#ifndef JOS_KERN_TRAP_H
#define JOS_KERN_TRAP_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

#include <inc/trap.h>
#include <inc/mmu.h>

/* The kernel's interrupt descriptor table */
extern struct Gatedesc idt[];
extern struct Pseudodesc idt_pd;

void trap_init(void);
void trap_init_percpu(void);
void print_regs(struct PushRegs *regs);
void print_trapframe(struct Trapframe *tf);
void page_fault_handler(struct Trapframe *);
void backtrace(struct Trapframe *);

void trap_ex_divide(void);
void trap_ex_debug(void);
void trap_ex_nmi(void);
void trap_ex_break_point(void);
void trap_ex_overflow(void);
void trap_ex_bound(void);
void trap_ex_iop(void);
void trap_ex_device(void);
void trap_ex_db_fault(void);
void trap_ex_tss(void);
void trap_ex_segnp(void);
void trap_ex_stack(void);
void trap_ex_gp_fault(void);
void trap_ex_pg_fault(void);
void trap_ex_fp_error(void);
void trap_ex_align(void);
void trap_ex_mcheck(void);
void trap_ex_simderr(void);
void trap_ex_syscall(void);


#endif /* JOS_KERN_TRAP_H */
