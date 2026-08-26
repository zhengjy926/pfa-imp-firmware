# ****************************************************************************
# * @file    : toolchain-arm-none-eabi.cmake
# * @author  : ZJY
# * @version : V1.0
# * @date    : 2026-08-26
# * @brief   : arm-none-eabi-gcc 交叉编译工具链描述（CI 编译验证用，见 ADR 0001）
# * @attention: 本工具链只用于「源码能编过、能链出镜像」的验证，不产出发布烧录件。
# *             本机开发与调试仍走 Keil MDK 工程。
# ****************************************************************************

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# 交叉编译时不要试着链接并运行探测程序，改为只编静态库
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(PFA_IMP_TOOLCHAIN_PREFIX "arm-none-eabi-" CACHE STRING "交叉工具链前缀")

find_program(CMAKE_C_COMPILER   "${PFA_IMP_TOOLCHAIN_PREFIX}gcc" REQUIRED)
find_program(CMAKE_ASM_COMPILER "${PFA_IMP_TOOLCHAIN_PREFIX}gcc" REQUIRED)
find_program(CMAKE_OBJCOPY      "${PFA_IMP_TOOLCHAIN_PREFIX}objcopy" REQUIRED)
find_program(CMAKE_SIZE         "${PFA_IMP_TOOLCHAIN_PREFIX}size" REQUIRED)
find_program(CMAKE_NM           "${PFA_IMP_TOOLCHAIN_PREFIX}nm" REQUIRED)

# 目标平台上没有主机的头与库，搜索时不要回退到主机根
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
