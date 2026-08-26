/**
 ******************************************************************************
 * @file : system_stm32f1xx.c
 * @author : ZJY
 * @version : V1.0
 * @date : 2026-08-26
 * @brief : STM32F103RET6 复位后的时钟与 Flash 时序初始化（手工维护）
 * @attention : 本文件是自研实现，不是 ST 模板或 STM32CubeMX 生成物（见 ADR 0001）。
 *              它只实现 CMSIS 约定的 SystemInit / SystemCoreClockUpdate 两个入口，
 *              以便复用 third_party/cmsis_device_f1 的 system_stm32f1xx.h 声明。
 *
 *              时钟源选择：本板原理图尚未确认外部晶振是否存在及其频率，因此骨架
 *              阶段一律使用片内 HSI（8 MHz，器件手册保证值，不是板级事实），经
 *              PLL 倍频到 64 MHz。确认 HSE 后再在此扩展，禁止先按「常见开发板」
 *              假设 8 MHz 晶振把 72 MHz 钉成硬件契约。
 *
 *              SystemInit 在 .data 搬运与 .bss 清零之前由启动文件调用，因此它
 *              只允许访问外设寄存器，不得读写任何有初值的全局变量。
 ******************************************************************************
 * @history :
 * V1.0 : 1.建立 HSI/2 × 16 = 64 MHz 的时钟树与有界等待的就绪轮询
 *
 *
 ******************************************************************************
 */
/* Includes ------------------------------------------------------------------*/
#include <stdbool.h>
#include <stdint.h>

#include "stm32f1xx.h"

/* Private typedef -----------------------------------------------------------*/


/* Private define ------------------------------------------------------------*/
/** @brief 片内高速振荡器频率，单位 Hz（器件手册标称值，非板级事实） */
#define SYSTEM_HSI_FREQ_HZ              (8000000U)

/**
 * @brief Flash 读等待周期 = 2
 * @note  LATENCY[2:0] = 010。CMSIS 里名为 FLASH_ACR_LATENCY_1（位 1），不要误用
 *        FLASH_ACR_LATENCY_2（位 2，值为 4，F1 上非法）。RM0008：48 MHz <
 *        SYSCLK <= 72 MHz 时需 2 个等待周期。
 */
#define SYSTEM_FLASH_LATENCY_2WS        (FLASH_ACR_LATENCY_1)

/**
 * @brief 时钟就绪轮询的最大次数
 * @note  取有界值以保证最坏执行时间可预测，而不是死等。HSI 起振约 2 us、PLL 锁定约
 *        200 us，而本上限即使按「一次循环一个周期」这种最悲观的编译结果估算，也远
 *        大于这两个时间。这里刻意只给次数不给时间：循环体的实际周期数随优化等级
 *        变化，任何毫秒数都是算不准的，写上去反而误导。
 */
#define SYSTEM_CLOCK_READY_RETRIES      (0x00010000U)

/** @brief PLLMUL 字段取值达到该值及以上时倍频系数封顶为 16 */
#define SYSTEM_PLLMULL_FIELD_CAP        (14U)

/** @brief PLLMUL 字段值到倍频系数的偏移（字段 0 表示 ×2） */
#define SYSTEM_PLLMULL_FIELD_BIAS       (2U)

/** @brief 倍频系数封顶值 */
#define SYSTEM_PLLMULL_MAX              (16U)

/** @brief 无法识别当前时钟配置时给 SystemCoreClock 的取值 */
#define SYSTEM_CORE_CLOCK_UNKNOWN       (0U)

/* Private macro -------------------------------------------------------------*/


/* Private variables ---------------------------------------------------------*/
/**
 * @brief AHB 预分频字段（HPRE[3:0]）到右移位数的映射
 * @note  据 RM0008：0..7 为不分频，8..15 依次为 /2 /4 /8 /16 /64 /128 /256 /512
 *        （无 /32 档，故 12 对应右移 6 位）。字段宽 4 位，索引恒在 0..15 内。
 */
static const uint8_t s_ahb_presc_shift[16U] =
{
    0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    1U, 2U, 3U, 4U, 6U, 7U, 8U, 9U
};

/* Exported variables -------------------------------------------------------*/
/**
 * @brief 当前内核时钟频率，单位 Hz
 * @note  初值取复位缺省的 HSI 直供值。SystemInit 运行在 .data 搬运之前，无法在
 *        那里写这个变量，因此真实值由 SystemCoreClockUpdate() 从寄存器回读得出。
 */
