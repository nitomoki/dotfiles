#!/bin/bash
# Claude Code の「セッション本体プロセス」PID を stdout に出す共通ヘルパ。
#
# 役割:
#   現在のプロセスの祖先を /proc の親子関係で遡り、cmdline に
#   `/share/claude/versions/` を含む最も近い祖先 (= claude 本体バイナリ) の
#   PID を返す。get-session-id.sh と statusline.sh の両方から使う。
#
# フロー:
#   起点 PID (引数 $1、無ければ自プロセス $$) から始めて、
#   /proc/<pid>/stat の親 PID を辿る。各段で /proc/<pid>/cmdline を検査し、
#   `/share/claude/versions/` を含めばその PID を出力して exit 0。
#   PID 1 到達 / 上限段数超過 / 読めない場合は exit 1 (stdout 無出力)。
#
# 実装上の注意:
#   /proc/<pid>/stat の第2フィールド (comm) は括弧内にスペースや `)` を
#   含みうる (例: `(2.1.201)`)。素朴な awk '{print $4}' は壊れるため、
#   `sed 's/^.*) //'` で最後の `) ` 以降 (= state ppid ...) を切り出してから
#   awk で ppid を取る。
set -uo pipefail

pid="${1:-$$}"

# 無限ループ・循環参照の保険として上限段数を設ける。
for _ in $(seq 1 40); do
  case "$pid" in
    ''|0|1) break ;;
  esac
  [ -r "/proc/$pid/stat" ] || break

  # cmdline (NUL 区切り) をスペース区切りにして検査。
  cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null)"
  case "$cmdline" in
    *"/share/claude/versions/"*)
      printf '%s\n' "$pid"
      exit 0
      ;;
  esac

  # 親 PID を取得。comm 内のスペース/括弧に強い切り出しを行う。
  ppid="$(sed 's/^.*) //' "/proc/$pid/stat" 2>/dev/null | awk '{print $2}')"
  [ -n "$ppid" ] || break
  pid="$ppid"
done

exit 1
