function normalizeEntry(value) {
  if (typeof value === "string")
    return value.trim().length > 0 ? { type: "text", text: value } : null

  if (!value || typeof value !== "object") return null

  var type = String(value.type || value.kind || "")
  if (type === "text") {
    var text = String(value.text || "")
    if (!text.trim().length) return null
    var t = { type: "text", text: text }
    if (value.capturedAtMs !== undefined && value.capturedAtMs !== null) t.capturedAtMs = Number(value.capturedAtMs)
    else if (value.capturedAt !== undefined && value.capturedAt !== null) t.capturedAt = String(value.capturedAt)
    return t
  }

  if (type === "image") {
    var path = String(value.path || "")
    if (!path) return null
    var entry = {
      type: "image",
      path: path,
      mime: String(value.mime || "image/png")
    }
    if (value.capturedAtMs !== undefined && value.capturedAtMs !== null)
      entry.capturedAtMs = Number(value.capturedAtMs)
    if (value.capturedAt !== undefined && value.capturedAt !== null)
      entry.capturedAt = String(value.capturedAt)
    return entry
  }

  return null
}

function entryKey(entry) {
  if (!entry) return ""
  if (entry.type === "image") return "image:" + String(entry.path || "")
  return "text:" + String(entry.text || "")
}

// Stable, compact key for pinning. Text is hashed so a pin does not bloat the
// pins file (and does not leak a private clipboard into a dotfile); images
// pin by path, which is already unique and deduplicated.
function hashString(s) {
  var h = 5381
  s = String(s || "")
  for (var i = 0; i < s.length; i++) h = ((h << 5) + h + s.charCodeAt(i)) >>> 0
  return h.toString(36)
}

function pinKey(entry) {
  if (!entry) return ""
  if (entry.type === "image") return "image:" + String(entry.path || "")
  return "text:" + hashString(String(entry.text || ""))
}

function parseHistory(raw) {
  try {
    var parsed = JSON.parse(String(raw || "[]"))
    var next = []
    if (!Array.isArray(parsed)) return next

    for (var i = 0; i < parsed.length; i++) {
      var entry = normalizeEntry(parsed[i])
      if (entry) next.push(entry)
    }
    return next
  } catch (e) {
    return []
  }
}

function addEntry(history, entry, limit) {
  var normalized = normalizeEntry(entry)
  var max = limit === undefined || limit === null ? 100 : Number(limit)
  if (isNaN(max)) max = 100
  max = Math.max(0, max)
  if (!normalized) return Array.isArray(history) ? history.slice(0, max) : []
  if (max === 0) return []

  var key = entryKey(normalized)
  var next = [normalized]
  var values = Array.isArray(history) ? history : []

  for (var i = 0; i < values.length && next.length < max; i++) {
    var existing = normalizeEntry(values[i])
    if (!existing || entryKey(existing) === key) continue
    next.push(existing)
  }

  return next
}

function removeEntryAt(history, index) {
  var values = Array.isArray(history) ? history : []
  var target = Number(index)
  if (isNaN(target) || target < 0 || target >= values.length) return values.slice()

  var next = values.slice()
  next.splice(target, 1)
  return next
}

function clearHistory() {
  return []
}

function parseEntryJson(line) {
  var raw = String(line || "").trim()
  if (!raw) return null
  try { return normalizeEntry(JSON.parse(raw)) } catch (e) { return null }
}

function searchableText(entry) {
  if (!entry) return ""
  if (entry.type === "image") return "image screenshot " + String(entry.mime || "") + " " + String(entry.capturedAt || "")
  return String(entry.text || "") + " " + fileEntryText(entry)
}

function decodeFileUri(uri) {
  var value = String(uri || "").trim()
  if (value.indexOf("file://") !== 0) return ""

  var path = value.substring(7)
  if (path.indexOf("localhost/") === 0) path = path.substring(9)
  if (path.charAt(0) !== "/") return ""

  try { return decodeURIComponent(path) } catch (e) { return path }
}

