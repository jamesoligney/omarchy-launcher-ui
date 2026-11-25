import QtQuick
import QtQuick.Shapes
import "WeatherIcons.js" as WeatherIcons

// One weather icon from WeatherIcons.js, stroked on its 24 grid and scaled to
// `size`, in `color`. Grayscale by design: the island passes its quiet ink.
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
      strokeColor: icon.color
      strokeWidth: 2
      fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      joinStyle: ShapePath.RoundJoin
      PathSvg { path: WeatherIcons.paths[icon.key] || "" }
    }
  }
}
