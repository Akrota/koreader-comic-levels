--[[--
Tonwerte (Prototyp, Windows-Claude 2.11.2026): eigene Tonwertkurve fuer Comics. Schwarz bleibt
Schwarz, Weiss bleibt Weiss; dazwischen ein verschiebbarer Mittelpunkt, darunter die Schatten und
darueber die Lichter getrennt anheben oder absenken (z. B. eine S-Kurve fuer mehr Kontrast), dazu
Mitteltoene (Gamma) und Schattenschutz.

Alles steckt in EINER Tabelle 0-255, die jede frisch gezeichnete Seite einmal durchlaeuft: pro
Farbkanal ein Nachschlagen, keine Verzweigungen. Der verworfene Farbausgleich hatte pro Bildpunkt
viel gerechnet; LuaJIT gab das auf dem Kobo nach einer Weile auf und rechnete zehnmal langsamer bis
zum Neustart. Deshalb hier eine einfache Schleife und eine Absicherung (bei einer ungewoehnlich
langsamen Seite den Uebersetzer zuruecksetzen).
--]]

local Blitbuffer = require("ffi/blitbuffer")
local DocCache = require("document/doccache")
local Document = require("document/document")
local InfoMessage = require("ui/widget/infomessage")
local SpinWidget = require("ui/widget/spinwidget")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local ffi = require("ffi")
local logger = require("logger")

local strings = {
    de = {
        menu_title = "Tonwerte",
        enabled = "Tonwerte an",
        enabled_help = "Hauptschalter zum schnellen Vergleichen. Aus = Seiten wie ohne Plugin, die Werte bleiben. Auch als Geste: Einstellungen → Tippen und Gesten → Gestenverwaltung → „Tonwerte an/aus“.",
        gesture = "Tonwerte an/aus",
        toggled_on = "Tonwerte: an",
        toggled_off = "Tonwerte: aus",
        pivot = "Mittelpunkt: %d",
        pivot_title = "Mittelpunkt (0 = schwarz, 255 = weiß)",
        pivot_help = "Die Stelle, an der sich Schatten und Lichter trennen. Weiter links (kleiner): mehr Töne zählen zu den Lichtern. Weiter rechts: mehr Töne zählen zu den Schatten. Der Mittelpunkt selbst behält seine Helligkeit.",
        shadows = "Schatten: %s",
        shadows_title = "Schatten (unter 0 dunkler, über 0 heller)",
        shadows_help = "Töne zwischen Schwarz und Mittelpunkt anheben (heller) oder absenken (dunkler). Schwarz bleibt Schwarz.",
        lights = "Lichter: %s",
        lights_title = "Lichter (unter 0 dunkler, über 0 heller)",
        lights_help = "Töne zwischen Mittelpunkt und Weiß anheben (heller) oder absenken (dunkler). Weiß bleibt Weiß.",
        scurve = "S-Kurve vorschlagen (mehr Kontrast)",
        scurve_done = "S-Kurve eingestellt: Schatten -30, Lichter +30, Mittelpunkt 128.",
        gamma = "Mitteltöne: %.2f",
        gamma_title = "Mitteltöne (unter 1,0 dunkler, über 1,0 heller)",
        shadow = "Schatten schützen: %s",
        shadow_off = "aus",
        shadow_light = "leicht",
        shadow_strong = "stark",
        reset = "Alles auf neutral",
        about = "Wie funktioniert das?",
        about_text = "Eine eigene Tonwertkurve für Comics, wie in einer Bildbearbeitung. Schwarz bleibt Schwarz, Weiß bleibt Weiß.\n\n"
            .. "• Mittelpunkt: trennt Schatten und Lichter, von dunkel (links) nach hell (rechts) verschiebbar.\n"
            .. "• Schatten: Töne zwischen Schwarz und Mittelpunkt heller (über 0) oder dunkler (unter 0).\n"
            .. "• Lichter: Töne zwischen Mittelpunkt und Weiß heller oder dunkler.\n"
            .. "Mehr Kontrast (S-Kurve): Schatten etwas dunkler, Lichter etwas heller.\n\n"
            .. "• Mitteltöne: hebt oder senkt alles dazwischen gleichmäßig (unter 1,0 dunkler).\n"
            .. "• Schatten schützen: die dunkelsten Töne laufen nicht zu (leicht: wie im Original, stark: etwas heller).\n\n"
            .. "Gilt für alle Comics. Jede Seite wird nur einmal umgerechnet. KOReaders eigene Regler wirken vorher, am besten Kontrast auf 1,0.",
    },
    en = {
        menu_title = "Levels",
        enabled = "Levels on",
        enabled_help = "Main switch for quick comparison. Off = pages as without the plugin, values are kept. Also as a gesture: Settings → Taps and gestures → Gesture manager → \"Levels on/off\".",
        gesture = "Levels on/off",
        toggled_on = "Levels: on",
        toggled_off = "Levels: off",
        pivot = "Midpoint: %d",
        pivot_title = "Midpoint (0 = black, 255 = white)",
        pivot_help = "Where shadows and lights are split. Further left (smaller): more tones count as lights. Further right: more tones count as shadows. The midpoint itself keeps its brightness.",
        shadows = "Shadows: %s",
        shadows_title = "Shadows (below 0 darker, above 0 lighter)",
        shadows_help = "Raise (lighter) or lower (darker) the tones between black and the midpoint. Black stays black.",
        lights = "Lights: %s",
        lights_title = "Lights (below 0 darker, above 0 lighter)",
        lights_help = "Raise (lighter) or lower (darker) the tones between the midpoint and white. White stays white.",
        scurve = "Suggest an S-curve (more contrast)",
        scurve_done = "S-curve set: shadows -30, lights +30, midpoint 128.",
        gamma = "Mid-tones: %.2f",
        gamma_title = "Mid-tones (below 1.0 darker, above 1.0 lighter)",
        shadow = "Protect shadows: %s",
        shadow_off = "off",
        shadow_light = "light",
        shadow_strong = "strong",
        reset = "Reset all to neutral",
        about = "How does it work?",
        about_text = "Your own tone curve for comics, like in an image editor. Black stays black, white stays white.\n\n"
            .. "• Midpoint: splits shadows and lights, movable from dark (left) to bright (right).\n"
            .. "• Shadows: tones between black and the midpoint lighter (above 0) or darker (below 0).\n"
            .. "• Lights: tones between the midpoint and white lighter or darker.\n"
            .. "More contrast (S-curve): shadows a little darker, lights a little lighter.\n\n"
            .. "• Mid-tones: raises or lowers everything in between evenly (below 1.0 darker).\n"
            .. "• Protect shadows: the darkest tones don't block up (light: as in the original, strong: a little lighter).\n\n"
            .. "Applies to all comics. Each page is converted only once. KOReader's own sliders apply first, best set contrast to 1.0.",
    },
}