function filePaths(entry) {
  if (!entry || entry.type !== "text") return []

  var lines = String(entry.text || "").split(/\r?\n/)
  var paths = []
  for (var i = 0; i < lines.length; i++) {
    var path = decodeFileUri(lines[i])
    if (path) paths.push(path)
  }
  return paths
}

function fileName(path) {
  var parts = String(path || "").split("/")
  return parts.length > 0 ? parts[parts.length - 1] : String(path || "")
}

function isImagePath(path) {
  return /\.(png|jpe?g|webp|gif|bmp|tiff?)$/i.test(String(path || ""))
}

// tr is an optional translate(key, english) from the QML side (I18n.t),
// trn its plural form (I18n.tn) and fmt a number formatter
// (I18n.formatNumber); without them the English text and plain digits
// stand, which is what the Node tests assert.
function translator(tr) {
  return typeof tr === "function" ? tr : function(key, english) { return english }
}

function fileEntryText(entry, tr, trn, fmt) {
  var tn = typeof trn === "function" ? trn : function(key, count, english) { return count === 1 ? english.one : english.other }
  var number = typeof fmt === "function" ? fmt : function(v) { return String(v) }
  var paths = filePaths(entry)
  if (paths.length === 0) return ""
  if (paths.length === 1) return fileName(paths[0])
  return tn("clipboard.files", paths.length, { one: "%1 file", other: "%1 files" }).replace("%1", number(paths.length))
}

function imagePreviewText(entry, tr) {
  var t = translator(tr)
  var timestamp = timeText(entry)
  if (!timestamp) return t("clipboard.image", "Image")

  var screenshot = String(entry && entry.mime || "") === "image/png"
  var pattern = screenshot
    ? t("clipboard.screenshotFrom", "Screenshot from %1")
    : t("clipboard.imageFrom", "Image from %1")
  return pattern.replace("%1", timestamp)
}

function previewText(entry, tr, trn, fmt) {
  if (!entry) return ""
  if (entry.type === "image") return imagePreviewText(entry, tr)
  var fileText = fileEntryText(entry, tr, trn, fmt)
  if (fileText) return fileText
  return String(entry.text || "").replace(/\s+/g, " ")
}

function fullText(entry) {
  if (!entry) return ""
  var paths = filePaths(entry)
  if (paths.length > 0) return paths.join("\n")
  return String(entry.text || "")
}

// The picker only ever searches and renders a prefix of an entry, so scan and
// render just that much. A single huge paste otherwise costs hundreds of
// megabytes of string work on every keystroke and stalls the whole shell.
// Pasting reads the full entry back from history by index, so nothing is lost.
var displayTextLimit = 8192

function cappedEntry(entry) {
  if (!entry || entry.type !== "text" || entry.text.length <= displayTextLimit) return entry

  // Cut on a line break so a file:// URI never truncates into a bogus path.
  var cut = entry.text.lastIndexOf("\n", displayTextLimit)
  return { type: "text", text: entry.text.slice(0, cut > 0 ? cut : displayTextLimit) }
}

function relativeTime(ms) {
  var t = Number(ms)
  if (isNaN(t) || t <= 0) return ""
  var diff = Date.now() - t
  if (diff < 0) diff = 0
  var sec = Math.floor(diff / 1000)
  if (sec < 60) return "just now"
  var min = Math.floor(sec / 60)
  if (min < 60) return min + "m ago"
  var hr = Math.floor(min / 60)
  if (hr < 24) return hr + "h ago"
  var day = Math.floor(hr / 24)
  if (day < 7) return day + "d ago"
  return formatTimestamp(t)
}

