# klack: cherry-mx-red keycode rename

**Added:** 2026-11-11

The `cherry-mx-red` sound pack shipped with Mechvibes-style filenames (`1.wav`,
`30.wav`, `57419.wav`). klack only recognises its own key tokens (`key_a.wav`,
`key_space.wav`), so all 84 numeric files were landing in klack's unmapped
fallback pool: every key picked a random sound and nothing was per-key.
Renaming them to klack tokens restored per-key sounds — spacebar, enter and
backspace are now audibly distinct from letters.

The pack was worth fixing: 83 of its 87 files are genuinely distinct audio, so
these were real per-key recordings klack simply could not address.

## What changed

Only filenames inside `~/.config/klack/cherry-mx-red/`. 84 files renamed, no
file added, removed or edited. `default0.wav`, `default1.wav` and
`default2.wav` were left alone — they remain the fallback for keys with no
recording of their own.

The mapping was built from `/usr/include/linux/input-event-codes.h`, filtered
to names `klack --list-keys` accepts (240 usable tokens), **not** from the line
numbers of that command's output. That distinction matters: the kernel leaves
code 84 unnamed, but klack prints a dense list with no placeholder, so naive
line-number arithmetic drifts by one from code 85 onward. It produced two wrong
answers before being corrected:

```
87.wav -> key_f11   (line-number arithmetic said key_f12)
88.wav -> key_f12   (line-number arithmetic said key_ro)
```

Codes at or below 83 were unaffected. The low range came out as a clean QWERTY
layout (30 -> `key_a`, 44 -> `key_z`, 57 -> `key_space`), which is good
confirmation the pack used plain evdev codes.

The twelve high-numbered files were Mechvibes extended scancodes, decoded as
`3584 + scancode` and `57344 + scancode`:

```
3640 -> key_rightalt    3663 -> key_end        57416 -> key_up
3655 -> key_home        3665 -> key_pagedown   57419 -> key_left
3657 -> key_pageup      3666 -> key_insert     57421 -> key_right
3675 -> key_leftmeta    3676 -> key_rightmeta  57424 -> key_down
```

All 84 targets were checked against `klack --list-keys` before anything moved:
zero collisions, zero unmapped files. Numeric source names cannot collide with
`key_*` targets, so the rename was safe in a single pass.

## Check it is working

```bash
ls ~/.config/klack/cherry-mx-red | grep -c '^key_'   # expect 84
ls ~/.config/klack/cherry-mx-red | grep -cE '^[0-9]+\.wav$'  # expect 0
systemctl --user restart klack.service
journalctl --user -u klack.service -n 1 -o cat        # expect "Loaded 87 sounds successfully"
```

Then type: space, enter and backspace should each sound different from a letter.

## Undo

Pre-rename copy, untouched:

```bash
rm -rf ~/.config/klack/cherry-mx-red
mv ~/.config/klack/cherry-mx-red.backup-20261111 ~/.config/klack/cherry-mx-red
systemctl --user restart klack.service
```

Verified on 2026-11-11: the backup holds all 87 files with the original 84
numeric names. Note that `klack-pack` deliberately skips any pack directory
whose name contains `backup`, so the rollback copy never appears as a
selectable pack while it sits there.

## Worth knowing

- klack requires every file in a pack to share one channel count and sample
  rate. This pack is uniformly 16-bit stereo 44100 Hz, which is why it loads
  cleanly. A mismatched file is a silent failure, not an error.
- klack's loaded-sound count does not always equal the file count. This pack
  reports 87 of 87, but `soundpacks/cyberpunk` reports 23 of 24 distinct,
  non-empty, uniform-format files. The count is a health signal, not an audit.
- The pack's provenance was inferred from its filenames and the layout they
  produced, not from a manifest. A systematic error is very unlikely given the
  QWERTY ordering, but a single odd-sounding key would be worth checking
  individually.

See also: [klack-pack-switcher.md](klack-pack-switcher.md).