local function T(key, ...)
    local ok, lang = pcall(function() return G_reader_settings:readSetting("language") end)
    if not ok or type(lang) ~= "string" then
        ok, lang = pcall(function() return require("gettext").current_lang end)
    end
    local l = (ok and type(lang) == "string" and lang:sub(1, 2):lower() == "de") and "de" or "en"
    local s = strings[l][key] or strings.en[key] or key
    if select("#", ...) > 0 then
        s = string.format(s, ...)
        if l == "de" then s = s:gsub("(%d)%.(%d)", "%1,%2") end
    end
    return s
end

-- Vorzeichen immer zeigen: "+30", "-30", "0"
local function signed(v)
    if v > 0 then return "+" .. v end
    return tostring(v)
end

-- ── Einstellungen (fuer alle Comics) ─────────────────────────────────────────────────────────────
local KEY = "tonwerte"
-- pivot 0-255, shadows/lights -100..+100, gamma 0,5-1,6, shadow 0/0,5/1
local NEUTRAL = { pivot = 128, shadows = 0, lights = 0, gamma = 1.0, shadow = 0 }

local function cfg()
    local c = G_reader_settings:readSetting(KEY) or {}
    return {
        on = c.off ~= true,
        pivot = tonumber(c.pivot) or NEUTRAL.pivot,
        shadows = tonumber(c.shadows) or NEUTRAL.shadows,
        lights = tonumber(c.lights) or NEUTRAL.lights,
        gamma = tonumber(c.gamma) or NEUTRAL.gamma,
        shadow = tonumber(c.shadow) or NEUTRAL.shadow,
    }
end

local function save(key, value)
    local c = G_reader_settings:readSetting(KEY) or {}
    c[key] = value
    G_reader_settings:saveSetting(KEY, c)
end

local function active(c)
    return c.on and (c.shadows ~= 0 or c.lights ~= 0 or math.abs(c.gamma - 1) > 0.001 or c.shadow > 0)
end

-- ── Tabelle ──────────────────────────────────────────────────────────────────────────────────────
local SHADOW_TOP = 0.35  -- Schattenschutz wirkt unterhalb dieser Helligkeit, weich auslaufend
local SHADOW_LIFT = 0.8  -- Ziel in den Schatten: v^0,8 (etwas heller als das Original)

