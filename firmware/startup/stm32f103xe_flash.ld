/*
 ******************************************************************************
 * @file : stm32f103xe_flash.ld
 * @author : ZJY
 * @version : V1.0
 * @date : 2026-08-26
 * @brief : STM32F103RET6 的 GNU ld 链接脚本（CI 交叉编译用）
 * @attention : 与 Keil 侧的 firmware/MDK-ARM/pfa_imp.sct 是同一份内存布局的两种
 *              描述；改动其一必须同步另一份，另外 pfa_imp.uvprojx 里还有两处只影响
 *              µVision 界面的副本（见 docs/build.md「工具链私有的文件」）。
 *              堆长度为 0：本项目禁止动态内存分配。
 ******************************************************************************
 */

ENTRY(Reset_Handler)

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 512K
    RAM   (xrw) : ORIGIN = 0x20000000, LENGTH = 64K
}

/* 栈顶取 SRAM 末端；栈向下生长 */
_estack = ORIGIN(RAM) + LENGTH(RAM);

_Min_Stack_Size = 0x400;    /* 1 KB：M1 骨架的最小栈裕量，后续按任务栈重新核定 */
_Min_Heap_Size  = 0x0;      /* 禁止动态分配，堆长度恒为 0 */

SECTIONS
{
    /*
     * 中断向量表必须落在 Flash 起始处。ALIGN(512) 不是为了排版：VTOR 的 TBLOFF 要求
     * 向量表按「不小于表长的 2 的幂」对齐，76 个字即 512 字节。它现在是第一个输出节，
     * 落在 0x08000000 上自然满足，但那是巧合而非约束——写明对齐后，将来在它前面插入
     * 任何东西都不会悄悄破掉 VTOR 的前提。
     */
    .isr_vector : ALIGN(512)
    {
        KEEP(*(.isr_vector))
    } >FLASH

    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
        . = ALIGN(4);
    } >FLASH

    .rodata :
    {
        . = ALIGN(4);
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
    } >FLASH

    /*
     * 这里刻意不收 .init / .fini / .eh_frame / .ARM.extab / .ARM.exidx / .glue_7*：
     * 前三者服务于本项目不执行的 C 运行时初始化链（启动文件不调 __libc_init_array），
     * 中间两者是 C++ 异常展开表，最后一个是 ARM/Thumb 互调用桩，而 Cortex-M3 只有
     * Thumb。当前编译产物里这些节一个都没有（arm-none-eabi-readelf -S 可复核）。
     * 从厂家模板抄链接脚本时请勿顺手补回来。
     */

    .preinit_array :
    {
        . = ALIGN(4);
        PROVIDE_HIDDEN(__preinit_array_start = .);
        KEEP(*(.preinit_array*))
        PROVIDE_HIDDEN(__preinit_array_end = .);
        . = ALIGN(4);
    } >FLASH

    .init_array :
    {
        . = ALIGN(4);
        PROVIDE_HIDDEN(__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array*))
        PROVIDE_HIDDEN(__init_array_end = .);
        . = ALIGN(4);
    } >FLASH

    .fini_array :
    {
        . = ALIGN(4);
        PROVIDE_HIDDEN(__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array*))
        PROVIDE_HIDDEN(__fini_array_end = .);
        . = ALIGN(4);
    } >FLASH

    /* .data 的加载地址在 Flash，运行地址在 SRAM，由启动文件搬运 */
    _sidata = LOADADDR(.data);

    .data :
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data)
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } >RAM AT> FLASH

    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        __bss_start__ = _sbss;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
        __bss_end__ = _ebss;
    } >RAM

    /* 只做链接期容量校验：栈裕量放不下就报错，不产生任何运行时内容 */
    ._stack_check :
    {
        . = ALIGN(8);
        . = . + _Min_Heap_Size;
        . = . + _Min_Stack_Size;
        . = ALIGN(8);
    } >RAM

    .ARM.attributes 0 : { *(.ARM.attributes) }
}

/*
 * 向量表长度是硬件契约：16 个内核异常槽 + 60 路外部中断（对齐 stm32f103xe.h 的
 * IRQn_Type）。漏写一项不会报错，只会让其后所有向量整体前移一格——这种错要到
 * 运行时才暴露且极难查，所以在链接期钉死。
 */
ASSERT(SIZEOF(.isr_vector) == ((16 + 60) * 4),
       "中断向量表长度不等于 76 个字，向量顺序已错位")

/* VTOR 的 TBLOFF 低 9 位保留为 0，向量表地址必须 512 字节对齐 */
ASSERT((ADDR(.isr_vector) % 512) == 0,
       "中断向量表未按 512 字节对齐，SCB->VTOR 装不进这个地址")

/*
 * 启动文件不调用 __libc_init_array（理由见 startup_stm32f103xe.S），因此这三个
 * 数组必须为空；否则构造/析构函数会被静默跳过。让它在链接期就暴露出来。
 */
ASSERT(__preinit_array_end == __preinit_array_start,
       "存在 .preinit_array 条目，但启动文件不会执行它们")
ASSERT(__init_array_end == __init_array_start,
       "存在 .init_array 条目（静态构造函数？），但启动文件不会执行它们")
ASSERT(__fini_array_end == __fini_array_start,
       "存在 .fini_array 条目，但启动文件不会执行它们")
