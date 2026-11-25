# Omarchy Bar Restructure — Design Brief v1
## For refinement, not for building yet

**Goal:** A total restructure of the Omarchy bar / control system. Not a "standard" menubar. A prominent, elegant feature of the GUI, built from a small set of critical elements, live and keyboard-first.

**Direction decided 2026-11-24:** Try **top first**. Gut says top. Bottom remains the fallback — James works mostly in a floating window or a pair side-by-side, typically closer to the bottom of the screen, and the 16" screen (3456x2234 @120Hz, scale 2, logical 1728x1117) is large enough that reserved space is not missed. Test top-first live, judge by feel, keep bottom as an option.

## Critical elements — the core set

At rest, only these. Everything else is hidden until summoned.

1. **Workspaces** — the element with the most movement, current iteration liked. Occupied only, active highlighted, stable order. Window name beside it: pair down to **just the app name** — titles are long and change constantly, making the pill breathe. If it is a web app, show the web app name. *Open question to iterate on: how does the system distinguish a web app window from a browser tab?*
2. **Time** — **time only at rest, HH:MM, no seconds, no AM/PM.** "3:04" and nothing else. Date lives in the panel, with the calendar. Tabular numbers preferred so centre width stays stable.
3. **Weather** — rest: temp + icon. Panel: forecast, location, last-updated time. It is a remote check with no push API, so it must be honest about staleness, not pretend to be live.
4. **Battery** — rest: % + icon. Panel: power profile, low-battery state. Live via UPower signals — see `jimmy.shared/PowerEvents.qml` (converted 2026-11-24, audit `009de90`). This is the model for the others.
5. **Agents — mission control** — rest: an agents icon / usage indicator. Panel, two modes: **pop** for a quick check (what is running, usage, Esc to dismiss), and **summon + pin for persistence** when doing heavy AI work (stays live, updates as agents run, close when done). Pin idea is already in muscle memory from the pickers (⌥P).

## The bar itself — top-first, dual pill / islands

- The notch at the top is **physical dead pixels** — camera/sensors, no screen there, cannot be overlaid. Anything drawn in it is cut off.
- What can be owned is the space **around** it. The top strip is already reserved (~44px across the whole top, to keep windows below the notch). Use that space.
- Design to explore: **dual pill / islands splitting the notch** — a bar with a hole in the middle for the notch. Left pill workspaces, right pill weather / battery, time just below the notch, or a single wide pill with a notch-shaped gap. Location decisions are secondary, pending functionality.
- One central pill / bar is still the hub idea: panels pop from it, keybinds summon them.

## Panels — one motion, different anchors

- All panels use the **identical bounce animation** to visually unify the system: the shared `jimmy.shared/CardMotion.qml` squash-and-stretch (X start 0.80, ω24, ζ0.40, peak 1.050; Y start 0.70, ω20, ζ0.46, peak 1.058), 160ms fade, 100ms close.
- Motion = system identity. Anchor = location. Pill pops bounce from the centre / bar, side panels bounce from the edge they are attached to. No second animation to learn.
- Panels feel **attached to screen edges** where they live, not floating in the middle for no reason.

## Side drawer — the secondary layer

- Tray and anything not committed to the primary still has to be accessible, but not visible at rest.
- A **large-ish panel animating from the right, full-height initially**. Height depends on what populates it. Larger icons showing **live states** (Bluetooth, volume, network, etc.).
- Contents are **uncertain by design** — James will not know he needs many tray items until he needs them, so the drawer must be fast to summon, discoverable, and keyboard-navigable (arrows across tiles, Enter to toggle / open, Esc to close). Big icons for mouse, not mouse-only.
- Each tile: read live state at a glance, tap / key to toggle or open its detail.

## Interaction — keyboard first

- Every element gets a keybind that pops its panel. Panels are keyboard-first, mouse optional. No mouse-only elements — same standing rule as the pickers. Hints visible on screen.
- One action per panel, obvious from the keyboard. If the main thing cannot be done in two keypresses, the panel is too complicated.
- Existing keybinds to avoid colliding with: Super+Space launcher, Super+Ctrl+E emoji, Super+Ctrl+V clipboard, Alt+letter app binds, Alt+number chip keys in pickers, Super+Return Ghostty.

## Data — live, not polling

- Build on the bar polling audit (`009de90`, 2026-11-24): almost nothing in the bar was polling a local value. Stock widgets are already on Quickshell service APIs (Pipewire, UPower, SystemTray, Bluetooth, NetworkManager, Mpris, Hyprland events, ToplevelManager) or pushed by IPC. The one real standing poll, battery 30s, was converted to `PowerEvents`.
- New work must use the actual Quickshell APIs, not `Process` + Timer polling. Remote checks (weather, updates, agent usage) have no live source — say when they were last fetched.
- Shared logic in `jimmy.shared`, not copied per widget, so it carries into the restructure.

## Visual / code standards

- Futuristic, elegant / simple, pinnacle of functionality — translated to rules, not adjectives: only the core at rest; live data, no polling; one shared panel shell; same glass, same motion, same typography, theme-aware (current theme Afterburn, no hardcoded palette).
- Code standard, standing rule: efficient, clean, and light, always.
- Standing rule, every pass: interrogate the rest of the UI first and apply the same learning everywhere it applies — never fix one picker / button / panel and leave the same pattern elsewhere.

## Related, not in the bar itself

- **Default window open position:** windows are mostly bigger than James wants. Most time is in a floating window or a pair side-by-side. The default open position should be a **specified floating window — dimension and location he chooses** — not full-screen / tiled large. Capture this as a requirement alongside the bar, not as an afterthought.
- **Dock:** next focus after the bar. Thinning the icons — unlikely to use most of them. Refactor toward visual / keyboard-driven. Constraint: the dock's own apps button cannot be changed without cloning the dock, and a dock clone does not get `shell.appLibrary` or `shell.shellConfig` (see `efd8834`), so cloning breaks the grid and the dock settings. No apps icon is currently visible on the dock, and everything opening from it already bounces.

## Open questions (for the refining agent)

- Top-first: dual islands flanking the notch, or a single wide pill with a notch gap, or time below the notch? Which reads best live?
- Keybind map for the 4 core panels + agents + side drawer — what is free, what is memorable, what collides?
- Web app name vs browser name — how is it detected, what are the test cases?
- Side drawer contents — what tiles earn a place, what is toggle vs detail, what can be dropped entirely?
- Agents mission control — what does the live panel show (running agents, status, token / allotment remaining, time to renewal, recent activity)? What does the pop show vs the pinned version?
- Default floating window — what dimension / location, and does it apply to all windows or only certain apps?

## Instructions to the refining agent

You are refining this brief, **not building yet**. Talk theory first.

1. Read this brief, `AGENTS.md`, the spec in `docs/omarchy-launcher-rice-spec.md`, and the latest report in `docs/reports/iteration-3b-claude-report.md` first.
2. **Ask clarifying questions** where the brief is ambiguous, and **make new suggestions** based on the brief — new elements, better interactions, risks, alternatives, things we have missed. Do not just repeat the brief back.
3. Present a refined v2 brief: keep what is decided, mark what is still open, and list your questions and suggestions separately so James can answer them.
4. Do not write code, do not change live config, do not restart the shell. This pass is words only.
5. Save the refined brief to `docs/omarchy-bar-restructure-design-brief-v2.md`, commit, and push with the hash in your final message.
