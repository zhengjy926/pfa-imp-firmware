# 双构建工具链：Keil MDK 本地开发 + CMake/GCC CI 验证

本机同时装有 Keil MDK（AC6/ARMCLANG）与 arm-none-eabi-gcc；GitHub runner 无法运行 Keil（license）。本机开发、调试与烧录走**手工维护**的 MDK-ARM 工程：要的是 µVision 外设寄存器窗以及与 AC6 工程一体的下载/调试，不是因为没有第二套编译器。不用 STM32CubeMX。烧录件只认本机 AC6 镜像。CI 用 CMake + arm-none-eabi-gcc 做编译验证与 cppcheck（MISRA C:2012），不产出烧录件；本机同一套 GCC/cppcheck 命令是提交前预检，不加 git hook。本机与 CI 的 GNU 工具链版本不钉死对齐。

**Considered Options**: 纯 Keil、无 CI（拒绝：丧失质量门禁）；纯 CMake+GCC 本地开发（拒绝：Ozone/GDB 替代不了上述 µVision 能力；本机已有 gcc，缺的不是编译器）。

**Consequences**: 并行维护 `.uvprojx` 与 `CMakeLists.txt`，源文件目录共享；AC6 无内置 MISRA，合规由 cppcheck 承担。公司透明加密下 cppcheck 可能读到密文，此时本机扫描退出 0 并声明无效，硬门禁在 CI。
