#!/usr/bin/env python3
"""核对固件镜像里不存在任何动态内存分配的实现。

项目规范禁止 malloc/free 及任何动态分配（见 README 工程约定与 ADR 0004 的
"RAM 占用可预测" 意图）。只靠代码评审容易漏掉「某个库函数悄悄拖进了堆」这类
情况，因此在链接完成后直接检查镜像的符号表：只要这些分配函数被 *定义* 进了
镜像（而不仅是未解析引用），就让构建失败。

用法：
    check_no_dynamic_alloc.py --nm <arm-none-eabi-nm> <image.elf>
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys

# 被禁止出现在镜像里的分配相关符号。含 newlib 的可重入变体，以及内部会分配的
# 少数标准函数。
FORBIDDEN_SYMBOLS = frozenset(
    {
        "malloc",
        "free",
        "calloc",
        "realloc",
        "reallocarray",
        "aligned_alloc",
        "memalign",
        "valloc",
        "pvPortMalloc",
        "vPortFree",
        "_malloc_r",
        "_free_r",
        "_calloc_r",
        "_realloc_r",
        "_memalign_r",
        "strdup",
        "strndup",
        "asprintf",
        "vasprintf",
    }
)

# nm 的 BSD 格式输出：<地址> <类型> <符号名>。类型为 U 表示未解析的引用，
# 未解析引用不算「镜像里有实现」，因此不拦。
NM_LINE_RE = re.compile(r"^(?P<addr>[0-9a-fA-F]*)\s+(?P<type>\S)\s+(?P<name>\S+)$")


def collect_defined_symbols(nm_tool: str, image: str) -> set[str]:
    try:
        completed = subprocess.run(
            [nm_tool, "--defined-only", image],
            check=True,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        sys.exit(f"找不到 nm 工具：{nm_tool}")
    except subprocess.CalledProcessError as exc:
        sys.exit(f"nm 执行失败（退出码 {exc.returncode}）：{exc.stderr.strip()}")

    symbols: set[str] = set()
    for line in completed.stdout.splitlines():
        match = NM_LINE_RE.match(line.strip())
        if match is not None and match.group("type") != "U":
            symbols.add(match.group("name"))
    return symbols


def main() -> int:
    parser = argparse.ArgumentParser(description="核对镜像中无动态内存分配")
    parser.add_argument("--nm", required=True, help="交叉工具链的 nm 可执行文件")
    parser.add_argument("image", help="待检查的固件镜像（.elf）")
    args = parser.parse_args()

    defined = collect_defined_symbols(args.nm, args.image)
    offenders = sorted(defined & FORBIDDEN_SYMBOLS)

    if offenders:
        print("镜像中出现了被禁止的动态内存分配符号：", file=sys.stderr)
        for name in offenders:
            print(f"  - {name}", file=sys.stderr)
        print(
            "请改用静态分配。若确有不可避免的第三方依赖，需先补一条 ADR 说明偏离。",
            file=sys.stderr,
        )
        return 1

    print("无动态内存分配符号，检查通过。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
