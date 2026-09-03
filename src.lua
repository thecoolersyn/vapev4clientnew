--[[
    Impulse UI Framework v1.0
    A complete, modular, data-driven Roblox UI framework.
    
    Features:
    - Draggable desktop-style window
    - Module registration system with categories
    - Data-driven settings panel (Toggle, Slider, Dropdown, etc.)
    - Config manager with JSON serialization
    - Notification system
    - Lucide-style icons
    - Dark theme
    - Animations via TweenService
]]

local Impulse = {}
Impulse.__index = Impulse

-- Default instance (singleton)
local _defaultInstance = nil

local function _getInstance()
    return _defaultInstance
end

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- THEME
--------------------------------------------------------------------------------
-- Vape V4 Theme
local Theme = {
    -- Colors
    Background = Color3.fromRGB(10, 10, 12),
    Surface = Color3.fromRGB(18, 18, 22),
    SurfaceLight = Color3.fromRGB(24, 24, 28),
    SurfaceHover = Color3.fromRGB(30, 30, 38),
    SurfaceActive = Color3.fromRGB(36, 36, 44),
    
    Accent = Color3.fromRGB(100, 220, 160),
    AccentDim = Color3.fromRGB(80, 180, 130),
    AccentHover = Color3.fromRGB(120, 240, 180),
    
    Text = Color3.fromRGB(235, 235, 240),
    TextSecondary = Color3.fromRGB(165, 165, 175),
    TextMuted = Color3.fromRGB(100, 100, 115),
    
    Border = Color3.fromRGB(30, 30, 38),
    BorderLight = Color3.fromRGB(45, 45, 58),
    
    ToggleOff = Color3.fromRGB(45, 45, 58),
    ToggleOn = Color3.fromRGB(100, 220, 160),
    
    SliderTrack = Color3.fromRGB(35, 35, 45),
    SliderFill = Color3.fromRGB(100, 220, 160),
    SliderHandle = Color3.fromRGB(235, 235, 240),
    
    Error = Color3.fromRGB(255, 100, 100),
    Success = Color3.fromRGB(100, 220, 160),
    Warning = Color3.fromRGB(255, 200, 100),
    
    -- Dimensions
    WindowWidth = 1050,
    WindowHeight = 620,
    TopBarHeight = 44,
    SidebarWidth = 180,
    SettingsPanelWidth = 300,
    
    -- Fonts
    Font = Enum.Font.Gotham,
    FontMedium = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamMedium,
    FontMono = Enum.Font.Code,
    
    -- Animation
    TweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    FastTween = TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    SlowTween = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}

--------------------------------------------------------------------------------
-- ICONS (Real Lucide icons with self-contained fallback)
--------------------------------------------------------------------------------
local Icons = {}
local _airflowMerged = false

-- Built-in Lucide icon asset IDs (from lucide-icons.lua)
local LucideAssets = {
    ["lucide-settings"] = "rbxassetid://10734950309",
    ["lucide-minus"] = "rbxassetid://10734896206",
    ["lucide-x"] = "rbxassetid://10747384394",
    ["lucide-arrow-left"] = "rbxassetid://10709768114",
    ["lucide-search"] = "rbxassetid://10734943674",
    ["lucide-chevron-right"] = "rbxassetid://10709791437",
    ["lucide-chevron-down"] = "rbxassetid://10709790948",
    ["lucide-more-vertical"] = "rbxassetid://10734897387",
    ["lucide-star"] = "rbxassetid://10734966248",
    ["lucide-swords"] = "rbxassetid://10734975692",
    ["lucide-eye"] = "rbxassetid://10723346959",
    ["lucide-target"] = "rbxassetid://10734977012",
    ["lucide-box"] = "rbxassetid://10709782497",
    ["lucide-keyboard"] = "rbxassetid://10723416765",
    ["lucide-palette"] = "rbxassetid://10734910430",
    ["lucide-zap"] = "rbxassetid://10709752254",
    ["lucide-shield"] = "rbxassetid://10734951847",
    ["lucide-hash"] = "rbxassetid://10723405975",
    ["lucide-circle"] = "rbxassetid://10709798174",
    ["lucide-sword"] = "rbxassetid://10734975486",
    ["lucide-users"] = "rbxassetid://10747373426",
    ["lucide-user"] = "rbxassetid://10747373176",
    ["lucide-play"] = "rbxassetid://10734923549",
    ["lucide-pause"] = "rbxassetid://10734919336",
    ["lucide-check"] = "rbxassetid://10709790644",
    ["lucide-home"] = "rbxassetid://10723407389",
    ["lucide-menu"] = "rbxassetid://10734887784",
}

-- Merge with Airflow.Lucide if available (loaded from lucide-icons.lua)
local function mergeAirflowIcons()
    local airflow = nil
    if type(getgenv) == "function" then
        local ok, env = pcall(getgenv)
        if ok and type(env) == "table" then
            airflow = env.Airflow
        end
    end
    if not airflow and _G then
        airflow = _G.Airflow
    end
    if airflow and type(airflow) == "table" and airflow.Lucide then
        for k, v in pairs(airflow.Lucide) do
            LucideAssets[k] = v
        end
    end
end

local function getLucideAsset(name)
    if not _airflowMerged then
        mergeAirflowIcons()
        _airflowMerged = true
    end
    return LucideAssets[name]
end

local function createIconFrame(size)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, size, 0, size)
    f.BackgroundTransparency = 1
    f.ClipsDescendants = true
    return f
end

function Icons.Icon(name, size, color)
    size = size or 16
    color = color or Theme.Text
    local f = createIconFrame(size)
    
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.ImageColor3 = color
    img.Parent = f
    
    local iconMap = {
        Settings = "lucide-settings",
        Minus = "lucide-minus",
        X = "lucide-x",
        ArrowLeft = "lucide-arrow-left",
        Search = "lucide-search",
        ChevronRight = "lucide-chevron-right",
        ChevronDown = "lucide-chevron-down",
        MoreVertical = "lucide-more-vertical",
        Star = "lucide-star",
        StarFilled = "lucide-star",
        Swords = "lucide-swords",
        Eye = "lucide-eye",
        Target = "lucide-target",
        Box = "lucide-box",
        Keyboard = "lucide-keyboard",
        Palette = "lucide-palette",
        Zap = "lucide-zap",
        Shield = "lucide-shield",
        Hash = "lucide-hash",
        Circle = "lucide-circle",
        Sword = "lucide-sword",
        Users = "lucide-users",
        User = "lucide-user",
        Play = "lucide-play",
        Pause = "lucide-pause",
        Check = "lucide-check",
        Home = "lucide-home",
        Menu = "lucide-menu",
    }
    
    local lucideName = iconMap[name] or "lucide-circle"
    local assetId = getLucideAsset(lucideName)
    if assetId then
        img.Image = assetId
    end
    
    return f
end

--------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------------------------
local function deepCopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = deepCopy(v)
    end
    return copy
end

local function mergeDefaults(saved, defaults)
    local result = deepCopy(defaults)
    if type(saved) == "table" then
        for k, v in pairs(saved) do
            if type(v) == "table" and type(result[k]) == "table" then
                result[k] = mergeDefaults(v, result[k])
            else
                result[k] = v
            end
        end
    end
    return result
end

local function safeCall(fn, ...)
    if type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not err then
            return ok
        end
    end
    return false
end

--------------------------------------------------------------------------------
-- FILE SYSTEM ADAPTER
--------------------------------------------------------------------------------
local FileSystemAdapter = {}
FileSystemAdapter.__index = FileSystemAdapter

function FileSystemAdapter:Exists(path)
    if isfolder and isfile then
        return isfolder(path) or isfile(path)
    end
    return false
end

function FileSystemAdapter:Read(path)
    if isfile(path) and readfile then
        local ok, result = pcall(readfile, path)
        if ok then return result end
    end
    return nil
end

function FileSystemAdapter:Write(path, data)
    if makefolder and writefile then
        local dir = path:match("(.+)/[^/]+$") or path:match("(.+)\\[^/\\]+$")
        if dir and not isfolder(dir) then
            pcall(makefolder, dir)
        end
        local ok, err = pcall(writefile, path, data)
        return ok
    end
    return false
end

function FileSystemAdapter:Delete(path)
    if delfile then
        pcall(delfile, path)
    end
end

function FileSystemAdapter:List(directory)
    if listfiles then
        local ok, files = pcall(listfiles, directory)
        if ok and files then
            local result = {}
            for _, f in ipairs(files) do
                local name = f:match("[^/\\]+$") or f
                if name:match("%.json$") then
                    result[#result + 1] = name:gsub("%.json$", "")
                end
            end
            return result
        end
    end
    return {}
end

--------------------------------------------------------------------------------
-- CONFIG SERVICE
--------------------------------------------------------------------------------
local ConfigService = {}
ConfigService.__index = ConfigService

function ConfigService.new()
    local self = setmetatable({}, ConfigService)
    self.basePath = "Impulse/Config"
    self.currentConfig = nil
    self.fs = FileSystemAdapter
    return self
end

function ConfigService:_path(name)
    return self.basePath .. "/" .. name .. ".json"
end

function ConfigService:Exists(name)
    return self.fs:Exists(self:_path(name))
end

function ConfigService:Create(name)
    if not name or name == "" then return false end
    if self:Exists(name) then return false end
    return self:Save(name)
end

function ConfigService:Save(name, data)
    if not name or name == "" then return false end
    local saveData = data or self:_collectAll()
    local json = HttpService:JSONEncode(saveData)
    return self.fs:Write(self:_path(name), json)
end

function ConfigService:Load(name)
    if not name or name == "" then return nil end
    local content = self.fs:Read(self:_path(name))
    if not content then return nil end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, content)
    if ok and type(data) == "table" then
        self.currentConfig = name
        return data
    end
    return nil
end

function ConfigService:Delete(name)
    self.fs:Delete(self:_path(name))
    if self.currentConfig == name then
        self.currentConfig = nil
    end
end

function ConfigService:Rename(oldName, newName)
    if not self:Exists(oldName) then return false end
    local data = self:Load(oldName)
    if data then
        self:Save(newName, data)
        self:Delete(oldName)
        return true
    end
    return false
end

function ConfigService:List()
    return self.fs:List(self.basePath)
end

function ConfigService:GetCurrent()
    return self.currentConfig
end

function ConfigService:_collectAll()
    local data = { Modules = {}, Favorites = {} }
    local registry = _getInstance()._registry
    if registry then
        for _, mod in pairs(registry.modules) do
            local modData = { Enabled = mod.Enabled, Settings = {} }
            for _, setting in pairs(mod.Settings) do
                modData.Settings[setting.Name] = setting.Value
            end
            data.Modules[mod.Name] = modData
            if mod.Favorite then
                data.Favorites[mod.Name] = true
            end
        end
    end
    return data
end

