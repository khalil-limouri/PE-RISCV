MEMORY
{
  rom      (rx)  : ORIGIN = 0x00000000, LENGTH = 0x000040000
  /* ram      (rwx) : ORIGIN = 0x00000000, LENGTH = 0x000400000 */ /* overlap ram<->rom => linker error */
  ram      (rwx) : ORIGIN = 0x000040000, LENGTH = 0x0003C0000       /* unused ram space but no more overlap */
}

/* Section Definitions */
SECTIONS
{
    .text :
    {
        *(.text.prologue);
        *(.text*)
        *(.rodata*)
    } > rom

    /* .bss section which is used for initialized data */
    .data :
    {
        *(.data*);
    } > rom /* trick: we will used the same binary for ram and rom */
    _edata = .;

    /* .bss section which is used for uninitialized data */
    .bss (NOLOAD) :
    {
        *(.bss*)
        *(COMMON)
    } > ram

    _end = . ;
}
