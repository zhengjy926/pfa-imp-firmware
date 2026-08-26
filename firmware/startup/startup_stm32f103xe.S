/**
 ******************************************************************************
 * @file : startup_stm32f103xe.S
 * @author : ZJY
 * @version : V1.0
 * @date : 2026-08-26
 * @brief : STM32F103RET6 手工维护的启动文件与中断向量表
 * @attention : 本文件同时供 arm-none-eabi-gcc（CI 交叉编译）与 Keil MDK AC6
 *              （armclang 集成汇编器）使用，故采用 GNU 汇编语法并经预处理器
 *              分支。向量表只有这一份，避免双工具链各持一份而静默分叉。
 *              两条工具链的差异仅在复位后的运行时初始化方式：
 *                - AC6：跳 __main，由 armlink 的 scatter-load 完成 RW/ZI 初始化；
 *                - GCC：本文件自行搬 .data、清 .bss，然后直接进 main。
 *              两条路径都不执行 .init_array（本项目无静态构造函数，理由见下方
 *              进 main 前的注释；链接脚本有断言兜底）。
 *              本文件不配置任何 GPIO，故上电路径不闭合任何继电器。
 ******************************************************************************
 * @history :
 * V1.0 : 1.建立 M1 骨架的启动文件与 60 路 IRQ 向量表（对齐 stm32f103xe.h 的 IRQn_Type）
 *
 *
 ******************************************************************************
 */

    .syntax unified
    .thumb

/* 栈顶符号：两条工具链由各自的链接描述提供，符号名不同 */
#if defined(__ARMCC_VERSION)
#define STACK_TOP   Image$$ARM_LIB_STACK$$ZI$$Limit
#else
#define STACK_TOP   _estack
#endif

/* ---------------------------------------------------------------------------
 * 中断向量表
 * -------------------------------------------------------------------------*/
    .section .isr_vector, "a", %progbits
    .type g_pfnVectors, %object
    .global g_pfnVectors

