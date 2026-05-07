#!/bin/bash

# ---------------------------
# miseの初期化
# ---------------------------
echo " ◆ mise trust を実行して、mise.toml を自動で信頼済みにします"
mise trust 
# 絶対パスで強制的に信頼させる
mise trust /workspaces/eye-dle/mise.toml
echo

cd /workspace/eye-dle
mise install

# mise環境を有効化
eval "$(mise activate bash)"
