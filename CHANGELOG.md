# Tonwerte – Änderungen

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
