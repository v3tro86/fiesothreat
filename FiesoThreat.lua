-- Fiesokic & Giftbräu Addon Manufaktur
local ADDON = ...
local VERSION = "1.8.0"
local PREFIX = "|cff33ccffFiesoThreat|r: "

local format = string.format
local floor = math.floor
local issecret = issecretvalue or function() return false end

-- true nur, wenn v ein lesbarer, wahrer Wert ist
local function truthy(v)
    if issecret(v) then return false end
    return v and true or false
end

-- true nur, wenn v lesbar und nicht nil ist
local function plain(v)
    if issecret(v) then return false end
    return v ~= nil
end

------------------------------------------------------------------------
-- Texte
------------------------------------------------------------------------
local GERMAN = GetLocale and GetLocale() == "deDE"
local L
if GERMAN then
    L = {
        idle = "FiesoThreat",
        aggro = "AGGRO",
        design = "Design",
        view = "Ansicht",
        optDps = "DPS / Heiler",
        optTank = "Tank",
        viewSet = "Ansicht: %s",
        tankMode = "Tank-Modus",
        tankModeDps = "Tank-Modus (nur DPS)",
        modeLocked = "In der Tank-Ansicht ist der Tank-Modus aus. Erst /ft dps wählen.",
        display = "Anzeige",
        optLead = "Tank-Vorsprung (+x %)",
        optOver = "Über dem Tank (+x %)",
        optSteal = "Aggro-Klau melden",
        optValues = "Rohwerte",
        optGlow = "Rahmen leuchten",
        optLocked = "Fenster fixieren",
        optTest = "Testmodus",
        hasAggro = "%s hat Aggro!",
        youAggro = "Du hast Aggro!",
        locked = "Fenster fixiert.",
        unlocked = "Fenster frei – oben ziehen zum Verschieben, Ecke unten rechts für die Grösse.",
        shown = "Fenster eingeblendet.",
        hidden = "Fenster ausgeblendet (/ft show).",
        reset = "Einstellungen zurückgesetzt.",
        warn = "Warnung ab %d%% Bedrohung.",
        glowOn = "Leuchtender Rahmen an.",
        glowOff = "Leuchtender Rahmen aus (Alarm blinkt weiterhin).",
        valuesOn = "Rohwerte werden angezeigt.",
        valuesOff = "Nur Prozent werden angezeigt.",
        alwaysOn = "Fenster bleibt auch ohne Kampf sichtbar.",
        alwaysOff = "Fenster nur bei Bedrohung sichtbar.",
        mode = "Tank-Modus: %s",
        optOff = "Aus",
        testOn = "Testmodus an (nochmal /ft test zum Beenden).",
        testOff = "Testmodus aus.",
        theme = "Design: %s",
        scale = "Skalierung: %.2f",
        rows = "Höhe für %d Balken.",
        width = "Breite: %d",
        badNumber = "Ungültiger Wert. Erlaubt: %s",
        badTheme = "Unbekanntes Design. Verfügbar: modern, glas, klassisch",
        help = {
            "Befehle (/ft oder /fiesothreat):",
            "  menu – Einstellungen öffnen (auch über den Knopf oben rechts)",
            "  lock / unlock – Fenster fixieren / verschieben und Grösse ändern",
            "  show / hide / toggle – Fenster ein-/ausblenden",
            "  theme [modern|glas|klassisch] – Design wechseln",
            "  tank / dps – Ansicht wählen (Farben aus Sicht des Tanks oder DPS)",
            "  polster / over / klau / aus – Tank-Modus wählen",
            "  warn <50-100> – Warnschwelle in Prozent",
            "  glow – leuchtenden Rahmen an/aus",
            "  values – Rohwerte an/aus",
            "  always – auch ohne Bedrohung anzeigen",
            "  scale <0.5-2> · rows <1-25> · width <160-500>",
            "  test – Beispieldaten anzeigen",
            "  reset – alles zurücksetzen",
        },
    }
else
    L = {
        idle = "FiesoThreat",
        aggro = "AGGRO",
        design = "Theme",
        view = "View",
        optDps = "DPS / Healer",
        optTank = "Tank",
        viewSet = "View: %s",
        tankMode = "Tank mode",
        tankModeDps = "Tank mode (DPS only)",
        modeLocked = "Tank mode is off in tank view. Choose /ft dps first.",
        display = "Display",
        optLead = "Tank lead (+x%)",
        optOver = "Above the tank (+x%)",
        optSteal = "Aggro steal alert",
        optValues = "Raw values",
        optGlow = "Glowing border",
        optLocked = "Lock window",
        optTest = "Test mode",
        hasAggro = "%s has aggro!",
        youAggro = "You have aggro!",
        locked = "Window locked.",
        unlocked = "Window unlocked – drag the top to move, the bottom-right corner to resize.",
        shown = "Window shown.",
        hidden = "Window hidden (/ft show).",
        reset = "Settings reset.",
        warn = "Warning at %d%% threat.",
        glowOn = "Glowing border on.",
        glowOff = "Glowing border off (alarm still pulses).",
        valuesOn = "Raw values shown.",
        valuesOff = "Percent only.",
        alwaysOn = "Window stays visible without threat.",
        alwaysOff = "Window only visible with threat.",
        mode = "Tank mode: %s",
        optOff = "Off",
        testOn = "Test mode on (/ft test again to stop).",
        testOff = "Test mode off.",
        theme = "Theme: %s",
        scale = "Scale: %.2f",
        rows = "Height for %d bars.",
        width = "Width: %d",
        badNumber = "Invalid value. Allowed: %s",
        badTheme = "Unknown theme. Available: modern, glass, classic",
        help = {
            "Commands (/ft or /fiesothreat):",
            "  menu – open settings (also the button top right)",
            "  lock / unlock – lock, or move and resize the window",
            "  show / hide / toggle – show or hide the window",
            "  theme [modern|glass|classic] – switch theme",
            "  tank / dps – choose view (colors from the tank's or DPS's side)",
            "  lead / over / steal / off – choose tank mode",
            "  warn <50-100> – warning threshold in percent",
            "  glow – glowing border on/off",
            "  values – raw values on/off",
            "  always – show even without threat",
            "  scale <0.5-2> · rows <1-25> · width <160-500>",
            "  test – show sample data",
            "  reset – reset everything",
        },
    }
end

local function Print(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. msg)
    else
        print(PREFIX .. msg)
    end
end

------------------------------------------------------------------------
-- Designs
------------------------------------------------------------------------
local WHITE = "Interface\\Buttons\\WHITE8x8"
local FONT_CLEAN = "Fonts\\ARIALN.TTF"
local FONT_CLASSIC = "Fonts\\FRIZQT__.TTF"

