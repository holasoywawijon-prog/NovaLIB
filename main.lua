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
║   Nova UI Library v1.0  —  Roblox Lua                                       ║
║   Diseño: Glassmorphism Oscuro con acentos neón aguamarina                  ║
║   Autor: Nova Library                                                        ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

LICENCIA: Libre para uso personal y proyectos de Roblox.
No re-distribuir como propia. Créditos apreciados.

DESCRIPCIÓN:
  Nova es una librería de UI completa para Roblox con estética Glassmorphism
  oscura, acentos de neón aguamarina/cyan, animaciones suaves, sistema de
  notificaciones, logger integrado, keybinds globales, y una API limpia.

CARACTERÍSTICAS:
  • Ventanas arrastrables, minimizables y con temas
  • Tabs con íconos, Secciones agrupables
  • Button, Toggle, Slider, Dropdown, Textbox, ColorPicker
  • Label, Paragraph, Keybind, Listbox, Separator
  • Logger flotante con niveles y exportación
  • Sistema de notificaciones con cola y tipos
  • Keybinds globales registrables
  • SaveConfig / LoadConfig con persistencia
  • Soporte para temas claro/oscuro custom

USO BÁSICO:
  local Nova = loadstring(...)()
  local win = Nova:new({ Title = "Mi App", Theme = "Dark" })
  local tab = win:AddTab("Principal", "rbxassetid://...")
  local sec = tab:AddSection("Opciones")
  sec:AddButton({ Text = "Hola", Callback = function() print("click") end })

]]

-- ═══════════════════════════════════════════════════════════════
--  SERVICIOS
-- ═══════════════════════════════════════════════════════════════
local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")
local CoreGui            = game:GetService("CoreGui")

local LocalPlayer        = Players.LocalPlayer
local Mouse              = LocalPlayer:GetMouse()

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
        -- Fondo principal de la ventana
        Background       = Color3.fromRGB(12, 14, 20),
        -- Panel lateral (tabs)
        Sidebar          = Color3.fromRGB(16, 19, 28),
        -- Cabecera de la ventana
        Header           = Color3.fromRGB(10, 12, 18),
        -- Secciones / cajas
        Section          = Color3.fromRGB(20, 24, 36),
        -- Elementos interactivos (fondo de botones, inputs)
        Element          = Color3.fromRGB(26, 31, 46),
        -- Elemento hover
        ElementHover     = Color3.fromRGB(34, 41, 60),
        -- Elemento activo / presionado
        ElementActive    = Color3.fromRGB(22, 28, 42),
        -- Acento principal (aguamarina/cyan neón)
        Accent           = Color3.fromRGB(0, 210, 190),
        -- Acento secundario (violeta suave)
        AccentSecondary  = Color3.fromRGB(120, 80, 220),
        -- Texto primario
        TextPrimary      = Color3.fromRGB(220, 230, 245),
        -- Texto secundario / subtítulos
        TextSecondary    = Color3.fromRGB(130, 145, 175),
        -- Texto deshabilitado
        TextDisabled     = Color3.fromRGB(70, 80, 105),
        -- Bordes
        Border           = Color3.fromRGB(35, 42, 62),
        -- Borde de acento
        BorderAccent     = Color3.fromRGB(0, 180, 165),
        -- Scrollbar
        Scrollbar        = Color3.fromRGB(40, 50, 75),
        -- Toggle ON
        ToggleOn         = Color3.fromRGB(0, 210, 190),
        -- Toggle OFF
        ToggleOff        = Color3.fromRGB(45, 52, 72),
        -- Slider track
        SliderTrack      = Color3.fromRGB(30, 37, 55),
        -- Slider fill
        SliderFill       = Color3.fromRGB(0, 210, 190),
        -- Notificación info
        NotifyInfo       = Color3.fromRGB(0, 150, 220),
        -- Notificación success
        NotifySuccess    = Color3.fromRGB(0, 200, 130),
        -- Notificación warning
        NotifyWarning    = Color3.fromRGB(240, 170, 0),
        -- Notificación error
        NotifyError      = Color3.fromRGB(220, 60, 80),
        -- Logger background
        LoggerBg         = Color3.fromRGB(8, 10, 16),
        -- Log info
        LogInfo          = Color3.fromRGB(80, 160, 240),
        -- Log warn
        LogWarn          = Color3.fromRGB(240, 190, 50),
        -- Log error
        LogError         = Color3.fromRGB(230, 70, 90),
        -- Log debug
        LogDebug         = Color3.fromRGB(160, 100, 240),
        -- Sombra
        Shadow           = Color3.fromRGB(0, 0, 0),
        -- Tab activo
        TabActive        = Color3.fromRGB(0, 210, 190),
        -- Tab inactivo
        TabInactive      = Color3.fromRGB(70, 80, 110),
        -- Indicador de tab
        TabIndicator     = Color3.fromRGB(0, 210, 190),
    },
    Light = {
        Background       = Color3.fromRGB(240, 243, 250),
        Sidebar          = Color3.fromRGB(225, 230, 245),
        Header           = Color3.fromRGB(215, 220, 238),
        Section          = Color3.fromRGB(250, 252, 255),
        Element          = Color3.fromRGB(235, 239, 252),
        ElementHover     = Color3.fromRGB(220, 226, 245),
        ElementActive    = Color3.fromRGB(205, 213, 238),
        Accent           = Color3.fromRGB(0, 170, 155),
        AccentSecondary  = Color3.fromRGB(100, 60, 200),
        TextPrimary      = Color3.fromRGB(30, 35, 55),
        TextSecondary    = Color3.fromRGB(90, 100, 130),
        TextDisabled     = Color3.fromRGB(170, 178, 200),
        Border           = Color3.fromRGB(200, 208, 228),
        BorderAccent     = Color3.fromRGB(0, 160, 145),
        Scrollbar        = Color3.fromRGB(180, 190, 215),
        ToggleOn         = Color3.fromRGB(0, 170, 155),
        ToggleOff        = Color3.fromRGB(195, 200, 220),
        SliderTrack      = Color3.fromRGB(210, 216, 235),
        SliderFill       = Color3.fromRGB(0, 170, 155),
        NotifyInfo       = Color3.fromRGB(0, 120, 200),
        NotifySuccess    = Color3.fromRGB(0, 170, 110),
        NotifyWarning    = Color3.fromRGB(200, 140, 0),
        NotifyError      = Color3.fromRGB(200, 50, 70),
        LoggerBg         = Color3.fromRGB(230, 234, 245),
        LogInfo          = Color3.fromRGB(0, 100, 200),
        LogWarn          = Color3.fromRGB(180, 130, 0),
        LogError         = Color3.fromRGB(190, 40, 60),
        LogDebug         = Color3.fromRGB(120, 60, 200),
        Shadow           = Color3.fromRGB(150, 160, 190),
        TabActive        = Color3.fromRGB(0, 170, 155),
        TabInactive      = Color3.fromRGB(130, 140, 170),
        TabIndicator     = Color3.fromRGB(0, 170, 155),
    },
}

-- ───────────────────────────────────────────────
--  ESTADO GLOBAL DE LA LIBRERÍA
-- ───────────────────────────────────────────────
Nova._windows       = {}   -- Ventanas activas
Nova._keybinds      = {}   -- Keybinds globales
Nova._notifyQueue   = {}   -- Cola de notificaciones
Nova._notifyActive  = {}   -- Notificaciones visibles
Nova._config        = {}   -- Configuración guardada
Nova._configKey     = "NovaLib_Config"
Nova._maxNotifications = 4
Nova._initialized   = false

-- ───────────────────────────────────────────────
--  UTILIDADES INTERNAS
-- ───────────────────────────────────────────────

