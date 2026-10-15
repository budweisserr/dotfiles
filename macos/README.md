# macos — Awesome WM habits on a MacBook

Ports the keyboard model from `../awesome` to macOS. Same terminal, same
launcher concept, same workspaces, same muscle memory where macOS allows it.

```
./setup.sh              # brew bundle + link configs
./setup.sh --no-bundle  # link configs only
./setup.sh --tweaks     # also apply the opinionated macOS defaults
```

Then work through the four manual steps the script prints at the end. The first
one — Accessibility — is what makes or breaks the whole thing.

## Why AeroSpace and not yabai

On a supervised corporate Mac you cannot disable SIP, and yabai's scripting
additions need that. Karabiner-Elements needs a DriverKit system extension,
which the `com.apple.system-extension-policy` profile on a managed Mac almost
certainly will not allow. AeroSpace needs only the public Accessibility API, so
it is the one tiling WM that actually works here. It also means no second
daemon: hotkeys and window management both live in `aerospace.toml`.

## Modifier: `Super` becomes `alt`

Linux binds the WM to `Super`. On macOS `cmd` is the app-shortcut modifier
(cmd-q, cmd-w, cmd-tab, cmd-1), so binding a WM to it swallows app shortcuts.
AeroSpace's own convention is `alt` (Option), and this config follows it.
cmd-tab still switches apps; only alt-tab is taken.

Side effect worth knowing: AeroSpace captures alt+letter globally, so the
Option-key special characters on those letters stop working — alt+m gives no
`µ`, alt+w no `∑`, alt+p no `π`, alt+s no `ß`. Use the Character Viewer if you
need them, or rebind.

## Keymap

| awesome (`Super`) | here (`alt`) | action |
| --- | --- | --- |
| `Return` | `alt-enter` | new kitty window |
| `r` | `alt-r` / `cmd-space` | launcher (Raycast) |
| `Print` | `alt-p` | screenshot (Flameshot) |
| — | `alt-h/j/k/l` | focus window |
| `Tab` | `alt-tab` | previous window |
| `Escape` | `alt-escape` | previous workspace |
| `Shift-j/k` | `alt-shift-h/j/k/l` | move window |
| `h` / `l` | `alt-minus` / `alt-equal` | resize |
| — | `alt-shift-equal` | balance sizes |
| `space` | `alt-slash` / `alt-comma` / `alt-space` | cycle layout |
| `Ctrl-space` | `alt-shift-f` | toggle floating |
| `f` | `alt-f` | fullscreen |
| `Up` (maximize) | `alt-ctrl-f` | macOS native fullscreen |
| `Down`, `n` | `alt-m` | minimize |
| `Alt-F4` | `alt-w` | close |
| `Ctrl-j` | `alt-ctrl-h` / `alt-ctrl-l` | focus monitor |
| `q`, `w`, `o` | `alt-shift-tab` | window to next monitor |
| — | `alt-ctrl-tab` | whole workspace to next monitor |
| `1..9` | `alt-1..9` | workspace |
| `Shift-1..9` | `alt-shift-1..9` | move window to workspace |
| `Ctrl-r` | `alt-shift-semicolon`, then `esc` | reload config |
| — | `alt-s` | resize mode |
| — | `alt-shift-semicolon` | service mode (flatten, float, join-with) |

Modes: `esc` returns to main. If you get stuck in one, that is the way out. All
current bindings: `aerospace config --get mode.main.binding --keys`.

## What does not port

- **Multiple tags visible at once** (`Super-Ctrl-1..9`, `viewtoggle`). AeroSpace
  has no equivalent; one workspace per monitor is the model.
- **Urgent-client jump** (`Super-u`) — no urgency concept.
- **Restore minimized** (`Super-Ctrl-n`) — use the Dock or cmd-tab.
- **maximize_vertical / maximize_horizontal** (`Super-Ctrl-m`, `Super-Shift-m`).
- **`center`, `ontop`, `neofetch size`, `toggle titlebar`** — the awesome
  versions operate on floating windows; close enough equivalents do not exist.
- **Hotkeys popup** (`Super-s`) — replaced by the resize mode.
- **Quit the WM** (`Super-Shift-q`) — quit from the AeroSpace tray icon.
- **Lua prompt** (`Super-x`) — `aerospace eval` on the CLI.
- **redshift night shift** (`Super-BrightnessDown`) — macOS Night Shift, in
  System Settings → Displays.
- **Volume / media / brightness keys** — native on macOS, no binding needed.
- **`us,ua` layout switch on alt-shift** — set both input sources, macOS uses
  ctrl-space.
- **picom, autorandr, xmbwave** — macOS composites and handles displays itself,
  and the live wallpaper has no equivalent (your org pins the wallpaper anyway).

## Caveats on this MDM-managed Mac

- **Accessibility permission is the gate.** AeroSpace needs it. The `com.apple.TCC.configuration-profile-policy` payloads on this machine grant TCC rights
  per-app, so the profile may refuse it. If the toggle in Privacy & Security is
  greyed out, that is the cause — IT can add AeroSpace to the allowlist.
- **Login items.** `com.apple.servicemanagement` can block registration. If
  Aerospace does not come back after a reboot, add it under System Settings →
  General → Login Items.
- **Install restrictions.** If `com.apple.applicationaccess` limits app
  installation, cask installs fail and `brew bundle` prints a failure summary.
  Formulas are unaffected.
- **Containers.** Docker Desktop needs a paid subscription above 250 employees,
  so the Brewfile uses `colima`. OrbStack is there as a commented option — check
  its licensing before using it for work.
- **No Karabiner, no yabai, no sketchybar tweaks that need SIP** — see above.

## Files

- `aerospace.toml` → linked to `~/.config/aerospace/aerospace.toml`
- `Brewfile` — every package name verified against the Homebrew API
- `setup.sh` — idempotent; existing configs get moved to `.bak`, never clobbered

The kitty config is not tracked in this repo. Add `kitty/kitty.conf` at the repo
root and `setup.sh` will link it; until then the script leaves whatever is
already in `~/.config/kitty` alone.