local THEMES = {
    modern = {
        label = "Modern",
        bar = WHITE, gloss = 0.16, font = FONT_CLEAN, size = 12, big = 15,
        bg = { 0.04, 0.05, 0.07, 0.88 }, border = { 0, 0, 0, 1 }, edge = { 1, 1, 1, 0.06 },
        headTop = { 0.15, 0.16, 0.20, 1 }, headBottom = { 0.07, 0.08, 0.10, 1 },
        title = { 1, 0.82, 0.30 }, rowBg = 0.25, rowBgAlpha = 0.75, gap = 2,
    },
    glass = {
        label = "Glas",
        bar = WHITE, gloss = 0.24, font = FONT_CLEAN, size = 12, big = 15,
        bg = { 0.02, 0.03, 0.05, 0.40 }, border = { 1, 1, 1, 0.14 }, edge = { 1, 1, 1, 0.10 },
        headTop = { 1, 1, 1, 0.12 }, headBottom = { 1, 1, 1, 0.02 },
        title = { 0.85, 0.93, 1 }, rowBg = 0.30, rowBgAlpha = 0.35, gap = 2,
    },
    classic = {
        label = "Klassisch",
        bar = "Interface\\TargetingFrame\\UI-StatusBar", gloss = 0, font = FONT_CLASSIC, size = 11, big = 13,
        bg = { 0, 0, 0, 0.70 }, border = { 0.78, 0.62, 0.26, 0.95 }, edge = { 0, 0, 0, 0 },
        headTop = { 0.30, 0.22, 0.06, 0.95 }, headBottom = { 0.12, 0.08, 0.02, 0.95 },
        title = { 1, 0.82, 0 }, rowBg = 0.15, rowBgAlpha = 0.6, gap = 1,
    },
}
local THEME_ALIAS = {
    modern = "modern", glas = "glass", glass = "glass",
    klassisch = "classic", classic = "classic", klassik = "classic",
}
local THEME_ORDER = { "modern", "glass", "classic" }

local function ThemeLabel(key)
    if not GERMAN and key == "glass" then return "Glass" end
    if not GERMAN and key == "classic" then return "Classic" end
    return THEMES[key].label
end

------------------------------------------------------------------------
-- Masse
------------------------------------------------------------------------
local ROW_H, HEADER_H, ACCENT_H, PAD = 18, 22, 2, 4
local GLOW_SIZE, GLOW_ALPHA = 8, 0.55
local TOP = 1 + HEADER_H + ACCENT_H          -- Rahmen + Kopf + Akzentleiste
local MIN_W, MAX_W, MAX_H = 160, 500, 640

-- Fensterhöhe für n Balken bei gegebenem Zeilenabstand
local function HeightFor(n, gap)
    return TOP + PAD * 2 + n * (ROW_H + gap) - gap + 1
end

-- Wie viele Balken passen in die Höhe h?
local function Capacity(h, gap)
    local n = floor((h - TOP - PAD * 2 - 1 + gap) / (ROW_H + gap))
    if n < 1 then n = 1 end
    return n
end

------------------------------------------------------------------------
-- Einstellungen
------------------------------------------------------------------------
local TANK_MODES = { off = true, lead = true, over = true, steal = true }
local TANK_ORDER = { "lead", "over", "steal", "off" }
local TANK_ALIAS = {
    lead = "lead", polster = "lead", vorsprung = "lead",
    over = "over", ["über"] = "over", ueber = "over",
    steal = "steal", klau = "steal",
    off = "off", aus = "off",
}

local defaults = {
    point = "CENTER", relPoint = "CENTER", x = 260, y = -140,
    scale = 1, width = 230, height = HeightFor(8, 2), warn = 90, theme = "modern",
    glow = true, values = true, always = false, locked = false, shown = true,
    tankMode = "lead", view = "dps",
}
local db = {}
for k, v in pairs(defaults) do db[k] = v end

local function LoadDB()
    -- Die Forever-Beta hat kontoweite SavedVariables zeitweise nicht wieder
    -- eingelesen. Darum zeigen Konto- und Charaktervariable auf dieselbe
    -- Tabelle; geladen wird, was vorhanden ist.
    local saved = FiesoThreatDB
    if type(saved) ~= "table" then saved = FiesoThreatCharDB end
    if type(saved) ~= "table" then saved = {} end
    -- Version 1.0/1.1 speicherte eine Balkenzahl statt einer Höhe
    if saved.height == nil and type(saved.rows) == "number" then
        saved.height = HeightFor(saved.rows, 2)
    end
    saved.rows = nil
    saved.sound = nil   -- Warnton gibt es nicht mehr
    -- Version 1.2/1.3 hatte drei Schalter; jetzt gilt genau ein Tank-Modus
    if saved.tankMode == nil and saved.lead == false then
        if saved.over ~= false then saved.tankMode = "over"
        elseif saved.steal ~= false then saved.tankMode = "steal"
        else saved.tankMode = "off" end
    end
    saved.lead, saved.over, saved.steal = nil, nil, nil
    for k, v in pairs(defaults) do
        if type(saved[k]) ~= type(v) then saved[k] = v end
    end
    if not THEMES[saved.theme] then saved.theme = defaults.theme end
    if not TANK_MODES[saved.tankMode] then saved.tankMode = defaults.tankMode end
    if saved.view ~= "tank" and saved.view ~= "dps" then saved.view = defaults.view end
    db = saved
    FiesoThreatDB = saved
    FiesoThreatCharDB = saved
end

local function Theme() return THEMES[db.theme] or THEMES.modern end
local function ActiveMode()
    if db.view == "tank" then return "off" end
    return db.tankMode
end
local function Mode(m) return ActiveMode() == m end

------------------------------------------------------------------------
-- Bausteine
------------------------------------------------------------------------
local PET_COLOR = { r = 0.55, g = 0.75, b = 0.45 }
local FALLBACK_COLOR = { r = 0.6, g = 0.6, b = 0.6 }

-- VERTICAL: a = unten, b = oben · HORIZONTAL: a = links, b = rechts
local function Gradient(tex, a, b, dir)
    tex:SetColorTexture(1, 1, 1, 1)
    if CreateColor and pcall(tex.SetGradient, tex, dir or "VERTICAL",
        CreateColor(a[1], a[2], a[3], a[4]), CreateColor(b[1], b[2], b[3], b[4])) then
        return
    end
    tex:SetColorTexture(b[1], b[2], b[3], b[4])
end

local function Font(fs, size, flags)
    if GameFontHighlightSmall then fs:SetFontObject(GameFontHighlightSmall) end
    fs:SetFont(Theme().font, size, flags or "")
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 0.9)
end

-- Rahmen aus vier Texturen
local function MakeBorder(parent, layer, size)
    local b = {}
    for i = 1, 4 do b[i] = parent:CreateTexture(nil, layer) end
    b[1]:SetPoint("TOPLEFT");    b[1]:SetPoint("TOPRIGHT");    b[1]:SetHeight(size)
    b[2]:SetPoint("BOTTOMLEFT"); b[2]:SetPoint("BOTTOMRIGHT"); b[2]:SetHeight(size)
    b[3]:SetPoint("TOPLEFT");    b[3]:SetPoint("BOTTOMLEFT");  b[3]:SetWidth(size)
    b[4]:SetPoint("TOPRIGHT");   b[4]:SetPoint("BOTTOMRIGHT"); b[4]:SetWidth(size)
    return b
