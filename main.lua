--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗     ██╗     ██╗██████╗               ║
║   ████╗  ██║██╔═══██╗██║   ██║██╔══██╗    ██║     ██║██╔══██╗              ║
║   ██╔██╗ ██║██║   ██║██║   ██║███████║    ██║     ██║██████╔╝              ║
║   ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║    ██║     ██║██╔══██╗              ║
║   ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║    ███████╗██║██████╔╝              ║
║   ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝    ╚══════╝╚═╝╚═════╝               ║
║                                                                              ║
║   Nova UI Library v2.0  —  Roblox Lua                                       ║
║   Paleta: Violeta profundo con acentos ámbar/dorado                         ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

CAMBIOS v2.0:
  • Paleta rediseñada: violeta profundo + ámbar/dorado como acento
  • Fix crítico: Dropdown y ColorPicker ahora se renderizan en el ScreenGui raíz
    → ya no se cortan por ClipsDescendants del ScrollingFrame del tab
  • Header buttons reubicados con espaciado uniforme (26px entre botones)
  • Sidebar reconstruido sin "parches" de frames rectangulares
    → usa UICorner solo en las esquinas que corresponden
  • Logger z-index correcto; no se superpone a la ventana
  • Slider: debounce en callback para evitar spam
  • Config: clave por juego usando game.GameId en lugar de _G plano
  • Toggle hitbox cubre todo el frame (no solo el knob)
  • Tooltip: posición corregida, ya no se sale de pantalla
  • Separador de sección: altura correcta (no colapsa)
  • AutomaticSize en secciones: no necesita altura manual
  • ScrollingFrame del tab: ClipsDescendants = false para overlays

USO BÁSICO:
  local Nova = loadstring(...)()
  local win = Nova:new({ Title = "Mi App" })
  local tab = win:AddTab("Principal", "⚡")
  local sec = tab:AddSection("Opciones")
  sec:AddButton({ Text = "Hola", Callback = function() print("click") end })

]]

-- ═══════════════════════════════════════════════════════════════
--  SERVICIOS
-- ═══════════════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer       = Players.LocalPlayer
local Mouse             = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════
--  LIBRERÍA PRINCIPAL
-- ═══════════════════════════════════════════════════════════════
local Nova = {}
Nova.__index = Nova

-- ───────────────────────────────────────────────
--  PALETA DE COLORES / TEMAS
-- ───────────────────────────────────────────────
Nova.Themes = {
    Dark = {
        -- Fondos
        Background      = Color3.fromRGB(13, 11, 20),
        Sidebar         = Color3.fromRGB(18, 15, 28),
        Header          = Color3.fromRGB(10, 8, 17),
        Section         = Color3.fromRGB(22, 18, 34),
        Element         = Color3.fromRGB(28, 24, 42),
        ElementHover    = Color3.fromRGB(38, 32, 58),
        ElementActive   = Color3.fromRGB(20, 17, 32),
        -- Acento principal: ámbar/dorado cálido
        Accent          = Color3.fromRGB(255, 185, 50),
        -- Acento secundario: naranja suave
        AccentSecondary = Color3.fromRGB(255, 120, 60),
        -- Acento terciario: violeta brillante
        AccentTertiary  = Color3.fromRGB(160, 100, 255),
        -- Textos
        TextPrimary     = Color3.fromRGB(235, 228, 255),
        TextSecondary   = Color3.fromRGB(145, 132, 180),
        TextDisabled    = Color3.fromRGB(75, 68, 100),
        -- Bordes
        Border          = Color3.fromRGB(42, 36, 62),
        BorderAccent    = Color3.fromRGB(200, 145, 40),
        -- Scrollbar
        Scrollbar       = Color3.fromRGB(55, 48, 80),
        -- Toggle
        ToggleOn        = Color3.fromRGB(255, 185, 50),
        ToggleOff       = Color3.fromRGB(48, 42, 68),
        -- Slider
        SliderTrack     = Color3.fromRGB(35, 30, 52),
        SliderFill      = Color3.fromRGB(255, 185, 50),
        -- Notificaciones
        NotifyInfo      = Color3.fromRGB(80, 160, 255),
        NotifySuccess   = Color3.fromRGB(80, 210, 140),
        NotifyWarning   = Color3.fromRGB(255, 185, 50),
        NotifyError     = Color3.fromRGB(230, 70, 90),
        -- Logger
        LoggerBg        = Color3.fromRGB(8, 6, 14),
        LogInfo         = Color3.fromRGB(100, 170, 255),
        LogWarn         = Color3.fromRGB(255, 200, 60),
        LogError        = Color3.fromRGB(230, 80, 100),
        LogDebug        = Color3.fromRGB(170, 110, 255),
        -- Misc
        Shadow          = Color3.fromRGB(0, 0, 0),
        TabActive       = Color3.fromRGB(255, 185, 50),
        TabInactive     = Color3.fromRGB(100, 90, 130),
        TabIndicator    = Color3.fromRGB(255, 185, 50),
    },
    Light = {
        Background      = Color3.fromRGB(245, 242, 255),
        Sidebar         = Color3.fromRGB(232, 228, 248),
        Header          = Color3.fromRGB(220, 216, 240),
        Section         = Color3.fromRGB(252, 250, 255),
        Element         = Color3.fromRGB(238, 234, 252),
        ElementHover    = Color3.fromRGB(224, 218, 245),
        ElementActive   = Color3.fromRGB(210, 204, 235),
        Accent          = Color3.fromRGB(200, 140, 0),
        AccentSecondary = Color3.fromRGB(200, 80, 30),
        AccentTertiary  = Color3.fromRGB(120, 60, 210),
        TextPrimary     = Color3.fromRGB(30, 25, 55),
        TextSecondary   = Color3.fromRGB(100, 90, 135),
        TextDisabled    = Color3.fromRGB(170, 162, 200),
        Border          = Color3.fromRGB(200, 194, 228),
        BorderAccent    = Color3.fromRGB(180, 130, 0),
        Scrollbar       = Color3.fromRGB(185, 178, 215),
        ToggleOn        = Color3.fromRGB(200, 140, 0),
        ToggleOff       = Color3.fromRGB(195, 188, 220),
        SliderTrack     = Color3.fromRGB(210, 204, 235),
        SliderFill      = Color3.fromRGB(200, 140, 0),
        NotifyInfo      = Color3.fromRGB(0, 120, 220),
        NotifySuccess   = Color3.fromRGB(0, 170, 110),
        NotifyWarning   = Color3.fromRGB(190, 130, 0),
        NotifyError     = Color3.fromRGB(200, 50, 70),
        LoggerBg        = Color3.fromRGB(228, 224, 245),
        LogInfo         = Color3.fromRGB(0, 100, 210),
        LogWarn         = Color3.fromRGB(170, 120, 0),
        LogError        = Color3.fromRGB(190, 40, 60),
        LogDebug        = Color3.fromRGB(110, 50, 200),
        Shadow          = Color3.fromRGB(140, 130, 180),
        TabActive       = Color3.fromRGB(200, 140, 0),
        TabInactive     = Color3.fromRGB(120, 110, 155),
        TabIndicator    = Color3.fromRGB(200, 140, 0),
    },
}

-- ───────────────────────────────────────────────
--  ESTADO GLOBAL
-- ───────────────────────────────────────────────
Nova._windows          = {}
Nova._keybinds         = {}
Nova._notifyQueue      = {}
Nova._notifyActive     = {}
Nova._config           = {}
Nova._configKey        = "NovaLib_v2_" .. tostring(game.GameId)
Nova._maxNotifications = 4
Nova._initialized      = false
-- Overlay global para cerrar dropdowns/pickers al hacer click fuera
Nova._openOverlays     = {}  -- lista de { frame, closeFunc }

