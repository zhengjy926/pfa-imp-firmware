# ****************************************************************************
# * @file    : CMakeLists.txt
# * @author  : ZJY
# * @version : V1.0
# * @date    : 2026-08-26
# * @brief   : 回路阻抗采集板固件的 CMake 构建描述（CI 硬门禁与本机预检，见 ADR 0001）
# * @attention: 这里的源文件清单与 MDK-ARM/pfa_imp.uvprojx 必须一一对应。新增或
# *             删除源文件时两处都要改，由 tools/check_source_registration.py 核对。
# *             详见 docs/build.md。
# ****************************************************************************

cmake_minimum_required(VERSION 3.20)

# ---------------------------------------------------------------------------
# 版本号：事实源是 app/include/app_version.h，这里解析出来，避免两处各写一遍
# ---------------------------------------------------------------------------
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/app/include/app_version.h" PFA_IMP_VERSION_HEADER)
foreach(_field MAJOR MINOR PATCH)
    if(NOT PFA_IMP_VERSION_HEADER MATCHES "#define[ \t]+APP_VERSION_${_field}[ \t]+\\(([0-9]+)U\\)")
        message(FATAL_ERROR "无法从 app/include/app_version.h 解析 APP_VERSION_${_field}")
    endif()
    set(PFA_IMP_VERSION_${_field} "${CMAKE_MATCH_1}")
endforeach()

project(pfa_imp
    VERSION ${PFA_IMP_VERSION_MAJOR}.${PFA_IMP_VERSION_MINOR}.${PFA_IMP_VERSION_PATCH}
    LANGUAGES C ASM
)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# ---------------------------------------------------------------------------
# 源文件清单（与 Keil 工程一一对应，勿改成 GLOB）
# ---------------------------------------------------------------------------
set(PFA_IMP_SOURCES
    app/src/main.c
    bsp/src/bsp_board.c
    third_party/cmsis_device_f1/Source/Templates/system_stm32f1xx.c
    startup/startup_stm32f103xe.S
)

# 自研代码的头文件搜索路径
set(PFA_IMP_INCLUDE_DIRS
    app/include
    bsp/include
)

# 第三方头文件：以 SYSTEM 方式引入，其告警不计入本仓库的 -Werror
set(PFA_IMP_SYSTEM_INCLUDE_DIRS
    third_party/cmsis_core/Include
    third_party/cmsis_device_f1/Include
)

set(PFA_IMP_MCU_FLAGS
    -mcpu=cortex-m3
    -mthumb
)

set(PFA_IMP_LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/startup/stm32f103xe_flash.ld")

add_executable(pfa_imp ${PFA_IMP_SOURCES})
set_target_properties(pfa_imp PROPERTIES SUFFIX ".elf")

target_include_directories(pfa_imp PRIVATE ${PFA_IMP_INCLUDE_DIRS})
target_include_directories(pfa_imp SYSTEM PRIVATE ${PFA_IMP_SYSTEM_INCLUDE_DIRS})

target_compile_definitions(pfa_imp PRIVATE
    STM32F103xE
    HSE_VALUE=16000000
)

# 原样入仓的厂商 .c 不以本仓库的 -Werror 验收（ADR 0004 / 0009）
set_source_files_properties(
    third_party/cmsis_device_f1/Source/Templates/system_stm32f1xx.c
    PROPERTIES
        COMPILE_OPTIONS "-w"
)

target_compile_options(pfa_imp PRIVATE
    ${PFA_IMP_MCU_FLAGS}
    -ffunction-sections
    -fdata-sections
    -fno-common
    $<$<COMPILE_LANGUAGE:C>:-Wall>
    $<$<COMPILE_LANGUAGE:C>:-Wextra>
    $<$<COMPILE_LANGUAGE:C>:-Wpedantic>
    $<$<COMPILE_LANGUAGE:C>:-Wshadow>
    $<$<COMPILE_LANGUAGE:C>:-Wconversion>
    $<$<COMPILE_LANGUAGE:C>:-Wdouble-promotion>
    $<$<COMPILE_LANGUAGE:C>:-Werror>
)

target_link_options(pfa_imp PRIVATE
    ${PFA_IMP_MCU_FLAGS}
    -T${PFA_IMP_LINKER_SCRIPT}
    --specs=nano.specs
    --specs=nosys.specs
    # 复位入口由 startup_stm32f103xe.S 自己提供，不要链 crt0：crt0 引用 exit，会
    # 顺带拖进 stdio 清理链乃至 _malloc_r，与「禁止动态分配」相悖。
    -nostartfiles
    -Wl,--gc-sections
    -Wl,--print-memory-usage
    -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/pfa_imp.map,--cref
)

# 链接脚本变了要重链
set_target_properties(pfa_imp PROPERTIES LINK_DEPENDS "${PFA_IMP_LINKER_SCRIPT}")

# ---------------------------------------------------------------------------
# 构建期门禁：镜像里不允许出现任何动态内存分配符号
# ---------------------------------------------------------------------------
find_package(Python3 COMPONENTS Interpreter REQUIRED)

add_custom_command(TARGET pfa_imp POST_BUILD
    COMMAND "${CMAKE_SIZE}" "$<TARGET_FILE:pfa_imp>"
    COMMAND "${Python3_EXECUTABLE}"
            "${CMAKE_CURRENT_SOURCE_DIR}/../tools/check_no_dynamic_alloc.py"
            --nm "${CMAKE_NM}"
            "$<TARGET_FILE:pfa_imp>"
    VERBATIM
    COMMENT "统计镜像体积并核对无动态内存分配"
)