end

local function BorderColor(b, c)
    for i = 1, 4 do b[i]:SetColorTexture(c[1], c[2], c[3], c[4]) end
end

-- Balken gleiten weich zum Zielwert. Geheime Werte werden direkt gesetzt.
local smoothBars = {}
local function SetBar(bar, v, secret)
    if secret then
        bar.smooth = false
        bar:SetValue(v)
        return
    end
    if v > 100 then v = 100 elseif v < 0 then v = 0 end
    bar.target = v
    if not bar.smooth then
        bar.smooth = true
        bar.cur = bar.cur or 0
    end
end

local function Hex(r, g, b)
    return format("%02x%02x%02x", floor(r * 255 + 0.5), floor(g * 255 + 0.5), floor(b * 255 + 0.5))
end

local function PctColor(p)
    if p >= db.warn then return 1, 0.19, 0.19 end
    if p >= 60 then return 1, 0.82, 0 end
    return 0.25, 1, 0.35
end

-- Farbe für deinen eigenen Wert, je nach Ansicht:
--   DPS:  wenig Bedrohung = grün, nahe am Aggro-Ziehen = rot
--   Tank: Aggro (100 %+) = grün, wenig Bedrohung = rot
local function MyColor(p, tanking)
    if db.view == "tank" then
        if tanking or p >= 100 then return 0.25, 1, 0.35 end
        if p >= 60 then return 1, 0.82, 0 end
        return 1, 0.19, 0.19
    end
    return PctColor(p)
end

-- Farbe für den Tank-Vorsprung: viel Polster grün, wenig rot
local function LeadColor(p)
    if p >= 30 then return "40ff59" end
    if p >= 10 then return "ffd100" end
    return "ff3030"
end

local OVER_COLOR = "ff8c1a"

------------------------------------------------------------------------
-- Fenster
------------------------------------------------------------------------
local frame, glow, grip, menu
local Update, ToggleMenu     -- weiter unten definiert
local rows = {}
local fadeTarget = 0
local bannerUntil = 0

local function RowTop(i)
    return -(TOP + PAD + (i - 1) * (ROW_H + Theme().gap))
end

local function SaveGeometry()
    local point, _, relPoint, x, y = frame:GetPoint(1)
    if point then
        db.point, db.relPoint, db.x, db.y = point, relPoint or point, x or 0, y or 0
    end
    local w, h = frame:GetWidth(), frame:GetHeight()
    if w and w > 0 then db.width = floor(w + 0.5) end
    if h and h > 0 then db.height = floor(h + 0.5) end
end

local function PlaceTick(row)
    local x = (db.width - PAD * 2) * db.warn / 100
    row.tick:ClearAllPoints()
    row.tick:SetPoint("TOP", row, "TOPLEFT", x, 0)
    row.tick:SetPoint("BOTTOM", row, "BOTTOMLEFT", x, 0)
end

local function StyleRow(row, i)
    local t = Theme()
    local y = RowTop(i)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, y)
    row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PAD, y)
    row:SetStatusBarTexture(t.bar)

    if t.gloss > 0 then
        Gradient(row.gloss, { 1, 1, 1, 0 }, { 1, 1, 1, t.gloss })
        row.gloss:Show()
    else
        row.gloss:Hide()
    end
    PlaceTick(row)

    Font(row.rank, t.size - 1)
    row.rank:SetTextColor(0.75, 0.75, 0.75)
    Font(row.name, t.size)
    Font(row.text, t.size)
    -- Rohwert: komplett weiss, wirkt fett durch weissen Rand
    -- (weisser Schatten nach rechts + zweite Kopie 1 px höher)
    for _, fs in ipairs({ row.val, row.valEdge }) do
        Font(fs, t.size + 1)
        fs:SetTextColor(1, 1, 1)
        fs:SetShadowColor(1, 1, 1, 1)
        fs:SetShadowOffset(1, 0)
    end
end

local function ApplyLayout()
    if not frame then return end
    local t = Theme()
    local minH = HeightFor(1, t.gap)
    if db.width < MIN_W then db.width = MIN_W elseif db.width > MAX_W then db.width = MAX_W end
    if db.height < minH then db.height = minH elseif db.height > MAX_H then db.height = MAX_H end

    frame:SetScale(db.scale)
    frame:SetSize(db.width, db.height)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(MIN_W, minH, MAX_W, MAX_H)
    elseif frame.SetMinResize then
        frame:SetMinResize(MIN_W, minH)
        frame:SetMaxResize(MAX_W, MAX_H)
    end
    frame:EnableMouse(not db.locked)
    frame:ClearAllPoints()
    frame:SetPoint(db.point, UIParent, db.relPoint, db.x, db.y)
    if db.locked then grip:Hide() else grip:Show() end

    frame.bg:SetColorTexture(t.bg[1], t.bg[2], t.bg[3], t.bg[4])
    BorderColor(frame.border, t.border)
    frame.edge:SetColorTexture(t.edge[1], t.edge[2], t.edge[3], t.edge[4])
    Gradient(frame.head, t.headBottom, t.headTop)
    frame.accentBg:SetColorTexture(0, 0, 0, 0.5)
    Font(frame.title, t.size + 1)
    frame.title:SetTextColor(t.title[1], t.title[2], t.title[3])
    Font(frame.mine, t.big)

    for i = 1, #rows do StyleRow(rows[i], i) end
end

