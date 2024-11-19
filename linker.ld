SECTIONS
{
	.text : {
		. = ALIGN(512);
		*(.text)
	}

	/* Read-only data. */
	.rodata :
	{
		. = ALIGN(512);
		*(.rodata)
	}

	/* Read-write data (initialized) */
	.data :
	{
		. = ALIGN(512);
		*(.data)
	}

	/* Read-write data (uninitialized) and stack */
	.bss :
	{
		. = ALIGN(512);
		*(COMMON)
		*(.bss)
	}
}
