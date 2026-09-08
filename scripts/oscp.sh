#!/usr/bin/env bash
set -euo pipefail

SESSION="oscp"
WORKDIR="$HOME/Projects/env_pentest"
URL="https://portal.offsec.com/courses/pen-200-44065/labs"

# i3/rofi から起動された場合 SSH_AUTH_SOCK が継承されないことがある。
# docker-compose.yml が ${SSH_AUTH_SOCK} を要求するため、未設定なら補完する。
if [[ -z "${SSH_AUTH_SOCK:-}" || ! -S "${SSH_AUTH_SOCK:-}" ]]; then
  for sock in \
    "${XDG_RUNTIME_DIR:-}/openssh_agent" \
    "/run/user/$(id -u)/openssh_agent" \
    "/run/user/$(id -u)/gcr/ssh" \
    "/run/user/$(id -u)/keyring/ssh"; do
    if [[ -n "$sock" && -S "$sock" ]]; then
      export SSH_AUTH_SOCK="$sock"
      break
    fi
  done
fi

cd "$WORKDIR"
# コンテナが既に起動中ならそのまま使う（再作成せず高速に）。
# 起動していない場合のみ docker compose up を実行する。
if [[ "$(docker inspect -f '{{.State.Running}}' pentest 2>/dev/null)" != "true" ]]; then
  make dc-up
fi

tmux has-session -t "$SESSION" 2>/dev/null && tmux kill-session -t "$SESSION" || true

PANES=()

# window 1
read -r WID P0 < <(
  tmux new-session -d -s "$SESSION" -n "1" -c "$WORKDIR" -P -F '#{window_id} #{pane_id}'
)
PANES+=("$P0")

P1="$(tmux split-window -h -P -F '#{pane_id}' -t "$P0" -c "$WORKDIR")"
PANES+=("$P1")

# window 2〜4
for name in 2 3 4; do
  read -r WID P0 < <(
    tmux new-window -t "$SESSION" -n "$name" -c "$WORKDIR" -P -F '#{window_id} #{pane_id}'
  )

  PANES+=("$P0")

  P1="$(tmux split-window -h -P -F '#{pane_id}' -t "$P0" -c "$WORKDIR")"
  PANES+=("$P1")
done

# 全paneでコンテナに入る
for pane in "${PANES[@]}"; do
  tmux send-keys -t "$pane" "cd '$WORKDIR' && make dc-shell" C-m
done

# 最初のpaneに戻る
tmux select-pane -t "${PANES[0]}"

# 開く対象のモニター（出力）を決定する。
# rofi_run_scripts.sh から I3_TARGET_OUTPUT が渡されていればそれを使い、
# なければ現在フォーカスされている出力にフォールバックする。
TARGET_OUTPUT="${I3_TARGET_OUTPUT:-}"
if [[ -z "$TARGET_OUTPUT" ]]; then
  TARGET_OUTPUT="$(i3-msg -t get_workspaces \
    | python3 -c 'import json,sys; print(next(w["output"] for w in json.load(sys.stdin) if w["focused"]))')"
fi

# ワークスペースを表示し、対象モニターへ移動して開く
i3-msg workspace "$SESSION"
i3-msg "move workspace to output $TARGET_OUTPUT"
i3-msg workspace "$SESSION"

# アプリは i3-msg exec を使わず直接起動する。
# （i3-msg exec 経由だと状況によって二重起動することがあるため）
setsid google-chrome --new-window "$URL" </dev/null >/dev/null 2>&1 &
setsid alacritty --working-directory "$WORKDIR" -e tmux attach-session -t "$SESSION" </dev/null >/dev/null 2>&1 &