-- Tween helper
local function Tween(instance, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    duration  = duration  or 0.25
    local info = TweenInfo.new(duration, style, direction)
    local t    = TweenService:Create(instance, info, props)
    t:Play()
    return t
end

-- Crear instância de forma concisa
local function New(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

-- Debounce helper
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

-- Clonar tabla
local function DeepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = DeepCopy(v)
    end
    return copy
end

-- Interpolar color
local function LerpColor(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

-- Color3 a Hex string
local function ColorToHex(c)
    return string.format("#%02X%02X%02X",
        math.floor(c.R * 255),
        math.floor(c.G * 255),
        math.floor(c.B * 255)
    )
end

-- Hex a Color3
local function HexToColor(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1,2), 16) / 255
    local g = tonumber(hex:sub(3,4), 16) / 255
    local b = tonumber(hex:sub(5,6), 16) / 255
    return Color3.new(r, g, b)
end

-- Texto corto con "..."
local function Truncate(text, maxLen)
    if #text > maxLen then
        return text:sub(1, maxLen - 3) .. "..."
    end
    return text
end

-- Timestamp
local function GetTimestamp()
    -- Roblox no tiene acceso a os.date completo en algunos contextos,
    -- pero os.time() y tick() están disponibles.
    local t = os.time()
    local h = math.floor(t / 3600) % 24
    local m = math.floor(t / 60) % 60
    local s = t % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- Crear UICorner
local function Corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    if parent then c.Parent = parent end
    return c
end

-- Crear UIStroke (borde)
local function Stroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color     = color or Color3.new(1,1,1)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    if parent then s.Parent = parent end
    return s
end

-- Crear UIPadding
local function Padding(top, right, bottom, left, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    if parent then p.Parent = parent end
    return p
end

-- Crear UIListLayout
local function ListLayout(padding, fillDir, sortOrder, parent)
    local l = Instance.new("UIListLayout")
    l.Padding          = UDim.new(0, padding  or 4)
    l.FillDirection    = fillDir  or Enum.FillDirection.Vertical
    l.SortOrder        = sortOrder or Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    if parent then l.Parent = parent end
    return l
end

-- ───────────────────────────────────────────────
--  SISTEMA DE DRAG (arrastrar ventanas)
-- ───────────────────────────────────────────────
local function MakeDraggable(frame, handle, onDrag)
    local dragging    = false
    local dragStart   = nil
    local startPos    = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Ctrl + arrastar = bloqueado
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
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            frame.Position = newPos
            if onDrag then onDrag(newPos) end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  INICIALIZACIÓN DE LA LIBRERÍA (ScreenGui raíz)
-- ═══════════════════════════════════════════════════════════════
function Nova:_init()
    if self._initialized then return end
    self._initialized = true

    -- ScreenGui principal (se intenta meter en CoreGui para evitar que
    -- se destruya con el personaje; si no hay permiso, usa PlayerGui)
    local gui
    local ok = pcall(function()
        -- Eliminar instancias anteriores
        local old = CoreGui:FindFirstChild("NovaLib_Root")
        if old then old:Destroy() end

        gui = New("ScreenGui", {
            Name            = "NovaLib_Root",
            ResetOnSpawn    = false,
            ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
            DisplayOrder    = 999,
            Parent          = CoreGui,
        })
    end)

    if not ok then
        local old = LocalPlayer:FindFirstChild("PlayerGui") and
                    LocalPlayer.PlayerGui:FindFirstChild("NovaLib_Root")
        if old then old:Destroy() end

        gui = New("ScreenGui", {
            Name            = "NovaLib_Root",
            ResetOnSpawn    = false,
            ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
            DisplayOrder    = 999,
            Parent          = LocalPlayer.PlayerGui,
        })
    end

    self._rootGui = gui

    -- Contenedor de notificaciones (esquina superior derecha)
    self._notifyContainer = New("Frame", {
        Name              = "NotifyContainer",
        BackgroundTransparency = 1,
        Position          = UDim2.new(1, -320, 0, 20),
        Size              = UDim2.new(0, 300, 1, -40),
        Parent            = gui,
    })
    ListLayout(8, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, self._notifyContainer)

    -- Iniciar listener de keybinds globales
    self:_startKeybindListener()
end

-- ───────────────────────────────────────────────
--  LISTENER DE KEYBINDS GLOBAL
-- ───────────────────────────────────────────────
function Nova:_startKeybindListener()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        -- Notificar a cualquier Keybind en modo "AnyKey"
        for _, win in pairs(self._windows) do
            if win._anyKeyCapture then
                win._anyKeyCapture(input.KeyCode)
                win._anyKeyCapture = nil
            end
        end
        -- Ejecutar keybinds registrados
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

--- Registra un keybind global
function Nova:RegisterKeybind(name, key, callback)
    self._keybinds[name] = { Key = key, Callback = callback }
    -- Guardar en _G para persistencia entre scripts
    _G["NovaKeybinds"] = _G["NovaKeybinds"] or {}
    _G["NovaKeybinds"][name] = key and key.Name or nil
end

--- Elimina un keybind global
function Nova:UnregisterKeybind(name)
    self._keybinds[name] = nil
    if _G["NovaKeybinds"] then
        _G["NovaKeybinds"][name] = nil
    end
end

--- Obtiene la siguiente tecla presionada (modo AnyKey) — devuelve Promise-like via callback
function Nova:GetPressedKey(callback)
    -- Se resuelve en el primer InputBegan no bloqueado
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

--- Muestra una notificación flotante
--- @param config { Title, Text, Duration, Icon, Type, Callback }
---   Type: "info" | "success" | "warning" | "error"
function Nova:Notify(config)
    config = config or {}
    local title    = config.Title    or "Notificación"
    local text     = config.Text     or ""
    local duration = config.Duration or 4
    local icon     = config.Icon     or nil
    local nType    = config.Type     or "info"
    local callback = config.Callback or nil

    -- Poner en cola si ya hay demasiadas activas
    if #self._notifyActive >= self._maxNotifications then
        table.insert(self._notifyQueue, config)
        return
    end

    self:_showNotification(title, text, duration, icon, nType, callback)
end

function Nova:_showNotification(title, text, duration, icon, nType, callback)
    self:_init()
    local theme = Nova.Themes.Dark  -- Las notificaciones siempre usan Dark por defecto de estilo

    -- Color según tipo
    local typeColor = theme.NotifyInfo
    local typeIcon  = "ℹ"
    if nType == "success" then typeColor = theme.NotifySuccess; typeIcon = "✓"
    elseif nType == "warning" then typeColor = theme.NotifyWarning; typeIcon = "⚠"
    elseif nType == "error" then typeColor = theme.NotifyError; typeIcon = "✖"
    end

    -- Frame de la notificación
    local notify = New("Frame", {
        Name              = "Notification",
        BackgroundColor3  = Color3.fromRGB(18, 22, 34),
        Size              = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        Parent            = self._notifyContainer,
    })
    Corner(10, notify)

    -- Efecto de entrada: deslizar desde la derecha
    notify.Position = UDim2.new(1, 20, 0, 0)

    -- Fondo principal
    local bg = New("Frame", {
        Name              = "BG",
        BackgroundColor3  = Color3.fromRGB(18, 22, 34),
        Size              = UDim2.new(1, 0, 1, 0),
        Parent            = notify,
    })
    Corner(10, bg)
    Stroke(typeColor, 1, bg)

    -- Barra de color lateral izquierda
    local colorBar = New("Frame", {
        BackgroundColor3 = typeColor,
        Size             = UDim2.new(0, 4, 1, -16),
        Position         = UDim2.new(0, 0, 0, 8),
        Parent           = bg,
    })
    Corner(4, colorBar)

    -- Ícono de tipo
    local iconLabel = New("TextLabel", {
        Text              = icon or typeIcon,
        Font              = Enum.Font.GothamBold,
        TextSize          = 18,
        TextColor3        = typeColor,
        BackgroundTransparency = 1,
        Size              = UDim2.new(0, 30, 0, 30),
        Position          = UDim2.new(0, 14, 0, 8),
        Parent            = bg,
    })

    -- Título
    New("TextLabel", {
        Text              = title,
        Font              = Enum.Font.GothamBold,
        TextSize          = 13,
        TextColor3        = Color3.fromRGB(220, 230, 245),
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -60, 0, 18),
        Position          = UDim2.new(0, 50, 0, 8),
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = bg,
    })

    -- Texto
    New("TextLabel", {
        Text              = text,
        Font              = Enum.Font.Gotham,
        TextSize          = 11,
        TextColor3        = Color3.fromRGB(140, 155, 185),
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -60, 0, 26),
        Position          = UDim2.new(0, 50, 0, 26),
        TextXAlignment    = Enum.TextXAlignment.Left,
        TextWrapped       = true,
        Parent            = bg,
    })

    -- Barra de progreso
    local progressBg = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(30, 36, 54),
        Size             = UDim2.new(1, -16, 0, 3),
        Position         = UDim2.new(0, 8, 1, -6),
        Parent           = bg,
    })
    Corner(2, progressBg)

    local progressFill = New("Frame", {
        BackgroundColor3 = typeColor,
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = progressBg,
    })
    Corner(2, progressFill)

    -- Botón de cerrar
    local closeBtn = New("TextButton", {
        Text              = "×",
        Font              = Enum.Font.GothamBold,
        TextSize          = 16,
        TextColor3        = Color3.fromRGB(130, 145, 175),
        BackgroundTransparency = 1,
        Size              = UDim2.new(0, 20, 0, 20),
        Position          = UDim2.new(1, -24, 0, 4),
        Parent            = bg,
    })

    -- Registrar como activa
    table.insert(self._notifyActive, notify)

    -- Animar entrada
    notify.BackgroundTransparency = 0
    Tween(notify, { Position = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Callback al hacer click
    if callback then
        bg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                pcall(callback)
            end
        end)
    end

    -- Función para cerrar la notificación
    local closed = false
    local function closeNotify()
        if closed then return end
        closed = true
        Tween(notify, {
            Position = UDim2.new(1, 20, 0, 0),
            BackgroundTransparency = 1
        }, 0.25)
        task.delay(0.3, function()
            notify:Destroy()
            -- Remover de activas
            for i, n in ipairs(self._notifyActive) do
                if n == notify then
                    table.remove(self._notifyActive, i)
                    break
                end
            end
            -- Procesar cola
            if #self._notifyQueue > 0 then
                local next = table.remove(self._notifyQueue, 1)
                self:_showNotification(
                    next.Title or "Notificación",
                    next.Text or "",
                    next.Duration or 4,
                    next.Icon,
                    next.Type or "info",
                    next.Callback
                )
            end
        end)
    end

    closeBtn.MouseButton1Click:Connect(closeNotify)

    -- Animar barra de progreso y cerrar automáticamente
    Tween(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)
    task.delay(duration, closeNotify)

    -- Hover
    bg.MouseEnter:Connect(function()
        Tween(bg, { BackgroundColor3 = Color3.fromRGB(24, 30, 46) }, 0.15)
    end)
    bg.MouseLeave:Connect(function()
        Tween(bg, { BackgroundColor3 = Color3.fromRGB(18, 22, 34) }, 0.15)
    end)
end

-- ───────────────────────────────────────────────
--  API GLOBAL: Config
-- ───────────────────────────────────────────────

--- Guarda la configuración en _G (persistencia entre runs del mismo juego)
function Nova:SaveConfig()
    local data = {}
    for _, win in pairs(self._windows) do
        data[win._id] = win:_collectConfig()
    end
    self._config = data
    _G[self._configKey] = HttpService:JSONEncode(data)
    return data
end

--- Carga la configuración guardada
function Nova:LoadConfig()
    local raw = _G[self._configKey]
    if not raw then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok then return false end
    self._config = data
    for _, win in pairs(self._windows) do
        if data[win._id] then
            win:_applyConfig(data[win._id])
        end
    end
    return true
end

--- Destruye toda la librería
function Nova:Destroy()
    if self._rootGui then
        self._rootGui:Destroy()
    end
    self._windows     = {}
    self._keybinds    = {}
    self._notifyQueue = {}
    self._notifyActive = {}
    self._initialized = false
end

--- Obtiene el logger global (del primer window, o nil)
function Nova:GetLogger()
    for _, win in pairs(self._windows) do
        if win._logger then return win._logger end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════
--  VENTANA (Window)
-- ═══════════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

--- Crea una nueva ventana
--- @param config { Title, Size, Theme, Position, MinSize, Icon, Closable }
function Nova:new(config)
    self:_init()

    config = config or {}

    local win = setmetatable({}, Window)
    win._lib         = self
    win._id          = config.Id or ("Window_" .. tostring(#self._windows + 1))
    win._title       = config.Title     or "Nova UI"
    win._themeName   = config.Theme     or "Dark"
    win._theme       = Nova.Themes[win._themeName] or Nova.Themes.Dark
    win._tabs        = {}
    win._activeTab   = nil
    win._minimized   = false
    win._visible     = true
    win._elements    = {}  -- todos los elementos con su key para config
    win._anyKeyCapture = nil

    -- Tamaño y posición
    local w = (config.Size and config.Size.X) or 600
    local h = (config.Size and config.Size.Y) or 420
    local px = (config.Position and config.Position.X) or 0.5
    local py = (config.Position and config.Position.Y) or 0.5
    win._size = { w = w, h = h }

    -- ── Construir el GUI de la ventana ──
    win:_build(w, h, px, py)

    -- ── Logger integrado ──
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

    -- ── Contenedor raíz (sombra + ventana) ──
    self._root = New("Frame", {
        Name              = "NovaWindow_" .. self._id,
        BackgroundTransparency = 1,
        Size              = UDim2.new(0, w, 0, h),
        Position          = UDim2.new(px, -w/2, py, -h/2),
        Parent            = lib._rootGui,
    })

    -- Sombra
    local shadow = New("ImageLabel", {
        Name              = "Shadow",
        BackgroundTransparency = 1,
        Image             = "rbxassetid://6014261993",
        ImageColor3       = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
        Size              = UDim2.new(1, 46, 1, 46),
        Position          = UDim2.new(0, -23, 0, -23),
        ZIndex            = 0,
        Parent            = self._root,
    })

    -- Frame principal
    self._main = New("Frame", {
        Name              = "Main",
        BackgroundColor3  = theme.Background,
        Size              = UDim2.new(1, 0, 1, 0),
        Parent            = self._root,
    })
    Corner(12, self._main)
    Stroke(theme.Border, 1, self._main)

    -- ── HEADER ──
    self._header = New("Frame", {
        Name              = "Header",
        BackgroundColor3  = theme.Header,
        Size              = UDim2.new(1, 0, 0, 42),
        Parent            = self._main,
    })
    -- Redondear solo las esquinas superiores
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = self._header

    -- Parche para no redondear las esquinas inferiores del header
    New("Frame", {
        BackgroundColor3 = theme.Header,
        Size  = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        Parent = self._header,
    })

    -- Logo / acento del header
    local accentBar = New("Frame", {
        BackgroundColor3 = theme.Accent,
        Size  = UDim2.new(0, 3, 0, 22),
        Position = UDim2.new(0, 12, 0.5, -11),
        Parent = self._header,
    })
    Corner(2, accentBar)

    -- Título
    self._titleLabel = New("TextLabel", {
        Text              = self._title,
        Font              = Enum.Font.GothamBold,
        TextSize          = 14,
        TextColor3        = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -160, 1, 0),
        Position          = UDim2.new(0, 24, 0, 0),
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = self._header,
    })

    -- ── Botones del header ──
    local btnY = UDim2.new(0.5, -10, 0, 11)  -- posición Y centrada, X se desplaza

    -- Botón Logger
    local logBtn = New("TextButton", {
        Text              = "◈",
        Font              = Enum.Font.GothamBold,
        TextSize          = 14,
        TextColor3        = theme.TextSecondary,
        BackgroundColor3  = theme.Element,
        Size              = UDim2.new(0, 20, 0, 20),
        Position          = UDim2.new(1, -108, 0.5, -10),
        Parent            = self._header,
    })
    Corner(5, logBtn)

    -- Botón Minimizar
    local minBtn = New("TextButton", {
        Text              = "─",
        Font              = Enum.Font.GothamBold,
        TextSize          = 13,
        TextColor3        = theme.TextSecondary,
        BackgroundColor3  = theme.Element,
        Size              = UDim2.new(0, 20, 0, 20),
        Position          = UDim2.new(1, -82, 0.5, -10),
        Parent            = self._header,
    })
    Corner(5, minBtn)

    -- Botón Cerrar
    local closeBtn = New("TextButton", {
        Text              = "×",
        Font              = Enum.Font.GothamBold,
        TextSize          = 16,
        TextColor3        = Color3.fromRGB(220, 80, 80),
        BackgroundColor3  = theme.Element,
        Size              = UDim2.new(0, 20, 0, 20),
        Position          = UDim2.new(1, -28, 0.5, -10),
        Parent            = self._header,
    })
    Corner(5, closeBtn)

    -- Botón Config (guardar/cargar)
    local cfgBtn = New("TextButton", {
        Text              = "⚙",
        Font              = Enum.Font.GothamBold,
        TextSize          = 14,
        TextColor3        = theme.TextSecondary,
        BackgroundColor3  = theme.Element,
        Size              = UDim2.new(0, 20, 0, 20),
        Position          = UDim2.new(1, -55, 0.5, -10),
        Parent            = self._header,
    })
    Corner(5, cfgBtn)

    -- Hover effects para botones del header
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

    -- ── Callback del botón Logger ──
    logBtn.MouseButton1Click:Connect(function()
        if self._loggerFrame then
            local vis = not self._loggerFrame.Visible
            self._loggerFrame.Visible = vis
            if vis then
                self._loggerFrame.BackgroundTransparency = 1
                Tween(self._loggerFrame, { BackgroundTransparency = 0 }, 0.2)
            end
        end
    end)

    -- ── Callback del botón Minimizar ──
    minBtn.MouseButton1Click:Connect(function()
        if self._minimized then
            self:Restore()
        else
            self:Minimize()
        end
    end)

    -- ── Callback del botón Cerrar ──
    closeBtn.MouseButton1Click:Connect(function()
        self:_hide()
    end)

    -- ── Callback Config ──
    cfgBtn.MouseButton1Click:Connect(function()
        lib:SaveConfig()
        lib:Notify({
            Title = "Configuración guardada",
            Text = "Nova ha guardado el estado actual.",
            Type = "success",
            Duration = 3,
        })
    end)

    -- ── Contenedor cuerpo (sidebar + contenido) ──
    self._body = New("Frame", {
        Name              = "Body",
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, 0, 1, -42),
        Position          = UDim2.new(0, 0, 0, 42),
        Parent            = self._main,
    })

    -- ── SIDEBAR (tabs) ──
    self._sidebar = New("Frame", {
        Name              = "Sidebar",
        BackgroundColor3  = theme.Sidebar,
        Size              = UDim2.new(0, 130, 1, 0),
        Parent            = self._body,
    })
    -- Redondear solo esquina inferior izquierda
    Corner(12, self._sidebar)
    New("Frame", {
        BackgroundColor3 = theme.Sidebar,
        Size  = UDim2.new(1, 0, 0, 12),
        Parent = self._sidebar,
    })
    New("Frame", {
        BackgroundColor3 = theme.Sidebar,
        Size  = UDim2.new(0, 12, 1, 0),
        Position = UDim2.new(1, -12, 0, 0),
        Parent = self._sidebar,
    })

    -- Separador vertical
    New("Frame", {
        BackgroundColor3 = theme.Border,
        Size  = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(0, 130, 0, 0),
        Parent = self._body,
    })

    -- Lista de tabs en el sidebar
    self._tabList = New("ScrollingFrame", {
        Name              = "TabList",
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, 0, 1, -10),
        Position          = UDim2.new(0, 0, 0, 10),
        CanvasSize        = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent            = self._sidebar,
    })
    local tabListLayout = ListLayout(4, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, self._tabList)
    Padding(6, 6, 6, 6, self._tabList)

    -- Auto-ajustar canvas
    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self._tabList.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 12)
    end)

    -- ── ÁREA DE CONTENIDO ──
    self._content = New("Frame", {
        Name              = "Content",
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -131, 1, 0),
        Position          = UDim2.new(0, 131, 0, 0),
        ClipsDescendants  = true,
        Parent            = self._body,
    })

    -- ── Hacer el header draggable ──
    MakeDraggable(self._root, self._header, function(pos)
        self._savedPosition = pos
    end)

    -- Animación de entrada
    self._root.BackgroundTransparency = 1
    self._main.BackgroundTransparency = 1
    task.spawn(function()
        task.wait(0.05)
        Tween(self._main, { BackgroundTransparency = 0 }, 0.3, Enum.EasingStyle.Quart)
        Tween(self._root, { BackgroundTransparency = 0 }, 0.3)
    end)