local function CreateUI()
    frame = CreateFrame("Frame", "FiesoThreatFrame", UIParent)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if not db.locked then self:StartMoving() end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveGeometry()
    end)
    -- Während des Ziehens an der Ecke live mitzeichnen
    frame:SetScript("OnSizeChanged", function(_, w)
        if w and w > 0 then
            db.width = floor(w + 0.5)
            for i = 1, #rows do PlaceTick(rows[i]) end
        end
    end)

    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.border = MakeBorder(frame, "BORDER", 1)

    -- Kopfzeile mit Verlauf und feiner Lichtkante
    frame.head = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    frame.head:SetPoint("TOPLEFT", 1, -1)
    frame.head:SetPoint("TOPRIGHT", -1, -1)
    frame.head:SetHeight(HEADER_H)

    frame.edge = frame:CreateTexture(nil, "BORDER", nil, 1)
    frame.edge:SetPoint("TOPLEFT", 1, -1)
    frame.edge:SetPoint("TOPRIGHT", -1, -1)
    frame.edge:SetHeight(1)

    -- Einstellungsknopf (drei Striche) ganz rechts in der Kopfzeile
    local mb = CreateFrame("Button", nil, frame)
    mb:SetSize(18, 16)
    mb:SetPoint("RIGHT", frame.head, "RIGHT", -3, 0)
    mb:SetFrameLevel(frame:GetFrameLevel() + 12)
    for i = 1, 3 do
        local line = mb:CreateTexture(nil, "ARTWORK")
        line:SetColorTexture(1, 1, 1, 1)
        line:SetSize(12, 2)
        line:SetPoint("CENTER", 0, 4 - (i - 1) * 4)
    end
    mb:SetAlpha(0.55)
    mb:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
    mb:SetScript("OnLeave", function(self) self:SetAlpha(0.55) end)
    mb:SetScript("OnClick", function() ToggleMenu() end)
    frame.menuButton = mb

    frame.mine = frame:CreateFontString(nil, "OVERLAY")
    frame.mine:SetPoint("RIGHT", mb, "LEFT", -3, 0)
    frame.mine:SetJustifyH("RIGHT")

    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetPoint("LEFT", frame.head, "LEFT", 7, 0)
    frame.title:SetPoint("RIGHT", frame.mine, "LEFT", -6, 0)
    frame.title:SetJustifyH("LEFT")
    frame.title:SetWordWrap(false)

    -- Leiste unter der Kopfzeile: deine eigene Bedrohung
    frame.accent = CreateFrame("StatusBar", nil, frame)
    frame.accent:SetPoint("TOPLEFT", frame.head, "BOTTOMLEFT", 0, 0)
    frame.accent:SetPoint("TOPRIGHT", frame.head, "BOTTOMRIGHT", 0, 0)
    frame.accent:SetHeight(ACCENT_H)
    frame.accent:SetStatusBarTexture(WHITE)
    frame.accent:SetMinMaxValues(0, 100)
    frame.accent:SetValue(0)
    frame.accentBg = frame.accent:CreateTexture(nil, "BACKGROUND")
    frame.accentBg:SetAllPoints()
    smoothBars[#smoothBars + 1] = frame.accent

    -- Leuchtender Rahmen in deiner Statusfarbe: scharfe Kante + weicher Schein nach aussen
    glow = CreateFrame("Frame", nil, frame)
    glow:SetPoint("TOPLEFT", 0, 0)
    glow:SetPoint("BOTTOMRIGHT", 0, 0)
    glow:SetFrameLevel(frame:GetFrameLevel() + 10)
    glow.line = MakeBorder(glow, "OVERLAY", 1)
    local H = GLOW_SIZE
    local top = glow:CreateTexture(nil, "BACKGROUND")
    top:SetPoint("BOTTOMLEFT", glow, "TOPLEFT", 0, 0)
    top:SetPoint("BOTTOMRIGHT", glow, "TOPRIGHT", 0, 0)
    top:SetHeight(H)
    local bottom = glow:CreateTexture(nil, "BACKGROUND")
    bottom:SetPoint("TOPLEFT", glow, "BOTTOMLEFT", 0, 0)
    bottom:SetPoint("TOPRIGHT", glow, "BOTTOMRIGHT", 0, 0)
    bottom:SetHeight(H)
    local left = glow:CreateTexture(nil, "BACKGROUND")
    left:SetPoint("TOPRIGHT", glow, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMRIGHT", glow, "BOTTOMLEFT", 0, 0)
    left:SetWidth(H)
    local right = glow:CreateTexture(nil, "BACKGROUND")
    right:SetPoint("TOPLEFT", glow, "TOPRIGHT", 0, 0)
    right:SetPoint("BOTTOMLEFT", glow, "BOTTOMRIGHT", 0, 0)
    right:SetWidth(H)
    glow.halo = { top = top, bottom = bottom, left = left, right = right }
    for _, t in pairs(glow.halo) do t:SetBlendMode("ADD") end
    -- Pulsieren: ruhiges "Atmen" im Normalfall, schnelles Blinken bei Alarm
    local function Pulse(from, duration)
        local group = glow:CreateAnimationGroup()
        local a = group:CreateAnimation("Alpha")
        a:SetFromAlpha(from)
        a:SetToAlpha(1)
        a:SetDuration(duration)
        group:SetLooping("BOUNCE")
        return group
    end
    glow.breathe = Pulse(0.35, 1.2)
    frame.glow = glow
    glow.alarm = Pulse(0.15, 0.3)
    glow:Hide()

    -- Ziehgriff für die Grösse (nur sichtbar, wenn entsperrt)
    grip = CreateFrame("Button", nil, frame)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", -1, 1)
    grip:SetFrameLevel(frame:GetFrameLevel() + 12)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" and not db.locked then frame:StartSizing("BOTTOMRIGHT") end
    end)
    frame.grip = grip
    grip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        SaveGeometry()
        ApplyLayout()
    end)

    ApplyLayout()
    frame:SetAlpha(0)
    frame:Hide()
end

