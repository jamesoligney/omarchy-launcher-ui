# Omarchy Bar Restructure — Refined Brief (theory, no build)

Status: Refined brief v1  
Scope: Theory and decisions only. Do not build yet.  
Purpose: Keep what is decided, mark what is open, and separate questions and suggestions.

---

## 1. Locked decisions (keep as written)

### Layout
- Top-first, two islands split by the notch. Bottom 32px reserve removed. Left island: workspaces + focused app. Right island: time (nearest notch), weather, battery, agents. Deeper top reserve than 32px, starting at 44px, tuned live.
- Single pill with notch gap and time-below-notch are rejected for now.
- Notch width is unknown — measure live with a ruler overlay, save as a token, keep content inset from corners.

### Core at rest (only these)
- **Workspaces:** occupied only, active highlighted, stable order.
- **App name:** focused window only, no doc title, web-app resolution via StartupWMClass/desktop entry, capped + faded, no width animation on focus change.
- **Time:** HH:MM 12-hour, no seconds, no AM/PM, tabular figures. Panel = date + Google Calendar with event dots. No next-event, no second zone.
- **Weather:** Berkeley, temp + icon at rest, manual refresh in panel, honest staleness (dim at 2× interval, "updated X min ago", offline mark after failure with last value retained).
- **Battery:** % always at rest inside a fixed-width progress bar, fill = charge, charging = motion/glow, discharging = steady, amber→red low, UPower signals via PowerEvents, smooth. Panel: power profile (cycle key), time to empty/full, low state. Power profile lives here, not the drawer.
- **Agents:** icon/usage indicator at rest with state dot (amber = waiting for input, red = near limit). Panel has pop (quick check) and summon+pin (persistent) modes. Claude = two live accounts (Personal, Teams) simultaneously. Claude Code hooks → omarchy-shell IPC, no polling.

### Interaction
- Leader **Super+D**, single unmodified letter: W/T/B/A, Shift+A pin, D drawer, 1–9 workspace, Esc leave. Every element has a key and visible hint. Main action ≤ 2 keypresses. Inside panels: arrows/Enter/Esc, Option+P pins. Hold-Super half-second = cheat sheet.
- Direct binds deferred until a panel earns one.

### Panels
- One shared **PanelShell** (anchor edge, CardMotion, glass tokens, keyboard nav, pin state, staleness label). One **Staleness** helper shared by weather/agents/updates. Identical bounce: X 0.80/ω24/ζ0.40/peak 1.050; Y 0.70/ω20/ζ0.46/peak 1.058; 160ms fade, 100ms close.
- Bar stays quiet at rest; only active element + contextual lights change. Numbers update in place without width animation. Motion reserved for panels/contextual islands.

### Drawer
- Right edge, full-height initially, follows content. Keyboard nav. Core tiles: Wi-Fi, Bluetooth, Microphone, Night light/Locus, Volume output switching, Updates (only when one exists), Tray apps, Stay awake. Drops: screen record, brightness, passwordless sudo, DND tile. Volume level = function keys only, no slider tile. Plugins section for tray-only plugins, prefer launcher rows. Notifications history lives here.

### Hover pop-out
- Keep hidden, default form except: Stay awake kept, passwordless sudo dropped, screen recording dropped, SetReminder kept + gets a home, Night light → opens Locus, Silence notifications kept hidden.

### Tray audit
- Keep launcher/binds (Scratchpad, Monitor, Launcher, Omaland, Fathom, LocalSend). CLI-only → launcher rows (Superwhisper, Omapop settings, Window Effects, Matrix Screens, Tricky Tiles, Lock Explorer, Locus). Drop tray-only/duplicates (AI Usage notch, stock night light, Superwhisper tray icon, Vicinae tray icon). Matrix and Lock Explorer both keepers. Vicinae stays until bind management is built into our launcher (future requirement, blocker to uninstall).
- Glyph Menu/Smart Divider replaced; Flea Shelf dropped; Notch Bar read as prior art.

### Contextual / privacy / fullscreen
- Right island briefly grows for volume/brightness, media now playing, recording timer, agent waiting. Privacy indicators kept (mic primary; screen-record/remote as contextual lights). Fullscreen = absolutely fullscreen, bar hides, ears black, no flicker.

