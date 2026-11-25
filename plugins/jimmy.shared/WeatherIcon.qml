import QtQuick
import QtQuick.Shapes
import "WeatherIcons.js" as WeatherIcons

// One weather glyph from WeatherIcons.js, filled on its 24 grid and scaled to
// `size`, in `color` (grayscale by design: callers pass their quiet ink).
// Shared by the bar's island and the weather panel.
Item {
  id: icon
  property string key: ""
  property int size: 20
  property color color: "white"
  width: size
  height: size
  Shape {
    width: 24
    height: 24
    scale: icon.size / 24
    transformOrigin: Item.TopLeft
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
      strokeColor: "transparent"
      strokeWidth: 0
      fillColor: icon.color
      fillRule: ShapePath.OddEvenFill
      PathSvg { path: WeatherIcons.paths[icon.key] || "" }
    }
  }
}
