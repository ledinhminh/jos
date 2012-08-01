#include <kern/e1000.h>

// LAB 6: Your driver code here
#include <kern/pmap.h>

int
pci_E1000_attach(struct pci_func *pcif)
{
	pci_func_enable(pcif);
	//cprintf("size need:%d\n",pcif->reg_size[0]);//need 128KB
	

	boot_map_region(kern_pgdir,E1000IO,pcif->reg_size[0],pcif->reg_base[0],PTE_PCD|PTE_PWT|PTE_W);
	e1000 = (void*)(E1000IO);	//used like lapic
	cprintf("dsr  %x pa %x : %x\n",e1000,pcif->reg_base[0],*(int*)(&e1000[E1000_STATUS]));  //DSR offset 0008h.Pay attention that the offset is byte but the data is int(4 byte)


	//transmit initialization s14.5	
	*(uint32_t*)(&e1000[E1000_TDBAL]) = TX_DESC_RING_BASE;
	*(uint32_t*)(&e1000[E1000_TDBAH]) = 0;					//32 not needed
	*(uint32_t*)(&e1000[E1000_TDLEN]) = TX_DESC_RING_LENGTH;
	*(uint32_t*)(&e1000[E1000_TDH])	  = 0;
	*(uint32_t*)(&e1000[E1000_TDT])   = 0;

	tx_desc_head = (uint32_t*)(&e1000[E1000_TDH]);
	tx_desc_tail = (uint32_t*)(&e1000[E1000_TDT]);
	
	
	

	//initialize TCTL
	uint32_t *tctl = (uint32_t*)(&e1000[E1000_TCTL]);
	*tctl |= E1000_TCTL_EN;		//1b
	*tctl |= E1000_TCTL_PSP;	//1b
	*tctl |= E1000_TCTL_CT  & ((0x10)<<4 );  
	*tctl |= E1000_TCTL_COLD& ((0x40)<<12);
	
	/* E1000_transmit((char*)&ncpu,4); */
	return 1;
}

int E1000_transmit(char* buf,int length){
	struct e1000_tx_desc *transmit_desc =  &tx_desc_ring[(*tx_desc_tail)];
	if(	(transmit_desc->lower.flags.cmd & E1000_TXD_CMD_RS) &&
		!(transmit_desc->upper.fields.status & E1000_TXD_STAT_DD)
        ) {
		cprintf("tx_desc_ring is full\n");
		return -1;
	}
	
	transmit_desc->buffer_addr = (uint32_t)PADDR(buf);
	transmit_desc->lower.flags.length = (uint16_t)length;
	transmit_desc->lower.data |= E1000_TXD_CMD_RS | E1000_TXD_CMD_IDE | E1000_TXD_CMD_RPS | E1000_TXD_CMD_TCP;
	int nexttail = *tx_desc_tail;
	nexttail = (nexttail+1)%TX_DESC_RING_SIZE;
	*tx_desc_tail = nexttail;	//use a variable to count.

	return 0;
}