function ConfigService:Apply(data)
    if not data or type(data) ~= "table" then return false end
    local registry = _getInstance()._registry
    if not registry then return false end
    
    -- Apply module states
    if data.Modules then
        for name, modData in pairs(data.Modules) do
            local mod = registry.modules[name]
            if mod then
                if type(modData.Enabled) == "boolean" then
                    mod:SetEnabled(modData.Enabled)
                end
                if type(modData.Settings) == "table" then
                    for sName, sVal in pairs(modData.Settings) do
                        mod:Set(sName, sVal)
                    end
                end
            end
        end
    end
    
    -- Apply favorites
    if data.Favorites then
        for name, fav in pairs(data.Favorites) do
            local registry = _getInstance()._registry
            local mod = registry.modules[name]
            if mod then
                mod:SetFavorite(fav == true)
            end
        end
    end
    
    return true
end

--------------------------------------------------------------------------------
-- NOTIFICATION SERVICE
--------------------------------------------------------------------------------
local NotificationService = {}
NotificationService.__index = NotificationService

function NotificationService.new()
    local self = setmetatable({}, NotificationService)
    self.notifications = {}
    self.container = nil
    return self
end

function NotificationService:Init(parent)
    local screen = Instance.new("ScreenGui")
    screen.Name = "ImpulseNotifications"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = parent or PlayerGui
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 280, 1, -40)
    container.Position = UDim2.new(1, -290, 0, 20)
    container.BackgroundTransparency = 1
    container.Parent = screen
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container
    
    self.container = container
    self.screen = screen
end

function NotificationService:Notify(title, message, notifType)
    if not self.container then self:Init() end
    
    notifType = notifType or "info"
    local color = Theme.Accent
    if notifType == "error" then color = Theme.Error
    elseif notifType == "warning" then color = Theme.Warning
    elseif notifType == "success" then color = Theme.Success end
    
    local card = Instance.new("Frame")
    card.Name = "Notif"
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Theme.Surface
    card.BorderSizePixel = 0
    card.BackgroundTransparency = 1
    card.LayoutOrder = #self.notifications + 1
    card.Parent = self.container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Transparency = 0.5
    stroke.Thickness = 1
    stroke.Parent = card
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, -16)
    accent.Position = UDim2.new(0, 6, 0, 8)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    accent.Parent = card
    
    local ac = Instance.new("UICorner")
    ac.CornerRadius = UDim.new(0, 2)
    ac.Parent = accent
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -24, 0, 18)
    titleLabel.Position = UDim2.new(0, 16, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 13
    titleLabel.Font = Theme.FontMedium
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -24, 0, 16)
    msgLabel.Position = UDim2.new(0, 16, 0, 30)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message or ""
    msgLabel.TextColor3 = Theme.TextSecondary
    msgLabel.TextSize = 11
    msgLabel.Font = Theme.Font
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = card
    
    -- Animate in
    card.Position = UDim2.new(1, 300, 0, 0)
    local tweenIn = TweenService:Create(card, Theme.FastTween, {
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0)
    })
    tweenIn:Play()
    
    self.notifications[#self.notifications + 1] = card
    
    -- Auto remove
    task.delay(3.5, function()
        if card and card.Parent then
            local tweenOut = TweenService:Create(card, Theme.FastTween, {
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 300, 0, 0)
            })
            tweenOut:Play()
            tweenOut.Completed:Wait()
            if card then card:Destroy() end
        end
        for i, n in ipairs(self.notifications) do
            if n == card then
                table.remove(self.notifications, i)
                break
            end
        end
    end)
end

--------------------------------------------------------------------------------
-- UI HELPER FUNCTIONS
--------------------------------------------------------------------------------
local function createCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function createStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function createPadding(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

local function createListLayout(parent, padding, direction)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, padding or 4)
    if direction then l.FillDirection = direction end
    l.Parent = parent
    return l
end

local function createText(parent, text, size, color, font, xAlign)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Text = text or ""
    t.TextColor3 = color or Theme.Text
    t.TextSize = size or 12
    t.Font = font or Theme.Font
    t.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.Parent = parent
    return t
end

-- Anchors a popup frame to an anchor GuiObject and keeps it attached for as
-- long as both are alive. The popup is positioned relative to its parent
-- using the anchor's current absolute position (never a stale screen-space
-- offset), and the position is refreshed every frame so the popup follows
-- the window when it is dragged, scrolled, or repositioned. Cleanup is
-- automatic: when either the popup or the anchor is destroyed, the tracking
-- connection is disconnected (and a dangling popup is destroyed with its
-- anchor so no orphaned popups are left behind).
local function anchorPopup(popup, anchor, offsetX, offsetY)
    local conn = nil

    local function updatePosition()
        if not popup.Parent or not anchor.Parent then
            return false
        end
        local host = popup.Parent
        local anchorPos = anchor.AbsolutePosition
        local hostPos = host.AbsolutePosition
        popup.Position = UDim2.new(
            0, anchorPos.X - hostPos.X + (offsetX or 0),
            0, anchorPos.Y - hostPos.Y + (offsetY or 0)
        )
        return true
    end

    updatePosition()

    conn = RunService.RenderStepped:Connect(function()
        if not updatePosition() then
            if conn then
                conn:Disconnect()
                conn = nil
            end
        end
    end)

    popup.Destroying:Connect(function()
        if conn then
            conn:Disconnect()
            conn = nil
        end
    end)

    anchor.Destroying:Connect(function()
        if popup and popup.Parent then
            popup:Destroy()
        end
    end)

    return popup
end

--------------------------------------------------------------------------------
-- SETTING CONTROLS
--------------------------------------------------------------------------------
local Controls = {}

function Controls.CreateToggle(parent, name, default, callback)
    local container = Instance.new("Frame")
    container.Name = "Toggle_" .. name
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = createText(container, name, 11, Theme.TextSecondary, Theme.Font)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    
    -- Toggle switch
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 32, 0, 18)
    switch.Position = UDim2.new(1, -32, 0.5, -9)
    switch.BackgroundColor3 = Theme.ToggleOff
    switch.BorderSizePixel = 0
    switch.AutoButtonColor = false
    switch.Text = ""
    switch.Parent = container
    createCorner(switch, 9)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Theme.SliderHandle
    knob.BorderSizePixel = 0
    knob.Parent = switch
    createCorner(knob, 7)
    
    local enabled = default or false
    
    local function updateVisuals(animate)
        if enabled then
            if animate then
                TweenService:Create(switch, Theme.FastTween, {BackgroundColor3 = Theme.ToggleOn}):Play()
                TweenService:Create(knob, Theme.FastTween, {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
            else
                switch.BackgroundColor3 = Theme.ToggleOn
                knob.Position = UDim2.new(1, -16, 0.5, -7)
            end
        else
            if animate then
                TweenService:Create(switch, Theme.FastTween, {BackgroundColor3 = Theme.ToggleOff}):Play()
                TweenService:Create(knob, Theme.FastTween, {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
            else
                switch.BackgroundColor3 = Theme.ToggleOff
                knob.Position = UDim2.new(0, 2, 0.5, -7)
            end
        end
    end
    
    updateVisuals(false)
    
    switch.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateVisuals(true)
        if callback then callback(enabled) end
    end)
    
    return container
end

function Controls.CreateSlider(parent, name, config, callback)
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local decimals = config.Decimals or 0
    local value = default
    
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. name
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 16)
    header.BackgroundTransparency = 1
    header.Parent = container
    
    local label = createText(header, name, 11, Theme.TextSecondary, Theme.Font)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    
    local valueLabel = createText(header, tostring(value), 11, Theme.Accent, Theme.FontMedium, Enum.TextXAlignment.Right)
    valueLabel.Size = UDim2.new(0.5, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    
    -- Slider track
    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, 0, 0, 5)
    track.Position = UDim2.new(0, 0, 1, -8)
    track.BackgroundColor3 = Theme.SliderTrack
    track.BorderSizePixel = 0
    track.AutoButtonColor = false
    track.Text = ""
    track.Parent = container
    createCorner(track, 3)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.SliderFill
    fill.BorderSizePixel = 0
    fill.Parent = track
    createCorner(fill, 3)
    
    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.Position = UDim2.new(0, -6, 0.5, -6)
    handle.BackgroundColor3 = Theme.SliderHandle
    handle.BorderSizePixel = 0
    handle.AutoButtonColor = false
    handle.Text = ""
    handle.Parent = track
    createCorner(handle, 6)
    
    local dragging = false
    
    local function updateSlider(val, animate)
        value = math.clamp(val, min, max)
        local pct = (value - min) / (max - min)
        local formatted
        if decimals == 0 then
            formatted = tostring(math.floor(value))
        else
            formatted = string.format("%." .. decimals .. "f", value)
        end
        valueLabel.Text = formatted
        
        if animate then
            TweenService:Create(fill, Theme.FastTween, {Size = UDim2.new(pct, 0, 1, 0)}):Play()
            TweenService:Create(handle, Theme.FastTween, {Position = UDim2.new(pct, -6, 0.5, -6)}):Play()
        else
            fill.Size = UDim2.new(pct, 0, 1, 0)
            handle.Position = UDim2.new(pct, -6, 0.5, -6)
        end
    end
    
    updateSlider(value, false)
    
    local function getPercentFromX(x)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        return math.clamp((x - absPos) / absSize, 0, 1)
    end
    
    handle.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = getPercentFromX(input.Position.X)
            local newVal = min + (max - min) * pct
            updateSlider(newVal, false)
            if callback then callback(value) end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    track.MouseButton1Down:Connect(function()
        local pct = getPercentFromX(UserInputService:GetMouseLocation().X)
        local newVal = min + (max - min) * pct
        updateSlider(newVal, true)
        if callback then callback(value) end
        dragging = true
    end)
    
    
    return container
end

function Controls.CreateDropdown(parent, name, config, callback)
    local options = config.Options or {}
    local default = config.Default or (options[1] or "")
    local value = default
    local open = false
    
    local container = Instance.new("Frame")
    container.Name = "Dropdown_" .. name
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = createText(container, name, 11, Theme.TextSecondary, Theme.Font)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -4, 1, -6)
    btn.Position = UDim2.new(0.5, 2, 0, 3)
    btn.BackgroundColor3 = Theme.SurfaceLight
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = container
    createCorner(btn, 5)
    createStroke(btn, Theme.Border, 1)
    
    local valueLabel = createText(btn, tostring(value), 10, Theme.Text, Theme.Font, Enum.TextXAlignment.Left)
    valueLabel.Size = UDim2.new(1, -24, 1, 0)
    valueLabel.Position = UDim2.new(0, 7, 0, 0)
    
    local arrow = Instance.new("Frame")
    arrow.Size = UDim2.new(0, 10, 0, 10)
    arrow.Position = UDim2.new(1, -18, 0.5, -5)
    arrow.BackgroundTransparency = 1
    arrow.Parent = btn
    
    local arrowIcon = Icons.Icon("ChevronDown", 10)
    arrowIcon.Size = UDim2.new(0, 10, 0, 10)
    arrowIcon.Position = UDim2.new(0, 0, 0, 0)
    arrowIcon.Parent = arrow
    
    local dropdownFrame = nil
    
    local function closeDropdown()
        if dropdownFrame then
            dropdownFrame:Destroy()
            dropdownFrame = nil
        end
        open = false
    end
    
    local function openDropdown()
        if open then closeDropdown() return end
        open = true
        
        dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, #options * 26 + 6)
        dropdownFrame.BackgroundColor3 = Theme.SurfaceLight
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.ZIndex = 100
        dropdownFrame.Parent = container.Parent.Parent
        anchorPopup(dropdownFrame, btn, 0, btn.AbsoluteSize.Y + 2)
        createCorner(dropdownFrame, 5)
        createStroke(dropdownFrame, Theme.Border, 1)
        
        local layout = createListLayout(dropdownFrame, 0)
        createPadding(dropdownFrame, 3, 3, 0, 0)
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.BackgroundColor3 = (opt == value) and Theme.SurfaceActive or Theme.SurfaceLight
            optBtn.BorderSizePixel = 0
            optBtn.AutoButtonColor = false
            optBtn.Text = ""
            optBtn.LayoutOrder = i
            optBtn.ZIndex = 101
            optBtn.Parent = dropdownFrame
            createCorner(optBtn, 4)
            
            local optLabel = createText(optBtn, tostring(opt), 10, (opt == value) and Theme.Accent or Theme.TextSecondary, Theme.Font, Enum.TextXAlignment.Left)
            optLabel.Size = UDim2.new(1, -10, 1, 0)
            optLabel.Position = UDim2.new(0, 8, 0, 0)
            optLabel.ZIndex = 102
            
            optBtn.MouseEnter:Connect(function()
                TweenService:Create(optBtn, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceHover}):Play()
            end)
            optBtn.MouseLeave:Connect(function()
                TweenService:Create(optBtn, Theme.FastTween, {BackgroundColor3 = (opt == value) and Theme.SurfaceActive or Theme.SurfaceLight}):Play()
            end)
            optBtn.MouseButton1Click:Connect(function()
                value = tostring(opt)
                valueLabel.Text = value
                closeDropdown()
                if callback then callback(value) end
            end)
        end
    end
    
    btn.MouseButton1Click:Connect(openDropdown)
    
    -- Close dropdown when clicking outside of it (and outside the button)
    local closeOnOutsideClick = UserInputService.InputBegan:Connect(function(input)
        if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouseLoc = UserInputService:GetMouseLocation()
            local guiInset = GuiService:GetGuiInset()
            local pos = Vector2.new(mouseLoc.X, mouseLoc.Y - guiInset.Y)
            
            local function isInside(gui)
                if not gui or not gui.Parent then return false end
                local p, s = gui.AbsolutePosition, gui.AbsoluteSize
                return pos.X >= p.X and pos.X <= p.X + s.X
                    and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
            end
            
            if not isInside(btn) and not isInside(dropdownFrame) then
                closeDropdown()
            end
        end
    end)
    
    container.Destroying:Connect(function()
        closeOnOutsideClick:Disconnect()
    end)
    
    return container
