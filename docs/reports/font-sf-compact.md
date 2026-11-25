# SF Compact Display for the islands, toasts and pickers (2026-11-25)

**Installed:**
- **Source:** `~/Downloads/sf-compact-display-medium.zip`, which held one TrueType file (`SF Compact Display Medium.ttf`) and a readme. It was extracted into its own empty folder, and only the `.ttf` was copied to `~/.local/share/fonts/`.
- **Cache:** rebuilt with `fc-cache -f`.
- **Check:** `fc-list | grep -i "SF Compact"` shows `SF Compact Display:style=Medium`.

**Wired through one token:** `[ui] font = "SF Compact Display"` in `~/.config/omarchy/shell.toml`, read through `jimmy.shared/Tokens.js`:
- **`jimmy.bar`:** island text (time, workspace numbers, app name, battery %). Icon glyphs (weather, lights, agents) stay on the Nerd Font, which SF Compact does not cover.
- **`jimmy.osd`:** toast text. The toast's icon is measured and drawn in the Nerd Font, as before.
- **`jimmy.emojis` and `jimmy.clipboard`:** picker text. Emoji glyphs fall back to the colour emoji font as before.
- **Unset token:** removing it returns each surface to its previous Omarchy font.
- **Not changed:** the launcher, apps window and reminders are not covered by this request. Adding them is the same one-line `fontFamily` change.

**Verified live** after `omarchy restart shell`, on its own:
- **Islands and toast:** screenshots show the island text and the toast's "30%" in SF Compact Display, with the icons unchanged.
- **Picker:** the clipboard picker renders in it.
- **Journal:** no errors; all nine hosted panels are still loaded.

**Build rule:** hold and stay-awake at the start; `allow-idle` and `release` at the end. `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`.

**Not in the repo:** the font file. It is Apple's licensed font. Restore it by reinstalling from the zip into `~/.local/share/fonts/` and running `fc-cache -f`.
