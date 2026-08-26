#!/usr/bin/env python3
"""firmware/ 目录树里「哪些是自研代码」的单一事实源。

有两个门禁需要区分自研代码与入仓的上游代码，但出发点不同：

  - tools/run_cppcheck.py 据此决定扫描范围。按 ADR 0004，上游代码的 MISRA 告警不算
    本仓库的缺陷。
  - tools/check_source_registration.py 据此决定「盘上有文件却两处工程都没登记」这条
    检查的搜索范围。入仓副本通常整树拷贝（例如 STM32 HAL 的全部模块），我们只编译
    其中几个，未登记是常态而不是缺陷。

两个门禁的排除集合必须相同，否则会出现「cppcheck 不扫、登记检查却要求登记」这类互相
矛盾的要求。所以集合写在这里一份，谁都别自己再抄一遍。

注意排除的是「扫描/搜索范围」，不是「比对范围」：某个上游 .c 一旦被任一工具链登记，
它就必须同时出现在两条工具链里，这条比对对上游代码同样成立。
"""

from __future__ import annotations

import pathlib

# 编译输入的后缀。头文件不在其列：它们被加进 Keil 的 Group 只为方便浏览。
SOURCE_SUFFIXES = frozenset({".c", ".S", ".s"})

# 入仓的上游代码子树（相对 firmware/）：sys/ 从 Zephyr 拷贝裁剪，third_party/ 是
# 按锁定 tag 入仓的第三方组件。新增入仓子树时加在这里。
VENDORED_SUBTREES = ("sys", "third_party")


def is_vendored(relative_path: pathlib.PurePath) -> bool:
    """判断 firmware/ 下的相对路径是否落在入仓的上游子树内。"""
    parts = relative_path.parts
    return (len(parts) > 0) and (parts[0] in VENDORED_SUBTREES)
