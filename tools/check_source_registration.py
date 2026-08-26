#!/usr/bin/env python3
"""核对双工具链的源文件清单没有分叉。

ADR 0001 决定本机用手工维护的 Keil MDK 工程开发、CI 用 CMake + arm-none-eabi-gcc
做编译验证，代价是同一批源要在两处工程描述里各登记一遍。人工同步迟早会漏，漏了
之后「只在一侧能编过」的文件会静默存在很久，因此这里把约定变成门禁：

  1. 任一处登记的源文件都必须同时出现在另一处；
  2. 两处不得登记不存在的文件；
  3. 自研目录下的源文件不得两处都漏登记。

第 3 条只搜自研目录，入仓的上游子树不搜（判据见 tools/firmware_tree.py）：整树拷贝
进来的上游代码通常只编译其中几个文件，未登记是常态。但第 1、2 条对上游文件同样成立
——一旦登记，就必须两处都登记。

另有两类文件全程不参与：链接描述属于工具链私有（GCC 用 startup/stm32f103xe_flash.ld，
armlink 用 MDK-ARM/pfa_imp.sct），而头文件即便被加进 Keil 的 Group 也只是为了在
µVision 里方便浏览，不是编译输入。启动文件本身是双方共用的同一份 .S。

用法：
    check_source_registration.py [--repo-root <path>]
"""

from __future__ import annotations

import argparse
import pathlib
import re
import sys
import xml.etree.ElementTree as ElementTree

from firmware_tree import SOURCE_SUFFIXES, is_vendored

CMAKE_SOURCES_RE = re.compile(
    r"set\(PFA_IMP_SOURCES(?P<body>.*?)\)", re.DOTALL
)


def read_cmake_sources(cmake_file: pathlib.Path) -> set[str]:
    match = CMAKE_SOURCES_RE.search(cmake_file.read_text(encoding="utf-8"))
    if match is None:
        sys.exit(f"{cmake_file} 里找不到 set(PFA_IMP_SOURCES ...) 清单")

    sources: set[str] = set()
    for raw in match.group("body").splitlines():
        entry = raw.split("#", 1)[0].strip()
        if entry:
            sources.add(entry.replace("\\", "/"))
    return sources


def read_keil_sources(uvprojx: pathlib.Path, firmware_dir: pathlib.Path) -> set[str]:
    tree = ElementTree.parse(uvprojx)
    sources: set[str] = set()
    for node in tree.iter("FilePath"):
        if node.text is None:
            continue
        raw = node.text.strip().replace("\\", "/")
        if not raw:
            continue
        # 头文件常被加进 Group 只为在 µVision 里方便浏览，它们不是编译输入，不比对
        if pathlib.PurePosixPath(raw).suffix not in SOURCE_SUFFIXES:
            continue
        # .uvprojx 里的路径相对 MDK-ARM 目录，统一折算成相对 firmware 目录
        resolved = (uvprojx.parent / raw).resolve()
        try:
            sources.add(resolved.relative_to(firmware_dir).as_posix())
        except ValueError:
            sys.exit(
                f"{uvprojx.name} 登记了 firmware/ 之外的源文件：{raw}\n"
                "双工具链比对以 firmware/ 为根，源文件请放在 firmware/ 下。"
            )
    return sources


def discover_sources(firmware_dir: pathlib.Path) -> set[str]:
    """列出盘上的源文件，用于「登记了不存在的文件」这条检查（含上游子树）。"""
    return {
        path.relative_to(firmware_dir).as_posix()
        for path in firmware_dir.rglob("*")
        if path.is_file() and (path.suffix in SOURCE_SUFFIXES)
    }


def report(title: str, entries: set[str]) -> None:
    print(f"{title}：", file=sys.stderr)
    for entry in sorted(entries):
        print(f"  - {entry}", file=sys.stderr)


def main() -> int:
    parser = argparse.ArgumentParser(description="核对双工具链源清单一致")
    parser.add_argument(
        "--repo-root",
        default=pathlib.Path(__file__).resolve().parent.parent,
        type=pathlib.Path,
        help="仓库根目录",
    )
    args = parser.parse_args()

    firmware_dir = (args.repo_root / "firmware").resolve()
    cmake_sources = read_cmake_sources(firmware_dir / "CMakeLists.txt")
    keil_sources = read_keil_sources(
        firmware_dir / "MDK-ARM" / "pfa_imp.uvprojx", firmware_dir
    )
    on_disk = discover_sources(firmware_dir)

    failed = False

    missing_in_keil = cmake_sources - keil_sources
    if missing_in_keil:
        report("CMake 已登记但 Keil 工程缺失", missing_in_keil)
        failed = True

    missing_in_cmake = keil_sources - cmake_sources
    if missing_in_cmake:
        report("Keil 工程已登记但 CMake 清单缺失", missing_in_cmake)
        failed = True

    own_code = {
        entry
        for entry in on_disk
        if not is_vendored(pathlib.PurePosixPath(entry))
    }
    unregistered = own_code - cmake_sources - keil_sources
    if unregistered:
        report("自研源文件存在于 firmware/ 但两处工程都未登记", unregistered)
        failed = True

    phantom = (cmake_sources | keil_sources) - on_disk
    if phantom:
        report("工程描述登记了不存在的文件", phantom)
        failed = True

    if failed:
        print(
            "\n双工具链源清单已分叉，改法见 docs/build.md「新增源文件」。",
            file=sys.stderr,
        )
        return 1

    print(
        f"双工具链源清单一致：已登记 {len(cmake_sources)} 个源文件，"
        f"其中自研 {len(own_code & cmake_sources)} 个。"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
