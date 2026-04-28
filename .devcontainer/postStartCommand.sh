#!/usr/bin/env bash
set -euo pipefail

# ---------------------------
# miseの設定
# ---------------------------
echo " ◆ mise trust を実行して、mise.toml を自動で信頼済みにします"
mise trust -a
echo
