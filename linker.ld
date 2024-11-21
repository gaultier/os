ENTRY(kmain);

SECTIONS
{

	.text 0x07e00 : {
		*(.text) 
	}

	/* Read-only data. */
	.rodata :  
	{
		*(.rodata)
	}

	/* Read-write data (initialized) */
	.data :
	{
		*(.data)
	}

	/* Read-write data (uninitialized) and stack */
	.bss :
	{
		*(COMMON)
		*(.bss)
	}
}
