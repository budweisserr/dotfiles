# macos/lib.sh — bookkeeping shared by setup.sh and test-manifest.sh.
#
# Sourced, never executed. Requires bash (process substitution, `local`).
#
# The point of this file is that the decision "which packages did setup.sh
# add?" is the decision uninstall.sh acts on destructively, so it lives in
# one place and the test can call the real thing rather than a copy.

STATE_DIR="${STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/macos-setup}"

# Installed packages of one kind, sorted, so `comm` can diff two snapshots.
# $1 = formula | cask
snapshot_pkgs() {
    brew list --"$1" 2>/dev/null | sort
}

# Record packages that appeared since the matching snapshot was taken.
# Unioned with any earlier record, so a second run of setup.sh does not
# erase what the first one installed.
# $1 = formula | cask
record_new_pkgs() {
    local kind="$1"
    local before="$STATE_DIR/before-${kind}s.txt"
    local manifest="$STATE_DIR/installed-${kind}s.txt"
    local tmp
    tmp="$(mktemp)"
    {
        cat "$manifest" 2>/dev/null || true
        comm -13 "$before" <(snapshot_pkgs "$kind")
    } | sort -u > "$tmp"
    mv "$tmp" "$manifest"
}
