#!/usr/bin/env python3
"""PreToolUse(Bash) hook: grep 系コマンドを拒否し ripgrep(rg) / ag へ誘導する。

背景:
  - GNU grep は「改行の無い巨大ファイル」(minified JS, ログ, バイナリ等) に当たると
    1 行をまるごとメモリに載せるため、簡単に数 GB を確保して OOM を起こす。
  - さらに Claude Code はシェルスナップショットで `grep` を関数として乗っ取り、
    `claude -G` (Node 製 ugrep) に転送する。1 回の grep ごとに Node プロセスが
    立ち上がるので、メモリ上限を切ったマシン (NucBox の user-1000.slice) では
    パイプやループで多重起動した瞬間に効いてくる。
  rg / ag は ignore ファイルを尊重し、メモリ使用量も安定しているのでそちらを使う。

判定方針:
  文字列全体に "grep" が含まれるかではなく、「コマンド名の位置」に来た
  grep 系だけを拒否する。ヒアドキュメント本文とクォート内の文字列は
  シェルの語彙規則どおり読み飛ばすので、grep の話を書いた PR 本文や
  ドキュメントを流し込んでも誤検知しない。

  拒否する:
    grep x / cmd | grep x / $(grep x) / `grep x` / xargs -0 grep x /
    sudo grep x / timeout 5 grep x / LC_ALL=C grep x /
    for f in *; do grep x; done / sh -c 'grep x' / /bin/grep x
  通す:
    git grep x (別実装でメモリ問題が無い) / rg 'grep' (引数中の grep) /
    pgrep / ripgrep / git log --grep= / echo "a | grep b" /
    cat <<'EOF' ... grep ... EOF
"""

from __future__ import annotations

import json
import re
import shlex
import sys

BANNED = {
    "grep", "egrep", "fgrep", "rgrep",
    "zgrep", "zegrep", "zfgrep", "bzgrep", "xzgrep", "lzgrep",
}

# コマンド名の手前に現れうるラッパー・シェルキーワード。読み飛ばして次を見る。
WRAPPERS = {
    "sudo", "doas", "env", "command", "builtin", "exec", "nohup",
    "time", "timeout", "nice", "ionice", "stdbuf", "xargs", "watch",
    "if", "then", "else", "elif", "while", "until", "do", "!",
}

# `sh -c '...'` の中身も再帰的に見る
SHELLS = {"sh", "bash", "zsh", "dash", "ksh", "ash"}

# ここを跨ぐと次のトークンが再びコマンド名の位置になる
OPERATORS = {"|", "||", "&", "&&", ";", ";;", "(", ")", "{", "}", "\n"}

# リダイレクト。直後のトークンはファイル名なのでコマンド名ではない
REDIRECTS = {"<", ">", ">>", "<<", "<<<", ">|", "<>"}

# timeout 5 / nice 10 のような数値引数
NUMERIC = re.compile(r"^\d+[smhd]?$")

# <<EOF / <<-'EOF' / <<"EOF"
HEREDOC = re.compile(r"<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1")

# バッククォート `...` の中身
BACKTICK = re.compile(r"`([^`]*)`")


def strip_heredocs(text: str) -> str:
    """ヒアドキュメント本文を落とす。中身はシェルが解釈しないデータなので。"""
    out: list[str] = []
    pos = 0
    while True:
        m = HEREDOC.search(text, pos)
        if m is None:
            out.append(text[pos:])
            return "".join(out)
        out.append(text[pos : m.start()])
        newline = text.find("\n", m.end())
        if newline == -1:  # 本文が始まる前に終端。残りは無い
            return "".join(out)
        out.append(text[m.end() : newline])  # 開始行の残り (`2>&1` 等) は残す
        terminator = re.compile(
            r"^[ \t]*" + re.escape(m.group(2)) + r"[ \t]*$", re.MULTILINE
        )
        end = terminator.search(text, newline + 1)
        if end is None:  # 閉じていない = 以降は全部本文
            return "".join(out)
        pos = end.end()


def lex(text: str) -> list[str]:
    """クォートを尊重しつつ、シェル演算子を独立したトークンとして切り出す。

    改行もコマンド区切りなので演算子扱いにする (shlex の既定では空白扱い)。
    """
    lexer = shlex.shlex(text, posix=True, punctuation_chars="();<>|&\n")
    lexer.whitespace = " \t\r"
    lexer.whitespace_split = True
    try:
        return list(lexer)
    except ValueError:
        # クォートが閉じていない等。素朴な分割にフォールバックする
        return text.split()


def basename(token: str) -> str:
    """`/usr/bin/grep` や `\\grep` からコマンド名だけ取り出す。"""
    return token.lstrip("\\").rsplit("/", 1)[-1]


def command_names(text: str) -> list[str]:
    """text の中で「コマンド名の位置」に立つトークンを列挙する。"""
    found: list[str] = []
    body = strip_heredocs(text)

    # バッククォート置換の中身は独立したコマンド。先に取り出して外側から外す
    for inner in BACKTICK.findall(body):
        found.extend(command_names(inner))
    body = BACKTICK.sub(" ", body)

    tokens = lex(body)
    at_command = True
    i = 0
    while i < len(tokens):
        token = tokens[i]
        i += 1

        if token in OPERATORS:
            at_command = True
            continue
        if token in REDIRECTS:
            i += 1  # リダイレクト先を読み飛ばす
            continue

        if not at_command:
            continue
        if "=" in token and not token.startswith("-"):
            continue  # VAR=value 形式の一時環境変数

        name = basename(token)
        if name in WRAPPERS:
            while i < len(tokens) and (
                tokens[i].startswith("-") or NUMERIC.match(tokens[i])
            ):
                i += 1
            continue

        found.append(name)
        at_command = False
        if name in SHELLS:
            for j in range(i, len(tokens) - 1):
                if tokens[j] == "-c":
                    found.extend(command_names(tokens[j + 1]))
                    break
    return found


REASON = """`{name}` は禁止されています (メモリ枯渇の原因になるため)。ripgrep / ag を使ってください。

  ファイル内容の検索      → Grep ツール (内蔵 ripgrep) を優先。無ければ `rg`
  grep -rn PAT dir        → rg -n PAT dir
  grep -rl PAT dir        → rg -l PAT dir
  grep -F 'literal' f     → rg -F 'literal' f
  cmd | grep PAT          → cmd | rg PAT
  cmd | grep -v PAT       → cmd | rg -v PAT
  cmd | grep -c PAT       → cmd | rg -c PAT
  ps aux | grep foo       → ps aux | rg foo

rg が無い環境では `ag`。git 管理下のリポジトリ内なら `git grep` も許可されています。
grep 固有のオプションが本当に必要な場合はユーザーに相談してください。"""


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0  # 解釈できない入力ではブロックしない

    command = (payload.get("tool_input") or {}).get("command") or ""
    hit = next((n for n in command_names(command) if n in BANNED), None)
    if hit is None:
        return 0

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": REASON.format(name=hit),
            }
        },
        sys.stdout,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
