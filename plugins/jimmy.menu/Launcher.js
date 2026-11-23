.pragma library

// Launcher data helpers for jimmy.menu.
//
// Keybind hints. Source of truth is ~/.config/hypr/bindings.lua: the menu
// reads that file on every open (parseBindingsLua) and merges it over the
// live Omarchy table from `omarchy menu keybindings --print` (stock defaults,
// Hyprland's active binds). The maps below only say which launcher row a
// bind description belongs to. A row whose target is not listed, and whose
// name matches no bind description, gets no hint.

var bindTargets = {
  // App ids (desktop-entry id, without .desktop) and names.
  apps: {
    "com.mitchellh.ghostty": "Ghostty",
    "helium": "Helium",
    "muse.ai": "Muse.AI",
    "one.ablaze.floorp": "Floorp",
    "orca": "Orca",
    "zen": "Zen",
    "chromium": "Browser",
    "com.thisisgm.flea": "File manager",
    "obsidian": "Obsidian",
    "omawrite": "Omawrite",
    "spotify": "Music",
    "omacalc": "Calculator",
    "1password": "Passwords",
    "chatgpt": "ChatGPT",
    "youtube": "YouTube",
    "whatsapp": "WhatsApp",
    "google messages": "Google Messages",
    "google photos": "Google Photos",
    "google maps": "Google Maps",
    "superwhisper": "Superwhisper: toggle",
    "vicinae": "Vicinae"
  },
  appNames: {
    "ghostty": "Ghostty",
    "chromium": "Browser",
    "flea": "File manager",
    "obsidian": "Obsidian",
    "omawrite": "Omawrite",
    "spotify": "Music",
    "omacalc": "Calculator",
    "1password": "Passwords",
    "chatgpt": "ChatGPT",
    "youtube": "YouTube",
    "whatsapp": "WhatsApp",
    "google messages": "Google Messages",
    "google photos": "Google Photos",
    "google maps": "Google Maps",
    "superwhisper": "Superwhisper: toggle",
    "vicinae": "Vicinae"
  },
  // Omarchy menu item ids.
  menu: {
    "apps": "Apps",
    "system": "System menu",
    "system.lock": "Lock system",
    "appearance.theme": "Theme menu",
    "appearance.background": "Background switcher",
    "appearance.top-bar.hide": "Toggle top bar",
    "appearance.top-bar.show": "Toggle top bar",
    "learn.keybindings": "Keybindings",
    "learn.tmux-keybindings": "Tmux keybindings",
    "learn.herdr-keybindings": "Herdr keybindings",
    "trigger.capture": "Capture menu",
    "trigger.capture.screenshot": "Screenshot",
    "trigger.capture.screenrecord": "Screenrecording",
    "trigger.capture.screenrecord.stop": "Screenrecording",
    "trigger.capture.text": "Extract text (OCR) from screenshot",
    "trigger.capture.color": "Color picker",
    "trigger.clipboard-history": "Clipboard manager",
    "trigger.reminder.set": "Set reminder",
    "trigger.share": "Share",
    "trigger.toggle": "Toggle menu",
    "trigger.hardware": "Hardware menu",
    "trigger.toggle.idle-lock-on": "Toggle locking on idle",
    "trigger.toggle.idle-lock-off": "Toggle locking on idle",
    "trigger.toggle.notifications-on": "Toggle silencing notifications",
    "trigger.toggle.notifications-off": "Toggle silencing notifications"
  }
}

