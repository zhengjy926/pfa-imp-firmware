# pfa-imp-firmware

PFA（脉冲电场消融）手术回路阻抗采集板固件。

**硬件基线**：STM32F103RET6 + AD5941（SPI1，阻抗测量）+ IO 扩展驱动多路继电器（电极 24、顶电极/顶电极极性/杆极性/标测/回路/负极板各 1）+ AT24C256C（I2C2，参数存储）+ USART1（调试桥）/ USART3（上位机）/ UART5（贴靠阻抗采集板）。放电使能不在本板。

> ⚠️ 当前状态：**M0 仓库骨架**。固件源码自 M1 起进入 `firmware/`。

## 文档

| 文档 | 说明 |
|---|---|
| [CONTEXT.md](CONTEXT.md) | 领域术语表（唯一权威定义） |
| [docs/adr/](docs/adr/) | 架构决策记录（ADR 0001~0006） |
| [docs/requirements.md](docs/requirements.md) | IEC 62304 轻量需求追踪矩阵 |
| [docs/research/pfa-discharge-circuit.md](docs/research/pfa-discharge-circuit.md) | PFA 放电回路与术语对照（厂家 IFU / PMA / 标准） |
| [docs/pin-map.md](docs/pin-map.md) | 引脚映射事实源（M1 提供） |
| [docs/architecture.md](docs/architecture.md) | 分层架构说明（M1 提供） |

## 目录规划（M1 起落位）

```
firmware/
├── app/          # 应用：任务、状态机、继电器业务
├── drivers/      # 设备模型上的芯片驱动：ad5941 / tca6424a / at24c256c
├── subsys/       # 自研子系统：protocol / params / relay_map / log
├── sys/          # 拷贝裁剪的 Zephyr sys 库 + device 核心 + compat 内核桩
├── bsp/          # 板级：初始化、引脚、HAL 总线设备注册
├── third_party/  # FreeRTOS / EasyLogger / SEGGER RTT / STM32 HAL
├── startup/ system/  # 启动文件、FreeRTOSConfig、中断
└── MDK-ARM/      # Keil 工程
tests/            # 主机单元测试（Unity/CMock，CI 执行）
```

## 构建

- **本地开发**：Keil MDK 5.43（AC6），工程 `firmware/MDK-ARM/pfa_imp.uvprojx`（M1 提供）。
- **CI**：GitHub Actions——cppcheck（MISRA C:2012）+ 主机单元测试 + arm-none-eabi-gcc 编译验证（M1 启用，当前为骨架冒烟检查）。

## 工程约定

- 分支：trunk-based（`main` 直进）；版本：语义化版本，0.1.0 起；提交：Conventional Commits。
- 代码标识符/提交信息英文，注释与文档中文。
- 本仓库为私有仓库，未附开源许可证；第三方组件清单见 [NOTICE](NOTICE)。
