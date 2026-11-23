# Plugins to revisit

Not a tweak note. A standing list of Omarchy plugins worth another look —
things seen and parked, not installed. Add a line when something catches the
eye; delete it once it is installed (and written up as its own tweak note) or
ruled out.

Each entry: what it is, why it is here, and what would have to be true to act
on it.

---

## Hydropunk

- **Id:** `terrizoaguimor.hydropunk`
- **Listing:** https://plugins.omarchy.org/plugin.html?id=terrizoaguimor.hydropunk
- **Added:** 2026-11-12
- **Why:** flagged to keep an eye on.
- **What it is:** unconfirmed. The listing page is a JavaScript app, so
  fetching it without a browser returns only its shell — which renders
  "Plugin not found / This plugin does not exist in the current catalog"
  regardless of the id, so that is not evidence either way.
  `https://plugins.omarchy.org/plugins.json` returns 404, and
  `https://github.com/terrizoaguimor/hydropunk` is 404, so the repo is named
  something else, owned by someone else, or private. The name suggests a
  theme, and the listing's breadcrumb showed a "Theme" category, but that
  looked like generic page furniture rather than this plugin's own kind.
- **To check:** open the listing in a real browser, or look for the catalog
  data in https://github.com/omacom/omarchy-plugin-marketplace.
- **Before installing:** it draws something, and on this machine the top
  centre of the screen is behind the MacBook's camera housing — see
  `island-notch`-style problems. Check where it paints before enabling.

---

## Fillet

- **Id:** `io.github.xtrimsystems.fillet`
- **Repo:** https://github.com/xtrimsystems/fillet (id implies; not verified)
- **Added:** 2026-11-12
- **Why:** installed and removed the same morning. The curves were fine — it
  attaches bar popups flush to the bar so the two read as one surface. What
  killed it was the always-on `barEdge` line: a full-width accent-orange rule
  across the screen, paid for full-time and collected on only while a popup
  is open. Thinning it to 1 logical px (via `[popups] border-width` in
  `~/.config/omarchy/shell.toml`) was not enough; 1 logical px is its floor
  without patching the plugin.
- **The untried middle option:** keep the plugin, turn only the line off —
  `omarchy bar set io.github.xtrimsystems.fillet barEdge false --json`, then
  `omarchy restart shell`. That keeps the curved popup attachment and drops
  the rule entirely. Worth one evening if the stock popups ever look detached.
- **Also unexplored:** `attachMenu`, which hangs the Omarchy menu off the bar
  under its icon instead of opening it centred with a screen overlay. Note
  the launcher button is now Glyph Menu, so check that still works with it.
- **Reinstall:** `omarchy plugin add https://github.com/xtrimsystems/fillet`

---

## Notch Bar

- **Id:** `io.github.crumble21.notch-bar`
- **Repo:** https://github.com/crumble21/omarchy-notch-bar
- **Listing:** https://plugins.omarchy.org/plugin.html?id=io.github.crumble21.notch-bar
- **Added:** 2026-11-12 — installed, used for about twenty minutes, reverted
- **Why it is worth coming back to:** it is the *right* answer to the notch on
  this machine. A fork of Omarchy's own bar that splits the top bar into two
  islands around the camera housing: nothing drawn or clickable behind the
  camera, island backgrounds following the housing's rounded corners, stock bar
  everywhere else. v0.1.0, MIT, by Connor Rumble. It rendered perfectly and
  left the widget layout alone, `jimmy.workspaces` included.
- **Measured here:** gap of 252 physical px centred on 1727 (screen centre
  1728) — i.e. notch `width` 348 minus `bleed` 48 per side, as documented.
  Whether 348 matches the real 16" housing was never confirmed by eye; the
  author's table marks the 16" as an estimate and only the 14" as calibrated.

### Why it was reverted

**It is forked from Omarchy 4.0.2; this machine runs 4.5.0-3.** The fork ships
its `upstream-base/`, so the drift is measurable: its base differs from the
installed bar by ~2515 lines, with only 249 lines of its own notch changes on
top. Three layout sections that 4.5.0 has simply do not exist in a 4.0.2 bar:

| Section | 4.5.0 | the fork |
|---|---|---|
| `left` / `center` / `right` | yes | yes |
| `tray` (the hidden drawer) | yes | **no** |
| `centerBegin` / `centerEnd` | yes | **no** |

So seven widgets parked in those sections stopped rendering — superwhisper
panel, omapop, omarchy-fx (tray), indicators (centerBegin), elsewhen, weather,
microphone, system-update (centerEnd) — and `SUPER + N` went dead, because the
scratchpad lived in the tray and the bar's `findPanelWidget` had no tray to
look in. That last one is what gave the game away.

**The author's `sync-upstream.sh` cannot close the gap unattended.** Tried in a
throwaway copy: 8 conflicts, 349 lines, one conflict per hunk of the notch
logic — upstream rewrote exactly the regions the fork changes. That is a port,
not a merge, and not something to hand-resolve into a 3,500-line QML bar that
runs all day.

### What would have to be true to come back

The fork rebased onto 4.5.x (or whatever is current), so the bar underneath has
the tray drawer and the centerBegin/centerEnd sections. Then it is a
one-command install again. Check `UPSTREAM` in the repo — it records the
Omarchy version the fork was last synced from.

- **Still installed but inactive.** `omarchy bar use io.github.crumble21.notch-bar`
  re-activates it, `omarchy bar use omarchy.bar` goes back. Remove entirely with
  `omarchy plugin remove io.github.crumble21.notch-bar`.
- **Worth sending upstream:** the version-drift finding above, as a feature
  request to rebase. The author ships a sync tool, so they intend to track
  upstream.

---

<!-- Template for new entries:

## Name

- **Id:** `author.plugin`
- **Listing:** https://plugins.omarchy.org/plugin.html?id=author.plugin
- **Added:** YYYY-MM-DD
- **Why:** what made it interesting
- **What it is:** kind, what it does
- **To check:** what to confirm before installing

-->