end

-- ───────────────────────────────────────────────
--  VENTANA: Minimizar / Restaurar / Ocultar
-- ───────────────────────────────────────────────
function Window:Minimize()
    if self._minimized then return end
    self._minimized = true
    Tween(self._root, { Size = UDim2.new(0, self._size.w, 0, 42) }, 0.3, Enum.EasingStyle.Quart)
    task.delay(0.1, function()
        self._body.Visible = false
    end)
end

function Window:Restore()
    if not self._minimized then return end
    self._minimized = false
    self._body.Visible = true
    Tween(self._root, { Size = UDim2.new(0, self._size.w, 0, self._size.h) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function Window:_hide()
    Tween(self._main, { BackgroundTransparency = 1 }, 0.25)
    Tween(self._root, {
        Size = UDim2.new(0, self._size.w * 0.9, 0, self._size.h * 0.9),
        Position = UDim2.new(
            self._root.Position.X.Scale,
            self._root.Position.X.Offset + self._size.w * 0.05,
            self._root.Position.Y.Scale,
            self._root.Position.Y.Offset + self._size.h * 0.05
        ),
    }, 0.25)
    task.delay(0.3, function()
        self._root.Visible = false
    end)
end

function Window:Show()
    self._root.Visible = true
    self._root.Size = UDim2.new(0, self._size.w * 0.9, 0, self._size.h * 0.9)
    Tween(self._root, { Size = UDim2.new(0, self._size.w, 0, self._size.h) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tween(self._main, { BackgroundTransparency = 0 }, 0.3)
end

-- ───────────────────────────────────────────────
--  VENTANA: Cambiar tema
-- ───────────────────────────────────────────────
function Window:SetTheme(themeName)
    self._themeName = themeName
    self._theme = Nova.Themes[themeName] or Nova.Themes.Dark
    -- Re-aplicar colores a los elementos principales
    local t = self._theme
    Tween(self._main,    { BackgroundColor3 = t.Background }, 0.3)
    Tween(self._header,  { BackgroundColor3 = t.Header }, 0.3)
    Tween(self._sidebar, { BackgroundColor3 = t.Sidebar }, 0.3)
    -- Re-colorear todos los elementos UI
    for _, elem in pairs(self._elements) do
        if elem._applyTheme then
            elem:_applyTheme(t)
        end
    end
end

-- ───────────────────────────────────────────────
--  VENTANA: Config
-- ───────────────────────────────────────────────
function Window:_collectConfig()
    local data = {}
    for key, elem in pairs(self._elements) do
        if elem._getValue then
            data[key] = elem:_getValue()
        end
    end
    -- Guardar posición
    data["__position"] = {
        x = self._root.Position.X.Offset,
        y = self._root.Position.Y.Offset,
    }
    return data
end

function Window:_applyConfig(data)
    for key, val in pairs(data) do
        if key ~= "__position" and self._elements[key] and self._elements[key]._setValue then
            pcall(function()
                self._elements[key]:_setValue(val)
            end)
        end
    end
    if data["__position"] then
        self._root.Position = UDim2.new(
            self._root.Position.X.Scale,
            data["__position"].x,
            self._root.Position.Y.Scale,
            data["__position"].y
        )
    end
end

function Window:SaveConfig()
    return self._lib:SaveConfig()
end

function Window:LoadConfig()
    return self._lib:LoadConfig()
end

function Window:GetLogger()
    return self._logger
end

-- ═══════════════════════════════════════════════════════════════
--  LOGGER INTEGRADO
-- ═══════════════════════════════════════════════════════════════
function Window:_buildLogger()
    local theme = self._theme

    -- Frame flotante del logger
    local lFrame = New("Frame", {
        Name              = "Logger",
        BackgroundColor3  = Color3.fromRGB(8, 10, 18),
        Size              = UDim2.new(0, 420, 0, 280),
        Position          = UDim2.new(0.5, -210, 0.5, 20),
        Visible           = false,
        ZIndex            = 10,
        Parent            = self._lib._rootGui,
    })
    Corner(10, lFrame)
    Stroke(theme.Border, 1, lFrame)

    self._loggerFrame = lFrame

    -- Header del logger
    local lHeader = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(12, 15, 24),
        Size             = UDim2.new(1, 0, 0, 32),
        ZIndex           = 11,
        Parent           = lFrame,
    })
    Corner(10, lHeader)
    New("Frame", {
        BackgroundColor3 = Color3.fromRGB(12, 15, 24),
        Size  = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        ZIndex = 11,
        Parent = lHeader,
    })

    New("TextLabel", {
        Text  = "◈ Nova Logger",
        Font  = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = theme.Accent,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
        Parent = lHeader,
    })

    -- Botones del logger header
    local function makeLogBtn(text, x, color)
        local b = New("TextButton", {
            Text = text, Font = Enum.Font.GothamBold,
            TextSize = 11, TextColor3 = color or theme.TextSecondary,
            BackgroundColor3 = Color3.fromRGB(20, 25, 38),
            Size = UDim2.new(0, 36, 0, 20),
            Position = UDim2.new(1, x, 0.5, -10),
            ZIndex = 12, Parent = lHeader,
        })
        Corner(4, b)
        return b
    end

    local clearBtn  = makeLogBtn("CLR", -118, Color3.fromRGB(220, 80, 80))
    local copyBtn   = makeLogBtn("CPY", -78,  theme.TextSecondary)
    local closeLogBtn = makeLogBtn("×", -38, Color3.fromRGB(180, 60, 60))

    -- Scroll de logs
    local lScroll = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -8, 1, -36),
        Position = UDim2.new(0, 4, 0, 34),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(40, 50, 75),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 11,
        Parent = lFrame,
    })
    local lLayout = ListLayout(2, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, lScroll)
    Padding(4, 4, 4, 4, lScroll)

    lLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        lScroll.CanvasSize = UDim2.new(0, 0, 0, lLayout.AbsoluteContentSize.Y + 8)
    end)

    -- Hacer draggable el logger
    MakeDraggable(lFrame, lHeader, nil)

    -- Cerrar logger
    closeLogBtn.MouseButton1Click:Connect(function()
        lFrame.Visible = false
    end)

    -- Crear objeto Logger
    local logger = {}
    logger._frame     = lFrame
    logger._scroll    = lScroll
    logger._layout    = lLayout
    logger._entries   = {}
    logger._autoScroll = true
    logger._logText   = ""

    -- Colores por nivel
    local levelColors = {
        info  = Color3.fromRGB(80, 160, 240),
        warn  = Color3.fromRGB(240, 190, 50),
        error = Color3.fromRGB(230, 70, 90),
        debug = Color3.fromRGB(160, 100, 240),
    }
    local levelIcons = {
        info  = "ℹ",
        warn  = "⚠",
        error = "✖",
        debug = "◉",
    }

    --- Añade una entrada al logger
    function logger:log(level, message)
        level = level or "info"
        local color  = levelColors[level] or levelColors.info
        local icon   = levelIcons[level] or "•"
        local ts     = GetTimestamp()
        local text   = string.format("[%s] %s %s", ts, icon, tostring(message))
        self._logText = self._logText .. text .. "\n"

        -- Frame de la entrada
        local entry = New("Frame", {
            BackgroundColor3 = Color3.fromRGB(14, 18, 28),
            Size  = UDim2.new(1, 0, 0, 20),
            ZIndex = 12,
            Parent = self._scroll,
        })
        Corner(4, entry)

        -- Indicador de color
        New("Frame", {
            BackgroundColor3 = color,
            Size  = UDim2.new(0, 3, 0, 12),
            Position = UDim2.new(0, 0, 0.5, -6),
            ZIndex = 13,
            Parent = entry,
        })
        Corner(2)

        -- Texto de la entrada
        local lbl = New("TextLabel", {
            Text  = text,
            Font  = Enum.Font.Code,
            TextSize = 10,
            TextColor3 = color,
            BackgroundTransparency = 1,
            Size  = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 13,
            Parent = entry,
        })

        table.insert(self._entries, entry)

        -- Auto-scroll
        if self._autoScroll then
            task.defer(function()
                self._scroll.CanvasPosition = Vector2.new(0, math.huge)
            end)
        end
    end

    function logger:info(msg)  self:log("info", msg)  end
    function logger:warn(msg)  self:log("warn", msg)  end
    function logger:error(msg) self:log("error", msg) end
    function logger:debug(msg) self:log("debug", msg) end

    --- Limpia el logger
    function logger:Clear()
        for _, e in ipairs(self._entries) do e:Destroy() end
        self._entries = {}
        self._logText = ""
    end

    --- Exportar (copia al clipboard si disponible)
    function logger:Export()
        local ok = pcall(function()
            setclipboard(self._logText)
        end)
        return self._logText
    end

    --- Abre/cierra el panel
    function logger:Open()
        self._frame.Visible = true
    end
    function logger:Close()
        self._frame.Visible = false
    end
    function logger:Toggle()
        self._frame.Visible = not self._frame.Visible
    end

    -- Botones del logger
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

