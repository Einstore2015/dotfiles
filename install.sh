#!/usr/bin/env bash

set -euo pipefail
# -e: 遇到任何错误立即停止执行。
# -u: 使用未定义的变量时报错。
# -o pipefail: 只要管道命令中有一个失败，整个管道就视为失败。

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$HOME/dotfiles_backup}"

mkdir -p "$BACKUP_DIR"
mkdir -p "$HOME/.config"

# 创建符号链接的函数
create_symlink() {
    local src="$1"
    local dest="$2"
    local rel_path="$3"
    local backup_path="$BACKUP_DIR/$rel_path"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "Skip (already linked): $dest -> $src"
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Backing up: $dest -> $backup_path"
        mkdir -p "$(dirname "$backup_path")"
        mv "$dest" "$backup_path"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "Linked: $dest -> $src"
}

link_root_dotfiles() {
    local entry name src dest
    while IFS= read -r entry; do
        name="$(basename "$entry")"
        case "$name" in
            .|..|.git|.config|install.sh|.gitignore)
                continue
                ;;
        esac
        src="$DOTFILES_DIR/$name"
        dest="$HOME/$name"
        create_symlink "$src" "$dest" "$name"
    done < <(find "$DOTFILES_DIR" -maxdepth 1 -mindepth 1 -name ".*" | sort)
}

link_config_entries() {
    local config_dir src rel_path dest
    config_dir="$DOTFILES_DIR/.config"

    [ -d "$config_dir" ] || return

    while IFS= read -r src; do
        rel_path="${src#$config_dir/}"
        dest="$HOME/.config/$rel_path"
        create_symlink "$src" "$dest" ".config/$rel_path"
    done < <(find "$config_dir" -mindepth 1 ! -type d | sort)
}

link_root_dotfiles
link_config_entries

echo "Dotfiles symlink setup complete."
