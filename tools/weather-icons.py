# Weather icon generator for jimmy.shared/WeatherIcons.js (build-time only).
# Needs shapely: python -m venv v && v/bin/pip install shapely
# Run: v/bin/python tools/weather-icons.py paths.json, then paste the JSON
# into the `paths` object of plugins/jimmy.shared/WeatherIcons.js.
import math, json, sys
from shapely.geometry import Point, Polygon, LineString, box
from shapely.ops import unary_union
from shapely import affinity

def circle(x, y, r): return Point(x, y).buffer(r, quad_segs=24)
def scal(g, f, ox, oy): return affinity.scale(g, f, f, origin=(ox, oy))
def mv(g, dx, dy): return affinity.translate(g, dx, dy)

def sun(cx=12, cy=12, s=1.0):
    pts = []
    for i in range(240):
        t = 2 * math.pi * i / 240
        r = (9.7 + 0.95 * math.cos(12 * t)) * s
        pts.append((cx + r * math.cos(t), cy + r * math.sin(t)))
    ring = Polygon(pts).difference(circle(cx, cy, 6.9 * s))
    return unary_union([ring, circle(cx, cy, 5.3 * s)])

def crescent(cx=11, cy=13, r=8.6, s=1.0):
    return circle(cx, cy, r * s).difference(circle(cx + 4.6 * s, cy - 4.4 * s, r * 0.86 * s))

def star(cx, cy, R, r):
    pts = []
    for i in range(10):
        t = -math.pi / 2 + i * math.pi / 5
        rr = R if i % 2 == 0 else r
        pts.append((cx + rr * math.cos(t), cy + rr * math.sin(t)))
    return Polygon(pts).buffer(0.35, quad_segs=6).buffer(-0.35, quad_segs=6)

def cloud(dx=0, dy=0, s=1.0):
    parts = [circle(7.6, 14.6, 4.1), circle(12.6, 11.3, 5.6), circle(17.6, 14.9, 3.8),
             box(7.6, 13.0, 17.6, 18.7)]
    c = unary_union(parts).intersection(box(0, 0, 24, 18.7))
    c = c.buffer(0.6, quad_segs=8).buffer(-0.6, quad_segs=8)
    return mv(scal(c, s, 12, 12), dx, dy)

def drop(x, y, h=3.4, r=1.25):
    tip = Polygon([(x, y - h), (x - r * 0.98, y - 0.25), (x + r * 0.98, y - 0.25)])
    return unary_union([circle(x, y, r), tip])

def bolt(dx=0, dy=0):
    return mv(Polygon([(13.2, 9.5), (8.6, 16.0), (11.6, 16.0), (10.4, 22.0), (15.6, 14.4), (12.6, 14.4), (14.6, 9.5)]), dx, dy)

def bar(x0, x1, y, w=1.7):
    return LineString([(x0, y), (x1, y)]).buffer(w / 2, quad_segs=8)

def cut(fore, back, gap=1.3):
    return unary_union([back.difference(fore.buffer(gap, quad_segs=12)), fore])

def snowflake(cx=12, cy=12):
    arms = []
    for k in range(6):
        t = math.pi / 2 + k * math.pi / 3
        ex, ey = cx + 9.2 * math.cos(t), cy - 9.2 * math.sin(t)
        arms.append(LineString([(cx, cy), (ex, ey)]).buffer(1.05, quad_segs=8))
        for d in (-1, 1):
            bx, by = cx + 5.6 * math.cos(t), cy - 5.6 * math.sin(t)
            u = t + d * math.pi / 4
            arms.append(LineString([(bx, by), (bx + 3.2 * math.cos(u), by - 3.2 * math.sin(u))]).buffer(0.95, quad_segs=8))
    hexa = Polygon([(cx + 2.6 * math.cos(k * math.pi / 3), cy + 2.6 * math.sin(k * math.pi / 3)) for k in range(6)])
    return unary_union(arms + [hexa]).difference(circle(cx, cy, 1.1))

def build():
    C = cloud(0, 0.6)          # the standard cloud, low enough to sit under a sun
    icons = {}
    icons["sun"] = sun()
    icons["moon"] = unary_union([crescent(10.6, 13.6), star(18.4, 5.4, 3.3, 1.45)])
    icons["cloud-sun"] = cut(cloud(1.2, 2.4, 0.9), sun(8.6, 8.6, 0.62))
    icons["cloud-moon"] = cut(cloud(1.2, 2.4, 0.9), crescent(9.6, 8.6, 6.8, 0.82))
    icons["cloud"] = cut(cloud(0.8, 3.0, 0.88), cloud(-3.6, -3.0, 0.62))
    top = cloud(0, -2.6, 0.88)
    icons["cloud-fog"] = unary_union([top, bar(5.5, 18.5, 19.6), bar(8, 21, 22.4)])
    icons["cloud-drizzle"] = unary_union([top, circle(8.5, 20.4, 1.15), circle(12.5, 21.6, 1.15), circle(16.5, 20.4, 1.15)])
    icons["cloud-rain"] = unary_union([top, drop(8.4, 21.2), drop(12.5, 22.2), drop(16.6, 21.2)])
    heavy = cut(cloud(1.2, -2.6, 0.84), cloud(-3.4, -6.0, 0.6))
    icons["cloud-rain-wind"] = unary_union([heavy, drop(7.4, 21.2), drop(11.0, 22.4), drop(14.6, 21.2), drop(18.2, 22.4)])
    icons["cloud-hail"] = unary_union([top, drop(8.4, 21.2), circle(12.5, 21.4, 1.35), drop(16.6, 21.2)])
    icons["cloud-snow"] = snowflake()
    icons["cloud-lightning"] = cut(bolt(0.4, 0.6), cloud(0, -1.6, 0.92), 1.2)
    return icons

def to_path(g):
    g = g.simplify(0.04, preserve_topology=True)
    polys = [g] if g.geom_type == "Polygon" else list(g.geoms)
    out = []
    for p in polys:
        for ring in [p.exterior] + list(p.interiors):
            cs = list(ring.coords)[:-1]
            out.append("M" + " L".join("%s %s" % (round(x, 2), round(y, 2)) for x, y in cs) + "Z")
    return "".join(out)

if __name__ == "__main__":
    icons = {k: to_path(v) for k, v in build().items()}
    json.dump(icons, open(sys.argv[1], "w"), indent=2)
    for k, v in icons.items():
        b = build()[k].bounds
        print(k, len(v), [round(x, 1) for x in b])
