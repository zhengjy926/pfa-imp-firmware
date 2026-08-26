#!/usr/bin/env python3
"""对自研固件源跑 cppcheck（含 MISRA C:2012 插件）。

AC6 没有内置 MISRA 检查（见 ADR 0001），合规门禁由 cppcheck 承担。按 ADR 0004，
扫描范围排除入仓的上游子树——不能把上游代码的告警算作本仓库的缺陷。哪些算上游见
tools/firmware_tree.py，那里也说明了为什么它与源登记门禁共用同一份判据。

被扫描的文件列表由目录结构推导，而不是写死清单：新增自研源文件会自动进入扫描，
不需要再改这个脚本。

本地与 CI 走同一个入口，避免「CI 上才发现」。MISRA 插件的位置由脚本自己探测，不在
CI 配置里写死路径——各发行版把 misra.py 装在不同地方，写死会让门禁在换 runner 镜像时
静默失效。用法：
    run_cppcheck.py [--cppcheck <exe>] [--addon <misra.py 或 misra>]
"""

from __future__ import annotations

import argparse
import pathlib
import shutil
import subprocess
import sys

from firmware_tree import VENDORED_SUBTREES, is_vendored

# 自研代码的头文件搜索路径（相对仓库根）
INCLUDE_DIRS = (
    "firmware/app/include",
    "firmware/bsp/include",
)

# 第三方头文件搜索路径：参与预处理，但其自身不被扫描
SYSTEM_INCLUDE_DIRS = (
    "firmware/third_party/cmsis_core/Include",
    "firmware/third_party/cmsis_device_f1/Include",
)


def locate_misra_addon(cppcheck: str) -> str:
    """找出 misra.py 的位置，找不到就退回插件名让 cppcheck 自己解析。

    cppcheck 接受插件名（如 misra）或 .py 的路径。前者依赖 cppcheck 自身的数据目录
    配置，在部分发行版的包里解析不到；后者的路径又随发行版而异。所以先按已知位置找
    文件，找不到再退回插件名——两条路都走不通时，让 cppcheck 自己报错，因为它的错误
    信息比这里能给的更准确。
    """
    candidates = [
        pathlib.Path("/usr/share/cppcheck/addons"),
        pathlib.Path("/usr/lib/cppcheck/addons"),
        pathlib.Path("/usr/local/share/cppcheck/addons"),
        pathlib.Path(r"C:\Program Files\Cppcheck\addons"),
    ]

    resolved = shutil.which(cppcheck)
    if resolved is not None:
        candidates.insert(0, pathlib.Path(resolved).resolve().parent / "addons")

    for directory in candidates:
        addon = directory / "misra.py"
        if addon.is_file():
            return addon.as_posix()

    return "misra"


def collect_sources(repo_root: pathlib.Path) -> list[str]:
    firmware = repo_root / "firmware"
    sources: list[pathlib.Path] = []
    for path in sorted(firmware.rglob("*.c")):
        if is_vendored(path.relative_to(firmware)):
            continue
        sources.append(path)
    return [source.as_posix() for source in sources]


def main() -> int:
    parser = argparse.ArgumentParser(description="对自研固件源跑 cppcheck + MISRA")
    parser.add_argument("--cppcheck", default="cppcheck", help="cppcheck 可执行文件")
    parser.add_argument(
        "--addon",
        default=None,
        help="MISRA 插件：插件名或 misra.py 的绝对路径；缺省时自动探测",
    )
    parser.add_argument(
        "--repo-root",
        default=pathlib.Path(__file__).resolve().parent.parent,
        type=pathlib.Path,
        help="仓库根目录",
    )
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    sources = collect_sources(repo_root)
    if not sources:
        print("firmware/ 下没有需要扫描的自研源文件", file=sys.stderr)
        return 1

    addon = args.addon if args.addon is not None else locate_misra_addon(args.cppcheck)

    command = [
        args.cppcheck,
        f"--addon={addon}",
        "--std=c99",
        "--language=c",
        "--platform=arm32-wchar_t4",
        "--enable=warning,style,performance,portability",
        "--inline-suppr",
        "--error-exitcode=1",
        "-DSTM32F103xE",
    ]

    # 把被排除的子树也从「告警归属」上排除掉。cppcheck 没有 -isystem 的等价物：
    # 第三方头文件必须参与预处理，否则连预处理都过不去，但它们内部的告警不算本
    # 仓库的缺陷。这属于扫描范围本身，不是「偏离」，所以写在这里而不是
    # tools/cppcheck/suppressions.txt（那里只登记本仓库代码的偏离）。
    for excluded in VENDORED_SUBTREES:
        command.append(f"--suppress=*:*firmware/{excluded}/*")

    suppressions = repo_root / "tools" / "cppcheck" / "suppressions.txt"
    if suppressions.is_file():
        command.append(f"--suppressions-list={suppressions.as_posix()}")

    for include_dir in INCLUDE_DIRS + SYSTEM_INCLUDE_DIRS:
        command.append(f"-I{(repo_root / include_dir).as_posix()}")

    command.extend(sources)

    print("运行：" + " ".join(command), flush=True)
    completed = subprocess.run(command, cwd=repo_root, check=False)
    return completed.returncode


if __name__ == "__main__":
    sys.exit(main())
