#!/usr/bin/env bash
#
# macos/uninstall.sh — undo what setup.sh did
#
#   ./uninstall.sh --dry-run      show what would happen, change nothing
#   ./uninstall.sh                unlink configs, revert tweaks, remove the
#                                 packages setup.sh recorded as newly installed
#   ./uninstall.sh --zap          also wipe app data (browser profiles, caches)
#   ./uninstall.sh --links-only   configs and tweaks only, keep the packages
#   ./uninstall.sh --from-brewfile  no manifest? remove everything in Brewfile
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/macos-setup"

DRY_RUN=0
ZAP=0
LINKS_ONLY=0
FROM_BREWFILE=0

usage() { sed -n '3,11p' "$0" | cut -c3-; exit "${1:-0}"; }

for arg in "$@"; do
    case "$arg" in
        --dry-run)       DRY_RUN=1 ;;
        --zap)           ZAP=1 ;;
        --links-only)    LINKS_ONLY=1 ;;
        --from-brewfile) FROM_BREWFILE=1 ;;
        -h|--help)       usage 0 ;;
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
    local dst bak parent
    while IFS=$'\t' read -r dst bak; do
        [[ -n "$dst" ]] || continue
        if [[ -L "$dst" ]]; then
            run rm -f "$dst"
            printf '  unlinked %s\n' "$dst"
        elif [[ -e "$dst" ]]; then
            warn "$dst is no longer a symlink — leaving it alone"
        fi

        if [[ -n "$bak" && -e "$bak" ]]; then
            run mv "$bak" "$dst"
            printf '  restored %s\n' "$dst"
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

    while read -r p; do
        [[ -n "$p" ]] || continue
        if [[ "$kind" == cask ]]; then
            if (( ZAP )); then
                run brew uninstall --cask --zap "$p"
            else
                run brew uninstall --cask "$p"
            fi
        else
            run brew uninstall --formula "$p"
        fi
    done < "$list"
}

brewfile_pkgs() {
    local key="$1"
    [[ "$key" == cask ]] || key="brew"
    awk -v k="$key" '$1 == k { gsub(/"/, "", $2); print $2 }' "$DOTFILES/Brewfile" \
        | sort -u
}

if (( LINKS_ONLY )); then
    say "keeping packages (--links-only)"
elif (( FROM_BREWFILE )); then
    say "removing every package listed in the Brewfile"
    warn "--from-brewfile removes tools you may have installed yourself —"
    warn "including visual-studio-code, your browsers, and the rest."
    # real files, not process substitution: `-s` on a pipe is always false
    tmp_casks="$(mktemp)";    brewfile_pkgs cask    > "$tmp_casks"
    tmp_formulae="$(mktemp)"; brewfile_pkgs formula > "$tmp_formulae"
    remove_pkgs cask    "$tmp_casks"    "Brewfile casks"
    remove_pkgs formula "$tmp_formulae" "Brewfile formulae"
    rm -f "$tmp_casks" "$tmp_formulae"
elif [[ -s "$STATE_DIR/installed-casks.txt" || -s "$STATE_DIR/installed-formulas.txt" ]]; then
    say "removing packages that setup.sh installed"
    remove_pkgs cask    "$STATE_DIR/installed-casks.txt"    "casks"
    remove_pkgs formula "$STATE_DIR/installed-formulas.txt" "formulae"
    printf '\n  Packages that were already on this Mac were left alone.\n'
    printf '  Version upgrades made by `brew bundle` are not reverted.\n'
else
    say "no install manifest — nothing removed"
    warn "setup.sh only started recording what it installs in a later version,"
    warn "so it cannot tell which packages it added. Options:"
    warn "  ./uninstall.sh --links-only      configs and tweaks only"
    warn "  ./uninstall.sh --from-brewfile   remove all Brewfile packages"
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
