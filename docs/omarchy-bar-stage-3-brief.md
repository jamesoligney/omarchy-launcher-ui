# Omarchy Bar — Stage 3 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` in the repo, plus brief v2 (`docs/omarchy-bar-restructure-design-brief.md`). Build from those. Do not rebuild from a task message alone.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua config, single internal monitor eDP-1, 3456x2234 @120Hz, scale 2. No external monitor, ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules for this round
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` (saves backlight, sets 0, pauses auto) + `omarchy toggle idle stay-awake` (freeze screen, no screensaver/lock during the build). End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` (restore backlight, resume auto) + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. The end step belongs in the build report checklist, next to "no debug logs left" and "backups complete".
- **Stay awake is OFF and verified now.** Do not touch it except via the build start/end steps above.
- **Backup everything that determines behaviour** before editing, audit first, include it, only exclude with a stated reason. Runtime state stays out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** Safe reload is `omarchy restart shell`, on its own, never combined with a summon loop.
- **Theme-aware, not fixed.** Afterburn default edition. Tokens in `shell.toml`, one-line edits.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change — never fix one element and leave the same pattern elsewhere.

## What this round builds — Stage 3: islands live

### 1. Islands centered in their ears
Islands live equidistant between the edge of the notch and their respective edge of the screen, floating in the middle of their respective areas.
- Left island centered between left screen edge and notch left edge. Right island centered between notch right edge and right screen edge.
- They expand symmetrically as content changes — centre stays put, they grow both ways. That is more stable than the current notch-anchored layout, where the centre moves.
- Current: left island right edge at notch minus inset 10, right island left edge at notch plus inset 10. Replace that anchoring with centering in the ear.

### 2. Islands less pill-shaped, larger elements, less padding
- Corner radius less than now (current token `island.radius 14`). More like rounded squares, closer to the window radius, but not that extreme. Less like pills.
- Everything in the islands larger, more legible. First move is *inside* the existing 44px top reserve: island height is currently 32, with 6px padding top + bottom. Reduce padding to 2–3px each side, island height 38–40 within the 44, elements fill more of the island.
- Only if that is not enough, increase the reserve (bar height above 44) — and only after James judges it live by eye. Do not take more screen by default.

### 3. Battery pill — wider AND taller, % inside
- Current token `battery.bar-width 26, bar-height 9` is wrong — a 26px bar cannot hold a % inside it.
- Battery is a fixed-width horizontal pill, % inside, fill = charge, motion / glow = charging, amber at 20%, red at 10%, fluid live via PowerEvents.
- Pill must be wider *and* taller so a number fits inside it. This is the same "larger, more legible" direction as §2, applied to the battery.

### 4. Toasts / OSDs — one system, anchored to the owning island
- **All toasts need to come from the same place.** No toast pops up at the bottom of the screen, or randomly.
- Each toast grows out of the spot that owns that control. Keyboard backlight brightness lives in the right island (with battery / brightness), so its toast grows out of the right island. Same for volume, display brightness, etc. — each anchored to its owning island.
- One toast system: same glass, same CardMotion bounce, same animation as launcher / pickers. Do not change the backlight daemon or its lux mapping in this round — only where its toast anchors.
- The backlight toast built in commit 90176d1 works well — keep it, move its home.

### 5. Stay-awake light + privacy lights on the bar (R2 — never hide)
- `jimmy.bar` currently has *no* stay-awake indicator. Stock bar did. That hid stay awake being ON for 30 minutes, and the screensaver never fired. See `docs/reports/bar-idle-screensaver-diagnosis.md` (commit a614baa).
- Add a contextual stay-awake light on the right island while stay awake is on, read from the idle service (`shell.firstPartyServiceFor("omarchy.idle")`, open to bar plugins).
- Add privacy lights as contextual lights in the same family: microphone primary, screen-record, remote. Mic wins if several are active. These must never hide.
- Until these lights land, this bar is not the daily bar for sessions where they matter.

### 6. Weather live, not placeholder
- Weather icon is currently a placeholder — stock weather data lives only inside its panel. Move live weather data into the right island.
- Icon-only by default, easily expandable to the full panel. Three-state staleness. Theme-aware glyphs, 8–10 conditions. Berkeley, stock source / interval, manual refresh R.

### 7. Agents live, not placeholder
- Agents icon is currently a placeholder. Make it live: Claude Personal + Teams both live (do not make James switch manually), OpenCode, Grok.
- Review the hook contract frozen in Stage 0-2 (`docs/contracts/agent-hook-payload.schema.json`) before building mission control. Open investigations #12 (OpenCode/Grok status push) and #13 (Claude Personal vs Teams data) stay open — do not fill them in, report what is and is not verified.

### 8. Bar-widget panels — do not leave dead keys
- Stage 0-2 left `Super+Ctrl+A/B/N/P/D` (audio, Bluetooth, network, power, display) with no host — keys do nothing, shell calls guarded so nothing errors. That is not acceptable as a finished state.
- Either restore those panels as hosts, or replace them via the leader Super+D (then a single letter: W/T/B/A/D, 1-9, Esc). Decide, implement, and state which in the report. Do not leave dead keys.

## Out of scope for this round
- Panels through PanelShell, drawer, mission control pop/pin — Stage 4+.
- Dock remake — after the bar.
- ALS backlight daemon itself — built in 90176d1, do not rebuild it. Only its toast anchoring (§4).
- Notch width calibration — James's eye task with `jimmy.notch-ruler` (`notch.width` is provisional 174). Do not guess it.

## Verify live, then report
- Islands centered, less pill, larger elements, battery % fits inside, toasts grow from their island, stay-awake + privacy lights show, weather live, agents live, Super+Ctrl keys or Super+D replacement work.
- Fullscreen: bar hides cleanly, no flicker. Theme switch. Reload without refresh.
- `omarchy-shell idle status` after the build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-3-report.md`, commit, push, present the commit hash only. Include token values changed, what was judged live vs not, and what is still open.