--- Añade un tab a la ventana
--- @param name string  Nombre del tab
--- @param icon string? rbxassetid://... o texto/emoji
--- @return Tab
function Window:AddTab(name, icon)
    local theme = self._theme

    -- ── Botón del tab en el sidebar ──
    local tabBtn = New("TextButton", {
        Name             = "Tab_" .. name,
        Text             = "",
        BackgroundColor3 = theme.ElementActive,
        Size             = UDim2.new(1, -8, 0, 34),
        AutoButtonColor  = false,
        LayoutOrder      = #self._tabs + 1,
        Parent           = self._tabList,
    })
    Corner(8, tabBtn)

    -- Indicador izquierdo (barra de acento al activar)
    local indicator = New("Frame", {
        BackgroundColor3 = theme.Accent,
        Size  = UDim2.new(0, 3, 0, 18),
        Position = UDim2.new(0, 0, 0.5, -9),
        BackgroundTransparency = 1,
        Parent = tabBtn,
    })
    Corner(2, indicator)

    -- Ícono del tab
    local iconLabel
    if icon and icon ~= "" then
        local isAsset = icon:find("rbxassetid") or icon:find("https")
        if isAsset then
            iconLabel = New("ImageLabel", {
                Image = icon,
                BackgroundTransparency = 1,
                Size  = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 10, 0.5, -8),
                Parent = tabBtn,
            })
        else
            iconLabel = New("TextLabel", {
                Text  = icon,
                Font  = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = theme.TabInactive,
                BackgroundTransparency = 1,
                Size  = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Parent = tabBtn,
            })
        end
    end

    -- Nombre del tab
    local nameLabel = New("TextLabel", {
        Text  = name,
        Font  = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.TabInactive,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, (icon and 30 or 10), 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn,
    })

    -- ── Página del contenido del tab ──
    local tabPage = New("ScrollingFrame", {
        Name              = "Page_" .. name,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, 0, 1, 0),
        CanvasSize        = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.Scrollbar,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible           = false,
        Parent            = self._content,
    })
    local pageLayout = ListLayout(8, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, tabPage)
    Padding(10, 10, 10, 10, tabPage)

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabPage.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
    end)

    -- Crear objeto Tab
    local tab = {}
    tab._window    = self
    tab._name      = name
    tab._btn       = tabBtn
    tab._page      = tabPage
    tab._indicator = indicator
    tab._nameLabel = nameLabel
    tab._iconLabel = iconLabel
    tab._sections  = {}

    -- Selección del tab
    tabBtn.MouseButton1Click:Connect(function()
        self:_selectTab(tab)
    end)

    -- Hover
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

    -- Seleccionar si es el primero
    if #self._tabs == 1 then
        self:_selectTab(tab)
    end

    -- Método para añadir secciones
    setmetatable(tab, { __index = TabMethods })

    return tab
