import QtQuick
import qs.Commons
import qs.Commons as Commons
import "Tokens.js" as Tokens

// Gives the stock bar-widget panels (hosted by jimmy.bar) the same language as
// PanelShell without editing stock files: when a panel opens, its card takes
// the island glass, thin outline and radius, and the shared CardMotion replaces
// the stock grow-in; when it closes, the shared close runs. The stock panel
// window stays mapped while its card is visible, so it follows the motion.
//
// adopt(key) / release(key): the key a stock panel passes the bar when it
// opens and closes (its owner widget, or the panel itself).
Item {
  id: adopter
  visible: false

  readonly property var tokens: Commons.Color.shellValues
  property var motions: new Map()     // card -> CardMotion
  property var adoptedIds: []          // module ids adopted at least once (status)
  property string lastAttempt: ""      // what the last adopt() found (status)

  Component { id: motionComponent; CardMotion {} }
  Component { id: scaleComponent; Scale {} }
  Component { id: blankComponent; Item {} }
  Component { id: glowComponent; IslandGlow {} }

  // The stock KeyboardPanel that answers to `key`, searched from the key down.
  function panelFor(key) {
    if (!key) return null
    if (key.anchorItem !== undefined && key.coordinatorKey !== undefined) return key
    var queue = [key], seen = 0
    while (queue.length && seen < 400) {
      var node = queue.shift(); seen++
      var kids = node && node.data ? node.data : []
      for (var i = 0; i < kids.length; i++) {
        var k = kids[i]
        if (!k) continue
        if (k.anchorItem !== undefined && k.coordinatorKey === key) return k
        queue.push(k)
      }
    }
    return null
  }

  // The panel's card: the item it declares that carries `shown` and a border.
  // (A KeyboardPanel's own `contentItem` is its panel content, not the
  // window's root, so search what it declares.)
  function cardOf(panel) {
    var kids = panel && panel.data ? panel.data : []
    for (var i = 0; i < kids.length; i++)
      if (kids[i] && kids[i].shown !== undefined && kids[i].borderSpec !== undefined) return kids[i]
    return null
  }

  function adopt(key, moduleName) {
    var panel = panelFor(key)
    var card = cardOf(panel)
    lastAttempt = String(moduleName) + ": key " + (key ? String(key).split("(")[0] : "none")
      + ", panel " + !!panel + ", card " + !!card
    if (!card) return false
    var motion = motions.get(card)
    if (!motion) {
      var blank = blankComponent.createObject(card)
      motion = motionComponent.createObject(card, { card: card, scrim: blank })
      var scale = scaleComponent.createObject(card)
      scale.origin.x = Qt.binding(function() { return card.width / 2 })
      scale.origin.y = 0
      scale.xScale = Qt.binding(function() { return motion.xScale })
      scale.yScale = Qt.binding(function() { return motion.yScale })
      card.transform = [scale]
      glowComponent.createObject(card)
      motions.set(card, motion)
    }
    card.color = Qt.binding(function() {
      return Util.alpha(Commons.Color.background, Tokens.num(adopter.tokens, "launcher.panel-background-alpha", 0.70))
    })
    card.radius = Qt.binding(function() { return Tokens.num(adopter.tokens, "island.radius", 9) })
    card.borderSpec = Qt.binding(function() {
      return Border.surfaceSpec("launcher", "panel-border",
        Util.alpha(Commons.Color.accent, Tokens.num(adopter.tokens, "launcher.panel-border-alpha", 0.16)), 1)
    })
    motion.play()
    if (moduleName && adoptedIds.indexOf(moduleName) < 0) adoptedIds = adoptedIds.concat([moduleName])
    return true
  }

  function release(key) {
    var card = cardOf(panelFor(key))
    var motion = card ? motions.get(card) : null
    if (motion) motion.hide()
  }
}
