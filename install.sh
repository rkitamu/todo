#!/usr/bin/env bash
# scripts/ 配下の実行可能ファイルを ~/.local/bin にシンボリックリンクする。
#   ./install.sh            リンクを作成（既存のリンクは張り直す）
#   ./install.sh --uninstall このリポジトリを指すリンクだけ削除
# リンクではない同名ファイルが既にある場合は上書きせずに中断する。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO/scripts"
DEST="${INSTALL_BIN_DIR:-$HOME/.local/bin}"

mode="install"
[[ "${1:-}" == "--uninstall" ]] && mode="uninstall"

mkdir -p "$DEST"

for f in "$SRC"/*; do
  [[ -f "$f" && -x "$f" ]] || continue
  name="$(basename "$f")"
  link="$DEST/$name"

  if [[ "$mode" == "uninstall" ]]; then
    if [[ -L "$link" && "$(readlink "$link")" == "$f" ]]; then
      rm "$link" && echo "removed  $link"
    fi
    continue
  fi

  if [[ -e "$link" && ! -L "$link" ]]; then
    echo "error: $link はリンクではない既存ファイルです。手動で確認してください。" >&2
    exit 1
  fi
  ln -sfn "$f" "$link"
  echo "linked   $link -> $f"
done

if [[ "$mode" == "install" ]] && ! command -v uv >/dev/null; then
  echo "warning: uv が見つかりません。todo-view の実行には uv が必要です。" >&2
fi

# data/ は todo リポジトリでは管理せず、手元専用の git リポジトリにする（push しない）。
# 無ければ data.template/ から作って初期コミットする。既にあれば触らない。
if [[ "$mode" == "install" && ! -e "$REPO/data" ]]; then
  cp -r "$REPO/data.template" "$REPO/data"
  git -C "$REPO/data" init -q
  git -C "$REPO/data" add -A
  git -C "$REPO/data" commit -q -m "init"
  echo "created  $REPO/data（手元専用の git リポジトリ）"
fi