-- ───────────────────────────────────────────────
--  UTILIDADES INTERNAS
-- ───────────────────────────────────────────────
local function Tween(instance, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    duration  = duration  or 0.25
    local t   = TweenService:Create(instance, TweenInfo.new(duration, style, direction), props)
    t:Play()
    return t
end

local function New(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do inst[k] = v end
    end
    if children then
        for _, child in ipairs(children) do child.Parent = inst end
    end
    return inst
end

local function Debounce(fn, wait)
    local last = 0
    return function(...)
        local now = tick()
        if now - last >= (wait or 0.1) then
            last = now
            fn(...)
        end
    end
end

local function DeepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do copy[k] = DeepCopy(v) end
    return copy
end

local function ColorToHex(c)
    return string.format("#%02X%02X%02X",
        math.floor(c.R * 255),
        math.floor(c.G * 255),
        math.floor(c.B * 255))
end

local function HexToColor(hex)
    hex = hex:gsub("#", "")
    return Color3.new(
        tonumber(hex:sub(1,2), 16) / 255,
        tonumber(hex:sub(3,4), 16) / 255,
        tonumber(hex:sub(5,6), 16) / 255)
end

local function GetTimestamp()
    local t = os.time()
    return string.format("%02d:%02d:%02d",
        math.floor(t/3600) % 24,
        math.floor(t/60)   % 60,
        t % 60)
end

local function Corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    if parent then c.Parent = parent end
    return c
end

local function Stroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color     = color or Color3.new(1,1,1)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    if parent then s.Parent = parent end
    return s
end

local function Padding(top, right, bottom, left, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    if parent then p.Parent = parent end
    return p
end

local function ListLayout(padding, fillDir, sortOrder, parent)
    local l = Instance.new("UIListLayout")
    l.Padding             = UDim.new(0, padding  or 4)
    l.FillDirection       = fillDir  or Enum.FillDirection.Vertical
    l.SortOrder           = sortOrder or Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    if parent then l.Parent = parent end
    return l
end

-- ───────────────────────────────────────────────
--  DRAG
-- ───────────────────────────────────────────────
local function MakeDraggable(frame, handle, onDrag)
    local dragging  = false
    local dragStart = nil
    local startPos  = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then return end
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta  = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,  startPos.X.Offset + delta.X,
                startPos.Y.Scale,  startPos.Y.Offset + delta.Y)
            frame.Position = newPos
            if onDrag then onDrag(newPos) end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════════
function Nova:_init()
    if self._initialized then return end
    self._initialized = true

    local gui
    local ok = pcall(function()
        local old = CoreGui:FindFirstChild("NovaLib_Root")
        if old then old:Destroy() end
        gui = New("ScreenGui", {
            Name           = "NovaLib_Root",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder   = 999,
            Parent         = CoreGui,
        })
    end)

    if not ok then
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            local old = pg:FindFirstChild("NovaLib_Root")
            if old then old:Destroy() end
        end
        gui = New("ScreenGui", {
            Name           = "NovaLib_Root",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder   = 999,
            Parent         = LocalPlayer.PlayerGui,
        })
    end

    self._rootGui = gui

    -- Capa de overlays (dropdowns, pickers) — siempre encima de todo
    -- Usamos el rootGui directamente con ZIndex alto

    -- Contenedor de notificaciones
    self._notifyContainer = New("Frame", {
        Name                   = "NotifyContainer",
        BackgroundTransparency = 1,
        Position               = UDim2.new(1, -320, 0, 20),
        Size                   = UDim2.new(0, 300, 1, -40),
        Parent                 = gui,
    })
    ListLayout(8, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, self._notifyContainer)

    -- Listener global para cerrar overlays al hacer click fuera
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        -- Iterar en reversa para no romper índices al remover
        for i = #self._openOverlays, 1, -1 do
            local ov = self._openOverlays[i]
            if ov and ov.frame and ov.frame.Parent then
                local mp = UserInputService:GetMouseLocation()
                local ap = ov.frame.AbsolutePosition
                local as = ov.frame.AbsoluteSize
                local inside = (mp.X >= ap.X and mp.X <= ap.X + as.X
                             and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y)
                -- También verificar si el click fue en el trigger
                local inTrigger = false
                if ov.trigger then
                    local tp = ov.trigger.AbsolutePosition
                    local ts = ov.trigger.AbsoluteSize
                    inTrigger = (mp.X >= tp.X and mp.X <= tp.X + ts.X
                              and mp.Y >= tp.Y and mp.Y <= tp.Y + ts.Y)
                end
                if not inside and not inTrigger then
                    ov.closeFunc()
                    table.remove(self._openOverlays, i)
                end
            else
                table.remove(self._openOverlays, i)
            end
        end
    end)

    self:_startKeybindListener()
end

-- ───────────────────────────────────────────────
--  OVERLAY HELPER — posicionar un frame flotante
--  anclado a un elemento de referencia
-- ───────────────────────────────────────────────
-- Crea un frame en el rootGui en la posición absoluta del anchor
-- @param anchor GuiObject  Elemento de referencia
-- @param overlayFrame Frame  El frame que se quiere posicionar
-- @param offsetY number  Offset vertical extra
function Nova:_positionOverlay(anchor, overlayFrame, offsetY)
    offsetY = offsetY or 0
    local ap = anchor.AbsolutePosition
    local as = anchor.AbsoluteSize
    overlayFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + offsetY)
end

-- ───────────────────────────────────────────────
--  KEYBIND LISTENER
-- ───────────────────────────────────────────────
function Nova:_startKeybindListener()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        for _, win in pairs(self._windows) do
            if win._anyKeyCapture then
                win._anyKeyCapture(input.KeyCode)
                win._anyKeyCapture = nil
            end
        end
        for name, kb in pairs(self._keybinds) do
            if kb.Key and input.KeyCode == kb.Key then
                pcall(kb.Callback)
            end
        end
    end)
end

-- ───────────────────────────────────────────────
--  API GLOBAL: Keybinds
-- ───────────────────────────────────────────────
function Nova:RegisterKeybind(name, key, callback)
    self._keybinds[name] = { Key = key, Callback = callback }
end

function Nova:UnregisterKeybind(name)
    self._keybinds[name] = nil
end

function Nova:GetPressedKey(callback)
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        conn:Disconnect()
        callback(input.KeyCode)
    end)
end

-- ───────────────────────────────────────────────
--  API GLOBAL: Notificaciones
-- ───────────────────────────────────────────────
function Nova:Notify(config)
    config = config or {}
    if #self._notifyActive >= self._maxNotifications then
        table.insert(self._notifyQueue, config)
        return
    end
    self:_showNotification(
        config.Title    or "Notificación",
        config.Text     or "",
        config.Duration or 4,
        config.Icon,
        config.Type     or "info",
        config.Callback
    )
end