end

function Controls.CreateKeybind(parent, name, config, callback)
    local default = config.Default or Enum.KeyCode.Unknown
    local value = default
    local listening = false
    
    local container = Instance.new("Frame")
    container.Name = "Keybind_" .. name
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = createText(container, name, 11, Theme.TextSecondary, Theme.Font)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, -4, 1, -6)
    btn.Position = UDim2.new(0.6, 2, 0, 3)
    btn.BackgroundColor3 = Theme.SurfaceLight
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = container
    createCorner(btn, 5)
    createStroke(btn, Theme.Border, 1)
    
    local valueLabel = createText(btn, tostring(value), 10, Theme.Text, Theme.FontMedium, Enum.TextXAlignment.Center)
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    
    local function updateLabel()
        if listening then
            valueLabel.Text = "..."
            valueLabel.TextColor3 = Theme.Accent
        else
            valueLabel.Text = tostring(value)
            valueLabel.TextColor3 = Theme.Text
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        listening = true
        updateLabel()
    end)
    
    local conn
    conn = UserInputService.InputBegan:Connect(function(input)
        if listening then
            if input.KeyCode ~= Enum.KeyCode.Escape then
                value = input.KeyCode
                if callback then callback(value) end
            end
            listening = false
            updateLabel()
            conn:Disconnect()
        end
    end)
    
    return container
end

function Controls.CreateColorPicker(parent, name, config, callback)
    local default = config.Default or Color3.fromRGB(255, 255, 255)
    local value = default
    
    local container = Instance.new("Frame")
    container.Name = "ColorPicker_" .. name
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = createText(container, name, 11, Theme.TextSecondary, Theme.Font)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 32, 0, 18)
    btn.Position = UDim2.new(1, -32, 0.5, -9)
    btn.BackgroundColor3 = value
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = container
    createCorner(btn, 5)
    createStroke(btn, Theme.BorderLight, 1)
    
    local pickerOpen = false
    local pickerFrame = nil
    
    local function closePicker()
        if pickerFrame then
            pickerFrame:Destroy()
            pickerFrame = nil
        end
        pickerOpen = false
    end
    
    local function openPicker()
        if pickerOpen then closePicker() return end
        pickerOpen = true
        
        pickerFrame = Instance.new("Frame")
        pickerFrame.Size = UDim2.new(0, 160, 0, 120)
        pickerFrame.BackgroundColor3 = Theme.SurfaceLight
        pickerFrame.BorderSizePixel = 0
        pickerFrame.ZIndex = 100
        pickerFrame.Parent = container.Parent.Parent
        anchorPopup(pickerFrame, btn, -128, 20)
        createCorner(pickerFrame, 7)
        createStroke(pickerFrame, Theme.Border, 1)
        
        local colors = {
            Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 160, 80), Color3.fromRGB(255, 230, 80),
            Color3.fromRGB(80, 255, 120), Color3.fromRGB(80, 200, 255), Color3.fromRGB(160, 100, 255),
            Color3.fromRGB(255, 100, 200), Color3.fromRGB(255, 255, 255), Color3.fromRGB(180, 180, 180),
            Color3.fromRGB(100, 220, 160), Color3.fromRGB(255, 120, 120), Color3.fromRGB(120, 120, 120),
        }
        
        for i, color in ipairs(colors) do
            local row = math.floor((i - 1) / 4)
            local col = (i - 1) % 4
            local cBtn = Instance.new("TextButton")
            cBtn.Size = UDim2.new(0, 28, 0, 22)
            cBtn.Position = UDim2.new(0, 10 + col * 36, 0, 10 + row * 28)
            cBtn.BackgroundColor3 = color
            cBtn.BorderSizePixel = 0
            cBtn.AutoButtonColor = false
            cBtn.Text = ""
            cBtn.ZIndex = 101
            cBtn.Parent = pickerFrame
            createCorner(cBtn, 3)
            
            cBtn.MouseButton1Click:Connect(function()
                value = color
                btn.BackgroundColor3 = color
                closePicker()
                if callback then callback(color) end
            end)
        end
    end
    
    btn.MouseButton1Click:Connect(openPicker)
    
    return container
end

function Controls.CreateButton(parent, name, callback)
    local container = Instance.new("Frame")
    container.Name = "Button_" .. name
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Theme.SurfaceLight
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = name
    btn.TextColor3 = Theme.Text
    btn.TextSize = 11
    btn.Font = Theme.FontMedium
    btn.Parent = container
    createCorner(btn, 5)
    createStroke(btn, Theme.Border, 1)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceLight}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return container
end

function Controls.CreateSection(parent, name)
    local container = Instance.new("Frame")
    container.Name = "Section_" .. name
    container.Size = UDim2.new(1, 0, 0, 20)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = createText(container, name:upper(), 9, Theme.TextMuted, Theme.FontBold, Enum.TextXAlignment.Left)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.TextTransparency = 0.3
    
    return container
end

function Controls.CreateLabel(parent, text)
    local container = Instance.new("Frame")
    container.Name = "Label"
    container.Size = UDim2.new(1, 0, 0, 18)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = createText(container, text, 10, Theme.TextMuted, Theme.Font, Enum.TextXAlignment.Left)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.TextWrapped = true
    
    return container
end

function Controls.CreateTextbox(parent, name, config, callback)
    local default = config.Default or ""
    local value = default
    local placeholder = config.Placeholder or ""
    
    local container = Instance.new("Frame")
    container.Name = "Textbox_" .. name
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = createText(container, name, 11, Theme.TextSecondary, Theme.Font)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.6, -4, 1, -6)
    box.Position = UDim2.new(0.4, 2, 0, 3)
    box.BackgroundColor3 = Theme.SurfaceLight
    box.BorderSizePixel = 0
    box.Text = value
    box.PlaceholderText = placeholder
    box.TextColor3 = Theme.Text
    box.PlaceholderColor3 = Theme.TextMuted
    box.TextSize = 10
    box.Font = Theme.Font
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false
    box.Parent = container
    createCorner(box, 5)
    createStroke(box, Theme.Border, 1)
    createPadding(box, 0, 0, 7, 7)
    
    box.FocusLost:Connect(function()
        value = box.Text
        if callback then callback(value) end
    end)
    
    return container
end

