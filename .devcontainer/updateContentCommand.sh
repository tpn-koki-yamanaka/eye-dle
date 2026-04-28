#!/bin/bash
set -euo pipefail

cd /workspace

mise trust -a
mise install

# Create symlinks for all mise-managed tools
TARGET_DIR="/usr/local/bin"

# Function to find tool executable (handles both regular and ubi tools)
find_tool_executable() {
    local tool_name=$1

    # Try mise which first
    local tool_path=$(mise which "$tool_name" 2>/dev/null)
    if [ -n "$tool_path" ] && [ -f "$tool_path" ]; then
        echo "$tool_path"
        return
    fi

    # For ubi tools, search in mise installs directory
    if [[ "$tool_name" == ubi:* ]]; then
        local clean_name=$(echo "$tool_name" | sed 's/ubi://; s/\//-/g')
        local MISE_DATA_DIR="${MISE_DATA_DIR:-$HOME/.local/share/mise}"
        local base_name=$(basename "${tool_name##*/}")
        local found_path=$(find "${MISE_DATA_DIR}/installs/ubi-${clean_name}" -name "$base_name" -type f 2>/dev/null | head -1)
        if [ -n "$found_path" ] && [ -f "$found_path" ]; then
            echo "$found_path"
            return
        fi
    fi

    echo ""
}

# Get list of installed tools from mise
INSTALLED_TOOLS=$(mise list --installed --json | jq -r 'keys[]' | sort -u)

echo "Creating symlinks for mise-managed tools..."

for tool in $INSTALLED_TOOLS; do
    tool_path=$(find_tool_executable "$tool")

    if [ -n "$tool_path" ] && [ -f "$tool_path" ]; then
        tool_basename=$(basename "$tool_path")

        # Remove existing file (symlink or regular file) if it exists
        if [ -e "$TARGET_DIR/$tool_basename" ]; then
            rm "$TARGET_DIR/$tool_basename"
            echo "Removed existing file: $TARGET_DIR/$tool_basename"
        fi

        # Create new symlink
        ln -s "$tool_path" "$TARGET_DIR/$tool_basename"
        echo "Created symlink: $TARGET_DIR/$tool_basename -> $tool_path"
    fi
done

echo "All tool symlinks created successfully"