// One-line subtitles. The menu JSONC has no description field, so the common
// rows get a sentence here; everything else falls back to its parent path.
var details = {
  "apps": "Applications on this system",
  "launcher.bind": "Give an app an Alt + letter shortcut",
  "learn": "Documentation and keybindings",
  "appearance": "Theme, background, fonts, and bar",
  "trigger": "Capture, toggles, and sharing",
  "setup": "Configure this machine",
  "install": "Install software",
  "remove": "Uninstall software",
  "update": "Update Omarchy and hardware",
  "about": "System information",
  "system": "Lock, suspend, restart, or shut down",

  "system.screensaver": "Start the screensaver",
  "system.lock": "Lock the screen",
  "system.suspend": "Suspend to RAM",
  "system.hibernate": "Hibernate to disk",
  "system.logout": "Sign out of the session",
  "system.reboot": "Restart the computer",
  "system.shutdown": "Power off the computer",

  "appearance.theme": "Change the desktop theme",
  "appearance.background": "Change the wallpaper",
  "appearance.font": "Change the system font",
  "appearance.top-bar": "Menu bar settings",
  "appearance.top-bar.hide": "Hide the menu bar",
  "appearance.top-bar.show": "Show the menu bar",
  "appearance.windows": "Window appearance",
  "appearance.dock": "Dock settings",

  "learn.keybindings": "Show all Hyprland keybindings",
  "learn.tmux-keybindings": "Show tmux keybindings",
  "learn.herdr-keybindings": "Show Herdr keybindings",

  "trigger.capture": "Screenshots, recording, OCR, and color picking",
  "trigger.capture.screenshot": "Capture the screen",
  "trigger.capture.screenrecord": "Record the screen",
  "trigger.capture.screenrecord.no-audio": "Record without audio",
  "trigger.capture.screenrecord.desktop-audio": "Record with desktop audio",
  "trigger.capture.screenrecord.microphone": "Record with desktop and microphone audio",
  "trigger.capture.screenrecord.webcam": "Record with audio and webcam",
  "trigger.capture.screenrecord.stop": "Stop the current recording",
  "trigger.capture.text": "Copy text from a screenshot",
  "trigger.capture.color": "Pick a color from the screen",
  "trigger.capture.qr": "Show a QR code",
  "trigger.toggle": "Quick system toggles",
  "trigger.toggle.nightlight-on": "Warm the screen color at night",
  "trigger.toggle.nightlight-off": "Turn off the warm screen tint",
  "trigger.toggle.notifications-on": "Allow notification popups",
  "trigger.toggle.notifications-off": "Do not disturb: mute popups",
  "trigger.toggle.idle-lock-on": "Keep the screen awake",
  "trigger.toggle.idle-lock-off": "Allow the screen to sleep",
  "trigger.clipboard-history": "Browse the clipboard history",
  "trigger.reminder.set": "Create a reminder",
  "trigger.reminder.show": "Show all reminders",
  "trigger.reminder.clear": "Clear all reminders",
  "trigger.share": "Share the clipboard, a file, or a folder",
  "trigger.hardware": "Display, GPU, touchpad, and touchscreen",
  "trigger.emoji": "Search and insert an emoji",

  "update.omarchy": "Update Omarchy",
  "update.kernel": "Change the kernel",
  "update.timezone": "Set the timezone",

  "setup.monitors": "Configure displays",
  "setup.keybindings": "Edit your Hyprland keybindings",
  "setup.input": "Configure input devices",
  "setup.network": "Network settings",
  "setup.plugin": "Manage shell plugins",

  "install.package": "Install a package",
  "remove.package": "Remove a package"
}

var modifierSymbols = {
  SUPER: "⌘",
  SHIFT: "⇧",
  CTRL: "⌃",
  ALT: "⌥"
}

// The examples in the spec fix this order: Super+Shift -> ⌘⇧,
// Super+Ctrl+Shift -> ⌃⌘⇧.
var modifierOrder = ["CTRL", "ALT", "SUPER", "SHIFT"]

var keyNames = {
  SPACE: "Space",
  RETURN: "↵",
  ENTER: "↵",
  ESCAPE: "Esc",
  TAB: "⇥",
  BACKSPACE: "⌫",
  DELETE: "⌦",
  PRINT: "Print",
  COMMA: ",",
  PERIOD: ".",
  SLASH: "/",
  BACKSLASH: "\\",
  MINUS: "-",
  EQUAL: "=",
  BRACKETLEFT: "[",
  BRACKETRIGHT: "]",
  GRAVE: "`",
  SEMICOLON: ";",
  APOSTROPHE: "'",
  LEFT: "←",
  RIGHT: "→",
  UP: "↑",
  DOWN: "↓",
  HOME: "Home",
  END: "End",
  PAGEUP: "PgUp",
  PAGEDOWN: "PgDn",
  INSERT: "Ins"
}

function trim(value) {
  return String(value || "").replace(/^\s+|\s+$/g, "")
}

// The bind description for an app row. Mapped ids/names first; otherwise the
// row's own name, so an app-launch bind created from the menu (described by
// the app's name) finds its row without a map entry.
function targetForApp(appId, label, records) {
  var id = trim(appId).toLowerCase()
  if (id.indexOf(".desktop") === id.length - 8) id = id.substring(0, id.length - 8)
  if (bindTargets.apps[id]) return bindTargets.apps[id]
  var name = trim(label).toLowerCase()
  if (bindTargets.appNames[name]) return bindTargets.appNames[name]
  if (records && records[trim(label)]) return trim(label)
  return ""
}

function targetForMenu(itemId) {
  return bindTargets.menu[String(itemId || "")] || ""
}

function detailForMenu(itemId, parentPath) {
  var id = String(itemId || "")
  if (details[id]) return details[id]
  if (parentPath) return parentPath
  return "Command"
}

function detailForApp(genericName) {
  var value = trim(genericName)
  return value.length > 0 ? value : "Application"
}

// `omarchy menu keybindings --print` lines look like:
//   SUPER + K                           → Keybindings
// Build description -> [chords]; a description can have several chords.
function parseRecords(text) {
  var records = ({})
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]
    var arrow = line.indexOf(" → ")
    if (arrow < 0) continue
    var description = trim(line.substring(arrow + 3))
    var chordText = trim(line.substring(0, arrow))
    if (!description || !chordText) continue
    var chords = chordText.split(" / ")
    var list = records[description] || []
    for (var j = 0; j < chords.length; j++) {
      var chord = trim(chords[j])
      if (chord && list.indexOf(chord) < 0) list.push(chord)
    }
    records[description] = list
  }
  return records
}