function Controls.CreateMultiDropdown(parent, name, config, callback)
    local options = config.Options or {}
    local default = config.Default or {}
    local values = {}
    for _, v in ipairs(default) do
        values[tostring(v)] = true
    end
    local open = false
    
    local container = Instance.new("Frame")
    container.Name = "MultiDropdown_" .. name
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = createText(container, name, 11, Theme.TextSecondary, Theme.Font)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -4, 1, -6)
    btn.Position = UDim2.new(0.5, 2, 0, 3)
    btn.BackgroundColor3 = Theme.SurfaceLight
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = container
    createCorner(btn, 5)
    createStroke(btn, Theme.Border, 1)
    
    local function getDisplayText()
        local count = 0
        for _ in pairs(values) do count = count + 1 end
        if count == 0 then return "None" end
        if count == 1 then
            for k in pairs(values) do return tostring(k) end
        end
        return count .. " selected"
    end
    
    local valueLabel = createText(btn, getDisplayText(), 10, Theme.Text, Theme.Font, Enum.TextXAlignment.Left)
    valueLabel.Size = UDim2.new(1, -24, 1, 0)
    valueLabel.Position = UDim2.new(0, 7, 0, 0)
    
    local arrow = Instance.new("Frame")
    arrow.Size = UDim2.new(0, 10, 0, 10)
    arrow.Position = UDim2.new(1, -18, 0.5, -5)
    arrow.BackgroundTransparency = 1
    arrow.Parent = btn
    
    local arrowIcon = Icons.Icon("ChevronDown", 10)
    arrowIcon.Size = UDim2.new(0, 10, 0, 10)
    arrowIcon.Parent = arrow
    
    local dropdownFrame = nil
    
    local function closeDropdown()
        if dropdownFrame then
            dropdownFrame:Destroy()
            dropdownFrame = nil
        end
        open = false
    end
    
    local function openDropdown()
        if open then closeDropdown() return end
        open = true
        
        dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, #options * 26 + 6)
        dropdownFrame.BackgroundColor3 = Theme.SurfaceLight
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.ZIndex = 100
        dropdownFrame.Parent = container.Parent.Parent
        anchorPopup(dropdownFrame, btn, 0, btn.AbsoluteSize.Y + 2)
        createCorner(dropdownFrame, 5)
        createStroke(dropdownFrame, Theme.Border, 1)
        
        local layout = createListLayout(dropdownFrame, 0)
        createPadding(dropdownFrame, 3, 3, 0, 0)
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.BackgroundColor3 = values[tostring(opt)] and Theme.SurfaceActive or Theme.SurfaceLight
            optBtn.BorderSizePixel = 0
            optBtn.AutoButtonColor = false
            optBtn.Text = ""
            optBtn.LayoutOrder = i
            optBtn.ZIndex = 101
            optBtn.Parent = dropdownFrame
            createCorner(optBtn, 4)
            
            local check = Instance.new("Frame")
            check.Size = UDim2.new(0, 12, 0, 12)
            check.Position = UDim2.new(0, 7, 0.5, -6)
            check.BackgroundColor3 = values[tostring(opt)] and Theme.Accent or Theme.Border
            check.BorderSizePixel = 0
            check.ZIndex = 102
            check.Parent = optBtn
            createCorner(check, 3)
            
            local optLabel = createText(optBtn, tostring(opt), 10, Theme.TextSecondary, Theme.Font, Enum.TextXAlignment.Left)
            optLabel.Size = UDim2.new(1, -26, 1, 0)
            optLabel.Position = UDim2.new(0, 24, 0, 0)
            optLabel.ZIndex = 102
            
            optBtn.MouseButton1Click:Connect(function()
                if values[tostring(opt)] then
                    values[tostring(opt)] = nil
                else
                    values[tostring(opt)] = true
                end
                check.BackgroundColor3 = values[tostring(opt)] and Theme.Accent or Theme.Border
                optBtn.BackgroundColor3 = values[tostring(opt)] and Theme.SurfaceActive or Theme.SurfaceLight
                valueLabel.Text = getDisplayText()
                if callback then callback(values) end
            end)
        end
    end
    
    btn.MouseButton1Click:Connect(openDropdown)
    
    
    return container
end

--------------------------------------------------------------------------------
-- MODULE CLASS
--------------------------------------------------------------------------------
local ModuleInstance = {}
ModuleInstance.__index = ModuleInstance

function ModuleInstance.new(data, category)
    local self = setmetatable({}, ModuleInstance)
    self.Name = data.Name or "Unnamed"
    self.Category = category or "Utility"
    self.Description = data.Description or ""
    self.Enabled = data.Default or false
    self.Visible = true
    self.Favorite = data.Favorite or false
    self.Keybind = nil
    self.Settings = {}
    self._settingOrder = {}
    self._callbacks = {}
    self._toggleCallback = nil
    self._destroyCallback = nil
    self._controls = {}
    return self
end

function ModuleInstance:SetDescription(desc)
    self.Description = desc
end

function ModuleInstance:SetEnabled(val)
    self.Enabled = val and true or false
    if self._toggleCallback then
        safeCall(self._toggleCallback, self.Enabled)
    end
    if _getInstance()._ui and _getInstance()._ui.refreshModules then
        _getInstance()._ui:refreshModules()
    end
end

function ModuleInstance:IsEnabled()
    return self.Enabled
end

function ModuleInstance:SetVisible(val)
    self.Visible = val
end

function ModuleInstance:IsVisible()
    return self.Visible
end

function ModuleInstance:SetFavorite(val)
    self.Favorite = val and true or false
    if _getInstance()._ui then
        _getInstance()._ui:refreshSidebar()
        _getInstance()._ui:refreshModules()
    end
end

function ModuleInstance:IsFavorite()
    return self.Favorite
end

function ModuleInstance:SetKeybind(key)
    self.Keybind = key
end

function ModuleInstance:GetKeybind()
    return self.Keybind
end

function ModuleInstance:OnToggle(cb)
    self._toggleCallback = cb
end

function ModuleInstance:OnDestroy(cb)
    self._destroyCallback = cb
end

function ModuleInstance:_addSetting(name, config, type)
    local setting = {
        Name = name,
        Type = type,
        Default = config.Default,
        Value = config.Default,
        Min = config.Min,
        Max = config.Max,
        Decimals = config.Decimals,
        Options = config.Options,
        Placeholder = config.Placeholder,
        Callback = config.Callback,
    }
    self.Settings[name] = setting
    self._settingOrder[#self._settingOrder + 1] = name
    return setting
end

function ModuleInstance:AddToggle(name, config)
    config = config or {}
    self:_addSetting(name, config, "Toggle")
    return self
end

function ModuleInstance:AddSlider(name, config)
    config = config or {}
    self:_addSetting(name, config, "Slider")
    return self
end

function ModuleInstance:AddDropdown(name, config)
    config = config or {}
    self:_addSetting(name, config, "Dropdown")
    return self
end

function ModuleInstance:AddMultiDropdown(name, config)
    config = config or {}
    self:_addSetting(name, config, "MultiDropdown")
    return self
end

function ModuleInstance:AddTextbox(name, config)
    config = config or {}
    self:_addSetting(name, config, "Textbox")
    return self
end

function ModuleInstance:AddKeybind(name, config)
    config = config or {}
    self:_addSetting(name, config, "Keybind")
    return self
end

function ModuleInstance:AddColorPicker(name, config)
    config = config or {}
    self:_addSetting(name, config, "ColorPicker")
    return self
end

function ModuleInstance:AddButton(name, callback)
    local config = { Callback = callback }
    self:_addSetting(name, config, "Button")
    return self
end

function ModuleInstance:AddSection(name)
    local config = {}
    self:_addSetting(name, config, "Section")
    return self
end

function ModuleInstance:AddLabel(text)
    local config = { Text = text }
    self:_addSetting(text, config, "Label")
    return self
end

function ModuleInstance:Get(name)
    return self.Settings[name]
end

function ModuleInstance:Set(name, value)
    local setting = self.Settings[name]
    if setting then
        setting.Value = value
        if setting.Callback then
            safeCall(setting.Callback, value)
        end
    end
end

function ModuleInstance:GetValue(name)
    local setting = self.Settings[name]
    return setting and setting.Value
end

function ModuleInstance:Reset()
    for _, setting in pairs(self.Settings) do
        setting.Value = setting.Default
    end
    self.Enabled = false
    self.Favorite = false
end

function ModuleInstance:Destroy()
    if self._destroyCallback then
        safeCall(self._destroyCallback)
    end
    self.Settings = {}
    self._settingOrder = {}
    local registry = _getInstance()._registry
    if registry then
        registry.modules[self.Name] = nil
    end
    if _getInstance()._ui then
        _getInstance()._ui:refreshSidebar()
        _getInstance()._ui:refreshModules()
    end
end

--------------------------------------------------------------------------------
-- MODULE TAB (CATEGORY) CLASS
--------------------------------------------------------------------------------
local ModuleTab = {}
ModuleTab.__index = ModuleTab

function ModuleTab.new(name, options)
    local self = setmetatable({}, ModuleTab)
    self.Name = name
    self.Icon = (options and options.Icon) or "Circle"
    self.Order = (options and options.Order) or 999
    self.Modules = {}
    return self
end

function ModuleTab:Add(name, options)
    options = options or {}
    
    -- Check for duplicate
    local registry = _getInstance()._registry
    if registry and registry.modules[name] then
        return registry.modules[name]
    end
    
    local mod = ModuleInstance.new(options, self.Name)
    mod.Name = name
    if options.Description then mod.Description = options.Description end
    if options.Default ~= nil then mod.Enabled = options.Default end
    if options.Favorite then mod.Favorite = options.Favorite end
    
    self.Modules[name] = mod
    if registry then
        registry.modules[name] = mod
    end
    
    if _getInstance()._ui then
        _getInstance()._ui:refreshSidebar()
        _getInstance()._ui:refreshModules()
    end
    
    return mod
end

--------------------------------------------------------------------------------
-- MAIN UI CLASS
--------------------------------------------------------------------------------
local UI = {}
UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)
    self.screen = nil
    self.mainWindow = nil
    self.topBar = nil
    self.pageContainer = nil
    self.modulesPage = nil
    self.configPage = nil
    self.sidebar = nil
    self.moduleList = nil
    self.settingsPanel = nil
    self.selectedModule = nil
    self.selectedCategory = "Favorites"
    self.searchTerm = ""
    self.isMinimized = false
    self.connections = {}
    self.settingControls = {}
    return self
end

function UI:Init()
    -- Create main ScreenGui
    local screen = Instance.new("ScreenGui")
    screen.Name = "ImpulseUI"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.DisplayOrder = 100
    screen.Parent = PlayerGui
    self.screen = screen
    
    -- Create main window
    self:createMainWindow()
    self:createModulesPage()
    self:createConfigPage()
    self:showPage("Modules")
    
    -- Init notification service
    local notif = _getInstance()._notifications
    if notif then
        notif:Init(screen)
    end
end

function UI:createMainWindow()
    local win = Instance.new("Frame")
    win.Name = "MainWindow"
    win.Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight)
    win.Position = UDim2.new(0.5, -Theme.WindowWidth/2, 0.5, -Theme.WindowHeight/2)
    win.BackgroundColor3 = Theme.Background
    win.BorderSizePixel = 0
    win.ClipsDescendants = true
    win.Parent = self.screen
    createCorner(win, 10)
    createStroke(win, Theme.Border, 1)
    self.mainWindow = win
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(20, 20, 20, 20)
    shadow.ZIndex = -1
    shadow.Parent = win
    -- Use a simple frame shadow instead of image
    shadow:Destroy()
    
    -- Top bar
    self:createTopBar()
    
    -- Page container
    local container = Instance.new("Frame")
    container.Name = "PageContainer"
    container.Size = UDim2.new(1, 0, 1, -Theme.TopBarHeight)
    container.Position = UDim2.new(0, 0, 0, Theme.TopBarHeight)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = win
    self.pageContainer = container
    
    -- Make window draggable
    self:makeDraggable()
end