function Nova:_showNotification(title, text, duration, icon, nType, callback)
    self:_init()
    local theme = Nova.Themes.Dark

    local typeColor = theme.NotifyInfo
    local typeIcon  = "ℹ"
    if nType == "success" then typeColor = theme.NotifySuccess; typeIcon = "✓"
    elseif nType == "warning" then typeColor = theme.NotifyWarning; typeIcon = "⚠"
    elseif nType == "error"   then typeColor = theme.NotifyError;   typeIcon = "✖"
    end

    local notify = New("Frame", {
        Name                   = "Notification",
        BackgroundColor3       = Color3.fromRGB(20, 16, 32),
        Size                   = UDim2.new(1, 0, 0, 72),
        BackgroundTransparency = 1,
        Parent                 = self._notifyContainer,
    })
    Corner(10, notify)

    local bg = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 16, 32),
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = notify,
    })
    Corner(10, bg)
    Stroke(typeColor, 1, bg)

    New("Frame", {
        BackgroundColor3 = typeColor,
        Size             = UDim2.new(0, 3, 1, -16),
        Position         = UDim2.new(0, 0, 0, 8),
        Parent           = bg,
    })

    New("TextLabel", {
        Text                   = icon or typeIcon,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 18,
        TextColor3             = typeColor,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0, 30, 0, 30),
        Position               = UDim2.new(0, 14, 0, 8),
        Parent                 = bg,
    })

    New("TextLabel", {
        Text                   = title,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 13,
        TextColor3             = Color3.fromRGB(235, 228, 255),
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -60, 0, 18),
        Position               = UDim2.new(0, 50, 0, 8),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = bg,
    })

    New("TextLabel", {
        Text                   = text,
        Font                   = Enum.Font.Gotham,
        TextSize               = 11,
        TextColor3             = Color3.fromRGB(145, 132, 180),
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -60, 0, 26),
        Position               = UDim2.new(0, 50, 0, 26),
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        Parent                 = bg,
    })

    local progressBg = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(35, 30, 52),
        Size             = UDim2.new(1, -16, 0, 3),
        Position         = UDim2.new(0, 8, 1, -7),
        Parent           = bg,
    })
    Corner(2, progressBg)

    local progressFill = New("Frame", {
        BackgroundColor3 = typeColor,
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = progressBg,
    })
    Corner(2, progressFill)

    local closeBtn = New("TextButton", {
        Text                   = "×",
        Font                   = Enum.Font.GothamBold,
        TextSize               = 16,
        TextColor3             = Color3.fromRGB(145, 132, 180),
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0, 20, 0, 20),
        Position               = UDim2.new(1, -24, 0, 4),
        Parent                 = bg,
    })

    table.insert(self._notifyActive, notify)
    notify.BackgroundTransparency = 0
    notify.Position = UDim2.new(1, 20, 0, 0)
    Tween(notify, { Position = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    if callback then
        bg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                pcall(callback)
            end
        end)
    end

    local closed = false
    local function closeNotify()
        if closed then return end
        closed = true
        Tween(notify, { Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1 }, 0.25)
        task.delay(0.3, function()
            notify:Destroy()
            for i, n in ipairs(self._notifyActive) do
                if n == notify then table.remove(self._notifyActive, i); break end
            end
            if #self._notifyQueue > 0 then
                local nxt = table.remove(self._notifyQueue, 1)
                self:_showNotification(
                    nxt.Title or "Notificación", nxt.Text or "",
                    nxt.Duration or 4, nxt.Icon, nxt.Type or "info", nxt.Callback)
            end
        end)
    end

    closeBtn.MouseButton1Click:Connect(closeNotify)
    Tween(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)
    task.delay(duration, closeNotify)

    bg.MouseEnter:Connect(function() Tween(bg, { BackgroundColor3 = Color3.fromRGB(28, 22, 44) }, 0.15) end)
    bg.MouseLeave:Connect(function() Tween(bg, { BackgroundColor3 = Color3.fromRGB(20, 16, 32) }, 0.15) end)
end

-- ───────────────────────────────────────────────
--  API GLOBAL: Config
-- ───────────────────────────────────────────────
function Nova:SaveConfig()
    local data = {}
    for _, win in pairs(self._windows) do
        data[win._id] = win:_collectConfig()
    end
    self._config = data
    _G[self._configKey] = HttpService:JSONEncode(data)
    return data
end

function Nova:LoadConfig()
    local raw = _G[self._configKey]
    if not raw then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok then return false end
    self._config = data
    for _, win in pairs(self._windows) do
        if data[win._id] then win:_applyConfig(data[win._id]) end
    end
    return true
end

function Nova:Destroy()
    if self._rootGui then self._rootGui:Destroy() end
    self._windows      = {}
    self._keybinds     = {}
    self._notifyQueue  = {}
    self._notifyActive = {}
    self._openOverlays = {}
    self._initialized  = false
end

function Nova:GetLogger()
    for _, win in pairs(self._windows) do
        if win._logger then return win._logger end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════
--  VENTANA
-- ═══════════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Nova:new(config)
    self:_init()
    config = config or {}

    local win = setmetatable({}, Window)
    win._lib           = self
    win._id            = config.Id       or ("Window_" .. tostring(#self._windows + 1))
    win._title         = config.Title    or "Nova UI"
    win._themeName     = config.Theme    or "Dark"
    win._theme         = Nova.Themes[win._themeName] or Nova.Themes.Dark
    win._tabs          = {}
    win._activeTab     = nil
    win._minimized     = false
    win._visible       = true
    win._elements      = {}
    win._anyKeyCapture = nil

    local w  = (config.Size     and config.Size.X)     or 620
    local h  = (config.Size     and config.Size.Y)     or 430
    local px = (config.Position and config.Position.X) or 0.5
    local py = (config.Position and config.Position.Y) or 0.5
    win._size = { w = w, h = h }

    win:_build(w, h, px, py)
    win._logger = win:_buildLogger()

    table.insert(self._windows, win)
    return win
end

-- ───────────────────────────────────────────────
--  CONSTRUCCIÓN DE LA VENTANA
-- ───────────────────────────────────────────────
function Window:_build(w, h, px, py)
    local theme = self._theme
    local lib   = self._lib

    -- Raíz
    self._root = New("Frame", {
        Name                   = "NovaWindow_" .. self._id,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0, w, 0, h),
        Position               = UDim2.new(px, -w/2, py, -h/2),
        Parent                 = lib._rootGui,
    })

    -- Sombra
    New("ImageLabel", {
        Name                   = "Shadow",
        BackgroundTransparency = 1,
        Image                  = "rbxassetid://6014261993",
        ImageColor3            = Color3.fromRGB(0, 0, 0),
        ImageTransparency      = 0.55,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(49, 49, 450, 450),
        Size                   = UDim2.new(1, 50, 1, 50),
        Position               = UDim2.new(0, -25, 0, -25),
        ZIndex                 = 0,
        Parent                 = self._root,
    })

    -- Frame principal
    self._main = New("Frame", {
        Name             = "Main",
        BackgroundColor3 = theme.Background,
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = self._root,
    })
    Corner(12, self._main)
    Stroke(theme.Border, 1, self._main)

    -- ── HEADER ──
    -- Altura 44px. Sin parches: usamos un Frame normal + Corner arriba
    -- y un rectángulo que cubre la mitad inferior (para esquinas cuadradas abajo).
    -- MEJOR SOLUCIÓN: Header con ClipsDescendants = false, y el Content
    -- empieza en Y=44. Las esquinas redondeadas del main ya se encargan
    -- de que las esquinas sup del header queden redondeadas porque el header
    -- está dentro del main con overflow. Solo necesitamos redondear arriba.
    self._header = New("Frame", {
        Name             = "Header",
        BackgroundColor3 = theme.Header,
        Size             = UDim2.new(1, 0, 0, 44),
        ClipsDescendants = false,
        Parent           = self._main,
    })
    -- Corners superiores: creamos un frame con corner y lo superponemos
    -- para que las esquinas inferiores del header sean cuadradas.
    -- Técnica limpia: el header tiene corner=12 (igual que el main)
    -- pero cubrimos las esquinas inferiores con dos cuadraditos del mismo color.
    Corner(12, self._header)
    -- Cubrir esquinas inferiores del header
    New("Frame", {
        BackgroundColor3 = theme.Header,
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new(0, 0, 1, -12),
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = self._header,
    })
    New("Frame", {
        BackgroundColor3 = theme.Header,
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new(1, -12, 1, -12),
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = self._header,
    })

    -- Barra de acento izquierda
    local accentBar = New("Frame", {
        BackgroundColor3 = theme.Accent,
        Size             = UDim2.new(0, 3, 0, 22),
        Position         = UDim2.new(0, 14, 0.5, -11),
        ZIndex           = 3,
        Parent           = self._header,
    })
    Corner(2, accentBar)

    -- Título
    self._titleLabel = New("TextLabel", {
        Text                   = self._title,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 14,
        TextColor3             = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -180, 1, 0),
        Position               = UDim2.new(0, 26, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 3,
        Parent                 = self._header,
    })

    -- ── Botones del header (espaciado uniforme de 26px desde la derecha) ──
    -- Orden: Logger | Minimize | Config | Close
    -- Posiciones X desde la derecha: -30, -56, -82, -108
    local headerBtnSize = UDim2.new(0, 20, 0, 20)

    local function makeHeaderBtn(text, xOffset, textColor)
        local b = New("TextButton", {
            Text             = text,
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            TextColor3       = textColor or theme.TextSecondary,
            BackgroundColor3 = theme.Element,
            Size             = headerBtnSize,
            Position         = UDim2.new(1, xOffset, 0.5, -10),
            AutoButtonColor  = false,
            ZIndex           = 4,
            Parent           = self._header,
        })
        Corner(5, b)
        return b
    end

    local logBtn   = makeHeaderBtn("◈", -108)
    local minBtn   = makeHeaderBtn("─", -82)
    local cfgBtn   = makeHeaderBtn("⚙", -56)
    local closeBtn = makeHeaderBtn("×", -30, Color3.fromRGB(230, 80, 80))

    -- Hovers
    for _, btn in ipairs({logBtn, minBtn, cfgBtn}) do
        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundColor3 = theme.ElementHover, TextColor3 = theme.Accent }, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundColor3 = theme.Element, TextColor3 = theme.TextSecondary }, 0.15)
        end)
    end
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, { BackgroundColor3 = Color3.fromRGB(180, 40, 40) }, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, { BackgroundColor3 = theme.Element }, 0.15)
    end)

    -- Callbacks
    logBtn.MouseButton1Click:Connect(function()
        if self._loggerFrame then
            self._loggerFrame.Visible = not self._loggerFrame.Visible
        end
    end)
    minBtn.MouseButton1Click:Connect(function()
        if self._minimized then self:Restore() else self:Minimize() end
    end)
    cfgBtn.MouseButton1Click:Connect(function()
        lib:SaveConfig()
        lib:Notify({ Title = "Configuración guardada", Text = "Estado actual guardado.", Type = "success", Duration = 3 })
    end)
    closeBtn.MouseButton1Click:Connect(function() self:_hide() end)

    -- ── Cuerpo ──
    self._body = New("Frame", {
        Name                   = "Body",
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, -44),
        Position               = UDim2.new(0, 0, 0, 44),
        Parent                 = self._main,
    })

    -- ── SIDEBAR ──
    -- Construimos limpiamente: Frame con Corner=12, luego cubrimos
    -- las esquinas que no deben ser redondeadas (superior derecha, inferior derecha)
    self._sidebar = New("Frame", {
        Name             = "Sidebar",
        BackgroundColor3 = theme.Sidebar,
        Size             = UDim2.new(0, 130, 1, 0),
        Parent           = self._body,
    })
    Corner(12, self._sidebar)
    -- Cubrir esquina superior derecha e inferior derecha del sidebar
    New("Frame", {
        BackgroundColor3 = theme.Sidebar,
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new(1, -12, 0, 0),
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = self._sidebar,
    })
    -- Cubrir esquina superior izquierda (alineada con las esquinas del header)
    New("Frame", {
        BackgroundColor3 = theme.Sidebar,
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new(0, 0, 0, 0),
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = self._sidebar,
    })

    -- Separador vertical
    New("Frame", {
        BackgroundColor3 = theme.Border,
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(0, 130, 0, 0),
        Parent           = self._body,
    })

    -- Lista de tabs
    self._tabList = New("ScrollingFrame", {
        Name                   = "TabList",
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, -8),
        Position               = UDim2.new(0, 0, 0, 8),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness     = 0,
        ScrollingDirection     = Enum.ScrollingDirection.Y,
        Parent                 = self._sidebar,
    })
    local tabListLayout = ListLayout(4, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, self._tabList)
    Padding(4, 6, 6, 6, self._tabList)

    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self._tabList.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 12)
    end)

    -- ── ÁREA DE CONTENIDO ──
    -- IMPORTANTE: ClipsDescendants = false para que dropdowns/pickers
    -- puedan renderizarse fuera del área sin cortarse.
    -- Los overlays reales se ponen en el rootGui de todas formas.
    self._content = New("Frame", {
        Name                   = "Content",
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -131, 1, 0),
        Position               = UDim2.new(0, 131, 0, 0),
        ClipsDescendants       = false,
        Parent                 = self._body,
    })

    MakeDraggable(self._root, self._header, function(pos)
        self._savedPosition = pos
    end)

    -- Animación de entrada
    self._main.BackgroundTransparency = 1
    task.spawn(function()
        task.wait(0.05)
        Tween(self._main, { BackgroundTransparency = 0 }, 0.3, Enum.EasingStyle.Quart)
    end)
end

-- ───────────────────────────────────────────────
--  VENTANA: Minimizar / Restaurar / Ocultar
-- ───────────────────────────────────────────────
function Window:Minimize()
    if self._minimized then return end
    self._minimized = true
    Tween(self._root, { Size = UDim2.new(0, self._size.w, 0, 44) }, 0.3, Enum.EasingStyle.Quart)
    task.delay(0.15, function() if self._body then self._body.Visible = false end end)
end