uint32_t SystemCoreClock = SYSTEM_HSI_FREQ_HZ;

/* Private function prototypes -----------------------------------------------*/
static bool system_wait_masked_value(const volatile uint32_t *reg,
                                     uint32_t mask,
                                     uint32_t expected);
static void system_switch_to_hsi_pll(void);
static uint32_t system_pll_multiplier(void);

/* Exported functions --------------------------------------------------------*/
/**
 * @brief  复位后的最小系统初始化：Flash 时序、时钟树与向量表基址
 * @param  None
 * @retval None
 * @note   由启动文件在 C 运行时初始化之前调用，只访问外设寄存器。
 *
 *         整个升频过程建立在「HSI 已就绪且系统时钟已落到 HSI」这个前提上——只有
 *         站在 HSI 上才能安全地改 PLL 配置。任一前提不成立就完全不动时钟树：
 *         此时系统仍运行在复位缺省或引导程序留下的时钟上，而调用方随后通过
 *         SystemCoreClockUpdate() 得到真实频率，不会拿着 64 MHz 的假设往下算。
 *
 *         本函数不配置任何 GPIO，因此上电路径不会闭合任何继电器。
 */
void SystemInit(void)
{
    /* 先放宽 Flash 等待周期并开预取，之后升频才安全 */
    FLASH->ACR = FLASH_ACR_PRFTBE | SYSTEM_FLASH_LATENCY_2WS;

    /* HSI 是切换过程中唯一的安全落脚点 */
    RCC->CR |= RCC_CR_HSION;
    if (system_wait_masked_value(&RCC->CR, RCC_CR_HSIRDY, RCC_CR_HSIRDY))
    {
        RCC->CFGR = (RCC->CFGR & ~RCC_CFGR_SW) | RCC_CFGR_SW_HSI;
        if (system_wait_masked_value(&RCC->CFGR, RCC_CFGR_SWS, RCC_CFGR_SWS_HSI))
        {
            system_switch_to_hsi_pll();
        }
    }

    /* 向量表定位到 Flash 起始，不使用偏移 */
    SCB->VTOR = FLASH_BASE;
}

/**
 * @brief  从时钟寄存器回读并刷新 SystemCoreClock
 * @param  None
 * @retval None
 * @note   只解析本固件会配置出的状态：HSI 直供，或以 HSI/2 为源的 PLL。其余状态
 *         （含以 HSE 为源）一律置 SYSTEM_CORE_CLOCK_UNKNOWN 而不是回退到某个看起来
 *         合理的频率——错的频率会让下游算出「看着对」的波特率与定时，比算不出来更难查。
 *         HSE 的晶振频率待原理图确认后再在此补齐分支。
 */
void SystemCoreClockUpdate(void)
{
    const uint32_t sws = RCC->CFGR & RCC_CFGR_SWS;
    uint32_t sysclk;
    uint32_t hpre_field;

    if (sws == RCC_CFGR_SWS_HSI)
    {
        sysclk = SYSTEM_HSI_FREQ_HZ;
    }
    else if ((sws == RCC_CFGR_SWS_PLL) && ((RCC->CFGR & RCC_CFGR_PLLSRC) == 0U))
    {
        sysclk = (SYSTEM_HSI_FREQ_HZ / 2U) * system_pll_multiplier();
    }
    else
    {
        sysclk = SYSTEM_CORE_CLOCK_UNKNOWN;
    }

    /* 未知时 sysclk 为 0，右移后仍为 0，无需另开分支 */
    hpre_field = (RCC->CFGR & RCC_CFGR_HPRE) >> RCC_CFGR_HPRE_Pos;
    SystemCoreClock = sysclk >> s_ahb_presc_shift[hpre_field];
}

/* Private functions ---------------------------------------------------------*/
/**
 * @brief  把时钟树配成 HSI/2 × 16 = 64 MHz 并切到 PLL
 * @param  None
 * @retval None
 * @note   前提：系统时钟当前已落在 HSI 上，因此关掉并重配 PLL 不会自断时钟。
 *         若 PLL 未能在有界次数内锁定，则留在 HSI 直供而不死等。
 */
