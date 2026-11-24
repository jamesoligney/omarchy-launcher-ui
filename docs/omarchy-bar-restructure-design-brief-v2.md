# Omarchy Bar Restructure — Design Brief v2
## Refined for discussion, not for building yet (2026-11-24)

v1 is `docs/omarchy-bar-restructure-design-brief.md`. This version keeps what v1 decided, corrects a few facts against the live machine, marks what is still open, and separates **questions for James** and **suggestions** at the end so they can be answered one by one. No code, config or shell changes were made for this pass.

---

## 0. Facts checked on the machine (corrections to v1)

- **The top strip is 32 logical px, not ~44.** `hypr/monitors.lua` reserves `top = 32` for eDP-1. The cutout is 64 physical rows (`/usr/share/omarchy-platform/display-cutouts.json`) = 32 logical at scale 2. The current bar is also 32 tall (`shell.toml` `[bar] size-horizontal = 32`) and sits at the **bottom**, reserving another 32.
- **Consequence:** a 32-px bar placed in the top strip costs **zero extra space**. The ears either side of the notch are already reserved and currently empty. Moving the bar up gives back the bottom 32 px. That is the strongest practical argument for top-first, beyond feel.
- **The notch width is not in the platform data.** `display-cutouts.json` only gives the cutout height. The width (and the rounded top corners) must be measured live before any layout is fixed (see Suggestion S1).
- **The clock is currently 12-hour with AM/PM** (`shell.json`: `"format": "ddd d MMM h:mm AP"`). v1 says "3:04 and nothing else". That changes the live format, and 12-hour without AM/PM is ambiguous across noon (Question Q4).
- **Web app windows already identify themselves.** Omarchy web apps launch through `omarchy-launch-webapp` (Chromium `--app`). Their window class is `chrome-<host>__<path>-<profile>`, e.g. `chrome-muse.ai__-Default`, and their desktop entry carries the same value as `StartupWMClass` with `Name=Muse.AI`. 13 of the 25 user desktop entries are web apps. `jimmy.active-window` already resolves names through `DesktopEntries.heuristicLookup`, which matches on that class. So v1's open question "web app vs browser tab" is mostly answered: **a window is a web app if its class matches a desktop entry's `StartupWMClass`; otherwise it is the app itself** (a Helium or Floorp window is "Helium" or "Floorp", whatever tab is open). Test cases are in §6.
- **A notch-aware bar already exists as prior art:** `io.github.crumble21.notch-bar` is installed but disabled (`kind: bar, bar-widget`). It proves a third-party `bar`-kind plugin can replace the stock bar, and is worth reading before designing from scratch (S2).
- **Free Super keys** (from `hyprctl binds`): `Super + B, D, E, H, R, U, Y, Z` are unused. Most other Super letters, and many Super+Shift / Super+Ctrl combinations, are taken. Alt + F, G, H, K, M, O, Z, Space and Tab are taken by app binds and Vicinae.
- **The data behind the core elements is already live**, except the remote checks (audit `009de90`): workspaces through Hyprland events, battery through UPower via `jimmy.shared/PowerEvents.qml`, weather and agent usage through remote fetches with timestamps on disk. Agent usage records (`~/.local/state/omarchy/agents/usage/*.json`) carry `limits`, `limitsFetchedAt`, `limitsStale`, `todayTotalTokens`, `todayPrompts`, `recentDays` and `retryAdvised`, which is enough for mission control's numbers without a new collector.

---

## 1. Decided (kept from v1)