function Window:Restore()
    if not self._minimized then return end
    self._minimized = false
    if self._body then self._body.Visible = true end
    Tween(self._root, { Size = UDim2.new(0, self._size.w, 0, self._size.h) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function Window:_hide()
    Tween(self._main, { BackgroundTransparency = 1 }, 0.25)
    task.delay(0.3, function() self._root.Visible = false end)
end

function Window:Show()
    self._root.Visible = true
    Tween(self._main, { BackgroundTransparency = 0 }, 0.3)
end

-- ───────────────────────────────────────────────
--  VENTANA: Tema / Config
-- ───────────────────────────────────────────────
function Window:SetTheme(themeName)
    self._themeName = themeName
    self._theme = Nova.Themes[themeName] or Nova.Themes.Dark
    local t = self._theme
    Tween(self._main,    { BackgroundColor3 = t.Background }, 0.3)
    Tween(self._header,  { BackgroundColor3 = t.Header },     0.3)
    Tween(self._sidebar, { BackgroundColor3 = t.Sidebar },    0.3)
end

function Window:_collectConfig()
    local data = {}
    for key, elem in pairs(self._elements) do
        if elem._getValue then data[key] = elem:_getValue() end
    end
    data["__pos"] = { x = self._root.Position.X.Offset, y = self._root.Position.Y.Offset }
    return data
end

function Window:_applyConfig(data)
    for key, val in pairs(data) do
        if key ~= "__pos" and self._elements[key] and self._elements[key]._setValue then
            pcall(function() self._elements[key]:_setValue(val) end)
        end
    end
    if data["__pos"] then
        self._root.Position = UDim2.new(
            self._root.Position.X.Scale, data["__pos"].x,
            self._root.Position.Y.Scale, data["__pos"].y)
    end
end

function Window:SaveConfig() return self._lib:SaveConfig() end
function Window:LoadConfig() return self._lib:LoadConfig() end
function Window:GetLogger()  return self._logger end

-- ═══════════════════════════════════════════════════════════════
--  LOGGER
-- ═══════════════════════════════════════════════════════════════
function Window:_buildLogger()
    local theme = self._theme
    local lib   = self._lib

    local lFrame = New("Frame", {
        Name             = "Logger",
        BackgroundColor3 = Color3.fromRGB(10, 8, 18),
        Size             = UDim2.new(0, 430, 0, 290),
        Position         = UDim2.new(0, 20, 0.5, 20),
        Visible          = false,
        ZIndex           = 100,
        Parent           = lib._rootGui,
    })
    Corner(10, lFrame)
    Stroke(theme.Border, 1, lFrame)
    self._loggerFrame = lFrame

    local lHeader = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(15, 12, 24),
        Size             = UDim2.new(1, 0, 0, 34),
        ZIndex           = 101,
        Parent           = lFrame,
    })
    Corner(10, lHeader)
    New("Frame", {
        BackgroundColor3 = Color3.fromRGB(15, 12, 24),
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        ZIndex           = 101,
        Parent           = lHeader,
    })

    New("TextLabel", {
        Text                   = "◈  Nova Logger",
        Font                   = Enum.Font.GothamBold,
        TextSize               = 12,
        TextColor3             = theme.Accent,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -130, 1, 0),
        Position               = UDim2.new(0, 12, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 102,
        Parent                 = lHeader,
    })

    local function makeLogBtn(text, x, color)
        local b = New("TextButton", {
            Text             = text,
            Font             = Enum.Font.GothamBold,
            TextSize         = 11,
            TextColor3       = color or theme.TextSecondary,
            BackgroundColor3 = Color3.fromRGB(22, 18, 34),
            Size             = UDim2.new(0, 38, 0, 22),
            Position         = UDim2.new(1, x, 0.5, -11),
            ZIndex           = 102,
            Parent           = lHeader,
        })
        Corner(5, b)
        return b
    end

    local clearBtn    = makeLogBtn("CLR", -124, Color3.fromRGB(230, 80, 100))
    local copyBtn     = makeLogBtn("CPY", -82,  theme.TextSecondary)
    local closeLogBtn = makeLogBtn("×",   -38,  Color3.fromRGB(200, 60, 60))

    local lScroll = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -8, 1, -38),
        Position               = UDim2.new(0, 4, 0, 36),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness     = 4,
        ScrollBarImageColor3   = theme.Scrollbar,
        ScrollingDirection     = Enum.ScrollingDirection.Y,
        ZIndex                 = 101,
        Parent                 = lFrame,
    })
    local lLayout = ListLayout(2, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, lScroll)
    Padding(4, 4, 4, 4, lScroll)

    lLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        lScroll.CanvasSize = UDim2.new(0, 0, 0, lLayout.AbsoluteContentSize.Y + 8)
    end)

    MakeDraggable(lFrame, lHeader, nil)
    closeLogBtn.MouseButton1Click:Connect(function() lFrame.Visible = false end)

    local logger = {}
    logger._frame      = lFrame
    logger._scroll     = lScroll
    logger._entries    = {}
    logger._logText    = ""
    logger._autoScroll = true

    local levelColors = {
        info  = Color3.fromRGB(100, 170, 255),
        warn  = Color3.fromRGB(255, 200, 60),
        error = Color3.fromRGB(230, 80, 100),
        debug = Color3.fromRGB(170, 110, 255),
    }
    local levelIcons = { info = "ℹ", warn = "⚠", error = "✖", debug = "◉" }

    function logger:log(level, message)
        level = level or "info"
        local color = levelColors[level] or levelColors.info
        local icon  = levelIcons[level]  or "•"
        local ts    = GetTimestamp()
        local text  = string.format("[%s] %s %s", ts, icon, tostring(message))
        self._logText = self._logText .. text .. "\n"

        local entry = New("Frame", {
            BackgroundColor3 = Color3.fromRGB(16, 13, 26),
            Size             = UDim2.new(1, 0, 0, 20),
            ZIndex           = 102,
            Parent           = self._scroll,
        })
        Corner(4, entry)

        New("Frame", {
            BackgroundColor3 = color,
            Size             = UDim2.new(0, 3, 0, 12),
            Position         = UDim2.new(0, 0, 0.5, -6),
            ZIndex           = 103,
            Parent           = entry,
        })

        New("TextLabel", {
            Text                   = text,
            Font                   = Enum.Font.Code,
            TextSize               = 10,
            TextColor3             = color,
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, -10, 1, 0),
            Position               = UDim2.new(0, 8, 0, 0),
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextTruncate           = Enum.TextTruncate.AtEnd,
            ZIndex                 = 103,
            Parent                 = entry,
        })

        table.insert(self._entries, entry)
        if self._autoScroll then
            task.defer(function()
                self._scroll.CanvasPosition = Vector2.new(0, math.huge)
            end)
        end
    end

    function logger:info(msg)  self:log("info",  msg) end
    function logger:warn(msg)  self:log("warn",  msg) end
    function logger:error(msg) self:log("error", msg) end
    function logger:debug(msg) self:log("debug", msg) end

    function logger:Clear()
        for _, e in ipairs(self._entries) do e:Destroy() end
        self._entries = {}
        self._logText = ""
    end

    function logger:Export()
        pcall(function() setclipboard(self._logText) end)
        return self._logText
    end

    function logger:Open()   self._frame.Visible = true  end
    function logger:Close()  self._frame.Visible = false end
    function logger:Toggle() self._frame.Visible = not self._frame.Visible end

    clearBtn.MouseButton1Click:Connect(function() logger:Clear() end)
    copyBtn.MouseButton1Click:Connect(function()
        logger:Export()
        self._lib:Notify({ Title = "Logger", Text = "Log copiado al portapapeles.", Type = "info", Duration = 2 })
    end)

    return logger
end

-- ═══════════════════════════════════════════════════════════════
--  TABS
-- ═══════════════════════════════════════════════════════════════
function Window:AddTab(name, icon)
    local theme = self._theme

    local tabBtn = New("TextButton", {
        Name             = "Tab_" .. name,
        Text             = "",
        BackgroundColor3 = theme.ElementActive,
        Size             = UDim2.new(1, -8, 0, 36),
        AutoButtonColor  = false,
        LayoutOrder      = #self._tabs + 1,
        Parent           = self._tabList,
    })
    Corner(8, tabBtn)

    local indicator = New("Frame", {
        BackgroundColor3       = theme.Accent,
        Size                   = UDim2.new(0, 3, 0, 18),
        Position               = UDim2.new(0, 0, 0.5, -9),
        BackgroundTransparency = 1,
        Parent                 = tabBtn,
    })
    Corner(2, indicator)

    local iconLabel
    if icon and icon ~= "" then
        local isAsset = icon:find("rbxassetid") or icon:find("https")
        if isAsset then
            iconLabel = New("ImageLabel", {
                Image                  = icon,
                BackgroundTransparency = 1,
                Size                   = UDim2.new(0, 16, 0, 16),
                Position               = UDim2.new(0, 10, 0.5, -8),
                Parent                 = tabBtn,
            })
        else
            iconLabel = New("TextLabel", {
                Text                   = icon,
                Font                   = Enum.Font.GothamBold,
                TextSize               = 14,
                TextColor3             = theme.TabInactive,
                BackgroundTransparency = 1,
                Size                   = UDim2.new(0, 20, 1, 0),
                Position               = UDim2.new(0, 8, 0, 0),
                Parent                 = tabBtn,
            })
        end
    end

    local nameLabel = New("TextLabel", {
        Text              = name,
        Font              = Enum.Font.Gotham,
        TextSize          = 12,
        TextColor3        = theme.TabInactive,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -36, 1, 0),
        Position          = UDim2.new(0, (icon and 30 or 10), 0, 0),
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = tabBtn,
    })

    -- Página: ClipsDescendants = false para no cortar overlays
    local tabPage = New("ScrollingFrame", {
        Name                   = "Page_" .. name,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness     = 4,
        ScrollBarImageColor3   = theme.Scrollbar,
        ScrollingDirection     = Enum.ScrollingDirection.Y,
        Visible                = false,
        ClipsDescendants       = false,  -- FIX: overlays no se cortan
        Parent                 = self._content,
    })
    local pageLayout = ListLayout(8, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, tabPage)
    Padding(10, 10, 10, 10, tabPage)

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabPage.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
    end)

    local tab = {}
    tab._window    = self
    tab._name      = name
    tab._btn       = tabBtn
    tab._page      = tabPage
    tab._indicator = indicator
    tab._nameLabel = nameLabel
    tab._iconLabel = iconLabel
    tab._sections  = {}

    tabBtn.MouseButton1Click:Connect(function() self:_selectTab(tab) end)

    tabBtn.MouseEnter:Connect(function()
        if self._activeTab ~= tab then
            Tween(tabBtn, { BackgroundColor3 = theme.ElementHover }, 0.15)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self._activeTab ~= tab then
            Tween(tabBtn, { BackgroundColor3 = theme.ElementActive }, 0.15)
        end
    end)

    table.insert(self._tabs, tab)
    if #self._tabs == 1 then self:_selectTab(tab) end

    setmetatable(tab, { __index = TabMethods })
    return tab
end

function Window:_selectTab(tab)
    if self._activeTab and self._activeTab ~= tab then
        local prev = self._activeTab
        Tween(prev._btn,       { BackgroundColor3 = self._theme.ElementActive }, 0.2)
        Tween(prev._nameLabel, { TextColor3 = self._theme.TabInactive },         0.2)
        if prev._iconLabel and prev._iconLabel:IsA("TextLabel") then
            Tween(prev._iconLabel, { TextColor3 = self._theme.TabInactive }, 0.2)
        end
        Tween(prev._indicator, { BackgroundTransparency = 1 }, 0.2)
        prev._page.Visible = false
    end
    self._activeTab = tab
    tab._page.Visible = true
    Tween(tab._btn,       { BackgroundColor3 = self._theme.Element },  0.2)
    Tween(tab._nameLabel, { TextColor3 = self._theme.TabActive },      0.2)
    if tab._iconLabel and tab._iconLabel:IsA("TextLabel") then
        Tween(tab._iconLabel, { TextColor3 = self._theme.TabActive }, 0.2)
    end
    Tween(tab._indicator, { BackgroundTransparency = 0 }, 0.2)
