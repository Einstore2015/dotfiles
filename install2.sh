#!/usr/bin/env bash

set -euo pipefail
# -e: 遇到任何错误立即停止执行。
# -u: 使用未定义的变量时报错。
# -o pipefail: 只要管道命令中有一个失败，整个管道就视为失败。

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$HOME/dotfiles_backup}"
DRY_RUN=false

usage() {
    cat <<'USAGE'
Usage: install2.sh [--dry-run|-n]

Options:
  -n, --dry-run   Show planned operations without changing files
  -h, --help      Show this help message
USAGE
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

run_cmd() {
    if $DRY_RUN; then
        printf '[DRY RUN] '
        printf '%q ' "$@"
        printf '\n'
    else
        "$@"
    fi
}

prepare_dirs() {
    run_cmd mkdir -p "$BACKUP_DIR"
    run_cmd mkdir -p "$HOME/.config"
}

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
        if $DRY_RUN; then
            echo "Would back up: $dest -> $backup_path"
        else
            echo "Backing up: $dest -> $backup_path"
        fi
        run_cmd mkdir -p "$(dirname "$backup_path")"
        run_cmd mv "$dest" "$backup_path"
    fi

    run_cmd mkdir -p "$(dirname "$dest")"
    run_cmd ln -s "$src" "$dest"
    if $DRY_RUN; then
        echo "Would link: $dest -> $src"
    else
        echo "Linked: $dest -> $src"
    fi
}

link_root_dotfiles() {
    local entry name src dest
    while IFS= read -r entry; do
        name="$(basename "$entry")"
        case "$name" in
            .|..|.git|.config|install.sh|install2.sh|.gitignore)
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

prepare_dirs
link_root_dotfiles
link_config_entries

if $DRY_RUN; then
    echo "Dry run complete. No files were changed."
else
    echo "Dotfiles symlink setup complete."
fi
