#!/usr/bin/env bash
#
# macos/uninstall.sh — undo what setup.sh did
#
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/macos-setup"

DRY_RUN=0
ZAP=0
LINKS_ONLY=0

usage() {
    cat <<'EOF'
macos/uninstall.sh — undo what setup.sh did

  ./uninstall.sh --dry-run      show what would happen, change nothing
  ./uninstall.sh                unlink configs, revert tweaks, remove the
                                packages setup.sh recorded as newly installed
  ./uninstall.sh --zap          also wipe app data (browser profiles, caches)
  ./uninstall.sh --links-only   configs and tweaks only, keep the packages
EOF
    exit "${1:-0}"
}

for arg in "$@"; do
    case "$arg" in
        --dry-run)    DRY_RUN=1 ;;
        --zap)        ZAP=1 ;;
        --links-only) LINKS_ONLY=1 ;;
        -h|--help)    usage 0 ;;
        *) printf 'unknown flag: %s\n' "$arg" >&2; usage 2 ;;
    esac
done

say()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m warn:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# Tolerant runner: an uninstall must keep going past a missing defaults key,
# a symlink someone already deleted by hand, or a package already gone.
run() {
    if (( DRY_RUN )); then
        printf '  [dry-run] %s\n' "$*"
    else
        "$@" || warn "failed, continuing: $*"
    fi
}

[[ "$(uname -s)" == Darwin ]] || die "this script targets macOS"

# --- 1. config symlinks -------------------------------------------------
remove_links() {
    local dst bak parent removed
    while IFS=$'\t' read -r dst bak; do
        [[ -n "$dst" ]] || continue

        removed=0
        if [[ -L "$dst" ]]; then
            run rm -f "$dst"
            removed=1
            printf '  unlinked %s\n' "$dst"
        elif [[ -e "$dst" ]]; then
            warn "$dst is no longer a symlink — leaving it alone"
        fi

        # Only put the backup back if we just took our symlink away. If
        # something real is living at $dst, it is not ours to overwrite.
        if (( removed )) && [[ -n "$bak" && -e "$bak" ]]; then
            run mv "$bak" "$dst"
            printf '  restored %s\n' "$dst"
        elif [[ -n "$bak" && -e "$bak" ]]; then
            warn "left $bak in place — $dst is not ours to replace"
        fi

        parent="$(dirname "$dst")"
        if [[ -d "$parent" && -z "$(ls -A "$parent" 2>/dev/null)" ]]; then
            run rmdir "$parent"
            printf '  removed empty %s\n' "$parent"
        fi
    done < "$STATE_DIR/links.tsv"
}

if [[ -f "$STATE_DIR/links.tsv" ]]; then
    say "removing config symlinks"
    remove_links
else
    warn "no links manifest at $STATE_DIR/links.tsv — nothing to unlink"
fi

# --- 2. macOS defaults --------------------------------------------------
if [[ -f "$STATE_DIR/tweaks-applied" ]]; then
    say "reverting macOS defaults"
    # `defaults delete` restores the system default rather than writing false
    run defaults delete com.apple.dock expose-group-apps
    run defaults delete com.apple.spaces spans-displays
    if (( ! DRY_RUN )); then
        killall Dock 2>/dev/null || true
        killall SystemUIServer 2>/dev/null || true
    fi
    warn "log out and back in for the Spaces change to take effect"
else
    say "macOS defaults were never tweaked — nothing to revert"
fi

# --- 3. quit the WM before touching its app -----------------------------
if [[ -d /Applications/AeroSpace.app ]]; then
    say "quitting AeroSpace"
    run osascript -e 'quit app "AeroSpace"'
fi

# --- 4. packages --------------------------------------------------------
remove_pkgs() {
    local kind="$1" list="$2" label="$3" p

    if [[ ! -s "$list" ]]; then
        printf '  nothing recorded for %s\n' "$label"
        return
    fi
    printf '  %s:\n' "$label"

    # </dev/null so a child that reads stdin cannot swallow the remaining
    # package names
    while read -r p; do
        [[ -n "$p" ]] || continue
        if [[ "$kind" == cask ]]; then
            if (( ZAP )); then
                run brew uninstall --cask --zap "$p" < /dev/null
            else
                run brew uninstall --cask "$p" < /dev/null
            fi
        else
            run brew uninstall --formula "$p" < /dev/null
        fi
    done < "$list"
}

if (( LINKS_ONLY )); then
    say "keeping packages (--links-only)"
    if [[ -d /Applications/AeroSpace.app ]]; then
        warn "AeroSpace is still installed and still registered to start at"
        warn "login. Next login it comes back on its built-in default config."
        warn "Remove it under System Settings -> General -> Login Items."
    fi
elif [[ -e "$STATE_DIR/installed-casks.txt" || -e "$STATE_DIR/installed-formulas.txt" ]]; then
    say "removing packages that setup.sh installed"
    remove_pkgs cask    "$STATE_DIR/installed-casks.txt"    "casks"
    remove_pkgs formula "$STATE_DIR/installed-formulas.txt" "formulae"
    printf '\n  Packages that were already on this Mac were left alone.\n'
    printf '  Version upgrades made by `brew bundle` are not reverted.\n'
else
    say "no install manifest — no packages removed"
    warn "setup.sh keeps its install record in $STATE_DIR and there is none,"
    warn "so this script cannot tell which packages it added. Either"
    warn "brew bundle never ran, or the record was deleted by hand."
    warn "Packages were left alone; remove them yourself with brew uninstall."
fi

# --- 5. drop the state --------------------------------------------------
if (( ! DRY_RUN )) && [[ -d "$STATE_DIR" ]]; then
    say "clearing $STATE_DIR"
    rm -rf "$STATE_DIR"
fi

cat <<'EOF'

Done. Left in place on purpose:

  - the dotfiles repo itself, and the ~/.config files it holds
  - Homebrew and anything it installed before setup.sh ran
  - app data, unless you passed --zap

To clean up dependencies the removed packages pulled in:

  brew autoremove && brew cleanup

EOF
