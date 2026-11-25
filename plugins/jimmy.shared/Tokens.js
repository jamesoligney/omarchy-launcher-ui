.pragma library
// Token readers over Commons.Color.shellValues (flat "section.key" -> string
// from shell.toml, user file winning over the theme's). A missing or bad
// value falls back, so a token never breaks a surface.

function num(values, key, fallback) {
  var v = values ? values[key] : undefined
  var n = (v === undefined || v === null || String(v).length === 0) ? NaN : Number(v)
  return isFinite(n) ? n : fallback
}

function str(values, key, fallback) {
  var v = values ? values[key] : undefined
  return (v === undefined || v === null || String(v).length === 0) ? fallback : String(v)
}
