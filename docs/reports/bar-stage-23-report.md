# Bar Stage 23: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-23-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

The bar and the default size are untouched: `o.float_default = { width = 1100, height = 619 }`, centred at (314, 273), `~/.config/hypr/float-default.lua` line 5.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-155606-bar-stage-23`** (mode 700, 208 files), taken before any file was edited. The investigation before it only read state and opened test windows. It covers every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, helpers and the systemd unit, plus (local only) the saved per-workspace layouts. Checksums: live before = backup = live after |
| Reload | `hyprctl reload` only (`configerrors` empty) |
| Debug / temporary code | None. The event captures ran in scratch only. Six test windows were closed: three Helium windows I opened, one Floorp, one NYT, one calculator. Your own windows stayed open. Saved layouts unchanged (1, 2, 3, 4, 8). Focus returned to Orca. **Your Helium preferences were read, not changed** |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `config/hypr/float-default.lua`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

**The screenshot** (`image-5cd65482.png`) was not on this machine; the brief links only the markdown. The live state matched it.

## 1. Investigation, in Hyprland's own terms

**The wrong window, as found** (`hyprctl clients -j`):

| Field | Helium on workspace 3 (wrong) | Ghostty on workspace 3 (right) |
|---|---|---|
| address | `0xaaab984c4bb0` | `0xaaab983cce50` |
| class / initialClass | `helium` / `helium` | `com.mitchellh.ghostty` |
| title | `New Tab - Helium` | `~` |
| workspace | 3 | 3 |
| floating | true | true |
| size / position | **1100 × 726 at (338, 244)** | 1100 × 619 at (314, 273) |
| fullscreen | 0 | 0 |
| tags | `chromium-based-browser*`, `float-default*`, `omaland-opaque*`, `omarchy-floating-workspace`, `omarchy-mode-floated`, `omarchy-mode-opened*` | `float-default*`, `omarchy-floating-workspace`, `omarchy-mode-floated`, `omarchy-mode-opened*`, `terminal*`, `transparent-window*` |

- **A newer window:** not the Helium that Stage 22 reset. It was opened after Stage 22 (its address was reused from the closed Zen).
- **Ruled out:**
  - **not `self-floated`;**
  - **not in `o.floating_apps`** (checked: no browser is);
  - **no unusual route:** it was opened directly on workspace 3.
- **The placement is the stock floating mode's:** 1100 × 726 is its size, and (338, 244) is its centre plus one +24 px cascade step.

**What differs, from the event stream** (Hyprland socket2, recorded while opening fresh windows on workspace 3):

| App | Events at open | Result |
|---|---|---|
| **Helium** | `openwindow>>…,3,helium,…` then, **2 ms later**, `changefloatingmode>>…,1` | maps **tiled**, then floated by Omarchy's mode → **1100 × 726 at (362, 268)** (the next cascade step) |
| **Floorp** | `openwindow>>…,3,one.ablaze.floorp,…` only | maps **already floating** (the float rules applied) → 1100 × 619 at (314, 273) |

- **Cause:** Helium **maps tiled**, so neither float rule takes effect as it maps; neither the default rule nor the floating mode's open rule.
- **Then:**
  1. Omarchy's floating mode sees a tiled window on a floating workspace in its own `window.open` handler.
  2. It floats it (that `changefloatingmode … 1`) and places it the stock way.
  3. Its handler is registered after mine (the saved layouts load after this file), so it **ran after my hook**, and its placement stayed.
  4. On a tiled workspace, the same Helium window would simply have stayed tiled.
- **Why only Helium:** its preferences (`~/.config/net.imput.helium/Default/Preferences`) store the last window as **`browser.window_placement.maximized: true`**, so every new Helium window **asks to open maximized**.
  - **The maximize is already suppressed:** Omarchy's stock `windows.lua` has `suppress_event = "maximize"` for every window.
  - **But the window still maps tiled** instead of taking the float rules.
  - **Floorp and the NYT Chromium app** don't ask to maximize, so the rules float them as they map.
- **Certainty:** the maximize link is the one difference I found. I did not change your Helium preferences to prove it. The fix below doesn't depend on it.

## 2. Fix: the open path no longer trusts the rules alone

**Where:** `float-default.lua`, lines 87–118.

1. **Classify at once.** As before, a window that opened floating on its own account (dialog, popup, modal, own float rule) is tagged `self-floated`.
2. **Finish shortly after (30 ms),** once Omarchy's floating mode has run. A normal app window on a regular workspace is **floated if it is still tiled**, and then **set to the default**, whatever the rules did.
   - **Covered:** Helium and any other app that maps tiled for any reason, on floating-mode and tiled workspaces alike.
   - **Replaces** the Stage 19 open hook, which only placed windows carrying the floating mode's open-rule tag.

**Unchanged:**
- the switch reset (Stages 21–22);
- the moved-in and leaving-fullscreen hooks (Stage 22);
- dialogs, modals and own-float apps keeping their size;
- fullscreen untouched;
- special workspaces (scratchpad, the agent console) untouched, now explicit (workspace id < 1 is skipped);
- no per-app exceptions anywhere.

## Verified live (`hyprctl clients`)

| Test | Result |
|---|---|
| **Fresh Helium window on workspace 3** (floating mode) | **1100 × 619 at (314, 273)** (before the fix: 1100 × 726 at (362, 268)) |
| **Fresh Helium window on workspace 6** (plain tiled workspace) | **floating, 1100 × 619 at (314, 273)** |
| **Your Helium "New Tab"** (the one in the screenshot), workspace 3 → dwindle → floating | **1100 × 619 at (314, 273)** |
| An older Helium (opened before the fix at 1100 × 726), the same switch | **1100 × 619 at (314, 273)** |
| **Floorp** (new window, workspace 3) | **1100 × 619 at (314, 273)** |
| **NYT Chromium web app** (`chrome-www.nytimes.com__-Default`, new window, workspace 3) | **1100 × 619 at (314, 273)** |
| **Ghostty**, workspace 3 | **1100 × 619 at (314, 273)** |
| Calculator (own stock float size) | **kept 400 × 568 at (664, 299)**, `self-floated` |
| **Super+T** on Helium after moving it to (344, 293), tiled then floating | **back at (344, 293)**: no conflict |
| Your other windows (the workspace 2 Helium, Orca and Muse on workspace 1) | untouched |

- **Zen** is no longer open (it was closed before this stage), so it could not be re-measured. Zen is Firefox-based like Floorp, which passes.
- **Two or more windows** after a switch to floating: all at (314, 273), stacked exactly. This is unchanged and out of scope.

## Still open

- **Your check:** open Helium from the launcher, on a floating and on a tiled workspace.
- **Optional:** if you'd rather Helium stopped asking to open maximized, its "maximized" memory clears once a Helium window is closed while not maximized. The fix doesn't need it.
- **Still pending:** cascade vs. stacked, the broken `notify-send`, and #12.
