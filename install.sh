#!/usr/bin/env bash
# todo リポジトリを使えるようにする。
#   ./install.sh  data/ が無ければ data.template/ から作り、git フック（.githooks/）を有効にし、uv の有無を確認する
# scripts/ のコマンドは PATH に置かず、リポジトリからの相対パス（scripts/todo-view など）で呼ぶ。
# 再実行してもよい（既にある data/ には触らない）。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# .githooks/ のフックを有効にする（commit-msg: メッセージの形、pre-commit / pre-merge-commit / pre-push: main への直接コミット・push の拒否）。
# commit.cleanup=strip で、-m・-F・--no-edit のときも # のコメント行を git に消させる
# （既定ではエディタを開いたときしか消えず、マージの '# Conflicts:' などが残る）。
# todo リポジトリの config だけを変えるので、data/ の git リポジトリには影響しない。
# git の作業ツリーでなければ（アーカイブから展開したときなど）飛ばす。
if git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$REPO" config core.hooksPath .githooks
  git -C "$REPO" config commit.cleanup strip
fi

if ! command -v uv >/dev/null; then
  echo "warning: uv が見つかりません。todo-view の実行には uv が必要です。" >&2
fi

# data/ は todo リポジトリでは管理せず、手元専用の git リポジトリにする（push しない）。
# 無ければ data.template/ から作って初期コミットする。既にあれば触らない。
if [[ ! -e "$REPO/data" ]]; then
  cp -r "$REPO/data.template" "$REPO/data"
  git -C "$REPO/data" init -q
  git -C "$REPO/data" add -A
  git -C "$REPO/data" commit -q -m "init"
  echo "created  $REPO/data（手元専用の git リポジトリ）"
fi
