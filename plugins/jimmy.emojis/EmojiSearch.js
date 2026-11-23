// Search + category helpers for jimmy.emojis.
//
// The data file (emoji-data.json) is one flat array of { e, k, c, t } built
// once at clone time: e = glyph, k = space-separated keywords, c = category
// id, t = "emoji" | "symbol". `parseData` lowercases every item's searchable
// text into `s` up front so filtering is a single indexOf scan per term — no
// per-keystroke allocation beyond the result slice.

function parseData(raw) {
  try {
    var data = JSON.parse(String(raw || ""))
    var cats = Array.isArray(data.categories) ? data.categories : []
    var items = Array.isArray(data.items) ? data.items : []

    var nameByCat = {}
    for (var i = 0; i < cats.length; i++) {
      var c = cats[i]
      if (c && c.id) nameByCat[c.id] = c.name || c.id
    }

    var out = []
    for (var j = 0; j < items.length; j++) {
      var it = items[j]
      if (!it || !it.e) continue
      var cat = String(it.c || "symbols")
      var searchable = (it.e + " " + (it.k || "") + " " + (nameByCat[cat] || cat)).toLowerCase()
      out.push({ e: it.e, k: it.k || "", c: cat, t: it.t || "emoji", s: searchable })
    }
    return { categories: cats, items: out }
  } catch (e) {
    return { categories: [], items: [] }
  }
}

function normalizedQuery(query) {
  return String(query || "").trim().toLowerCase()
}

function matches(item, terms) {
  for (var i = 0; i < terms.length; i++) {
    if (item.s.indexOf(terms[i]) < 0) return false
  }
  return true
}

// Rank so the exact glyph wins, then keyword word-boundary matches, then
// prefixes, then plain substrings. Lower is better.
function score(item, needle) {
  if (item.e === needle) return 0
  var k = " " + item.k.toLowerCase() + " "
  if (k.indexOf(" " + needle + " ") >= 0) return 1
  if (item.s.indexOf(needle) === 0) return 2
  if (k.indexOf(needle) >= 0) return 3
  return 4
}

// Ranked matches across every term in the query. `limit` caps the slice.
function search(data, query, limit) {
  var items = data ? data.items : []
  var needle = normalizedQuery(query)
  var max = limit === undefined || limit === null ? 1000 : Number(limit)
  if (isNaN(max)) max = 1000
  max = Math.max(0, max)
  if (max === 0) return []
  if (!needle) return items.slice(0, max)

  var terms = needle.split(/\s+/)
  var out = []
  for (var i = 0; i < items.length; i++) {
    if (matches(items[i], terms)) out.push(items[i])
  }
  out.sort(function (a, b) { return score(a, needle) - score(b, needle) })
  return out.slice(0, max)
}

// Items in one category, preserving data order (roughly the original emoji
// order within a block, which reads as grouped when browsed).
function byCategory(data, categoryId) {
  var items = data ? data.items : []
  var cat = String(categoryId || "")
  if (!cat || cat === "all") return items
  var out = []
  for (var i = 0; i < items.length; i++) {
    if (items[i].c === cat) out.push(items[i])
  }
  return out
}

// Reorder items so pinned glyphs lead, then the recency order, then the rest.
// Glyphs are matched by their character, which is unique in this data set.
function orderByPinsAndRecents(items, pins, recents) {
  var pinned = Array.isArray(pins) ? pins : []
  var recent = Array.isArray(recents) ? recents : []
  var byGlyph = {}
  for (var i = 0; i < items.length; i++) byGlyph[items[i].e] = items[i]

  var seen = {}
  var out = []
  function push(glyph) {
    if (!glyph || seen[glyph]) return
    var it = byGlyph[glyph]
    if (!it) return
    seen[glyph] = true
    out.push(it)
  }
  for (var p = 0; p < pinned.length; p++) push(pinned[p])
  for (var r = 0; r < recent.length; r++) push(recent[r])
  for (var j = 0; j < items.length; j++) if (!seen[items[j].e]) out.push(items[j])
  return out
}

if (typeof module !== "undefined") {
  module.exports = {
    parseData: parseData,
    search: search,
    byCategory: byCategory,
    orderByPinsAndRecents: orderByPinsAndRecents
  }
}