### Data
- Quickshell services + events only (Pipewire, UPower, SystemTray, Bluetooth, NetworkManager, Mpris, Hyprland, ToplevelManager). Remote checks say when last fetched. Agent records carry limits, limitsFetchedAt, limitsStale, todayTotalTokens, todayPrompts, recentDays, retryAdvised.

### Floating default window
- Start 1100x700, tune live. Real test = YouTube workflow (Helium, Cmd+Opt+V/F fullscreen-in-window, resize to video dims, Cmd+F/undo, Cmd+Opt+C centre). Measure that window → preset. Standard applies to every window; second window stacks on first floated, Cmd+L to dwindle. Exclusions to list.

### Staging
- (1) notch calibration, (2) static two-island mock judged live, (3) move live widgets, (4) panels via PanelShell, (5) drawer, (6) mission control with hooks. Each reversible, verified live, own plugin next to stock, enable/disable switch, timestamped shell.json backup before each switch. Never `omarchy refresh shell`.

---

## 2. Open items (explicitly unresolved)

### Layout / calibration
- Exact notch width and shape (measure live, tokenize).
- Final top reserve (44px is a starting point, not a decision).
- Whether the right island's four elements (time, weather, battery, agents) fit at rest without crowding at 1728 logical width — needs the static mock to judge. If not, what yields first? (Likely weather to icon-only, or agents to dot-only.)
- Island corner radius / inset policy vs. notch corners (content inset from corners is decided; the token value is not).

### App name
- Exact cap width and fade curve — needs live judgment with long names (e.g. `chrome-muse.ai__-Default`).
- Fallback when StartupWMClass is missing or ambiguous — show WM_CLASS raw, or a generic glyph?

### Time / calendar
- Google Calendar auth path (OAuth device flow vs. existing token), refresh cadence, and what "event dots" mean at month view vs. day view — one dot per event, capped at 3, colour by calendar?
- Is the calendar read-only, or do you want event creation from the panel eventually? (Affects scope.)

### Weather
- Stock source and interval — is "stock" Omarchy's existing weather plugin, and what interval (15 min? 30?)?
- Icon set for conditions — theme-aware glyphs or a small custom set?
- Panel content beyond "updated X min ago" — forecast? hourly? Or strictly current + refresh + staleness?

### Battery
- "Motion/glow/flow" charging animation — CSS-style keyframes on a shader/fill, or a discrete pulse? Needs a spec to avoid it feeling gimmicky.
- Time-to-empty/full source (UPower `timeToEmpty`/`timeToFull` are estimates; do you want smoothing or raw?).
- Low thresholds (amber at 20%? red at 10%?) and whether low state also triggers a contextual island pulse.

### Agents
- Claude Code hook payload contract — what fields does `omarchy-shell IPC` receive (session id, account, state, limit, tokens)? Needs a schema before mission control is built.
- Personal vs Teams separation — open investigation as noted; do usage records already carry an account discriminator, or do hooks need to tag it?
- OpenCode/Grok push — open; fallback is usage records + toplevel events. Acceptable as v1?
- Pin mode: "must not take keyboard focus, needs its own key to focus it" — what key? And does pin persist across workspace switches / fullscreen?
- Pop vs pin transition — does the same panel morph (CardMotion re-anchor) or is pin a separate window? Affects PanelShell design.

### Drawer
- Full-height initially, "height follows content" — what triggers the shrink (first open after content known? per-session?).
- Volume output switching UI — list with radio selection, or cycle? Keyboard model?
- Notifications history — how much, grouped by app, clear-all? (Not specified.)
- Tray apps tile — grid or list, and does it host StatusNotifier menus natively or launch them?

### Hover pop-out
- SetReminder "home" — is it a hover-popout item that opens a reminder panel, or does it get a leader key (R is taken by weather refresh; maybe Shift+R)? Needs a decision.
- Locus pop-out — open Locus window, or an inline mini-panel?

### Contextual islands
- Media now playing: what's the at-rest vs. grown layout, and does it replace or append to the right island's four elements?
- Recording timer — which recorder? (Screen record was dropped from the drawer; is this a separate tool?)
- Privacy indicators — exact glyphs and whether they coexist with agents dot in the same island slot.
- Fullscreen hide: does the bar fully unmount (ears black, zero draw) or stay mounted at 0 opacity? "No flicker" suggests the former but needs a spec.

