-- Test (Windows-Claude, 2.11.2026): Tonwerte mit S-Kurve. Tabelle (Mittelpunkt, Schatten, Lichter, Mitteltoene,
-- Schattenschutz), Seite korrigiert, Panel-Zoom-Form, Schalter/Geste, Menue, Dauertest (Zeit pro Seite stabil),
-- und ein Bild der Kurven (kurven.ppm) zum Ansehen.
local UIManager = require("ui/uimanager")
local Event = require("ui/event")
local OUT = os.getenv("TONWERTE_TEST_OUT") or "."
local f = io.open(OUT .. "/tonwerte-results.txt", "w")
local function log(...) local p = {} for i = 1, select("#", ...) do p[#p+1] = tostring(select(i, ...)) end f:write(table.concat(p, " ") .. "\n"); f:flush() end
local function check(n, ok) log(ok and "PASS" or "FAIL", n) end

G_reader_settings:delSetting("tonwerte")

UIManager:scheduleIn(5, function()
  local ok, e = pcall(function()
    local ui = require("apps/reader/readerui").instance
    local doc = ui.document
    local tw = ui.tonwerte
    local DocCache = require("document/doccache")
    local Document = require("document/document")
    check("Plugin geladen", tw ~= nil and Document._tonwerte_patched == true)
    local info = debug.getinfo(doc.renderPage, "u")
    check("Panel Zoom erkennt neue Form (8 Parameter)", info.nparams >= 8 and not info.isvararg)

    -- Tabelle
    local B = tw.buildTable
    local n = B(128, 0, 0, 1.0, 0)
    check("neutral: Identitaet", n[0] == 0 and n[64] == 64 and n[128] == 128 and n[200] == 200 and n[255] == 255)
    local s = B(128, -30, 30, 1.0, 0)
    log("INFO S-Kurve -30/+30 bei 32/64/128/192/224:", s[32], s[64], s[128], s[192], s[224])
    check("S-Kurve: Schwarz und Weiss bleiben", s[0] == 0 and s[255] == 255)
    check("S-Kurve: Mittelpunkt bleibt", math.abs(s[128] - 128) <= 1)
    check("S-Kurve: Schatten dunkler, Lichter heller", s[64] < 64 and s[192] > 192)
    local mono = true
    for _, a in ipairs({ { 128, -100, 100 }, { 60, 100, -100 }, { 200, -100, -100 }, { 30, 100, 100 } }) do
      local t = B(a[1], a[2], a[3], 1.0, 0)
      for i = 1, 255 do if t[i] < t[i - 1] then mono = false end end
    end
    check("Kurve immer steigend, auch bei Extremwerten", mono)
    local m = B(60, -50, 0, 1.0, 0)
    check("Mittelpunkt 60: bleibt an seiner Stelle, darunter dunkler", math.abs(m[60] - 60) <= 1 and m[30] < 30 and m[150] == 150)
    local g = B(128, 0, 0, 0.8, 1)
    check("Mitteltoene + Schatten schuetzen wie bisher", g[0] == 0 and g[25] > 25 and g[128] < 128)

    -- Seite korrigiert, nur wenn aktiv
    local function tile() return doc:renderPage(1, nil, 1.0, 0, 1.0, 1.0) end
    DocCache:clear()
    check("neutral: Seite unveraendert", tile().tonwerte_done == nil)
    G_reader_settings:saveSetting("tonwerte", { shadows = -30, lights = 30 })
    DocCache:clear()
    local a = tile()
    check("aktiv: Seite korrigiert, nicht auf Platte", a.tonwerte_done == true and a.persistent == false)
    check("Zwischenspeicher-Schluessel mit Werten", doc:getFullPageHash(1, 1.0, 0, 1.0, 1.0):find("|tw128/-30/30/1.00/0.0", 1, true) ~= nil)

    -- Schalter, Geste, Menue
    ui:handleEvent(Event:new("TonwerteToggle"))
    DocCache:clear()
    check("Geste: aus", tile().tonwerte_done == nil)
    ui:handleEvent(Event:new("TonwerteToggle"))
    DocCache:clear()
    check("Geste: wieder an", tile().tonwerte_done == true)
    local items = {}; tw:addToMainMenu(items)
    local sub = items.tonwerte.sub_item_table
    log("INFO Menue:", sub[2].text_func(), "|", sub[3].text_func(), "|", sub[4].text_func())
    check("Menue: Schalter oben, Schatten/Mittelpunkt/Lichter, Anleitung zuletzt",
      sub[1].text == "Tonwerte an" and sub[2].text_func() == "Schatten: -30" and sub[3].text_func() == "Mittelpunkt: 128"
      and sub[4].text_func() == "Lichter: +30" and sub[#sub].text == "Wie funktioniert das?")
    sub[5].callback()
    local c = G_reader_settings:readSetting("tonwerte")
    check("S-Kurve vorschlagen setzt -30/+30/128", c.shadows == -30 and c.lights == 30 and c.pivot == 128)
    while UIManager:getTopmostVisibleWidget() and UIManager:getTopmostVisibleWidget().name ~= "ReaderUI" do
      UIManager:close(UIManager:getTopmostVisibleWidget())
    end

    -- Dauertest: 300 Seiten in Kobo-Groesse, Einstellungen wechseln
    local zoom = 1680 / doc:getPageDimensions(1, 1, 0).h
    local times = {}
    local settings = {
      { shadows = -30, lights = 30 }, { shadows = 40, lights = -20, pivot = 90, gamma = 0.8, shadow = 1 },
      { lights = 50, pivot = 180 }, { shadows = -60, shadow = 0.5 },
    }
    for k = 1, 300 do
      G_reader_settings:saveSetting("tonwerte", settings[(k % #settings) + 1])
      DocCache:clear()
      local t0 = os.clock()
      doc:renderPage((k % doc:getPageCount()) + 1, nil, zoom, 0, 1.0, 1.0)
      times[#times + 1] = os.clock() - t0
    end
    local function avg(a2, b2) local s2 = 0 for i = a2, b2 do s2 = s2 + times[i] end return s2 / (b2 - a2 + 1) end
    local first, last = avg(1, 50), avg(251, 300)
    log(string.format("INFO Dauertest (Seite zeichnen + Tonwerte): erste 50 %.3f s, letzte 50 %.3f s", first, last))
    check("Dauertest: Zeit pro Seite bleibt stabil", last < first * 2)

    -- Bild der Kurven (256 x 256 je Kurve, nebeneinander): neutral, S-Kurve, Mittelpunkt 60 Schatten -50,
    -- Lichter +60 Mittelpunkt 180, Mitteltoene 0,8 + Schatten schuetzen stark
    local curves = { B(128, 0, 0, 1.0, 0), B(128, -30, 30, 1.0, 0), B(60, -50, 0, 1.0, 0), B(180, 0, 60, 1.0, 0), B(128, 0, 0, 0.8, 1) }
    local W, H = 256 * #curves + 10 * (#curves - 1), 256
    local img = {}
    for i = 1, W * H do img[i] = 255 end
    for k, lut in ipairs(curves) do
      local x0 = (k - 1) * 266
      for x = 0, 255 do
        img[(255 - x) * W + x0 + x + 1] = 180 -- Diagonale (unveraendert)
        local y = 255 - lut[x]
        for dy = -1, 1 do
          local yy = y + dy
          if yy >= 0 and yy < 256 then img[yy * W + x0 + x + 1] = 0 end
        end
      end
    end
    local pf = io.open(OUT .. "/kurven.ppm", "wb")
    pf:write(string.format("P5\n%d %d\n255\n", W, H))
    local bytes = {}
    for i = 1, W * H do bytes[i] = string.char(img[i]) end
    pf:write(table.concat(bytes))
    pf:close()
    G_reader_settings:delSetting("tonwerte")
  end)
  if not ok then log("ERROR", e) end
  f:close(); UIManager:quit()
end)