function UI:createTopBar()
    local bar = Instance.new("Frame")
    bar.Name = "TopBar"
    bar.Size = UDim2.new(1, 0, 0, Theme.TopBarHeight)
    bar.BackgroundColor3 = Theme.Surface
    bar.BorderSizePixel = 0
    bar.Parent = self.mainWindow
    createStroke(bar, Theme.Border, 1)
    
    -- Fix corners (only top)
    local bgCover = Instance.new("Frame")
    bgCover.Size = UDim2.new(1, 0, 0, 10)
    bgCover.Position = UDim2.new(0, 0, 1, -5)
    bgCover.BackgroundColor3 = Theme.Surface
    bgCover.BorderSizePixel = 0
    bgCover.Parent = bar
    
    self.topBar = bar
    
    -- Logo area
    local logo = Instance.new("Frame")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 90, 1, 0)
    logo.Position = UDim2.new(0, 12, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Parent = bar
    
    local logoText = createText(logo, "VAPE", 15, Theme.Text, Theme.FontBold, Enum.TextXAlignment.Left)
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.Position = UDim2.new(0, 0, 0, 1)
    
    -- Navigation
    local nav = Instance.new("Frame")
    nav.Name = "Navigation"
    nav.Size = UDim2.new(0, 200, 1, 0)
    nav.Position = UDim2.new(0, 110, 0, 0)
    nav.BackgroundTransparency = 1
    nav.Parent = bar
    
    local navLayout = Instance.new("UIListLayout")
    navLayout.FillDirection = Enum.FillDirection.Horizontal
    navLayout.Padding = UDim.new(0, 6)
    navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    navLayout.Parent = nav
    
    local navItems = {"Modules"}
    for _, item in ipairs(navItems) do
        local btn = Instance.new("TextButton")
        btn.Name = item
        btn.Size = UDim2.new(0, 66, 0, 26)
        btn.BackgroundColor3 = (item == "Modules") and Theme.SurfaceLight or Theme.Surface
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = item
        btn.TextColor3 = (item == "Modules") and Theme.Text or Theme.TextSecondary
        btn.TextSize = 11
        btn.Font = Theme.FontMedium
        btn.Parent = nav
        createCorner(btn, 6)
        
        btn.MouseEnter:Connect(function()
            if item ~= "Modules" then
                TweenService:Create(btn, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceHover}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if item ~= "Modules" then
                TweenService:Create(btn, Theme.FastTween, {BackgroundColor3 = Theme.Surface}):Play()
            end
        end)
    end
    
    -- Window controls
    local controls = Instance.new("Frame")
    controls.Name = "WindowControls"
    controls.Size = UDim2.new(0, 120, 1, 0)
    controls.Position = UDim2.new(1, -12, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = bar
    controls.AnchorPoint = Vector2.new(1, 0)
    
    local cLayout = Instance.new("UIListLayout")
    cLayout.FillDirection = Enum.FillDirection.Horizontal
    cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    cLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    cLayout.Padding = UDim.new(0, 4)
    cLayout.Parent = controls
    
    local function createControlBtn(name, iconName)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 28, 0, 28)
        btn.BackgroundColor3 = Theme.Surface
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.Parent = controls
        createCorner(btn, 6)
        
        local icon = Icons.Icon(iconName, 14)
        icon.Size = UDim2.new(0, 14, 0, 14)
        icon.Position = UDim2.new(0.5, -7, 0.5, -7)
        icon.Parent = btn
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceHover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, Theme.FastTween, {BackgroundColor3 = Theme.Surface}):Play()
        end)
        
        return btn
    end
    
    local settingsBtn = createControlBtn("Settings", "Settings")
    local minimizeBtn = createControlBtn("Minimize", "Minus")
    local closeBtn = createControlBtn("Close", "X")
    
    settingsBtn.MouseButton1Click:Connect(function()
        self:showPage("Config")
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        self:toggleMinimized()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:close()
    end)
end

function UI:createModulesPage()
    local page = Instance.new("Frame")
    page.Name = "ModulesPage"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.pageContainer
    self.modulesPage = page
    
    -- Sidebar
    self:createSidebar()
    
    -- Module list area
    self:createModuleListArea()
    
    -- Settings panel
    self:createSettingsPanel()
end

function UI:createSidebar()
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, Theme.SidebarWidth, 1, 0)
    sidebar.BackgroundColor3 = Theme.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = self.modulesPage
    createStroke(sidebar, Theme.Border, 1)
    self.sidebar = sidebar
    
    -- Sidebar header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundTransparency = 1
    header.Parent = sidebar
    
    local headerText = createText(header, "Modules", 12, Theme.Text, Theme.FontMedium, Enum.TextXAlignment.Left)
    headerText.Size = UDim2.new(1, -16, 1, 0)
    headerText.Position = UDim2.new(0, 12, 0, 0)
    
    -- Scrolling list
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "CategoryList"
    scroll.Size = UDim2.new(1, -8, 1, -40)
    scroll.Position = UDim2.new(0, 4, 0, 38)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.AccentDim
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticSize = Enum.AutomaticSize.Y
    scroll.Parent = sidebar
    
    local layout = createListLayout(scroll, 2)
    self.sidebarLayout = layout
    self.sidebarScroll = scroll
    
    self:refreshSidebar()
end

function UI:refreshSidebar()
    if not self.sidebarScroll then return end
    
    -- Clear existing
    for _, child in ipairs(self.sidebarScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Gather categories
    local categories = {}
    
    -- Favorites first
    categories[#categories + 1] = {
        Name = "Favorites",
        Icon = "Star",
        Order = 0,
        Count = 0
    }
    
    local registry = _getInstance()._registry
    if registry then
        for name, cat in pairs(registry.categories) do
            local count = 0
            for _, mod in pairs(cat.Modules) do
                if mod.Enabled then count = count + 1 end
            end
            categories[#categories + 1] = {
                Name = name,
                Icon = cat.Icon,
                Order = cat.Order,
                Count = count
            }
        end
    end
    
    table.sort(categories, function(a, b) return a.Order < b.Order end)
    
    -- Count favorites
    local favCount = 0
    local registry = _getInstance()._registry
    if registry then
        for _, mod in pairs(registry.modules) do
            if mod.Favorite then favCount = favCount + 1 end
        end
    end
    categories[1].Count = favCount
    
    -- Create buttons
    for _, cat in ipairs(categories) do
        local btn = Instance.new("TextButton")
        btn.Name = cat.Name
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = (cat.Name == self.selectedCategory) and Theme.SurfaceLight or Theme.Surface
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.LayoutOrder = cat.Order
        btn.Parent = self.sidebarScroll
        createCorner(btn, 6)
        
        -- Icon
        local icon = Icons.Icon(cat.Icon, 14)
        icon.Size = UDim2.new(0, 14, 0, 14)
        icon.Position = UDim2.new(0, 10, 0.5, -7)
        icon.Parent = btn
        
        -- Name
        local nameLabel = createText(btn, cat.Name, 12, (cat.Name == self.selectedCategory) and Theme.Text or Theme.TextSecondary, Theme.FontMedium, Enum.TextXAlignment.Left)
        nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 30, 0, 0)
        
        -- Count
        if cat.Count > 0 then
            local countLabel = createText(btn, tostring(cat.Count), 10, Theme.TextMuted, Theme.Font, Enum.TextXAlignment.Right)
            countLabel.Size = UDim2.new(0, 20, 1, 0)
            countLabel.Position = UDim2.new(1, -36, 0, 0)
        end
        
        -- Chevron
        local chevron = Icons.Icon("ChevronRight", 12)
        chevron.Size = UDim2.new(0, 12, 0, 12)
        chevron.Position = UDim2.new(1, -18, 0.5, -6)
        chevron.Parent = btn
        
        -- Hover
        btn.MouseEnter:Connect(function()
            if cat.Name ~= self.selectedCategory then
                TweenService:Create(btn, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceHover}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if cat.Name ~= self.selectedCategory then
                TweenService:Create(btn, Theme.FastTween, {BackgroundColor3 = Theme.Surface}):Play()
            end
        end)
        
        -- Click
        btn.MouseButton1Click:Connect(function()
            self.selectedCategory = cat.Name
            self:refreshSidebar()
            self:refreshModules()
        end)
    end
end

