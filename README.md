# todo

TODO を Markdown で管理し、Claude Code に操作させるための仕組み。データ（`data/`）はこのリポジトリに含めない。

## 構成

```
todo/
├── CLAUDE.md              # リポジトリの思想とデータのルール
├── .claude/agents/todo.md # TODO 管理エージェントの役割（claude --agent todo）
├── install.sh             # data/ の用意、commit-msg フックの有効化、uv の確認
├── .githooks/commit-msg   # コミットメッセージの形を確かめるフック
├── scripts/
│   ├── todo-view          # active.md の色付きビューア
│   ├── todo-notes         # notes を id の数字順に選んで leaf で開く
│   ├── todo-next-id       # 次に振る id を表示
│   ├── todo-view.toml     # status / 象限 / 期限の色設定（既定値）
│   └── todo-view.local.toml # 手元だけの上書き（任意。git 管理しない）
├── contrib/herdr/todo-herdr # herdr にビューアとエージェントを並べる（任意）
├── data/                  # 実データ。このリポジトリでは管理しない（手元専用の別 git リポジトリ）
│   ├── active.md          # 未完了の TODO（4 象限のテーブル）
│   ├── archive.md         # 完了した TODO
│   └── notes/             # TODO ごとの詳細メモ（NN-slug.md）
├── data.template/         # data/ の空の雛形（install.sh が data/ を作るときに使う）
├── demo/                  # 表示確認用のダミーデータ（scripts/todo-view demo/active.md）
└── LICENSE                # MIT
```

## セットアップ

前提:

- `todo-notes` を使うなら fzf と leaf が入っている
- [uv](https://docs.astral.sh/uv/) が入っている。`todo-view` が必要とする次のものは、初回実行時に uv が用意する
  - Python 3.11 以上
  - rich 13 以上

```sh
git clone <this repo> todo
cd todo
./install.sh
```

- `data/` が無ければ `data.template/` から作り、手元専用の git リポジトリとして初期コミットする（既にあれば触らない）。別のマシンにデータを移すときは `data/` ごとコピーする
- commit-msg フックを有効にする（件名は Conventional Commits の形）
- uv が見つからなければ警告する
- 再実行してもよい
- `scripts/` のコマンドは PATH に置かない。複数の環境に clone しても混ざらないよう、リポジトリのディレクトリから `scripts/todo-view` のような相対パスで実行する

## 使い方

### ビューア

```sh
scripts/todo-view                   # data/active.md を監視して表示
scripts/todo-view path/to/active.md # 別のファイルを表示
scripts/todo-view --once            # 1 回だけ描画して終了
```

- `q` / `Ctrl-C` で終了、`r` で再描画
- 画面に収まらないときはスクロールできる: `j`/`k`・`↑`/`↓`（1 行）、`Space`/`b`・`PgDn`/`PgUp`（1 画面）、`g`/`G`（先頭/末尾）。端末が対応していればマウスホイールも効く
- `Ctrl-E` で `$VISUAL` / `$EDITOR` を開いて active.md を編集（herdr 上では編集中だけペインを最大化）
- active.md・notes/・`todo-view.toml` の変更を検知して自動で再描画する
- 色や status の種類は `scripts/todo-view.toml` で変えられる（書き方はファイル内のコメントを参照）。手元だけ変えたいときは、変えたい値だけを `scripts/todo-view.local.toml`（git 管理しない）に書くと上に重なる

### notes のピッカー

```sh
scripts/todo-notes                # data/notes を id の数字順に並べて選ぶ
scripts/todo-notes demo/notes     # 別の notes ディレクトリ
```

- 文字を打つと id でもタイトルでも絞り込める（`18` と打てば #18 が先頭に来る）。Enter で開く、Ctrl-R で再読み込み、Ctrl-P でプレビューの切替、Esc で終了
- 選んだ note は `leaf --watch` で開き、`q` で閉じると一覧に戻る。herdr 上ではマウスキャプチャを自動で切る
- fzf と leaf が必要

### エージェント

```sh
claude --agent todo   # リポジトリのディレクトリで起動する
```

役割は `.claude/agents/todo.md`、データのルールは `CLAUDE.md` にある。TODO を追加・更新・アーカイブする。「30 をやりたい」のように id で指示できる。

新しい TODO の id は `scripts/todo-next-id` が払い出す（エージェントが TODO を足すときに使う）。

### herdr で並べる（任意）

```sh
contrib/herdr/todo-herdr
```

- [herdr](https://herdr.dev) に `todo` ワークスペースを作り、左上に `todo-view`、左下に `claude --agent todo`、右に `todo-notes` を並べる
- ワークスペースが既にあれば、`todo-view`・`todo-notes` が止まっているペインだけで起動し直す（herdr の再起動ではビューアが戻らないため）
- ペインの配置は作者の好みの例。合わなければスクリプトを書き換えて使う
- herdr と jq が必要