local Tonwerte = WidgetContainer:extend{
    name = "tonwerte",
    is_doc_only = true,
}

-- Ein Abschnitt der Kurve (0-1 auf 0-1), um `a` (-1..+1) nach oben oder unten gebogen.
-- u + a*u*(1-u) bleibt fuer |a| <= 1 immer steigend: keine Spruenge, keine umgedrehten Toene.
local function bend(u, a)
    return u + a * u * (1 - u)
end

--- Tabelle 0-255: Kurve (Mittelpunkt, Schatten, Lichter), dann Mitteltoene, dann Schattenschutz
function Tonwerte.buildTable(pivot, shadows, lights, gamma, shadow)
    local lut = ffi.new("uint8_t[256]")
    local p = math.min(0.9, math.max(0.1, pivot / 255))
    local sa, la = shadows / 100, lights / 100
    local inv = 1 / gamma
    for i = 0, 255 do
        local v = i / 255
        local c
        if v <= p then
            c = p * bend(v / p, sa)
        else
            c = p + (1 - p) * bend((v - p) / (1 - p), la)
        end
        c = c ^ inv
        if shadow > 0 and v < SHADOW_TOP then
            local x = v / SHADOW_TOP
            local s = 1 - x * x * (3 - 2 * x)
            c = c + (v ^ SHADOW_LIFT - c) * s * shadow
        end
        if c < 0 then c = 0 elseif c > 1 then c = 1 end
        lut[i] = math.floor(c * 255 + 0.5)
    end
    return lut
end

-- Eine Schleife ohne Verzweigungen: jedes Farb-Byte durch die Tabelle (Alpha bleibt).
local function applyRGB32(bb, lut)
    local px = ffi.cast("uint8_t *", bb.data)
    local stride, w = tonumber(bb.stride), bb.w
    for y = 0, bb.h - 1 do
        local row = px + y * stride
        for o = 0, w * 4 - 1, 4 do
            row[o] = lut[row[o]]
            row[o + 1] = lut[row[o + 1]]
            row[o + 2] = lut[row[o + 2]]
        end
    end
end

local function apply8(bb, lut)
    local px = ffi.cast("uint8_t *", bb.data)
    local stride, w = tonumber(bb.stride), bb.w
    for y = 0, bb.h - 1 do
        local row = px + y * stride
        for x = 0, w - 1 do
            row[x] = lut[row[x]]
        end
    end
end

Tonwerte.applyRGB32 = applyRGB32

-- ── Einhaengen ───────────────────────────────────────────────────────────────────────────────────
local SLOW = 3 -- Sekunden: so lange darf eine Seite nie dauern (normal Bruchteile)

if not Document._tonwerte_patched then
    Document._tonwerte_patched = true
    local orig_render = Document.renderPage
    local orig_full_hash = Document.getFullPageHash
    local orig_part_hash = Document.getPagePartHash

    local function suffix()
        local c = cfg()
        if not active(c) then return "" end
        return string.format("|tw%d/%d/%d/%.2f/%.1f", c.pivot, c.shadows, c.lights, c.gamma, c.shadow)
    end

    function Document:getFullPageHash(...)
        return orig_full_hash(self, ...) .. suffix()
    end

    function Document:getPagePartHash(...)
        return orig_part_hash(self, ...) .. suffix()
    end

    -- Feste Parameter: Panel Zoom erkennt daran die Form von renderPage (debug.getinfo().nparams).
    function Document:renderPage(pageno, rect, zoom, rotation, gamma, saturation, hinting)
        local tile = orig_render(self, pageno, rect, zoom, rotation, gamma, saturation, hinting)
        local c = cfg()
        if tile and tile.bb and not tile.tonwerte_done and active(c) then
            local t = tile.bb:getType()
            local rgb = t == Blitbuffer.TYPE_BBRGB32
            if rgb or t == Blitbuffer.TYPE_BB8 then
                local t0 = os.clock()
                local lut = Tonwerte.buildTable(c.pivot, c.shadows, c.lights, c.gamma, c.shadow)
                if rgb then applyRGB32(tile.bb, lut) else apply8(tile.bb, lut) end
                local took = os.clock() - t0
                logger.info(string.format("Tonwerte: page %s %dx%d: %.2f s", tostring(pageno), tile.bb.w, tile.bb.h, took))
                if took > SLOW then
                    -- LuaJIT hat die Schleife aufgegeben: Uebersetzer zuruecksetzen, statt langsam zu bleiben
                    logger.warn("Tonwerte: page took", took, "s, flushing the JIT")
                    pcall(function() require("jit").flush() end)
                end
                tile.tonwerte_done = true
                tile.persistent = false
            end
        end
        return tile
    end
