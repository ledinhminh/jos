// evil hello world -- kernel pointer passed to kernel
// kernel should destroy user environment in response

#include <inc/lib.h>
#include <inc/mmu.h>
#include <inc/x86.h>

char tmp[2*PGSIZE];
// Call this function with ring0 privilege
void evil()
{
	// Kernel memory access
	*(char*)0xf010000a = 0;

	// Out put something via outb
	outb(0x3f8, 'I');
	outb(0x3f8, 'N');
	outb(0x3f8, ' ');
	outb(0x3f8, 'R');
	outb(0x3f8, 'I');
	outb(0x3f8, 'N');
	outb(0x3f8, 'G');
	outb(0x3f8, '0');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '\n');
}

static void
sgdt(struct Pseudodesc* gdtd)
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
}

// Invoke a given function pointer with ring0 privilege, then return to ring3
void ring0_call(void (*fun_ptr)(void)) {
    // Here's some hints on how to achieve this.
    // 1. Store the GDT descripter to memory (sgdt instruction)
    // 2. Map GDT in user space (sys_map_kernel_page)
    // 3. Setup a CALLGATE in GDT (SETCALLGATE macro)
    // 4. Enter ring0 (lcall instruction)
    // 5. Call the function pointer
    // 6. Recover GDT entry modified in step 3 (if any)
    // 7. Leave ring0 (lret instruction)

    // Hint : use a wrapper function to call fun_ptr. Feel free
    //        to add any functions or global variables in this 
    //        file if necessary.

    // Lab3 : Your Code Here
    //1
    struct Pseudodesc lgdtcopy;
    sgdt(&lgdtcopy);
    //2
    sys_map_kernel_page((void*)(lgdtcopy.pd_base),(void*)&tmp[PGSIZE]);
    //3
    struct Gatedesc* gatedesc = &(((struct Gatedesc*)(
									(lgdtcopy.pd_base - ROUNDDOWN(lgdtcopy.pd_base,PGSIZE)) + ROUNDDOWN((&tmp[PGSIZE]),PGSIZE)
									))
									[3]
								);
    struct Gatedesc  savegate = *gatedesc;
    SETCALLGATE(*gatedesc,GD_KT,0x8000e5,3);
    //4
    __asm __volatile("lcall $0x1b,$0\n");
    //5
    fun_ptr();
    //6
    *gatedesc = savegate;
    //7
    __asm __volatile("lret \n");
    return;
    
}

void
umain(int argc, char **argv)
{
        // call the evil function in ring0

	ring0_call(&evil);
	// call the evil function in ring3
	evil();
}

