# Parked ideas

Not plugins (those live in `plugins-to-revisit.md`) and not finished tweaks.
Things we decided to table. Each entry: what it is, where it stands, and what
would have to be true to pick it up. Delete an entry once it is done (and
written up as its own tweak note) or dropped.

---

## Playing-aware YouTube idle inhibit

- **Added:** 2026-11-16
- **Status:** tabled. The static `idle_inhibit` window rule was reverted (see
  `yt-idle-inhibit.md`).
- **Goal:** block the screensaver and lock only while a YouTube video is
  actually playing. Paused videos and idle tabs must let it start.
- **Approach:** a small helper that watches MPRIS, holds a Wayland idle
  inhibitor only while playback is `Playing` and the media URL is a
  `youtube.com` one, and releases it on pause or when the player goes away.
- **Findings so far:**
  - Helium is Chromium-based and registers as
    `org.mpris.MediaPlayer2.chromium.instance…`. Its `PlaybackStatus` is
    readable with `busctl --user` (it reads `Stopped` when nothing plays).
  - Floorp (Firefox-based) was not running, so its MPRIS registration is
    unverified.
  - `playerctl` is not installed.
- **To pick up:** confirm Helium's `PlaybackStatus` reads `Playing` during a
  video and `Paused` after pausing. Open Floorp, play a video, and check it
  registers too. Then decide whether to install `playerctl` or read D-Bus
  directly.

---

<!-- Template:

## Name

- **Added:** YYYY-MM-DD
- **Status:** tabled, why
- **Goal:**
- **Approach:**
- **To pick up:**

-->
