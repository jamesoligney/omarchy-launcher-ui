# klack: sound pack switcher

**Added:** 2026-11-11

`klack-pack` switches klack's sound pack from the terminal or the Omarchy menu,
instead of hand-editing the systemd drop-in and restarting the service.

```bash
klack-pack              # list packs, * marks the active one
klack-pack get          # name of the active pack
klack-pack set clicky   # switch
klack-pack next         # cycle to the next pack (good for auditioning)
klack-pack menu         # Omarchy picker, pre-selected on the active pack
```

## What changed

**New file:** `~/.local/bin/klack-pack` (executable). Nothing else on the
system was modified by it; it writes only the drop-in below, at runtime.

**One block** appended to `~/.config/omarchy/extensions/omarchy-menu.jsonc`,
adding a row under Setup -> Typing, next to Omarchy's own Keyboard Layouts:

```jsonc
  // klack-pack: begin
  "setup.typing.sound": {"icon":"","label":"Keyboard Sound", ... },
  // klack-pack: end
```

The row uses `"when":"command -v klack-pack"`, so it hides itself if the script
is ever removed, and `"checked":"systemctl --user is-active --quiet
klack.service"`, so it shows a checkmark while keyboard sound is actually on.

Pre-edit backup of the menu file: `omarchy-menu.jsonc.bak.*` in the same
directory.

## How it works, and why it works that way

klack reads its configuration once at startup — env vars, no runtime config and
no IPC — so switching packs means rewriting
`~/.config/systemd/user/klack.service.d/override.conf` and restarting the unit.
The script does that, and three details are load-bearing:

- **`systemctl --user daemon-reload` before the restart.** systemd caches
  drop-ins; a restart on its own would reuse the old `KLACK_SOUNDPACK`.
- **Only the `KLACK_SOUNDPACK` line is rewritten.** Any other setting in the
  drop-in is preserved, so adding `KLACK_VOLUME` or `Restart=` later is safe.
- **The load report is anchored to a journal cursor** taken *before* the
  restart, then read back with `--after-cursor`. A time window such as
  `--since -15s` is not sufficient: two switches in quick succession both fall
  inside it, and the second reports the first pack's sound count. This was a
  real bug during development, caught because restoring an 87-sound pack
  reported 28 — the previous pack's number.

Playback volume survives the restart on its own, so switching packs does not
disturb `klack-volume`: that script sets per-stream PipeWire volume, and
WirePlumber persists it keyed on `application.name`.

Packs are discovered under `~/.config/klack` and `~/.config/klack/soundpacks` —
directories holding at least one `.wav`, or `.tar.gz` archives. Any name
containing `backup` is skipped, so rollback copies never appear as choices.

## Check it is working

```bash
klack-pack list        # expect 5 packs, * on cherry-mx-red
klack-pack set tactile && klack-pack set cherry-mx-red
```

Each switch should print its own correct count (`tactile` 7, `cyberpunk` 23,
`mechanical` 28, `cherry-mx-red` 87). If two consecutive switches report the
same number, the cursor anchoring has regressed.

Menu row: `omarchy menu refresh`, then Setup -> Typing -> Keyboard Sound, or
search "klack" / "soundpack" in the menu. The active pack carries a ✓ and the
others a ○.

Note there are two independent ✓ marks in play, which is intentional: the
`Keyboard Sound` row itself shows one when `klack.service` is running (sound is
on at all), and inside the picker one marks the active pack. Dropping the
row's `"checked"` field removes the former if that reads as ambiguous.

## Undo

**Remove the menu row only.** Delete the `// klack-pack: begin` …
`// klack-pack: end` block from
`~/.config/omarchy/extensions/omarchy-menu.jsonc`, then `omarchy menu refresh`.
Or restore the backup, which also drops any later edits to that file:

```bash
cp ~/.config/omarchy/extensions/omarchy-menu.jsonc.bak.* ~/.config/omarchy/extensions/omarchy-menu.jsonc
omarchy menu refresh
```

**Remove the script too.**

```bash
rm ~/.local/bin/klack-pack
omarchy menu refresh
```

Verified on 2026-11-11: with `klack-pack` off `PATH` the row's `when` condition
fails, so the row disappears on its own and leaving the jsonc block in place is
harmless.

Neither undo touches klack itself or the active pack. The pack in effect is
whatever is in the drop-in at the time, and it keeps working:

```bash
cat ~/.config/systemd/user/klack.service.d/override.conf
```

To go back to the original hand-written drop-in, set the pack you want with
`klack-pack set <name>` before removing the script, or edit that file directly
and run `systemctl --user daemon-reload && systemctl --user restart klack`.

## Worth knowing

- JSONC here tolerates a trailing comma before the closing brace — Omarchy's
  own `omarchy-menu.jsonc` ends that way. `jq` will reject the file for that
  reason; that is `jq` being strict JSON, not a broken config.
- The menu picker is `omarchy-menu-select`, which returns the chosen label on
  stdout. It also supports `--on-change` for applying a choice as you move
  through the list, which would give live audition; that is documented as
  geared to `--multiple`, so the script uses the plain single-select path.
- **`--selected` draws nothing in a single-select list.** `Menu.qml:667` only
  renders the ✓/○ markers when `multiple` is true, so passing `--selected` on
  its own marks nothing visibly. The active pack is instead marked through the
  glyph column: an option may lead with `"<glyph><TAB><label>"`, and the menu
  shows the glyph but never returns it, so the choice still arrives as the bare
  pack name. The script passes ✓ for the active pack and ○ for the rest, which
  is the same vocabulary the built-in multi-select uses. `--selected` is still
  passed, harmlessly, in case it gains meaning in single mode later.
- `klack --list-keys` prints 240 usable key tokens plus four group tokens
  (`modifier_keys`, `arrow_keys`, `function_keys`, `printable_keys`). Group
  files are a cheap way to author a pack without 80 recordings.

See also: [klack-soundpack-keycodes.md](klack-soundpack-keycodes.md).
