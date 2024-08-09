stack_size = 8192 ;

MEMORY
{
  rom : o = 0x00000000, l = 128k
  ram : o = 0x10000000, l = 64k
}
SECTIONS
{
  .text :
 {
   __text_start = . ;
  *(.start)
  *(.text)
  *(.rodata)
   __text_end =  . ;
 }>rom
 .bss :
  {
    __bss_start = . ;
   __global_pointer$ = .;
   *(.bss)
   *(.sbss)
 
    __bss_end  = . ; 
  }>ram
.init : AT(__text_end)
 {
   __data_start = . ;
  *(.data)
  *(.sdata)
   __data_end =  . ;
 }>ram

 .stack :
  {
     . = ALIGN (16);
    __stack_start = . ;
     . = . + stack_size;
    __stack_end  = . ; 
    _sp = . ;
  }>ram


}