function UI:createModuleListArea()
    local area = Instance.new("Frame")
    area.Name = "ModuleListArea"
    area.Size = UDim2.new(1, -Theme.SidebarWidth - Theme.SettingsPanelWidth, 1, 0)
    area.Position = UDim2.new(0, Theme.SidebarWidth, 0, 0)
    area.BackgroundTransparency = 1
    area.Parent = self.modulesPage
    
    -- Search bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchBar"
    searchFrame.Size = UDim2.new(1, -16, 0, 28)
    searchFrame.Position = UDim2.new(0, 8, 0, 6)
    searchFrame.BackgroundColor3 = Theme.Surface
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = area
    createCorner(searchFrame, 6)
    createStroke(searchFrame, Theme.Border, 1)
    
    local searchIcon = Icons.Icon("Search", 13)
    searchIcon.Size = UDim2.new(0, 13, 0, 13)
    searchIcon.Position = UDim2.new(0, 9, 0.5, -6)
    searchIcon.Parent = searchFrame
    
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchInput"
    searchBox.Size = UDim2.new(1, -30, 1, 0)
    searchBox.Position = UDim2.new(0, 28, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search modules..."
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.TextColor3 = Theme.Text
    searchBox.TextSize = 11
    searchBox.Font = Theme.Font
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchFrame
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self.searchTerm = searchBox.Text:lower()
        self:refreshModules()
    end)
    
    -- Module list scroll
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "ModuleList"
    scroll.Size = UDim2.new(1, -16, 1, -42)
    scroll.Position = UDim2.new(0, 8, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.AccentDim
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticSize = Enum.AutomaticSize.Y
    scroll.Parent = area
    
    local layout = createListLayout(scroll, 3)
    self.moduleListLayout = layout
    self.moduleListScroll = scroll
end

function UI:refreshModules()
    if not self.moduleListScroll then return end
    
    -- Clear existing
    for _, child in ipairs(self.moduleListScroll:GetChildren()) do
        if child:IsA("Frame") and child.Name == "ModuleCard" then
            child:Destroy()
        end
    end
    
    -- Gather modules for current category
    local modules = {}
    
    local registry = _getInstance()._registry
    if registry then
        if self.selectedCategory == "Favorites" then
            for name, mod in pairs(registry.modules) do
                if mod.Favorite then
                    modules[#modules + 1] = mod
                end
            end
        else
            local cat = registry.categories[self.selectedCategory]
            if cat then
                for name, mod in pairs(cat.Modules) do
                    modules[#modules + 1] = mod
                end
            end
        end
    end
    
    -- Filter by search
    if self.searchTerm and self.searchTerm ~= "" then
        local filtered = {}
        for _, mod in ipairs(modules) do
            local searchIn = (mod.Name .. " " .. mod.Description .. " " .. mod.Category):lower()
            if searchIn:find(self.searchTerm, 1, true) then
                filtered[#filtered + 1] = mod
            end
        end
        modules = filtered
    end
    
    -- Sort
    table.sort(modules, function(a, b) return a.Name < b.Name end)
    
    -- Create cards
    for i, mod in ipairs(modules) do
        self:createModuleCard(mod, i)
    end
end

function UI:createModuleCard(mod, index)
    local card = Instance.new("Frame")
    card.Name = "ModuleCard"
    card.Size = UDim2.new(1, 0, 0, 42)
    card.BackgroundColor3 = (mod == self.selectedModule) and Theme.SurfaceLight or Theme.Surface
    card.BorderSizePixel = 0
    card.LayoutOrder = index
    card.Parent = self.moduleListScroll
    createCorner(card, 6)
    
    -- Accent indicator
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 3, 1, -12)
    accent.Position = UDim2.new(0, 6, 0, 6)
    accent.BackgroundColor3 = mod.Enabled and Theme.Accent or Theme.Border
    accent.BorderSizePixel = 0
    accent.Parent = card
    createCorner(accent, 2)
    
    -- Module name
    local nameLabel = createText(card, mod.Name, 12, Theme.Text, Theme.FontMedium, Enum.TextXAlignment.Left)
    nameLabel.Size = UDim2.new(0.38, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 16, 0, 7)
    
    -- Description
    local descLabel = createText(card, mod.Description, 10, Theme.TextMuted, Theme.Font, Enum.TextXAlignment.Left)
    descLabel.Size = UDim2.new(0.55, -90, 0, 12)
    descLabel.Position = UDim2.new(0, 16, 0, 25)
    descLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Right side controls
    local rightX = 1
    
    -- Keybind indicator
    if mod.Keybind then
        local kb = Instance.new("Frame")
        kb.Size = UDim2.new(0, 22, 0, 16)
        kb.Position = UDim2.new(1, -rightX - 22, 0.5, -8)
        kb.BackgroundColor3 = Theme.SurfaceLight
        kb.BorderSizePixel = 0
        kb.Parent = card
        createCorner(kb, 4)
        
        local kbLabel = createText(kb, tostring(mod.Keybind.Name or mod.Keybind), 9, Theme.TextSecondary, Theme.FontMedium, Enum.TextXAlignment.Center)
        kbLabel.Size = UDim2.new(1, 0, 1, 0)
        
        rightX = rightX + 26
    end
    
    -- Toggle
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(0, 30, 0, 16)
    toggle.Position = UDim2.new(1, -rightX - 30, 0.5, -8)
    toggle.BackgroundColor3 = mod.Enabled and Theme.ToggleOn or Theme.ToggleOff
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Text = ""
    toggle.Parent = card
    createCorner(toggle, 8)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(mod.Enabled and 1 or 0, mod.Enabled and -14 or 2, 0.5, -6)
    knob.BackgroundColor3 = Theme.SliderHandle
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    createCorner(knob, 6)
    
    toggle.MouseButton1Click:Connect(function()
        mod:SetEnabled(not mod.Enabled)
        toggle.BackgroundColor3 = mod.Enabled and Theme.ToggleOn or Theme.ToggleOff
        TweenService:Create(knob, Theme.FastTween, {
            Position = UDim2.new(mod.Enabled and 1 or 0, mod.Enabled and -14 or 2, 0.5, -6)
        }):Play()
        accent.BackgroundColor3 = mod.Enabled and Theme.Accent or Theme.Border
    end)
    
    rightX = rightX + 34
    
    -- Three-dot menu
    local menuBtn = Instance.new("TextButton")
    menuBtn.Name = "MenuBtn"
    menuBtn.Size = UDim2.new(0, 20, 0, 20)
    menuBtn.Position = UDim2.new(1, -rightX - 20, 0.5, -10)
    menuBtn.BackgroundColor3 = Theme.Surface
    menuBtn.BorderSizePixel = 0
    menuBtn.AutoButtonColor = false
    menuBtn.Text = ""
    menuBtn.Parent = card
    createCorner(menuBtn, 5)
    
    local menuIcon = Icons.Icon("MoreVertical", 11)
    menuIcon.Size = UDim2.new(0, 11, 0, 11)
    menuIcon.Position = UDim2.new(0.5, -5, 0.5, -5)
    menuIcon.Parent = menuBtn
    
    menuBtn.MouseButton1Click:Connect(function()
        self:showModuleContextMenu(mod, menuBtn)
    end)
    
    -- Click to select
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.selectedModule = mod
            self:refreshModules()
            self:refreshSettingsPanel()
        end
    end)
    
    -- Hover
    card.MouseEnter:Connect(function()
        if mod ~= self.selectedModule then
            TweenService:Create(card, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceHover}):Play()
        end
    end)
    card.MouseLeave:Connect(function()
        if mod ~= self.selectedModule then
            TweenService:Create(card, Theme.FastTween, {BackgroundColor3 = Theme.Surface}):Play()
        end
    end)
end

function UI:showModuleContextMenu(mod, parent)
    -- Close existing context menu
    if self.contextMenu then
        self.contextMenu:Destroy()
        self.contextMenu = nil
    end
    
    local menu = Instance.new("Frame")
    menu.Name = "ContextMenu"
    menu.Size = UDim2.new(0, 140, 0, 0)
    menu.BackgroundColor3 = Theme.SurfaceLight
    menu.BorderSizePixel = 0
    menu.ZIndex = 200
    menu.ClipsDescendants = true
    menu.Parent = self.modulesPage
    anchorPopup(menu, parent, -100, 24)
    createCorner(menu, 6)
    createStroke(menu, Theme.Border, 1)
    
    local items = {
        { Name = mod.Favorite and "Unfavorite" or "Favorite", Icon = "Star" },
        { Name = "Bind Key", Icon = "Keyboard" },
        { Name = "Reset Settings", Icon = "Target" },
        { Name = "Open Settings", Icon = "Settings" },
    }
    
    local layout = createListLayout(menu, 0)
    createPadding(menu, 4, 4, 0, 0)
    
    for i, item in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = Theme.SurfaceLight
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.LayoutOrder = i
        btn.ZIndex = 201
        btn.Parent = menu
        createCorner(btn, 4)
        
        local icon = Icons.Icon(item.Icon, 12)
        icon.Size = UDim2.new(0, 12, 0, 12)
        icon.Position = UDim2.new(0, 8, 0.5, -6)
        icon.ZIndex = 202
        icon.Parent = btn
        
        local label = createText(btn, item.Name, 11, Theme.TextSecondary, Theme.Font, Enum.TextXAlignment.Left)
        label.Size = UDim2.new(1, -30, 1, 0)
        label.Position = UDim2.new(0, 26, 0, 0)
        label.ZIndex = 202
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceHover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceLight}):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            if i == 1 then
                mod:SetFavorite(not mod.Favorite)
            elseif i == 2 then
                -- Keybind handled by module
            elseif i == 3 then
                mod:Reset()
                self:refreshSettingsPanel()
            elseif i == 4 then
                self.selectedModule = mod
                self:refreshModules()
                self:refreshSettingsPanel()
            end
            menu:Destroy()
            self.contextMenu = nil
        end)
    end
    
    menu.Size = UDim2.new(0, 140, 0, #items * 28 + 8)
    self.contextMenu = menu
    
    -- Close on click outside the menu
    task.delay(0.1, function()
        if not menu.Parent then return end
        local closeConn
        closeConn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouseLoc = UserInputService:GetMouseLocation()
                local guiInset = GuiService:GetGuiInset()
                local pos = Vector2.new(mouseLoc.X, mouseLoc.Y - guiInset.Y)
                local mp, ms = menu.AbsolutePosition, menu.AbsoluteSize
                local inside = pos.X >= mp.X and pos.X <= mp.X + ms.X
                    and pos.Y >= mp.Y and pos.Y <= mp.Y + ms.Y
                if not inside and menu and menu.Parent then
                    menu:Destroy()
                    self.contextMenu = nil
                end
            end
        end)
        menu.Destroying:Connect(function()
            if closeConn then
                closeConn:Disconnect()
                closeConn = nil
            end
        end)
    end)
end