### Copy-on-select
- Investigation only for now: is it system-wide feasible? Candidates: a Wayland primary-selection hook, a Hyprland `bind` + clipboard tool, or a compositor plugin. What's the acceptable latency and scope (all apps vs. terminal-only)? Does it respect password fields?

### Floating window
- Exclusions list — dialogs, pickers, fullscreen video, Picture-in-Picture, portals, games, screen share, etc. Needs enumeration.
- Cmd+L toggle — does it remember the previous formation, or always go dwindle?
- Is the preset per-app (YouTube→measured dims) or global default with per-app overrides?

### Staging
- How is "verified live" defined per stage — a checklist, or just visual judgment?
- Backup naming/rotation for shell.json (keep last N?).

---

## 3. Questions (things genuinely ambiguous)

1. **Right island density.** At rest you want time + weather + battery + agents in the right ear, with time nearest the notch. At 1728 logical px and a notch of unknown width, how much horizontal room is actually left per ear? Have you measured the notch's logical width yet, or is that strictly stage 1? If the right ear can't hold four elements, which degrades first and to what form?
2. **Agents focus key.** Pin mode "needs its own key to focus it" — is that a global bind (e.g. Super+Shift+A) or contextual when pinned? And if it's focused, does Esc return focus to the previously focused window?
3. **Time panel calendar scope.** Read-only event dots, or do you want create/edit? If read-only, does the panel need day/week/month views or just month + today list?
4. **Weather "stock source."** Is that Omarchy's existing weather plugin with its default provider (which one?), or do you mean "a stock/simple source of your choosing"? Interval — 15 min or 30?
5. **Battery animation spec.** "Motion / glow / flow" — do you have a reference (e.g. a charging indicator you like), or should I propose two or three concrete treatments for you to pick from before any build?
6. **Media now playing.** "Only appears when something is actually playing" — does it replace the time/weather/battery/agents row temporarily, or grow the island above/below them? And does it show for any Mpris source or only specific apps (Helium/YouTube counts or not)?
7. **Recording timer.** Which recording tool is this? Screen record was dropped from the drawer; is there another recorder (e.g. a CLI) that should get a contextual timer, or is this speculative?
8. **SetReminder home.** Hover pop-out item, leader key, or drawer tile? You said "give it a home" — which layer?
9. **Copy-on-select scope.** System-wide (all apps) or terminal-first? And does it need to work in browsers (where selection is a DOM concept) or only native Wayland clients?
10. **Floating window exclusions.** Should I draft the exclusion list for your review, or do you have a list already?
11. **Vicinae replacement.** "Robust bind management ... is the blocker to uninstalling Vicinae" — is that in scope for this restructure, or a later phase? If later, Vicinae stays installed and its tray icon drops now — correct?
12. **Pin key.** Option+P is the pin key inside panels. On a Mac keyboard, is Option the right modifier for a Linux/Hyprland system, or did you mean Alt? (Worth confirming since Super is the leader.)

---

## 4. Suggestions (things you didn't ask for, or didn't specify)

### Layout / structure
- **Add a thin "ear baseline" guide during stage 1–2 only.** A toggleable 1px line at the island baseline and notch edges makes the static mock judgeable; remove after calibration.
- **Tokenize the notch as `notch.width`, `notch.inset`, `bar.height`, `island.gap`, `island.radius`** in the theme file — not literals — so the mock and the live bar share one source and theme-switching doesn't drift.
- **Define a "quiet" contract for the bar:** at rest, only the active workspace, the active app name, and the agents state dot are allowed to be non-neutral. Everything else is foreground at reduced opacity. This makes "the bar stays quiet" testable rather than a vibe.
- **Right-island overflow policy** (pick one now, before the mock): priority order time > battery > agents > weather; weather degrades to icon-only first, then agents to dot-only. Write it down so the mock has a rule.

### Time / calendar
- **Event dots cap at 3 per day, with a "+N" affordance** in the day cell — prevents a busy day from turning into a dot wall.
- **Today's date is the only "active" cell at rest**; hover/focus moves the highlight, but nothing animates until the panel opens.
- **Consider a "now" line in the day view** — cheap, elegant, and it makes the calendar feel live without polling.

