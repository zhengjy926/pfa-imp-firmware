/**
 ******************************************************************************
 * @file : app_version.h
 * @author : ZJY
 * @version : V1.0
 * @date : 2026-08-26
 * @brief : 固件版本号（语义化版本，自 0.1.0 起）
 * @attention : 本文件是固件版本号的唯一事实源，改版本只改这里。
 *              firmware/CMakeLists.txt 会解析本文件得出 project(... VERSION ...)，
 *              不需要另行同步；Keil 工程的输出名不带版本号，也无需改动。
 *              下面三个数字与 APP_VERSION_STRING 必须一致——两者刻意不用字符串化
 *              宏拼接（MISRA C:2012 Rule 20.10 不建议使用 # 与 ## 运算符）。
 ******************************************************************************
 * @history :
 * V1.0 : 1.确立语义化版本起点 0.1.0
 ******************************************************************************
 */
#ifndef PFA_APP_VERSION_H
#define PFA_APP_VERSION_H

#ifdef __cplusplus
 extern "C" {
#endif /* __cplusplus */

/* Includes ------------------------------------------------------------------*/


/* Exported types ------------------------------------------------------------*/


/* Exported constants --------------------------------------------------------*/


/* Exported macros -----------------------------------------------------------*/
#define APP_VERSION_MAJOR       (0U)
#define APP_VERSION_MINOR       (1U)
#define APP_VERSION_PATCH       (0U)

/** @brief 供协议上报与日志使用的版本字符串，须与上面三个数字一致 */
#define APP_VERSION_STRING      "0.1.0"

/* Exported variables --------------------------------------------------------*/


/* Exported functions --------------------------------------------------------*/


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* PFA_APP_VERSION_H */