end

-- ── Plugin ───────────────────────────────────────────────────────────────────────────────────────
function Tonwerte:init()
    self.ui.menu:registerToMainMenu(self)
    local ok, Dispatcher = pcall(require, "dispatcher")
    if ok and Dispatcher.registerAction then
        Dispatcher:registerAction("tonwerte_toggle", {
            category = "none", event = "TonwerteToggle", title = T("gesture"), reader = true,
        })
    end
end

function Tonwerte:refresh()
    DocCache:clear()
    if self.ui.view then self.ui.view:recalculate() end
    UIManager:setDirty("all", "full")
end

function Tonwerte:onTonwerteToggle()
    save("off", cfg().on or nil)
    self:refresh()
    local text = cfg().on and T("toggled_on") or T("toggled_off")
    local ok, Notification = pcall(require, "ui/widget/notification")
    if ok and Notification.notify then Notification:notify(text) else UIManager:show(InfoMessage:new{ text = text, timeout = 1 }) end
    return true
end

function Tonwerte:addToMainMenu(menu_items)
    local function spin(title, key, min, max, step, precision)
        return function(touchmenu_instance)
            UIManager:show(SpinWidget:new{
                title_text = title,
                value = cfg()[key],
                default_value = NEUTRAL[key],
                value_min = min, value_max = max,
                value_step = step, value_hold_step = step * 5,
                precision = precision,
                ok_always_enabled = true,
                callback = function(s)
                    if not s then return end
                    save(key, s.value)
                    self:refresh()
                    if touchmenu_instance then touchmenu_instance:updateItems() end
                end,
            })
        end
    end
    local shadow_items = {}
    for _, s in ipairs({ { 0, "shadow_off" }, { 0.5, "shadow_light" }, { 1, "shadow_strong" } }) do
        shadow_items[#shadow_items + 1] = {
            text = T(s[2]),
            radio = true,
            checked_func = function() return math.abs(cfg().shadow - s[1]) < 0.01 end,
            callback = function() save("shadow", s[1]); self:refresh() end,
        }
    end
    menu_items.tonwerte = {
        text = T("menu_title"),
        sorting_hint = "tools",
        sub_item_table = {
            {
                text = T("enabled"),
                help_text = T("enabled_help"),
                checked_func = function() return cfg().on end,
                callback = function()
                    save("off", cfg().on or nil)
                    self:refresh()
                end,
                separator = true,
            },
            {
                text_func = function() return T("shadows", signed(cfg().shadows)) end,
                help_text = T("shadows_help"),
                keep_menu_open = true,
                callback = spin(T("shadows_title"), "shadows", -100, 100, 5, "%d"),
            },
            {
                text_func = function() return T("pivot", cfg().pivot) end,
                help_text = T("pivot_help"),
                keep_menu_open = true,
                callback = spin(T("pivot_title"), "pivot", 30, 225, 5, "%d"),
            },
            {
                text_func = function() return T("lights", signed(cfg().lights)) end,
                help_text = T("lights_help"),
                keep_menu_open = true,
                callback = spin(T("lights_title"), "lights", -100, 100, 5, "%d"),
            },
            {
                text = T("scurve"),
                keep_menu_open = true,
                callback = function(touchmenu_instance)
                    save("shadows", -30); save("lights", 30); save("pivot", 128)
                    self:refresh()
                    UIManager:show(InfoMessage:new{ text = T("scurve_done"), timeout = 3 })
                    if touchmenu_instance then touchmenu_instance:updateItems() end
                end,
                separator = true,
            },
            {
                text_func = function() return T("gamma", cfg().gamma) end,
                keep_menu_open = true,
                callback = spin(T("gamma_title"), "gamma", 0.5, 1.6, 0.05, "%.2f"),
            },
            {
                text_func = function()
                    local v = cfg().shadow
                    return T("shadow", v >= 0.99 and T("shadow_strong") or v > 0 and T("shadow_light") or T("shadow_off"))
                end,
                sub_item_table = shadow_items,
            },
            {
                text = T("reset"),
                keep_menu_open = true,
                callback = function(touchmenu_instance)
                    for k, v in pairs(NEUTRAL) do save(k, v) end
                    self:refresh()
                    if touchmenu_instance then touchmenu_instance:updateItems() end
                end,
                separator = true,
            },
            {
                text = T("about"),
                keep_menu_open = true,
                callback = function() UIManager:show(InfoMessage:new{ text = T("about_text") }) end,
            },
        },
    }
end

return Tonwerte
