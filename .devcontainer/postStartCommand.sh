#!/usr/bin/env bash
set -euo pipefail

# ---------------------------
# AWSプロファイルの設定
# ---------------------------
AWS_PROFILE_PATH="$HOME/.aws"
mkdir -p "$AWS_PROFILE_PATH"

echo "AWS Configファイルを作成します"
bash /workspace/.devcontainer/init_aws_profile.sh \
    "/aws_settings/config" "AWS_CONFIG" \
    "$AWS_PROFILE_PATH/config"
echo "AWS Configファイルを作成しました"
echo

echo "AWS Credentialsファイルを作成します"
bash /workspace/.devcontainer/init_aws_profile.sh \
    "/aws_settings/credentials" "AWS_CREDENTIALS" \
    "$AWS_PROFILE_PATH/credentials"
echo "AWS Credentialsファイルを作成しました"
echo
