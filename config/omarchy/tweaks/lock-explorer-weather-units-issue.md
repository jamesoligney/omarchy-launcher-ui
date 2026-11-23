**Title:** Weather design hardcodes Celsius and km/h, ignoring Omarchy's weather unit setting

The full-screen Weather design always renders metric units, even on a system
where Omarchy's own weather widget shows Fahrenheit. There is no setting to
change it — `settingKeys` has no weather unit — so the only way out is to
customize the design and edit the field names by hand.

### Where

`designs/Weather.qml` reads the metric fields directly (v2.0.12, `2eea881`):

- L17 `current.temp_C`
- L18 `current.FeelsLikeC`
- L153 `current.windspeedKmph + " km/h"`
- L190 `modelData.maxtempC` / `modelData.mintempC`

### Why it looks like an oversight rather than a choice

Everything needed is already there:

- `wttr.in?format=j1` returns `temp_F`, `FeelsLikeF`, `maxtempF`, `mintempF`
  and `windspeedMiles` in the same response, so no extra request is needed.
- `designs/LiveWeather.qml` already exposes **both** (`tempC` on L21 and
  `tempF` on L22).
- The designer's Weather piece already offers the choice — `Designer.js`
  L337-342, `unit: "c" | "f"`, consumed in `designs/DesignerItem.qml` L171.

So a Weather piece placed in the designer can be Fahrenheit, while the
built-in Weather design cannot. That inconsistency is what makes this feel
like a gap.

Omarchy itself already resolves the unit, and the plugin could defer to the
same logic instead of inventing a setting:

```qml
// omarchy/shell/plugins/panels/weather/Panel.qml:151
readonly property bool useImperial: Model.shouldUseImperial(setting("unit", ""), Qt.locale().name, reportCountry)
```

`Model.js:134` takes an explicit `unit` override first, then the country from
the wttr.in report, then the locale. On an `en_US` system with no override it
returns imperial, which is why the bar widget and the lock screen disagree
today.

### Suggested fix

Either of these would resolve it, in order of preference:

1. Follow Omarchy's resolution (explicit `unit` override → report country →
   locale), so the lock screen matches the bar widget with no new setting.
2. Add `setWeatherUnit c|f|auto` alongside `setClockFormat`, defaulting to
   `auto`, and have the Weather design and the designer piece share it.

Worth noting that `windspeedKmph` on L153 needs the same treatment as the
temperatures — Fahrenheit with km/h beside it would look half-converted.

### Workaround, for anyone who finds this

```sh
omarchy-shell lock customize weather   # copies to ~/.config/omarchy/lock-designs/Weather.qml
```

Then in that copy: `temp_C`→`temp_F`, `FeelsLikeC`→`FeelsLikeF`,
`maxtempC`/`mintempC`→`maxtempF`/`mintempF`, and
`windspeedKmph + " km/h"`→`windspeedMiles + " mph"`. It shows up under Custom
and survives plugin updates. `qmllint` parses the result clean.

### Environment

- Lock Screen Explorer 2.0.12 (`2eea881`)
- Omarchy 4.5.0-3, `LANG=en_US.UTF-8`, `LC_MEASUREMENT=en_US.UTF-8`
- `extras/doctor.sh`: all ok (one note about no FIDO2 service, unrelated)