function UI:createSettingsPanel()
    local panel = Instance.new("Frame")
    panel.Name = "SettingsPanel"
    panel.Size = UDim2.new(0, Theme.SettingsPanelWidth, 1, 0)
    panel.Position = UDim2.new(1, -Theme.SettingsPanelWidth, 0, 0)
    panel.BackgroundColor3 = Theme.Surface
    panel.BorderSizePixel = 0
    panel.Parent = self.modulesPage
    createStroke(panel, Theme.Border, 1)
    self.settingsPanel = panel
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = panel
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = panel
    self.settingsPanelLayout = layout
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 56)
    header.BackgroundTransparency = 1
    header.LayoutOrder = 0
    header.Parent = panel
    
    local moduleName = createText(header, "", 13, Theme.Text, Theme.FontMedium, Enum.TextXAlignment.Left)
    moduleName.Size = UDim2.new(1, -70, 0, 18)
    moduleName.Position = UDim2.new(0, 0, 0, 6)
    self.settingsModuleName = moduleName
    
    local moduleDesc = createText(header, "", 10, Theme.TextMuted, Theme.Font, Enum.TextXAlignment.Left)
    moduleDesc.Size = UDim2.new(1, -14, 0, 14)
    moduleDesc.Position = UDim2.new(0, 0, 0, 26)
    moduleDesc.TextWrapped = true
    self.settingsModuleDesc = moduleDesc
    
    -- Right controls
    local rightControls = Instance.new("Frame")
    rightControls.Name = "RightControls"
    rightControls.Size = UDim2.new(0, 56, 0, 28)
    rightControls.Position = UDim2.new(1, -56, 0, 8)
    rightControls.BackgroundTransparency = 1
    rightControls.Parent = header
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.FillDirection = Enum.FillDirection.Horizontal
    rightLayout.Padding = UDim.new(0, 4)
    rightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    rightLayout.Parent = rightControls
    
    -- Star button
    local starBtn = Instance.new("TextButton")
    starBtn.Name = "StarBtn"
    starBtn.Size = UDim2.new(0, 24, 0, 24)
    starBtn.BackgroundTransparency = 1
    starBtn.AutoButtonColor = false
    starBtn.Text = ""
    starBtn.LayoutOrder = 1
    starBtn.Parent = rightControls
    self.settingsStarBtn = starBtn
    
    local starIcon = Icons.Icon("Star", 15)
    starIcon.Size = UDim2.new(0, 15, 0, 15)
    starIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    starIcon.Parent = starBtn
    self.settingsStarIcon = starIcon
    
    self._starConn = nil
    self._toggleConn = nil
    
    -- Enabled toggle
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 32, 0, 18)
    toggleBtn.BackgroundColor3 = Theme.ToggleOff
    toggleBtn.BorderSizePixel = 0
    toggleBtn.AutoButtonColor = false
    toggleBtn.Text = ""
    toggleBtn.LayoutOrder = 2
    toggleBtn.Parent = rightControls
    createCorner(toggleBtn, 9)
    self.settingsToggleBtn = toggleBtn
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 14, 0, 14)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -7)
    toggleKnob.BackgroundColor3 = Theme.SliderHandle
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBtn
    createCorner(toggleKnob, 7)
    self.settingsToggleKnob = toggleKnob
    
    self._starConn = starBtn.MouseButton1Click:Connect(function()
        local current = self.selectedModule
        if current then
            current:SetFavorite(not current.Favorite)
            self:refreshSettingsPanel()
            self:refreshModules()
        end
    end)
    
    self._toggleConn = toggleBtn.MouseButton1Click:Connect(function()
        local current = self.selectedModule
        if current then
            current:SetEnabled(not current.Enabled)
            self.settingsToggleBtn.BackgroundColor3 = current.Enabled and Theme.ToggleOn or Theme.ToggleOff
            TweenService:Create(self.settingsToggleKnob, Theme.FastTween, {
                Position = UDim2.new(current.Enabled and 1 or 0, current.Enabled and -16 or 2, 0.5, -7)
            }):Play()
            self:refreshModules()
        end
    end)
    
    -- Settings scroll
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "SettingsList"
    scroll.Size = UDim2.new(1, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.AccentDim
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticSize = Enum.AutomaticSize.Y
    scroll.LayoutOrder = 1
    scroll.Parent = panel
    
    local scrollPadding = Instance.new("UIPadding")
    scrollPadding.PaddingTop = UDim.new(0, 4)
    scrollPadding.PaddingBottom = UDim.new(0, 4)
    scrollPadding.PaddingLeft = UDim.new(0, 0)
    scrollPadding.PaddingRight = UDim.new(0, 0)
    scrollPadding.Parent = scroll
    
    local layout2 = createListLayout(scroll, 3)
    self.settingsLayout = layout2
    self.settingsScroll = scroll
    
    -- Empty state
    local empty = createText(scroll, "Select a module to view its settings", 11, Theme.TextMuted, Theme.Font, Enum.TextXAlignment.Center)
    empty.Size = UDim2.new(1, 0, 1, 0)
    empty.Name = "EmptyState"
    self.settingsEmpty = empty
end

function UI:refreshSettingsPanel()
    if not self.settingsScroll then return end
    
    -- Clear existing controls
    for _, child in ipairs(self.settingsScroll:GetChildren()) do
        if child ~= self.settingsEmpty and child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local mod = self.selectedModule
    
    if not mod then
        self.settingsEmpty.Visible = true
        self.settingsModuleName.Text = ""
        self.settingsModuleDesc.Text = ""
        return
    end
    
    self.settingsEmpty.Visible = false
    self.settingsModuleName.Text = mod.Name
    self.settingsModuleDesc.Text = mod.Description
    
    -- Update star
    if self.settingsStarIcon then
        self.settingsStarIcon:Destroy()
    end
    local starIcon = mod.Favorite and Icons.Icon("StarFilled", 16, Theme.Accent) or Icons.Icon("Star", 16)
    starIcon.Size = UDim2.new(0, 16, 0, 16)
    starIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    starIcon.Parent = self.settingsStarBtn
    self.settingsStarIcon = starIcon
    
    -- Update toggle
    self.settingsToggleBtn.BackgroundColor3 = mod.Enabled and Theme.ToggleOn or Theme.ToggleOff
    self.settingsToggleKnob.Position = UDim2.new(mod.Enabled and 1 or 0, mod.Enabled and -16 or 2, 0.5, -7)
    
    -- Create setting controls
    for _, sName in ipairs(mod._settingOrder) do
        local setting = mod.Settings[sName]
        if setting then
            local control = self:createSettingControl(setting, mod)
            if control then
                control.Parent = self.settingsScroll
            end
        end
    end
end

function UI:createSettingControl(setting, mod)
    local ctrl = nil
    
    if setting.Type == "Toggle" then
        ctrl = Controls.CreateToggle(self.settingsScroll, setting.Name, setting.Value, function(val)
            setting.Value = val
            if setting.Callback then safeCall(setting.Callback, val) end
        end)
        
    elseif setting.Type == "Slider" then
        ctrl = Controls.CreateSlider(self.settingsScroll, setting.Name, {
            Min = setting.Min, Max = setting.Max, Default = setting.Value, Decimals = setting.Decimals
        }, function(val)
            setting.Value = val
            if setting.Callback then safeCall(setting.Callback, val) end
        end)
        
    elseif setting.Type == "Dropdown" then
        ctrl = Controls.CreateDropdown(self.settingsScroll, setting.Name, {
            Options = setting.Options, Default = setting.Value
        }, function(val)
            setting.Value = val
            if setting.Callback then safeCall(setting.Callback, val) end
        end)
        
    elseif setting.Type == "MultiDropdown" then
        ctrl = Controls.CreateMultiDropdown(self.settingsScroll, setting.Name, {
            Options = setting.Options, Default = setting.Value
        }, function(vals)
            setting.Value = vals
            if setting.Callback then safeCall(setting.Callback, vals) end
        end)
        
    elseif setting.Type == "Keybind" then
        ctrl = Controls.CreateKeybind(self.settingsScroll, setting.Name, {
            Default = setting.Value
        }, function(val)
            setting.Value = val
            mod.Keybind = val
            if setting.Callback then safeCall(setting.Callback, val) end
        end)
        
    elseif setting.Type == "ColorPicker" then
        ctrl = Controls.CreateColorPicker(self.settingsScroll, setting.Name, {
            Default = setting.Value
        }, function(val)
            setting.Value = val
            if setting.Callback then safeCall(setting.Callback, val) end
        end)
        
    elseif setting.Type == "Button" then
        ctrl = Controls.CreateButton(self.settingsScroll, setting.Name, function()
            if setting.Callback then safeCall(setting.Callback) end
        end)
        
    elseif setting.Type == "Textbox" then
        ctrl = Controls.CreateTextbox(self.settingsScroll, setting.Name, {
            Default = setting.Value, Placeholder = setting.Placeholder
        }, function(val)
            setting.Value = val
            if setting.Callback then safeCall(setting.Callback, val) end
        end)
        
    elseif setting.Type == "Section" then
        ctrl = Controls.CreateSection(self.settingsScroll, setting.Name)
        
    elseif setting.Type == "Label" then
        ctrl = Controls.CreateLabel(self.settingsScroll, setting.Name)
    end
    
    return ctrl
end

function UI:createConfigPage()
    local page = Instance.new("Frame")
    page.Name = "ConfigPage"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.pageContainer
    self.configPage = page
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    header.Parent = page
    
    -- Back button
    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0, 80, 0, 32)
    backBtn.Position = UDim2.new(0, 12, 0, 9)
    backBtn.BackgroundColor3 = Theme.Surface
    backBtn.BorderSizePixel = 0
    backBtn.AutoButtonColor = false
    backBtn.Text = ""
    backBtn.Parent = header
    createCorner(backBtn, 6)
    
    local backIcon = Icons.Icon("ArrowLeft", 14)
    backIcon.Size = UDim2.new(0, 14, 0, 14)
    backIcon.Position = UDim2.new(0, 8, 0.5, -7)
    backIcon.Parent = backBtn
    
    local backLabel = createText(backBtn, "Back", 12, Theme.TextSecondary, Theme.FontMedium, Enum.TextXAlignment.Left)
    backLabel.Size = UDim2.new(1, -30, 1, 0)
    backLabel.Position = UDim2.new(0, 26, 0, 0)
    
    backBtn.MouseEnter:Connect(function()
        TweenService:Create(backBtn, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceHover}):Play()
    end)
    backBtn.MouseLeave:Connect(function()
        TweenService:Create(backBtn, Theme.FastTween, {BackgroundColor3 = Theme.Surface}):Play()
    end)
    backBtn.MouseButton1Click:Connect(function()
        self:showPage("Modules")
    end)
    
    -- Title
    local title = createText(header, "Config Manager", 16, Theme.Text, Theme.FontBold, Enum.TextXAlignment.Left)
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 100, 0, 0)
    
    -- Search and create
    local toolbar = Instance.new("Frame")
    toolbar.Size = UDim2.new(1, -24, 0, 32)
    toolbar.Position = UDim2.new(0, 12, 0, 56)
    toolbar.BackgroundTransparency = 1
    toolbar.Parent = page
    
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(0.6, -8, 1, 0)
    searchFrame.BackgroundColor3 = Theme.Surface
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = toolbar
    createCorner(searchFrame, 8)
    createStroke(searchFrame, Theme.Border, 1)
    
    local searchIcon = Icons.Icon("Search", 14)
    searchIcon.Size = UDim2.new(0, 14, 0, 14)
    searchIcon.Position = UDim2.new(0, 10, 0.5, -7)
    searchIcon.Parent = searchFrame
    
    local configSearch = Instance.new("TextBox")
    configSearch.Size = UDim2.new(1, -36, 1, 0)
    configSearch.Position = UDim2.new(0, 30, 0, 0)
    configSearch.BackgroundTransparency = 1
    configSearch.Text = ""
    configSearch.PlaceholderText = "Search configs..."
    configSearch.PlaceholderColor3 = Theme.TextMuted
    configSearch.TextColor3 = Theme.Text
    configSearch.TextSize = 12
    configSearch.Font = Theme.Font
    configSearch.TextXAlignment = Enum.TextXAlignment.Left
    configSearch.ClearTextOnFocus = false
    configSearch.Parent = searchFrame
    
    local createBtn = Instance.new("TextButton")
    createBtn.Size = UDim2.new(0.4, -8, 1, 0)
    createBtn.Position = UDim2.new(0.6, 4, 0, 0)
    createBtn.BackgroundColor3 = Theme.Accent
    createBtn.BorderSizePixel = 0
    createBtn.AutoButtonColor = false
    createBtn.Text = "+ Create Config"
    createBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    createBtn.TextSize = 12
    createBtn.Font = Theme.FontMedium
    createBtn.Parent = toolbar
    createCorner(createBtn, 8)
    
    createBtn.MouseEnter:Connect(function()
        TweenService:Create(createBtn, Theme.FastTween, {BackgroundColor3 = Theme.AccentHover}):Play()
    end)
    createBtn.MouseLeave:Connect(function()
        TweenService:Create(createBtn, Theme.FastTween, {BackgroundColor3 = Theme.Accent}):Play()
    end)
    createBtn.MouseButton1Click:Connect(function()
        self:showCreateConfigModal()
    end)
    
    -- Config list
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "ConfigList"
    scroll.Size = UDim2.new(1, -24, 1, -100)
    scroll.Position = UDim2.new(0, 12, 0, 94)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.AccentDim
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticSize = Enum.AutomaticSize.Y
    scroll.Parent = page
    
    local layout = createListLayout(scroll, 6)
    self.configListScroll = scroll
    self.configSearch = configSearch
    
    configSearch:GetPropertyChangedSignal("Text"):Connect(function()
        self:refreshConfigList()
    end)
    
    self:refreshConfigList()
end