- **Top first**, bottom as the fallback, judged live by feel.
- **Only the core at rest:** workspaces (with app name), time, weather, battery, agents. Everything else is hidden until summoned.
- **Panels share one motion:** `jimmy.shared/CardMotion.qml`, the same springs, the 160 ms fade and the 100 ms close. Pill panels bounce from the bar; side panels bounce from their edge.
- **Panels are attached to the edge they live on**, not floating mid-screen.
- **A side drawer from the right** holds the tray and everything not in the core, with large live-state tiles, keyboard-navigable.
- **Keyboard first:** every element has a key and a visible hint; no mouse-only element; the main action in a panel takes at most two keypresses.
- **Live, not polling:** Quickshell APIs and events; remote checks state their age.
- **Shared code in `jimmy.shared`**; theme-aware; efficient, clean and light; and the standing rule of applying each learning across the whole UI.
- **Related work captured now:** default floating window size/position, then the dock.

---

## 2. Layout (open, with a recommended starting point)

Two physical facts constrain everything: the bar must stay 32 px tall to live in the ears, and nothing can be drawn in the notch.

**Recommended first prototype: two islands in the ears.**

```
 ┌ rounded corner ┐                                          ┌ rounded corner ┐
 │  [1 2 ·4]  Muse.AI      ◖▔▔▔▔▔ NOTCH ▔▔▔▔▔◗      3:04   18° ☀   ◔ 82%   ✳ │
 └────────────────────────────────────────────────────────────────────────────┘
   left island: workspaces + app name          right island: time, weather, battery, agents
```

- **Left ear:** workspaces, then the app name. That is the element with the most movement, next to where the eye starts.
- **Right ear:** time, weather, battery, agents. Time sits nearest the notch, so it is the stable anchor beside the cutout.
- **Alternatives to test live:**
  - (b) A single wide pill with a notch-shaped gap. It reads as one object but needs exact notch geometry, and the gap must not look like a rendering bug.
  - (c) Time centred *below* the notch. That costs extra reserved height, which defeats the zero-cost advantage above.
- The **hub** idea survives as a keyboard concept (one leader key, §4) rather than a central pixel location, since the centre is the notch.

---

## 3. The elements, refined

### Workspaces + app name
- Occupied only, active highlighted, stable order, as live now (`jimmy.workspaces`).
- App name only, no title. Name resolution order: desktop entry by `StartupWMClass` (web apps), then desktop entry by app id, then a capitalised last segment of the class.
- **Width discipline:** cap the name width and fade it (no animation of width on every focus change). The current `Behavior on implicitWidth` (180 ms) would make the left island breathe on every focus change, which v1 wants to avoid.
- Open: show the name of the **focused window only**, or of each workspace's main window (Q2)?

### Time
- At rest: time only, tabular figures so the width never changes.
- Panel: date, calendar, and (suggestion) the next calendar event and a second time zone if wanted.

### Weather
- At rest: temperature and icon.
- **Honest staleness:** the icon dims after twice the refresh interval, and the panel shows "updated 12 min ago". After a failed fetch it shows the last value with an "offline" mark rather than a blank.
- Panel: forecast, location, last-updated time, a manual refresh key.

### Battery
- At rest: % and icon, from UPower signals (`PowerEvents`).
- Panel: power profile (one key cycles it), time to empty/full, low-battery state.
- Open: show the % always, or only when discharging or below a threshold (Q5)?

### Agents — mission control
- **Two data streams, both push-based:**
  1. **Usage and limits:** the existing usage records (watched files), with their fetch time shown.
  2. **What is running right now:** agent windows are already visible to Hyprland (class `org.omarchy.agent`), so the list of running agent windows is live through toplevel events. Per-agent *status* (thinking, waiting for input, done) can be **pushed by the agents themselves** through their hook systems. Claude Code hooks (session start, stop, notification) can call `omarchy-shell` IPC. No process polling is needed.
- **Pop** (quick check): one line per running agent with status, then usage bars for the next limit to reset. Esc closes.
- **Pinned** (heavy AI work): stays open, updates live, and adds recent activity and time to renewal per plan.
- **Pinned must not take keyboard focus** (`WlrKeyboardFocus.None`), or it will swallow typing in the window underneath. It needs its own key to focus it when wanted.
- Rest indicator: the icon gains a small state dot. Amber means an agent is waiting for input. Red means near a limit (`limits` within N %).

