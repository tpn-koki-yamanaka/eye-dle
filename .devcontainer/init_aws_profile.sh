#!/usr/bin/env bash
set -euo pipefail

# --- 引数の受け取り ---
file_path=$1    # 入力ファイルパス（例: /aws_settings/config）
env_var_name=$2 # 環境変数名（例: AWS_CONFIG）
dst_path=$3     # 出力ファイルパス（例: $HOME/.aws/config）

# --- ログ用関数 ---
log_info() {
  echo "Info: $*"
}

# --- 連想配列定義 ---
declare -A base_data file_data env_data combined_data

# --- ファイルからセクション毎に読み込んで連想配列に格納 ---
parse_data_file() {
  local path=$1
  local -n arr=$2
  local key=""
  local raw line

  # 末尾改行が無くても最後の行を処理するため `|| [[ -n $raw ]]` を付ける
  while IFS= read -r raw || [[ -n $raw ]]; do
    # 前後空白を削除（CRLF対策で末尾の \r も除去）
    line=$(printf '%s' "$raw" | sed 's/\r$//;s/^[[:space:]]*//;s/[[:space:]]*$//')

    if [[ $line =~ ^\[.*\]$ ]]; then
      key=$line
      arr["$key"]="" # 初期化
    elif [[ -n $key ]]; then
      if [[ -n ${arr[$key]} ]]; then
        arr["$key"]+=$'\n'"$line"
      else
        arr["$key"]="$line"
      fi
    fi
  done < "$path"
}

# --- 環境変数から同様に読み込む ---
parse_data_env() {
  local varname=$1
  local -n arr=$2
  local raw line

  # decode Unicode/バックスラッシュエスケープ
  local env_raw="${!varname:-}"
  if [[ -z $env_raw ]]; then
    return
  fi

  # printf '%b' で \n などを実体改行に展開
  local decoded
  decoded=$(printf '%b' "$env_raw")

  local key=""
  # ここも同様に、末尾改行なしでも最後の行を処理
  while IFS= read -r raw || [[ -n $raw ]]; do
    line=$(printf '%s' "$raw" | sed 's/\r$//;s/^[[:space:]]*//;s/[[:space:]]*$//')

    if [[ $line =~ ^\[.*\]$ ]]; then
      key=$line
      arr["$key"]=""
    elif [[ -n $key ]]; then
      if [[ -n ${arr[$key]} ]]; then
        arr["$key"]+=$'\n'"$line"
      else
        arr["$key"]="$line"
      fi
    fi
  done <<<"$decoded"
}

# --- 連想配列を書き出す（キーをソートして）---
write_data_file() {
  local -n arr=$1
  local out=$2
  mkdir -p "$(dirname "$out")"
  : >"$out" # ファイルをクリア

  # キーをソート
  IFS=$'\n' sorted_keys=($(printf '%s\n' "${!arr[@]}" | sort))
  unset IFS

  for key in "${sorted_keys[@]}"; do
    echo "$key" >>"$out"
    # 値が複数行のときは行ごとに出力
    while IFS= read -r val; do
      echo "$val" >>"$out"
    done <<<"${arr[$key]}"
  done
}

# --- main 処理 ---
# 1) 既存の出力ファイル (dst_path) から読み込み
if [[ -f "$dst_path" && -s "$dst_path" ]]; then
  log_info "既存の出力ファイル '$dst_path' からデータを取得しました"
  parse_data_file "$dst_path" base_data
else
  log_info "既存の出力ファイル '$dst_path' が空です"
fi

# 2) 指定ファイル (file_path) から読み込み
if [[ -f "$file_path" && -s "$file_path" ]]; then
  log_info "ファイル '$file_path' からデータを取得しました"
  parse_data_file "$file_path" file_data
else
  log_info "ファイル '$file_path' が空です"
fi

# 3) 環境変数から読み込み
if [[ -n "${!env_var_name:-}" ]]; then
  log_info "環境変数 '$env_var_name' からデータを取得しました"
  parse_data_env "$env_var_name" env_data
else
  log_info "環境変数 '$env_var_name' が空です"
fi

# 4) 結合（「後から適用された値が優先」のルールでマージ）
# デフォルト(existing_output_is_highest=true): file → env → existing output の順に適用
#   - 最後に適用される existing output が最優先で残る
# 切替(existing_output_is_highest=false / 環境変数が存在): existing output → file → env の順に適用
#   - 最後に適用される env が最優先／existing output は最下位で上書きされうる（優先しない）
# ※ file vs env の優先は常に env が後勝ち（env の方が優先）

existing_output_is_highest=true

# 環境変数が「存在」していれば、既存出力ファイル優先を無効化（値は空でもOK）
if [[ -n "${AWS_PROFILE_DISABLE_EXISTING_OUTPUT_PRIORITY+x}" ]]; then
  existing_output_is_highest=false
  log_info "優先順位: 既存出力ファイルは優先しない（AWS_PROFILE_DISABLE_EXISTING_OUTPUT_PRIORITY が存在）"
else
  log_info "優先順位: 既存出力ファイルを優先（デフォルト。AWS_PROFILE_DISABLE_EXISTING_OUTPUT_PRIORITY は未設定）"
fi

declare -A combined_data

if $existing_output_is_highest; then
  # file
  for k in "${!file_data[@]}"; do
    combined_data["$k"]="${file_data["$k"]}"
  done
  # env（envがfileを上書き）
  for k in "${!env_data[@]}"; do
    combined_data["$k"]="${env_data["$k"]}"
  done
  # 既存出力ファイル（dst_path）由来が最終勝ち
  for k in "${!base_data[@]}"; do
    combined_data["$k"]="${base_data["$k"]}"
  done
else
  # 既存出力ファイル（dst_path）由来は最下位
  for k in "${!base_data[@]}"; do
    combined_data["$k"]="${base_data["$k"]}"
  done
  for k in "${!file_data[@]}"; do
    combined_data["$k"]="${file_data["$k"]}"
  done
  for k in "${!env_data[@]}"; do
    combined_data["$k"]="${env_data["$k"]}"
  done
fi

# 5) 書き出し
write_data_file combined_data "$dst_path"
log_info "結合されたデータを '$dst_path' に出力しました"