function chordScore(chord) {
  var plus = chord.lastIndexOf("+")
  var modText = plus >= 0 ? trim(chord.substring(0, plus)) : ""
  var key = plus >= 0 ? trim(chord.substring(plus + 1)) : trim(chord)
  var keyUpper = key.toUpperCase()
  var mods = modText.length > 0 ? modText.split(/\s+/) : []

  if (/^(XF86|CODE:|MOUSE|LEFT MOUSE|RIGHT MOUSE)/.test(keyUpper)) return -1000

  var score = 100
  if (/^[A-Z0-9]$/.test(keyUpper)) score += 40
  if (keyUpper === "SPACE") score += 10
  if (["RETURN", "ENTER", "ESCAPE", "TAB", "PRINT", "BACKSPACE", "DELETE"].indexOf(keyUpper) >= 0) score -= 50
  if (["RETURN", "ENTER"].indexOf(keyUpper) >= 0) score -= 20
  if (mods.length === 0) score -= 60
  if (mods.length > 2) score -= 15 * (mods.length - 2)
  return score
}

function chooseChord(chords) {
  if (!chords || chords.length === 0) return ""
  var best = ""
  var bestScore = -100000
  for (var i = 0; i < chords.length; i++) {
    var score = chordScore(chords[i])
    if (score > bestScore) {
      best = chords[i]
      bestScore = score
    }
  }
  return bestScore > 0 ? best : ""
}

function keyLabel(key) {
  var raw = String(key || "")
  var upper = raw.toUpperCase()
  if (keyNames[upper] !== undefined) return keyNames[upper]
  if (raw.length === 1) return upper
  return raw
}

function symbolsForChord(chord) {
  if (!chord) return ""
  var plus = chord.lastIndexOf("+")
  var modText = plus >= 0 ? trim(chord.substring(0, plus)) : ""
  var key = plus >= 0 ? trim(chord.substring(plus + 1)) : trim(chord)
  var keyUpper = key.toUpperCase()
  if (/^(XF86|CODE:|MOUSE|LEFT MOUSE|RIGHT MOUSE)/.test(keyUpper)) return ""

  var mods = modText.length > 0 ? modText.split(/\s+/) : []
  var seen = ({})
  for (var i = 0; i < mods.length; i++) seen[mods[i].toUpperCase()] = true

  var out = []
  for (var j = 0; j < modifierOrder.length; j++) {
    var name = modifierOrder[j]
    if (seen[name] && modifierSymbols[name]) out.push(modifierSymbols[name])
  }
  out.push(keyLabel(key))
  return out.join(" ")
}

function bindText(target, records) {
  if (!target) return ""
  var chords = records ? records[target] : null
  var chord = chooseChord(chords)
  return symbolsForChord(chord)
}

function appBindText(appId, label, records) {
  return bindText(targetForApp(appId, label, records), records)
}

function resolveMenuBind(itemId, records) {
  var target = targetForMenu(itemId)
  var chord = chooseChord(records ? records[target] : null)
  if (!target || !chord) return null
  return { text: symbolsForChord(chord), raw: chord, source: "Hyprland/Omarchy", target: target }
}

// ~/.config/hypr/bindings.lua, read on every open. A line counts only when it
// starts with o.bind( or o.rebind( and carries a description, so comments and
// hl.unbind lines never match. Same shape as parseRecords.
var luaBindRe = /^\s*o\.(?:bind|rebind)\(\s*"([^"]+)"\s*,\s*"([^"]+)"/

function parseBindingsLua(text) {
  var records = ({})
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var m = luaBindRe.exec(lines[i])
    if (!m) continue
    var chord = trim(m[1])
    var description = trim(m[2])
    var list = records[description] || []
    if (list.indexOf(chord) < 0) list.push(chord)
    records[description] = list
  }
  return records
}

// The file's binds override the live table for the same description.
function mergeRecords(base, over) {
  var out = ({})
  var key
  for (key in base) out[key] = base[key]
  for (key in over) out[key] = over[key]
  return out
}

// Description of the bind that already owns plain Alt+<letter>, or "".
function altConflict(letter, records) {
  var want = String(letter || "").toUpperCase()
  for (var description in records) {
    var chords = records[description]
    for (var i = 0; i < chords.length; i++) {
      var plus = chords[i].lastIndexOf("+")
      if (plus < 0) continue
      var mods = trim(chords[i].substring(0, plus)).split(/\s+/)
      var key = trim(chords[i].substring(plus + 1)).toUpperCase()
      if (key === want && mods.length === 1 && mods[0].toUpperCase() === "ALT") return description
    }
  }
  return ""
}

// The Lua line for a new app-launch bind. Launches the way the shell does
// (uwsm-app -- gtk-launch <id>.desktop). Returns "" for an id it cannot
// quote safely, so nothing is written.
function appBindLine(letter, name, desktopId) {
  var id = String(desktopId || "")
  if (!/^[A-Za-z0-9._-]+$/.test(id) || !/^[A-Z]$/.test(letter)) return ""
  var label = trim(name).replace(/[\r\n]/g, " ").replace(/\\/g, "\\\\").replace(/"/g, "\\\"")
  return 'o.bind("ALT + ' + letter + '", "' + label + '", { launch = "gtk-launch \'' + id + '.desktop\'" })'
}
