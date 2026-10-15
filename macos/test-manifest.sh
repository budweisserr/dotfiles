#!/usr/bin/env bash
#
# macos/test-manifest.sh — checks the bookkeeping that decides which packages
# macos/uninstall.sh is allowed to remove.
#
#   ./test-manifest.sh
#
# No framework. Five cases, exit 1 if any fail.
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

STATE_DIR="$TMP/state"
mkdir -p "$STATE_DIR"

source "$DOTFILES/lib.sh"

# Replace the real `brew list` with a list the test can set. This has to come
# after the source, or lib.sh would redefine it.
CURRENT=""
snapshot_pkgs() {
    printf '%s\n' "$CURRENT" | tr ' ' '\n' | sed '/^$/d' | sort
}

fails=0

norm() { tr '\n' ' ' | sed 's/ *$//'; }

manifest() {  # manifest <formula|cask>
    sort "$STATE_DIR/installed-$1s.txt" 2>/dev/null | norm
}

check() {  # check <what> <expected> <actual>
    if [[ "$2" == "$3" ]]; then
        printf 'ok   %s\n' "$1"
    else
        printf 'FAIL %s\n     expected: [%s]\n     actual:   [%s]\n' "$1" "$2" "$3"
        fails=$(( fails + 1 ))
    fi
}

# 1. fresh machine: everything currently installed is new
: > "$STATE_DIR/before-formulas.txt"
CURRENT="git node go"
record_new_pkgs formula
check "fresh machine records everything" "git go node" "$(manifest formula)"

# 2. a second run with nothing new must not erase the record
record_new_pkgs formula
check "repeat run keeps the record" "git go node" "$(manifest formula)"

# 3. a package that was already there is never claimed
printf 'node\n' > "$STATE_DIR/before-formulas.txt"
rm -f "$STATE_DIR/installed-formulas.txt"
record_new_pkgs formula
check "pre-existing packages are not claimed" "git go" "$(manifest formula)"

# 4. a genuinely new package joins the existing record
CURRENT="git node go ripgrep"
record_new_pkgs formula
check "a new package joins the record" "git go ripgrep" "$(manifest formula)"

# 5. casks keep their own manifest, separate from formulae
: > "$STATE_DIR/before-casks.txt"
CURRENT="kitty zen"
record_new_pkgs cask
check "casks get their own manifest" "kitty zen" "$(manifest cask)"

if (( fails )); then
    printf '\n%s check(s) failed\n' "$fails" >&2
    exit 1
fi
printf '\nall checks passed\n'