---

## 4. Interaction — a leader key instead of five new binds (suggestion, open)

v1 asks for a key per element and lists collisions to avoid. With most Super letters taken, five separate global binds are hard to make memorable. Proposal:

- **One leader: `Super + B`** (free; "B" for bar). It enters a Hyprland *submap* and the bar shows a one-letter hint under each element:
  - `W` weather, `T` time/calendar, `B` battery, `A` agents (pop), `Shift+A` agents (pin), `D` drawer, `1–9` jump to workspace, `Esc` leave.
- One bind to learn, letters on screen while it is active, and no collisions with the app, picker or Omarchy binds. Direct binds can still be added later for the panels used most.
- Alternative: direct `Super + D` for the drawer (free) as the single most-used shortcut, plus the leader for the rest.

Inside panels, the picker rules hold: arrows move, Enter acts, Esc closes, ⌥P pins (the same pin key as the pickers), and hints are on screen.

---

## 5. Side drawer (open: contents)

Suggested starting tiles. **Enter or click toggles; → or a second key opens the detail.**

| Tile | Toggle | Detail |
|---|---|---|
| Wi-Fi | on/off | network list (existing network panel) |
| Bluetooth | on/off | devices |
| Volume / output | mute | output device, per-app volume |
| Microphone | mute | input device |
| Brightness | — | slider |
| Night light | on/off | temperature |
| Do not disturb | on/off | notification history |
| Power profile | cycle | — |
| Stay awake | on/off | — |
| Screen record | start/stop | — |
| Updates | — | run update (only shown when an update exists) |
| Tray apps | — | each app's menu (see risk R5) |

Candidates to drop entirely unless James uses them: Dropbox, Tailscale, the speed tests, the dev gallery.

---

## 6. Test cases for app-name resolution

| Window | Expected name |
|---|---|
| Muse.AI web app (`chrome-muse.ai__-Default`) | Muse.AI |
| Any other Omarchy web app (Keep, Discord, Gemini…) | the desktop entry's Name |
| Helium browser window, any tab | Helium |
| Floorp (`one.ablaze.floorp`, flatpak) | Floorp |
| Zen | Zen |
| Ghostty | Ghostty |
| Omarchy agent window (`org.omarchy.agent`) | the agent's name if it can be read, else "Agent" |
| Orca | Orca |
| A Helium-installed PWA, if any exist (class not yet seen) | its app name; **untested** |
| A window with no desktop entry | capitalised class |

---

## 7. Default floating window (related, open)

- Mechanism: Hyprland window rules in a new `hypr/*.lua` include (float, size, centre or position) applied by class. Not a global "float everything", which breaks dialogs, pickers and fullscreen video.
- Suggest a **preset size** (for example 1100 × 700 logical, centred slightly low, since James works closer to the bottom) for an explicit list of apps, plus one key to toggle a window between that preset and tiled.
- Open: which apps, what size, and whether terminals are included (Q8).

---

## 8. Risks and things v1 did not cover

