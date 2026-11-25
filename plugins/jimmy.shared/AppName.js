.pragma library
// One app-name resolver for the bar and the active-window widget. Web apps
// resolve through their desktop entry (StartupWMClass = the window class,
// e.g. chrome-muse.ai__-Default -> "Muse.AI"); anything without an entry
// falls back to the capitalised last segment of its app id.
function resolve(appId, lookup) {
  var id = String(appId || "")
  if (id === "") return ""
  var entry = lookup ? lookup(id) : null
  if (entry && entry.name) return entry.name
  var last = id.split(".").pop()
  return last.charAt(0).toUpperCase() + last.slice(1)
}