g_pfnVectors:
    .word STACK_TOP                     /* 0  初始栈指针，复位时由硬件装入 SP */
    .word Reset_Handler                 /* 1  复位 */
    .word NMI_Handler                   /* 2  不可屏蔽中断 */
    .word HardFault_Handler             /* 3  硬故障 */
    .word MemManage_Handler             /* 4  存储管理故障 */
    .word BusFault_Handler              /* 5  总线故障 */
    .word UsageFault_Handler            /* 6  用法故障 */
    .word 0                             /* 7  保留 */
    .word 0                             /* 8  保留 */
    .word 0                             /* 9  保留 */
    .word 0                             /* 10 保留 */
    .word SVC_Handler                   /* 11 系统服务调用 */
    .word DebugMon_Handler              /* 12 调试监视器 */
    .word 0                             /* 13 保留 */
    .word PendSV_Handler                /* 14 可挂起系统服务 */
    .word SysTick_Handler               /* 15 系统节拍 */

    /* 外部中断 IRQ 0..59，顺序与 stm32f103xe.h 的 IRQn_Type 严格一致 */
    .word WWDG_IRQHandler               /* 0  窗口看门狗 */
    .word PVD_IRQHandler                /* 1  PVD 经 EXTI 检测 */
    .word TAMPER_IRQHandler             /* 2  入侵检测 */
    .word RTC_IRQHandler                /* 3  RTC 全局 */
    .word FLASH_IRQHandler              /* 4  Flash 全局 */
    .word RCC_IRQHandler                /* 5  RCC 全局 */
    .word EXTI0_IRQHandler              /* 6  EXTI 线 0 */
    .word EXTI1_IRQHandler              /* 7  EXTI 线 1 */
    .word EXTI2_IRQHandler              /* 8  EXTI 线 2 */
    .word EXTI3_IRQHandler              /* 9  EXTI 线 3 */
    .word EXTI4_IRQHandler              /* 10 EXTI 线 4 */
    .word DMA1_Channel1_IRQHandler      /* 11 DMA1 通道 1 */
    .word DMA1_Channel2_IRQHandler      /* 12 DMA1 通道 2 */
    .word DMA1_Channel3_IRQHandler      /* 13 DMA1 通道 3 */
    .word DMA1_Channel4_IRQHandler      /* 14 DMA1 通道 4 */
    .word DMA1_Channel5_IRQHandler      /* 15 DMA1 通道 5 */
    .word DMA1_Channel6_IRQHandler      /* 16 DMA1 通道 6 */
    .word DMA1_Channel7_IRQHandler      /* 17 DMA1 通道 7 */
    .word ADC1_2_IRQHandler             /* 18 ADC1 与 ADC2 全局 */
    .word USB_HP_CAN1_TX_IRQHandler     /* 19 USB 高优先级或 CAN1 发送 */
    .word USB_LP_CAN1_RX0_IRQHandler    /* 20 USB 低优先级或 CAN1 接收 0 */
    .word CAN1_RX1_IRQHandler           /* 21 CAN1 接收 1 */
    .word CAN1_SCE_IRQHandler           /* 22 CAN1 状态改变/错误 */
    .word EXTI9_5_IRQHandler            /* 23 EXTI 线 [9:5] */
    .word TIM1_BRK_IRQHandler           /* 24 TIM1 刹车 */
    .word TIM1_UP_IRQHandler            /* 25 TIM1 更新 */
    .word TIM1_TRG_COM_IRQHandler       /* 26 TIM1 触发与换相 */
    .word TIM1_CC_IRQHandler            /* 27 TIM1 捕获比较 */
    .word TIM2_IRQHandler               /* 28 TIM2 全局 */
    .word TIM3_IRQHandler               /* 29 TIM3 全局 */
    .word TIM4_IRQHandler               /* 30 TIM4 全局 */
    .word I2C1_EV_IRQHandler            /* 31 I2C1 事件 */
    .word I2C1_ER_IRQHandler            /* 32 I2C1 错误 */
    .word I2C2_EV_IRQHandler            /* 33 I2C2 事件 */
    .word I2C2_ER_IRQHandler            /* 34 I2C2 错误 */
    .word SPI1_IRQHandler               /* 35 SPI1 全局 */
    .word SPI2_IRQHandler               /* 36 SPI2 全局 */
    .word USART1_IRQHandler             /* 37 USART1 全局 */
    .word USART2_IRQHandler             /* 38 USART2 全局 */
    .word USART3_IRQHandler             /* 39 USART3 全局 */
    .word EXTI15_10_IRQHandler          /* 40 EXTI 线 [15:10] */
    .word RTC_Alarm_IRQHandler          /* 41 RTC 闹钟经 EXTI */
    .word USBWakeUp_IRQHandler          /* 42 USB 挂起唤醒经 EXTI */
    .word TIM8_BRK_IRQHandler           /* 43 TIM8 刹车 */
    .word TIM8_UP_IRQHandler            /* 44 TIM8 更新 */
    .word TIM8_TRG_COM_IRQHandler       /* 45 TIM8 触发与换相 */
    .word TIM8_CC_IRQHandler            /* 46 TIM8 捕获比较 */
    .word ADC3_IRQHandler               /* 47 ADC3 全局 */
    .word FSMC_IRQHandler               /* 48 FSMC 全局 */
    .word SDIO_IRQHandler               /* 49 SDIO 全局 */
    .word TIM5_IRQHandler               /* 50 TIM5 全局 */
    .word SPI3_IRQHandler               /* 51 SPI3 全局 */
    .word UART4_IRQHandler              /* 52 UART4 全局 */
    .word UART5_IRQHandler              /* 53 UART5 全局 */
    .word TIM6_IRQHandler               /* 54 TIM6 全局 */
    .word TIM7_IRQHandler               /* 55 TIM7 全局 */
    .word DMA2_Channel1_IRQHandler      /* 56 DMA2 通道 1 */
    .word DMA2_Channel2_IRQHandler      /* 57 DMA2 通道 2 */
    .word DMA2_Channel3_IRQHandler      /* 58 DMA2 通道 3 */
    .word DMA2_Channel4_5_IRQHandler    /* 59 DMA2 通道 4 与通道 5 */

    .size g_pfnVectors, . - g_pfnVectors

