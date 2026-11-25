# Changelog – Levels / Tonwerte

*Deutsche Fassung weiter unten.*

## 0.3.0 (25 Nov 2026)

- **New default values:** midpoint 160, shadows -45, lights +10, mid-tones 0.9, protect shadows light (tried on a Kobo Libra Colour). New menu entry "Recommended values (default)". "Reset all to neutral" stays. If you already saved your own values, you keep them.

## 0.2.0 (prototype with a curve)

- **A curve instead of black and white point:** black stays black, white stays white. The **midpoint** (30 to 225, default 128) can be moved and keeps its brightness. **Shadows** (-100 to +100) bend the section from black to the midpoint, **lights** (-100 to +100) the section from the midpoint to white. The curve always keeps rising.
- New entry **"Suggest an S-curve"** (shadows -30, lights +30, midpoint 128).
- Order in the table: curve, then mid-tones, then protect shadows. Still a single table, as fast as in 0.1.
- Removed: black point, white point and "Measure" (no use in practice).
- Known: if only one side is bent (for example only the shadows), the curve has a slight kink at the midpoint. It can show in smooth gradients, not with a symmetrical S-curve.

## 0.1.0 (prototype)

- Black point and white point, plus a "Measure" function.
- **Mid-tones** (0.5 to 1.6) and **protect shadows** (off, light, strong).
- Main switch **"Levels on"** and gesture **"Levels on/off"**, "Reset all to neutral", "How does it work?".
- Everything in one table with 256 entries, one lookup per colour channel. Works for colour and greyscale pages. If a page takes more than 3 seconds, LuaJIT is reset; the time of every page is written to the log.

---

# Deutsch

## 0.3.0 (25.11.2026)

- **Neue Standardwerte:** Mittelpunkt 160, Schatten -45, Lichter +10, Mitteltöne 0,9, Schatten schützen leicht (auf einem Kobo Libra Colour erprobt). Neuer Menüpunkt „Empfohlene Werte (Standard)“. „Alles auf neutral“ bleibt. Wer schon eigene Werte gespeichert hat, behält sie.

## 0.2.0 (Prototyp mit Kurve)

- **Kurve statt Schwarz-/Weißpunkt:** Schwarz bleibt Schwarz, Weiß bleibt Weiß. Der **Mittelpunkt** (30 bis 225, Standard 128) ist verschiebbar und behält seine Helligkeit. **Schatten** (-100 bis +100) biegen den Abschnitt Schwarz bis Mittelpunkt, **Lichter** (-100 bis +100) den Abschnitt Mittelpunkt bis Weiß. Die Kurve bleibt dabei immer steigend.
- Neuer Eintrag **„S-Kurve vorschlagen“** (Schatten -30, Lichter +30, Mittelpunkt 128).
- Reihenfolge in der Tabelle: Kurve, dann Mitteltöne, dann Schatten schützen. Weiterhin eine einzige Tabelle, gleich schnell wie in 0.1.
- Entfernt: Schwarzpunkt, Weißpunkt und „Messen“ (brachten in der Praxis nichts).
- Bekannt: Wird nur eine Seite gebogen (zum Beispiel nur die Schatten), hat die Kurve am Mittelpunkt einen leichten Knick. Bei weichen Verläufen kann er sichtbar sein, bei einer symmetrischen S-Kurve nicht.

## 0.1.0 (Prototyp)

- Schwarzpunkt und Weißpunkt, dazu die Funktion „Messen“.
- **Mitteltöne** (0,5 bis 1,6) und **Schatten schützen** (aus, leicht, stark).
- Hauptschalter **„Tonwerte an“** und Geste **„Tonwerte an/aus“**, „Alles auf neutral“, „Wie funktioniert das?“.
- Alles in einer Tabelle mit 256 Einträgen, pro Farbkanal ein Nachschlagen. Funktioniert für Farbseiten und Graustufen. Dauert eine Seite über 3 Sekunden, wird LuaJIT zurückgesetzt; die Zeit jeder Seite steht im Protokoll.
