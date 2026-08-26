# 钉扎 CMSIS-Core 5.9.0，不跟随 CMSIS 6

本板是 STM32F103RET6（Cortex-M3），设备头来自 `cmsis-device-f1` v4.3.5，其兼容表配对的是 CMSIS-Core 5.x（v4.3.x 文档写的是 5.4.0_cm3）。决定：CMSIS-Core 钉在 `CMSIS_5` 发行 tag `5.9.0`（5.x 最后一版），只入仓本项目用到的 5 个头文件；不升 CMSIS 6。F103 无 MPU、用不上 6 新增的核，而 6.0 对 M3 有破坏性改名（`NVIC_Type.IP`→`IPR`、`CoreDebug_Type`→`DCB_Type` 等）；6.1+ 虽以 deprecated 符号补兼容，仍要把 ST 设备头、规划中的 F1 HAL、以及 ADR 0004 里基于 CMSIS LDREX/STREX 的原子桩重新对一遍符号。

**Considered Options**: 升到 CMSIS 6.x（拒绝：没有用不上的 Core 能力，却要承担与 ST F1 设备层/HAL 的配对风险和裁剪清单重审）；继续钉在 5.4.0_cm3 与 ST 表逐项对齐（拒绝：5.9.0 对 F1 是超集，少跟一个已停止维护的中间 tag）。

**Consequences**: 入仓副本与 `CMSIS_5` tag `5.9.0` 逐字节可比对（见 `NOTICE`）。规划中的 STM32F1 HAL 按 CMSIS 5 设备头接入，不为此预埋 CMSIS 6 兼容补丁。
