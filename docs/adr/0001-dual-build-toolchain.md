# 双构建工具链：Keil MDK 本地开发 + CMake/GCC CI 验证

本机唯一可用的 ARM 工具链是 Keil MDK（AC6/ARMCLANG），而 GitHub 云端 runner 无法运行 Keil（license 限制）。决定：本地开发与调试使用**手工维护**的 MDK-ARM 工程——用户明确不使用 STM32CubeMX，初始化代码、`.uvprojx` 与引脚映射文档均为手工维护；CI（GitHub Actions）使用 CMake + arm-none-eabi-gcc 做编译验证、Unity 主机单元测试与 cppcheck（MISRA C:2012）静态分析，CI 不产出烧录件。

**Considered Options**: 纯 Keil、无 CI（拒绝：丧失企业级质量门禁）；纯 CMake+GCC 本地开发（拒绝：本机环境只有 Keil，调试链路不匹配）。

**Consequences**: 需并行维护 `.uvprojx` 与 `CMakeLists.txt` 两套工程描述，源文件目录共享；AC6 无内置 MISRA 检查，合规由 cppcheck 承担。