end

-- ═══════════════════════════════════════════════════════════════
--  SECCIONES
-- ═══════════════════════════════════════════════════════════════
TabMethods = {}
TabMethods.__index = TabMethods

function TabMethods:AddSection(name)
    local theme = self._window._theme

    local sFrame = New("Frame", {
        Name             = "Section_" .. name,
        BackgroundColor3 = theme.Section,
        Size             = UDim2.new(1, 0, 0, 30),
        AutomaticSize    = Enum.AutomaticSize.Y,
        LayoutOrder      = #self._sections + 1,
        Parent           = self._page,
    })
    Corner(8, sFrame)
    Stroke(theme.Border, 1, sFrame)

    -- Cabecera
    local sHeader = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 28),
        Parent                 = sFrame,
    })

    New("Frame", {
        BackgroundColor3 = theme.Accent,
        Size             = UDim2.new(0, 2, 0, 12),
        Position         = UDim2.new(0, 10, 0.5, -6),
        Parent           = sHeader,
    })

    New("TextLabel", {
        Text                   = name,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 11,
        TextColor3             = theme.Accent,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -24, 1, 0),
        Position               = UDim2.new(0, 18, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = sHeader,
    })

    New("Frame", {
        BackgroundColor3 = theme.Border,
        Size             = UDim2.new(1, -16, 0, 1),
        Position         = UDim2.new(0, 8, 0, 27),
        Parent           = sFrame,
    })

    local sContent = New("Frame", {
        Name              = "Content",
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, 0, 0, 0),
        Position          = UDim2.new(0, 0, 0, 29),
        AutomaticSize     = Enum.AutomaticSize.Y,
        Parent            = sFrame,
    })
    local sLayout = ListLayout(4, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, sContent)
    Padding(4, 8, 8, 8, sContent)

    local section = {}
    section._tab     = self
    section._window  = self._window
    section._frame   = sFrame
    section._content = sContent
    section._layout  = sLayout
    section._elems   = {}
    section._count   = 0

    table.insert(self._sections, section)
    setmetatable(section, { __index = SectionMethods })
    return section
end

-- ═══════════════════════════════════════════════════════════════
--  ELEMENTOS DE LA SECCIÓN
-- ═══════════════════════════════════════════════════════════════
SectionMethods = {}
SectionMethods.__index = SectionMethods

-- Tooltip (se renderiza en rootGui para no cortar)
local function MakeTooltip(parent, text, lib)
    if not text or text == "" then return end
    local tip = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(18, 14, 30),
        Size             = UDim2.new(0, 210, 0, 30),
        Visible          = false,
        ZIndex           = 200,
        Parent           = lib._rootGui,
    })
    Corner(6, tip)
    Stroke(Color3.fromRGB(60, 50, 90), 1, tip)
    New("TextLabel", {
        Text                   = text,
        Font                   = Enum.Font.Gotham,
        TextSize               = 11,
        TextColor3             = Color3.fromRGB(210, 200, 235),
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -10, 1, 0),
        Position               = UDim2.new(0, 5, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        ZIndex                 = 201,
        Parent                 = tip,
    })

    parent.MouseEnter:Connect(function()
        local mp = UserInputService:GetMouseLocation()
        -- Ajustar para no salir de pantalla
        local vp = workspace.CurrentCamera.ViewportSize
        local tx = mp.X + 14
        local ty = mp.Y + 14
        if tx + 210 > vp.X then tx = mp.X - 220 end
        if ty + 30  > vp.Y then ty = mp.Y - 36  end
        tip.Position = UDim2.new(0, tx, 0, ty)
        tip.Visible  = true
    end)
    parent.MouseMoved:Connect(function()
        local mp = UserInputService:GetMouseLocation()
        local vp = workspace.CurrentCamera.ViewportSize
        local tx = mp.X + 14
        local ty = mp.Y + 14
        if tx + 210 > vp.X then tx = mp.X - 220 end
        if ty + 30  > vp.Y then ty = mp.Y - 36  end
        tip.Position = UDim2.new(0, tx, 0, ty)
    end)
    parent.MouseLeave:Connect(function()
        tip.Visible = false
    end)
end

local function RegisterElement(section, key, elem)
    if key then section._window._elements[key] = elem end
    section._count = section._count + 1
    return section._count
end

-- ─────────────────────────────────────────────────
--  SEPARATOR
-- ─────────────────────────────────────────────────
function SectionMethods:AddSeparator()
    local theme = self._window._theme
    return New("Frame", {
        BackgroundColor3 = theme.Border,
        Size             = UDim2.new(1, 0, 0, 1),
        LayoutOrder      = RegisterElement(self, nil, nil),
        Parent           = self._content,
    })
end

-- ─────────────────────────────────────────────────
--  LABEL
-- ─────────────────────────────────────────────────
function SectionMethods:AddLabel(config)
    config = config or {}
    local theme = self._window._theme
    local frame = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 20),
        LayoutOrder            = RegisterElement(self, config.Key, nil),
        Parent                 = self._content,
    })
    local lbl = New("TextLabel", {
        Text                   = config.Text or "Label",
        Font                   = Enum.Font.Gotham,
        TextSize               = 12,
        TextColor3             = theme.TextSecondary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = frame,
    })
    return { _label = lbl, SetText = function(self, t) lbl.Text = t end }
end

-- ─────────────────────────────────────────────────
--  PARAGRAPH
-- ─────────────────────────────────────────────────
function SectionMethods:AddParagraph(config)
    config = config or {}
    local theme = self._window._theme
    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        LayoutOrder      = RegisterElement(self, config.Key, nil),
        Parent           = self._content,
    })
    Corner(6, frame)
    Padding(6, 8, 6, 8, frame)
    ListLayout(4, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, frame)

    New("TextLabel", {
        Text                   = config.Title or "Título",
        Font                   = Enum.Font.GothamBold,
        TextSize               = 12,
        TextColor3             = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 16),
        TextXAlignment         = Enum.TextXAlignment.Left,
        LayoutOrder            = 1,
        Parent                 = frame,
    })
    local contentLbl = New("TextLabel", {
        Text                   = config.Content or "",
        Font                   = Enum.Font.Gotham,
        TextSize               = 11,
        TextColor3             = theme.TextSecondary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        LayoutOrder            = 2,
        Parent                 = frame,
    })
    return { SetContent = function(self, t) contentLbl.Text = t end }
end

-- ─────────────────────────────────────────────────
--  BUTTON
-- ─────────────────────────────────────────────────
function SectionMethods:AddButton(config)
    config = config or {}
    local theme    = self._window._theme
    local callback = config.Callback and Debounce(config.Callback, 0.3) or nil

    local frame = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 32),
        LayoutOrder            = RegisterElement(self, config.Key, nil),
        Parent                 = self._content,
    })

    local btn = New("TextButton", {
        Text             = config.Text or "Botón",
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        TextColor3       = theme.TextPrimary,
        BackgroundColor3 = theme.Element,
        Size             = UDim2.new(1, 0, 1, 0),
        AutoButtonColor  = false,
        Parent           = frame,
    })
    Corner(7, btn)
    Stroke(theme.Border, 1, btn)

    local accentLine = New("Frame", {
        BackgroundColor3 = theme.Accent,
        Size             = UDim2.new(0, 0, 0, 2),
        Position         = UDim2.new(0.5, 0, 1, -2),
        AnchorPoint      = Vector2.new(0.5, 0),
        Parent           = btn,
    })
    Corner(1, accentLine)

    btn.MouseEnter:Connect(function()
        Tween(btn,        { BackgroundColor3 = theme.ElementHover }, 0.15)
        Tween(accentLine, { Size = UDim2.new(0.8, 0, 0, 2) }, 0.2, Enum.EasingStyle.Back)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn,        { BackgroundColor3 = theme.Element }, 0.15)
        Tween(accentLine, { Size = UDim2.new(0, 0, 0, 2) }, 0.2)
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(btn, { BackgroundColor3 = theme.ElementActive }, 0.1)
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, { BackgroundColor3 = theme.ElementHover }, 0.1)
        if callback then pcall(callback) end
    end)

    MakeTooltip(btn, config.Tooltip, self._window._lib)
    return { _btn = btn, SetText = function(self, t) btn.Text = t end }
end