function formatTimestamp(ms) {
  var t = Number(ms)
  if (isNaN(t) || t <= 0) return ""
  try {
    var d = new Date(t)
    var hh = d.getHours()
    var mm = d.getMinutes()
    return (hh < 10 ? "0" + hh : hh) + ":" + (mm < 10 ? "0" + mm : mm) + " " + d.toDateString().replace(/\s+\d{4}$/, "")
  } catch (e) { return "" }
}

function timeText(entry) {
  if (!entry) return ""
  if (entry.capturedAtMs) return relativeTime(entry.capturedAtMs)
  return String(entry.capturedAt || "")
}

function sizeText(entry) {
  if (!entry) return ""
  if (entry.type === "image") return "Image"
  var bytes = String(entry.text || "").length
  if (bytes < 1024) return bytes + " B"
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
  return (bytes / 1024 / 1024).toFixed(1) + " MB"
}

// typeFilter: "all" | "text" | "image" | "file". Every row also carries its
// compact pinKey, capture time and size so the caller renders them directly.
function displayRows(history, query, typeFilter, limit, tr, trn, fmt) {
  var values = Array.isArray(history) ? history : []
  var needle = String(query || "").trim().toLowerCase()
  var type = String(typeFilter || "all")
  var max = limit === undefined || limit === null ? 50 : Number(limit)
  if (isNaN(max)) max = 50
  max = Math.max(0, max)
  if (max === 0) return []

  var rows = []

  for (var i = 0; i < values.length; i++) {
    var entry = cappedEntry(normalizeEntry(values[i]))
    if (!entry) continue
    var paths = filePaths(entry)
    var isFile = paths.length > 0
    var isImage = entry.type === "image"
    var entryType = isFile ? "file" : entry.type
    if (type !== "all" && entryType !== type) continue
    if (needle && searchableText(entry).toLowerCase().indexOf(needle) < 0) continue

    var previewPath = isImage ? String(entry.path || "") : (isFile && paths.length === 1 && isImagePath(paths[0]) ? paths[0] : "")
    rows.push({
      entryType: entryType,
      fullText: isImage ? "" : fullText(entry),
      previewText: previewText(entry, tr, trn, fmt),
      previewImage: previewPath,
      path: isImage ? String(entry.path || "") : (isFile && paths.length === 1 ? paths[0] : ""),
      mime: isImage ? String(entry.mime || "image/png") : "text/plain",
      pinKey: pinKey(entry),
      timeText: timeText(entry),
      sizeText: sizeText(entry),
      index: i
    })
    if (rows.length >= max) break
  }

  return rows
}

// Hoist pinned rows to the top, keeping their relative order; the rest follow.
// Each row gets a `pinned` flag the UI can read directly.
function orderByPins(rows, pins) {
  var values = Array.isArray(rows) ? rows : []
  var pinned = Array.isArray(pins) ? pins : []
  var pinSet = {}
  for (var i = 0; i < pinned.length; i++) pinSet[pinned[i]] = true

  var pinnedRows = []
  var rest = []
  for (var j = 0; j < values.length; j++) {
    var r = values[j]
    r.pinned = pinSet[r.pinKey] === true
    if (r.pinned) pinnedRows.push(r)
    else rest.push(r)
  }
  return pinnedRows.concat(rest)
}

if (typeof module !== "undefined") {
  module.exports = {
    normalizeEntry: normalizeEntry,
    entryKey: entryKey,
    hashString: hashString,
    pinKey: pinKey,
    parseHistory: parseHistory,
    addEntry: addEntry,
    removeEntryAt: removeEntryAt,
    clearHistory: clearHistory,
    parseEntryJson: parseEntryJson,
    searchableText: searchableText,
    previewText: previewText,
    imagePreviewText: imagePreviewText,
    filePaths: filePaths,
    fileEntryText: fileEntryText,
    fullText: fullText,
    relativeTime: relativeTime,
    formatTimestamp: formatTimestamp,
    timeText: timeText,
    sizeText: sizeText,
    displayRows: displayRows,
    orderByPins: orderByPins
  }
}
