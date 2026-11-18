# todo — Markdown の TODO 管理

TODO を手元の Markdown で持ち、Claude Code に操作させるための仕組み。
データは Markdown のまま持ち、人は `todo-view`（色付きビューア）と leaf で読み、更新は主に Claude に任せる。

- TODO 管理エージェントの役割と手順は `.claude/agents/todo.md` にある（`claude --agent todo` で起動する）。

以下は、どのエージェントもデータを触るときに守るルール。

## ファイル構成

- `data/active.md` — 未完了の TODO 一覧（アイゼンハワー・マトリクスの 4 象限）
- `data/notes/<id>-<slug>.md` — 詳細・作業記録が必要な TODO のメモ。完了しても移動・削除しない
- `data/archive.md` — 完了した TODO の記録（追記のみ）
- `demo/` — レイアウト確認用のダミーデータ（`todo-reset --demo`）。実データではない
- `data.template/` — 空の `data/` の雛形。`install.sh` が `data/` が無いときにこれをコピーする

`data/` は todo リポジトリでは git 管理しない（`.gitignore` 済み）。`data/` の中だけが、手元専用の独立した git リポジトリになっている。

## active.md の書式

見出しは次の 4 つで固定。順番も変えない（緊急のものが上に来る順）。

- `## Necessary（緊急かつ重要）`
- `## Distraction（緊急だが重要でない）`
- `## Effective（重要だが緊急でない）`
- `## Waste（緊急でも重要でもない）`

各見出しの下に 1 つの Markdown テーブルを置く。列は次の順。

| 列 | 内容 |
|----|------|
| id | 整数。全 TODO に必ず振る |
| status | `none`（未着手）/ `wip`（作業中）/ `pending`（止まっている。理由は問わない） |
| name | 1 行の短い説明。`|` は使わない |
| start | 着手予定日 `YYYY-MM-DD`。無ければ空 |
| due | 期限 `YYYY-MM-DD`。無ければ空 |
| notes | `data/notes/` にメモがあれば `o`、無ければ `x` |

- 空の象限でもヘッダ行と区切り行は残す。
- 新しい行は、その象限のテーブルの末尾に足す。並べ替えはユーザーに頼まれたときだけ行う。
- 利用可能な status の一覧と色は `scripts/todo-view.toml` が正。新しい status を使うときはそこにも追記する。
- `active.md` は `todo-view` が監視して色付きで表示している。書式を崩すと表示が壊れるので、テーブル以外の文章を書かない。

## ID の規則

- 新しい id は `scripts/todo-next-id` の出力を使う。
  - 1 回の操作で複数件を足すときは、出力された id から順に +1 して振る。
- id は再利用しない。完了・削除後も欠番のまま。
- ユーザーは「30 をやりたい」のように id だけで指示する。数字だけの指示（「30」「30 完了」など）は、id のことだと解釈する。

## コミット

`data/` のデータを変更したら、その操作単位で **`data/` のリポジトリに** commit する（`git -C data commit ...`。例: `add #31`, `done #30`）。取り消しや履歴の確認のためのもので、remote は無く push もしない。

todo リポジトリ本体（仕組み）のコミットにデータを混ぜない。