/* ---------------------------------------------------------------------------
 * 复位入口
 * -------------------------------------------------------------------------*/
    .section .text.Reset_Handler, "ax", %progbits
    .type Reset_Handler, %function
    .global Reset_Handler
    .thumb_func
Reset_Handler:
    /* 复位时硬件已从向量表装入 SP；此处显式重装，使两条工具链行为一致 */
    ldr   r0, =STACK_TOP
    mov   sp, r0

    /* 时钟与 Flash 等待周期先于任何 C 代码配置；SystemInit 不依赖已初始化的全局量 */
    bl    SystemInit

#if defined(__ARMCC_VERSION)
    /* AC6：RW 搬运与 ZI 清零由 armlink 的 scatter-load 在 __main 内完成 */
    ldr   r0, =__main
    bx    r0
#else
    /* GCC：自行把 .data 从 Flash 搬到 SRAM */
    ldr   r0, =_sdata
    ldr   r1, =_edata
    ldr   r2, =_sidata
    movs  r3, #0
    b     LoopCopyData
CopyData:
    ldr   r4, [r2, r3]
    str   r4, [r0, r3]
    adds  r3, r3, #4
LoopCopyData:
    adds  r4, r0, r3
    cmp   r4, r1
    bcc   CopyData

    /* GCC：清零 .bss */
    ldr   r2, =_sbss
    ldr   r4, =_ebss
    movs  r3, #0
    b     LoopZeroBss
ZeroBss:
    str   r3, [r2]
    adds  r2, r2, #4
LoopZeroBss:
    cmp   r2, r4
    bcc   ZeroBss

    /*
     * 不调用 __libc_init_array：本项目是 C99 + MISRA C:2012，没有静态构造函数，
     * 且该函数依赖 crti/crtn 提供的 _init，而我们以 -nostartfiles 排除了 crt0
     * （crt0 会引用 exit 并顺带拖进 stdio 与 _malloc_r）。链接脚本里有断言保证
     * .init_array/.fini_array 为空，一旦真出现构造函数会在链接期报错，而不是被
     * 静默跳过。
     */
    bl    main

    /* main 不应返回；返回即停在此处等看门狗/调试器介入 */
LoopForever:
    b     LoopForever
#endif
    .size Reset_Handler, . - Reset_Handler

/* ---------------------------------------------------------------------------
 * 缺省中断服务程序
 *
 * 未被实现覆盖的向量都指向这里。M1 骨架只做死循环停机，不做故障落盘；
 * HardFault 现场落 EEPROM 属后续里程碑（见 ADR 0004）。
 * -------------------------------------------------------------------------*/
    .section .text.Default_Handler, "ax", %progbits
    .type Default_Handler, %function
    .global Default_Handler
    .thumb_func
Default_Handler:
    b     Default_Handler
    .size Default_Handler, . - Default_Handler

