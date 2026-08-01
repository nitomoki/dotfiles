#!/usr/bin/env python3
"""deny-grep.py の判定マトリクス。hook 本体を直接 import して検証する。"""
import importlib.util
import pathlib
import sys

spec = importlib.util.spec_from_file_location(
    "deny_grep", pathlib.Path.home() / ".claude" / "hooks" / "deny-grep.py"
)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


def blocked(cmd):
    return next((n for n in mod.command_names(cmd) if n in mod.BANNED), None)


G = "gr" + "ep"  # このテストファイル自体が誤検知の的にならないよう分割

DENY = [
    f"{G} -rn foo .",
    f"ps aux | {G} foo",
    f"cat x.log | {G} -v INFO",
    f"echo $({G} x file)",
    f"echo `{G} x file`",
    f"find . -type f | xargs -0 {G} -l TODO",
    f"sudo {G} root /etc/passwd",
    f"for f in *; do {G} x \"$f\"; done",
    f"sh -c '{G} foo bar'",
    f"/bin/{G} foo x",
    f"/usr/bin/{G} foo x",
    'e' + G + ' "a|b" x',
    'z' + G + " foo x.gz",
    f"command {G} foo x",
    f"timeout 5 {G} foo x",
    f"LC_ALL=C {G} foo x",
    f"ls && {G} foo x",
    # 複数行スクリプト（改行がコマンド区切りとして効くか）
    f"cd /tmp\n{G} -rn foo .",
    f"set -e\nls\n{G} foo x\n",
    # 出力リダイレクト付き
    f"{G} foo x > /tmp/out",
    f"if {G} -q foo x; then echo yes; fi",
]

ALLOW = [
    f"git {G} foo",
    f"cd ~/repo && git {G} -n TODO",
    "rg -n foo .",
    f"rg -n '{G}' .",
    "pgrep -f claude",
    f"ps aux | rg {G}",
    f"git log --{G}=fix",
    "make help",
    "echo hello",
    "ag foo .",
    "ls -la",
    'python3 -c "print(1)"',
    # クォート内の文字列（ドキュメント・コミットメッセージ）
    f'echo "a | {G} b"',
    f"git commit -m 'replace {G} with rg'",
    f"gh pr create --title 'ban {G}' --body 'cmd | {G} x is blocked'",
    # ヒアドキュメント本文
    f"cat <<'EOF' > /tmp/doc.md\n| cmd | {G} x |\n{G} -rn foo .\nEOF\n",
    f"git commit -F - <<'EOF'\nfeat: ban {G}\n\ncmd | {G} x を禁止した\nEOF",
    # 開始行の残りは残るので、ヒアドキュメント後のコマンドも見える
    "cat <<'EOF' 2>&1\nbody\nEOF\nrg foo .",
    # ripgrep / 部分一致
    "which ripgrep",
    f"echo {G}suffix",
]

fails = 0
for cmd in DENY:
    hit = blocked(cmd)
    label = "OK  " if hit else "FAIL"
    fails += hit is None
    print(f"  {label} deny  {cmd!r}")
for cmd in ALLOW:
    hit = blocked(cmd)
    label = "FAIL" if hit else "OK  "
    fails += hit is not None
    print(f"  {label} allow {cmd!r}" + (f"   <- 誤検知: {hit}" if hit else ""))

print(f"\n{len(DENY) + len(ALLOW) - fails}/{len(DENY) + len(ALLOW)} passed")
sys.exit(1 if fails else 0)
