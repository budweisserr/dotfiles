# macos — Awesome WM habits on a MacBook

Ports the keyboard model from `../awesome` to macOS. Same terminal, same
launcher concept, same workspaces, same muscle memory where macOS allows it.

```
./setup.sh              # brew bundle + link configs
./setup.sh --no-bundle  # link configs only
./setup.sh --tweaks     # also apply the opinionated macOS defaults
./uninstall.sh --dry-run  # print the rollback plan, change nothing
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

The same capture means alt+letters never reach the terminal. kitty's
`macos_option_as_alt no` is moot here: alt+b and alt+f will not arrive, so
readline word movement needs ctrl+arrow or shell-side bindings.

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
- **No Karabiner, no yabai, no sketchybar tweaks that need SIP** — see above.

## Rollback

`setup.sh` records what it does under
`${XDG_STATE_HOME:-~/.local/state}/macos-setup/`:

- `before-formulas.txt` / `before-casks.txt` — what was installed beforehand
- `installed-formulas.txt` / `installed-casks.txt` — the difference, i.e. what
  `setup.sh` itself added
- `links.tsv` — every symlink it made, plus any `.bak` it moved aside
- `tweaks-applied` — marker that the `--tweaks` defaults were written

`uninstall.sh` reads that, so packages you already had are never touched. If the
record is missing it removes nothing from Homebrew and says so, rather than
guessing.

```
./uninstall.sh --dry-run      # print the plan, change nothing
./uninstall.sh                # unlink, revert tweaks, remove its own packages
./uninstall.sh --zap          # also wipe app data (browser profiles, caches)
./uninstall.sh --links-only   # configs and tweaks only
```

Caveats worth knowing. `--links-only` leaves AeroSpace installed and registered
to start at login, so it comes back on the next start with its built-in default
config — remove it under System Settings → General → Login Items, or run
uninstall without the flag. Plain `brew bundle` does not upgrade existing
packages, so there is nothing to downgrade; a formula you upgraded by hand is
left as it is. Homebrew itself stays. AeroSpace is quit before its app is
removed. `--zap` is opt-in, because for a browser it means your profile.

The manifest logic in `lib.sh` decides what a destructive script is allowed to
remove, so it has a test:

```
./test-manifest.sh
```

## kitty

`kitty/kitty.conf` is shared between the Linux box and the Mac — stock kitty
config plus a Horizon palette, opacity 0.8, Fira Mono at size 10. It carries
`macos_*` and `linux_display_server` lines; kitty ignores whichever ones do not
apply to the platform it is running on.

`setup.sh` links it over `~/.config/kitty/kitty.conf`, moving any file already
there to `kitty.conf.bak`. That matters because kitty writes its own
`kitty.conf` the first time you open it — so on a Mac where you launched kitty
before running setup, your generated one ends up in the `.bak` and the shared
config is what kitty reads. Rollback puts the `.bak` back.

Two font notes, since the config references fonts Homebrew does not all supply:

- `font_family Fira Mono` — the Brewfile installs `font-fira-mono` (exact
  family) plus `font-fira-mono-nerd-font` (icons for btop and powerline
  prompts). For one font everywhere, change the line to `FiraMono Nerd Font`.
- `symbol_map U+2800-U+28FF Symbola` — Homebrew has no Symbola cask. kitty logs
  a warning and falls back. If braille cells (btop, ncdu graphs) render as
  boxes, install Symbola by hand or drop that line.

## Files

- `aerospace.toml` → linked to `~/.config/aerospace/aerospace.toml`
- `Brewfile` — six entries: the three apps `aerospace.toml` launches, plus the
  two fonts `kitty.conf` asks for. Not a port of the Arch package list
- `setup.sh` — idempotent; existing configs get moved to `.bak`, never clobbered
- `uninstall.sh` — reverses the above from the recorded manifest
- `lib.sh` — the install record: snapshot, diff, union across runs
- `test-manifest.sh` — five checks over `lib.sh`, no framework
- `../kitty/kitty.conf` → linked to `~/.config/kitty/kitty.conf`