end

-- Seleccionar un tab
function Window:_selectTab(tab)
    -- Desactivar tab anterior
    if self._activeTab and self._activeTab ~= tab then
        local prev = self._activeTab
        Tween(prev._btn, { BackgroundColor3 = self._theme.ElementActive }, 0.2)
        Tween(prev._nameLabel, { TextColor3 = self._theme.TabInactive }, 0.2)
        if prev._iconLabel and prev._iconLabel:IsA("TextLabel") then
            Tween(prev._iconLabel, { TextColor3 = self._theme.TabInactive }, 0.2)
        end
        Tween(prev._indicator, { BackgroundTransparency = 1 }, 0.2)
        prev._page.Visible = false
    end

    self._activeTab = tab
    tab._page.Visible = true
    Tween(tab._btn, { BackgroundColor3 = self._theme.Element }, 0.2)
    Tween(tab._nameLabel, { TextColor3 = self._theme.TabActive }, 0.2)
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

--- Añade una sección (caja agrupadora) al tab
--- @param name string Nombre de la sección
--- @return Section
function TabMethods:AddSection(name)
    local theme = self._window._theme

    -- Frame de la sección
    local sFrame = New("Frame", {
        Name             = "Section_" .. name,
        BackgroundColor3 = theme.Section,
        Size             = UDim2.new(1, 0, 0, 30),  -- Se auto-ajusta
        AutomaticSize    = Enum.AutomaticSize.Y,
        LayoutOrder      = #self._sections + 1,
        Parent           = self._page,
    })
    Corner(8, sFrame)
    Stroke(theme.Border, 1, sFrame)

    -- Cabecera de la sección
    local sHeader = New("Frame", {
        Name             = "Header",
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 28),
        Parent           = sFrame,
    })

    -- Línea decorativa
    New("Frame", {
        BackgroundColor3 = theme.Accent,
        Size  = UDim2.new(0, 2, 0, 12),
        Position = UDim2.new(0, 10, 0.5, -6),
        Parent = sHeader,
    })

    New("TextLabel", {
        Text  = name,
        Font  = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = theme.Accent,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sHeader,
    })

    -- Separador bajo el header
    New("Frame", {
        BackgroundColor3 = theme.Border,
        Size  = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 0, 27),
        Parent = sFrame,
    })

    -- Contenedor de elementos
    local sContent = New("Frame", {
        Name             = "Content",
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 0),
        Position         = UDim2.new(0, 0, 0, 29),
        AutomaticSize    = Enum.AutomaticSize.Y,
        Parent           = sFrame,
    })
    local sLayout = ListLayout(4, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, sContent)
    Padding(4, 8, 6, 8, sContent)

    -- Crear objeto Section
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

-- Helper: crear tooltip
local function MakeTooltip(parent, text, lib)
    if not text or text == "" then return end
    local tip = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(15, 18, 28),
        Size  = UDim2.new(0, 200, 0, 28),
        Visible = false,
        ZIndex = 50,
        Parent = lib._rootGui,
    })
    Corner(6, tip)
    Stroke(Color3.fromRGB(50, 60, 90), 1, tip)
    New("TextLabel", {
        Text  = text,
        Font  = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(200, 210, 230),
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 51,
        Parent = tip,
    })

    parent.MouseEnter:Connect(function()
        local mp = UserInputService:GetMouseLocation()
        tip.Position = UDim2.new(0, mp.X + 12, 0, mp.Y + 12)
        tip.Visible = true
    end)
    parent.MouseMoved:Connect(function()
        local mp = UserInputService:GetMouseLocation()
        tip.Position = UDim2.new(0, mp.X + 12, 0, mp.Y + 12)
    end)
    parent.MouseLeave:Connect(function()
        tip.Visible = false
    end)
