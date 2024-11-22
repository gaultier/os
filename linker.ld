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

	/* Read-write data (uninitialized) */
	.bss :
	{
	  *(COMMON);
		*(.bss)
	}

	. = ALIGN(512);
	.pad : {
			. = . + (512 - (. % 512)) % 512;
			BYTE(0)
	}
}