### Weather
- **Staleness should have three states, not two:** fresh (full opacity), stale (dimmed + "updated X min ago"), offline (dimmed + offline mark + last value). You described this, but make it a shared Staleness helper with exactly these three states so agents/updates reuse it identically.
- **Weather icon should be a small theme-aware glyph set**, not an emoji, to match the elegance bar. Propose 8–10 conditions.

### Battery
- **Spec the charging animation as a single 1.5–2s loop** with a soft leading edge (not a full-bar sweep), so it reads as "flow" not "progress." Two candidate treatments: (a) a slow gradient drift across the filled portion, (b) a subtle pulse at the fill edge. Pick one before build.
- **Amber at 20%, red at 10%** as defaults; make thresholds tokens.
- **Time-to-empty/full:** show raw UPower estimate, but round to 5 min and prefix with "~" — honest and calm.

### Agents
- **Define the hook payload schema now**, even if only Claude implements it in v1: `{ account, session, state, limitUsed, limitTotal, limitsFetchedAt, limitsStale, todayTotalTokens, todayPrompts, retryAdvised }`. This is the contract mission control depends on.
- **Personal vs Teams separation:** if usage records don't carry an account discriminator, tag at the hook layer (the hook knows which config dir / account it fired from). Flag this as the critical unknown for stage 6.
- **Pin mode should be a separate floating window**, not a morphed bar panel — it avoids the focus-stealing problem entirely and lets PanelShell's anchor be "free-floating." Worth deciding before PanelShell is frozen.
- **Add a "quiet" agents state:** no agents running → icon at reduced opacity, no dot. Only lights up when there's something to see. Matches the quiet-bar contract.

### Panels / motion
- **PanelShell should expose a `staleness` slot and a `pin` slot as first-class props**, not per-panel ad hoc — you implied this; make it explicit in the component contract.
- **Closing motion (100ms) should be the reverse of the bounce, not a fade** — otherwise panels feel like they teleport. Specify: reverse CardMotion, 100ms, no fade.
- **Define "anchor" as an enum** (`top`, `right`, `left`, `free`) so side panels and the drawer share the same component without branching.

### Drawer
- **Notifications history needs a spec:** last N (50?), grouped by app, timestamp relative ("12 min ago"), clear-all + per-app clear, and does it respect Silence? It's the least-specified tile.
- **Tray apps tile:** prefer launching the app's own menu via StatusNotifier rather than reimplementing menus; if a tray item has no menu, show it as a launcher row instead.
- **Volume output switching:** a radio list (Bluetooth buds / wired / headphones / speakers) with Enter to select, arrows to move — fits the keyboard-first model better than a cycle.

### Hover pop-out
- **Give the pop-out a keyboard path too** — hover is mouse-only today, which violates "no mouse-only element." Suggest: when the right island has focus (via leader), arrows walk the pop-out items and Enter activates. Hidden visually until hovered *or* focused.
- **SetReminder home:** a hover-pop-out item that opens a small PanelShell panel (anchor: top, below the island) with a list + "new reminder" action. Reuses PanelShell, no new component.

### Contextual islands
- **Media now playing should occupy a dedicated "media slot" in the right island** that is zero-width when idle and grows when playing — not a replacement for time/weather/battery/agents. This keeps time as the stable anchor.
- **Define the privacy-indicator glyphs now** (mic, screen-record, remote) and their priority if two are active — mic wins, others stack to its left.
- **Fullscreen hide:** unmount the bar (zero draw) rather than opacity 0; ears black. Add a 50ms debounce so a fullscreen toggle doesn't flicker.

### Copy-on-select
- **Scope it as a separate investigation with a decision gate:** (a) Wayland primary selection already exists but only pastes on middle-click; (b) a `wl-paste --primary` watcher → `wl-copy` bridge is the cheapest system-wide approximation; (c) a Hyprland plugin is the robust path. Recommend (b) as a v0 experiment, measure latency, decide. Note it will not work inside browsers' DOM selections without a browser extension.
- **Respect password fields** — exclude `xwayland`/`electron` password inputs and any `Secret`-typed selections; this is a security requirement, not a nicety.

### Floating window
- **Draft the exclusion list for review:** portals (file pickers), dialogs (modals), fullscreen video/PiP, games, screen-share windows, `xdg-desktop-portal` surfaces, and anything with `_NET_WM_WINDOW_TYPE_DIALOG`. Confirm before implementing.
- **Cmd+L should remember the previous formation** per window (toggle), not force dwindle — matches the YouTube workflow.