end

-- Helper: registrar elemento en la ventana para config
local function RegisterElement(section, key, elem)
    if key then
        section._window._elements[key] = elem
    end
    section._count = section._count + 1
    return section._count
end

-- ─────────────────────────────────────────────────
--  SEPARATOR
-- ─────────────────────────────────────────────────
function SectionMethods:AddSeparator()
    local theme = self._window._theme
    local sep = New("Frame", {
        BackgroundColor3 = theme.Border,
        Size  = UDim2.new(1, 0, 0, 1),
        LayoutOrder = RegisterElement(self, nil, nil),
        Parent = self._content,
    })
    return sep
end

-- ─────────────────────────────────────────────────
--  LABEL
-- ─────────────────────────────────────────────────
function SectionMethods:AddLabel(config)
    config = config or {}
    local theme = self._window._theme
    local frame = New("Frame", {
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, 0, 0, 20),
        LayoutOrder = RegisterElement(self, config.Key, nil),
        Parent = self._content,
    })
    local lbl = New("TextLabel", {
        Text  = config.Text or "Label",
        Font  = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.TextSecondary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
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
        Size  = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = RegisterElement(self, config.Key, nil),
        Parent = self._content,
    })
    Corner(6, frame)
    Padding(6, 8, 6, 8, frame)
    ListLayout(4, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, frame)

    New("TextLabel", {
        Text  = config.Title or "Título",
        Font  = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = frame,
    })
    local contentLbl = New("TextLabel", {
        Text  = config.Content or "",
        Font  = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = theme.TextSecondary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = 2,
        Parent = frame,
    })
    return {
        SetContent = function(self, t) contentLbl.Text = t end
    }
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
        Size  = UDim2.new(1, 0, 0, 32),
        LayoutOrder = RegisterElement(self, config.Key, nil),
        Parent = self._content,
    })

    local btn = New("TextButton", {
        Text              = config.Text or "Botón",
        Font              = Enum.Font.GothamBold,
        TextSize          = 12,
        TextColor3        = theme.TextPrimary,
        BackgroundColor3  = theme.Element,
        Size              = UDim2.new(1, 0, 1, 0),
        AutoButtonColor   = false,
        Parent            = frame,
    })
    Corner(7, btn)
    Stroke(theme.Border, 1, btn)

    -- Línea de acento inferior
    local accentLine = New("Frame", {
        BackgroundColor3 = theme.Accent,
        Size  = UDim2.new(0, 0, 0, 2),
        Position = UDim2.new(0.5, 0, 1, -2),
        AnchorPoint = Vector2.new(0.5, 0),
        Parent = btn,
    })
    Corner(1, accentLine)

    btn.MouseEnter:Connect(function()
        Tween(btn, { BackgroundColor3 = theme.ElementHover }, 0.15)
        Tween(accentLine, { Size = UDim2.new(0.8, 0, 0, 2) }, 0.2, Enum.EasingStyle.Back)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, { BackgroundColor3 = theme.Element }, 0.15)
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
        Size  = UDim2.new(1, 0, 0, 32),
        LayoutOrder = RegisterElement(self, config.Key, nil),
        Parent = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(0, 10, 0, 10, frame)

    New("TextLabel", {
        Text  = config.Text or "Toggle",
        Font  = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -50, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    -- Track del toggle
    local track = New("Frame", {
        BackgroundColor3 = value and theme.ToggleOn or theme.ToggleOff,
        Size  = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -36, 0.5, -9),
        Parent = frame,
    })
    Corner(9, track)

    -- Circulo del toggle
    local knob = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size  = UDim2.new(0, 14, 0, 14),
        Position = value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        Parent = track,
    })
    Corner(7, knob)

    -- Botón invisible sobre todo
    local hitbox = New("TextButton", {
        Text  = "",
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, 0, 1, 0),
        Parent = frame,
    })

    local toggleElem = {}
    toggleElem._value = value

    local function setToggle(v, silent)
        toggleElem._value = v
        Tween(track, { BackgroundColor3 = v and theme.ToggleOn or theme.ToggleOff }, 0.2)
        Tween(knob, { Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.2, Enum.EasingStyle.Back)
        if not silent and callback then pcall(callback, v) end
    end

    hitbox.MouseButton1Click:Connect(function()
        setToggle(not toggleElem._value)
    end)
    frame.MouseEnter:Connect(function()
        Tween(frame, { BackgroundColor3 = theme.ElementHover }, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        Tween(frame, { BackgroundColor3 = theme.Element }, 0.15)
    end)

    toggleElem._getValue = function(self) return self._value end
    toggleElem._setValue = function(self, v) setToggle(v, true) end
    toggleElem.Set       = function(self, v) setToggle(v) end
    toggleElem.Get       = function(self) return self._value end

    if config.Key then
        self._window._elements[config.Key] = toggleElem
    end

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
        Size  = UDim2.new(1, 0, 0, 48),
        LayoutOrder = RegisterElement(self, config.Key, nil),
        Parent = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(6, 10, 6, 10, frame)

    -- Texto y valor
    local topRow = New("Frame", {
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, 0, 0, 16),
        Parent = frame,
    })
    New("TextLabel", {
        Text  = config.Text or "Slider",
        Font  = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(0.7, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topRow,
    })
    local valLabel = New("TextLabel", {
        Text  = tostring(value),
        Font  = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = theme.Accent,
        BackgroundTransparency = 1,
        Size  = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new(0.7, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = topRow,
    })

    -- Track
    local track = New("Frame", {
        BackgroundColor3 = theme.SliderTrack,
        Size  = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -6),
        Parent = frame,
    })
    Corner(3, track)

    -- Fill
    local fill = New("Frame", {
        BackgroundColor3 = theme.SliderFill,
        Size  = UDim2.new(0, 0, 1, 0),
        Parent = track,
    })
    Corner(3, fill)

    -- Knob
    local knob = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size  = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, -7, 0.5, -7),
        Parent = track,
    })
    Corner(7, knob)
    Stroke(theme.Accent, 2, knob)

    local sliderElem = {}
    sliderElem._value = value

    local function formatVal(v)
        if decimals > 0 then
            return string.format("%." .. decimals .. "f", v)
        end
        return tostring(math.floor(v + 0.5))
    end

    local function setValue(v, silent)
        v = math.clamp(v, minVal, maxVal)
        if decimals == 0 then v = math.floor(v + 0.5) end
        sliderElem._value = v
        local pct = (v - minVal) / (maxVal - minVal)
        Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.1)
        Tween(knob, { Position = UDim2.new(pct, -7, 0.5, -7) }, 0.1)
        valLabel.Text = formatVal(v)
        if not silent and callback then pcall(callback, v) end
    end

    -- Inicializar posición
    setValue(value, true)

    -- Input del slider
    local dragging = false
    local function updateFromInput(input)
        local trackAbs = track.AbsolutePosition
        local trackSize = track.AbsoluteSize
        local relX = math.clamp(input.Position.X - trackAbs.X, 0, trackSize.X)
        local pct  = relX / trackSize.X
        local v    = minVal + (maxVal - minVal) * pct
        setValue(v)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromInput(input)
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
            updateFromInput(input)
        end
    end)

    frame.MouseEnter:Connect(function()
        Tween(frame, { BackgroundColor3 = theme.ElementHover }, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        Tween(frame, { BackgroundColor3 = theme.Element }, 0.15)
    end)

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
-- ─────────────────────────────────────────────────
function SectionMethods:AddDropdown(config)
    config = config or {}
    local theme    = self._window._theme
    local options  = config.Options  or {}
    local value    = config.Default  or (options[1] or "")
    local callback = config.Callback
    local isOpen   = false

    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size  = UDim2.new(1, 0, 0, 32),
        LayoutOrder = RegisterElement(self, config.Key, nil),
        Parent = self._content,
        ClipsDescendants = false,
        ZIndex = 5,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)

    local mainRow = New("Frame", {
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, 0, 0, 32),
        ZIndex = 6,
        Parent = frame,
    })
    Padding(0, 10, 0, 10, mainRow)

    New("TextLabel", {
        Text  = config.Text or "Dropdown",
        Font  = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(0.55, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7,
        Parent = mainRow,
    })

    local valueLabel = New("TextLabel", {
        Text  = tostring(value),
        Font  = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = theme.Accent,
        BackgroundTransparency = 1,
        Size  = UDim2.new(0.35, 0, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 7,
        Parent = mainRow,
    })

    local arrow = New("TextLabel", {
        Text  = "▾",
        Font  = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = theme.TextSecondary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -14, 0, 0),
        ZIndex = 7,
        Parent = mainRow,
    })

    -- Panel desplegable
    local dropdown = New("Frame", {
        BackgroundColor3 = theme.Section,
        Size  = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 2),
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 20,
        Parent = frame,
    })
    Corner(7, dropdown)
    Stroke(theme.Border, 1, dropdown)

    local dropList = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Scrollbar,
        ZIndex = 21,
        Parent = dropdown,
    })
    local dropLayout = ListLayout(2, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, dropList)
    Padding(2, 4, 2, 4, dropList)

    dropLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        dropList.CanvasSize = UDim2.new(0, 0, 0, dropLayout.AbsoluteContentSize.Y + 4)
    end)

    local dropElem = { _value = value }

    local function closeDropdown()
        isOpen = false
        Tween(dropdown, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quart)
        Tween(arrow, { Rotation = 0 }, 0.2)
        task.delay(0.2, function()
            dropdown.Visible = false
        end)
        Tween(frame, { ZIndex = 5 }, 0.01)
    end

    local function openDropdown()
        isOpen = true
        local h = math.min(#options * 26 + 6, 130)
        dropdown.Visible = true
        dropdown.Size = UDim2.new(1, 0, 0, 0)
        frame.ZIndex = 30
        Tween(dropdown, { Size = UDim2.new(1, 0, 0, h) }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(arrow, { Rotation = 180 }, 0.2)
    end

    -- Construir opciones
    local function buildOptions()
        for _, child in ipairs(dropList:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        for i, opt in ipairs(options) do
            local optBtn = New("TextButton", {
                Text = tostring(opt),
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = (tostring(opt) == tostring(dropElem._value)) and theme.Accent or theme.TextPrimary,
                BackgroundColor3 = (tostring(opt) == tostring(dropElem._value)) and theme.ElementActive or Color3.fromRGB(0,0,0),
                BackgroundTransparency = (tostring(opt) == tostring(dropElem._value)) and 0 or 1,
                Size  = UDim2.new(1, 0, 0, 24),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = i,
                ZIndex = 22,
                Parent = dropList,
            })
            Corner(5, optBtn)
            Padding(0, 4, 0, 8, optBtn)

            optBtn.MouseEnter:Connect(function()
                if tostring(opt) ~= tostring(dropElem._value) then
                    Tween(optBtn, { BackgroundTransparency = 0, BackgroundColor3 = theme.ElementHover }, 0.1)
                end
            end)
            optBtn.MouseLeave:Connect(function()
                if tostring(opt) ~= tostring(dropElem._value) then
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
        Text = "", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        ZIndex = 8,
        Parent = frame,
    })
    hitbox.MouseButton1Click:Connect(function()
        if isOpen then closeDropdown() else openDropdown() end
    end)

    frame.MouseEnter:Connect(function()
        Tween(frame, { BackgroundColor3 = theme.ElementHover }, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        Tween(frame, { BackgroundColor3 = theme.Element }, 0.15)
    end)

    dropElem._getValue = function(self) return self._value end
    dropElem._setValue = function(self, v)
        self._value = v; valueLabel.Text = tostring(v); buildOptions()
    end
    dropElem.Set     = dropElem._setValue
    dropElem.Get     = function(self) return self._value end
    dropElem.SetOptions = function(self, opts)
        options = opts
        buildOptions()
    end

    if config.Key then self._window._elements[config.Key] = dropElem end
    MakeTooltip(frame, config.Tooltip, self._window._lib)
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
        Size  = UDim2.new(1, 0, 0, 48),
        LayoutOrder = RegisterElement(self, config.Key, nil),
        Parent = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(4, 10, 4, 10, frame)
    ListLayout(4, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, frame)

    New("TextLabel", {
        Text  = config.Text or "Textbox",
        Font  = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = theme.TextSecondary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, 0, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = frame,
    })

    local inputFrame = New("Frame", {
        BackgroundColor3 = theme.Background,
        Size  = UDim2.new(1, 0, 0, 22),
        LayoutOrder = 2,
        Parent = frame,
    })
    Corner(5, inputFrame)
    Stroke(theme.Border, 1, inputFrame)

    local inputBox = New("TextBox", {
        Text  = value,
        PlaceholderText = config.Placeholder or "Escribe aquí...",
        PlaceholderColor3 = theme.TextDisabled,
        Font  = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputFrame,
    })

    local textElem = { _value = value }

    inputBox.Focused:Connect(function()
        Tween(inputFrame, { BackgroundColor3 = theme.ElementHover }, 0.15)
        Stroke(theme.Accent, 1, inputFrame)
    end)
    inputBox.FocusLost:Connect(function(enterPressed)
        Tween(inputFrame, { BackgroundColor3 = theme.Background }, 0.15)
        Stroke(theme.Border, 1, inputFrame)
        textElem._value = inputBox.Text
        if callback then pcall(callback, inputBox.Text, enterPressed) end
    end)
    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        textElem._value = inputBox.Text
    end)

    textElem._getValue = function(self) return self._value end
    textElem._setValue = function(self, v) inputBox.Text = v; self._value = v end
    textElem.Set     = textElem._setValue
    textElem.Get     = function(self) return self._value end

    if config.Key then self._window._elements[config.Key] = textElem end
    MakeTooltip(frame, config.Tooltip, self._window._lib)
    return textElem
end

-- ─────────────────────────────────────────────────
--  COLOR PICKER
-- ─────────────────────────────────────────────────
function SectionMethods:AddColorPicker(config)
    config = config or {}
    local theme    = self._window._theme
    local value    = config.Default or Color3.fromRGB(255, 100, 100)
    local callback = config.Callback
    local isOpen   = false

    -- Convertir Color3 a HSV
    local function toHSV(c)
        local r, g, b = c.R, c.G, c.B
        local max = math.max(r, g, b)
        local min = math.min(r, g, b)
        local delta = max - min
        local h, s, v = 0, 0, max
        if max ~= 0 then s = delta / max end
        if delta ~= 0 then
            if max == r then h = (g - b) / delta % 6
            elseif max == g then h = (b - r) / delta + 2
            else h = (r - g) / delta + 4
            end
            h = h / 6
        end
        return h, s, v
    end

    local h, s, v = toHSV(value)

    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size  = UDim2.new(1, 0, 0, 32),
        LayoutOrder = RegisterElement(self, config.Key, nil),
        Parent = self._content,
        ClipsDescendants = false,
        ZIndex = 5,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(0, 10, 0, 10, frame)

    New("TextLabel", {
        Text  = config.Text or "Color Picker",
        Font  = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -50, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = frame,
    })

    -- Muestra del color actual
    local preview = New("Frame", {
        BackgroundColor3 = value,
        Size  = UDim2.new(0, 24, 0, 18),
        Position = UDim2.new(1, -26, 0.5, -9),
        ZIndex = 6,
        Parent = frame,
    })
    Corner(5, preview)
    Stroke(theme.Border, 1, preview)

    -- Panel del picker
    local pickerPanel = New("Frame", {
        BackgroundColor3 = theme.Section,
        Size  = UDim2.new(0, 200, 0, 180),
        Position = UDim2.new(1, -200, 1, 4),
        Visible = false,
        ZIndex = 30,
        Parent = frame,
    })
    Corner(10, pickerPanel)
    Stroke(theme.Border, 1, pickerPanel)
    Padding(8, 8, 8, 8, pickerPanel)

    -- Gradiente SV (cuadrado de saturación/valor)
    local svBox = New("Frame", {
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Size  = UDim2.new(1, 0, 0, 120),
        ZIndex = 31,
        Parent = pickerPanel,
    })
    Corner(6, svBox)

    -- Overlay blanco horizontal (saturación)
    local svWhite = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size  = UDim2.new(1, 0, 1, 0),
        ZIndex = 32,
        Parent = svBox,
    })
    Corner(6, svWhite)
    local svWhiteGrad = Instance.new("UIGradient")
    svWhiteGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    })
    svWhiteGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    svWhiteGrad.Parent = svWhite

    -- Overlay negro vertical (valor)
    local svBlack = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size  = UDim2.new(1, 0, 1, 0),
        ZIndex = 33,
        Parent = svBox,
    })
    Corner(6, svBlack)
    local svBlackGrad = Instance.new("UIGradient")
    svBlackGrad.Rotation = 90
    svBlackGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    })
    svBlackGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    svBlackGrad.Parent = svBlack

    -- Cursor SV
    local svCursor = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size  = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(s, 0, 1-v, 0),
        ZIndex = 34,
        Parent = svBox,
    })
    Corner(5, svCursor)
    Stroke(Color3.fromRGB(255,255,255), 2, svCursor)

    -- Slider de hue
    local hueBar = New("Frame", {
        Size  = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 0, 128),
        ZIndex = 31,
        Parent = pickerPanel,
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
        Size  = UDim2.new(0, 8, 1, 4),
        Position = UDim2.new(h, -4, 0, -2),
        AnchorPoint = Vector2.new(0, 0),
        ZIndex = 32,
        Parent = hueBar,
    })
    Corner(3, hueCursor)
    Stroke(Color3.fromRGB(200,200,200), 1, hueCursor)

    -- Hex input
    local hexFrame = New("Frame", {
        BackgroundColor3 = theme.Background,
        Size  = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 148),
        ZIndex = 31,
        Parent = pickerPanel,
    })
    Corner(5, hexFrame)
    Stroke(theme.Border, 1, hexFrame)
    local hexInput = New("TextBox", {
        Text  = ColorToHex(value),
        Font  = Enum.Font.Code,
        TextSize = 10,
        TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        ClearTextOnFocus = false,
        ZIndex = 32,
        Parent = hexFrame,
    })

    local colorElem = { _value = value }

    local function updateColor(silent)
        local newColor = Color3.fromHSV(h, s, v)
        colorElem._value = newColor
        preview.BackgroundColor3 = newColor
        svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svCursor.Position = UDim2.new(s, 0, 1-v, 0)
        hueCursor.Position = UDim2.new(h, -4, 0, -2)
        hexInput.Text = ColorToHex(newColor)
        if not silent and callback then pcall(callback, newColor) end
    end
    updateColor(true)

    -- Dragging SV
    local draggingSV = false
    svBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSV = true
            local pos = svBox.AbsolutePosition
            local sz  = svBox.AbsoluteSize
            s = math.clamp((input.Position.X - pos.X) / sz.X, 0, 1)
            v = 1 - math.clamp((input.Position.Y - pos.Y) / sz.Y, 0, 1)
            updateColor()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSV and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = svBox.AbsolutePosition
            local sz  = svBox.AbsoluteSize
            s = math.clamp((input.Position.X - pos.X) / sz.X, 0, 1)
            v = 1 - math.clamp((input.Position.Y - pos.Y) / sz.Y, 0, 1)
            updateColor()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSV = false
        end
    end)

    -- Dragging Hue
    local draggingHue = false
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
            local pos = hueBar.AbsolutePosition
            local sz  = hueBar.AbsoluteSize
            h = math.clamp((input.Position.X - pos.X) / sz.X, 0, 1)
            updateColor()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = hueBar.AbsolutePosition
            local sz  = hueBar.AbsoluteSize
            h = math.clamp((input.Position.X - pos.X) / sz.X, 0, 1)
            updateColor()
        end
    end)

    -- Hex input
    hexInput.FocusLost:Connect(function()
        local ok, c = pcall(function() return HexToColor(hexInput.Text) end)
        if ok then
            colorElem._value = c
            h, s, v = toHSV(c)
            updateColor()
        end
    end)

    -- Toggle picker
    local hitbox = New("TextButton", {
        Text = "", BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 0, 18),
        Position = UDim2.new(1, -26, 0.5, -9),
        ZIndex = 7,
        Parent = frame,
    })
    hitbox.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        pickerPanel.Visible = isOpen
    end)

    -- Cerrar al hacer click fuera (simplificado)
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isOpen and not pickerPanel:IsAncestorOf(Mouse.Target or game) then
                isOpen = false
                pickerPanel.Visible = false
            end
        end
    end)

    colorElem._getValue = function(self) return self._value end
    colorElem._setValue = function(self, c)
        colorElem._value = c
        h, s, v = toHSV(c)
        updateColor(true)
    end
    colorElem.Set     = function(self, c) colorElem._value = c; h,s,v = toHSV(c); updateColor() end
    colorElem.Get     = function(self) return self._value end

    if config.Key then self._window._elements[config.Key] = colorElem end
    MakeTooltip(frame, config.Tooltip, self._window._lib)
    return colorElem