/* 弱符号：上层实现同名函数即自动覆盖 */
    .macro  DEFAULT_VECTOR name
    .weak   \name
    .thumb_set \name, Default_Handler
    .endm

    DEFAULT_VECTOR NMI_Handler
    DEFAULT_VECTOR HardFault_Handler
    DEFAULT_VECTOR MemManage_Handler
    DEFAULT_VECTOR BusFault_Handler
    DEFAULT_VECTOR UsageFault_Handler
    DEFAULT_VECTOR SVC_Handler
    DEFAULT_VECTOR DebugMon_Handler
    DEFAULT_VECTOR PendSV_Handler
    DEFAULT_VECTOR SysTick_Handler

    DEFAULT_VECTOR WWDG_IRQHandler
    DEFAULT_VECTOR PVD_IRQHandler
    DEFAULT_VECTOR TAMPER_IRQHandler
    DEFAULT_VECTOR RTC_IRQHandler
    DEFAULT_VECTOR FLASH_IRQHandler
    DEFAULT_VECTOR RCC_IRQHandler
    DEFAULT_VECTOR EXTI0_IRQHandler
    DEFAULT_VECTOR EXTI1_IRQHandler
    DEFAULT_VECTOR EXTI2_IRQHandler
    DEFAULT_VECTOR EXTI3_IRQHandler
    DEFAULT_VECTOR EXTI4_IRQHandler
    DEFAULT_VECTOR DMA1_Channel1_IRQHandler
    DEFAULT_VECTOR DMA1_Channel2_IRQHandler
    DEFAULT_VECTOR DMA1_Channel3_IRQHandler
    DEFAULT_VECTOR DMA1_Channel4_IRQHandler
    DEFAULT_VECTOR DMA1_Channel5_IRQHandler
    DEFAULT_VECTOR DMA1_Channel6_IRQHandler
    DEFAULT_VECTOR DMA1_Channel7_IRQHandler
    DEFAULT_VECTOR ADC1_2_IRQHandler
    DEFAULT_VECTOR USB_HP_CAN1_TX_IRQHandler
    DEFAULT_VECTOR USB_LP_CAN1_RX0_IRQHandler
    DEFAULT_VECTOR CAN1_RX1_IRQHandler
    DEFAULT_VECTOR CAN1_SCE_IRQHandler
    DEFAULT_VECTOR EXTI9_5_IRQHandler
    DEFAULT_VECTOR TIM1_BRK_IRQHandler
    DEFAULT_VECTOR TIM1_UP_IRQHandler
    DEFAULT_VECTOR TIM1_TRG_COM_IRQHandler
    DEFAULT_VECTOR TIM1_CC_IRQHandler
    DEFAULT_VECTOR TIM2_IRQHandler
    DEFAULT_VECTOR TIM3_IRQHandler
    DEFAULT_VECTOR TIM4_IRQHandler
    DEFAULT_VECTOR I2C1_EV_IRQHandler
    DEFAULT_VECTOR I2C1_ER_IRQHandler
    DEFAULT_VECTOR I2C2_EV_IRQHandler
    DEFAULT_VECTOR I2C2_ER_IRQHandler
    DEFAULT_VECTOR SPI1_IRQHandler
    DEFAULT_VECTOR SPI2_IRQHandler
    DEFAULT_VECTOR USART1_IRQHandler
    DEFAULT_VECTOR USART2_IRQHandler
    DEFAULT_VECTOR USART3_IRQHandler
    DEFAULT_VECTOR EXTI15_10_IRQHandler
    DEFAULT_VECTOR RTC_Alarm_IRQHandler
    DEFAULT_VECTOR USBWakeUp_IRQHandler
    DEFAULT_VECTOR TIM8_BRK_IRQHandler
    DEFAULT_VECTOR TIM8_UP_IRQHandler
    DEFAULT_VECTOR TIM8_TRG_COM_IRQHandler
    DEFAULT_VECTOR TIM8_CC_IRQHandler
    DEFAULT_VECTOR ADC3_IRQHandler
    DEFAULT_VECTOR FSMC_IRQHandler
    DEFAULT_VECTOR SDIO_IRQHandler
    DEFAULT_VECTOR TIM5_IRQHandler
    DEFAULT_VECTOR SPI3_IRQHandler
    DEFAULT_VECTOR UART4_IRQHandler
    DEFAULT_VECTOR UART5_IRQHandler
    DEFAULT_VECTOR TIM6_IRQHandler
    DEFAULT_VECTOR TIM7_IRQHandler
    DEFAULT_VECTOR DMA2_Channel1_IRQHandler
    DEFAULT_VECTOR DMA2_Channel2_IRQHandler
    DEFAULT_VECTOR DMA2_Channel3_IRQHandler
    DEFAULT_VECTOR DMA2_Channel4_5_IRQHandler

    .end