local function GetRow(i)
    local row = rows[i]
    if row then return row end

    row = CreateFrame("StatusBar", nil, frame)
    row:SetMinMaxValues(0, 100)
    row:SetValue(0)
    row:SetHeight(ROW_H)

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()

    row.gloss = row:CreateTexture(nil, "ARTWORK", nil, 3)  -- Glanz oben
    row.gloss:SetAllPoints()

    row.me = row:CreateTexture(nil, "ARTWORK", nil, 4)     -- eigene Zeile aufhellen
    row.me:SetAllPoints()
    row.me:SetColorTexture(1, 1, 1, 0.10)

    row.tick = row:CreateTexture(nil, "ARTWORK", nil, 5)   -- Warnschwelle
    row.tick:SetWidth(1)
    row.tick:SetColorTexture(1, 1, 1, 0.22)

    row.over = row:CreateTexture(nil, "ARTWORK", nil, 6)   -- über dem Tank
    row.over:SetPoint("TOPRIGHT")
    row.over:SetPoint("BOTTOMRIGHT")
    row.over:SetWidth(3)
    row.over:SetColorTexture(1, 0.55, 0.1, 1)

    row.aggro = row:CreateTexture(nil, "ARTWORK", nil, 6)  -- hat Aggro
    row.aggro:SetPoint("TOPLEFT")
    row.aggro:SetPoint("BOTTOMLEFT")
    row.aggro:SetWidth(3)
    row.aggro:SetColorTexture(1, 0.15, 0.1, 1)

    row.rank = row:CreateFontString(nil, "OVERLAY")
    row.rank:SetPoint("LEFT", 6, 0)
    row.rank:SetWidth(16)
    row.rank:SetJustifyH("RIGHT")

    row.text = row:CreateFontString(nil, "OVERLAY")
    row.text:SetPoint("RIGHT", -6, 0)
    row.text:SetJustifyH("RIGHT")

    row.val = row:CreateFontString(nil, "OVERLAY")
    row.val:SetPoint("RIGHT", row.text, "LEFT", -6, 0)
    row.val:SetJustifyH("RIGHT")
    row.valEdge = row:CreateFontString(nil, "OVERLAY")
    row.valEdge:SetPoint("BOTTOMRIGHT", row.val, "BOTTOMRIGHT", 0, 1)
    row.valEdge:SetJustifyH("RIGHT")

    row.name = row:CreateFontString(nil, "OVERLAY")
    row.name:SetPoint("LEFT", row.rank, "RIGHT", 5, 0)
    row.name:SetPoint("RIGHT", row.val, "LEFT", -4, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    rows[i] = row
    smoothBars[#smoothBars + 1] = row
    StyleRow(row, i)
    return row
end

local function FadeIn()
    fadeTarget = 1
    if not frame:IsShown() then
        frame:SetAlpha(0)
        frame:Show()
    end
end

local function FadeOut()
    fadeTarget = 0
end

------------------------------------------------------------------------
-- Daten
------------------------------------------------------------------------
local units = {}      -- { unit=, isPlayer=, isPet= } in Anzeigereihenfolge
local data = {}       -- aktuelle Einträge
local testMode = false
local holder          -- wer zuletzt Aggro hatte (für die Klau-Meldung)
local lastSteal = 0

local function AddUnit(unit, isPlayer, isPet)
    units[#units + 1] = { unit = unit, isPlayer = isPlayer, isPet = isPet }
end

local function BuildUnits()
    for i = #units, 1, -1 do units[i] = nil end
    AddUnit("player", true, false)
    AddUnit("pet", false, true)
    if IsInRaid and IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local u = "raid" .. i
            if not truthy(UnitIsUnit(u, "player")) then
                AddUnit(u, false, false)
                AddUnit("raidpet" .. i, false, true)
            end
        end
    elseif IsInGroup and IsInGroup() then
        for i = 1, GetNumSubgroupMembers() do
            AddUnit("party" .. i, false, false)
            AddUnit("partypet" .. i, false, true)
        end
    end
end

local function IsMob(unit)
    return truthy(UnitExists(unit))
        and truthy(UnitCanAttack("player", unit))
        and not truthy(UnitIsDead(unit))
        and not truthy(UnitIsPlayer(unit))
end

-- Ziel, sonst (für Heiler) das Ziel des anvisierten Verbündeten
local function GetMob()
    if IsMob("target") then return "target" end
    if truthy(UnitExists("target")) and IsMob("targettarget") then return "targettarget" end
end

local function Entry(n)
    local e = data[n]
    if not e then e = {}; data[n] = e end
    return e
end

local function Trim(n)
    for i = #data, n + 1, -1 do data[i] = nil end
end

local function Collect(mob)
    local n, anySecret = 0, false
    for i = 1, #units do
        local u = units[i]
        if truthy(UnitExists(u.unit)) then
            local tanking, _, pct, raw, val = UnitDetailedThreatSituation(u.unit, mob)
            local sec = issecret(pct)
            -- lesbare 0 % nur beim Spieler selbst zeigen
            if sec or (pct ~= nil and (u.isPlayer or pct > 0)) then
                n = n + 1
                local e = Entry(n)
                e.unit, e.isPlayer, e.isPet, e.order = u.unit, u.isPlayer, u.isPet, i
                e.secret, e.pct, e.val = sec, pct, val
                e.raw = (not sec and plain(raw)) and raw or nil
                e.tanking = truthy(tanking)
                e.role = nil
                e.name = UnitName(u.unit)
                local _, class = UnitClass(u.unit)
                e.class = plain(class) and class or nil
                if sec then anySecret = true end
            end
        end
    end
    Trim(n)
    return n, anySecret
end

-- name, Klasse, Prozent, Aggro, Pet, Rolle
local TEST = {
    { "Tankard", "WARRIOR", 100, true, false, "TANK" },
    { nil, nil, 0, false },              -- du selbst, Wert pendelt
    { "Frostina", "MAGE", 72, false },
    { "Pfeilhagel", "HUNTER", 55, false },
    { "Wolf", nil, 31, false, true },
    { "Lichtblick", "PRIEST", 18, false },
}

local function FillTest()
    local now = GetTime()
    local swing = 76 + 22 * math.sin(now * 0.7)
    -- alle 15 s klaut Frostina für 3 s die Aggro (zeigt Über-Tank und Klau-Meldung)
    local phase = now % 15
    local rip = phase >= 12
    for i = 1, #TEST do
        local t = TEST[i]
        local e = Entry(i)
        e.unit, e.order, e.secret = nil, i, false
        e.isPlayer, e.isPet = (t[1] == nil), t[5] or false
        e.tanking, e.role = t[4], t[6] or "DAMAGER"
        if e.isPlayer then
            e.name = UnitName("player")
            local _, class = UnitClass("player")
            e.class = plain(class) and class or nil
            e.pct = swing
        else
            e.name, e.class, e.pct = t[1], t[2], t[3]
        end
        -- Rohprozent relativ zum Tank (Aggro wechselt bei 110 %)
        e.raw = e.pct * 1.1
        if e.name == "Frostina" and phase >= 8 then
            e.pct = rip and 100 or 72 + (phase - 8) * 6.5
            e.raw = rip and 100 or e.pct * 1.1
            e.tanking = rip
        elseif e.name == "Tankard" and rip then
            e.pct, e.raw, e.tanking = 91, 91, false
        elseif e.tanking then
            e.raw = 100
        end
        e.val = e.raw * 137
    end
    if db.view == "tank" then
        -- Rollen tauschen: du tankst, "Tankard" macht Schaden
        local me, other = data[2], data[1]
        me.pct, other.pct = other.pct, me.pct
        me.raw, other.raw = other.raw, me.raw
        me.val, other.val = other.val, me.val
        me.tanking, other.tanking = other.tanking, me.tanking
        me.role, other.role = "TANK", "DAMAGER"
    end
    Trim(#TEST)
    return #TEST
end

local function ByThreat(a, b)
    if a.pct ~= b.pct then return a.pct > b.pct end
    if a.tanking ~= b.tanking then return a.tanking end
    return a.order < b.order
end

local function IsTank(e)
    if e.role then return e.role == "TANK" end
    if not e.unit then return false end
    if UnitGroupRolesAssigned then
        local r = UnitGroupRolesAssigned(e.unit)
        if plain(r) and r == "TANK" then return true end
    end
    if GetPartyAssignment then
        local ok, v = pcall(GetPartyAssignment, "MAINTANK", e.unit)
        if ok and truthy(v) then return true end
    end
    return false
end

------------------------------------------------------------------------
-- Anzeige
------------------------------------------------------------------------
local function Short(n)
    if n >= 1e6 then return format("%.1fM", n / 1e6) end
    if n >= 1e4 then return format("%.0fk", n / 1e3) end
    if n >= 1e3 then return format("%.1fk", n / 1e3) end
    return format("%.0f", n)
end

local function ClassColor(e)
    if e.isPet then return PET_COLOR end
    local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
    return (e.class and colors and colors[e.class]) or FALLBACK_COLOR
end

local glowCur = { 0, 0, 0 }
local glowTarget = { 0, 0, 0 }

local function PaintGlow(c)
    local r, g, b = c[1], c[2], c[3]
    BorderColor(glow.line, { r, g, b, 0.95 })
    local h, A = glow.halo, GLOW_ALPHA
    Gradient(h.top, { r, g, b, A }, { r, g, b, 0 })
    Gradient(h.bottom, { r, g, b, 0 }, { r, g, b, A })
    Gradient(h.left, { r, g, b, 0 }, { r, g, b, A }, "HORIZONTAL")
    Gradient(h.right, { r, g, b, A }, { r, g, b, 0 }, "HORIZONTAL")
end

-- Rahmen in Farbe r,g,b pulsierend leuchten lassen; pulse = Alarm (schnell).
-- Ohne Farbe (r = nil) aus. Ist das Leuchten abgeschaltet, bleibt nur der Alarm.
local function SetGlow(r, g, b, pulse)
    if r == nil or not (db.glow or pulse) then
        if glow:IsShown() then
            glow.breathe:Stop()
            glow.alarm:Stop()
            glow.pulse = nil
            glow:Hide()
        end
        return
    end
    glowTarget[1], glowTarget[2], glowTarget[3] = r, g, b
    if not glow:IsShown() then
        glowCur[1], glowCur[2], glowCur[3] = r, g, b
        PaintGlow(glowCur)
        glow:Show()
    end
    local want = pulse and "alarm" or "breathe"
    if glow.pulse ~= want then
        glow.pulse = want
        if pulse then glow.breathe:Stop() else glow.alarm:Stop() end
        glow[want]:Play()
    end
end

-- Meldung, wenn jemand ohne Tank-Rolle die Aggro übernimmt
local function CheckSteal(top)
    local key = top and (top.unit or top.name)
    if not top or not plain(key) then
        holder = nil
        return
    end
    local previous = holder
    holder = key
    if not Mode("steal") or previous == nil or previous == key then return end
    if IsTank(top) then return end
    if not (testMode or (IsInGroup and IsInGroup())) then return end

    local now = GetTime()
    if now - lastSteal < 2 then return end   -- kein Dauerfeuer bei Hin und Her
    lastSteal = now

    local msg
    if top.isPlayer then
        msg = L.youAggro
    elseif plain(top.name) then
        msg = format(L.hasAggro, top.name)
    end
    if not msg then return end

    frame.title:SetText("|cffff3030" .. msg .. "|r")
    bannerUntil = now + 3
    if RaidNotice_AddMessage and RaidWarningFrame then
        local color = (ChatTypeInfo and ChatTypeInfo["RAID_WARNING"]) or { r = 1, g = 0.2, b = 0.2 }
        pcall(RaidNotice_AddMessage, RaidWarningFrame, msg, color)
    end
end

local function HideRows(from)
    for i = from, #rows do
        local r = rows[i]
        if r:IsShown() then
            r:Hide()
            r.cur, r.target = 0, 0   -- beim nächsten Erscheinen von links einwachsen
            r:SetValue(0)
        end
    end
end

local function SetTitle(text)
    if GetTime() < bannerUntil then return end   -- Klau-Meldung bleibt kurz stehen
    frame.title:SetText(text)
end

function Update()
    if not frame then return end
    if not db.shown then
        SetGlow(nil)
        FadeOut()
        return
    end

    local n, anySecret, mob = 0, false, nil
    if testMode then
        n = FillTest()
    else
        mob = GetMob()
        if mob then n, anySecret = Collect(mob) end
    end

    if n == 0 then
        SetGlow(nil)
        holder = nil
        if db.always or not db.locked or (menu and menu:IsShown()) then
            if mob then SetTitle(UnitName(mob)) else SetTitle(L.idle) end
            frame.mine:SetText("")
            SetBar(frame.accent, 0)
            HideRows(1)
            FadeIn()
        else
            FadeOut()
        end
        return
    end

    -- Sortieren geht nur mit lesbaren Zahlen; sonst bleibt die Gruppenreihenfolge.
    if not anySecret then table.sort(data, ByThreat) end

    local me, tank, second
    for i = 1, n do
        local e = data[i]
        e.rank = i
        if e.isPlayer then me = i end
        if e.tanking and not tank then tank = e end
    end
    if tank and not anySecret then
        for i = 1, n do
            if data[i] ~= tank then second = data[i] break end
        end
    end

    -- Passt nicht alles ins Fenster, bleibt die eigene Zeile trotzdem sichtbar.
    local t = Theme()
    local cap = Capacity(db.height, t.gap)
    local shown = n
    if shown > cap then
        shown = cap
        if me and me > shown then
            data[shown], data[me] = data[me], data[shown]
            me = shown
        end
    end

    -- Tank-Vorsprung: wie weit der Nächste noch vom Aggro-Ziehen entfernt ist
    local lead = (Mode("lead") and second and not second.secret) and math.max(0, 100 - second.pct) or nil

    for i = 1, shown do
        local e, row = data[i], GetRow(i)
        local c = ClassColor(e)
        row:SetStatusBarColor(c.r, c.g, c.b, 0.95)
        row.bg:SetColorTexture(c.r * t.rowBg, c.g * t.rowBg, c.b * t.rowBg, t.rowBgAlpha)
        row.rank:SetText(anySecret and "" or e.rank)
        row.name:SetText(e.name)
        if e.isPlayer then row.name:SetTextColor(1, 1, 1) else row.name:SetTextColor(0.92, 0.92, 0.92) end

        local isOver = false
        if e.secret then
            -- Geheimer Wert: unverändert an Balken und Text durchreichen.
            SetBar(row, e.pct, true)
            if not pcall(row.text.SetFormattedText, row.text, "%.0f%%", e.pct) then
                row.text:SetText("?")
            end
            row.val:SetText("")
            row.valEdge:SetText("")
        else
            SetBar(row, e.pct)
            local pctText = format("%.0f%%", e.pct)
            local extra = ""
            if e.tanking and lead then
                pctText = format("|cff%s+%.0f%%|r", LeadColor(lead), lead)
            elseif not e.tanking and Mode("over") and e.raw and e.raw > 100 then
                -- schon mehr Bedrohung als der Tank, Aggro wechselt aber erst bei 110/130 %
                isOver = true
                extra = format("|cff%s+%.0f%%|r  ", OVER_COLOR, e.raw - 100)
            end
            row.text:SetText(extra .. pctText)
            local v = (db.values and plain(e.val) and not isOver) and Short(e.val) or ""
            row.val:SetText(v)
            row.valEdge:SetText(v)
        end
        if isOver then row.over:Show() else row.over:Hide() end
        if e.isPlayer then row.me:Show() else row.me:Hide() end
        if e.tanking then row.aggro:Show() else row.aggro:Hide() end
        row:Show()
    end
    HideRows(shown + 1)

    if anySecret then holder = nil else CheckSteal(tank) end
    if testMode then SetTitle("Test") else SetTitle(UnitName(mob)) end

    -- Eigener Stand in der Kopfzeile, Akzentleiste und Warnung
    local my = me and data[me]
    local warnNow = false
    if not my then
        frame.mine:SetText("")
        SetBar(frame.accent, 0)
        SetGlow(nil)
    elseif my.tanking then
        local r, g, b = MyColor(my.pct, true)
        frame.mine:SetText(format("|cff%s%.0f%%|r", Hex(r, g, b), my.pct))
        frame.accent:SetStatusBarColor(r, g, b)
        SetBar(frame.accent, 100)
        SetGlow(r, g, b, false)
    elseif my.secret then
        frame.mine:SetText("")
        frame.accent:SetStatusBarColor(0.45, 0.7, 1)
        SetBar(frame.accent, my.pct, true)
        local grouped = (IsInGroup and IsInGroup()) or truthy(UnitExists("pet"))
        local status = UnitThreatSituation("player", mob)
        if grouped and plain(status) then
            if db.view == "tank" then
                warnNow = status < 2          -- Tank hat die Aggro verloren
            else
                warnNow = status == 1
            end
        end
        if warnNow then SetGlow(1, 0.19, 0.19, true) else SetGlow(0.45, 0.7, 1, false) end
    else
        local r, g, b = MyColor(my.pct, false)
        local over = ""
        if Mode("over") and my.raw and my.raw > 100 then
            over = format("|cff%s+%.0f%%|r ", OVER_COLOR, my.raw - 100)
        end
        frame.mine:SetText(format("%s|cff%s%.0f%%|r", over, Hex(r, g, b), my.pct))
        frame.accent:SetStatusBarColor(r, g, b)
        SetBar(frame.accent, my.pct)
        local grouped = testMode or (IsInGroup and IsInGroup()) or truthy(UnitExists("pet"))
        if db.view == "tank" then
            warnNow = grouped                 -- Tank-Sicht: Alarm, sobald du die Aggro verloren hast
        else
            warnNow = grouped and my.pct >= db.warn
        end
        SetGlow(r, g, b, warnNow)
    end

    FadeIn()
end

------------------------------------------------------------------------
-- Einstellungsmenü
------------------------------------------------------------------------
local MENU_W, ITEM_H = 196, 18
local GOLD = { 1, 0.82, 0.3 }

local function MenuFont(fs, size)
    if GameFontHighlightSmall then fs:SetFontObject(GameFontHighlightSmall) end
    fs:SetFont(FONT_CLEAN, size, "")
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 0.9)
end

local function RefreshMenu()
    if not menu then return end
    for i = 1, #menu.items do
        local b = menu.items[i]
        local off = b.disabled and b.disabled()
        b:EnableMouse(not off)
        if off then
            if b.get() then b.mark:Show() else b.mark:Hide() end
            b.mark:SetAlpha(0.35)
            b.label:SetTextColor(0.35, 0.35, 0.35)
        elseif b.get() then
            b.mark:SetAlpha(1)
            b.mark:Show()
            b.label:SetTextColor(1, 1, 1)
        else
            b.mark:Hide()
            b.label:SetTextColor(0.7, 0.7, 0.7)
        end
    end
end

local function MenuHeading(y, text)
    local fs = menu:CreateFontString(nil, "OVERLAY")
    MenuFont(fs, 11)
    fs:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
    fs:SetPoint("TOPLEFT", 12, y)
    fs:SetText(string.upper(text))
    local line = menu:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 1, 1, 0.08)
    line:SetHeight(1)
    line:SetPoint("LEFT", fs, "RIGHT", 6, 0)
    line:SetPoint("RIGHT", menu, "RIGHT", -12, 0)
    return y - 16
end

-- radio = Auswahl (kleiner Punkt), sonst Häkchen-Kästchen (grösserer Punkt)
local function MenuOption(y, id, label, radio, get, set)
    local b = CreateFrame("Button", nil, menu)
    b:SetPoint("TOPLEFT", 6, y)
    b:SetPoint("TOPRIGHT", -6, y)
    b:SetHeight(ITEM_H)

    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.07)

    b.box = b:CreateTexture(nil, "ARTWORK")
    b.box:SetSize(11, 11)
    b.box:SetPoint("LEFT", 8, 0)
    b.box:SetColorTexture(0.22, 0.24, 0.29, 1)

    b.mark = b:CreateTexture(nil, "OVERLAY")
    if radio then b.mark:SetSize(5, 5) else b.mark:SetSize(7, 7) end
    b.mark:SetPoint("CENTER", b.box)
    b.mark:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 1)

    b.label = b:CreateFontString(nil, "OVERLAY")
    MenuFont(b.label, 12)
    b.label:SetPoint("LEFT", b.box, "RIGHT", 8, 0)
    b.label:SetText(label)

    b.id, b.get = id, get
    menu.lastItem = b
    b:SetScript("OnClick", function()
        if b.disabled and b.disabled() then return end
        set()
        ApplyLayout()
        Update()
        RefreshMenu()
    end)
    menu.items[#menu.items + 1] = b
    return y - ITEM_H
end

local function CreateMenu()
    menu = CreateFrame("Frame", "FiesoThreatMenu", UIParent)
    menu:SetFrameStrata("DIALOG")
    menu:SetWidth(MENU_W)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    menu.items = {}

    local bg = menu:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.05, 0.06, 0.08, 0.96)
    BorderColor(MakeBorder(menu, "BORDER", 1), { 0, 0, 0, 1 })
    local edge = menu:CreateTexture(nil, "BORDER", nil, 1)
    edge:SetPoint("TOPLEFT", 1, -1)
    edge:SetPoint("TOPRIGHT", -1, -1)
    edge:SetHeight(1)
    edge:SetColorTexture(1, 1, 1, 0.08)

    local y = -10
    y = MenuHeading(y, L.view)
    y = MenuOption(y, "view:dps", L.optDps, true,
        function() return db.view == "dps" end,
        function() db.view = "dps" end)
    y = MenuOption(y, "view:tank", L.optTank, true,
        function() return db.view == "tank" end,
        function() db.view = "tank" end)

    y = MenuHeading(y - 8, L.design)
    for i = 1, #THEME_ORDER do
        local key = THEME_ORDER[i]
        y = MenuOption(y, "theme:" .. key, ThemeLabel(key), true,
            function() return db.theme == key end,
            function() db.theme = key end)
    end

    y = MenuHeading(y - 8, L.tankModeDps)
    local labels = { lead = L.optLead, over = L.optOver, steal = L.optSteal, off = L.optOff }
    for i = 1, #TANK_ORDER do
        local key = TANK_ORDER[i]
        y = MenuOption(y, "mode:" .. key, labels[key], true,
            function() return ActiveMode() == key end,
            function() db.tankMode = key; holder = nil end)
        menu.lastItem.disabled = function() return db.view == "tank" end
    end

    y = MenuHeading(y - 8, L.display)
    y = MenuOption(y, "values", L.optValues, false,
        function() return db.values end, function() db.values = not db.values end)
    y = MenuOption(y, "glow", L.optGlow, false,
        function() return db.glow end, function() db.glow = not db.glow end)
    y = MenuOption(y, "locked", L.optLocked, false,
        function() return db.locked end, function() db.locked = not db.locked end)
    y = MenuOption(y, "test", L.optTest, false,
        function() return testMode end,
        function() testMode = not testMode; holder = nil end)

    menu:SetHeight(-y + 8)
    menu:Hide()
    if UISpecialFrames then table.insert(UISpecialFrames, "FiesoThreatMenu") end  -- ESC schliesst
