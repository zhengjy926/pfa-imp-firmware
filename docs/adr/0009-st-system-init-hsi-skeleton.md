# SystemInit 用 cmsis-device-f1 原样模板；骨架留 HSI 8 MHz；72 MHz 先于 USART

启动文件继续自研一份 `startup_stm32f103xe.S`（双工具链共用向量表，见 `docs/build.md`）。`SystemInit` / `SystemCoreClockUpdate` 改用 `cmsis-device-f1` v4.3.5 的 `Source/Templates/system_stm32f1xx.c` 原样入仓（`firmware/third_party/cmsis_device_f1/`），不改其源码。该模板的 `SystemInit` 不配 PLL、不开 HSE，复位后保持片内 HSI 8 MHz；板级目标时钟是 HSE 16 MHz / 2 × 9 = 72 MHz，另做且必须在配置 USART3/UART5 之前完成。`HSE_VALUE=16000000` 现在就以编译宏钉死（CMake / Keil / cppcheck），只影响日后 `SystemCoreClockUpdate` 的算术，不表示骨架已经在用 HSE。

**Considered Options**: 两份 ST 启动（`gcc/` + `arm/`）——拒绝：向量表分叉，且 `arm/` 自带堆区，与禁止动态分配冲突；自研 `system_stm32f1xx.c` 在 `SystemInit` 里把 HSI PLL 拉到 64 MHz——拒绝：与「骨架留复位缺省、升频另做」不一致，且会与 ST 模板双定义；把 72 MHz 写进 ST 的 `SystemInit`——拒绝：破坏 third_party 逐字节可比对；骨架阶段就配 USART——拒绝：波特率必须按最终 HCLK 计算。

**Consequences**: `firmware/system/` 不再有自研 `SystemInit`。MISRA 仍排除 `third_party/`（ADR 0004）：原样厂商源码不以 MISRA 验收；72 MHz 升频函数落在自研路径时再进扫描。
