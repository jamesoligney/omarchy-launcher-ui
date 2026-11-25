# Omarchy Bar — Stage 4 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + `docs/omarchy-bar-stage-3-brief.md` in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: save the attached brief as `docs/omarchy-bar-stage-4-brief.md` first, then build Stage 4 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything** before editing, audit first, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked from Stage 3 — do not touch:** island size 38px high, island radius 9, bar height 44, island text 16px. Island size and corner radius are fine.

## 1. Uniform weight — SF Compact Display Medium, everywhere
- Font is already installed: `SF Compact Display:style=Medium`, in `~/.local/share/fonts/`, token `[ui] font = "SF Compact Display"`.
- **Medium is the balance** between thin and bold — that is the weight James chose. Do not bold it.
- **All numbers the same weight, all text the same weight.** No bold active workspace number, no bold battery %. No bold app name / window text. Everything in the islands, toasts, and pickers renders in SF Compact Display Medium, regular Medium weight, no synthetic bold.
- Apply the same weight to the launcher, apps window, and reminders as well — they were not covered by the font pass, add the same one-line `fontFamily` change there, so the whole system is one weight.
- Icons stay on Nerd Font, emoji glyphs fall back to colour emoji, as before.

## 2. Agents — red dot OFF, icon itself is the state
- **Remove the red dot entirely.** It is meaningless — it says something is over, not what, how much, or what to do.
- The model icon itself shows state, by fill / colour: running, waiting, near limit, over limit, per model (Claude Personal, Claude Teams, OpenCode, Grok). Fill = usage, colour = state, same language as the battery.
- Expanding the agents palette digs into per-model detail. That expansion is part of this round if the data is there; if not, the icon is quiet and live, with no dot, and the missing data is flagged as open, not filled in.
- Hook contract: add the optional `account` field (`main` / `teams`) at the hook layer before mission control — flagged in Stage 3, do it here if it is safe, otherwise state exactly what blocks it. Do not fill in #12 / #13 — report what is and is not verified.

## 3. Battery charging — shimmering / pulsing outline in accent
- Replace the current charging pulse at the fill's leading edge — it does not read as charging.
- **New: a shimmering / pulsing outline around the battery pill, in the current system accent / highlight colour.** Visible from across the room, pill itself stays calm, % inside unchanged.
- Try the outline first and judge it live. Fallback, do not do both at once: if the outline does not read, the number itself turns to the system accent while charging. State in the report which one shipped, and how it reads.

## 4. Toasts — one system, right island is the default, thin outline, attached
- **No orphan toasts.** Audit every toast source on the machine, map each one to an island.
- **If a toast does not map to an island, it always comes up under the right island, centered on the right island.** Never on the right edge of the screen, never at the bottom, never randomly.
- Toasts must look like an extension of the islands, not a different animal: **same thin outline as the islands, same radius 9, same glass, same padding.** They grow out of the island they belong to, literally attached to it — if you cannot tell where the island ends and the toast begins, except that the toast is the part that grew, it is right.
- Same CardMotion bounce, same close motion, as launcher / pickers / panels.

## 5. Hover pop-out back, and Stay awake you can touch
- **Bring back the hover pop-out** that used to slide out when hovering over the time: Stay awake, SetReminder, Night light (Locus), Silence notifications, etc. Same list as stock, in the new language: same glass, same thin outline, same bounce, dropping from the right island. Add a keyboard path to it — it must not be mouse-only.
- **Stay awake must be clickable, and it must live somewhere after you turn it on.** A light you cannot touch is not even decoration.
  - Click the Stay awake item in the pop-out to turn it on.
  - While on, it lives visibly — to the left of the time as it did on the stock bar, or occupying the right island — until you click it to turn it off, or use a keybind to turn it off.
  - The stay-awake light on the bar is that live element: click it to toggle off. Do not make a light that only shows state.
- SetReminder gets a home in that pop-out, opening a PanelShell panel.

## 6. Panels — all bounce, one UI language, via PanelShell
- Panels work in Stage 3, but they do not bounce. **Every panel that drops from an island must maintain the same UI language:** same CardMotion bounce, same glass, same thin outline, same close motion as launcher / pickers / toasts.
- Build them through PanelShell (Stage 4). No stock panel opens raw. If a panel cannot bounce, it is not finished.
- Hosted panels from Stage 3 (audio, Bluetooth, network, power, monitor, clock, weather, agents, mic) all go through PanelShell. Super+Ctrl+A/B/N/P/D keep working.

## Out of scope
- Drawer, mission control pop/pin — Stage 5+, after the hook contract / account field lands.
- Dock remake — after the bar.
- Island size / radius / reserve — locked, do not touch.
- ALS backlight daemon — do not rebuild it.

## Verify live, then report
- Uniform Medium weight everywhere, no bold numbers or text in islands / toasts / pickers / launcher.
- Red dot gone, agents icon live by fill / colour.
- Charging outline shimmer reads as charging, in accent.
- Orphan toast test: a toast with no island owner lands centered under the right island.
- Hover pop-out returns, Stay awake clicks on, lives visibly, clicks off.
- Every hosted panel bounces, same glass / outline / motion.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-4-report.md`, commit, push, present the commit hash only.