end

function ToggleMenu()
    if not frame then return end
    if not menu then CreateMenu() end
    if menu:IsShown() then
        menu:Hide()
        return
    end
    menu:SetScale(db.scale)
    menu:ClearAllPoints()
    menu:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, 0)
    RefreshMenu()
    menu:Show()
    FadeIn()
end

------------------------------------------------------------------------
-- Ereignisse
------------------------------------------------------------------------
local driver = CreateFrame("Frame")
local elapsed = 0

driver:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON then LoadDB(); ApplyLayout() end
        return
    end
    if event == "PLAYER_LOGIN" then
        LoadDB()
        CreateUI()
        BuildUnits()
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        BuildUnits()
    elseif event == "PLAYER_TARGET_CHANGED" then
        holder = nil
    end
    Update()
end)

driver:SetScript("OnUpdate", function(_, dt)
    if not frame then return end

    -- Ein-/Ausblenden
    if frame:IsShown() then
        local a = frame:GetAlpha()
        if a ~= fadeTarget then
            if fadeTarget > a then a = math.min(1, a + dt * 6) else a = math.max(0, a - dt * 4) end
            frame:SetAlpha(a)
        end
        if fadeTarget == 0 and a <= 0 then
            frame:Hide()
            if menu then menu:Hide() end
        end
    end

    -- Rahmenfarbe weich überblenden
    if glow:IsShown() then
        local k, changed = math.min(1, dt * 6), false
        for i = 1, 3 do
            local d = glowTarget[i] - glowCur[i]
            if d ~= 0 then
                glowCur[i] = (math.abs(d) < 0.01) and glowTarget[i] or (glowCur[i] + d * k)
                changed = true
            end
        end
        if changed then PaintGlow(glowCur) end
    end

    -- Balken gleiten lassen
    if frame:IsShown() then
        local k = math.min(1, dt * 12)
        for i = 1, #smoothBars do
            local bar = smoothBars[i]
            if bar.smooth and bar.target and bar.cur ~= bar.target then
                local cur = bar.cur + (bar.target - bar.cur) * k
                if math.abs(bar.target - cur) < 0.05 then cur = bar.target end
                bar.cur = cur
                bar:SetValue(cur)
            end
        end
    end

    elapsed = elapsed + dt
    if elapsed >= 0.2 then
        elapsed = 0
        Update()
    end
end)