### Staging / process
- **Add a stage 0: token + contract freeze.** Before any build, freeze the theme tokens (notch, bar height, island gap/radius, thresholds) and the agent hook payload schema. This prevents rework in stages 2–6.
- **"Verified live" = a 5-item checklist per stage** (visual, keyboard, theme-switch, fullscreen, reload-without-refresh). Cheap, repeatable, reversible.
- **shell.json backups:** timestamped, keep last 10, in `~/.local/state/omarchy/bar-backups/`.

### Risks / alternatives
- **Risk: right-island density.** If four elements don't fit, the fallback you rejected ("time below notch") may return — decide the degradation order now so you don't relitigate later.
- **Risk: pin-mode focus.** A persistent panel that never steals focus is easy to forget; add a subtle "pinned" indicator in the bar (a small dot on the agents icon) so you always know it's live.
- **Alternative to a notch-gap pill:** keep two islands but give them a shared visual "rail" (a 1px baseline) that visually connects them under the notch — reinforces "one bar, two islands" without faking screen under the camera.
- **Alternative to per-panel Option+P:** a single global pin toggle for the currently focused panel — simpler muscle memory, fewer per-panel quirks. Worth considering.
- **Risk: copy-on-select false positives** (selecting to read, not copy) — mitigate with a 150–200ms debounce after selection settles before copying, and a clipboard-history "just copied" toast in the drawer's notifications history.

---

## 5. What I'd add to the brief as new elements

- **A "quiet contract" section** (what may be non-neutral at rest) — makes the elegance testable.
- **A token table** (notch, bar, island, thresholds, motion) as a single source of truth.
- **An agent hook payload schema** as a contract, not a detail.
- **A PanelShell component contract** (anchor enum, staleness slot, pin slot, close-motion spec).
- **A three-state Staleness helper** shared explicitly.
- **A degradation/overflow policy** for the right island.
- **A copy-on-select decision gate** with v0 bridge, latency target, and password-field exclusion.
- **A stage 0 (freeze tokens + contracts)** before stage 1.
- **A "verified live" checklist** per stage.
- **A pin-mode focus contract** (own key, Esc returns focus, pinned indicator in bar).

## Adopted from DeepSeek — Max's gut picks, locked 2026-11-24
## This is NOT a redefinition of the brief. It is a jumping-off point — these are the DeepSeek suggestions adopted into the brief, the rest stay open / rejected as noted in the discussion.

### Locked by James, reading the DeepSeek brief quickly
- **Weather at rest: icon only.** Not temp + icon. Icon only at rest, expandable easily — leader W opens the full weather panel with temp, forecast, staleness.
- **Copy-on-select: system-wide, definitely.** However we have to do it, that is important. Scope is system-wide, not terminal-first. Investigate the v0 bridge, the Hyprland plugin path, and the browser DOM limitation — browsers will need an extension or a separate route, do not pretend system-wide covers them without it.