function UI:refreshConfigList()
    if not self.configListScroll then return end
    
    for _, child in ipairs(self.configListScroll:GetChildren()) do
        if child:IsA("Frame") and child.Name == "ConfigCard" then
            child:Destroy()
        end
    end
    
    local configs = _getInstance()._config:List() or {}
    local searchTerm = (self.configSearch and self.configSearch.Text or ""):lower()
    
    if searchTerm ~= "" then
        local filtered = {}
        for _, name in ipairs(configs) do
            if name:lower():find(searchTerm, 1, true) then
                filtered[#filtered + 1] = name
            end
        end
        configs = filtered
    end
    
    table.sort(configs)
    
    for i, name in ipairs(configs) do
        self:createConfigCard(name, i)
    end
end

function UI:createConfigCard(name, index)
    local card = Instance.new("Frame")
    card.Name = "ConfigCard"
    card.Size = UDim2.new(1, 0, 0, 64)
    card.BackgroundColor3 = Theme.Surface
    card.BorderSizePixel = 0
    card.LayoutOrder = index
    card.Parent = self.configListScroll
    createCorner(card, 8)
    createStroke(card, Theme.Border, 1)
    
    -- Name
    local nameLabel = createText(card, name, 13, Theme.Text, Theme.FontMedium, Enum.TextXAlignment.Left)
    nameLabel.Size = UDim2.new(0.5, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 14, 0, 12)
    
    -- Description
    local descLabel = createText(card, "Saved configuration", 11, Theme.TextMuted, Theme.Font, Enum.TextXAlignment.Left)
    descLabel.Size = UDim2.new(0.5, 0, 0, 14)
    descLabel.Position = UDim2.new(0, 14, 0, 32)
    
    -- Menu button
    local menuBtn = Instance.new("TextButton")
    menuBtn.Size = UDim2.new(0, 24, 0, 24)
    menuBtn.Position = UDim2.new(1, -30, 0.5, -12)
    menuBtn.BackgroundTransparency = 1
    menuBtn.AutoButtonColor = false
    menuBtn.Text = ""
    menuBtn.Parent = card
    createCorner(menuBtn, 5)
    
    local menuIcon = Icons.Icon("MoreVertical", 14)
    menuIcon.Size = UDim2.new(0, 14, 0, 14)
    menuIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    menuIcon.Parent = menuBtn
    
    -- Load button
    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0, 50, 0, 24)
    loadBtn.Position = UDim2.new(1, -150, 0.5, -12)
    loadBtn.BackgroundColor3 = Theme.Accent
    loadBtn.BorderSizePixel = 0
    loadBtn.AutoButtonColor = false
    loadBtn.Text = "Load"
    loadBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    loadBtn.TextSize = 11
    loadBtn.Font = Theme.FontMedium
    loadBtn.Parent = card
    createCorner(loadBtn, 6)
    
    loadBtn.MouseButton1Click:Connect(function()
        local inst = _getInstance()
        local data = inst._config:Load(name)
        if data then
            inst._config:Apply(data)
            inst._notifications:Notify("Config", "Loaded " .. name, "success")
        else
            inst._notifications:Notify("Config", "Failed to load " .. name, "error")
        end
    end)
    
    -- Save button
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 50, 0, 24)
    saveBtn.Position = UDim2.new(1, -95, 0.5, -12)
    saveBtn.BackgroundColor3 = Theme.SurfaceLight
    saveBtn.BorderSizePixel = 0
    saveBtn.AutoButtonColor = false
    saveBtn.Text = "Save"
    saveBtn.TextColor3 = Theme.Text
    saveBtn.TextSize = 11
    saveBtn.Font = Theme.FontMedium
    saveBtn.Parent = card
    createCorner(saveBtn, 6)
    createStroke(saveBtn, Theme.Border, 1)
    
    saveBtn.MouseButton1Click:Connect(function()
        local inst = _getInstance()
        if inst._config:Save(name) then
            inst._notifications:Notify("Config", "Saved " .. name, "success")
        else
            inst._notifications:Notify("Config", "Failed to save " .. name, "error")
        end
    end)
    
    -- Hover
    card.MouseEnter:Connect(function()
        TweenService:Create(card, Theme.FastTween, {BackgroundColor3 = Theme.SurfaceHover}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, Theme.FastTween, {BackgroundColor3 = Theme.Surface}):Play()
    end)
end

function UI:showCreateConfigModal()
    if self.createModal then
        self.createModal:Destroy()
    end
    
    local overlay = Instance.new("Frame")
    overlay.Name = "ModalOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 500
    overlay.Parent = self.configPage
    
    local modal = Instance.new("Frame")
    modal.Name = "CreateModal"
    modal.Size = UDim2.new(0, 320, 0, 150)
    modal.Position = UDim2.new(0.5, -160, 0.5, -75)
    modal.BackgroundColor3 = Theme.Surface
    modal.BorderSizePixel = 0
    modal.ZIndex = 501
    modal.Parent = overlay
    createCorner(modal, 10)
    createStroke(modal, Theme.Border, 1)
    
    local title = createText(modal, "Create Config", 14, Theme.Text, Theme.FontBold, Enum.TextXAlignment.Left)
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 14, 0, 14)
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -28, 0, 32)
    input.Position = UDim2.new(0, 14, 0, 46)
    input.BackgroundColor3 = Theme.SurfaceLight
    input.BorderSizePixel = 0
    input.Text = ""
    input.PlaceholderText = "Config Name"
    input.PlaceholderColor3 = Theme.TextMuted
    input.TextColor3 = Theme.Text
    input.TextSize = 12
    input.Font = Theme.Font
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.ZIndex = 502
    input.Parent = modal
    createCorner(input, 6)
    createStroke(input, Theme.Border, 1)
    createPadding(input, 0, 0, 10, 10)
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 80, 0, 30)
    cancelBtn.Position = UDim2.new(1, -180, 1, -44)
    cancelBtn.BackgroundColor3 = Theme.SurfaceLight
    cancelBtn.BorderSizePixel = 0
    cancelBtn.AutoButtonColor = false
    cancelBtn.Text = "Cancel"
    cancelBtn.TextColor3 = Theme.TextSecondary
    cancelBtn.TextSize = 12
    cancelBtn.Font = Theme.FontMedium
    cancelBtn.ZIndex = 502
    cancelBtn.Parent = modal
    createCorner(cancelBtn, 6)
    createStroke(cancelBtn, Theme.Border, 1)
    
    local createBtn = Instance.new("TextButton")
    createBtn.Size = UDim2.new(0, 80, 0, 30)
    createBtn.Position = UDim2.new(1, -90, 1, -44)
    createBtn.BackgroundColor3 = Theme.Accent
    createBtn.BorderSizePixel = 0
    createBtn.AutoButtonColor = false
    createBtn.Text = "Create"
    createBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    createBtn.TextSize = 12
    createBtn.Font = Theme.FontMedium
    createBtn.ZIndex = 502
    createBtn.Parent = modal
    createCorner(createBtn, 6)
    
    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
        self.createModal = nil
    end)
    
    createBtn.MouseButton1Click:Connect(function()
        local name = input.Text
        local inst = _getInstance()
        if name == "" then
            inst._notifications:Notify("Config", "Name cannot be empty", "error")
            return
        end
        if name:match("[/\\<>:\"|?*]") or name:find("%.%.") then
            inst._notifications:Notify("Config", "Invalid characters in name", "error")
            return
        end
        if #name > 50 then
            inst._notifications:Notify("Config", "Name too long", "error")
            return
        end
        if inst._config:Exists(name) then
            inst._notifications:Notify("Config", "Config already exists", "error")
            return
        end
        if inst._config:Create(name) then
            inst._notifications:Notify("Config", "Created " .. name, "success")
            self:refreshConfigList()
            overlay:Destroy()
            self.createModal = nil
        else
            inst._notifications:Notify("Config", "Failed to create config", "error")
        end
    end)
    
    self.createModal = overlay
end

function UI:showPage(pageName)
    if self.modulesPage then self.modulesPage.Visible = (pageName == "Modules") end
    if self.configPage then self.configPage.Visible = (pageName == "Config") end
end

function UI:toggleMinimized()
    self.isMinimized = not self.isMinimized
    if self.isMinimized then
        TweenService:Create(self.mainWindow, Theme.TweenInfo, {
            Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.TopBarHeight)
        }):Play()
    else
        TweenService:Create(self.mainWindow, Theme.TweenInfo, {
            Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight)
        }):Play()
    end
end

function UI:makeDraggable()
    local dragging = false
    local dragStart, startPos
    
    self.topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainWindow.Position
        end
    end)
    
    local conn = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.mainWindow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    self.connections[#self.connections + 1] = conn
    
    local conn2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    self.connections[#self.connections + 1] = conn2
end

function UI:close()
    for _, conn in ipairs(self.connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    self.connections = {}
    if self.screen then
        self.screen:Destroy()
    end
    self.screen = nil
end

--------------------------------------------------------------------------------
-- MAIN IMPULSE API
--------------------------------------------------------------------------------
function Impulse.new()
    local self = setmetatable({}, Impulse)
    self._registry = {
        modules = {},
        categories = {},
    }
    self._config = ConfigService.new()
    self._notifications = NotificationService.new()
    self._ui = nil
    return self
end

function Impulse:_createWindow(config)
    config = config or {}
    self._ui = UI.new()
    self._ui:Init()
    return self._ui
end

function Impulse:_createModule(name, options)
    if self._registry.categories[name] then
        return self._registry.categories[name]
    end
    local tab = ModuleTab.new(name, options)
    self._registry.categories[name] = tab
    if self._ui then
        self._ui:refreshSidebar()
    end
    return tab
end

function Impulse:_getModule(name)
    return self._registry.modules[name]
end

function Impulse:_getModules()
    return self._registry.modules
end

function Impulse:_getCategory(name)
    return self._registry.categories[name]
end

function Impulse:_getCategories()
    return self._registry.categories
end

function Impulse:_destroyModule(name)
    local mod = self._registry.modules[name]
    if mod then
        mod:Destroy()
    end
end

function Impulse:_destroyCategory(name)
    local cat = self._registry.categories[name]
    if cat then
        for modName, mod in pairs(cat.Modules) do
            mod:Destroy()
        end
        self._registry.categories[name] = nil
    end
end

function Impulse:_getConfig()
    return self._config
end

function Impulse:_getNotifications()
    return self._notifications
end

-- Global singleton
local defaultInstance = Impulse.new()
_defaultInstance = defaultInstance
Impulse._default = defaultInstance

-- Module-level API functions
function Impulse.CreateModule(name, options)
    return defaultInstance:_createModule(name, options)
end

function Impulse.GetModule(name)
    return defaultInstance:_getModule(name)
end

function Impulse.GetModules()
    return defaultInstance:_getModules()
end

function Impulse.GetCategory(name)
    return defaultInstance:_getCategory(name)
end

function Impulse.GetCategories()
    return defaultInstance:_getCategories()
end

function Impulse.DestroyModule(name)
    defaultInstance:_destroyModule(name)
end

function Impulse.DestroyCategory(name)
    defaultInstance:_destroyCategory(name)
end

function Impulse.CreateWindow(config)
    return defaultInstance:_createWindow(config)
end

function Impulse.GetConfig()
    return defaultInstance:_getConfig()
end

function Impulse.GetNotifications()
    return defaultInstance:_getNotifications()
end

return Impulse