for _, event in ipairs({
    "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "GROUP_ROSTER_UPDATE",
    "PLAYER_TARGET_CHANGED", "UNIT_THREAT_LIST_UPDATE", "UNIT_THREAT_SITUATION_UPDATE",
    "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED",
}) do
    pcall(driver.RegisterEvent, driver, event)  -- unbekannte Events nicht fatal
end

------------------------------------------------------------------------
-- Befehle
------------------------------------------------------------------------
local function Number(arg, lo, hi)
    local v = tonumber(arg)
    if v and v >= lo and v <= hi then return v end
    Print(format(L.badNumber, lo .. "–" .. hi))
end

local function Toggle(key, onMsg, offMsg)
    db[key] = not db[key]
    Print(db[key] and onMsg or offMsg)
end

SLASH_FIESOTHREAT1 = "/ft"
SLASH_FIESOTHREAT2 = "/fiesothreat"
SlashCmdList["FIESOTHREAT"] = function(msg)
    local cmd, arg = string.match(string.lower(msg or ""), "^%s*(%S*)%s*(.-)%s*$")
    arg = string.gsub(arg, ",", ".")

    if cmd == "menu" or cmd == "config" or cmd == "optionen" or cmd == "settings" then
        ToggleMenu()
        return
    elseif cmd == "lock" then
        db.locked = true; Print(L.locked)
    elseif cmd == "unlock" then
        db.locked = false; Print(L.unlocked)
    elseif cmd == "show" then
        db.shown = true; Print(L.shown)
    elseif cmd == "hide" then
        db.shown = false; Print(L.hidden)
    elseif cmd == "toggle" then
        Toggle("shown", L.shown, L.hidden)
    elseif cmd == "glow" or cmd == "leuchten" then
        Toggle("glow", L.glowOn, L.glowOff)
    elseif cmd == "values" then
        Toggle("values", L.valuesOn, L.valuesOff)
    elseif cmd == "always" then
        Toggle("always", L.alwaysOn, L.alwaysOff)
    elseif cmd == "tank" or cmd == "dps" then
        db.view = cmd
        Print(format(L.viewSet, cmd == "tank" and L.optTank or L.optDps))
    elseif TANK_ALIAS[cmd] and db.view == "tank" then
        Print(L.modeLocked)
    elseif TANK_ALIAS[cmd] then
        db.tankMode = TANK_ALIAS[cmd]
        holder = nil
        local labels = { lead = L.optLead, over = L.optOver, steal = L.optSteal, off = L.optOff }
        Print(format(L.mode, labels[db.tankMode]))
    elseif cmd == "theme" or cmd == "design" or cmd == "style" then
        local key
        if arg == "" then
            for i = 1, #THEME_ORDER do
                if THEME_ORDER[i] == db.theme then key = THEME_ORDER[i % #THEME_ORDER + 1] end
            end
            key = key or "modern"
        else
            key = THEME_ALIAS[arg]
        end
        if key then
            db.theme = key
            Print(format(L.theme, ThemeLabel(key)))
        else
            Print(L.badTheme)
        end
    elseif cmd == "test" then
        testMode = not testMode
        holder = nil
        Print(testMode and L.testOn or L.testOff)
    elseif cmd == "warn" then
        local v = Number(arg, 50, 100)
        if v then db.warn = floor(v); Print(format(L.warn, db.warn)) end
    elseif cmd == "scale" then
        local v = Number(arg, 0.5, 2)
        if v then db.scale = v; Print(format(L.scale, v)) end
    elseif cmd == "rows" then
        local v = Number(arg, 1, 25)
        if v then db.height = HeightFor(floor(v), Theme().gap); Print(format(L.rows, floor(v))) end
    elseif cmd == "width" then
        local v = Number(arg, MIN_W, MAX_W)
        if v then db.width = floor(v); Print(format(L.width, db.width)) end
    elseif cmd == "reset" then
        for k, v in pairs(defaults) do db[k] = v end
        testMode = false
        Print(L.reset)
    else
        Print("v" .. VERSION)
        for i = 1, #L.help do Print(L.help[i]) end
        return
    end
    ApplyLayout()
    Update()
    RefreshMenu()
end