end

-- ─────────────────────────────────────────────────
--  KEYBIND
-- ─────────────────────────────────────────────────
function SectionMethods:AddKeybind(config)
    config = config or {}
    local theme    = self._window._theme
    local value    = config.Default  -- Enum.KeyCode o nil
    local callback = config.Callback
    local anyKey   = config.AnyKey or false
    local listening = false

    local frame = New("Frame", {
        BackgroundColor3 = theme.Element,
        Size  = UDim2.new(1, 0, 0, 32),
        LayoutOrder = RegisterElement(self, config.Key, nil),
        Parent = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(0, 10, 0, 10, frame)

    New("TextLabel", {
        Text  = config.Text or "Keybind",
        Font  = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size  = UDim2.new(0.6, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local keyBtn = New("TextButton", {
        Text  = value and value.Name or "Ninguna",
        Font  = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = theme.Accent,
        BackgroundColor3 = theme.ElementActive,
        Size  = UDim2.new(0, 80, 0, 20),
        Position = UDim2.new(1, -82, 0.5, -10),
        AutoButtonColor = false,
        Parent = frame,
    })
    Corner(5, keyBtn)
    Stroke(theme.BorderAccent, 1, keyBtn)

    local kbElem = { _value = value }

    local function setKey(k, silent)
        kbElem._value = k
        keyBtn.Text = k and k.Name or "Ninguna"
        keyBtn.TextColor3 = k and theme.Accent or theme.TextSecondary
        if not silent and callback then pcall(callback, k) end
    end

    -- Registrar en keybinds globales automáticamente si tiene callback
    local function updateGlobalKB()
        if config.Key and kbElem._value then
            self._window._lib:RegisterKeybind(
                "elem_" .. config.Key,
                kbElem._value,
                function() if callback then pcall(callback, kbElem._value) end end
            )
        end
    end

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = theme.NotifyWarning

        self._window._lib:GetPressedKey(function(keyCode)
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
        if config.Key then
            self._window._lib:UnregisterKeybind("elem_" .. config.Key)
        end
    end)

    frame.MouseEnter:Connect(function()
        Tween(frame, { BackgroundColor3 = theme.ElementHover }, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        Tween(frame, { BackgroundColor3 = theme.Element }, 0.15)
    end)

    kbElem._getValue = function(self) return self._value and self._value.Name or nil end
    kbElem._setValue = function(self, v)
        if type(v) == "string" then
            local ok, k = pcall(function() return Enum.KeyCode[v] end)
            if ok then setKey(k, true) end
        else
            setKey(v, true)
        end
    end
    kbElem.Set     = function(self, k) setKey(k) end
    kbElem.Get     = function(self) return self._value end

    if value then updateGlobalKB() end
    if config.Key then self._window._elements[config.Key] = kbElem end
    MakeTooltip(frame, config.Tooltip, self._window._lib)
    return kbElem
end

-- ─────────────────────────────────────────────────
--  LISTBOX
-- ─────────────────────────────────────────────────
function SectionMethods:AddListbox(config)
    config = config or {}
    local theme    = self._window._theme
    local options  = config.Options   or {}
    local multi    = config.Multi     or false
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
        Size  = UDim2.new(1, 0, 0, 90),
        LayoutOrder = RegisterElement(self, config.Key, nil),
        Parent = self._content,
    })
    Corner(7, frame)
    Stroke(theme.Border, 1, frame)
    Padding(4, 6, 4, 6, frame)
    ListLayout(4, Enum.FillDirection.Vertical, Enum.SortOrder.LayoutOrder, frame)

    New("TextLabel", {
        Text  = config.Text or "Listbox",
        Font  = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = theme.Accent,
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, 0, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = frame,
    })

    local scroll = New("ScrollingFrame", {
        BackgroundColor3 = theme.Background,
        Size  = UDim2.new(1, 0, 1, -18),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Scrollbar,
        LayoutOrder = 2,
        Parent = frame,
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
            local isSelected = selected[tostring(opt)] == true
            local row = New("TextButton", {
                Text  = tostring(opt),
                Font  = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = isSelected and theme.Accent or theme.TextPrimary,
                BackgroundColor3 = isSelected and theme.ElementActive or Color3.fromRGB(0,0,0),
                BackgroundTransparency = isSelected and 0 or 1,
                Size  = UDim2.new(1, 0, 0, 22),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = i,
                Parent = scroll,
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
                    -- single select: deselect all
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

    listElem._getValue = function(self) return getSelected() end
    listElem._setValue = function(self, vals)
        selected = {}
        if type(vals) == "table" then
            for _, v in ipairs(vals) do selected[tostring(v)] = true end
        else
            selected[tostring(vals)] = true
        end
        buildList()
    end
    listElem.Get         = listElem._getValue
    listElem.Set         = listElem._setValue
    listElem.SetOptions  = function(self, opts) options = opts; buildList() end

    if config.Key then self._window._elements[config.Key] = listElem end
    MakeTooltip(frame, config.Tooltip, self._window._lib)
    return listElem
end

-- ═══════════════════════════════════════════════════════════════
--  RETORNAR LA LIBRERÍA
-- ═══════════════════════════════════════════════════════════════
return Nova
