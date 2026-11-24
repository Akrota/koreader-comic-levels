# Levels (Tonwerte) for KOReader

*Deutsch: [README.de.md](README.de.md)*

<!-- byline -->
A plugin by **Akrota and Claude**.

<!-- lang-note -->
*Works in **English and German**: menus and texts follow KOReader's language. A German description is at the bottom of this page.*

A KOReader plugin with your own tone curve for comics, like in an image editor. Black stays black, white stays white. In between you can move a midpoint and lighten or darken the shadows and the lights separately, for example for an S-curve with more contrast.

- It is meant for colour and greyscale comic pages. Both colour pages (RGB) and greyscale pages are handled.
- It doesn't change any KOReader files, so it survives updates.
- It works together with [Comic Panel Zoom](https://github.com/Akrota/koreader-comic-panel-zoom): the plugin keeps the page-rendering call in the form Panel Zoom expects.

**Status: prototype / beta.** It runs on a Kobo Libra Colour, but the settings are still being tuned.

## Screenshots

*The screenshots show the English interface; in a German KOReader the texts are German.*

<table>
<tr><td align="center" valign="top" width="33%"><img src="docs/screenshots/menu.png" width="260" alt="Levels menu: shadows, midpoint, lights, mid-tones"><br><sub>Levels menu: shadows, midpoint, lights, mid-tones</sub></td><td align="center" valign="top" width="33%"><img src="docs/screenshots/protect-shadows.png" width="260" alt="Protect shadows: off, light, strong"><br><sub>Protect shadows: off, light, strong</sub></td><td align="center" valign="top" width="33%"><img src="docs/screenshots/how-it-works.png" width="260" alt="Help text for midpoint, shadows, lights, mid-tones"><br><sub>Help text for midpoint, shadows, lights, mid-tones</sub></td></tr>
</table>

## Features

- **Midpoint** (30 to 225, default 128): splits shadows and lights. The midpoint itself keeps its brightness.
- **Shadows** (-100 to +100): lightens (above 0) or darkens (below 0) the tones between black and the midpoint.
- **Lights** (-100 to +100): lightens or darkens the tones between the midpoint and white.
- **Suggest an S-curve (more contrast):** one tap sets shadows -30, lights +30, midpoint 128.
- **Mid-tones** (0.5 to 1.6, default 1.0): lightens or darkens everything in between evenly (below 1.0 darker).
- **Protect shadows** (off / light / strong): the darkest tones don't block up.
- **On/off switch** and a **gesture** "Levels on/off" for a quick before/after comparison.
- **Reset all to neutral.**
- The settings apply to all comics alike (not per comic), so pages don't look different from each other.

## Installation

1. Download the ZIP from [Releases](../../releases) and unpack it, or download this repository.
2. Copy the folder **`tonwerte.koplugin`** to KOReader's `plugins` folder. On a Kobo, that is `.adds/koreader/plugins/`.
3. Restart KOReader.

## Settings

Open a comic, then go to: top menu → tools icon (wrench) → **Levels** (in a German KOReader: **Tonwerte**).

- **Levels on** (main switch; off = pages as without the plugin, the values are kept)
- **Shadows**
- **Midpoint**
- **Lights**
- **Suggest an S-curve (more contrast)**
- **Mid-tones**
- **Protect shadows** (off, light, strong)
- **Reset all to neutral**
- **How does it work?** (short explanation)

Long-press an entry for its help text. For the gesture: Settings → Taps and gestures → Gesture manager → "Levels on/off".

KOReader's own sliders (for example contrast) apply first, so it is best to leave KOReader's contrast at 1.0.

## How it works

All settings are combined into **one lookup table** with 256 entries (one per brightness value). Each freshly drawn page is run through this table once, colour channel by colour channel. That is fast: there is no per-pixel calculation, only a lookup. Order: curve (midpoint, shadows, lights), then mid-tones, then protect shadows.

If a page ever takes unusually long (more than 3 seconds), the plugin resets LuaJIT's compiler and writes a note to the log. The time of each page is logged as "Tonwerte: page ... s".

## Known limitation

If only one side is bent (for example only the shadows), the curve has a slight kink at the midpoint. With soft gradients it may be visible; with a symmetrical S-curve it is not. A smoother transition is possible if it turns out to matter.

## Tested on

Kobo Libra Colour with KOReader 2026.07.1 and ZenOS.

## Who made this

The code was written entirely by **Claude**, an AI by Anthropic (in Claude Code). The owner of this repository came up with the idea, tested the plugin on a Kobo and gave feedback, but did not write the code.

There is no warranty and no guaranteed support. Bug reports are welcome as [issues](../../issues). Please attach `crash.log` from the KOReader folder.

## More plugins by Akrota and Claude

- [Comic Display](https://github.com/Akrota/koreader-comic-display): Refresh against ghosting, dark borders and a clock for comics
- [Comic Panel Zoom](https://github.com/Akrota/koreader-comic-panel-zoom): Panel-by-panel view (fork of JorgeTheFox's plugin)
- [Comic Dual Page](https://github.com/Akrota/koreader-comic-dual-page): Double pages with detection (fork of KORComic)
- [CBZ Converter](https://github.com/Akrota/koreader-cbz-converter): Convert comics, PDF and EPUB to CBZ on the device
- [Folder to series](https://github.com/Akrota/koreader-folder-to-series): Comic folders to series with volume numbers
- [Drive Library](https://github.com/Akrota/koreader-drive-library): Google Drive as a cloud library
- [Story Recall](https://github.com/Akrota/koreader-story-recall): Spoiler-free AI recap for books
- [Guitar Tab Reader](https://github.com/Akrota/koreader-guitar-tab-reader): Guitar tabs and chords for e-ink
- [Wi-Fi while charging](https://github.com/Akrota/koreader-wifi-while-charging): Keep Wi-Fi on while charging
- [Zen page browser gesture](https://github.com/Akrota/koreader-zen-page-browser-gesture): Gesture for the ZenOS page browser

## License

[MIT](LICENSE)

---

## Deutsch (Kurzbeschreibung)

Ein KOReader-Plugin mit einer eigenen Tonwertkurve für Comics, wie in einer Bildbearbeitung. Schwarz bleibt Schwarz, Weiß bleibt Weiß. Dazwischen lässt sich ein Mittelpunkt verschieben, und Schatten und Lichter lassen sich getrennt heller oder dunkler machen, zum Beispiel für eine S-Kurve mit mehr Kontrast.

- Gedacht für Farb- und Graustufenseiten von Comics. Beides wird umgerechnet.
- Es ändert keine KOReader-Dateien und übersteht daher Updates.
- Es arbeitet mit [Comic Panel Zoom](https://github.com/Akrota/koreader-comic-panel-zoom) zusammen: Das Plugin lässt den Aufruf zum Zeichnen der Seite in der Form, die Panel Zoom erwartet.

**Stand: Prototyp / Beta.** Es läuft auf einem Kobo Libra Colour, die Einstellungen werden aber noch abgestimmt.

Die ausführliche deutsche Anleitung steht in der [README.de.md](README.de.md).
