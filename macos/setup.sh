#!/usr/bin/env bash
#
# macos/setup.sh — bootstrap a keyboard-driven macOS box
#
#   ./setup.sh              install Homebrew packages, then link configs
#   ./setup.sh --no-bundle  skip `brew bundle`, only link configs
#   ./setup.sh --tweaks     also apply the opinionated macOS defaults
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$DOTFILES")"

WITH_BUNDLE=1
WITH_TWEAKS=0

usage() {
    sed -n '3,7p' "$0" | cut -c3-
    exit "${1:-0}"
}

for arg in "$@"; do
    case "$arg" in
        --no-bundle) WITH_BUNDLE=0 ;;
        --tweaks)    WITH_TWEAKS=1 ;;
        -h|--help)   usage 0 ;;
        *)           printf 'unknown flag: %s\n' "$arg" >&2; usage 2 ;;
    esac
done

say()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m warn:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

[[ "$(uname -s)" == Darwin ]] || die "this script targets macOS"

# --- Xcode command line tools -------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
    say "installing Xcode Command Line Tools"
    xcode-select --install || true
    die "re-run this script once the Command Line Tools finish installing"
fi

# --- Homebrew -----------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
    say "installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

for prefix in /opt/homebrew /usr/local; do
    if [[ -x "$prefix/bin/brew" ]]; then
        eval "$("$prefix/bin/brew" shellenv)"
        break
    fi
done
command -v brew >/dev/null 2>&1 || die "Homebrew installed but not on PATH"

# --- packages -----------------------------------------------------------
if (( WITH_BUNDLE )); then
    say "installing packages from Brewfile"
    brew bundle --file "$DOTFILES/Brewfile" \
        || warn "brew bundle reported failures — see the summary above"
fi

# --- config linking -----------------------------------------------------
link() {
    local src="$1" dst="$2"
    if [[ ! -e "$src" ]]; then
        warn "$src is missing, skipping"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        warn "$dst exists — moving it to $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sfn "$src" "$dst"
    printf '  %s -> %s\n' "$dst" "$src"
}

say "linking configs"
if [[ -e "$HOME/.aerospace.toml" ]]; then
    warn "~/.aerospace.toml exists; AeroSpace errors out when both that and"
    warn "~/.config/aerospace/aerospace.toml are present. Delete one."
fi
link "$DOTFILES/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"

# the kitty config lives at the repo root and is shared with the Linux box
if [[ -f "$REPO/kitty/kitty.conf" && ! -e "$HOME/.config/kitty/kitty.conf" ]]; then
    link "$REPO/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
fi

# --- opinionated macOS defaults -----------------------------------------
if (( WITH_TWEAKS )); then
    say "applying macOS defaults"
    # mission control groups windows better when AeroSpace hides some off-screen
    defaults write com.apple.dock expose-group-apps -bool true
    # 'Displays have separate Spaces' fights the Accessibility APIs AeroSpace uses
    defaults write com.apple.spaces spans-displays -bool true
    killall Dock 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
    warn "log out and back in for the Spaces change to take effect"
fi

# --- bring it up --------------------------------------------------------
say "starting AeroSpace"
open -a AeroSpace 2>/dev/null || warn "launch AeroSpace from /Applications"

cat <<'EOF'

By hand, once:

  1. System Settings -> Privacy & Security -> Accessibility
     Enable AeroSpace and Raycast. Nothing works without this step.

  2. System Settings -> Keyboard -> Keyboard Shortcuts -> Spotlight
     Uncheck "Show Spotlight search" to free cmd-space, then set Raycast's
     hotkey to cmd-space.

  3. System Settings -> Keyboard -> Input Sources
     Add "Ukrainian" next to "U.S." — the awesome config switched layout with
     alt-shift, macOS uses ctrl-space by default.

  4. kitty picks up ~/.config/kitty/kitty.conf on its own.
     kitty's config is not tracked in this repo yet — add kitty/ if you want
     it shared with the Linux box.

macos/README.md covers what does not port across and what this particular
MDM-managed Mac will refuse to do.

EOF