static void system_switch_to_hsi_pll(void)
{
    /*
     * 关 PLL、HSE 与时钟安全系统，回到可预测的起点。
     * 不动 HSEBYP：RM0008 规定它只能在 HSE 已停振时写，而刚清掉 HSEON 时 HSERDY
     * 还没归零，此刻写入正落在禁写窗口内；何况本固件根本不用 HSE，该位是什么值
     * 都不影响 HSI/PLL 这条链。
     */
    RCC->CR &= ~(RCC_CR_PLLON | RCC_CR_HSEON | RCC_CR_CSSON);

    /* 清掉所有预分频、MCO 输出与 PLL 选择位；清零即等于 /1 与 PLL 源 = HSI/2 */
    RCC->CFGR &= ~(RCC_CFGR_HPRE | RCC_CFGR_PPRE1 | RCC_CFGR_PPRE2 |
                   RCC_CFGR_ADCPRE | RCC_CFGR_MCO | RCC_CFGR_PLLSRC |
                   RCC_CFGR_PLLXTPRE | RCC_CFGR_PLLMULL | RCC_CFGR_USBPRE);

    /* 关闭并清除全部 RCC 中断，骨架阶段不使用时钟中断 */
    RCC->CIR = RCC_CIR_LSIRDYC | RCC_CIR_LSERDYC | RCC_CIR_HSIRDYC |
               RCC_CIR_HSERDYC | RCC_CIR_PLLRDYC | RCC_CIR_CSSC;

    /*
     * 目标时钟树：SYSCLK = (HSI / 2) * 16 = 64 MHz
     *   HCLK  = SYSCLK / 1 = 64 MHz（HPRE 已清零，即 /1）
     *   PCLK1 = HCLK  / 2 = 32 MHz（APB1 上限 36 MHz）
     *   PCLK2 = HCLK  / 1 = 64 MHz（PPRE2 已清零，即 /1）
     * PLL 源保持 HSI/2（PLLSRC 已清零），故此处只需写非零的两个字段。
     *
     * 这条时钟树拿不到 USB 所需的 48 MHz：64 MHz 无论 /1 还是 /1.5 都不是 48 MHz。
     * 本板不使用 USB，故不为它牺牲 SYSCLK；将来若要用 USB，必须改用 HSE。
     */
    RCC->CFGR |= (RCC_CFGR_PPRE1_DIV2 | RCC_CFGR_PLLMULL16);

    RCC->CR |= RCC_CR_PLLON;
    if (system_wait_masked_value(&RCC->CR, RCC_CR_PLLRDY, RCC_CR_PLLRDY))
    {
        RCC->CFGR = (RCC->CFGR & ~RCC_CFGR_SW) | RCC_CFGR_SW_PLL;
        (void)system_wait_masked_value(&RCC->CFGR, RCC_CFGR_SWS, RCC_CFGR_SWS_PLL);
    }
}

/**
 * @brief  从 PLLMUL 字段解出当前的 PLL 倍频系数
 * @param  None
 * @retval 倍频系数，取值 2..16
 */
static uint32_t system_pll_multiplier(void)
{
    const uint32_t mul_field = (RCC->CFGR & RCC_CFGR_PLLMULL) >> RCC_CFGR_PLLMULL_Pos;
    uint32_t multiplier;

    if (mul_field >= SYSTEM_PLLMULL_FIELD_CAP)
    {
        multiplier = SYSTEM_PLLMULL_MAX;
    }
    else
    {
        multiplier = mul_field + SYSTEM_PLLMULL_FIELD_BIAS;
    }

    return multiplier;
}

/**
 * @brief  有界轮询某寄存器的若干位，直到其等于期望值
 * @param  reg      待轮询的寄存器地址
 * @param  mask     参与比较的位掩码
 * @param  expected 期望的掩码后取值
 * @retval true 已达到期望值；false 在上限次数内未达到
 * @note   返回值取自循环退出时的那次采样，而不是退出后再读一遍：reg 是 volatile，
 *         重读会拿到新的一次采样，可能与循环的判定结果相反。
 */
static bool system_wait_masked_value(const volatile uint32_t *reg,
                                     uint32_t mask,
                                     uint32_t expected)
{
    uint32_t retries = SYSTEM_CLOCK_READY_RETRIES;
    bool reached = ((*reg & mask) == expected);

    while ((!reached) && (retries > 0U))
    {
        retries--;
        reached = ((*reg & mask) == expected);
    }

    return reached;
}