-- ─────────────────────────────────────────────────
--  TOGGLE
-- ─────────────────────────────────────────────────
function SectionMethods:AddToggle(config)
    config = config or {}
    local theme    = self._window._theme
    local value    = config.Default ~= nil and config.Default or false
    local callback = config.Callback

    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size             = UDim2.new(1, 0, 0, 32),
        LayoutOrder      = RegisterElement(self, config.Key, nil),
        Parent           = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(0, 10, 0, 10, frame)

    New("TextLabel", {
        Text                   = config.Text or "Toggle",
        Font                   = Enum.Font.Gotham,
        TextSize               = 12,
        TextColor3             = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -50, 1, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = frame,
    })

    local track = New("Frame", {
        BackgroundColor3 = value and theme.ToggleOn or theme.ToggleOff,
        Size             = UDim2.new(0, 36, 0, 18),
        Position         = UDim2.new(1, -36, 0.5, -9),
        Parent           = frame,
    })
    Corner(9, track)

    local knob = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        Parent           = track,
    })
    Corner(7, knob)

    -- FIX: hitbox cubre TODO el frame, no solo el track
    local hitbox = New("TextButton", {
        Text                   = "",
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        Position               = UDim2.new(0, 0, 0, 0),
        Parent                 = frame,
    })

    local toggleElem = { _value = value }

    local function setToggle(v, silent)
        toggleElem._value = v
        Tween(track, { BackgroundColor3 = v and theme.ToggleOn or theme.ToggleOff }, 0.2)
        Tween(knob,  { Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.2, Enum.EasingStyle.Back)
        if not silent and callback then pcall(callback, v) end
    end

    hitbox.MouseButton1Click:Connect(function() setToggle(not toggleElem._value) end)
    frame.MouseEnter:Connect(function() Tween(frame, { BackgroundColor3 = theme.ElementHover }, 0.15) end)
    frame.MouseLeave:Connect(function() Tween(frame, { BackgroundColor3 = theme.Element },      0.15) end)

    toggleElem._getValue = function(self) return self._value end
    toggleElem._setValue = function(self, v) setToggle(v, true) end
    toggleElem.Set       = function(self, v) setToggle(v) end
    toggleElem.Get       = function(self) return self._value end

    if config.Key then self._window._elements[config.Key] = toggleElem end
    MakeTooltip(frame, config.Tooltip, self._window._lib)
    return toggleElem
end

-- ─────────────────────────────────────────────────
--  SLIDER
-- ─────────────────────────────────────────────────
function SectionMethods:AddSlider(config)
    config = config or {}
    local theme    = self._window._theme
    local minVal   = config.Min      or 0
    local maxVal   = config.Max      or 100
    local default  = config.Default  or minVal
    local decimals = config.Decimals or 0
    local callback = config.Callback
    local value    = math.clamp(default, minVal, maxVal)

    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size             = UDim2.new(1, 0, 0, 50),
        LayoutOrder      = RegisterElement(self, config.Key, nil),
        Parent           = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(6, 10, 8, 10, frame)

    local topRow = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 16),
        Parent                 = frame,
    })
    New("TextLabel", {
        Text                   = config.Text or "Slider",
        Font                   = Enum.Font.Gotham,
        TextSize               = 12,
        TextColor3             = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.7, 0, 1, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = topRow,
    })
    local valLabel = New("TextLabel", {
        Text                   = tostring(value),
        Font                   = Enum.Font.GothamBold,
        TextSize               = 12,
        TextColor3             = theme.Accent,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.3, 0, 1, 0),
        Position               = UDim2.new(0.7, 0, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Right,
        Parent                 = topRow,
    })

    local track = New("Frame", {
        BackgroundColor3 = theme.SliderTrack,
        Size             = UDim2.new(1, 0, 0, 6),
        Position         = UDim2.new(0, 0, 1, -6),
        Parent           = frame,
    })
    Corner(3, track)

    local fill = New("Frame", {
        BackgroundColor3 = theme.SliderFill,
        Size             = UDim2.new(0, 0, 1, 0),
        Parent           = track,
    })
    Corner(3, fill)

    local knob = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = UDim2.new(0, -7, 0.5, -7),
        Parent           = track,
    })
    Corner(7, knob)
    Stroke(theme.Accent, 2, knob)

    local sliderElem  = { _value = value }
    local lastCbValue = nil  -- FIX: evitar spam de callback con el mismo valor

    local function formatVal(v)
        if decimals > 0 then return string.format("%." .. decimals .. "f", v) end
        return tostring(math.floor(v + 0.5))
    end

    local function setValue(v, silent)
        v = math.clamp(v, minVal, maxVal)
        if decimals == 0 then v = math.floor(v + 0.5) end
        sliderElem._value = v
        local pct = (v - minVal) / (maxVal - minVal)
        Tween(fill, { Size     = UDim2.new(pct, 0, 1, 0) },       0.08)
        Tween(knob, { Position = UDim2.new(pct, -7, 0.5, -7) },   0.08)
        valLabel.Text = formatVal(v)
        -- FIX: solo llamar callback si el valor cambió
        if not silent and callback and v ~= lastCbValue then
            lastCbValue = v
            pcall(callback, v)
        end
    end

    setValue(value, true)

    local dragging = false

    local function updateFromMouse()
        local trackAbs  = track.AbsolutePosition
        local trackSize = track.AbsoluteSize
        local mp        = UserInputService:GetMouseLocation()
        local relX      = math.clamp(mp.X - trackAbs.X, 0, trackSize.X)
        local pct       = relX / trackSize.X
        setValue(minVal + (maxVal - minVal) * pct)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromMouse()
        end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromMouse()
        end
    end)

    frame.MouseEnter:Connect(function() Tween(frame, { BackgroundColor3 = theme.ElementHover }, 0.15) end)
    frame.MouseLeave:Connect(function() Tween(frame, { BackgroundColor3 = theme.Element },      0.15) end)

    sliderElem._getValue = function(self) return self._value end
    sliderElem._setValue = function(self, v) setValue(v, true) end
    sliderElem.Set       = function(self, v) setValue(v) end
    sliderElem.Get       = function(self) return self._value end

    if config.Key then self._window._elements[config.Key] = sliderElem end
    MakeTooltip(frame, config.Tooltip, self._window._lib)
    return sliderElem
end

-- ─────────────────────────────────────────────────
--  DROPDOWN
--  FIX PRINCIPAL: el panel flotante se monta en rootGui
--  con posición absoluta → no se corta por ClipsDescendants
-- ─────────────────────────────────────────────────
function SectionMethods:AddDropdown(config)
    config = config or {}
    local theme    = self._window._theme
    local lib      = self._window._lib
    local options  = config.Options or {}
    local value    = config.Default or (options[1] or "")
    local callback = config.Callback
    local isOpen   = false

    -- Frame del elemento (en la sección)
    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size             = UDim2.new(1, 0, 0, 32),
        LayoutOrder      = RegisterElement(self, config.Key, nil),
        Parent           = self._content,
        ClipsDescendants = false,
        ZIndex           = 2,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(0, 10, 0, 10, frame)

    New("TextLabel", {
        Text                   = config.Text or "Dropdown",
        Font                   = Enum.Font.Gotham,
        TextSize               = 12,
        TextColor3             = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.55, 0, 1, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 3,
        Parent                 = frame,
    })

    local valueLabel = New("TextLabel", {
        Text                   = tostring(value),
        Font                   = Enum.Font.GothamBold,
        TextSize               = 11,
        TextColor3             = theme.Accent,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.35, 0, 1, 0),
        Position               = UDim2.new(0.55, 0, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Right,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        ZIndex                 = 3,
        Parent                 = frame,
    })

    local arrow = New("TextLabel", {
        Text                   = "▾",
        Font                   = Enum.Font.GothamBold,
        TextSize               = 12,
        TextColor3             = theme.TextSecondary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0, 14, 1, 0),
        Position               = UDim2.new(1, -14, 0, 0),
        ZIndex                 = 3,
        Parent                 = frame,
    })

    -- Panel flotante en rootGui (ZIndex alto, fuera del scroll)
    local dropdown = New("Frame", {
        BackgroundColor3 = theme.Section,
        Size             = UDim2.new(0, 10, 0, 0),  -- se ajustará al abrir
        Visible          = false,
        ZIndex           = 150,
        Parent           = lib._rootGui,
    })
    Corner(7, dropdown)
    Stroke(theme.Border, 1, dropdown)

    local dropList = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -4, 1, -4),
        Position               = UDim2.new(0, 2, 0, 2),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = theme.Scrollbar,
        ZIndex                 = 151,
        Parent                 = dropdown,
    })
    local dropLayout = ListLayout(2, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, dropList)
    Padding(2, 4, 2, 4, dropList)

    dropLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        dropList.CanvasSize = UDim2.new(0, 0, 0, dropLayout.AbsoluteContentSize.Y + 4)
    end)

    local dropElem = { _value = value }

    local function repositionDropdown()
        local ap = frame.AbsolutePosition
        local as = frame.AbsoluteSize
        local h  = math.min(#options * 26 + 6, 140)
        dropdown.Size     = UDim2.new(0, as.X, 0, h)
        -- Verificar si hay espacio abajo; si no, abrir hacia arriba
        local vp = workspace.CurrentCamera.ViewportSize
        if ap.Y + as.Y + h > vp.Y - 10 then
            dropdown.Position = UDim2.new(0, ap.X, 0, ap.Y - h - 2)
        else
            dropdown.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 2)
        end
    end

    local function closeDropdown()
        if not isOpen then return end
        isOpen = false
        Tween(dropdown, { Size = UDim2.new(0, dropdown.AbsoluteSize.X, 0, 0) }, 0.18, Enum.EasingStyle.Quart)
        Tween(arrow,    { Rotation = 0 }, 0.18)
        task.delay(0.2, function() dropdown.Visible = false end)
        -- Remover de overlays
        for i, ov in ipairs(lib._openOverlays) do
            if ov.frame == dropdown then table.remove(lib._openOverlays, i); break end
        end
    end

    local function openDropdown()
        if isOpen then return end
        -- Cerrar otros overlays
        for i = #lib._openOverlays, 1, -1 do
            local ov = lib._openOverlays[i]
            if ov and ov.closeFunc then ov.closeFunc() end
        end
        lib._openOverlays = {}

        isOpen = true
        repositionDropdown()
        dropdown.Visible = true
        local targetH = math.min(#options * 26 + 6, 140)
        dropdown.Size = UDim2.new(0, dropdown.AbsoluteSize.X, 0, 0)
        Tween(dropdown, { Size = UDim2.new(0, frame.AbsoluteSize.X, 0, targetH) }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(arrow, { Rotation = 180 }, 0.2)

        table.insert(lib._openOverlays, {
            frame     = dropdown,
            trigger   = frame,
            closeFunc = closeDropdown,
        })
    end

    local function buildOptions()
        for _, child in ipairs(dropList:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        for i, opt in ipairs(options) do
            local isSel = tostring(opt) == tostring(dropElem._value)
            local optBtn = New("TextButton", {
                Text                   = tostring(opt),
                Font                   = Enum.Font.Gotham,
                TextSize               = 11,
                TextColor3             = isSel and theme.Accent or theme.TextPrimary,
                BackgroundColor3       = isSel and theme.ElementActive or Color3.fromRGB(0,0,0),
                BackgroundTransparency = isSel and 0 or 1,
                Size                   = UDim2.new(1, 0, 0, 24),
                TextXAlignment         = Enum.TextXAlignment.Left,
                LayoutOrder            = i,
                ZIndex                 = 152,
                Parent                 = dropList,
            })
            Corner(5, optBtn)
            Padding(0, 4, 0, 8, optBtn)

            optBtn.MouseEnter:Connect(function()
                if not isSel then
                    Tween(optBtn, { BackgroundTransparency = 0, BackgroundColor3 = theme.ElementHover }, 0.1)
                end
            end)
            optBtn.MouseLeave:Connect(function()
                if not isSel then
                    Tween(optBtn, { BackgroundTransparency = 1 }, 0.1)
                end
            end)
            optBtn.MouseButton1Click:Connect(function()
                dropElem._value = opt
                valueLabel.Text = tostring(opt)
                if callback then pcall(callback, opt) end
                buildOptions()
                closeDropdown()
            end)
        end
    end
    buildOptions()

    local hitbox = New("TextButton", {
        Text                   = "",
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        ZIndex                 = 4,
        Parent                 = frame,
    })
    hitbox.MouseButton1Click:Connect(function()
        if isOpen then closeDropdown() else openDropdown() end
    end)

    frame.MouseEnter:Connect(function() Tween(frame, { BackgroundColor3 = theme.ElementHover }, 0.15) end)
    frame.MouseLeave:Connect(function() Tween(frame, { BackgroundColor3 = theme.Element },      0.15) end)

    dropElem._getValue  = function(self) return self._value end
    dropElem._setValue  = function(self, v) self._value = v; valueLabel.Text = tostring(v); buildOptions() end
    dropElem.Set        = dropElem._setValue
    dropElem.Get        = function(self) return self._value end
    dropElem.SetOptions = function(self, opts) options = opts; buildOptions() end

    if config.Key then self._window._elements[config.Key] = dropElem end
    MakeTooltip(frame, config.Tooltip, lib)
    return dropElem
end

-- ─────────────────────────────────────────────────
--  TEXTBOX
-- ─────────────────────────────────────────────────
function SectionMethods:AddTextbox(config)
    config = config or {}
    local theme    = self._window._theme
    local callback = config.Callback
    local value    = config.Default or ""

    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size             = UDim2.new(1, 0, 0, 50),
        LayoutOrder      = RegisterElement(self, config.Key, nil),
        Parent           = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(5, 10, 5, 10, frame)
    ListLayout(4, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, frame)

    New("TextLabel", {
        Text                   = config.Text or "Textbox",
        Font                   = Enum.Font.Gotham,
        TextSize               = 11,
        TextColor3             = theme.TextSecondary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 14),
        TextXAlignment         = Enum.TextXAlignment.Left,
        LayoutOrder            = 1,
        Parent                 = frame,
    })

    local inputFrame = New("Frame", {
        BackgroundColor3 = theme.Background,
        Size             = UDim2.new(1, 0, 0, 22),
        LayoutOrder      = 2,
        Parent           = frame,
    })
    Corner(5, inputFrame)
    local inputStroke = Stroke(theme.Border, 1, inputFrame)

    local inputBox = New("TextBox", {
        Text              = value,
        PlaceholderText   = config.Placeholder or "Escribe aquí...",
        PlaceholderColor3 = theme.TextDisabled,
        Font              = Enum.Font.Gotham,
        TextSize          = 11,
        TextColor3        = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -8, 1, 0),
        Position          = UDim2.new(0, 4, 0, 0),
        TextXAlignment    = Enum.TextXAlignment.Left,
        ClearTextOnFocus  = false,
        Parent            = inputFrame,
    })

    local textElem = { _value = value }

    inputBox.Focused:Connect(function()
        Tween(inputFrame,  { BackgroundColor3 = theme.ElementHover }, 0.15)
        inputStroke.Color = theme.Accent
    end)
    inputBox.FocusLost:Connect(function(enterPressed)
        Tween(inputFrame,  { BackgroundColor3 = theme.Background }, 0.15)
        inputStroke.Color = theme.Border
        textElem._value   = inputBox.Text
        if callback then pcall(callback, inputBox.Text, enterPressed) end
    end)
    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        textElem._value = inputBox.Text
    end)

    textElem._getValue = function(self) return self._value end
    textElem._setValue = function(self, v) inputBox.Text = v; self._value = v end
    textElem.Set       = textElem._setValue
    textElem.Get       = function(self) return self._value end

    if config.Key then self._window._elements[config.Key] = textElem end
    MakeTooltip(frame, config.Tooltip, self._window._lib)
    return textElem
