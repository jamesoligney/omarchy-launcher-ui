.pragma library
// Weather icons for the island: Lucide (lucide-static 0.460.0, ISC licence,
// https://lucide.dev; Feather portions MIT), stroke outlines on a 24 grid,
// stroke 2, round caps and joins; each Lucide <path> joined into one path
// (a leading "m" made "M", as it is in its own <path>, with the pairs that
// follow it kept as relative linetos). Drawn by WeatherIcon.qml as one stroked
// path, so they take the theme's colour and stay grayscale.
//
// ISC License. Copyright (c) for portions of Lucide are held by Cole Bemis
// 2013-2022 as part of Feather (MIT). All other copyright (c) for Lucide are
// held by Lucide Contributors 2022. Permission to use, copy, modify, and/or
// distribute this software for any purpose with or without fee is hereby
// granted, provided that the above copyright notice and this permission
// notice appear in all copies.

var paths = {
  "cloud-drizzle": "M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242 M8 19v1 M8 14v1 M16 19v1 M16 14v1 M12 21v1 M12 16v1",
  "cloud-fog": "M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242 M16 17H7 M17 21H9",
  "cloud-hail": "M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242 M16 14v2 M8 14v2 M16 20h.01 M8 20h.01 M12 16v2 M12 22h.01",
  "cloud-lightning": "M6 16.326A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 .5 8.973 M13 12l-3 5h4l-3 5",
  "cloud-moon": "M10.188 8.5A6 6 0 0 1 16 4a1 1 0 0 0 6 6 6 6 0 0 1-3 5.197 M13 16a3 3 0 1 1 0 6H7a5 5 0 1 1 4.9-6Z",
  "cloud-rain-wind": "M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242 M9.2 22l3-7 M9 13l-3 7 M17 13l-3 7",
  "cloud-rain": "M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242 M16 14v6 M8 14v6 M12 16v6",
  "cloud-snow": "M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242 M8 15h.01 M8 19h.01 M12 17h.01 M12 21h.01 M16 15h.01 M16 19h.01",
  "cloud-sun": "M12 2v2 M4.93 4.93l1.41 1.41 M20 12h2 M19.07 4.93l-1.41 1.41 M15.947 12.65a4 4 0 0 0-5.925-4.128 M13 22H7a5 5 0 1 1 4.9-6H13a3 3 0 0 1 0 6Z",
  "cloud": "M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z",
  "moon": "M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z",
  "sun": "M8 12a4 4 0 1 0 8 0a4 4 0 1 0 -8 0 M12 2v2 M12 20v2 M4.93 4.93l1.41 1.41 M17.66 17.66l1.41 1.41 M2 12h2 M20 12h2 M6.34 17.66l-1.41 1.41 M19.07 4.93l-1.41 1.41"
}

// The condition for the stock widget's current reading: Open-Meteo WMO code
// with its day flag when present, else wttr.in's code (the same two sources,
// in the same order, as the stock Model.currentIcon). Every code the stock
// set maps has a key here; anything unknown reads as cloud, as stock does.
function key(current) {
  if (!current) return ""
  var night = Number(current.isDay) === 0
  if (current.openMeteoWeatherCode !== undefined && current.openMeteoWeatherCode !== null) {
    var c = parseInt(String(current.openMeteoWeatherCode), 10)
    if (c === 0) return night ? "moon" : "sun"
    if (c === 1 || c === 2) return night ? "cloud-moon" : "cloud-sun"
    if (c === 3) return "cloud"
    if (c === 45 || c === 48) return "cloud-fog"
    if (c >= 51 && c <= 57) return "cloud-drizzle"
    if (c === 61 || c === 63 || c === 80) return "cloud-rain"
    if (c === 65 || c === 81 || c === 82) return "cloud-rain-wind"
    if (c === 66 || c === 67) return "cloud-hail"
    if ((c >= 71 && c <= 77) || c === 85 || c === 86) return "cloud-snow"
    if (c >= 95) return "cloud-lightning"
    return "cloud"
  }
  if (current.weatherCode === undefined || current.weatherCode === null) return ""
  switch (parseInt(String(current.weatherCode), 10)) {
    case 113: return night ? "moon" : "sun"
    case 116: return night ? "cloud-moon" : "cloud-sun"
    case 143: case 248: case 260: return "cloud-fog"
    case 176: case 263: case 266: case 293: case 296: case 353: return "cloud-drizzle"
    case 299: case 302: case 356: return "cloud-rain"
    case 305: case 308: case 359: return "cloud-rain-wind"
    case 182: case 185: case 281: case 284: case 311: case 314: case 317: case 320:
    case 350: case 362: case 365: case 374: case 377: return "cloud-hail"
    case 179: case 227: case 230: case 323: case 326: case 329: case 332:
    case 335: case 338: case 368: case 371: return "cloud-snow"
    case 200: case 386: case 389: case 392: case 395: return "cloud-lightning"
    default: return "cloud"
  }
}