### Adopted on Max's gut
- **Quiet contract:** at rest, only the active workspace, the active app name, and the agents state dot are allowed to be non-neutral. Everything else is foreground at reduced opacity. Makes "elegant / quiet" testable.
- **Token table:** notch, bar, island, thresholds, motion as a single source of truth — `notch.width`, `notch.inset`, `bar.height`, `island.gap`, `island.radius`, plus battery thresholds, in the theme file, not literals.
- **Stage 0: token + contract freeze.** Before any build, freeze theme tokens and the agent hook payload schema. Prevents rework in stages 2-6.
- **Hook payload schema:** `{ account, session, state, limitUsed, limitTotal, limitsFetchedAt, limitsStale, todayTotalTokens, todayPrompts, retryAdvised }`. This is the contract mission control depends on. Personal vs Teams separation: if usage records don't carry an account discriminator, tag at the hook layer.
- **Right-island degradation order:** time > battery > agents > weather. Weather degrades first — and per James, weather is icon-only at rest by default, not just as a fallback. Next degradation is agents to dot-only.
- **PanelShell contract:** anchor enum (`top`, `right`, `left`, `free`), staleness slot and pin slot as first-class props, close motion to be tested live (reverse CardMotion, 100ms, no fade, vs current fade — do not lock, test it).
- **Pin mode: separate floating window, not a morphed bar panel.** Avoids focus-stealing entirely, lets PanelShell's anchor be "free-floating". Own key to focus it, Esc returns focus to the previously focused window, small pinned dot on the agents icon so you always know it's live.
- **Hover pop-out keyboard path:** hover is mouse-only today, which violates "no mouse-only element". When the right island has focus via the leader, arrows walk the pop-out items and Enter activates. Hidden visually until hovered *or* focused.
- **SetReminder home:** hover-pop-out item that opens a small PanelShell panel (anchor: top, below the island) with a list + "new reminder" action. Reuses PanelShell, no new component.
- **Media slot:** dedicated media slot in the right island, zero-width when idle, grows when playing — not a replacement for time / weather / battery / agents. Keeps time as the stable anchor. Media now playing is elegant, simple, understated, only when playing.
- **Privacy glyphs:** define them now (mic, screen-record, remote), mic wins if two are active, others stack to its left.
- **Fullscreen hide:** unmount the bar (zero draw) rather than opacity 0, ears black, 50ms debounce so a fullscreen toggle doesn't flicker. Test live.
- **Notifications history spec (draft):** last 50, grouped by app, relative timestamp ("12 min ago"), clear-all + per-app clear, respects Silence.
- **Tray apps:** prefer launching the app's own menu via StatusNotifier rather than reimplementing menus; if a tray item has no menu, show it as a launcher row.
- **Volume output switching:** radio list (Bluetooth buds / wired / headphones / speakers) with Enter to select, arrows to move — keyboard-first, not a cycle.
- **Battery charging animation:** single 1.5-2s loop, soft leading edge, not a full-bar sweep. Two candidates to pick before build: (a) slow gradient drift across the filled portion, (b) subtle pulse at the fill edge. Amber at 20%, red at 10% as tokens. Time-to-empty/full: raw UPower estimate, rounded to 5 min, prefix "~".
- **Weather staleness, three states:** fresh (full opacity), stale (dimmed + "updated X min ago"), offline (dimmed + offline mark + last value). Shared Staleness helper, same for agents / updates. Weather icon: small theme-aware glyph set, 8-10 conditions, not emoji.
- **Calendar:** event dots cap at 3 per day, with "+N" affordance. Today's date is the only "active" cell at rest. Consider a "now" line in the day view.
- **Agents quiet state:** no agents running → icon at reduced opacity, no dot. Only lights up when there's something to see.
- **Copy-on-select decision gate:** (a) Wayland primary selection exists but only pastes on middle-click; (b) `wl-paste --primary` watcher → `wl-copy` bridge is the cheapest system-wide approximation, v0 experiment, measure latency; (c) Hyprland plugin is the robust path. Respect password fields — exclude xwayland / electron password inputs and Secret-typed selections. Mitigate false positives with 150-200ms debounce after selection settles, and a clipboard-history "just copied" note in notifications history. Scope is system-wide per James, browsers are the known caveat.
- **Floating window exclusions (draft for review):** portals (file pickers), dialogs (modals), fullscreen video / PiP, games, screen-share windows, `xdg-desktop-portal` surfaces, anything with `_NET_WM_WINDOW_TYPE_DIALOG`. Cmd+L remembers the previous formation per window (toggle), not force dwindle.
- **Verified live checklist per stage:** visual, keyboard, theme-switch, fullscreen, reload-without-refresh. Cheap, repeatable, reversible. shell.json backups: timestamped, keep last 10, in `~/.local/state/omarchy/bar-backups/`.
- **Shared rail (test in mock):** keep two islands but give them a shared visual "rail" (a 1px baseline) that visually connects them under the notch — reinforces "one bar, two islands" without faking screen under the camera. Test in the static mock, do not lock it yet.

### Not adopted / rejected
- **Recording timer:** speculative — screen record was dropped from the drawer, no recorder identified. Drop unless another recorder is named.
- **Calendar create/edit:** keep read-only event dots. Do not re-open.
- **Option vs Alt (Q12):** already answered — Option *is* Alt on a Mac keyboard, Hyprland uses Alt, symbol is ⌥.
- **Per-panel Option+P vs a single global pin toggle:** keep Option+P for now, consistent with the pickers. Global toggle stays as an alternative, not adopted.
- **Close motion reverse bounce:** test live, do not lock yet (see PanelShell above).
