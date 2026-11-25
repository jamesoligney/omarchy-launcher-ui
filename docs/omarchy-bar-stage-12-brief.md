# Omarchy Bar — Stage 12 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–11 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-12-brief.md` first, then build Stage 12 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently green edition. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** island height 44, bar height 48, SF Compact Display Medium everywhere with no bold, text 20px, toast attached to right island with `toast.gap` 0, battery number only (no pill), calendar leader C, quick icons slide out left outside the island, Super+D hints only, leader letters dissecting the bottom outline, leader hints switchable (`leader.hints`), sparks hybrid ember/lightning (good now — do not touch), islands wide (padding-x 44 / spacing 48 — leave here for now, do not pull back yet).

## 1. Third island — Wi-Fi + Bluetooth, persistent, far right, smaller
- **Wi-Fi and Bluetooth are staples, and they are missing.** They are not often accessed, but it is helpful when they are visible. They need to be persistent, or at least more accessible — not hidden in a pop-out.
- **Why not the drawer / panel:** the drawer / panel we were going to build is a pop-out, not persistently visible. It pops out and then it can be persistent when pinned, but when it is closed you cannot see Wi-Fi / Bluetooth status. That does not solve the visibility need.
- **Build a third island.** Split the right side into two islands:
  - **Main right island (as now):** time, weather, battery, agents mark, lights, quick strip to its left.
  - **Far right island (new, smaller):** Wi-Fi + Bluetooth + microphone — the very functional, staple pieces.
- **Far right island design:**
  - **Same shape as the main islands — do not make the island itself smaller.** Same height (44), same radius, same glass, same glow, so it fits in with the primary island. Only the *icons inside it* are smaller.
  - **Icons significantly smaller, staggered to fit more in.** The icons in this island are status lights only — they are either lighting up or staying grayed out, going on and off automatically through keybinds. Click targets are not a concern. So the icons can be significantly smaller than the main island's 20px (try ~12-14px), and they can be **staggered** — e.g. two offset rows within the 44px height — so more icons fit in the same width. That is the concept: a dense, quiet status strip, same island shape, smaller staggered lights inside it.
  - Start with Wi-Fi + Bluetooth + mic at that smaller staggered size, and leave room in the layout for more status lights in the same staggered grid. Do not fill it just to fill it — build the staggered layout so more can be added cleanly later.
  - **Segmented, not two separate pills — confirm this understanding:** the two right islands are separate islands, but they need to connect. The middle joint between them needs to be square, or not as soft as the outsides, so it looks like **one island divided into two pieces**, and that division is more square than the outsides, which are the more rounded radius (13). In other words: outer corners rounded 13, inner corners facing each other square / ~0-2px. A small gap between them, with the glow spilling into that empty area between the two — James thinks that will be okay, and Claude should confirm it reads that way live. If the square inner corners do not read as one divided island, state that and try the next clean approach — do not just leave two fully rounded pills floating apart.
  - Position: far right, in the right ear, to the right of the main right island, with a gap between the two islands. Both islands stay centred in their own space — do not let the far right island push the main right island off centre in its ear, or state how the geometry is split.
  - Wi-Fi icon: shows connection status / signal, quiet when connected, muted / urgent when disconnected. Click opens the network / Wi-Fi panel.
  - Bluetooth icon: shows connection status, quiet when connected / on, muted when off, accent / lit when a device is connected. Click opens the Bluetooth panel.
  - **Microphone icon moves here, from the main right island.** Rather than disappearing and reappearing, it is **persistent but grayed out**, then activates when James is using the mic (accent / lit, as before, rightmost / primary when active). Click mutes / toggles, as before. It no longer pops in and out of the main island.
  - All three icons are status first, action second — click to open the panel / toggle, not to toggle on/off blindly.
  - Leader: give Wi-Fi, Bluetooth, and mic leader letters in Super+D, on the bottom outline like the others, and state them in the report. Check for collisions with the existing leader keys (1-9, W, C, B, A, Q, Esc) — B is already battery, so do not reuse B for Bluetooth without a collision check and a clear decision.
  - **Do NOT add screen recording or remote session.** James does not use them, they do not belong here. Other status lights that could fit in the staggered grid later: audio output, stay awake, night light, silence — all the same pattern, persistent grayed out, lit when on, toggled by keybind. Do not add them unasked in this stage — build the staggered layout, start with Wi-Fi + Bluetooth + mic, and state in the report how many more staggered lights would fit.
- **Do not build the drawer in this stage.** The drawer / panel is a later phase. This stage is only the third island.

## 2. Corner radius — 11 → 13
- **Island corner radius: 11 → 13.**
- James agreed: the islands are taller now (44, not 38), so the rounded corners look less pill-like, and they are significantly wider. 13 on a 44px island is ~30% of height, not the ~37% that 14 was on a 38px island.
- Apply to all islands (including the new far right island) and to every surface in the island language that shares the radius token (toasts, notifications, reminder card, PanelShell, adopted panels), so the system keeps one radius. State in the report which surfaces changed.

## 3. Glow — mask it, outside only, middle stays dark / glassy
- **The glow now seems injected into the centre of the bar as well. James does not like that.**
- **Fix:** glow must emanate from the outline, not spill into the middle. The middle was just dark / glassy, see-through to the wallpaper — that is what James wants back.
- **Do the mask Claude flagged in Stage 11 and did not do unasked:** cut the glow out under the fill, so the glow is only outside the outline. The fill stays neutral / glassy, the halo is outside only.
- Glow values stay at Stage 11 (alpha 0.32, blur 20) unless the mask changes how they read — if so, retune and state the new values. Do not make it a brighter outline again; it must be a halo fading to nothing.
- Apply to all three islands, and to toasts / panels / PanelShell if they share the glow — same language, middle dark / glassy everywhere.

## Out of scope
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks — good now, do not touch.
- Island width — leave padding-x 44 / spacing 48 here for now, do not pull back yet.
- Toasts, quick icons, hover pop-out, leader letters — no change except as in §1–3 (third island, radius, glow mask).

## Verify live, then report
- Third island is live, far right, smaller, Wi-Fi + Bluetooth + mic persistent and visible, clicks open their panels / toggle, leader letters stated, no collisions. Inner corners square, outer corners 13, reads as one island divided into two, glow spilling into the gap between them.
- Corner radius is 13, reads as rounded square, softer than 11, not a pill.
- Glow is outside only — halo emanating from the outline, middle dark / glassy, no spill into the centre.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-12-report.md`, commit, push, present the commit hash only.