- **R1. Notch geometry.** Width unknown; rounded top corners can clip the outermost glyphs. Mitigation: measure first (S1); keep content inset from both corners.
- **R2. Privacy-critical indicators must never hide.** v1's "only the core at rest" would push the screen-recording, mic-in-use and remote-session (screen share) indicators into the drawer. They must appear on the bar **whenever active**, as contextual lights, then disappear. This is a missed element, not a nice-to-have.
- **R3. Notifications have no home in v1.** Toasts, DND and history need a place. Suggest toasts drop from the right island's edge (same motion) and history lives in the drawer's DND tile.
- **R4. External monitors have no notch.** The same bar must lay out as one continuous strip on a plain monitor, and each monitor keeps its own workspace block (as `jimmy.workspaces` does now).
- **R5. Tray menus.** Status-notifier apps expose DBus menus that are built for right-click. Keyboard access needs Quickshell's menu opener and may not cover every app; some tray items may stay pointer-first. Acceptable only if named.
- **R6. Pinned panels and focus.** See mission control: pinned panels must not steal keyboard focus; several pinned panels need a stacking rule.
- **R7. Fullscreen.** Fullscreen windows cover the reserved strip; the bar should hide cleanly and the ears go black, not flicker.
- **R8. Replacing the stock bar.** The new bar is a `bar`-kind plugin. Third-party plugins get a scoped shell (the apps-window lesson, `efd8834`): check before building that a third-party bar receives what it needs (bar config, first-party services for DND, night light, idle, media, notifications). The notch-bar plugin is evidence it can work.
- **R9. Rollback.** Build the new bar as its own plugin next to the stock one, switch with `omarchy plugin enable/disable`, and keep the stock bar one command away. Back up `shell.json` with a timestamp before each switch. Never use `omarchy refresh shell`.
- **R10. The width of moving numbers.** Time, battery and the temperature change length (9:59 → 10:00, 9% → 10%). Tabular figures and fixed minimum widths keep the islands from jittering.

---

## 9. Questions for James

1. **Layout:** start with two islands in the ears (recommended), a single pill with a notch gap, or time below the notch?
2. **App name:** the focused window's app only, or each workspace's main app?
3. **Leader key:** happy with `Super + B` as a bar leader showing letter hints, or do you want a direct bind per panel?
4. **Time format:** v1 says "3:04", but the live clock is currently 12-hour with AM/PM. Keep 12-hour without AM/PM (ambiguous across noon), or switch to 24-hour "15:04"?
5. **Battery at rest:** always show the %, or only when discharging or low?
6. **Agents:** which agents matter in mission control (the records exist for agy, claude, codex, copilot, cursor, deepseek, devin, fireworks, grok, grokbot…)? Can agent status be pushed by Claude Code hooks (it needs a small hook entry in its settings)?
7. **Drawer:** confirm the tile list in §5. Which can be dropped?
8. **Floating default:** which apps, what size and position, terminals included or not?
9. **Notifications:** toasts from the top-right island, history in the drawer. OK?
10. **External monitor:** do you use one? If not, R4 can wait.

---

## 10. Suggestions (new, beyond v1)

- **S1. Measure the notch first.** A one-off calibration overlay that draws a ruler across the top strip, read by eye, then saved as a token in `shell.toml` (`[bar] notch-width`, `corner-inset`). No guessing.
- **S2. Read the installed notch-bar plugin** (`io.github.crumble21.notch-bar`, disabled) for how it handles the notch, then decide whether to fork its layout code or start clean.
- **S3. Contextual islands, "dynamic island" style.** The right island briefly grows to show something live, then shrinks back: volume and brightness changes (replacing the separate OSD), media now playing (Mpris), a recording timer, and an agent waiting for input. Same motion, no new animation.
- **S4. One `PanelShell` in `jimmy.shared`.** Anchor edge, `CardMotion`, glass tokens, keyboard navigation, pin state and a staleness label in one component. Each panel supplies only its content. This is the equivalent for panels of what `CardMotion` did for motion.
- **S5. One `Staleness` helper in `jimmy.shared`.** "Updated 12 min ago", dimming after twice the interval, and an offline mark, shared by weather, agents and updates.
- **S6. A held-Super cheat sheet.** Holding Super for half a second shows the bar's letters and the main binds, for discoverability without clutter.
- **S7. A staging plan.** (1) calibrate the notch; (2) a static mock of the two islands at 32 px, judged live; (3) move the existing live widgets into it; (4) the panels through `PanelShell`; (5) the drawer; (6) mission control with hooks. Each stage reversible and verified live.
- **S8. Keep the bar quiet.** Only the active element and contextual lights change at rest; numbers update in place without animating their width. Motion is reserved for panels and contextual islands, so it keeps its meaning.
