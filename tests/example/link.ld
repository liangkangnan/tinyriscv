OUTPUT_ARCH( "riscv" )
ENTRY(_reset)

SECTIONS
{
    __stack_size = 0x100;

    . = 0x00000000;
    .text : { *(.text) }

    PROVIDE( _data_start = . );
    .data ALIGN(0x1000) : { *(.data) }
    . = ALIGN(4);
    PROVIDE( _data_end = . );

    PROVIDE( _bss_start = . );
    .bss : { *(.bss) }
    PROVIDE( _bss_end = . );

    PROVIDE(_stack_begin = .);
    . = __stack_size;
    PROVIDE( _sp = . );
    PROVIDE(_stack_end = .);
    _end = .;
}
