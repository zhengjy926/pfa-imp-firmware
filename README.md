# pfa-imp-firmware

PFA（脉冲电场消融）手术回路阻抗采集板固件。

**硬件基线**：STM32F103RET6 + AD5941（SPI1，阻抗测量）+ IO 扩展驱动多路继电器（电极 24、顶电极/顶电极极性/杆极性/标测/回路/负极板各 1）+ AT24C256C（I2C2，参数存储）+ USART1（调试桥）/ USART3（上位机）/ UART5（贴靠阻抗采集板）。放电使能不在本板。

> ⚠️ 当前状态：**M1 进行中**。固件分层树已落在 `firmware/`，双工具链可编译并链出镜像；
> 尚未实现工作模式、组态预设、阻抗测量与 ECSP 产品命令。

## 文档

| 文档 | 说明 |
|---|---|
| [CONTEXT.md](CONTEXT.md) | 领域术语表（唯一权威定义） |
| [docs/adr/](docs/adr/) | 架构决策记录（ADR 0001~0010） |
| [docs/requirements.md](docs/requirements.md) | IEC 62304 轻量需求追踪矩阵 |
| [docs/protocol/ecsp.md](docs/protocol/ecsp.md) | ECSP 通用规范钉扎快照（设备组标准，非本仓库真源） |
| [docs/protocol/loop-impedance-board.md](docs/protocol/loop-impedance-board.md) | 回路阻抗采集板产品命令 |
| [docs/research/pfa-discharge-circuit.md](docs/research/pfa-discharge-circuit.md) | PFA 放电回路与术语对照（厂家 IFU / PMA / 标准） |
| [docs/build.md](docs/build.md) | 构建与工具链：双工具链约定、静态分析、版本与时钟 |
| `docs/pin-map.md` | 引脚映射事实源（尚未落地） |
| `docs/architecture.md` | 分层架构说明（尚未落地） |

## 目录落位

```
firmware/
├── app/          # 应用：任务、状态机、继电器业务
├── drivers/      # 设备模型上的芯片驱动：ad5941 / tca6424a / at24c256c
├── subsys/       # 自研子系统：protocol / params / relay_map / log
├── sys/          # 拷贝裁剪的 Zephyr sys 库 + device 核心 + compat 内核桩
├── bsp/          # 板级：初始化、引脚、HAL 总线设备注册
├── third_party/  # 第三方组件（CMSIS / STM32 HAL / FreeRTOS / ...）
├── startup/      # 启动文件、中断向量、GNU ld 链接脚本
└── MDK-ARM/      # Keil 工程与 armlink 分散加载描述
```

`drivers/`、`subsys/`、`sys/` 目前只有占位；主机单元测试树 `tests/` 尚未落地。

## 构建

- **本地开发**：Keil MDK（AC6）编译、µVision 调试与烧录，工程 `firmware/MDK-ARM/pfa_imp.uvprojx`，手工维护，不用 STM32CubeMX。烧录件只认 AC6。
- **本机预检 / CI 验证**：CMake + arm-none-eabi-gcc 交叉编译并链出镜像，不产出烧录件。

```bash
cmake -S firmware -B build/firmware -G Ninja \
      -DCMAKE_TOOLCHAIN_FILE="$PWD/cmake/toolchain-arm-none-eabi.cmake" \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build/firmware
```

提交前本机预检与 CI 同一套：源登记核对、CMake 构建（含无动态内存分配核对）、明文环境下的
cppcheck（MISRA C:2012）。cppcheck 读到密文则跳过，硬门禁在 CI。主机单元测试（Unity）
尚未落地。细节见 [docs/build.md](docs/build.md)。

## 工程约定

- 分支：trunk-based（`main` 直进）；提交：Conventional Commits。
- 版本：语义化版本，0.1.0 起；事实源 `firmware/app/include/app_version.h`，CMake 从其解析。
- 代码：C99、MISRA C:2012、禁止动态内存分配。
- 代码标识符/提交信息英文，注释与文档中文。
- 本仓库为私有仓库，未附开源许可证；第三方组件清单见 [NOTICE](NOTICE)。
