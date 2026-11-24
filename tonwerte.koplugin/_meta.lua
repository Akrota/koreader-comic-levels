-- Beschreibung auf Deutsch oder Englisch, je nach KOReader-Sprache
local ok, lang = pcall(function() return G_reader_settings:readSetting("language") end)
local de = ok and type(lang) == "string" and lang:sub(1, 2):lower() == "de"
return {
    version = "0.2.0",
    fullname = de and "Tonwerte" or "Levels",
    description = de
        and "Für Comics: Tonwertkurve mit Mittelpunkt, Schatten und Lichtern (S-Kurve), Mitteltöne heller oder dunkler, dunkle Stellen vor dem Zulaufen schützen."
        or "For comics: a tone curve with midpoint, shadows and highlights (S-curve), lighter or darker mid-tones, keep dark areas from blocking up.",
}
