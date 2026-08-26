# 构建与工具链

本仓库并行维护两套工程描述：本机开发用手工维护的 Keil MDK 工程，CI 用 CMake +
arm-none-eabi-gcc 做编译验证。取舍与代价见 [ADR 0001](adr/0001-dual-build-toolchain.md)。

**不使用 STM32CubeMX。** 引脚映射、启动文件、中断向量与时钟初始化全部手工维护，
`.uvprojx` 也是手写的。CubeMX 生成的初始化代码与工程不接受进入本仓库。

目录落位见 [README 的「目录落位」](../README.md#目录落位)，本文不重复一份。

## 本机开发：Keil MDK

前置条件：

- Keil MDK 5.42 或更高，编译器用 Arm Compiler for Embedded 6（AC6）。规划基线是
  MDK 5.43；当前开发机实测为 MDK 5.42 + AC6 6.23，工程按 AC6 配置，两者均可打开。
  `.uvprojx` 里的 `pCCUsed` 记的是 6.23，装了别的 AC6 小版本时 µVision 会提示切换，
  照提示选本机版本即可；
- 设备支持包 `Keil.STM32F1xx_DFP`（本机实测 2.4.1）。没装的话用 Pack Installer 装上，
  否则 µVision 打不开器件选择。

打开 `firmware/MDK-ARM/pfa_imp.uvprojx` 直接编译。若 µVision 提示汇编器选择，
确认 Options for Target → Asm → Assembler 为 **Auto Select**：启动文件是 `.S`
（大写），需要走 armclang 集成汇编器并经过预处理器。

工程选用 **MicroLIB**：本项目禁止动态内存分配，MicroLIB 不需要堆区，
`pfa_imp.sct` 因此刻意不定义 `ARM_LIB_HEAP`——任何用到堆的库函数都会在链接期报错。

## CI 与本机的 CMake 构建

```bash
cmake -S firmware -B build/firmware -G Ninja \
      -DCMAKE_TOOLCHAIN_FILE="$PWD/cmake/toolchain-arm-none-eabi.cmake" \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build/firmware
```

构建收尾会打印镜像体积，并核对镜像里没有任何动态内存分配符号
（`tools/check_no_dynamic_alloc.py`）。

CI **只做编译验证，不产出烧录件**：workflow 不上传 `.elf` / `.hex`，发布件一律来自
本机 Keil 构建。

这带来一个需要说清的错位：`check_no_dynamic_alloc.py` 只挂在 CMake 的 `POST_BUILD`
上，被它检查的是那个**不发布**的 GCC 镜像。发布件走的是另一道机制——工程选用
MicroLIB 且 `pfa_imp.sct` 刻意不定义 `ARM_LIB_HEAP`，任何用到堆的库函数在 armlink
链接期就会报错。两道机制各自成立，但覆盖面不等价：GCC 侧是按符号名扫成品镜像，
armlink 侧靠「没有堆区可分配」。CI 环境没有 Keil，因此后者只能在本机构建时体现。

## 新增源文件

同一批源要在两处工程描述里各登记一遍：

1. `firmware/CMakeLists.txt` 的 `PFA_IMP_SOURCES` 清单（**不要**改成 GLOB——
   显式清单才能和 Keil 工程逐项比对）；
2. `firmware/MDK-ARM/pfa_imp.uvprojx` 对应 `<Group>` 下的 `<File>` 条目。

漏掉任何一处，`tools/check_source_registration.py` 会让 CI 失败并指名文件。该门禁
同时拦住「登记了不存在的文件」和「文件躺在 firmware/ 里但两处都没登记」。加进 Keil
Group 的头文件只为方便浏览，不算编译输入，不参与比对。

比源清单更容易漏的是**编译配置**，它没有门禁，只能靠人盯：

- 新增头文件搜索路径要改三处：`firmware/CMakeLists.txt` 的
  `PFA_IMP_INCLUDE_DIRS` / `PFA_IMP_SYSTEM_INCLUDE_DIRS`、`pfa_imp.uvprojx` 的
  `IncludePath`（第三方路径走 `MiscControls` 里的 `-isystem`）、以及
  `tools/run_cppcheck.py` 的 `INCLUDE_DIRS` / `SYSTEM_INCLUDE_DIRS`。
- 告警开关在 `firmware/CMakeLists.txt` 与 `pfa_imp.uvprojx` 的 `MiscControls` 里各写
  一份，改一处要同步另一处，否则两条工具链的严格程度会悄悄拉开。

### 工具链私有的文件

只有链接描述是按工具链分开的，且互为镜像——改一个必须同步另一个：

| 用途 | GCC | armlink |
|---|---|---|
| 内存布局 | `firmware/startup/stm32f103xe_flash.ld` | `firmware/MDK-ARM/pfa_imp.sct` |

内存布局其实散在**四处**，改 Flash/RAM 尺寸要全部同步，而且没有门禁能拦住漏改：
上表两个链接描述，加上 `pfa_imp.uvprojx` 里的 `<Cpu>` 字符串（µVision 器件对话框读它）
与 `<OnChipMemories>`（Options for Target 的 IROM/IRAM 勾选）。后两处只影响 µVision
的界面与默认值，不参与 armlink 的实际布局——那由 `.sct` 说了算——但对不上会让人在
界面里看到与镜像不符的数字。

启动文件与中断向量表**只有一份**：`firmware/startup/startup_stm32f103xe.S` 用 GNU
汇编语法书写，靠 `__ARMCC_VERSION` 分支适配两条工具链（AC6 跳 `__main` 走
scatter-load，GCC 自行搬 `.data`、清 `.bss`）。这样 60 路 IRQ 的向量表不会两边各持
一份而静默分叉。

启动文件不调用 `__libc_init_array`：本项目是 C99 + MISRA C:2012，没有静态构造函数。
链接脚本里有断言兜底，一旦真出现 `.init_array` 条目会在链接期报错，而不是被静默跳过。

## 静态分析

AC6 没有内置 MISRA 检查，合规门禁由 cppcheck 承担：

```bash
python3 tools/run_cppcheck.py
```

`misra.py` 的位置由脚本按已知路径探测（找不到则退回插件名 `misra`），因此 CI 配置里
不写死路径——各发行版装的地方不一样，写死会让门禁在换 runner 镜像时静默失效。位置特殊
时用 `--addon <路径>` 指定。

扫描范围由目录结构推导，排除 `firmware/sys/`（从 Zephyr 拷贝裁剪）与
`firmware/third_party/`（第三方组件）——不把上游代码的告警算作本仓库缺陷
（[ADR 0004](adr/0004-zephyr-compatible-device-model.md)）。新增自研源文件会自动
进入扫描，不需要改脚本。这份「哪些算上游」的判据在 `tools/firmware_tree.py` 里只有
一份，源登记门禁共用它，避免出现「cppcheck 不扫、登记检查却要求登记」的互相矛盾。

已知且被接受的偏离登记在 `tools/cppcheck/suppressions.txt`，写法与举证要求见该文件
开头。只在个别位置成立的偏离用源码内 `// cppcheck-suppress <id>` 就近说明。

MISRA 规则原文有版权，不入仓，因此不传 `--rule-texts`。违规会以
`misra-c2012-<规则号>` 的形式报出而没有规则描述，看到规则号后请对照 MISRA C:2012
正式文本。另注意 `misra.py` 只实现了规则中的一个子集（例如 Rule 17.4 就不在其内），
门禁通过不等于全量合规。

## 版本号

语义化版本，自 **0.1.0** 起。事实源是 `firmware/app/include/app_version.h`；
`firmware/CMakeLists.txt` 从该头文件解析出 `project(... VERSION ...)`，两处不会各写一遍。

## 时钟

骨架阶段一律使用片内 HSI（8 MHz）经 PLL 倍频到 **64 MHz**：SYSCLK 64 MHz、
HCLK 64 MHz、PCLK1 32 MHz、PCLK2 64 MHz，Flash 2 个等待周期。

本板原理图尚未确认外部晶振是否存在及其频率，因此**不启用 HSE**，也不按「常见开发板
是 8 MHz 晶振」去假设 72 MHz。确认后再在 `firmware/system/src/system_stm32f1xx.c`
扩展，并同步更新本节。