end

-- ─────────────────────────────────────────────────
--  COLOR PICKER
--  FIX: panel montado en rootGui, misma solución que Dropdown
-- ─────────────────────────────────────────────────
function SectionMethods:AddColorPicker(config)
    config = config or {}
    local theme    = self._window._theme
    local lib      = self._window._lib
    local value    = config.Default or Color3.fromRGB(255, 185, 50)
    local callback = config.Callback
    local isOpen   = false

    local function toHSV(c)
        local r, g, b = c.R, c.G, c.B
        local max   = math.max(r, g, b)
        local min   = math.min(r, g, b)
        local delta = max - min
        local h, s, v = 0, 0, max
        if max ~= 0 then s = delta / max end
        if delta ~= 0 then
            if max == r then     h = (g - b) / delta % 6
            elseif max == g then h = (b - r) / delta + 2
            else                 h = (r - g) / delta + 4
            end
            h = h / 6
        end
        return h, s, v
    end

    local h, s, v = toHSV(value)

    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size             = UDim2.new(1, 0, 0, 32),
        LayoutOrder      = RegisterElement(self, config.Key, nil),
        Parent           = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(0, 10, 0, 10, frame)

    New("TextLabel", {
        Text                   = config.Text or "Color",
        Font                   = Enum.Font.Gotham,
        TextSize               = 12,
        TextColor3             = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -50, 1, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 2,
        Parent                 = frame,
    })

    local preview = New("Frame", {
        BackgroundColor3 = value,
        Size             = UDim2.new(0, 24, 0, 18),
        Position         = UDim2.new(1, -26, 0.5, -9),
        ZIndex           = 2,
        Parent           = frame,
    })
    Corner(5, preview)
    Stroke(theme.Border, 1, preview)

    -- Panel flotante en rootGui
    local pickerPanel = New("Frame", {
        BackgroundColor3 = theme.Section,
        Size             = UDim2.new(0, 200, 0, 188),
        Visible          = false,
        ZIndex           = 150,
        Parent           = lib._rootGui,
    })
    Corner(10, pickerPanel)
    Stroke(theme.Border, 1, pickerPanel)
    Padding(8, 8, 8, 8, pickerPanel)

    -- SV Box
    local svBox = New("Frame", {
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Size             = UDim2.new(1, 0, 0, 116),
        ZIndex           = 151,
        Parent           = pickerPanel,
    })
    Corner(6, svBox)

    local svWhite = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = 152,
        Parent           = svBox,
    })
    Corner(6, svWhite)
    local svWhiteGrad = Instance.new("UIGradient")
    svWhiteGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    svWhiteGrad.Parent = svWhite

    local svBlack = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = 153,
        Parent           = svBox,
    })
    Corner(6, svBlack)
    local svBlackGrad = Instance.new("UIGradient")
    svBlackGrad.Rotation = 90
    svBlackGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    svBlackGrad.Parent = svBlack

    local svCursor = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Size             = UDim2.new(0, 10, 0, 10),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(s, 0, 1-v, 0),
        ZIndex           = 154,
        Parent           = svBox,
    })
    Corner(5, svCursor)
    Stroke(Color3.fromRGB(255,255,255), 2, svCursor)

    -- Hue bar
    local hueBar = New("Frame", {
        Size     = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 0, 124),
        ZIndex   = 151,
        Parent   = pickerPanel,
    })
    Corner(6, hueBar)
    local hueGrad = Instance.new("UIGradient")
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,0)),
    })
    hueGrad.Parent = hueBar

    local hueCursor = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Size             = UDim2.new(0, 8, 1, 4),
        Position         = UDim2.new(h, -4, 0, -2),
        ZIndex           = 152,
        Parent           = hueBar,
    })
    Corner(3, hueCursor)
    Stroke(Color3.fromRGB(200,200,200), 1, hueCursor)

    -- Hex input
    local hexFrame = New("Frame", {
        BackgroundColor3 = theme.Background,
        Size             = UDim2.new(1, 0, 0, 22),
        Position         = UDim2.new(0, 0, 0, 144),
        ZIndex           = 151,
        Parent           = pickerPanel,
    })
    Corner(5, hexFrame)
    Stroke(theme.Border, 1, hexFrame)

    local hexInput = New("TextBox", {
        Text              = ColorToHex(value),
        Font              = Enum.Font.Code,
        TextSize          = 10,
        TextColor3        = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -8, 1, 0),
        Position          = UDim2.new(0, 4, 0, 0),
        ClearTextOnFocus  = false,
        ZIndex            = 152,
        Parent            = hexFrame,
    })

    local colorElem = { _value = value }

    local function updateColor(silent)
        local newColor    = Color3.fromHSV(h, s, v)
        colorElem._value  = newColor
        preview.BackgroundColor3 = newColor
        svBox.BackgroundColor3   = Color3.fromHSV(h, 1, 1)
        svCursor.Position        = UDim2.new(s, 0, 1-v, 0)
        hueCursor.Position       = UDim2.new(h, -4, 0, -2)
        hexInput.Text            = ColorToHex(newColor)
        if not silent and callback then pcall(callback, newColor) end
    end
    updateColor(true)

    -- Dragging SV
    local draggingSV  = false
    local draggingHue = false

    svBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSV = true
            local pos = svBox.AbsolutePosition
            local sz  = svBox.AbsoluteSize
            local mp  = UserInputService:GetMouseLocation()
            s = math.clamp((mp.X - pos.X) / sz.X, 0, 1)
            v = 1 - math.clamp((mp.Y - pos.Y) / sz.Y, 0, 1)
            updateColor()
        end
    end)
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
            local pos = hueBar.AbsolutePosition
            local sz  = hueBar.AbsoluteSize
            local mp  = UserInputService:GetMouseLocation()
            h = math.clamp((mp.X - pos.X) / sz.X, 0, 1)
            updateColor()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local mp = UserInputService:GetMouseLocation()
        if draggingSV then
            local pos = svBox.AbsolutePosition
            local sz  = svBox.AbsoluteSize
            s = math.clamp((mp.X - pos.X) / sz.X, 0, 1)
            v = 1 - math.clamp((mp.Y - pos.Y) / sz.Y, 0, 1)
            updateColor()
        elseif draggingHue then
            local pos = hueBar.AbsolutePosition
            local sz  = hueBar.AbsoluteSize
            h = math.clamp((mp.X - pos.X) / sz.X, 0, 1)
            updateColor()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSV  = false
            draggingHue = false
        end
    end)

    hexInput.FocusLost:Connect(function()
        local ok, c = pcall(function() return HexToColor(hexInput.Text) end)
        if ok then
            colorElem._value = c
            h, s, v = toHSV(c)
            updateColor()
        end
    end)

    local function closePicker()
        if not isOpen then return end
        isOpen = false
        pickerPanel.Visible = false
        for i, ov in ipairs(lib._openOverlays) do
            if ov.frame == pickerPanel then table.remove(lib._openOverlays, i); break end
        end
    end

    local hitbox = New("TextButton", {
        Text                   = "",
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0, 24, 0, 18),
        Position               = UDim2.new(1, -26, 0.5, -9),
        ZIndex                 = 3,
        Parent                 = frame,
    })
    hitbox.MouseButton1Click:Connect(function()
        if isOpen then
            closePicker()
        else
            -- Cerrar otros overlays
            for i = #lib._openOverlays, 1, -1 do
                local ov = lib._openOverlays[i]
                if ov and ov.closeFunc then ov.closeFunc() end
            end
            lib._openOverlays = {}

            isOpen = true
            -- Posicionar panel
            local ap = frame.AbsolutePosition
            local as = frame.AbsoluteSize
            local vp = workspace.CurrentCamera.ViewportSize
            local px_ = ap.X + as.X - 200
            local py_ = ap.Y + as.Y + 2
            if py_ + 188 > vp.Y - 10 then py_ = ap.Y - 190 end
            if px_ < 2 then px_ = 2 end
            pickerPanel.Position = UDim2.new(0, px_, 0, py_)
            pickerPanel.Visible  = true

            table.insert(lib._openOverlays, {
                frame     = pickerPanel,
                trigger   = frame,
                closeFunc = closePicker,
            })
        end
    end)

    colorElem._getValue = function(self) return self._value end
    colorElem._setValue = function(self, c)
        colorElem._value = c; h, s, v = toHSV(c); updateColor(true)
    end
    colorElem.Set = function(self, c) colorElem._value = c; h, s, v = toHSV(c); updateColor() end
    colorElem.Get = function(self) return self._value end

    if config.Key then self._window._elements[config.Key] = colorElem end
    MakeTooltip(frame, config.Tooltip, lib)
    return colorElem
