#!/usr/bin/env bash
# todo リポジトリを使えるようにする。
#   ./install.sh  data/ が無ければ data.template/ から作り、uv の有無を確認する
# scripts/ のコマンドは PATH に置かず、リポジトリからの相対パス（scripts/todo-view など）で呼ぶ。
# 再実行してもよい（既にある data/ には触らない）。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
