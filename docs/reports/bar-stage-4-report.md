# Bar Stage 4: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-4-brief.md`. The brief was downloaded from the given URL into `docs/` first and is committed with this report. All six items are built and live. The Stage 3 locks were respected: island height 38, radius 9, bar height 44 and island text 16 px are untouched.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| Backup before editing | `~/.local/state/omarchy-launcher-backups/20261125-105559-bar-stage-4` (mode 700, 65 files, checksums): every `jimmy.*` plugin, all of `~/.config/hypr`, `shell.json`, `shell.toml`, the menu extension, `weather.json`, both helper scripts, the backlight unit. `shell.json.bak.stage4-*` was also taken before the notifications clone switched plugins |
| Reload | `omarchy restart shell` only, each run on its own; never `refresh`, never combined with a summon |
| Debug logs | none (`console.log` = 0 across every touched plugin). Diagnostics live in the permanent `omarchy-shell jimmy.bar status` (now with `adopted` and `lastAdopt`) |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`**; backlight `mode: auto`; the bar's stay-awake light went off with it |
| Snapshot | 193 live files resynced; checksums identical before and after; snapshot equals live; no runtime state in git |

## 1. One weight: SF Compact Display Medium

- **No bold left anywhere in our surfaces.** Removed from the active workspace number, the app name, the battery % and the toast readout (`font.bold` → none, or `Font.Medium`). The notification cards' bold summary, DemiBold avatar letter and bold button hints are now Medium too.
- **The `[ui] font` token now also drives the launcher, the apps window and reminders** (plus the notification cards). In the launcher, the token now wins over the font that a menu payload passes on each open.
- **Medium, never synthetic bold.** Only the Medium face is installed. Normal-weight text resolves to that same face, and nothing requests Bold any more. The launcher's own weight tokens were already 500 (Medium).
- **Icons** stay on the Nerd Font; **emoji** fall back to the colour emoji font.
- Verified on screen: islands, toast, notification, clipboard picker, launcher and reminders.
- **Not covered:** the stock panels' own content (for example the power panel's "Battery" heading and its large "79%") keeps the stock fonts and weights. That content is stock code inside the hosted panels and is not in §1's list. Flagged.

## 2. Agents: dot removed, the capsules are the state

- **The red dot is gone.**
- **One slim capsule per model**, in fixed order: Claude Personal, Claude Teams, OpenCode, Grok.
  - **Fill** = the highest limit used, rising from the bottom.
  - **Colour** = state: red when over its limit (≥ 100 %), accent when near it (≥ `agents.near-limit` 0.85), calm otherwise.
  - **A dim empty outline** = no data. Same language as the battery.
- **Live now:**
  - **Claude Personal:** half full, its session limit at about 50 %.
  - **Claude Teams:** no data.
  - **OpenCode:** full and red, its monthly limit at 100 %.
  - **Grok:** no data, since its record has no limits.
- **Expansion:** clicking opens the agents panel (stock, hosted and adopted), which has the per-model detail.
- **Running:** the robot glyph is at full opacity while an Omarchy agent window is open.
- **Not available, so not filled in:**
  - **Waiting state:** needs hooks, not built (#12).
  - **Teams usage:** there is one `claude.json` record, and it is for the active account only. `accounts/claude.json` says which account is active (`main` now), so the record lands on the right capsule and the other shows no data (#13).
- **Hook contract:** added optional `agent.account` (`main` / `teams`, tagged by the hook from the config dir it fires in) to `docs/contracts/agent-hook-payload.schema.json` and `.md`. It is additive, so `v` stays 1. **Safe because nothing implements the contract yet.**

## 3. Battery charging: the outline (shipped)

- The edge pulse is removed.
- **Shipped:** a 2 px outline around the pill in the system accent, pulsing in opacity from 0.25 to 1 over one 1.8 s loop (`battery.pulse-ms`). The pill and the % inside stay calm.
- **Fallback (accent number) not used:** the outline reads. Brightest outline pixel sampled six times over a loop: (205,122,59), neutral, neutral, (191,114,56), **(244,144,69)**, (158,96,48). It visibly brightens and dims in the Afterburn accent.

## 4. Toasts: one system, attached to the right island

**Audit of every toast source on the machine:**

| Source | Who sends it | Island | Now |
|---|---|---|---|
| OSD: volume, display brightness, keyboard backlight, media | the shell's audio and media services; `omarchy-brightness-*` (2 scripts call `omarchy-osd`) | right (controls live there) | `jimmy.osd` (Stage 3 clone) |
| Notifications: apps and `notify-send` | any app over D-Bus; 4 Omarchy scripts use `notify-send` | none: **orphan → right** | **`jimmy.notifications`** (new clone) |
| Compositor notices (`hyprctl notify`) | nothing on this machine uses it | — | — |
| Lock Explorer "sting" | third-party lock-screen effect | not a desktop toast | unchanged |

**What changed:**
- **The OSD:** radius 9 instead of 16, island padding (10), the island's thin outline and glass. **Attached:** its top edge is the island's bottom edge (`toast.gap` 0).
- **The notification deck** (`omarchy plugin clone omarchy.notifications` → `jimmy.notifications`):
  - **Position:** was hung from the screen's **right edge**; now **centred under the right island**, attached to it.
  - **Cards:** island glass, thin outline and radius 9, Medium text.
  - **Motion:** the deck grows out of the island with the shared `CardMotion` when it appears. Stacking inside the deck keeps the stock choreography.
- **Blur:** `omarchy-notifications` was added to the glass blur rule.

**Orphan test:**
- A D-Bus notification (the same path an app uses) landed centred under the right island, attached, in the island style.
- **`notify-send` itself is broken on this machine:** `symbol lookup error: undefined symbol: notify_notification_get_activation_app_launch_context` (libnotify 0.8.9-1). That is a system library mismatch, not the bar, but it means the Omarchy scripts that call `notify-send` currently notify nothing. Flagged.

## 5. Hover pop-out and a stay-awake you can touch

- **Pop-out:** a new shared **`jimmy.shared/PanelShell.qml`** (anchor enum, island glass and outline, radius 9, island padding, `CardMotion`, attached under the island).
  - **Items:** Stay awake, Set reminder, Night light, Silence notifications. That is the stock list minus passwordless sudo and screen recording, which the refined brief dropped.
  - **Hover:** hovering the time opens it with no keyboard grab; leaving the time and the card closes it.
  - **Keyboard:** **`Super+Ctrl+Q`** (checked free first) opens it with focus. Up/Down moves, Enter acts, Esc closes.
- **Stay awake is clickable and lives on the bar:**
  - **On:** it is the first thing in the right island, left of the time, in accent.
  - **Off:** clicking that light turns stay awake off, as does Enter on it in the pop-out.
- **Set reminder:** opens the reminders panel. Its card now drops from the right island, attached, in the island style, with the `[ui]` font. Night light opens Locus (now hosted and adopted). Silence toggles the notification service's Do Not Disturb.

**Verified:**
- **Hover:** with real pointer motion over the time it opened (`opened: true, keyboard: false`); moving away closed it.
- **Keyboard:** the `Super+Ctrl+Q` command opened it with focus; Esc closed it.
- **Stay awake off:** Enter on Stay awake → `omarchy-shell idle status` `stayAwake: false`, the light left the island, and the island re-centred.
- **Stay awake on:** Enter again → on, light back.

**Not physically tested:** a mouse *click* on the light or a pop-out row (no uinput tool here, and Hyprland ignores virtual input for clicks). They call the same functions the keyboard path proved.

## 6. Every hosted panel in the same language

- New **`jimmy.shared/PanelAdopter.qml`** (the PanelShell family).
- **How it works:** when a hosted stock panel opens, its card is adopted at runtime, with no stock file edited:
  - **Style:** island glass, the thin outline and radius 9.
  - **Motion:** the shared `CardMotion` replaces the stock grow-in.
  - **Close:** on close the shared close motion runs. The stock panel's window stays mapped exactly while its card is visible, so the window follows the shared motion.
- **Adopted, all 9:** audio, Bluetooth, network, power, monitor, clock, weather, agents, Locus. The microphone widget has no panel. `status.adopted` lists all nine; each opened and closed through `omarchy-shell shell toggle`, which is exactly what `Super+Ctrl+A/B/N/P/D` run.
- **Bounce evidence:** frames of the audio panel about 50 ms in show the card narrower and fading in; at about 1 s it is settled, wider, at full opacity.
- **Blur:** `omarchy-keyboard-panel` was added to the glass blur rule. At 0.70 alpha without blur, the panel content competed with the window behind it.
- **Fixed during the build:** the first adoption attempt found no card, because `KeyboardPanel.contentItem` is its content property, not the window root. It now searches the panel's declared children.

## Tokens changed (`shell.toml`)

| Token | Was | Now |
|---|---|---|
| `toast.gap` | 8 | 0 (attached; the toast's top edge = the island's bottom edge) |

Nothing else changed. The islands, battery, motion and agents tokens are as in Stage 3; `ui.font` is from the font pass.

## Files

- **New:**
  - `jimmy.shared/PanelShell.qml` and `jimmy.shared/PanelAdopter.qml`.
  - `jimmy.notifications/`, a clone of `Service.qml`, `Toast.qml` and `DeedButton.qml`, edited.
- **Changed:**
  - **Plugins:** `jimmy.bar/Bar.qml`, `jimmy.osd/Osd.qml`, `jimmy.menu/Menu.qml`, `jimmy.apps/Apps.qml`, `jimmy.reminders/ReminderFlow.qml`.
  - **Hyprland:** `hypr/bindings.lua` (`bar-quick` block: `Super+Ctrl+Q`) and `hypr/menu-glass.lua` (blur: `omarchy-notifications`, `jimmy-panel`, `omarchy-keyboard-panel`).
  - **Shell config:** `shell.toml` (`toast.gap`) and `shell.json` (the notifications clone).
- **Contract:** `docs/contracts/agent-hook-payload.{schema.json,md}`.

## Still open

- **For your eye:**
  - Whether the outline pulse reads "charging" from across the room.
  - Whether the capsules read as "per model" without labels. The order is fixed; the agents panel has the names.
  - The pop-out's hover delays (open 180 ms, close 300 ms).
- **#12, #13:** live agent status and per-account Claude usage still need hooks (contract now carries `account`).
- **Broken `notify-send`:** the libnotify symbol error above.
- **Stock panel content weights:** not changed (see §1).
- **Not exercised:**
  - The notification deck's close motion on dismiss.
  - Low and critical battery colours (on AC).
  - A real mouse click on the light.
- `notch.width` is still provisional (ruler read pending).