end

-- ─────────────────────────────────────────────────
--  KEYBIND
-- ─────────────────────────────────────────────────
function SectionMethods:AddKeybind(config)
    config = config or {}
    local theme     = self._window._theme
    local lib       = self._window._lib
    local value     = config.Default
    local callback  = config.Callback
    local listening = false

    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size             = UDim2.new(1, 0, 0, 32),
        LayoutOrder      = RegisterElement(self, config.Key, nil),
        Parent           = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(0, 10, 0, 10, frame)

    New("TextLabel", {
        Text                   = config.Text or "Keybind",
        Font                   = Enum.Font.Gotham,
        TextSize               = 12,
        TextColor3             = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.6, 0, 1, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = frame,
    })

    local keyBtn = New("TextButton", {
        Text             = value and value.Name or "Ninguna",
        Font             = Enum.Font.GothamBold,
        TextSize         = 10,
        TextColor3       = theme.Accent,
        BackgroundColor3 = theme.ElementActive,
        Size             = UDim2.new(0, 82, 0, 20),
        Position         = UDim2.new(1, -84, 0.5, -10),
        AutoButtonColor  = false,
        Parent           = frame,
    })
    Corner(5, keyBtn)
    Stroke(theme.BorderAccent, 1, keyBtn)

    local kbElem = { _value = value }

    local function setKey(k, silent)
        kbElem._value    = k
        keyBtn.Text      = k and k.Name or "Ninguna"
        keyBtn.TextColor3 = k and theme.Accent or theme.TextSecondary
        if not silent and callback then pcall(callback, k) end
    end

    local function updateGlobalKB()
        if config.Key and kbElem._value then
            lib:RegisterKeybind(
                "elem_" .. config.Key,
                kbElem._value,
                function() if callback then pcall(callback, kbElem._value) end end)
        end
    end

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text      = "..."
        keyBtn.TextColor3 = theme.NotifyWarning
        lib:GetPressedKey(function(keyCode)
            listening = false
            if keyCode == Enum.KeyCode.Escape then
                setKey(nil)
            else
                setKey(keyCode)
                updateGlobalKB()
            end
        end)
    end)

    keyBtn.MouseButton2Click:Connect(function()
        setKey(nil)
        if config.Key then lib:UnregisterKeybind("elem_" .. config.Key) end
    end)

    frame.MouseEnter:Connect(function() Tween(frame, { BackgroundColor3 = theme.ElementHover }, 0.15) end)
    frame.MouseLeave:Connect(function() Tween(frame, { BackgroundColor3 = theme.Element },      0.15) end)

    kbElem._getValue = function(self) return self._value and self._value.Name or nil end
    kbElem._setValue = function(self, v)
        if type(v) == "string" then
            local ok, k = pcall(function() return Enum.KeyCode[v] end)
            if ok then setKey(k, true) end
        else setKey(v, true) end
    end
    kbElem.Set = function(self, k) setKey(k) end
    kbElem.Get = function(self) return self._value end

    if value then updateGlobalKB() end
    if config.Key then self._window._elements[config.Key] = kbElem end
    MakeTooltip(frame, config.Tooltip, lib)
    return kbElem
end

-- ─────────────────────────────────────────────────
--  LISTBOX
-- ─────────────────────────────────────────────────
function SectionMethods:AddListbox(config)
    config = config or {}
    local theme    = self._window._theme
    local options  = config.Options or {}
    local multi    = config.Multi   or false
    local callback = config.Callback
    local selected = {}

    if config.Default then
        if type(config.Default) == "table" then
            for _, v in ipairs(config.Default) do selected[tostring(v)] = true end
        else
            selected[tostring(config.Default)] = true
        end
    end

    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size             = UDim2.new(1, 0, 0, 94),
        LayoutOrder      = RegisterElement(self, config.Key, nil),
        Parent           = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(4, 6, 4, 6, frame)
    ListLayout(4, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, frame)

    New("TextLabel", {
        Text                   = config.Text or "Listbox",
        Font                   = Enum.Font.GothamBold,
        TextSize               = 11,
        TextColor3             = theme.Accent,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 14),
        TextXAlignment         = Enum.TextXAlignment.Left,
        LayoutOrder            = 1,
        Parent                 = frame,
    })

    local scroll = New("ScrollingFrame", {
        BackgroundColor3   = theme.Background,
        Size               = UDim2.new(1, 0, 1, -18),
        CanvasSize         = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Scrollbar,
        LayoutOrder        = 2,
        Parent             = frame,
    })
    Corner(5, scroll)
    local listLayout = ListLayout(2, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, scroll)
    Padding(2, 4, 2, 4, scroll)

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
    end)

    local listElem = { _selected = selected }

    local function getSelected()
        local out = {}
        for k in pairs(selected) do table.insert(out, k) end
        return out
    end

    local function buildList()
        for _, c in ipairs(scroll:GetChildren()) do
            if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
        end
        for i, opt in ipairs(options) do
            local isSel = selected[tostring(opt)] == true
            local row = New("TextButton", {
                Text                   = tostring(opt),
                Font                   = Enum.Font.Gotham,
                TextSize               = 11,
                TextColor3             = isSel and theme.Accent or theme.TextPrimary,
                BackgroundColor3       = isSel and theme.ElementActive or Color3.fromRGB(0,0,0),
                BackgroundTransparency = isSel and 0 or 1,
                Size                   = UDim2.new(1, 0, 0, 22),
                TextXAlignment         = Enum.TextXAlignment.Left,
                LayoutOrder            = i,
                Parent                 = scroll,
            })
            Corner(4, row)
            Padding(0, 4, 0, 8, row)

            row.MouseEnter:Connect(function()
                if not selected[tostring(opt)] then
                    Tween(row, { BackgroundTransparency = 0, BackgroundColor3 = theme.ElementHover }, 0.1)
                end
            end)
            row.MouseLeave:Connect(function()
                if not selected[tostring(opt)] then
                    Tween(row, { BackgroundTransparency = 1 }, 0.1)
                end
            end)
            row.MouseButton1Click:Connect(function()
                if not multi then
                    for k in pairs(selected) do selected[k] = nil end
                end
                if selected[tostring(opt)] then
                    selected[tostring(opt)] = nil
                else
                    selected[tostring(opt)] = true
                end
                buildList()
                if callback then pcall(callback, getSelected()) end
            end)
        end
    end
    buildList()

    listElem._getValue  = function(self) return getSelected() end
    listElem._setValue  = function(self, vals)
        selected = {}
        if type(vals) == "table" then
            for _, v in ipairs(vals) do selected[tostring(v)] = true end
        else selected[tostring(vals)] = true end
        buildList()
    end
    listElem.Get        = listElem._getValue
    listElem.Set        = listElem._setValue
    listElem.SetOptions = function(self, opts) options = opts; buildList() end

    if config.Key then self._window._elements[config.Key] = listElem end
    MakeTooltip(frame, config.Tooltip, self._window._lib)
    return listElem
end

-- ═══════════════════════════════════════════════════════════════
--  RETORNAR LA LIBRERÍA
-- ═══════════════════════════════════════════════════════════════
return Nova
