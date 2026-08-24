# Zephyr 兼容设备模型与 sys 库（拷贝裁剪 + FreeRTOS 内核桩）

用户选定自研"Zephyr 风格精简设备模型"，且产品线未来可能整体迁移 Zephyr OS，因此设备层 API 必须与 Zephyr 现行版本形状对齐。决定：

- **设备核心**采用 Zephyr v4.x 机制（已核实 main 分支 `device.h`）：编译期句柄 `DEVICE_GET(id)`（对应 `DEVICE_DT_GET`，**无字符串查找**——`device_get_binding` 是遗留路径）+ 多 API 访问 `DEVICE_API_GET(spi, dev)`；设备表静态定义，初始化走 `bsp_board.c` 里的**显式顺序表**（不用 linker section 魔法）。迁移时两个宏重定义即可，上层零改动。
- **sys 库**（ring_buffer、crc、dlist/slist、util 等）**直接拷贝 Zephyr v4.x 源码裁剪**（用户决策），保留 SPDX 版权头；其内核依赖由自写 `sys/compat/` 最小内核桩消除，桩**构建在 FreeRTOS + CMSIS 之上**：`k_spinlock`=保存并屏蔽 PRIMASK（ISR 可用，不用 FreeRTOS 临界区）、`atomic_*`=CMSIS LDREX/STREX、`__ASSERT`=`configASSERT`、tick=`pdMS_TO_TICKS`；只拷贝无超时 API 变体。设备模型与 FreeRTOS 调度正交，互不替代。
- **抽象五类总线**：spi / i2c / uart / gpio / eeprom（API 形状对齐 Zephyr `drivers/*.h`），HAL 实现在 bsp 层注册为设备；AD5941（spi）、TCA6424A（gpio）、AT24C256C（eeprom）挂对应类。
- **OSS 合规**：仓库维护 `NOTICE`（OSS 清单：来源、版本、许可证）；MISRA/静态扫描排除 `sys/` 与 `third_party/`。

**Considered Options**: 全自写实现（拒绝：用户要求复用 Zephyr 现成件）；上完整 Zephyr OS（拒绝：推翻 Keil/FreeRTOS 与 ADR 0001 既有决策）；字符串 `device_get_binding`（拒绝：Zephyr 现行机制是编译期 DT 句柄）。

**Consequences**: Zephyr 版本在 M1 锁定具体 tag；参数/校准/故障记录全部存 AT24C256C EEPROM（撤销"内部 Flash 4KB 参数区"计划），HardFault 现场经轮询式 I2C 写 EEPROM。
