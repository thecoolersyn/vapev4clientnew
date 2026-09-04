RunService = game:GetService("RunService")
Players = game:GetService("Players")
UserInputService = game:GetService("UserInputService")
Stats = game:GetService("Stats")
HttpService = game:GetService("HttpService")
Debris = game:GetService("Debris")
Lighting = game:GetService("Lighting")
ReplicatedStorage = game:GetService("ReplicatedStorage")
TeleportService = game:GetService("TeleportService")
CollectionService = game:GetService("CollectionService")
TweenService = pcall(function() return game:GetService("TweenService") end) and game:GetService("TweenService") or nil

-- External Enum Source
local EnumSource = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/thecoolersyn/enum/refs/heads/main/enum.lua"))()
end)
local KeyCode = EnumSource and EnumSource or Enum.KeyCode

-- Block keybind detection
local function detectBlockKeybind()
    local ok, Replion = pcall(function()
        return ReplicatedStorage.Packages:FindFirstChild("Replion")
    end)
    if not ok or not Replion then return Enum.KeyCode.Equals end
    
    local ok2, mod = pcall(require, Replion)
    if not ok or type(mod) ~= "table" then return Enum.KeyCode.Equals end
    
    local ok2, data = pcall(function()
        return mod.Client:GetReplion("Data")
    end)
    if not ok2 or not data then return Enum.KeyCode.Equals end
    
    local ok3, block = pcall(function()
        return data.Data.Settings.Keybinds.Block
    end)
    if not ok3 or not block then return Enum.KeyCode.Equals end
    
    -- Check PC binds first
    if block.PC and block.PC.Bind1 and block.PC.Bind1 ~= "" then
        local keyName = block.PC.Bind1
        if Enum.KeyCode[keyName] then
            return Enum.KeyCode[keyName]
        end
    end
    
    -- Check Console binds
    if block.Console then
        for _, bind in ipairs({block.Console.Bind1, block.Console.Bind2, block.Console.Bind3}) do
            if bind and bind ~= "" and Enum.KeyCode[bind] then
                return Enum.KeyCode[bind]
            end
        end
    end
    
    return Enum.KeyCode.Equals
end

local BlockKeybind = detectBlockKeybind()

Player = Players.LocalPlayer
PlayerGui = Player:WaitForChild("PlayerGui")

LocalPlayer = Player
Alive = workspace:FindFirstChild("Alive")

STATUS_BRAND = "Hyperion"
UI = "Hyperion-V2"
Version = "HYP-V2"
Module = "HYPERION"
SWORD_REPO = "https://raw.githubusercontent.com/x-l-v/Blade-Ball-Sword/refs/heads/main/"
SWORD_LIST_URL = SWORD_REPO .. "sword.lua"
HYPERION_VERSION_URL = SWORD_REPO .. "version.lua"
DISCORD_INVITE = "https://discord.gg/6gdXU6ZKT"
BANNED_HWIDS_URL = "https://raw.githubusercontent.com/x-l-v/hwid/refs/heads/main/hwid.txt"
DEV_USERS_URL = "https://raw.githubusercontent.com/x-l-v/hwid/refs/heads/main/dev.txt"
CustomIconFallback = "rbxassetid://72109545964414"

-- Configuration (user-configurable values)
local Config = {
    -- Discord webhook URL for HWID ban notifications
    -- NOTE: Replace with your own webhook URL or leave empty to disable
    WebhookUrl = "",
    
    -- Target user for identity spoofer (0 = disabled)
    SpoofUserId = 0,
    SpoofUsername = "",
    SpoofDisplayName = "",
}

-- Load config from file if it exists
pcall(function()
    if isfile and isfile("hyperion_config.json") then
        local data = readfile("hyperion_config.json")
        local decoded = HttpService:JSONDecode(data)
        if decoded.WebhookUrl then Config.WebhookUrl = decoded.WebhookUrl end
        if decoded.SpoofUserId then Config.SpoofUserId = decoded.SpoofUserId end
        if decoded.SpoofUsername then Config.SpoofUsername = decoded.SpoofUsername end
        if decoded.SpoofDisplayName then Config.SpoofDisplayName = decoded.SpoofDisplayName end
    end
end)

function RunHWIDBlocker()
	local hwid = "unknown"
	local ok, hw = pcall(gethwid)
	if ok then hwid = tostring(hw) end

	local execName = "unknown"
	local ok2, name = pcall(identifyexecutor)
	if ok2 then execName = tostring(name) end

	if ok2 then
		local lowerName = name:lower()
		if lowerName:find("xeno") or lowerName:find("solara") or lowerName:find("luna") then
			Players.LocalPlayer:Kick("Executor Missmatch | ".. tostring(math.random(100000, 999999)))
			return true
		end
	end

	local success, bannedList = pcall(game.HttpGet, game, BANNED_HWIDS_URL)
	if success and type(bannedList) == "string" and bannedList ~= "" then
		for line in bannedList:gmatch("[^\r\n]+") do
			local trimmed = line:match("^%s*(.-)%s*$")
			if trimmed ~= "" and trimmed == hwid then
				local payload = {
					embeds = {{
						title = "HWID Banned",
						color = 16711680,
						fields = {
							{name = "Time", value = os.date("%Y-%m-%d %H:%M:%S"), inline = true},
							{name = "Username", value = "||" .. Player.Name .. " (" .. Player.DisplayName .. ")||", inline = false},
							{name = "HWID", value = hwid, inline = false},
							{name = "Executor", value = execName, inline = false}
						},
						footer = {text = "Hyperion"}
					}}
				}
				local req = request or ((syn and syn.request) and syn.request) or http_request
				if type(req) == "function" and Config.WebhookUrl ~= "" then
					pcall(req, {
						Url = Config.WebhookUrl,
						Method = "POST",
						Headers = {["Content-Type"] = "application/json"},
						Body = HttpService:JSONEncode(payload)
					})
				end
				task.wait(0.5)
				Players.LocalPlayer:Kick("HWID Banned")
				return true
			end
		end
	end

	return false
end

RunHWIDBlocker()

function GetCustomIcon()
	if typeof(getcustomasset) == "function" and CustomIconFile ~= "" then
		local v2, asset = pcall(getcustomasset, CustomIconFile)
		if v2 and type(asset) == "string" and asset ~= "" then
			return asset
		end
	end

	return CustomIconFallback
end

CustomIcon = GetCustomIcon()
TabIcons = {
	Combat = "rbxassetid://10734975692",
	AI = "rbxassetid://10709782230",
	Visuals = "rbxassetid://10723346959",
	Changer = "rbxassetid://10709782497",
	Misc = "rbxassetid://10734950309",
	GUI = "rbxassetid://10734950309"
}

HyperionGuiRoot = PlayerGui:FindFirstChild("RobloxGui")

function HttpGetContent(Url)
	local v2, result = pcall(function()
		return game:HttpGet(Url, true)
	end)

	if v2 and type(result) == "string" and result ~= "" then
		return result
	end

	requestFunction = request or ((syn and syn.request) and syn.request) or http_request

	if type(requestFunction) == "function" then
		local ok, response = pcall(requestFunction, {
			Url = Url,
			Method = "GET"
		})

		if ok and type(response) == "table" then
			local body = response.Body or response.body

			if type(body) == "string" and body ~= "" then
				return body
			end
		end
	end

	return ""
end

function ParseVersionInfo(RawContent)
	if type(RawContent) ~= "string" then
		return {}
	end

	return {
		UI = RawContent:match("UI%s*=%s*[\"']([^\"']+)[\"']") or "",
		Version = RawContent:match("Version%s*=%s*[\"']([^\"']+)[\"']") or "",
		Module = RawContent:match("Module%s*=%s*[\"']([^\"']+)[\"']") or ""
	}
end

function ValidateVersion()
	local RemoteVersionContent = HttpGetContent(HYPERION_VERSION_URL)

	if RemoteVersionContent == "" then
		return true
	end

	local remote = ParseVersionInfo(RemoteVersionContent)

	if remote.UI ~= "" and remote.Version ~= "" and remote.Module ~= ""
		and (remote.UI ~= UI or remote.Version ~= Version or remote.Module ~= Module) then
		Player:Kick("Module Version Missmatch | " .. tostring(math.random(100000, 999999)))
		return false
	end

	return true
end

if not ValidateVersion() then
	return
end

if not HyperionGuiRoot then
	HyperionGuiRoot = Instance.new("ScreenGui")
	HyperionGuiRoot.Name = "RobloxGui"
	HyperionGuiRoot.ResetOnSpawn = false
	HyperionGuiRoot.Parent = PlayerGui
end
pcall(function()
	HyperionGuiRoot.DisplayOrder = 100
end)

-- =============================================================================
-- VAPE UI (Impulse) — replaces the external Frost library entirely.
-- The Impulse framework is loaded and exposed as HyperionLibrary so the rest
-- of the Hyperion script can drive it through the same compat layer.
-- =============================================================================
local VAPE_SRC_URL = "https://raw.githubusercontent.com/thecoolersyn/vapev4clientnew/refs/heads/main/src.lua"
local VAPE_SRC_LOCAL = "vapev4clientnew/src.lua"

local function LoadVapeLibrary()
    local source = nil
    if type(readfile) == "function" and type(isfile) == "function" and isfile(VAPE_SRC_LOCAL) then
        local okRead, content = pcall(readfile, VAPE_SRC_LOCAL)
        if okRead and type(content) == "string" and #content > 100 then
            source = content
        end
    end
    if not source then
        local okHttp, content = pcall(function()
            return game:HttpGet(VAPE_SRC_URL, true)
        end)
        if okHttp and type(content) == "string" and #content > 100 then
            source = content
        end
    end
    if not source then
        return nil, "vape src.lua unavailable"
    end

    local fn, compileErr = loadstring(source)
    if type(fn) ~= "function" then
        return nil, "compile failed: " .. tostring(compileErr)
    end

    local okRun, result = pcall(fn)
    if not okRun then
        return nil, "runtime failed: " .. tostring(result)
    end
    if type(result) ~= "table" then
        return nil, "did not return a table"
    end
    return result
end

local okLib, HyperionLibrary = pcall(LoadVapeLibrary)
if not okLib or type(HyperionLibrary) ~= "table" then
    warn("[Hyperion] Vape (Impulse) UI failed to load: " .. tostring(HyperionLibrary))
    return
end

-- The Impulse framework stores its config in a global singleton; make sure a
-- fresh Hyperion run starts from a clean registry.
pcall(function()
    if HyperionLibrary._default and HyperionLibrary._default._registry then
        HyperionLibrary._default._registry.modules = {}
        HyperionLibrary._default._registry.categories = {}
    end
end)

if type(cloneref) ~= "function" then
    cloneref = function(a) return a end
end

-- Frost removed: EnsureHyperionConfig is no longer needed (Impulse has its own config).
function EnsureHyperionConfig() end

function SafeToNumber(value, DefaultValue)
	local v11 = tonumber(value)

	if v11 == nil then
		return DefaultValue
	end

	return v11
end

function SanitizeFlagName(value)
	return tostring(value or "item"):gsub("%W+", "_")
end

function NormalizeLabel(value)
	return tostring(value or ""):lower():gsub("%W+", "")
end

function ShouldPromoteModuleToggle(moduleTitle, ToggleLabel)
	local NormalizedModule = NormalizeLabel(moduleTitle)
	local NormalizedToggle = NormalizeLabel(ToggleLabel)

	if NormalizedModule == "" or NormalizedToggle == "" then
		return false
	end

	return NormalizedModule == NormalizedToggle
		or string.find(NormalizedToggle, NormalizedModule, 1, true) ~= nil
		or string.find(NormalizedModule, NormalizedToggle, 1, true) ~= nil
end

Num = SafeToNumber
SanitizeFlag = SanitizeFlagName
NormalizeLabel = NormalizeLabel
ShouldPromoteModuleToggle = ShouldPromoteModuleToggle

function FormatIconAsset(value)
	value = tostring(value or "")

	if value == "" then
		return nil
	end

	if tonumber(value) then
		return "rbxassetid://" .. value
	end

	return value
end

-- =============================================================================
-- CreateVapeCompat: maps the Hyperion / Frost UI API onto the Impulse (Vape)
-- UI framework.  Frost's tab/module/toggle/slider/dropdown/input/button API
-- is preserved identically so that all Hyperion game-logic code works without
-- modification.  Frost-specific calls (EnsureHyperionConfig, change_state on
-- Frost modules, Frost.new / create_tab / create_module, _config._flags,
-- UIAccent, SetProfile, RunJunkieKeyValidation, IconAnimated) are safely
-- stubbed or routed to the equivalent Impulse functionality.
-- =============================================================================
	-- Rebuilds an Impulse dropdown setting in place (options changed at runtime).
	function RebuildVapeDropdown(dropdownRef, options, default, callback)
		if not dropdownRef or type(dropdownRef) ~= "table" or not dropdownRef.module then return end
		local mod = dropdownRef.module
		local title = dropdownRef.title
		-- Remove old setting
		if mod.Settings then
			mod.Settings[title] = nil
		end
		if mod._settingOrder then
			for i, name in ipairs(mod._settingOrder) do
				if name == title then
					table.remove(mod._settingOrder, i)
					break
				end
			end
		end
		-- Re-add with new options
		mod:AddDropdown(title, {
			Options = options or {},
			Default = default ~= nil and tostring(default) or nil,
			Callback = callback or function() end,
		})
		-- Refresh the panel if open
		pcall(function()
			local ui = HyperionLibrary._default._ui
			if ui and ui.refreshSettingsPanel then ui:refreshSettingsPanel() end
		end)
		return dropdownRef
	end

	function CreateVapeCompat()
	local compat = { _window = nil, _groupCounter = 0 }

	-- Forward-declared for recursion in primary toggle helpers
	local WrapModule
	local WrapTab

	-- ── WrapModule ──────────────────────────────────────────────────────────
	WrapModule = function(module, moduleTitle, setPrimaryToggle)
		local wrapped = {}
		local primaryToggleAssigned = false

		function wrapped:AddLabel(text, wrap)
			module:AddLabel(tostring(text or ""))
			return {}
		end

		function wrapped:AddToggle(flag, settings)
			EnsureHyperionConfig()
			local title = settings.Text or tostring(flag)
			local callback = settings.Callback or function() end

			-- Primary toggle: the first toggle whose title matches the
			-- groupbox title is promoted to the module's own enable toggle.
			if not settings.NoPromote
				and not primaryToggleAssigned
				and ShouldPromoteModuleToggle(moduleTitle, title) then
				primaryToggleAssigned = true
				setPrimaryToggle(flag, settings.Default == true, callback)

				return {
					_state = settings.Default == true,
					change_state = function(self, newState)
						self._state = newState == true
						module:SetEnabled(self._state)
					end,
				}
			end

			-- Regular setting toggle
			module:AddToggle(title, {
				Default = settings.Default == true,
				Callback = callback,
			})
			return {}
		end

		function wrapped:AddSlider(flag, settings)
			EnsureHyperionConfig()
			module:AddSlider(settings.Text or tostring(flag), {
				Min = Num(settings.Min, 0),
				Max = Num(settings.Max, 100),
				Default = Num(settings.Default, settings.Min or 0),
				Decimals = math.max(0, tonumber(settings.Rounding) or 0),
				Callback = settings.Callback or function() end,
			})
			return {}
		end

		function wrapped:AddDropdown(flag, settings)
			EnsureHyperionConfig()
			local values = settings.Values or {}
			if #values == 0 then values = { "None" } end

			local mod = module
			local title = settings.Text or tostring(flag)

			if settings.Multi == true then
				local default = {}
				if settings.Default and type(settings.Default) == "table" then
					for _, v in ipairs(settings.Default) do default[#default+1] = tostring(v) end
				end
				mod:AddMultiDropdown(title, {
					Options = values,
					Default = default,
					Callback = settings.Callback or function() end,
				})
			else
				mod:AddDropdown(title, {
					Options = values,
					Default = settings.Default ~= nil and tostring(settings.Default) or nil,
					Callback = settings.Callback or function() end,
				})
			end
			-- Return a ref so RebuildVapeDropdown can locate and update it later
			return { module = mod, title = title }
		end

		function wrapped:AddInput(flag, settings)
			EnsureHyperionConfig()
			module:AddTextbox(settings.Text or tostring(flag), {
				Default = settings.Default ~= nil and tostring(settings.Default) or "",
				Placeholder = settings.Placeholder or "",
				Callback = settings.Callback or function() end,
			})
			return {}
		end

		function wrapped:AddButton(settings)
			EnsureHyperionConfig()
			local btnText = settings.Text or settings.Title or "Button"
			module:AddButton(btnText, settings.Func or settings.Callback or function() end)
			-- Return a mock object that passes IsA("TextButton") checks and
			-- absorbs property writes / tree lookups, so Frost-specific layout
			-- hacks (e.g. the custom Accuracy Range widget) degrade gracefully
			-- on Impulse instead of erroring.
			return setmetatable({}, {
				__index = function(_, key)
					if key == "IsA" then
						return function(_, className)
							return className == "TextButton" or className == "Frame"
						end
					end
					if key == "GetDescendants" or key == "GetChildren" then
						return function() return {} end
					end
					if key == "FindFirstChild" or key == "FindFirstChildOfClass"
						or key == "FindFirstChildWhichIsA" then
						return function() return nil end
					end
					if key == "Destroy" or key == "ClearAllChildren" then
						return function() end
					end
					return nil
				end,
				__newindex = function() end,
			})
		end

		function wrapped:AddColorPicker(name, opts)
			EnsureHyperionConfig()
			module:AddColorPicker(name or tostring(math.random(10000, 99999)), opts)
			return {}
		end

		return wrapped
	end

	-- ── WrapTab ─────────────────────────────────────────────────────────────
	WrapTab = function(tab)
		local wrapped = {}

		function wrapped:AddLeftGroupbox(title)
			return wrapped:_addModule(title)
		end

		function wrapped:AddRightGroupbox(title)
			return wrapped:_addModule(title)
		end

		function wrapped:_addModule(title)
			compat._groupCounter = compat._groupCounter + 1
			local module = tab:Add(title, { Description = "" })

			local primaryToggleFlag = nil
			local primaryCallback = nil
			local primaryState = false

			local function SetPrimaryToggle(flag, default, callback)
				primaryToggleFlag = flag
				primaryCallback = callback
				primaryState = default == true
				module:SetEnabled(primaryState)
				module:OnToggle(function(state)
					primaryCallback(state)
				end)
			end

			return WrapModule(module, title, SetPrimaryToggle)
		end

		return wrapped
	end

	-- ── Compat: CreateWindow ────────────────────────────────────────────────
	function compat:CreateWindow(settings)
		-- Build the actual Impulse window (ScreenGui + pages + topbar)
		pcall(function()
			HyperionLibrary.CreateWindow({
				Name = STATUS_BRAND,
			})
		end)
		self._window = { tabs = {} }
		return self
	end

	function compat:AddTab(title, icon)
		local iconName = (icon and tostring(icon):match("Icon%.([%w_]+)$")) or nil
		local iconMap = {
			Combat = "Swords",  AI = "Zap",       Visuals = "Eye",
			Changer = "Box",    Misc = "Settings",  GUI = "Settings",
		}
		local modIcon = iconMap[title] or "Circle"

		local order = 1
		local orderMap = { Combat=1, Detections=2, Player=3, Visuals=4, Changer=5, Misc=6, GUI=7 }
		order = orderMap[title] or order

		local tab = HyperionLibrary.CreateModule(title, { Icon = modIcon, Order = order })
		return WrapTab(tab)
	end

	-- ── Compat: Notify methods ──────────────────────────────────────────────
	function compat:Notify(text, duration, opts)
		ShowNotification(text, duration, opts)
	end
	function compat:NotifySuccess(text, duration) ShowNotification(text, duration, "success") end
	function compat:NotifyError(text, duration)   ShowNotification(text, duration, "error")   end
	function compat:NotifyWarning(text, duration) ShowNotification(text, duration, "warning") end
	function compat:NotifyInfo(text, duration)    ShowNotification(text, duration, "info")    end

	-- ── Compat: Unload ──────────────────────────────────────────────────────
	function compat:Unload()
		pcall(function()
			HyperionLibrary._default._ui.screen:Destroy()
		end)
	end

	return compat
end

-- When Frost compat was used, EnsureHyperionConfig(Frost) was called here.
-- Now a no-op (already defined above).

Library = CreateVapeCompat()

AutoParry = {
	Enabled = false,
	Mode = "Remote",
	Threshold = 0.85,
	CollisionRadius = 22,
	RandomAccuracyEnabled = false,
	RandomAccuracyMin = 0.05,
	RandomAccuracyMax = 0.95,

	PlayAnimationEnabled = true,
	AntiCurveEnabled = true,
	AutoAbilityEnabled = false,

	PanicParryEnabled = true,
	PanicSpeed = 1200,
	PanicParried = false,

	LowSpeedDeadzoneEnabled = true,
	LowSpeedLimit = 250,
	LowSpeedDeadzone = 15,
	LowSpeedParried = false,
	LowSpeedParryBall = nil,
	LowSpeedParryTarget = nil,
	LastLowSpeedParryClock = 0,

	MinParryEnabled = true,
	MinDetectorSize = 5,
	MinParried = false,

	CFrameDetectorSize = 15,
	CFramesPerUnit = 10,
	CFrameCounter = 0,

TriggerBotEnabled = false,

	TriggerBotDelayMs = 0,
	TriggerBotPlayAnimation = true,

CurveHotkeyEnabled = false,
		CurveNotifyHotkeyEnabled = false,

		ForceSkillEnabled = false,
		ForceSkillOnlyOnCooldown = true,
		ForceSkillTimeToReach = 0.45,
		ForceSkillRepeatCooldown = 0.2,
		LastForceSkillFire = 0,
		CurveEnabled = false,
	CurveMode = "Fast",
	CurveModeSelected = {"Fast"},
	CurveModeIndex = 0,
	SkinChangerEnabled = false,
	SkinName = "",
	LastSkinRefresh = 0,

	AutoParryKey = nil,
	AutoSpamKey = nil,
	ManualSpamKey = nil,
	UIKey = Enum.KeyCode.RightShift,

	AutoSpamEnabled = false,
	ManualSpamEnabled = false,
	AutoSpamDetectorSize = 18,
	AutoSpamMultiplier = 1,

	ManualSpamMethod = "Remote",
	ManualSpamButtonEnabled = false,
	ManualSpamNotify = true,
	ManualSpamActive = false,
	ManualSpamMultiplier = 1,
	ManualSpamPlayAnimation = true,

	AIWalkEnabled = false,
	AIWalkRadius = 45,
	AIWalkDelay = 2.5,
	AIWalkReachDistance = 5,
	AIWalkTarget = nil,
	AIWalkNextPick = 0,
	AIWalkMoving = false,
	AIWalkLastDist = nil,
	AIWalkLastCheck = 0,
	AIWalkStuckSince = nil,

	CharacterModuleEnabled = true,
	AvatarChangerEnabled = false,
	AvatarChangerName = "",
	CustomVFXEnabled = false,
	CustomVFXName = "None",

	AvatarChamsEnabled = false,
	AvatarChamsSelf = true,
	AvatarChamsOthers = true,
	SwordAccessoryEnabled = false,
	SwordStyleEnabled = false,
	InstantEquipEnabled = false,

	BallInformationEnabled = false,
	ShowBallSpeed = false,
	ShowFPSInInfo = false,
	ShowPingInInfo = false,
	NotifyVertical = "Bottom",
	NotifyHorizontal = "Left",
	CustomLogoEnabled = false,
	AccentColorR = 255,
	AccentColorG = 40,
	AccentColorB = 40,
	TargetLockRingEnabled = false,
	TargetLockRingThickness = 0.35,
	TargetLockRingRadius = 3.2,
	TargetLockRingDistort = false,
	DistanceRingEnabled = false,
	DistanceRingThickness = 0.6,
	DistanceRingRadius = 18,
	DistanceRingPulse = true,
	InfoPanelPosition = {XOffset = 12, YOffset = 12},
	CameraEnabled = false,

	ShowStatusBar = false,
	ShowSphere = false,

	ViewBallEnabled = false,

	VisualColorR = 140,
	VisualColorG = 100,
	VisualColorB = 255,

	BallTrailColorR = 140,
	BallTrailColorG = 100,
	BallTrailColorB = 255,
	BallTrailEnabled = false,
	BallTrailLifetime = 1.2,
	BallTrailThickness = 0.2,
	BallTrailVerticalThickness = 0.2,
	BallTrailHorizontalThickness = 0.2,
	BallGlowColorR = 140,
	BallGlowColorG = 100,
	BallGlowColorB = 255,
	BallGlowEnabled = false,

	CharacterTrailColorR = 90,
	CharacterTrailColorG = 200,
	CharacterTrailColorB = 255,
	CharacterTrailEnabled = false,
	CharacterTrailLifetime = 1.2,
	CharacterTrailThickness = 0.25,
	CharacterTrailVerticalThickness = 0.25,
	CharacterTrailHorizontalThickness = 0.25,

	ParryFXColorEnabled = false,
	ParryFXColorR = 140,
	ParryFXColorG = 100,
	ParryFXColorB = 255,
	ParryFXRainbow = false,

	SwordColorEnabled = false,
	SwordColorR = 255,
	SwordColorG = 255,
	SwordColorB = 255,
	SwordRainbow = false,

	JumpCircleColorR = 255,
	JumpCircleColorG = 120,
	JumpCircleColorB = 180,
	JumpCircleEnabled = false,
	JumpCircleLifetime = 0.8,
	JumpCircleSize = 8,
	JumpCircleThickness = 0.08,

	SnowEnabled = false,
	SnowCount = 45,
	SnowSpeed = 120,
	SnowSize = 14,

	ChinaHatEnabled = false,
	ChinaHatRadius = 2.6,
	ChinaHatHeight = 0.8,
	ChinaHatThickness = 0.05,
	ChinaHatSpinSpeed = 1,

	AtmosphereEnabled = false,
	AtmosphereDensity = 0.35,

	WorldLightingEnabled = false,
	LightingBrightness = 3,
	LightingClockTime = 14,

	SaturationEnabled = false,
	SaturationAmount = 0.35,

	StatusBarColorR = 150,
	StatusBarColorG = 105,
	StatusBarColorB = 255,
	StatusBarTextR = 245,
	StatusBarTextG = 245,
	StatusBarTextB = 255,
	StatusBarTransparency = 0.38,

	UIBackgroundR = 18,
	UIBackgroundG = 16,
	UIBackgroundB = 28,
	UIFontR = 235,
	UIFontG = 235,
	UIFontB = 245,

	HeadlessEnabled = false,
	KorbloxEnabled = false,
	UnlockAllSwordsEnabled = false,
	FavoriteSwordName = "",
	FOVEnabled = false,
	CameraFOV = 70,
	CharacterModifierEnabled = false,
	InfiniteJumpEnabled = false,
	SpinEnabled = false,
	SpinSpeed = 5,
	WalkSpeedEnabled = false,
	WalkSpeedValue = 36,
	JumpPowerEnabled = false,
	JumpPowerValue = 50,
	GravityEnabled = false,
	GravityValue = 196.2,
	HipHeightEnabled = false,
	HipHeightValue = 0,
	AbilityESPEnabled = false,
	CooldownTimerEnabled = true,
	ActiveTimerEnabled = true,
	BallVelocityEnabled = false,
	InfinityDetectionEnabled = false,
	InfinityDetectionNotify = false,
	TimeHoleDetectionEnabled = false,
	DeathSlashDetectionEnabled = false,
	SingularityDetectionEnabled = true,
	AerodynamicSlashEnabled = false,
	SlashesOfFuryDetectionEnabled = false,
	SlashesOfFuryParryDelay = 0.05,
	SlashesOfFuryMaxParryCount = 35,
	NoRenderEnabled = false,
	FFlagInjectionEnabled = false,
	ForceRegion = "None",
	ActiveConfig = "Autosave",
	PendingConfigName = "",

	StatusBarPosition = {
		XScale = 0.5,
		XOffset = -215,
		YScale = 0,
		YOffset = 12
	},

	Parried = false,
	BallConnection = nil,
	CachedBall = nil,
	CachedBlockButton = nil,

	LastTarget = nil,
	LastSpeed = 0,
	LastDistance = 0,
	LastTimeToReach = 0,
	LastRequest = "none",
	LastParryTime = 0,
	PredictionStrength = 1.0,
	ReactionDelay = 0.0,
	MaxParryDistance = 250,
	ParryFOV = 360,
	ParryCooldown = 0.03,
	SmartLeadEnabled = true,
	SmoothingEnabled = true,
	TickRateAware = true,
	TimeGatingEnabled = false,
	BaseReactionMs = 200,
}

_G.UIKey = AutoParry.UIKey

RuntimeState = {
	LastFrameBall = nil,
	LastFrameTarget = nil,
	LastParryRequest = 0,
	LastAnyParryRequest = 0,
	LastSpamParryRequest = 0,
	LastManualSpamParryRequest = 0,
	LastTriggerBotRequest = 0,
	ParryRequestCooldown = 0.03,
	SpamParryCooldown = 0.09,
	AutoSpamAfterCoreDelay = 0.16,
	SpamRemoteWindowStart = os.clock(),
	SpamRemoteCount = 10,
	SpamRemoteLimit = 2000,
	SpamBurstLimit = 0,
	HighVelocityAliveSpamActive = false,
	SpamAccumulator = 0,
	SpamRateDefault = 100,
	ManualSpamCPSEnabled = false,
	ManualSpamCPS = 100,


	TriggerBotEnabled = false,
	TriggerBotIsParrying = false,
	TriggerBotParries = 0,
	TriggerBotMaxParries = 10,
	TriggerBotParryDelay = 0.5,
	TriggerBotConnection = nil,
	Fps = 0,
	FrameCounter = 0,
	LastFpsClock = os.clock(),
	StatusGui = nil,
	StatusText = nil,
	StatusFrame = nil,
	BallSpeedGui = nil,
	BallSpeedText = nil,
	BallSpeedPeak = 0,
	BallSpeedLastBall = nil,
	ManualSpamGui = nil,
	ManualSpamButton = nil,
	TriggerBotGui = nil,
	TriggerBotButton = nil,
	NotificationGui = nil,
	NotificationList = nil,
	SpherePart = nil,
	VisualFolder = nil,
	LastBallTrailPosition = nil,
	LastBallTrailClock = 0,
	BallTrailObject = nil,
	BallTrailAttachment0 = nil,
	BallTrailAttachment1 = nil,
	BallTrailBall = nil,
	BallGlowLight = nil,
	BallGlowPart = nil,
	BallGlowBall = nil,
	BallGlowConnection = nil,
	ColorPickerOpen = false,
	UIVisible = true,
	HyperionUIParent = nil,
	LastCharacterTrailPosition = nil,
	CharacterTrailObject = nil,
	CharacterTrailAttachment0 = nil,
	CharacterTrailAttachment1 = nil,
	CharacterTrailPart = nil,
	LastJumpState = false,
	LastJumpCircleTime = 0,
	LastVisualUpdateClock = os.clock(),
	SnowGui = nil,
	Snowflakes = {},
	ChinaHatFolder = nil,
	ChinaHatParts = {},
	ChinaHatRotation = 0,
	AtmosphereEffect = nil,
	SaturationEffect = nil,
	OriginalLighting = nil,
	NoRenderEffect = nil,
	NoRenderOriginalLighting = nil,
	NoRenderOriginalTerrain = nil,
	NoRenderOriginalGraphicsSettings = nil,
	NoRenderOriginalObjects = {},
	NoRenderQueue = {},
	NoRenderQueued = {},
	NoRenderLastQueueStep = 0,
	NoRenderWorkspaceConnection = nil,
	NoRenderLightingConnection = nil,
	NoRenderPlayerScriptsConnection = nil,
	NoRenderLoopConnection = nil,
	DetectionConnections = {},
	InfinityActive = false,
	InfinityOwner = nil,
	TimeHoleActive = false,
	DeathSlashActive = false,
	SlashesOfFuryActive = false,
	AerodynamicSlashActive = false,
	TornadoTime = tick(),
	StatusStroke = nil,
	StatusGradient = nil,
	StatusShine = nil,
	StatusShineGradient = nil,
	CustomLogoGui = nil,
	CustomLogoImage = nil,
	ProjectileStates = {},
	SmoothPing = 0,
	SmoothPingAlpha = 0.1,
	ServerTickRate = 60,
	LastTickCheck = 0,
	FrameDelta = 0,
	LastFrameTime = 0,
	SpamQueue = {},
	SpamQueueProcessing = false,
	SpamLastBatchTime = 0,
	SpamBatchSize = 50,
	SpamBatchInterval = 0.005,
	SpamMaxQueueSize = 10000,
	SpamNetworkThrottle = false,
	SpamQueueRateLimit = 2000,
	SpamQueueBatchSize = 50,
	SpamQueueLastProcess = 0,
	V129FrameCounter = 0,
	V129ScreenCache = nil,
	CloseRangeSustainedBall = nil,
	CloseRangeSustainedStart = 0,
	CloseRangeSustainedDuration = 0.4,
	CloseRangeSustainedThreshold = 10,

	TargetLockRing = nil,
	TargetLockRingFade = 0,
	TargetLockRingTargetFade = 0,
	TargetLockRingPulse = 0,
	DistanceRing = nil,
	DistanceRingRadius = 18,
	DistanceRingPulse = 0,


	CachedHrpPosition = nil,
	CachedBallPosition = nil,
	CachedBallVelocity = nil,
	CachedBallSpeed = 0,
	CachedBallPrevVelocity = nil,
	CachedBallTarget = nil,
	CachedInstantParryProcessed = false,
	CachedPlayerVelocity = nil,

}

ParryKeypressState = {
	KeypressAttempts = 0,
	MaxKeypressAttempts = 5,
	LastNotice = 0,
}

HyperionPort = {
	OriginalGravity = workspace.Gravity,
	SpinAngle = 0,
	AbilityESPBillboards = {},
	AbilityImageCache = {},
	DevUsernames = {},
	DevDataLastFetch = 0,
	DevTagBillboards = {}
}

ChinaHatCacheKey = ""
ChinaHatLastRebuildTime = 0

HYPERION_FOLDER = "Hyperion"
ASSETS_FOLDER = HYPERION_FOLDER .. "/Assets"
CONFIG_FOLDER_PATH = HYPERION_FOLDER .. "/Configs"
CONFIG_FILE_PATH = CONFIG_FOLDER_PATH .. "/HyperionMain.json"
CONFIG_AUTOLOAD_FILE = CONFIG_FOLDER_PATH .. "/AutoloadConfig.txt"
ConfigDirty = false
SaveInProgress = false

AbilityData = {
  Absolute_Confidence = { cooldown = "None (Passive)", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/9/9b/Absolute_Confidence.png" },
  Aerodynamic_Slash = { cooldown = "40s/35s/30s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/2/21/Aerodynamic_Slash.png" },
  Blade_Trap = { cooldown = "25s/20s/15s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/e/e4/Blade_Trap.png" },
  Blink = { cooldown = "10s/8s/6s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/2/2b/Blink_new.png" },
  Bounty = { cooldown = "25s/20s", duration = "15s", image = "https://static.wikia.nocookie.net/bladeball/images/f/fd/Bounty_Ability.png" },
  Bunny_Leap = { cooldown = "8s/6s/4s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/0/08/Bunny_Leap.png" },
  Calming_Deflection = { cooldown = "20s/15s/10s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/b/bf/Calming_Deflection.png" },
  Chieftain_s_Totem = { cooldown = "35s/30s/25s", duration = "12s", image = "https://static.wikia.nocookie.net/bladeball/images/b/be/Chieftain%27s_Totem.png" },
  Continuity_Zero = { cooldown = "20s/15s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/8/82/Continuity_Zero.png" },
  Dash = { cooldown = "7s/6s/5s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/5/55/Dash.png" },
  Death_Slash = { cooldown = "15.5s/13s", duration = "3s/5s", image = "https://static.wikia.nocookie.net/bladeball/images/f/f5/DeathSlash.png" },
  Displace = { cooldown = "35s/30s/25s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/0/0f/Displace.png" },
  Doppelganger = { cooldown = "40s/35s", duration = "15s", image = "https://static.wikia.nocookie.net/bladeball/images/7/75/Doppelganger.png" },
  Dragon_Spirit = { cooldown = "28s/25s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/4/4b/Dragon_Spirit.png" },
  Dribble = { cooldown = "12s/10s/8s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/5/5b/Dribble.png" },
  Encrypted_Clone = { cooldown = "12s (full 27s)", duration = "15s", image = "https://static.wikia.nocookie.net/bladeball/images/4/40/Encrypted_Clone.png" },
  Flash_Counter = { cooldown = "20s/15s/10s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/3/3c/Flash_Counter.png" },
  Force = { cooldown = "40s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/8/87/Force.png" },
  Forcefield = { cooldown = "26s/22s/18s", duration = "5s/7s/9s", image = "https://static.wikia.nocookie.net/bladeball/images/0/0f/Forcefield.png" },
  Fracture = { cooldown = "20s/17s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/6/6c/Fracture.png" },
  Freeze = { cooldown = "30s/25s/20s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/0/00/Freeze.png" },
  Freeze_Trap = { cooldown = "35s/30s/25s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/c/c5/Freeze_Trap.png" },
  Gale_s_Edge = { cooldown = "30s/25s/20s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/2/24/Gale%27s_Edge.png" },
  Golden_Ball = { cooldown = "None (Passive)", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/0/05/Golden_Ball.png" },
  Guardian_Angel = { cooldown = "None (Passive)", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/a/a7/Guardian_Angel.png" },
  Angel_Guardian = { cooldown = "None (Passive)", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/a/a7/Guardian_Angel.png" },
  Hell_Hook = { cooldown = "25s/20s/15s", duration = "1.5s/2s/2.5s", image = "https://static.wikia.nocookie.net/bladeball/images/f/f7/Hell_Hook.png" },
  Infinity = { cooldown = "30s/25s", duration = "10s/12s", image = "https://static.wikia.nocookie.net/bladeball/images/e/e2/Infinity.png" },
  Invisibility = { cooldown = "20s/17s/14s", duration = "5s/7s/9s", image = "https://static.wikia.nocookie.net/bladeball/images/e/e5/Invisibility.png" },
  Luck = { cooldown = "None (Passive)", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/2/27/Luck_image.png" },
  Martyrdom = { cooldown = "45s/35s/25s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/f/ff/Martyrdom.png" },
  Misfortune = { cooldown = "35s/30s/25s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/4/4b/Misfortune.png" },
  Necromancer = { cooldown = "60s/50s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/5/5d/Necromancer.png" },
  Ninja_Dash = { cooldown = "10s/8s/6s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/b/b2/Ninja_Dash.png" },
  Phantom = { cooldown = "30s/25s", duration = "8s/10s", image = "https://static.wikia.nocookie.net/bladeball/images/e/ec/Phantom.png" },
  Phase_Bypass = { cooldown = "40s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/3/35/Phase_Bypass.png" },
  Platform = { cooldown = "15s/12s/9s", duration = "8s/10s/12s", image = "https://static.wikia.nocookie.net/bladeball/images/7/7d/Platform.png" },
  Pull = { cooldown = "30s/25s/20s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/3/31/Pull.png" },
  Pulse = { cooldown = "40s/35s/30s", duration = "5s/6s/7s", image = "https://static.wikia.nocookie.net/bladeball/images/9/9a/Pulse.png" },
  Qi_Charge = { cooldown = "25s/20s/15s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/f/f7/Qi-Charge.png" },
  Quad_Jump = { cooldown = "None (Passive)", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/b/b6/Quad_Jump.png" },
  Quantum_Arena = { cooldown = "1 Kill", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/c/c6/Quantum_Arena.png" },
  Quasar = { cooldown = "35s/30s/25s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/4/4e/Quasar.png" },
  Raging_Deflection = { cooldown = "35s/30s/25s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/4/46/Raging_Deflection.png" },
  Rapture = { cooldown = "30s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/e/e9/Rapture.png" },
  Reaper = { cooldown = "None (Passive)", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/6/6a/Reaper.png" },
  Scopophobia = { cooldown = "20s/15s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/c/c1/Scopophobia.png" },
  Serpent_Shadow_Clone = { cooldown = "40s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/8/85/Serpent_Shadow_Clone_image.png" },
  Shadow_Step = { cooldown = "26s/22.7s/19.5s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/d/d4/Shadow_Step.png" },
  Singularity = { cooldown = "25s/20s", duration = "Up to 5s", image = "https://static.wikia.nocookie.net/bladeball/images/d/d0/Singularity.png" },
  Slash_of_Duality = { cooldown = "30s/25s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/b/b2/Slash_of_Duality_V1.png" },
  Slashes_of_Fury = { cooldown = "30s/25s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/f/f9/Slashes_of_Fury_V1.png" },
  Super_Jump = { cooldown = "8s/7s/6s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/7/7f/Super_Jump.png" },
  Swap = { cooldown = "25s/19s/13s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/0/0d/Swap.png" },
  Tact = { cooldown = "None (Passive)", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/d/d0/Tact.png" },
  Telekinesis = { cooldown = "45s/38s/23s", duration = "few seconds", image = "https://static.wikia.nocookie.net/bladeball/images/c/c3/Telekinesis.png" },
  Thunder_Dash = { cooldown = "4s/3s/2s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/b/b4/Thunder_Dash.png" },
  Time_Hole = { cooldown = "35s/30s", duration = "8s/10s", image = "https://static.wikia.nocookie.net/bladeball/images/e/eb/Time_Hole.png" },
  Titan = { cooldown = "7s-60s", duration = "12s/infinite", image = "https://static.wikia.nocookie.net/bladeball/images/e/e6/Titan.png" },
  Tsunami = { cooldown = "N/A", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/9/94/Tsunami.png" },
  Virus = { cooldown = "None (Passive)", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/f/fd/Virus.png" },
  Waypoint = { cooldown = "3s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/c/c2/Waypoint.png" },
  Wind_Cloak = { cooldown = "30s/25s/20s", duration = 0, image = "https://static.wikia.nocookie.net/bladeball/images/6/69/Wind_Cloak.png" },
}

function GetAbilityImage(url, key)
	if not url or url == "" then return nil end
	cacheKey = key or url
	cached = HyperionPort.AbilityImageCache[cacheKey]
	if cached then return cached end

	fileName = (key and key .. ".png") or (url:match("([^/]+)$") or "ability.png")
	fileName = fileName:gsub("%%(%x%x)", function(hex)
		return string.char(tonumber(hex, 16))
	end)
	fileName = fileName:gsub("[^%w_%-%.]", "_")
	folderPath = ASSETS_FOLDER .. "/Ability"
	filePath = folderPath .. "/" .. fileName

	if type(makefolder) == "function" then
		pcall(function() makefolder(folderPath) end)
	end

	function LoadAsset(path)
		ok, asset = pcall(getcustomasset, path)
		if ok and type(asset) == "string" and asset ~= "" then
			return asset
		end
		return nil
	end

	if type(isfile) == "function" and isfile(filePath) then
		local asset = LoadAsset(filePath)
		if asset then
			HyperionPort.AbilityImageCache[cacheKey] = asset
			return asset
		end
	end

	if not key then return url end

	data = nil
	function tryGet(u)
		ok, r = pcall(function() return game:HttpGet(u) end)
		if ok and type(r) == "string" and #r > 100 then return r end
		return nil
	end

	data = tryGet("https://raw.githubusercontent.com/x-l-v/BladeBallAbility/main/" .. key .. ".png")

	if data then
		writefile(filePath, data)
		task.wait(1)
		local asset = LoadAsset(filePath)
		if asset then
			HyperionPort.AbilityImageCache[cacheKey] = asset
			return asset
		end
	end

	return url
end

function GetVersionValue(str, versionIndex)
	if type(str) == "number" then return str end
	if not str or str == "" or str == "None (Passive)" or str == "N/A" then return nil end

	parts = {}
	for part in str:gmatch("[^/]+") do
		table.insert(parts, part)
	end

	idx = math.min(versionIndex, #parts)
	val = parts[idx]
	if not val then return nil end

	num = val:match("([%d%.]+)")
	if num then return tonumber(num) end

	return nil
end

function FindAbilityData(name)
	if not name then return nil end
	data = AbilityData[name]
	if data then return data, name end

	norm = name:lower():gsub("_", " "):gsub("  ", " ")
	for key in pairs(AbilityData) do
		if key:lower():gsub("_", " "):gsub("  ", " ") == norm then
			return AbilityData[key], key
		end
	end

	for key in pairs(AbilityData) do
		if key:lower():gsub("_", "") == name:lower():gsub("_", ""):gsub(" ", "") then
			return AbilityData[key], key
		end
	end

	return nil
end

function PascalToUnderscore(str)
	return str:gsub("(%u)", "_%1"):gsub("^_", ""):gsub("__", "_")
end

function ConvertRemoteNameToAbilityKey(remoteName)
	name = remoteName

	if name:sub(1, 3) == "Plr" then
		name = name:sub(4)
	end

	if name:sub(-1) == "d" and #name > 1 then
		name = name:sub(1, -2)
	end

	name = PascalToUnderscore(name)

	for key in pairs(AbilityData) do
		if key:lower() == name:lower() then
			return key
		end
	end

	for _, separator in ipairs({"_", "", " "}) do
		local search = name:gsub("_", separator)
		for key in pairs(AbilityData) do
			if key:lower() == search:lower() then
				return key
			end
		end
	end

	norm = name:lower():gsub("_", ""):gsub(" ", "")
	for key in pairs(AbilityData) do
		if key:lower():gsub("_", ""):gsub(" ", "") == norm then
			return key
		end
	end

	return nil
end

nonPlrHardcodedMap = {
	ThunderDash = "Thunder_Dash",
	ForceAbilityActivate = "Force",
	RaptureSuccess2 = "Rapture",
	DeathSlashSuccess = "Death_Slash",
	WindCloak = "Wind_Cloak",
	CloakJump = "Wind_Cloak",
	PhaseBypassed = "Phase_Bypass",
	Infinity = "Infinity",
	Swapped = "Swap",
	ReaperFx = "Reaper",
	Phantom = "Phantom",
	Blinked = "Blink",
	PulseFX = "Pulse",
	QuantumArena = "Quantum_Arena",
	VirusAbilityEffect = "Virus",
	XtraJumped = "Quad_Jump",
	ShadowFollow = "Shadow_Step",
}

function ParseAbilityCooldown(cooldownStr)
	if not cooldownStr or cooldownStr == "" or cooldownStr == "None (Passive)" or cooldownStr == "N/A" or cooldownStr == "1 Kill" or cooldownStr == "0" or cooldownStr == "None" then
		return 0
	end

	duration = 0

	for part in cooldownStr:gmatch("[^/%s]+" ) do
		local value = part

		if value:match("^%d+$" ) then
			duration = math.max(duration, tonumber(value))
			break
		end

		if value:match("^%d+%.%d+$" ) then
			local parsed = tonumber(value)
			if parsed then
				duration = math.max(duration, parsed)
			end
		end

		if value:match(".*s" ) and #value > 1 then
			local num = value:match("^(%d+%.?%d*)%s*s$")
			if num then
				local parsed = tonumber(num)
				if parsed then
					duration = math.max(duration, parsed)
				end
			end
		end

		if value:match("full %d+s" ) then
			local num = value:match("full (%d+)s")
			if num then
				duration = math.max(duration, tonumber(num))
			end
		end

		if value:match("(%d+)s" ) then
			local num = value:match("(%d+)s")
			if num then
				duration = math.max(duration, tonumber(num))
			end
		end

		if value:match("(%d+)s/" ) then
			local num = value:match("(%d+)s/")
			if num then
				duration = math.max(duration, tonumber(num))
			end
		end

		if value:match("(%d+)s(%-)(%d+)s" ) then
			local num = value:match("(%d+)s%-(%d+)s")
			if num then
				local parsed = tonumber(num)
				if parsed then
					duration = math.max(duration, parsed)
				end
			end
		end

		if value:match("(%d+)s/" ) and #value > 1 then
			local num = value:match("(%d+)s")
			if num then
				local parsed = tonumber(num)
				if parsed then
					duration = math.max(duration, parsed)
				end
			end
		end

		if value:match("(%d+)s/" ) then
			local num = value:match("(%d+)s")
			if num then
				duration = math.max(duration, tonumber(num))
			end
		end

		if value:match("^[0-9]+s$" ) then
			local num = value:match("^([0-9]+)s$")
			if num then
				duration = math.max(duration, tonumber(num))
			end
		end

		if value:match("(%d+)s" ) then
			local num = value:match("(%d+)s")
			if num then
				duration = math.max(duration, tonumber(num))
			end
		end
	end

	return duration
end

function GetAbilityCooldown(abilityKey)
	data = AbilityData[abilityKey]
	if not data then
		local ok, result = FindAbilityData(abilityKey)
		if result then
			data = AbilityData[result]
		end
	end
	if not data then
		return 0
	end
	return ParseAbilityCooldown(data.cooldown)
end

function GetAbilityDuration(abilityKey)
	data = AbilityData[abilityKey]
	if not data then
		local ok, result = FindAbilityData(abilityKey)
		if result then
			data = AbilityData[result]
		end
	end
	if not data or not data.duration or data.duration == 0 or data.duration == "" then
		return 0
	end
	return ParseAbilityCooldown(data.duration)
end

HyperionPort.PlayerAbilityStates = HyperionPort.PlayerAbilityStates or {}
HyperionPort.AbilityAttributeWatchers = HyperionPort.AbilityAttributeWatchers or {}
HyperionPort.AbilityRefreshTasks = HyperionPort.AbilityRefreshTasks or {}
HyperionPort.PlayerAbilityAttributes = HyperionPort.PlayerAbilityAttributes or {}

function RefreshPlayerAbilityCooldown(player, abilityKey)
	if not player or not abilityKey then
		return
	end

	cooldown = GetAbilityCooldown(abilityKey)
	state = HyperionPort.PlayerAbilityStates[player]
	if not state then
		state = {
			activeEnd = nil,
			cdEnd = nil,
			abilityKey = abilityKey,
		}
		HyperionPort.PlayerAbilityStates[player] = state
	end

	state.abilityKey = abilityKey

	if cooldown > 0 then
		state.cdEnd = os.clock() + cooldown
	else
		state.cdEnd = nil
		state.activeEnd = nil
		return
	end

	local duration = GetAbilityDuration(abilityKey)
	if duration > 0 then
		state.activeEnd = os.clock() + duration
	end

	if HyperionPort.AbilityRefreshTasks[player] then
		HyperionPort.AbilityRefreshTasks[player]:Disconnect()
		HyperionPort.AbilityRefreshTasks[player] = nil
	end

	HyperionPort.AbilityRefreshTasks[player] = nil

	local function MonitorCooldown()
		while HyperionPort.PlayerAbilityStates[player] do
			local currentState = HyperionPort.PlayerAbilityStates[player]
			if not currentState or not currentState.cdEnd then
				break
			end
			if os.clock() >= currentState.cdEnd then
				local wasKey = currentState.abilityKey

				if currentState.activeEnd and os.clock() < currentState.activeEnd then
					task.wait(currentState.activeEnd - os.clock() + 0.05)
				end

				if HyperionPort.PlayerAbilityStates[player] and HyperionPort.PlayerAbilityStates[player].abilityKey == wasKey then
					HyperionPort.PlayerAbilityStates[player] = nil
				end
				break
			end
			task.wait(0.5)
		end
		HyperionPort.AbilityRefreshTasks[player] = nil
	end

	HyperionPort.AbilityRefreshTasks[player] = task.spawn(MonitorCooldown)
end

function SetupAbilityAttributeWatcher(player)
	if not player then return end
	if HyperionPort.AbilityAttributeWatchers[player] then return end

	local conns = {}

	local function WatchCharacter(char)
		if not char then return end

		local attrConn = char.AttributeChanged:Connect(function(attr)
			local val = char:GetAttribute(attr)

			if attr == "Ability" then
				local attrs = HyperionPort.PlayerAbilityAttributes[player]
				if not attrs then
					attrs = {}
					HyperionPort.PlayerAbilityAttributes[player] = attrs
				end
				attrs.abilityName = val

				if val and val ~= "" then
					local upgrade = char:GetAttribute("AbilityUpgrade")
					local active = char:GetAttribute("AbilityActive")
					attrs.upgrade = upgrade
					attrs.abilityActive = active == true
					attrs.lastActivatedTime = os.clock()

					if active == true then
						local data, matchedKey = FindAbilityData(val)
						if data then
							local versionIndex = math.max(0, (type(upgrade) == "number" and upgrade or 0)) + 1
							local dur = GetAbilityDuration(matchedKey or val)
							if dur and dur > 0 then
								attrs.activeEnd = os.clock() + dur
							end
							local cd = GetAbilityCooldown(matchedKey or val)
							if cd and cd > 0 then
								attrs.cooldownEnd = os.clock() + cd
							end
						end
					end
				end
			end

			if attr == "AbilityActive" then
				local attrs = HyperionPort.PlayerAbilityAttributes[player]
				if not attrs then
					attrs = {}
					HyperionPort.PlayerAbilityAttributes[player] = attrs
				end
				attrs.abilityActive = val == true

				if val == true then
					attrs.lastActivatedTime = os.clock()
					local abilityName = attrs.abilityName or char:GetAttribute("Ability")
					if abilityName then
						local data, matchedKey = FindAbilityData(abilityName)
						if data then
							local upgrade = attrs.upgrade or char:GetAttribute("AbilityUpgrade") or 0
							local versionIndex = math.max(0, (type(upgrade) == "number" and upgrade or 0)) + 1
							local dur = GetAbilityDuration(matchedKey or abilityName)
							if dur and dur > 0 then
								attrs.activeEnd = os.clock() + dur
							end
							local cd = GetAbilityCooldown(matchedKey or abilityName)
							if cd and cd > 0 then
								attrs.cooldownEnd = os.clock() + cd
							end
						end
					end
				end
			end

			if attr == "AbilityUpgrade" then
				local attrs = HyperionPort.PlayerAbilityAttributes[player]
				if not attrs then
					attrs = {}
					HyperionPort.PlayerAbilityAttributes[player] = attrs
				end
				attrs.upgrade = val
			end

			if attr == "LastAbilityUsed" then
				local attrs = HyperionPort.PlayerAbilityAttributes[player]
				if not attrs then
					attrs = {}
					HyperionPort.PlayerAbilityAttributes[player] = attrs
				end
				attrs.lastUsed = val
			end
		end)

		table.insert(conns, attrConn)


		ability = char:GetAttribute("Ability")
		active = char:GetAttribute("AbilityActive")
		upgrade = char:GetAttribute("AbilityUpgrade")
		lastUsed = char:GetAttribute("LastAbilityUsed")

		if ability then
			local attrs = {
				abilityName = ability,
				abilityActive = active == true,
				upgrade = upgrade,
				lastUsed = lastUsed,
				lastActivatedTime = active == true and os.clock() or nil,
			}
			if active == true then
				local data, matchedKey = FindAbilityData(ability)
				if data then
					local versionIndex = math.max(0, (type(upgrade) == "number" and upgrade or 0)) + 1
					local dur = GetAbilityDuration(matchedKey or ability)
					if dur and dur > 0 then
						attrs.activeEnd = os.clock() + dur
					end
					local cd = GetAbilityCooldown(matchedKey or ability)
					if cd and cd > 0 then
						attrs.cooldownEnd = os.clock() + cd
					end
				end
			end
			HyperionPort.PlayerAbilityAttributes[player] = attrs
		end
	end

	if player.Character then
		WatchCharacter(player.Character)
	end

	local charConn = player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		WatchCharacter(char)
	end)
	table.insert(conns, charConn)

	HyperionPort.AbilityAttributeWatchers[player] = conns
end

function InitAbilityRemoteHooks()
	for _, player in Players:GetPlayers() do
		SetupAbilityAttributeWatcher(player)
	end

	if not HyperionPort.AbilityESPPlayerConn then
		HyperionPort.AbilityESPPlayerConn = Players.PlayerAdded:Connect(function(player)
			SetupAbilityAttributeWatcher(player)
		end)
	end
	if not HyperionPort.AbilityESPRemovingConn then
		HyperionPort.AbilityESPRemovingConn = Players.PlayerRemoving:Connect(function(player)
			local conns = HyperionPort.AbilityAttributeWatchers[player]
			if conns then
				for _, conn in ipairs(conns) do
					conn:Disconnect()
				end
			end
			HyperionPort.AbilityAttributeWatchers[player] = nil
			HyperionPort.PlayerAbilityAttributes[player] = nil
			HyperionPort.PlayerAbilityStates[player] = nil
		end)
	end
end

function HyperionPort.GetPlayerCooldown(player, abilityKey)
	if not player then
		return 0
	end
	if abilityKey then
		return GetAbilityCooldown(abilityKey)
	end
	local state = HyperionPort.PlayerAbilityStates[player]
	if not state then
		return 0
	end
	return GetAbilityCooldown(state.abilityKey)
end

function HyperionPort.GetPlayerAbility(player)
	if not player then
		return nil
	end
	local state = HyperionPort.PlayerAbilityStates[player]
	if not state then
		return nil
	end
	return state.abilityKey
end

function HyperionPort.IsAbilityReady(player)
	if not player then
		return true
	end
	local state = HyperionPort.PlayerAbilityStates[player]
	if not state or not state.cdEnd then
		return true
	end
	return os.clock() >= state.cdEnd
end

function HyperionPort.GetRemainingCooldown(player)
	if not player then
		return 0
	end
	local state = HyperionPort.PlayerAbilityStates[player]
	if not state or not state.cdEnd then
		return 0
	end
	local remaining = state.cdEnd - os.clock()
	if remaining < 0 then
		return 0
	end
	return remaining
end

function GetNotificationList()
	return nil -- not needed: notifications go through Impulse
end

_G.UpdateNotificationPosition = function() end -- Impulse uses its own fixed position

UpdateNotificationBlur = function() end

local function Tween(obj, info, props)
	if not TweenService or not obj then return nil end
	local ok, t = pcall(TweenService.Create, TweenService, obj, info, props)
	if ok and t then
		t:Play()
		return t
	end
	return nil
end

HyperionPort.RampBlur = function() end

UpdateNotificationBlur = function() end

-- Route notifications through the Impulse (Vape) notification service.
-- Hyperion callers pass (text, duration, opts) where opts may be a string
-- ("success"/"error"/"warning"/"info") or a table {title=..., type=...}.
function ShowNotification(text, duration, opts)
	if not _G.HyperionBellEnabled then return end
	if not text or text == "" then return end

	local title = "Hyperion"
	local notifType = "info"
	local message = tostring(text)

	if type(opts) == "string" then
		notifType = opts
	elseif type(opts) == "table" then
		if opts.title then title = tostring(opts.title) end
		if opts.type  then notifType = tostring(opts.type) end
	end

	-- Split first line off as title if the caller embedded a newline
	local nl = message:find("\n")
	if nl then
		title = message:sub(1, nl - 1)
		message = message:sub(nl + 1)
	end

	pcall(function()
		local notif = HyperionLibrary._default._notifications
		if notif then
			notif:Notify(title, message, notifType)
		end
	end)
end

_G.ShowNotification = ShowNotification
_G.HyperionBellEnabled = true

_startupComplete = false

function NotifyToggleState(SettingName, isEnabled)
	if not _startupComplete then return end
	local stateText = isEnabled and "Enabled" or "Disabled"
	ShowNotification(tostring(SettingName) .. " | " .. stateText, nil, { title = tostring(SettingName), type = "info" })
end

function CopyDiscordInvite()
	local SettingName = false

	if type(setclipboard) == "function" then
		SettingName = pcall(setclipboard, DISCORD_INVITE)
	elseif type(toclipboard) == "function" then
		SettingName = pcall(toclipboard, DISCORD_INVITE)
	end

	if SettingName then
		ShowNotification("Discord invite copied to clipboard")
	else
		ShowNotification("Clipboard is not supported by this executor")
	end
end

function HasFileIO()
	return type(writefile) == "function"
		and type(readfile) == "function"
		and type(isfile) == "function"
end

function EnsureDataFolder()
	if type(makefolder) == "function" then
		pcall(function() makefolder(HYPERION_FOLDER) end)
		pcall(function() makefolder(CONFIG_FOLDER_PATH) end)
		pcall(function() makefolder(ASSETS_FOLDER) end)
	end
end

function MarkConfigDirty()
	ConfigDirty = true
	if _pickerSwatchUpdaters and #_pickerSwatchUpdaters > 0 then
		UpdatePickerSwatches()
	end
end

function KeyCodeToString(EnumItem)
	if typeof(EnumItem) == "EnumItem" then
		return EnumItem.Name
	end

	return "None"
end

function StringToKeyCode(value)
	if typeof(value) == "EnumItem" then
		return value
	end

	if value == nil or value == "None" then
		return nil
	end

	if typeof(value) == "string" and Enum.KeyCode[value] then
		return Enum.KeyCode[value]
	end

	return nil
end

function SerializeConfig()
	return {
		Enabled = AutoParry.Enabled,
		Mode = AutoParry.Mode,
		CurveEnabled = AutoParry.CurveEnabled,
		CurveMode = AutoParry.CurveMode,
		CurveModeSelected = AutoParry.CurveModeSelected,
		CurveModeIndex = SafeToNumber(AutoParry.CurveModeIndex, 0),
		SkinChangerEnabled = AutoParry.SkinChangerEnabled,
		SkinName = AutoParry.SkinName,
		Threshold = SafeToNumber(AutoParry.Threshold, 0.25),
		RandomAccuracyEnabled = AutoParry.RandomAccuracyEnabled,
		RandomAccuracyMin = SafeToNumber(AutoParry.RandomAccuracyMin, 0.05),
		RandomAccuracyMax = SafeToNumber(AutoParry.RandomAccuracyMax, 0.95),

		PlayAnimationEnabled = AutoParry.PlayAnimationEnabled,
		AntiCurveEnabled = AutoParry.AntiCurveEnabled,
		CurveNotifyHotkeyEnabled = AutoParry.CurveNotifyHotkeyEnabled,
		AutoAbilityEnabled = AutoParry.AutoAbilityEnabled,

		PanicParryEnabled = AutoParry.PanicParryEnabled,
		PanicSpeed = SafeToNumber(AutoParry.PanicSpeed, 1500),

		LowSpeedDeadzoneEnabled = AutoParry.LowSpeedDeadzoneEnabled,
		LowSpeedLimit = SafeToNumber(AutoParry.LowSpeedLimit, 100),
		LowSpeedDeadzone = SafeToNumber(AutoParry.LowSpeedDeadzone, 10),

		MinParryEnabled = AutoParry.MinParryEnabled,
		MinDetectorSize = SafeToNumber(AutoParry.MinDetectorSize, 5),

CFrameDetectorSize = SafeToNumber(AutoParry.CFrameDetectorSize, 15),
	CFramesPerUnit = SafeToNumber(AutoParry.CFramesPerUnit, 10),

	TriggerBotEnabled = RuntimeState.TriggerBotEnabled,
	TriggerBotDelayMs = math.clamp(math.floor(SafeToNumber(AutoParry.TriggerBotDelayMs, 0)), 0, 150),
	TriggerBotPlayAnimation = AutoParry.TriggerBotPlayAnimation,

		ForceSkillEnabled = AutoParry.ForceSkillEnabled,
		ForceSkillOnlyOnCooldown = AutoParry.ForceSkillOnlyOnCooldown,
		ForceSkillTimeToReach = SafeToNumber(AutoParry.ForceSkillTimeToReach, 0.45),
		ForceSkillRepeatCooldown = SafeToNumber(AutoParry.ForceSkillRepeatCooldown, 0.2),

		AutoParryKey = KeyCodeToString(AutoParry.AutoParryKey),
		AutoSpamKey = KeyCodeToString(AutoParry.AutoSpamKey),
		ManualSpamKey = KeyCodeToString(AutoParry.ManualSpamKey),
		UIKey = KeyCodeToString(AutoParry.UIKey),

		AutoSpamEnabled = AutoParry.AutoSpamEnabled,
		ManualSpamEnabled = AutoParry.ManualSpamEnabled == true,
		AutoSpamDetectorSize = SafeToNumber(AutoParry.AutoSpamDetectorSize, 18),
		AutoSpamMultiplier = math.clamp(math.floor(SafeToNumber(AutoParry.AutoSpamMultiplier, 1)), 1, 2000),

		ManualSpamMethod = AutoParry.ManualSpamMethod,
		ManualSpamButtonEnabled = AutoParry.ManualSpamButtonEnabled,
		ManualSpamNotify = AutoParry.ManualSpamNotify,
		ManualSpamActive = AutoParry.ManualSpamActive,
		ManualSpamMultiplier = math.clamp(math.floor(SafeToNumber(AutoParry.ManualSpamMultiplier, 1)), 1, 2000),
		ManualSpamPlayAnimation = AutoParry.ManualSpamPlayAnimation,

		AIWalkEnabled = AutoParry.AIWalkEnabled,
		AIWalkRadius = SafeToNumber(AutoParry.AIWalkRadius, 45),
		AIWalkDelay = SafeToNumber(AutoParry.AIWalkDelay, 2.5),
		AIWalkReachDistance = SafeToNumber(AutoParry.AIWalkReachDistance, 5),
		CharacterModuleEnabled = AutoParry.CharacterModuleEnabled,
		AvatarChangerEnabled = AutoParry.AvatarChangerEnabled,
		AvatarChangerName = AutoParry.AvatarChangerName,
		CustomVFXEnabled = AutoParry.CustomVFXEnabled,
		CustomVFXName = AutoParry.CustomVFXName,
		AvatarChamsEnabled = AutoParry.AvatarChamsEnabled,

		AvatarChamsSelf = AutoParry.AvatarChamsSelf,
		AvatarChamsOthers = AutoParry.AvatarChamsOthers,

		SwordAccessoryEnabled = AutoParry.SwordAccessoryEnabled == true,
		SwordStyleEnabled = AutoParry.SwordStyleEnabled == true,
		InstantEquipEnabled = AutoParry.InstantEquipEnabled == true,

		BallInformationEnabled = AutoParry.BallInformationEnabled,
		CameraEnabled = AutoParry.CameraEnabled,
		ViewBallEnabled = AutoParry.ViewBallEnabled == true,

		ShowStatusBar = false,
		ShowSphere = AutoParry.ShowSphere,
		ShowBallSpeed = AutoParry.ShowBallSpeed,
		ShowFPSInInfo = AutoParry.ShowFPSInInfo,
		ShowPingInInfo = AutoParry.ShowPingInInfo,
		InfoPanelPosition = AutoParry.InfoPanelPosition,

	NotifyVertical = AutoParry.NotifyVertical,
		NotifyHorizontal = AutoParry.NotifyHorizontal,
		CustomLogoEnabled = AutoParry.CustomLogoEnabled == true,
		CustomImage = AutoParry.CustomImage,
		AccentColorR = SafeToNumber(AutoParry.AccentColorR, 255),
		AccentColorG = SafeToNumber(AutoParry.AccentColorG, 40),
		AccentColorB = SafeToNumber(AutoParry.AccentColorB, 40),
		TargetLockRingEnabled = AutoParry.TargetLockRingEnabled == true,
		TargetLockRingRadius = SafeToNumber(AutoParry.TargetLockRingRadius, 3.2),
		TargetLockRingThickness = SafeToNumber(AutoParry.TargetLockRingThickness, 0.35),
		DistanceRingEnabled = AutoParry.DistanceRingEnabled == true,
		DistanceRingRadius = SafeToNumber(AutoParry.DistanceRingRadius, 18),
		DistanceRingThickness = SafeToNumber(AutoParry.DistanceRingThickness, 0.6),
		DistanceRingPulse = AutoParry.DistanceRingPulse == true,

		VisualColorR = SafeToNumber(AutoParry.VisualColorR, 140),
		VisualColorG = SafeToNumber(AutoParry.VisualColorG, 100),
		VisualColorB = SafeToNumber(AutoParry.VisualColorB, 255),

		BallTrailColorR = SafeToNumber(AutoParry.BallTrailColorR, 140),
		BallTrailColorG = SafeToNumber(AutoParry.BallTrailColorG, 100),
		BallTrailColorB = SafeToNumber(AutoParry.BallTrailColorB, 255),
		BallTrailEnabled = AutoParry.BallTrailEnabled,
		BallTrailLifetime = SafeToNumber(AutoParry.BallTrailLifetime, 1.2),
		BallTrailThickness = SafeToNumber(AutoParry.BallTrailThickness, 0.2),
		BallTrailVerticalThickness = SafeToNumber(AutoParry.BallTrailVerticalThickness, AutoParry.BallTrailThickness),
		BallTrailHorizontalThickness = SafeToNumber(AutoParry.BallTrailHorizontalThickness, AutoParry.BallTrailThickness),
		BallGlowColorR = SafeToNumber(AutoParry.BallGlowColorR, 140),
		BallGlowColorG = SafeToNumber(AutoParry.BallGlowColorG, 100),
		BallGlowColorB = SafeToNumber(AutoParry.BallGlowColorB, 255),
		BallGlowEnabled = AutoParry.BallGlowEnabled == true,

		CharacterTrailColorR = SafeToNumber(AutoParry.CharacterTrailColorR, 90),
		CharacterTrailColorG = SafeToNumber(AutoParry.CharacterTrailColorG, 200),
		CharacterTrailColorB = SafeToNumber(AutoParry.CharacterTrailColorB, 255),
		CharacterTrailEnabled = AutoParry.CharacterTrailEnabled,
		CharacterTrailLifetime = SafeToNumber(AutoParry.CharacterTrailLifetime, 1.2),
		CharacterTrailThickness = SafeToNumber(AutoParry.CharacterTrailThickness, 0.25),
		CharacterTrailVerticalThickness = SafeToNumber(AutoParry.CharacterTrailVerticalThickness, AutoParry.CharacterTrailThickness),
		CharacterTrailHorizontalThickness = SafeToNumber(AutoParry.CharacterTrailHorizontalThickness, AutoParry.CharacterTrailThickness),

		ParryFXColorEnabled = AutoParry.ParryFXColorEnabled,
		ParryFXColorR = SafeToNumber(AutoParry.ParryFXColorR, 140),
		ParryFXColorG = SafeToNumber(AutoParry.ParryFXColorG, 100),
		ParryFXColorB = SafeToNumber(AutoParry.ParryFXColorB, 255),
		ParryFXRainbow = AutoParry.ParryFXRainbow,

		SwordColorEnabled = AutoParry.SwordColorEnabled,
		SwordColorR = SafeToNumber(AutoParry.SwordColorR, 255),
		SwordColorG = SafeToNumber(AutoParry.SwordColorG, 255),
		SwordColorB = SafeToNumber(AutoParry.SwordColorB, 255),
		SwordRainbow = AutoParry.SwordRainbow,

		JumpCircleColorR = SafeToNumber(AutoParry.JumpCircleColorR, 255),
		JumpCircleColorG = SafeToNumber(AutoParry.JumpCircleColorG, 120),
		JumpCircleColorB = SafeToNumber(AutoParry.JumpCircleColorB, 180),
		JumpCircleEnabled = AutoParry.JumpCircleEnabled,
		JumpCircleLifetime = SafeToNumber(AutoParry.JumpCircleLifetime, 0.8),
		JumpCircleSize = SafeToNumber(AutoParry.JumpCircleSize, 8),
		JumpCircleThickness = SafeToNumber(AutoParry.JumpCircleThickness, 0.08),

		SnowEnabled = AutoParry.SnowEnabled,
		SnowCount = math.max(1, math.floor(SafeToNumber(AutoParry.SnowCount, 45))),
		SnowSpeed = SafeToNumber(AutoParry.SnowSpeed, 120),
		SnowSize = SafeToNumber(AutoParry.SnowSize, 14),

		ChinaHatEnabled = AutoParry.ChinaHatEnabled,
		ChinaHatRadius = SafeToNumber(AutoParry.ChinaHatRadius, 2.6),
		ChinaHatHeight = SafeToNumber(AutoParry.ChinaHatHeight, 0.8),
		ChinaHatThickness = SafeToNumber(AutoParry.ChinaHatThickness, 0.05),
		ChinaHatSpinSpeed = SafeToNumber(AutoParry.ChinaHatSpinSpeed, 1),

		AtmosphereEnabled = AutoParry.AtmosphereEnabled,
		AtmosphereDensity = SafeToNumber(AutoParry.AtmosphereDensity, 0.35),

		WorldLightingEnabled = AutoParry.WorldLightingEnabled,
		LightingBrightness = SafeToNumber(AutoParry.LightingBrightness, 3),
		LightingClockTime = SafeToNumber(AutoParry.LightingClockTime, 14),

		SaturationEnabled = AutoParry.SaturationEnabled,
		SaturationAmount = SafeToNumber(AutoParry.SaturationAmount, 0.35),

		StatusBarColorR = SafeToNumber(AutoParry.StatusBarColorR, 150),
		StatusBarColorG = SafeToNumber(AutoParry.StatusBarColorG, 105),
		StatusBarColorB = SafeToNumber(AutoParry.StatusBarColorB, 255),
		StatusBarTextR = SafeToNumber(AutoParry.StatusBarTextR, 245),
		StatusBarTextG = SafeToNumber(AutoParry.StatusBarTextG, 245),
		StatusBarTextB = SafeToNumber(AutoParry.StatusBarTextB, 255),
		StatusBarTransparency = SafeToNumber(AutoParry.StatusBarTransparency, 0.38),

		UIBackgroundR = SafeToNumber(AutoParry.UIBackgroundR, 18),
		UIBackgroundG = SafeToNumber(AutoParry.UIBackgroundG, 16),
		UIBackgroundB = SafeToNumber(AutoParry.UIBackgroundB, 28),
		UIFontR = SafeToNumber(AutoParry.UIFontR, 235),
		UIFontG = SafeToNumber(AutoParry.UIFontG, 235),
		UIFontB = SafeToNumber(AutoParry.UIFontB, 245),

		HeadlessEnabled = AutoParry.HeadlessEnabled,
		KorbloxEnabled = AutoParry.KorbloxEnabled,
		FOVEnabled = AutoParry.FOVEnabled,
		CameraFOV = SafeToNumber(AutoParry.CameraFOV, 70),
		CharacterModifierEnabled = AutoParry.CharacterModifierEnabled,
		InfiniteJumpEnabled = AutoParry.InfiniteJumpEnabled,
		SpinEnabled = AutoParry.SpinEnabled,
		SpinSpeed = SafeToNumber(AutoParry.SpinSpeed, 5),
		WalkSpeedEnabled = AutoParry.WalkSpeedEnabled,
		WalkSpeedValue = SafeToNumber(AutoParry.WalkSpeedValue, 36),
		JumpPowerEnabled = AutoParry.JumpPowerEnabled,
		JumpPowerValue = SafeToNumber(AutoParry.JumpPowerValue, 50),
		GravityEnabled = AutoParry.GravityEnabled,
		GravityValue = SafeToNumber(AutoParry.GravityValue, 196.2),
		HipHeightEnabled = AutoParry.HipHeightEnabled,
		HipHeightValue = SafeToNumber(AutoParry.HipHeightValue, 0),
		AbilityESPEnabled = AutoParry.AbilityESPEnabled,
		CooldownTimerEnabled = AutoParry.CooldownTimerEnabled,
		ActiveTimerEnabled = AutoParry.ActiveTimerEnabled,
		BallVelocityEnabled = AutoParry.BallVelocityEnabled,
		InfinityDetectionEnabled = AutoParry.InfinityDetectionEnabled,
		InfinityDetectionNotify = AutoParry.InfinityDetectionNotify,
		TimeHoleDetectionEnabled = AutoParry.TimeHoleDetectionEnabled,
		DeathSlashDetectionEnabled = AutoParry.DeathSlashDetectionEnabled,
		SingularityDetectionEnabled = AutoParry.SingularityDetectionEnabled,
		SlashesOfFuryDetectionEnabled = AutoParry.SlashesOfFuryDetectionEnabled,
		AerodynamicSlashEnabled = AutoParry.AerodynamicSlashEnabled,
		SlashesOfFuryParryDelay = SafeToNumber(AutoParry.SlashesOfFuryParryDelay, 0.05),
		SlashesOfFuryMaxParryCount = math.max(1, math.floor(SafeToNumber(AutoParry.SlashesOfFuryMaxParryCount, 36))),
		FFlagInjectionEnabled = AutoParry.FFlagInjectionEnabled,
		ForceRegion = tostring(AutoParry.ForceRegion or "None"),
		TargetLockRingEnabled = AutoParry.TargetLockRingEnabled == true,
		TargetLockRingRadius = SafeToNumber(AutoParry.TargetLockRingRadius, 3.2),
		TargetLockRingThickness = SafeToNumber(AutoParry.TargetLockRingThickness, 0.35),
		DistanceRingEnabled = AutoParry.DistanceRingEnabled == true,
		DistanceRingRadius = SafeToNumber(AutoParry.DistanceRingRadius, 18),
		DistanceRingThickness = SafeToNumber(AutoParry.DistanceRingThickness, 0.6),
		DistanceRingPulse = AutoParry.DistanceRingPulse == true,

		StatusBarPosition = AutoParry.StatusBarPosition,

		PredictionStrength = SafeToNumber(AutoParry.PredictionStrength, 1.0),
		ReactionDelay = SafeToNumber(AutoParry.ReactionDelay, 0.0),
		MaxParryDistance = SafeToNumber(AutoParry.MaxParryDistance, 250),
		ParryFOV = SafeToNumber(AutoParry.ParryFOV, 360),
		ParryCooldown = SafeToNumber(AutoParry.ParryCooldown, 0.03),
		SmartLeadEnabled = AutoParry.SmartLeadEnabled,
		SmoothingEnabled = AutoParry.SmoothingEnabled,
		TickRateAware = AutoParry.TickRateAware,

	}
end

function NormalizeParryMethod(value)
	value = tostring(value or ""):lower():gsub("%s+", "")

	if value == "keypress" or value == "key" or value == "firebutton" or value == "fire" or value == "button" or value == "original" then
		return "Keypress"
	end

	return "Remote"
end

function SetAutoParryMode(value)
	AutoParry.Mode = NormalizeParryMethod(value)
	ParryKeypressState.KeypressAttempts = 0
	_CachedModeValue = nil
	_CachedCurveMode = nil
	return AutoParry.Mode
end

function DeserializeConfig(ConfigTable)
	if typeof(ConfigTable) ~= "table" then
		return
	end

	if typeof(ConfigTable.Enabled) == "boolean" then
		AutoParry.Enabled = ConfigTable.Enabled
	end

	if ConfigTable.Mode == "Fire" .. "button" then
		SetAutoParryMode("Keypress")
	elseif ConfigTable.Mode == "Remote" or ConfigTable.Mode == "Keypress" then
		SetAutoParryMode(ConfigTable.Mode)
	elseif ConfigTable.Mode == "Original" or ConfigTable.Mode == "CFrame" then
		SetAutoParryMode("Remote")
	end

	if typeof(ConfigTable.CurveEnabled) == "boolean" then
		AutoParry.CurveEnabled = ConfigTable.CurveEnabled
	end

	if ConfigTable.CurveMode == "Acceler" .. "ated" then
		AutoParry.CurveMode = "Fast"
	elseif ConfigTable.CurveMode == "Random" or ConfigTable.CurveMode == "Fast" or ConfigTable.CurveMode == "Backwards" or ConfigTable.CurveMode == "Slow" or ConfigTable.CurveMode == "High" or ConfigTable.CurveMode == "Camera" then
		AutoParry.CurveMode = ConfigTable.CurveMode
	end
	if type(ConfigTable.CurveModeSelected) == "table" then
		AutoParry.CurveModeSelected = ConfigTable.CurveModeSelected
	end
	AutoParry.CurveModeIndex = SafeToNumber(ConfigTable.CurveModeIndex, 0)
	if typeof(ConfigTable.CurvePrinterEnabled) == "boolean" then
		AutoParry.CurvePrinterEnabled = ConfigTable.CurvePrinterEnabled
	end

	if typeof(ConfigTable.SkinChangerEnabled) == "boolean" then
		AutoParry.SkinChangerEnabled = ConfigTable.SkinChangerEnabled
	end

	if typeof(ConfigTable.SkinName) == "string" then
		AutoParry.SkinName = ConfigTable.SkinName
	end

	AutoParry.Threshold = math.clamp(SafeToNumber(ConfigTable.Threshold, AutoParry.Threshold), 0.05, 0.95)
	if typeof(ConfigTable.RandomAccuracyEnabled) == "boolean" then AutoParry.RandomAccuracyEnabled = ConfigTable.RandomAccuracyEnabled end
	AutoParry.RandomAccuracyMin = math.clamp(SafeToNumber(ConfigTable.RandomAccuracyMin, AutoParry.RandomAccuracyMin), 0.05, 1)
	AutoParry.RandomAccuracyMax = math.clamp(SafeToNumber(ConfigTable.RandomAccuracyMax, AutoParry.RandomAccuracyMax), 0.05, 1)
	if AutoParry.RandomAccuracyMin > AutoParry.RandomAccuracyMax then AutoParry.RandomAccuracyMin, AutoParry.RandomAccuracyMax = AutoParry.RandomAccuracyMax, AutoParry.RandomAccuracyMin end

	if typeof(ConfigTable.PlayAnimationEnabled) == "boolean" then AutoParry.PlayAnimationEnabled = ConfigTable.PlayAnimationEnabled end
	if typeof(ConfigTable.AntiCurveEnabled) == "boolean" then AutoParry.AntiCurveEnabled = ConfigTable.AntiCurveEnabled end
	if typeof(ConfigTable.CurveNotifyHotkeyEnabled) == "boolean" then AutoParry.CurveNotifyHotkeyEnabled = ConfigTable.CurveNotifyHotkeyEnabled end
	if typeof(ConfigTable.AutoAbilityEnabled) == "boolean" then AutoParry.AutoAbilityEnabled = ConfigTable.AutoAbilityEnabled end

	if typeof(ConfigTable.PanicParryEnabled) == "boolean" then
		AutoParry.PanicParryEnabled = ConfigTable.PanicParryEnabled
	end

	AutoParry.PanicSpeed = SafeToNumber(ConfigTable.PanicSpeed, AutoParry.PanicSpeed)

	if typeof(ConfigTable.LowSpeedDeadzoneEnabled) == "boolean" then
		AutoParry.LowSpeedDeadzoneEnabled = ConfigTable.LowSpeedDeadzoneEnabled
	end

	AutoParry.LowSpeedLimit = SafeToNumber(ConfigTable.LowSpeedLimit, AutoParry.LowSpeedLimit)
	AutoParry.LowSpeedDeadzone = math.clamp(SafeToNumber(ConfigTable.LowSpeedDeadzone, AutoParry.LowSpeedDeadzone), 1, 10)

	if typeof(ConfigTable.MinParryEnabled) == "boolean" then
		AutoParry.MinParryEnabled = ConfigTable.MinParryEnabled
	end

	AutoParry.MinDetectorSize = SafeToNumber(ConfigTable.MinDetectorSize, AutoParry.MinDetectorSize)
	AutoParry.CFrameDetectorSize = SafeToNumber(ConfigTable.CFrameDetectorSize, AutoParry.CFrameDetectorSize)
	AutoParry.CFramesPerUnit = math.max(1, math.floor(SafeToNumber(ConfigTable.CFramesPerUnit, AutoParry.CFramesPerUnit)))

	if typeof(ConfigTable.TriggerBotEnabled) == "boolean" then
		RuntimeState.TriggerBotEnabled = ConfigTable.TriggerBotEnabled
	end

	AutoParry.TriggerBotDelayMs = math.clamp(math.floor(SafeToNumber(ConfigTable.TriggerBotDelayMs, AutoParry.TriggerBotDelayMs)), 0, 150)
	if typeof(ConfigTable.TriggerBotPlayAnimation) == "boolean" then AutoParry.TriggerBotPlayAnimation = ConfigTable.TriggerBotPlayAnimation end

	if typeof(ConfigTable.ForceSkillEnabled) == "boolean" then
		AutoParry.ForceSkillEnabled = ConfigTable.ForceSkillEnabled
	end

	if typeof(ConfigTable.ForceSkillOnlyOnCooldown) == "boolean" then
		AutoParry.ForceSkillOnlyOnCooldown = ConfigTable.ForceSkillOnlyOnCooldown
	end

	if typeof(ConfigTable.CurveHotkeyEnabled) == "boolean" then
		AutoParry.CurveHotkeyEnabled = ConfigTable.CurveHotkeyEnabled
	end

	AutoParry.ForceSkillTimeToReach = math.max(0.05, SafeToNumber(ConfigTable.ForceSkillTimeToReach, AutoParry.ForceSkillTimeToReach))
	AutoParry.ForceSkillRepeatCooldown = math.max(0.05, SafeToNumber(ConfigTable.ForceSkillRepeatCooldown, AutoParry.ForceSkillRepeatCooldown))

AutoParry.AutoParryKey = StringToKeyCode(ConfigTable.AutoParryKey)
	AutoParry.AutoSpamKey = StringToKeyCode(ConfigTable.AutoSpamKey)
	AutoParry.ManualSpamKey = StringToKeyCode(ConfigTable.ManualSpamKey)
	AutoParry.UIKey = StringToKeyCode(ConfigTable.UIKey) or AutoParry.UIKey

	if typeof(ConfigTable.AutoSpamEnabled) == "boolean" then
		AutoParry.AutoSpamEnabled = ConfigTable.AutoSpamEnabled
	end
	if typeof(ConfigTable.ManualSpamEnabled) == "boolean" then
		AutoParry.ManualSpamEnabled = ConfigTable.ManualSpamEnabled
	end

	AutoParry.AutoSpamDetectorSize = SafeToNumber(ConfigTable.AutoSpamDetectorSize, AutoParry.AutoSpamDetectorSize)
	AutoParry.AutoSpamMultiplier = math.clamp(math.floor(SafeToNumber(ConfigTable.AutoSpamMultiplier, AutoParry.AutoSpamMultiplier)), 1, 2000)

	if ConfigTable.ManualSpamMethod == "Keypress" then
		AutoParry.ManualSpamMethod = "Keypress"
	elseif ConfigTable.ManualSpamMethod == "Remote" then
		AutoParry.ManualSpamMethod = "Remote"
	end

	if typeof(ConfigTable.ManualSpamButtonEnabled) == "boolean" then
		AutoParry.ManualSpamButtonEnabled = ConfigTable.ManualSpamButtonEnabled
	end

	if typeof(ConfigTable.ManualSpamNotify) == "boolean" then
		AutoParry.ManualSpamNotify = ConfigTable.ManualSpamNotify
	end

	AutoParry.ManualSpamMultiplier = math.clamp(math.floor(SafeToNumber(ConfigTable.ManualSpamMultiplier, AutoParry.ManualSpamMultiplier)), 1, 2000)
	if typeof(ConfigTable.ManualSpamPlayAnimation) == "boolean" then AutoParry.ManualSpamPlayAnimation = ConfigTable.ManualSpamPlayAnimation end

	if typeof(ConfigTable.ManualSpamActive) == "boolean" then
		AutoParry.ManualSpamActive = ConfigTable.ManualSpamActive
	end

	if typeof(ConfigTable.AIWalkEnabled) == "boolean" then
		AutoParry.AIWalkEnabled = ConfigTable.AIWalkEnabled
	end

	AutoParry.AIWalkRadius = math.max(5, SafeToNumber(ConfigTable.AIWalkRadius, AutoParry.AIWalkRadius))
	AutoParry.AIWalkDelay = math.max(0.2, SafeToNumber(ConfigTable.AIWalkDelay, AutoParry.AIWalkDelay))
	AutoParry.AIWalkReachDistance = math.max(1, SafeToNumber(ConfigTable.AIWalkReachDistance, AutoParry.AIWalkReachDistance))
	if typeof(ConfigTable.CharacterModuleEnabled) == "boolean" then AutoParry.CharacterModuleEnabled = ConfigTable.CharacterModuleEnabled end
	if typeof(ConfigTable.AvatarChangerEnabled) == "boolean" then AutoParry.AvatarChangerEnabled = ConfigTable.AvatarChangerEnabled end
	if typeof(ConfigTable.AvatarChangerName) == "string" then AutoParry.AvatarChangerName = ConfigTable.AvatarChangerName end
	if typeof(ConfigTable.CustomVFXEnabled) == "boolean" then AutoParry.CustomVFXEnabled = ConfigTable.CustomVFXEnabled end
	if typeof(ConfigTable.CustomVFXName) == "string" then AutoParry.CustomVFXName = ConfigTable.CustomVFXName end
	if typeof(ConfigTable.AvatarChamsEnabled) == "boolean" then
		AutoParry.AvatarChamsEnabled = ConfigTable.AvatarChamsEnabled
	end

	if typeof(ConfigTable.AvatarChamsSelf) == "boolean" then
		AutoParry.AvatarChamsSelf = ConfigTable.AvatarChamsSelf
	end
	if typeof(ConfigTable.AvatarChamsOthers) == "boolean" then
		AutoParry.AvatarChamsOthers = ConfigTable.AvatarChamsOthers
	end

	if typeof(ConfigTable.SwordAccessoryEnabled) == "boolean" then AutoParry.SwordAccessoryEnabled = ConfigTable.SwordAccessoryEnabled end
	if typeof(ConfigTable.SwordStyleEnabled) == "boolean" then AutoParry.SwordStyleEnabled = ConfigTable.SwordStyleEnabled end
	if typeof(ConfigTable.InstantEquipEnabled) == "boolean" then AutoParry.InstantEquipEnabled = ConfigTable.InstantEquipEnabled end

	if typeof(ConfigTable.BallInformationEnabled) == "boolean" then
		AutoParry.BallInformationEnabled = ConfigTable.BallInformationEnabled
	end
	if typeof(ConfigTable.CameraEnabled) == "boolean" then
		AutoParry.CameraEnabled = ConfigTable.CameraEnabled
	end
	if typeof(ConfigTable.ViewBallEnabled) == "boolean" then
		AutoParry.ViewBallEnabled = ConfigTable.ViewBallEnabled
	elseif typeof(ConfigTable.BreakBallViewBallEnabled) == "boolean" then
		AutoParry.ViewBallEnabled = ConfigTable.BreakBallViewBallEnabled
	end

	AutoParry.ShowStatusBar = false

	if typeof(ConfigTable.ShowSphere) == "boolean" then
		AutoParry.ShowSphere = ConfigTable.ShowSphere
	end

	if typeof(ConfigTable.ShowBallSpeed) == "boolean" then
		AutoParry.ShowBallSpeed = ConfigTable.ShowBallSpeed
	end
	if typeof(ConfigTable.ShowFPSInInfo) == "boolean" then
		AutoParry.ShowFPSInInfo = ConfigTable.ShowFPSInInfo
	end
	if typeof(ConfigTable.ShowPingInInfo) == "boolean" then
		AutoParry.ShowPingInInfo = ConfigTable.ShowPingInInfo
	end

	if typeof(ConfigTable.TargetLockRingEnabled) == "boolean" then
		AutoParry.TargetLockRingEnabled = ConfigTable.TargetLockRingEnabled
	end
	if typeof(ConfigTable.TargetLockRingRadius) == "number" then
		AutoParry.TargetLockRingRadius = ConfigTable.TargetLockRingRadius
	end
	if typeof(ConfigTable.TargetLockRingThickness) == "number" then
		AutoParry.TargetLockRingThickness = ConfigTable.TargetLockRingThickness
	end
	if typeof(ConfigTable.DistanceRingEnabled) == "boolean" then
		AutoParry.DistanceRingEnabled = ConfigTable.DistanceRingEnabled
	end
	if typeof(ConfigTable.DistanceRingRadius) == "number" then
		AutoParry.DistanceRingRadius = ConfigTable.DistanceRingRadius
	end
	if typeof(ConfigTable.DistanceRingThickness) == "number" then
		AutoParry.DistanceRingThickness = ConfigTable.DistanceRingThickness
	end
	if typeof(ConfigTable.DistanceRingPulse) == "boolean" then
		AutoParry.DistanceRingPulse = ConfigTable.DistanceRingPulse
	end
	if typeof(ConfigTable.NotificationPlacementSaved) == "boolean" then
		AutoParry.NotificationPlacementSaved = ConfigTable.NotificationPlacementSaved
	end
	if typeof(ConfigTable.NotificationPosX) == "number" then
		AutoParry.NotificationPosX = ConfigTable.NotificationPosX
	end
	if typeof(ConfigTable.NotificationPosY) == "number" then
		AutoParry.NotificationPosY = ConfigTable.NotificationPosY
	end
	if typeof(ConfigTable.InfoPanelPosition) == "table" then
		AutoParry.InfoPanelPosition = {
			XOffset = SafeToNumber(ConfigTable.InfoPanelPosition.XOffset, 12),
			YOffset = SafeToNumber(ConfigTable.InfoPanelPosition.YOffset, 12)
		}
	end

	AutoParry.VisualColorR = math.clamp(SafeToNumber(ConfigTable.VisualColorR, AutoParry.VisualColorR), 0, 255)
	AutoParry.VisualColorG = math.clamp(SafeToNumber(ConfigTable.VisualColorG, AutoParry.VisualColorG), 0, 255)
	AutoParry.VisualColorB = math.clamp(SafeToNumber(ConfigTable.VisualColorB, AutoParry.VisualColorB), 0, 255)

	AutoParry.BallTrailColorR = math.clamp(SafeToNumber(ConfigTable.BallTrailColorR, AutoParry.VisualColorR), 0, 255)
	AutoParry.BallTrailColorG = math.clamp(SafeToNumber(ConfigTable.BallTrailColorG, AutoParry.VisualColorG), 0, 255)
	AutoParry.BallTrailColorB = math.clamp(SafeToNumber(ConfigTable.BallTrailColorB, AutoParry.VisualColorB), 0, 255)
	if typeof(ConfigTable.BallTrailEnabled) == "boolean" then AutoParry.BallTrailEnabled = ConfigTable.BallTrailEnabled end
	AutoParry.BallTrailLifetime = SafeToNumber(ConfigTable.BallTrailLifetime, AutoParry.BallTrailLifetime)
	AutoParry.BallTrailThickness = SafeToNumber(ConfigTable.BallTrailThickness, AutoParry.BallTrailThickness)
	AutoParry.BallTrailVerticalThickness = SafeToNumber(ConfigTable.BallTrailVerticalThickness, AutoParry.BallTrailThickness)
	AutoParry.BallTrailHorizontalThickness = SafeToNumber(ConfigTable.BallTrailHorizontalThickness, AutoParry.BallTrailThickness)
	AutoParry.BallGlowColorR = math.clamp(SafeToNumber(ConfigTable.BallGlowColorR, AutoParry.VisualColorR), 0, 255)
	AutoParry.BallGlowColorG = math.clamp(SafeToNumber(ConfigTable.BallGlowColorG, AutoParry.VisualColorG), 0, 255)
	AutoParry.BallGlowColorB = math.clamp(SafeToNumber(ConfigTable.BallGlowColorB, AutoParry.VisualColorB), 0, 255)
	if typeof(ConfigTable.BallGlowEnabled) == "boolean" then AutoParry.BallGlowEnabled = ConfigTable.BallGlowEnabled end

	AutoParry.CharacterTrailColorR = math.clamp(SafeToNumber(ConfigTable.CharacterTrailColorR, AutoParry.VisualColorR), 0, 255)
	AutoParry.CharacterTrailColorG = math.clamp(SafeToNumber(ConfigTable.CharacterTrailColorG, AutoParry.VisualColorG), 0, 255)
	AutoParry.CharacterTrailColorB = math.clamp(SafeToNumber(ConfigTable.CharacterTrailColorB, AutoParry.VisualColorB), 0, 255)
	if typeof(ConfigTable.CharacterTrailEnabled) == "boolean" then AutoParry.CharacterTrailEnabled = ConfigTable.CharacterTrailEnabled end
	AutoParry.CharacterTrailLifetime = SafeToNumber(ConfigTable.CharacterTrailLifetime, AutoParry.CharacterTrailLifetime)
	AutoParry.CharacterTrailThickness = SafeToNumber(ConfigTable.CharacterTrailThickness, AutoParry.CharacterTrailThickness)
	AutoParry.CharacterTrailVerticalThickness = SafeToNumber(ConfigTable.CharacterTrailVerticalThickness, AutoParry.CharacterTrailThickness)
	AutoParry.CharacterTrailHorizontalThickness = SafeToNumber(ConfigTable.CharacterTrailHorizontalThickness, AutoParry.CharacterTrailThickness)

	if typeof(ConfigTable.ParryFXColorEnabled) == "boolean" then AutoParry.ParryFXColorEnabled = ConfigTable.ParryFXColorEnabled end
	AutoParry.ParryFXColorR = math.clamp(SafeToNumber(ConfigTable.ParryFXColorR, AutoParry.ParryFXColorR), 0, 255)
	AutoParry.ParryFXColorG = math.clamp(SafeToNumber(ConfigTable.ParryFXColorG, AutoParry.ParryFXColorG), 0, 255)
	AutoParry.ParryFXColorB = math.clamp(SafeToNumber(ConfigTable.ParryFXColorB, AutoParry.ParryFXColorB), 0, 255)
	if typeof(ConfigTable.ParryFXRainbow) == "boolean" then AutoParry.ParryFXRainbow = ConfigTable.ParryFXRainbow end

	if typeof(ConfigTable.SwordColorEnabled) == "boolean" then AutoParry.SwordColorEnabled = ConfigTable.SwordColorEnabled end
	AutoParry.SwordColorR = math.clamp(SafeToNumber(ConfigTable.SwordColorR, AutoParry.SwordColorR), 0, 255)
	AutoParry.SwordColorG = math.clamp(SafeToNumber(ConfigTable.SwordColorG, AutoParry.SwordColorG), 0, 255)
	AutoParry.SwordColorB = math.clamp(SafeToNumber(ConfigTable.SwordColorB, AutoParry.SwordColorB), 0, 255)
	if typeof(ConfigTable.SwordRainbow) == "boolean" then AutoParry.SwordRainbow = ConfigTable.SwordRainbow end

	AutoParry.JumpCircleColorR = math.clamp(SafeToNumber(ConfigTable.JumpCircleColorR, AutoParry.VisualColorR), 0, 255)
	AutoParry.JumpCircleColorG = math.clamp(SafeToNumber(ConfigTable.JumpCircleColorG, AutoParry.VisualColorG), 0, 255)
	AutoParry.JumpCircleColorB = math.clamp(SafeToNumber(ConfigTable.JumpCircleColorB, AutoParry.VisualColorB), 0, 255)
	if typeof(ConfigTable.JumpCircleEnabled) == "boolean" then AutoParry.JumpCircleEnabled = ConfigTable.JumpCircleEnabled end
	AutoParry.JumpCircleLifetime = SafeToNumber(ConfigTable.JumpCircleLifetime, AutoParry.JumpCircleLifetime)
	AutoParry.JumpCircleSize = SafeToNumber(ConfigTable.JumpCircleSize, AutoParry.JumpCircleSize)
	AutoParry.JumpCircleThickness = SafeToNumber(ConfigTable.JumpCircleThickness, AutoParry.JumpCircleThickness)

	if typeof(ConfigTable.SnowEnabled) == "boolean" then AutoParry.SnowEnabled = ConfigTable.SnowEnabled end
	AutoParry.SnowCount = math.max(1, math.floor(SafeToNumber(ConfigTable.SnowCount, AutoParry.SnowCount)))
	AutoParry.SnowSpeed = SafeToNumber(ConfigTable.SnowSpeed, AutoParry.SnowSpeed)
	AutoParry.SnowSize = SafeToNumber(ConfigTable.SnowSize, AutoParry.SnowSize)

	if typeof(ConfigTable.ChinaHatEnabled) == "boolean" then AutoParry.ChinaHatEnabled = ConfigTable.ChinaHatEnabled end
	AutoParry.ChinaHatRadius = SafeToNumber(ConfigTable.ChinaHatRadius, AutoParry.ChinaHatRadius)
	AutoParry.ChinaHatHeight = SafeToNumber(ConfigTable.ChinaHatHeight, AutoParry.ChinaHatHeight)
	AutoParry.ChinaHatThickness = SafeToNumber(ConfigTable.ChinaHatThickness, AutoParry.ChinaHatThickness)
	AutoParry.ChinaHatSpinSpeed = SafeToNumber(ConfigTable.ChinaHatSpinSpeed, AutoParry.ChinaHatSpinSpeed)

	if typeof(ConfigTable.AtmosphereEnabled) == "boolean" then AutoParry.AtmosphereEnabled = ConfigTable.AtmosphereEnabled end
	AutoParry.AtmosphereDensity = SafeToNumber(ConfigTable.AtmosphereDensity, AutoParry.AtmosphereDensity)

	if typeof(ConfigTable.WorldLightingEnabled) == "boolean" then AutoParry.WorldLightingEnabled = ConfigTable.WorldLightingEnabled end
	AutoParry.LightingBrightness = SafeToNumber(ConfigTable.LightingBrightness, AutoParry.LightingBrightness)
	AutoParry.LightingClockTime = SafeToNumber(ConfigTable.LightingClockTime, AutoParry.LightingClockTime)

	if typeof(ConfigTable.SaturationEnabled) == "boolean" then AutoParry.SaturationEnabled = ConfigTable.SaturationEnabled end
	AutoParry.SaturationAmount = SafeToNumber(ConfigTable.SaturationAmount, AutoParry.SaturationAmount)

	AutoParry.StatusBarColorR = math.clamp(SafeToNumber(ConfigTable.StatusBarColorR, AutoParry.StatusBarColorR), 0, 255)
	AutoParry.StatusBarColorG = math.clamp(SafeToNumber(ConfigTable.StatusBarColorG, AutoParry.StatusBarColorG), 0, 255)
	AutoParry.StatusBarColorB = math.clamp(SafeToNumber(ConfigTable.StatusBarColorB, AutoParry.StatusBarColorB), 0, 255)
	AutoParry.StatusBarTextR = math.clamp(SafeToNumber(ConfigTable.StatusBarTextR, AutoParry.StatusBarTextR), 0, 255)
	AutoParry.StatusBarTextG = math.clamp(SafeToNumber(ConfigTable.StatusBarTextG, AutoParry.StatusBarTextG), 0, 255)
	AutoParry.StatusBarTextB = math.clamp(SafeToNumber(ConfigTable.StatusBarTextB, AutoParry.StatusBarTextB), 0, 255)
	AutoParry.StatusBarTransparency = math.clamp(SafeToNumber(ConfigTable.StatusBarTransparency, AutoParry.StatusBarTransparency), 0, 0.9)

	AutoParry.UIBackgroundR = math.clamp(SafeToNumber(ConfigTable.UIBackgroundR, AutoParry.UIBackgroundR), 0, 255)
	AutoParry.UIBackgroundG = math.clamp(SafeToNumber(ConfigTable.UIBackgroundG, AutoParry.UIBackgroundG), 0, 255)
	AutoParry.UIBackgroundB = math.clamp(SafeToNumber(ConfigTable.UIBackgroundB, AutoParry.UIBackgroundB), 0, 255)
	AutoParry.UIFontR = math.clamp(SafeToNumber(ConfigTable.UIFontR, AutoParry.UIFontR), 0, 255)
	AutoParry.UIFontG = math.clamp(SafeToNumber(ConfigTable.UIFontG, AutoParry.UIFontG), 0, 255)
	AutoParry.UIFontB = math.clamp(SafeToNumber(ConfigTable.UIFontB, AutoParry.UIFontB), 0, 255)
	AutoParry.AccentColorR = math.clamp(SafeToNumber(ConfigTable.AccentColorR, AutoParry.AccentColorR), 0, 255)
	AutoParry.AccentColorG = math.clamp(SafeToNumber(ConfigTable.AccentColorG, AutoParry.AccentColorG), 0, 255)
	AutoParry.AccentColorB = math.clamp(SafeToNumber(ConfigTable.AccentColorB, AutoParry.AccentColorB), 0, 255)

	if typeof(ConfigTable.HeadlessEnabled) == "boolean" then AutoParry.HeadlessEnabled = ConfigTable.HeadlessEnabled end
	if typeof(ConfigTable.KorbloxEnabled) == "boolean" then AutoParry.KorbloxEnabled = ConfigTable.KorbloxEnabled end
	if typeof(ConfigTable.FOVEnabled) == "boolean" then AutoParry.FOVEnabled = ConfigTable.FOVEnabled end
	AutoParry.CameraFOV = math.clamp(SafeToNumber(ConfigTable.CameraFOV, AutoParry.CameraFOV), 50, 120)
	if typeof(ConfigTable.CharacterModifierEnabled) == "boolean" then AutoParry.CharacterModifierEnabled = ConfigTable.CharacterModifierEnabled end
	if typeof(ConfigTable.InfiniteJumpEnabled) == "boolean" then AutoParry.InfiniteJumpEnabled = ConfigTable.InfiniteJumpEnabled end
	if typeof(ConfigTable.SpinEnabled) == "boolean" then AutoParry.SpinEnabled = ConfigTable.SpinEnabled end
	AutoParry.SpinSpeed = math.clamp(SafeToNumber(ConfigTable.SpinSpeed, AutoParry.SpinSpeed), 1, 50)
	if typeof(ConfigTable.WalkSpeedEnabled) == "boolean" then AutoParry.WalkSpeedEnabled = ConfigTable.WalkSpeedEnabled end
	AutoParry.WalkSpeedValue = math.clamp(SafeToNumber(ConfigTable.WalkSpeedValue, AutoParry.WalkSpeedValue), 16, 500)
	if typeof(ConfigTable.JumpPowerEnabled) == "boolean" then AutoParry.JumpPowerEnabled = ConfigTable.JumpPowerEnabled end
	AutoParry.JumpPowerValue = math.clamp(SafeToNumber(ConfigTable.JumpPowerValue, AutoParry.JumpPowerValue), 50, 200)
	if typeof(ConfigTable.GravityEnabled) == "boolean" then AutoParry.GravityEnabled = ConfigTable.GravityEnabled end
	AutoParry.GravityValue = math.clamp(SafeToNumber(ConfigTable.GravityValue, AutoParry.GravityValue), 0, 400)
	if typeof(ConfigTable.HipHeightEnabled) == "boolean" then AutoParry.HipHeightEnabled = ConfigTable.HipHeightEnabled end
	AutoParry.HipHeightValue = math.clamp(SafeToNumber(ConfigTable.HipHeightValue, AutoParry.HipHeightValue), -5, 20)
	if typeof(ConfigTable.AbilityESPEnabled) == "boolean" then AutoParry.AbilityESPEnabled = ConfigTable.AbilityESPEnabled end
	if typeof(ConfigTable.CooldownTimerEnabled) == "boolean" then AutoParry.CooldownTimerEnabled = ConfigTable.CooldownTimerEnabled end
	if typeof(ConfigTable.ActiveTimerEnabled) == "boolean" then AutoParry.ActiveTimerEnabled = ConfigTable.ActiveTimerEnabled end
	if typeof(ConfigTable.BallVelocityEnabled) == "boolean" then AutoParry.BallVelocityEnabled = ConfigTable.BallVelocityEnabled end
	if typeof(ConfigTable.InfinityDetectionEnabled) == "boolean" then AutoParry.InfinityDetectionEnabled = ConfigTable.InfinityDetectionEnabled end
	if typeof(ConfigTable.InfinityDetectionNotify) == "boolean" then AutoParry.InfinityDetectionNotify = ConfigTable.InfinityDetectionNotify end
	if typeof(ConfigTable.TimeHoleDetectionEnabled) == "boolean" then AutoParry.TimeHoleDetectionEnabled = ConfigTable.TimeHoleDetectionEnabled end
	if typeof(ConfigTable.DeathSlashDetectionEnabled) == "boolean" then AutoParry.DeathSlashDetectionEnabled = ConfigTable.DeathSlashDetectionEnabled end
	if typeof(ConfigTable.SingularityDetectionEnabled) == "boolean" then AutoParry.SingularityDetectionEnabled = ConfigTable.SingularityDetectionEnabled end
	if typeof(ConfigTable.SlashesOfFuryDetectionEnabled) == "boolean" then AutoParry.SlashesOfFuryDetectionEnabled = ConfigTable.SlashesOfFuryDetectionEnabled end
	if typeof(ConfigTable.AerodynamicSlashEnabled) == "boolean" then AutoParry.AerodynamicSlashEnabled = ConfigTable.AerodynamicSlashEnabled end
	AutoParry.SlashesOfFuryParryDelay = math.clamp(SafeToNumber(ConfigTable.SlashesOfFuryParryDelay, AutoParry.SlashesOfFuryParryDelay), 0.05, 0.25)
	AutoParry.SlashesOfFuryMaxParryCount = math.max(1, math.floor(SafeToNumber(ConfigTable.SlashesOfFuryMaxParryCount, AutoParry.SlashesOfFuryMaxParryCount)))
	if typeof(ConfigTable.NoRenderEnabled) == "boolean" then AutoParry.NoRenderEnabled = ConfigTable.NoRenderEnabled end
if typeof(ConfigTable.ForceRegion) == "string" then AutoParry.ForceRegion = ConfigTable.ForceRegion end
	if typeof(ConfigTable.FFlagInjectionEnabled) == "boolean" then AutoParry.FFlagInjectionEnabled = ConfigTable.FFlagInjectionEnabled end
	if typeof(ConfigTable.TargetLockRingEnabled) == "boolean" then AutoParry.TargetLockRingEnabled = ConfigTable.TargetLockRingEnabled end
	if typeof(ConfigTable.TargetLockRingRadius) == "number" then AutoParry.TargetLockRingRadius = ConfigTable.TargetLockRingRadius end
	if typeof(ConfigTable.TargetLockRingThickness) == "number" then AutoParry.TargetLockRingThickness = ConfigTable.TargetLockRingThickness end
	if typeof(ConfigTable.DistanceRingEnabled) == "boolean" then AutoParry.DistanceRingEnabled = ConfigTable.DistanceRingEnabled end
	if typeof(ConfigTable.DistanceRingRadius) == "number" then AutoParry.DistanceRingRadius = ConfigTable.DistanceRingRadius end
	if typeof(ConfigTable.DistanceRingThickness) == "number" then AutoParry.DistanceRingThickness = ConfigTable.DistanceRingThickness end
	if typeof(ConfigTable.DistanceRingPulse) == "boolean" then AutoParry.DistanceRingPulse = ConfigTable.DistanceRingPulse end
	if typeof(ConfigTable.NotifyVertical) == "string" then AutoParry.NotifyVertical = ConfigTable.NotifyVertical end
	if typeof(ConfigTable.NotifyHorizontal) == "string" then AutoParry.NotifyHorizontal = ConfigTable.NotifyHorizontal end

	if typeof(ConfigTable.StatusBarPosition) == "table" then
		AutoParry.StatusBarPosition = {
			XScale = SafeToNumber(ConfigTable.StatusBarPosition.XScale, 0.5),
			XOffset = SafeToNumber(ConfigTable.StatusBarPosition.XOffset, -215),
			YScale = SafeToNumber(ConfigTable.StatusBarPosition.YScale, 0),
			YOffset = SafeToNumber(ConfigTable.StatusBarPosition.YOffset, 12)
		}
	end

	AutoParry.PredictionStrength = math.clamp(SafeToNumber(ConfigTable.PredictionStrength, AutoParry.PredictionStrength), 0.1, 2.0)
	AutoParry.ReactionDelay = math.clamp(SafeToNumber(ConfigTable.ReactionDelay, AutoParry.ReactionDelay), 0, 0.5)
	AutoParry.MaxParryDistance = math.max(10, SafeToNumber(ConfigTable.MaxParryDistance, AutoParry.MaxParryDistance))
	AutoParry.ParryFOV = math.clamp(SafeToNumber(ConfigTable.ParryFOV, AutoParry.ParryFOV), 10, 360)
	AutoParry.ParryCooldown = math.clamp(SafeToNumber(ConfigTable.ParryCooldown, AutoParry.ParryCooldown), 0.01, 0.2)
	if typeof(ConfigTable.SmartLeadEnabled) == "boolean" then AutoParry.SmartLeadEnabled = ConfigTable.SmartLeadEnabled end
	if typeof(ConfigTable.SmoothingEnabled) == "boolean" then AutoParry.SmoothingEnabled = ConfigTable.SmoothingEnabled end
	if typeof(ConfigTable.TickRateAware) == "boolean" then AutoParry.TickRateAware = ConfigTable.TickRateAware end
end

function LoadConfig()
	if not HasFileIO() then
		return
	end

	EnsureDataFolder()

	if not isfile(CONFIG_FILE_PATH) then
		return
	end

	local v2, decoded = pcall(function()
		return HttpService:JSONDecode(readfile(CONFIG_FILE_PATH))
	end)

	if v2 and typeof(decoded) == "table" then
		DeserializeConfig(decoded)
	end
end

function SaveConfig()
	if SaveInProgress then
		return
	end

	if not ConfigDirty then
		return
	end

	if not HasFileIO() then
		ConfigDirty = false
		return
	end

	SaveInProgress = true
	EnsureDataFolder()

	local v2, encoded = pcall(function()
		return HttpService:JSONEncode(SerializeAutosaveConfig())
	end)

	if v2 and encoded then
		local WriteSuccess = pcall(function()
			writefile(CONFIG_FILE_PATH, encoded)
		end)

		if WriteSuccess then
			ConfigDirty = false
		end
	end

	SaveInProgress = false
end

function SerializeAutosaveConfig()
	local full = SerializeConfig()
	return full
end

function SanitizeConfigName(name)
	name = tostring(name or ""):gsub("[\\/:*?\"<>|]", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" or name == "Autosave" then
		return nil
	end

	return name
end

function ListSavedConfigs()
	if not HasFileIO() then
		return {}
	end

	local ok, files = pcall(function()
		if type(isfolder) == "function" and not isfolder(CONFIG_FOLDER_PATH) then
			return {}
		end
		return listfiles(CONFIG_FOLDER_PATH)
	end)

	if not ok or type(files) ~= "table" then
		return {}
	end

	local names = {}
	for _, path in ipairs(files) do
		local name = path:match("([^/\\]+)%.json$")
		if name then
			table.insert(names, name)
		end
	end

	table.sort(names)
	return names
end

function SaveNamedConfig(name)
	name = SanitizeConfigName(name)
	if not name or not HasFileIO() then
		return false
	end

	EnsureDataFolder()
	if type(makefolder) == "function" then
		pcall(function() makefolder(CONFIG_FOLDER_PATH) end)
	end

	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(SerializeConfig())
	end)

	if not ok or not encoded then
		return false
	end

	local filePath = CONFIG_FOLDER_PATH .. "/" .. name .. ".json"
	local writeOk = pcall(function()
		writefile(filePath, encoded)
	end)

	return writeOk == true
end

function LoadNamedConfig(name)
	name = SanitizeConfigName(name)
	if not name or not HasFileIO() then
		return false
	end

	local filePath = CONFIG_FOLDER_PATH .. "/" .. name .. ".json"
	if not isfile(filePath) then
		return false
	end

	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(readfile(filePath))
	end)

	if ok and typeof(decoded) == "table" then
		DeserializeConfig(decoded)
		return true
	end

	return false
end

function SetAutoloadConfig(name)
	name = name or "Autosave"
	if not HasFileIO() then
		return false
	end

	EnsureDataFolder()
	local writeOk = pcall(function()
		writefile(CONFIG_AUTOLOAD_FILE, tostring(name))
	end)

	return writeOk == true
end

function GetAutoloadConfig()
	if not HasFileIO() then
		return "Autosave"
	end

	if not isfile(CONFIG_AUTOLOAD_FILE) then
		return "Autosave"
	end

	local ok, name = pcall(function()
		return readfile(CONFIG_AUTOLOAD_FILE)
	end)

	if ok and name and name ~= "" then
		return name
	end

	return "Autosave"
end

function DeleteNamedConfig(name)
	name = SanitizeConfigName(name)
	if not name or not HasFileIO() then
		return false
	end

	local filePath = CONFIG_FOLDER_PATH .. "/" .. name .. ".json"
	if not isfile(filePath) then
		return false
	end

	local ok = pcall(function()
		delfile(filePath)
	end)

	if ok and GetAutoloadConfig() == name then
		SetAutoloadConfig("Autosave")
	end

	return ok == true
end

function StartAutoSave()
    HyperionPort.AutoSaveActive = true
    task.spawn(function()
        while HyperionPort.AutoSaveActive and task.wait(10) do
            if ConfigDirty then
                SaveConfig()
            end
        end
    end)
end

_cachedPingValue = 0
_cachedPingFrame = -1
function GetPing()
	if _cachedPingFrame == BallCacheFrame then
		return _cachedPingValue
	end
	local v2, ping = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)

	if v2 and ping then
		_cachedPingValue = math.floor(SafeToNumber(ping, 0))
	else
		_cachedPingValue = 0
	end
	_cachedPingFrame = BallCacheFrame
	return _cachedPingValue
end

function GetCharacter()
	local Character = Player.Character
	if not Character then
		return nil, nil
	end

	local hrp = Character:FindFirstChild("HumanoidRootPart")
	return Character, hrp
end

function GetCharacterWithHumanoid()
	local Character, hrp = GetCharacter()
	if not Character or not hrp then
		return nil, nil, nil
	end

	local humanoid = Character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return Character, hrp, nil
	end

	return Character, hrp, humanoid
end

function HyperionPort.GetAutoParryPosition(hrp)
	return hrp and hrp.Position or nil
end

function GenerateRandomWalkPosition()
	local Character, hrp = GetCharacter()
	if not Character or not hrp then
		return nil
	end

	local Radius = math.max(5, SafeToNumber(AutoParry.AIWalkRadius, 45))
	local RandomAngle = math.random() * math.pi * 2
	local distance = Radius * (0.25 + (math.random() * 0.75))
	local OffsetVector = Vector3.new(math.cos(RandomAngle) * distance, 0, math.sin(RandomAngle) * distance)

	return hrp.Position + OffsetVector
end

function ClearWalkTarget()
	AutoParry.AIWalkTarget = nil
	AutoParry.AIWalkNextPick = 0
	AutoParry.AIWalkMoving = false
	AutoParry.AIWalkLastDist = nil
	AutoParry.AIWalkLastCheck = 0
	AutoParry.AIWalkStuckSince = nil
end

function PickNewWalkTarget()
	local WalkTarget = GenerateRandomWalkPosition()

	if WalkTarget then
		AutoParry.AIWalkTarget = WalkTarget
		AutoParry.AIWalkNextPick = os.clock() + math.max(0.2, SafeToNumber(AutoParry.AIWalkDelay, 2.5))
		AutoParry.AIWalkMoving = false
	end
end

_closestPlayerCache = nil
_closestPlayerCacheTime = 0
function _getClosestPlayer()
	t = tick()
	if t - _closestPlayerCacheTime < 0.05 then
		return _closestPlayerCache
	end
	_closestPlayerCacheTime = t
	if not Main or not Main.player then
		_closestPlayerCache = nil
		return nil
	end



	_closestPlayerCache = Main.player.get_closest_to_cursor and Main.player.get_closest_to_cursor()
	if _closestPlayerCache then return _closestPlayerCache end

	if type(GetClosestAliveByDistance) == "function" then
		_closestPlayerCache = GetClosestAliveByDistance()
		if _closestPlayerCache then return _closestPlayerCache end
	end

	return nil
end

function ExecuteAIWalk()
	if not AutoParry.AIWalkEnabled then
		local _, hrp, humanoid = GetCharacterWithHumanoid()
		if hrp and humanoid and AutoParry.AIWalkMoving then
			humanoid:MoveTo(hrp.Position)
		end
		AutoParry.AIWalkMoving = false
		return
	end

	local Index, hrp, humanoid = GetCharacterWithHumanoid()

	if not hrp or not humanoid then
		ClearWalkTarget()
		return
	end


	local WalkTarget = AutoParry.AIWalkTarget

	if not WalkTarget then
		if os.clock() >= AutoParry.AIWalkNextPick then
			PickNewWalkTarget()
			WalkTarget = AutoParry.AIWalkTarget
		end
	end

	if not WalkTarget then
		if AutoParry.AIWalkMoving then
			humanoid:MoveTo(hrp.Position)
			AutoParry.AIWalkMoving = false
		end
		return
	end

	local DistToTarget = (hrp.Position - WalkTarget).Magnitude
	local Reach = math.max(1, SafeToNumber(AutoParry.AIWalkReachDistance, 5))

	if DistToTarget <= Reach then

		humanoid:MoveTo(hrp.Position)
		AutoParry.AIWalkMoving = false
		AutoParry.AIWalkLastDist = nil
		AutoParry.AIWalkStuckSince = nil
		if os.clock() >= AutoParry.AIWalkNextPick then
			PickNewWalkTarget()
		end
		return
	end


	if AutoParry.AIWalkMoving and os.clock() - AutoParry.AIWalkLastCheck >= 1 then
		AutoParry.AIWalkLastCheck = os.clock()

		if AutoParry.AIWalkLastDist and DistToTarget >= AutoParry.AIWalkLastDist - 1.5 then
			AutoParry.AIWalkStuckSince = AutoParry.AIWalkStuckSince or os.clock()
			if os.clock() - AutoParry.AIWalkStuckSince >= 5 then
				PickNewWalkTarget()
				AutoParry.AIWalkStuckSince = nil
				AutoParry.AIWalkLastDist = nil
				return
			end
		else
			AutoParry.AIWalkStuckSince = nil
		end

		AutoParry.AIWalkLastDist = DistToTarget
	end

	humanoid:MoveTo(WalkTarget)
	AutoParry.AIWalkMoving = true
end

function GetPlayerAtCursor()
	if type(getgenv) == "function" and type(getgenv().CheckPlayerAtCursor) == "function" then
		local result = getgenv().CheckPlayerAtCursor()
		if result then return result end
	end

	if type(Main) == "table" and type(Main.player) == "table" and type(Main.player.get_closest_to_cursor) == "function" then
		local result = Main.player.get_closest_to_cursor()
		if result and type(result) == "table" and result.Name then
			return result.Name
		end
		if type(result) == "string" then
			return result
		end
	end

	local camera = workspace.CurrentCamera
	local mouseLocation = UserInputService:GetMouseLocation()
	local unitRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)

	if result then
		local hit = result.Instance
		if hit then
			local model = hit:FindFirstAncestorOfClass("Model")
			if model and (model.Parent == workspace:FindFirstChild("Alive") or Players:FindFirstChild(model.Name)) then
				return model.Name
			end
		end
	end

	if Players then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local char = player.Character or (workspace:FindFirstChild("Alive") and workspace.Alive:FindFirstChild(player.Name))
				if char then
					local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
					if hrp then
						local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
						if onScreen then
							local mousePos = UserInputService:GetMouseLocation()
							local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
							if dist < 50 then
								return player.Name
							end
						end
					end
				end
			end
		end
	end

	local alive = workspace:FindFirstChild("Alive")
	if alive then
		for _, model in ipairs(alive:GetChildren()) do
			if model:IsA("Model") and model ~= LocalPlayer.Character then
				local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
				if hrp then
					local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
					if onScreen then
						local mousePos = UserInputService:GetMouseLocation()
						local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
						if dist < 50 then
							return model.Name
						end
					end
				end
			end
		end
	end

	return nil
end

math.randomseed(tick())

_cachedMobile = nil
_cachedMobileFrame = 0
function _isMobile()
	f = (tick() * 60 // 30)
	if f ~= _cachedMobileFrame then
		_cachedMobileFrame = f
		_cachedMobile = IsMobile()
	end
	return _cachedMobile
end

AvatarChamsConnection = nil
PlayerRemovingConnection = nil
AvatarChamsPlayerConnections = {}
AvatarChamsCharConnections = {}
AvatarChamsHighlights = {}
AvatarChamsHiddenObjects = {}
AvatarChamsRefreshParts = {}
AvatarChamsRefreshConnection = nil

function GetGlassHighlight()
	hl = Instance.new("Highlight")
	hl.Name = "HyperionGlass"
	hl.DepthMode = Enum.HighlightDepthMode.Occluded
	hl.FillColor = Color3.fromRGB(180, 215, 255)
	hl.FillTransparency = 0.6
	hl.OutlineColor = Color3.new(1, 1, 1)
	hl.OutlineTransparency = 0.5
	return hl
end

BODY_PART_NAMES = {
	Torso = true, Head = true, ["Left Arm"] = true, ["Right Arm"] = true,
	["Left Leg"] = true, ["Right Leg"] = true, HumanoidRootPart = true,
}

function IsBodyModel(model)
	if not model:IsA("Model") then return false end
	return BODY_PART_NAMES[model.Name] == true
end

function GetWeaponModels(char)
	if not char then return {} end
	weapons = {}
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("Model") and not IsBodyModel(child) then
			local hasParts = false
			for _, desc in ipairs(child:GetDescendants()) do
				if desc:IsA("BasePart") then hasParts = true; break end
			end
			if hasParts then table.insert(weapons, child) end
		end
	end
	return weapons
end

function IsSwordPart(desc)
	if not desc:IsA("BasePart") then return false end
	char = desc:FindFirstAncestorOfClass("Model")
	if not char then return false end
	weapons = GetWeaponModels(char)
	for _, w in ipairs(weapons) do
		if desc:IsDescendantOf(w) then return true end
	end
	return false
end

function IsBodyPart(desc)
	if not desc:IsA("BasePart") then return false end
	isAccessory = desc:FindFirstAncestorOfClass("Accessory")
	isTool = desc:FindFirstAncestorOfClass("Tool")
	if isAccessory or isTool then return false end
	name = desc.Name:lower()
	if name == "handle" or name == "grip" then return false end
	return BODY_PART_NAMES[desc.Name] == true
end

function ClearCharacterChams(player)
	if not player then return end

	hidden = AvatarChamsHiddenObjects[player]
	if hidden then
		for _, item in ipairs(hidden) do
			pcall(function()
				if item.parent then
					item.instance.Parent = item.parent
				elseif item.property then
					item.instance[item.property] = item.oldValue
				end
			end)
		end
		AvatarChamsHiddenObjects[player] = nil
	end

	hls = AvatarChamsHighlights[player]
	if hls then
		for _, hl in ipairs(hls) do
			hl.Adornee = nil
			hl.Parent = nil
		end
		AvatarChamsHighlights[player] = nil
	end

	conns = AvatarChamsCharConnections[player]
	if conns then
		for _, conn in ipairs(conns) do
			conn:Disconnect()
		end
		AvatarChamsCharConnections[player] = nil
	end

	AvatarChamsRefreshParts[player] = nil

	char = player.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0
			end
		end
	end
end

function ClearPlayerConnections(player)
	if not player then return end
	conns = AvatarChamsPlayerConnections[player]
	if conns then
		for _, conn in ipairs(conns) do
			conn:Disconnect()
		end
		AvatarChamsPlayerConnections[player] = nil
	end
end

function SetupChamsForCharacter(player, char)
	ClearCharacterChams(player)

	if player == Player and not AutoParry.AvatarChamsSelf then return end
	if player ~= Player and not AutoParry.AvatarChamsOthers then return end

	hidden = {}
	refreshParts = {}
	AvatarChamsHiddenObjects[player] = hidden
	AvatarChamsRefreshParts[player] = refreshParts

	highlights = {}

	function processInstance(desc)
		if desc:IsA("BasePart") then
			if IsSwordPart(desc) then

				return
			end
			if IsBodyPart(desc) then
				desc.LocalTransparencyModifier = 0.85
			else
				desc.LocalTransparencyModifier = 0
			end
			table.insert(refreshParts, desc)
		elseif desc:IsA("Shirt") or desc:IsA("Pants") or desc:IsA("ShirtGraphic") then
			table.insert(hidden, {parent = desc.Parent, instance = desc})
			desc.Parent = nil
		elseif desc:IsA("Decal") and desc.Name == "face" then
			table.insert(hidden, {instance = desc, property = "Transparency", oldValue = desc.Transparency})
			desc.Transparency = 1
		end
	end

	for _, desc in ipairs(char:GetDescendants()) do
		processInstance(desc)
	end

	local c1 = char.DescendantAdded:Connect(function(desc)
		task.wait()
		if not AutoParry.AvatarChamsEnabled then return end
		processInstance(desc)
	end)

	AvatarChamsCharConnections[player] = {c1}

	local hl = GetGlassHighlight()
	if hl then
		hl.Adornee = char
		hl.Parent = workspace
		AvatarChamsHighlights[player] = {hl}
	end
end

function MonitorPlayer(player)
	ClearPlayerConnections(player)

	function onCharAdded(char)
		task.wait(0.5)
		if not AutoParry.AvatarChamsEnabled then return end
		SetupChamsForCharacter(player, char)
	end

	c1 = player.CharacterAdded:Connect(onCharAdded)
	c2 = player.CharacterRemoving:Connect(function()
		ClearCharacterChams(player)
	end)

	AvatarChamsPlayerConnections[player] = {c1, c2}

	if player.Character then
		task.spawn(function()
			onCharAdded(player.Character)
		end)
	end
end

function ApplyAvatarChams()
	if not AutoParry.AvatarChamsEnabled then
		if AvatarChamsConnection then
			AvatarChamsConnection:Disconnect()
			AvatarChamsConnection = nil
		end
		if PlayerRemovingConnection then
			PlayerRemovingConnection:Disconnect()
			PlayerRemovingConnection = nil
		end
		if AvatarChamsRefreshConnection then
			AvatarChamsRefreshConnection:Disconnect()
			AvatarChamsRefreshConnection = nil
		end
		for _, player in ipairs(Players:GetPlayers()) do
			ClearCharacterChams(player)
			ClearPlayerConnections(player)
		end
		return
	end

	if AvatarChamsConnection then
		AvatarChamsConnection:Disconnect()
	end
	if PlayerRemovingConnection then
		PlayerRemovingConnection:Disconnect()
	end
	if AvatarChamsRefreshConnection then
		AvatarChamsRefreshConnection:Disconnect()
	end

	for _, player in ipairs(Players:GetPlayers()) do
		ClearCharacterChams(player)
		ClearPlayerConnections(player)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		MonitorPlayer(player)
	end

	AvatarChamsConnection = Players.PlayerAdded:Connect(function(player)
		MonitorPlayer(player)
	end)

	PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		ClearCharacterChams(player)
		ClearPlayerConnections(player)
	end)

	chamsFrame = 0
	AvatarChamsRefreshConnection = RunService.Heartbeat:Connect(function()
		chamsFrame += 1
		if chamsFrame % 3 ~= 1 then return end
		if not AutoParry.AvatarChamsEnabled then return end
		for player, parts in pairs(AvatarChamsRefreshParts) do
			if player == Player and not AutoParry.AvatarChamsSelf then continue end
			if player ~= Player and not AutoParry.AvatarChamsOthers then continue end
			for _, part in ipairs(parts) do
				if part and part.Parent then
					part.LocalTransparencyModifier = IsBodyPart(part) and 0.85 or 0
				end
			end
		end
	end)
end

NoLagConnection = nil
function ApplyTextureLag()
	if AutoParry.NoRenderEnabled then
		if not NoLagConnection then
			NoLagConnection = workspace.DescendantAdded:Connect(function(c)
				task.wait()
				if c:IsA("BasePart") and not c:IsA("Terrain") then
					c.Material = Enum.Material.SmoothPlastic
				end
			end)
		end
		for _, c in ipairs(workspace:GetDescendants()) do
			if c:IsA("BasePart") and not c:IsA("Terrain") then
				c.Material = Enum.Material.SmoothPlastic
			end
			if c:IsA("MeshPart") then
				c.TextureID = ""
			end
		end
	elseif NoLagConnection then
		NoLagConnection:Disconnect()
		NoLagConnection = nil
	end
end

function FindBlockButton()
	if AutoParry.CachedBlockButton and AutoParry.CachedBlockButton.Parent then
		return AutoParry.CachedBlockButton
	end

	local HotbarGui = PlayerGui:FindFirstChild("Hotbar")
	local BlockButton = HotbarGui and HotbarGui:FindFirstChild("Block", true)

	if not BlockButton then
		for _, object in ipairs(PlayerGui:GetDescendants()) do
			if object.Name == "Block" and (object:IsA("GuiButton") or object:IsA("ImageButton") or object:IsA("TextButton")) then
				BlockButton = object
				break
			end
		end
	end

	if BlockButton then
		AutoParry.CachedBlockButton = BlockButton
	end

	return BlockButton
end

function FireBlockButtonParry()
    local curveCFrame = Main.curve and Main.curve.get_cframe and Main.curve.get_cframe()
    return ParryRemote.fire(curveCFrame) == true
end

function FireButton()
	return FireBlockButtonParry()
end

local ParryHookState = {
	parryRemote = nil,
	parryArgs = nil,
	parryDerivedKey = nil,
	parryRecoveredKey = nil,
	prevArgs = nil,
	blockNextParry = false,
}

local ParryCaptureInstalled = false
local ParryCaptureOrig = nil
local ParryCaptureTarget = nil

local function makeParryOTP()
	if not ParryHookState.parryDerivedKey then return nil end
	local serverTime = workspace:GetServerTimeNow()
	local timeStr = tostring(math.floor(serverTime * 100))
	local result = {}
	for j = 1, #timeStr do
		local v = (string.byte(timeStr, j) + j) % 256
		result[j] = string.char(bit32.bxor(v, string.byte(ParryHookState.parryDerivedKey, (j - 1) % #ParryHookState.parryDerivedKey + 1)))
	end
	return table.concat(result)
end

local function _recoverOTP(realOTP, serverTime)
	local timeStr = tostring(math.floor(serverTime * 100))
	local recovered = {}
	for j = 1, #realOTP do
		local v = (string.byte(timeStr, j) + j) % 256
		recovered[j] = string.char(bit32.bxor(string.byte(realOTP, j), v))
	end
	return table.concat(recovered)
end

local function UninstallParryCapture()
	if not ParryCaptureInstalled then return end
	ParryCaptureInstalled = false
	if ParryCaptureOrig and ParryCaptureTarget and hookfunction then
		pcall(function() hookfunction(ParryCaptureTarget, ParryCaptureOrig) end)
	end
	ParryCaptureOrig = nil
	ParryCaptureTarget = nil
end

local function InstallParryCapture()
	if ParryCaptureInstalled then return end
	if type(hookfunction) ~= "function" then return end

	local pa = nil
	local ok, remotes = pcall(function() return game.ReplicatedStorage:FindFirstChild("Remotes") end)
	if ok and remotes then pa = remotes:FindFirstChild("ParryAttempt") end
	if not pa then return end

	local origFireServer = pa.FireServer
	if type(origFireServer) ~= "function" then return end

	ParryCaptureTarget = origFireServer
	ParryCaptureOrig = origFireServer

	hookfunction(origFireServer, function(self, ...)
		local args = { ... }

		if self == pa and not checkcaller() then
			local serverTime = workspace:GetServerTimeNow()

			-- Multi-arg format: FireServer(CFrame, hash, OTP, ...)
			if #args >= 5 and type(args[2]) == "string" and type(args[3]) == "string" then
				ParryHookState.prevArgs = ParryHookState.parryArgs
				ParryHookState.parryRemote = self
				ParryHookState.parryArgs = args
				ParryHookState.parryHash = args[2]
				ParryHookState.parryTime = os.clock()
				ParryHookState.parryServerTime = serverTime
				ParryHookState.parryRecoveredKey = _recoverOTP(args[3], serverTime)
				ParryHookState.parryDerivedKey = ParryHookState.parryRecoveredKey
				UninstallParryCapture()
			-- Single-arg format: FireServer(OTPstring)
			elseif #args == 1 and type(args[1]) == "string" and #args[1] >= 8 then
				ParryHookState.prevArgs = ParryHookState.parryArgs
				ParryHookState.parryRemote = self
				ParryHookState.parryArgs = args
				ParryHookState.parryHash = nil
				ParryHookState.parryTime = os.clock()
				ParryHookState.parryServerTime = serverTime
				ParryHookState.parryRecoveredKey = _recoverOTP(args[1], serverTime)
				ParryHookState.parryDerivedKey = ParryHookState.parryRecoveredKey
				UninstallParryCapture()
			end
		end

		return origFireServer(self, ...)
	end)

	ParryCaptureInstalled = true
end

ParryRemote = {
	parryRemote = nil,
	ready = false,
}

function ParryRemote.fire(curveCFrame, screenPositions, mouseLocation)
	if not ParryHookState.parryArgs or not ParryHookState.parryDerivedKey then
		return false
	end

	local freshOTP = makeParryOTP()
	if not freshOTP then return false end

	local remote = ParryHookState.parryRemote
	if not remote or not remote:IsA("RemoteEvent") then
		return false
	end

	-- Single-arg OTP fire
	local ok = pcall(function()
		remote:FireServer(freshOTP)
	end)
	return ok == true
end

task.spawn(InstallParryCapture)

_CachedModeValue = nil
_CachedCurveMode = nil
_CachedBallsFolder = nil
_LocalRemoteArgs = {}

BallCache = {}
BallCacheFrame = 0
CandidateCache = {}
CandidateCount = 0
BestCandidate = nil
BestCandidateTTI = math.huge
BestCandidateFrame = 0
CandidateSelectionTime = 0

_CachedCursorCFrame = nil
_CachedCursorFrame = 0
_CachedCurveCFrame = nil
_CachedCurveFrame = 0
_CachedMouseScreenPos = {0, 0}
_CachedMouseFrame = 0
_CachedCharacter = nil
_CachedHrp = nil
_CachedCharFrame = 0

function IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

Main = {
	__properties = {
		__parries = 0,
		__first_parry_done = false,
		__is_mobile = IsMobile(),
		__grab_animation = nil,
		__cachedCameraCFrame = nil,
		__cachedMousePosition = nil,
	},
	__config = {
		__curve_names = { "Random", "Fast", "Backwards", "Slow", "High", "Camera" }
	}
}

Main.animation = {}

function Main.animation.play_grab_parry_force()
	local character = Player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not humanoid or not animator then return end

	local SwordAPIModule = ReplicatedStorage:FindFirstChild("Shared") and ReplicatedStorage.Shared:FindFirstChild("SwordAPI")
	if not SwordAPIModule then return end
	local SwordAPI = require(SwordAPIModule)
	local collection = SwordAPIModule:FindFirstChild("Collection")
	if not collection then return end

	local animCollection, swordType

	if AutoParry.SkinChangerEnabled then
		local ctrl = SkinChanger.SwordsController or FindSwordsController()
		if ctrl then
			animCollection = ctrl.AnimationCollection
			swordType = ctrl.SwordType
		end
	end

	if not animCollection then
		local sword_name = character:GetAttribute("CurrentlyEquippedSword")
		if sword_name then
			local ok, sword_data = pcall(function()
				return ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(sword_name)
			end)
			if ok and sword_data then
				animCollection = sword_data.AnimationType
				swordType = sword_data.SwordType
			end
		end
	end

	if not animCollection then
		animCollection = "Single"
		swordType = "Single"
	end

	local parry_animation
	for _, anim in SwordAPI:GetAnimations(character, { "Parry", "GrabParry" }, animCollection, swordType) do
		if not parry_animation then
			parry_animation = anim
		end
	end

	if not parry_animation then
		parry_animation = collection:FindFirstChild("Default") and collection.Default:FindFirstChild("GrabParry")
	end
	if not parry_animation then return end

	if Main.__properties.__grab_animation and Main.__properties.__grab_animation.IsPlaying then
		Main.__properties.__grab_animation:Stop()
	end
	Main.__properties.__grab_animation = animator:LoadAnimation(parry_animation)
	Main.__properties.__grab_animation.Priority = Enum.AnimationPriority.Action4
	Main.__properties.__grab_animation:Play()
end

function Main.animation.play_grab_parry()
	if not AutoParry.PlayAnimationEnabled then return end
	Main.animation.play_grab_parry_force()
end

Main.player = {}

function Main.player.get_closest_to_cursor()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then
		return nil
	end

	local ClosestTarget = nil
	local BestDot = -math.huge
	local Camera = workspace.CurrentCamera

	if not Alive then return nil end

	local MouseSuccess, mouse_location = pcall(function()
		return UserInputService:GetMouseLocation()
	end)

	if not MouseSuccess then return nil end

	MouseRay = Camera:ScreenPointToRay(mouse_location.X, mouse_location.Y)
	LookCFrame = CFrame.lookAt(MouseRay.Origin, MouseRay.Origin + MouseRay.Direction)

	for Index, AlivePlayer in pairs(Alive:GetChildren()) do
		if AlivePlayer == LocalPlayer.Character then continue end
		if not AlivePlayer:FindFirstChild('HumanoidRootPart') then continue end

		local DirectionToPlayer = (AlivePlayer.HumanoidRootPart.Position - Camera.CFrame.Position).Unit
		local DotProduct = LookCFrame.LookVector:Dot(DirectionToPlayer)

		if DotProduct > BestDot then
			BestDot = DotProduct
			ClosestTarget = AlivePlayer
		end
	end

	return ClosestTarget
end

Main.curve = {}

function NormalizeCurveMode(value)
	return string.format("%.2f, %.2f, %.2f", value.X, value.Y, value.Z)
end

function Main.curve.get_cframe()
	local Camera = workspace.CurrentCamera
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not Camera then return CFrame.new() end

	local function CursorCFrame()
		local mousePos = UserInputService:GetMouseLocation()
		local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
		return CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + ray.Direction * 100)
	end

	if not root then return CursorCFrame() end
	if not AutoParry.CurveEnabled then return CursorCFrame() end

	Main.__properties.__cachedCameraCFrame = Camera.CFrame
	Main.__properties.__cachedMousePosition = UserInputService:GetMouseLocation()

	AutoParryPosition = HyperionPort.GetAutoParryPosition(root) or root.Position
	MouseRay = Camera:ViewportPointToRay(Main.__properties.__cachedMousePosition.X, Main.__properties.__cachedMousePosition.Y)
	CursorDirection = MouseRay.Direction
	TargetPosition = AutoParryPosition + CursorDirection * 100
	CurveMode = AutoParry.CurveMode or "Camera"
	selected = AutoParry.CurveModeSelected
	if type(selected) == "table" and #selected > 0 then
		AutoParry.CurveModeIndex = (AutoParry.CurveModeIndex % #selected) + 1
		CurveMode = selected[AutoParry.CurveModeIndex]
	end

	if CurveMode == "Random" then
		local DirectionToPlayer = (TargetPosition - AutoParryPosition)
		if DirectionToPlayer.Magnitude <= 0 then return CursorCFrame() end
		DirectionToPlayer = DirectionToPlayer.Unit
		local RandomOffset
		local RandomAttempts = 0
		repeat
			RandomOffset = Vector3.new(math.random(-4000, 4000), math.random(-4000, 4000), math.random(-4000, 4000))
			local DirectionToRandom = (TargetPosition + RandomOffset - AutoParryPosition)
			if DirectionToRandom.Magnitude <= 0 then DirectionToRandom = DirectionToPlayer else DirectionToRandom = DirectionToRandom.Unit end
			RandomAttempts += 1
		until DirectionToPlayer:Dot((TargetPosition + RandomOffset - AutoParryPosition).Unit) < 0.95 or RandomAttempts > 10
		return CFrame.new(AutoParryPosition, TargetPosition + RandomOffset)
	elseif CurveMode == "Fast" or CurveMode == "Accelerated" then
		return CFrame.new(AutoParryPosition, TargetPosition + Vector3.new(0, 5, 0))
	elseif CurveMode == "Backwards" then
		local DirectionToPlayer = (AutoParryPosition - TargetPosition)
		if DirectionToPlayer.Magnitude <= 0 then return CursorCFrame() end
		local BackwardTarget = AutoParryPosition + DirectionToPlayer.Unit * 10000 + Vector3.new(0, 1000, 0)
		return CFrame.new(Camera.CFrame.Position, BackwardTarget)
	elseif CurveMode == "Slow" then
		return CFrame.new(AutoParryPosition, TargetPosition + Vector3.new(0, -9e18, 0))
	elseif CurveMode == "High" then
		return CFrame.new(AutoParryPosition, TargetPosition + Vector3.new(0, 9e18, 0))
	elseif CurveMode == "Camera" then
		return CursorCFrame()
	end

	return CFrame.new(AutoParryPosition, TargetPosition + Vector3.new(0, 5, 0))
end

local _keypressJitterMin = 0.012
local _keypressJitterMax = 0.040

function ManualSpamFireParry(projectile)
    if AutoParry.ManualSpamMethod == "Keypress" then
        return FireButton() == true
    end
    local curveCFrame = Main.curve and Main.curve.get_cframe and Main.curve.get_cframe()
    return ParryRemote.fire(curveCFrame) == true
end

function FireParryRequest(Force, Source, SkipCooldown, targetBall)
	local CurrentTime = os.clock()

	if not SkipCooldown then
		if CurrentTime - RuntimeState.LastParryRequest < RuntimeState.ParryRequestCooldown then
			return false
		end

		RuntimeState.LastParryRequest = CurrentTime
	end

	AutoParry.LastRequest = Source or "parry"

	local ParryFired = false

	if _CachedCurveMode == nil or _CachedModeValue ~= AutoParry.Mode then
		_CachedModeValue = AutoParry.Mode
		_CachedCurveMode = NormalizeParryMethod(AutoParry.Mode)
		CurveMode = _CachedCurveMode
	end

  if _CachedCurveMode == "Keypress" then
 		ParryFired = FireButton() == true
 	else
 		ParryKeypressState.KeypressAttempts = ParryKeypressState.MaxKeypressAttempts
		local curveCFrame = Main.curve and Main.curve.get_cframe and Main.curve.get_cframe()
 		ParryFired = ParryRemote.fire(curveCFrame) == true
 		if not ParryFired then
 			ParryKeypressState.KeypressAttempts = math.min(ParryKeypressState.KeypressAttempts + 1, ParryKeypressState.MaxKeypressAttempts)
 			ParryFired = FireButton() == true
 		end
 	end

 	if ParryFired then
  		RuntimeState.LastAnyParryRequest = CurrentTime
  		if type(Force) == "userdata" then
  			ParriedBalls[Force] = CurrentTime
  		end
  	end

  	return ParryFired
  end

_ballCache = {}
_ballCacheFrame = 0
function _getBallsFolder()
	if _CachedBallsFolder and _CachedBallsFolder.Parent then
		return _CachedBallsFolder
	end
	_CachedBallsFolder = workspace:FindFirstChild("Balls")
	return _CachedBallsFolder
end

function GetBallTarget(ball)
	if not ball then return nil end
	local whitelist = ball:FindFirstChild("CollisionWhitelist")
	if whitelist and whitelist:IsA("ObjectValue") and whitelist.Value then
		return whitelist.Value.Name
	end
	local target = ball:GetAttribute("target")
	if typeof(target) == "Instance" then
		return target.Name
	end
	return target
end

function FindTargetedBall()
	if BallCacheFrame > 0 then
		local myName = Player.Name
		for ball, cache in pairs(BallCache) do
			if cache.Exists and cache.RealBall and not cache.Frozen and cache.Target == myName then
				return ball
			end
		end
		return nil
	end

	local Balls = _getBallsFolder()
	if not Balls then return nil end
	local myName = Player.Name
	for _, ball in ipairs(Balls:GetChildren()) do
		if ball:GetAttribute("realBall") ~= true then continue end
		if ball:GetAttribute("Frozen") == true then continue end
		if GetBallTarget(ball) == myName then
			return ball
		end
	end
	return nil
end

function FindTrainingBall()
	if BallCacheFrame > 0 then
		for ball, cache in pairs(BallCache) do
			if cache.Exists and cache.RealBall and not cache.Frozen and cache.Target and cache.Target ~= "" then
				return ball
			end
		end
		return nil
	end

	local Balls = _getBallsFolder()
	if not Balls then return nil end
	for _, ball in ipairs(Balls:GetChildren()) do
		if ball:GetAttribute("realBall") ~= true then continue end
		if ball:GetAttribute("Frozen") == true then continue end
		local target = GetBallTarget(ball)
		if target and target ~= "" then
			return ball
		end
	end
	return nil
end

function GetBallVelocity(Ball)
	if not Ball then return nil end
	local zoomies = Ball:FindFirstChild("zoomies")
	if zoomies then
		local zv = zoomies.VectorVelocity
		if zv and zv.Magnitude > 0 then return zv end
	end
	local alv = Ball.AssemblyLinearVelocity
	if alv and alv.Magnitude > 0 then return alv end
	return Ball.Velocity
end

_ballTrackerData = {}

function GetSmoothedBallVelocity(Ball)
	return GetBallVelocity(Ball)
end

function ClearBallSpeedTracker(Ball) end
function ResetBallSpeedTracker() end

Main.ball = {}

function Main.ball.get()
	return FindTargetedBall()
end

function Main.ball.get_all()
	local balls_table = {}
	local BallsFolder = workspace:FindFirstChild("Balls")
	if not BallsFolder then
		return balls_table
	end

	for _, ball in ipairs(BallsFolder:GetChildren()) do
		if ball:GetAttribute("realBall") then
			ball.CanCollide = false
			table.insert(balls_table, ball)
		end
	end
	return balls_table
end

ballTargetCache = {}
ballTargetCacheFrame = 0

function ClearBallStats()
	ballTargetCache = {}
	ballTargetCacheFrame = 0
end

function ResetAllParryFlags()
	vParryExecuted = false
	lowSpeedParryExecuted = false
	cframeParryExecuted = false
	coreParryExecuted = false
	minParryExecuted = false
	sustainedParryActive = false
end

function SetupBallWatcher(Ball)
end

function InitBallTracking()
    HyperionPort.BallTrackingConnection = Player.CharacterAdded:Connect(function()
        task.delay(1, function()
            AutoParry.CachedBlockButton = nil
            HyperionPort.ApplyHeadlessKorbloxDescription(Player.Character)
        end)
    end)
end

ProjectileLifecycle = setmetatable({}, { __mode = "k" })

function UpdateBallStats(Ball, hrp)
	if not Ball or not hrp then return nil, nil, nil end
	local ballPos = Ball.Position
	local hrpPos = hrp.Position
	local velocity = GetBallVelocity(Ball)
	local speed = velocity and velocity.Magnitude or 0
	local distance = (ballPos - hrpPos).Magnitude
	local eta = speed > 0 and (distance / speed) or math.huge
	return distance, speed, eta
end

function UpdateBallCache()
	BallCacheFrame += 1
	local ballsFolder = workspace:FindFirstChild("Balls")
	if not ballsFolder then return end

	local seen = {}
	for _, ball in ipairs(ballsFolder:GetChildren()) do
		seen[ball] = true
		local cache = BallCache[ball]
		if not cache then
			cache = {
				Position = ball.Position,
				PrevPos = ball.Position,
				Velocity = Vector3.zero,
				Speed = 0,
				Target = "",
				PrevTarget = "",
				Frozen = false,
				RealBall = false,
				Exists = true,
				Dirty = true,
				Distance = math.huge,
				TTI = math.huge,
				IsCurved = false,
				ParryAccuracy = 0,
				HrpPos = nil,
				Zoomies = nil,
				Whitelist = nil,
				HasComboCounter = false,
				AeroVFX = nil,
				CurveStreak = 0,
				LastUpdate = BallCacheFrame,
			}
			BallCache[ball] = cache
		elseif not cache.Exists then
			ParriedBalls[ball] = nil
			ProjectileLifecycle[ball] = nil
			ScheduledParries[ball] = nil
		end

		local pos = ball.Position

		local whitelist = cache.Whitelist
		if not whitelist or whitelist.Parent ~= ball then
			whitelist = ball:FindFirstChild("CollisionWhitelist")
			cache.Whitelist = whitelist
		end
		local target = GetBallTarget(ball)

		local zoomies = cache.Zoomies
		if not zoomies or zoomies.Parent ~= ball then
			zoomies = ball:FindFirstChild("zoomies")
			cache.Zoomies = zoomies
		end

		local frozen = ball:GetAttribute("Frozen") == true
		local realBall = ball:GetAttribute("realBall") == true

		if pos ~= cache.Position or target ~= cache.Target or frozen ~= cache.Frozen or realBall ~= cache.RealBall then
			cache.Dirty = true
		end

		cache.PrevPos = cache.Position
		cache.Position = pos
		cache.PrevTarget = cache.Target
		cache.Target = target or ""
		if cache.PrevTarget ~= Player.Name and cache.Target == Player.Name then
			ParriedBalls[ball] = nil
			ProjectileLifecycle[ball] = nil
			ScheduledParries[ball] = nil
		end
		cache.Frozen = frozen
		cache.RealBall = realBall
		cache.Exists = true
		cache.LastUpdate = BallCacheFrame

		cache.HasComboCounter = ball:FindFirstChild("ComboCounter") ~= nil
		local aero = cache.AeroVFX
		if not aero or aero.Parent ~= ball then
			aero = ball:FindFirstChild("AeroDynamicSlashVFX")
			cache.AeroVFX = aero
		end
	end

	for ball, cache in pairs(BallCache) do
		if not seen[ball] then
			cache.Exists = false
			cache.Dirty = true
		end
	end
end

function UpdateBallPhysicsCache()
	local hrp = _CachedHrp
	if not hrp then return end

	local PreClickEnabled = getgenv().AutoPreClick
	local PreClickSpeeds = PreClickEnabled and getgenv().Hyperion_PreClickSpeeds
	local ping = GetPing() or 0
	local pingThreshold = math.clamp(ping / 10, 5, 17)

	local hrpPos = hrp.Position
	for ball, cache in pairs(BallCache) do
		if not cache.Exists or cache.Frozen then
			if cache.Exists then
				cache.Distance = math.huge
				cache.TTI = math.huge
			end
		else
			local zoomies = cache.Zoomies
			local velocity
			if zoomies then
				local zv = zoomies.VectorVelocity
				if zv and zv.Magnitude > 0 then
					velocity = zv
				end
			end
			if not velocity then
				local alv = ball.AssemblyLinearVelocity
				if alv and alv.Magnitude > 0 then velocity = alv else velocity = ball.Velocity end
			end
			local speed = velocity and velocity.Magnitude or 0
			local distance = (cache.Position - hrpPos).Magnitude
			local tti = speed > 0 and (distance / speed) or math.huge

			cache.Velocity = velocity or Vector3.zero
			cache.Speed = speed
			cache.Distance = distance
			cache.TTI = tti
			cache.HrpPos = hrpPos

		local cappedSpeedDiff = math.min(math.max(speed - 9.5, 0), 650)
		local speedDivisor = (2.4 + cappedSpeedDiff * 0.002) * 0.7
		cache.ParryAccuracy = pingThreshold + math.max(speed / speedDivisor, 9.5)
		if AutoParry.RandomAccuracyEnabled then
			local minVal = math.clamp(SafeToNumber(AutoParry.RandomAccuracyMin, 0.05), 0.05, 1)
			local maxVal = math.clamp(SafeToNumber(AutoParry.RandomAccuracyMax, 0.95), 0.05, 1)
			local randomFactor = math.random() * (maxVal - minVal) + minVal
			cache.ParryAccuracy = cache.ParryAccuracy * randomFactor
		end
		cache.InstantCandidate = speed > 1300

			if cache.Target == Player.Name then
				if IsProjectileCurved(ball, zoomies, hrp, ping) then
					cache.CurveStreak = math.min(cache.CurveStreak + 1, 4)
				else
					cache.CurveStreak = math.max(cache.CurveStreak - 1, 0)
				end
				cache.IsCurved = cache.CurveStreak >= 2
			else
				cache.CurveStreak = 0
				cache.IsCurved = false
			end

			if PreClickEnabled and cache.Target and cache.Target ~= "" and cache.Target ~= Player.Name then
				if not PreClickSpeeds[cache.Target] then
					PreClickSpeeds[cache.Target] = {}
				end
				table.insert(PreClickSpeeds[cache.Target], speed)
				if #PreClickSpeeds[cache.Target] > 15 then
					table.remove(PreClickSpeeds[cache.Target], 1)
				end
			end
		end
	end
end

function UpdateCandidateCache()
	CandidateCount = 0
	local now = os.clock()

	for ball, cache in pairs(BallCache) do
		local valid = true

		if not cache.Exists then valid = false end
		if valid and not cache.RealBall then valid = false end
		if valid and cache.Frozen then valid = false end
		if valid and cache.IsCurved then valid = false end
		if valid and cache.Target ~= Player.Name then valid = false end
		if valid and ParriedBalls[ball] and now - ParriedBalls[ball] < 0.5 then valid = false end
		if valid and IsProjectileExecuted(ball) then valid = false end
		if valid and cache.Distance > AutoParry.MaxParryDistance then valid = false end
		if valid and cache.Speed < 3 then valid = false end

		if valid and cache.Distance <= cache.ParryAccuracy then
			CandidateCount += 1
			CandidateCache[CandidateCount] = ball
		end
	end
end

function UpdateBestCandidate()
	BestCandidate = nil
	BestCandidateTTI = math.huge
	BestCandidateFrame = BallCacheFrame

	if CandidateCount == 0 then
		return
	end

	for i = 1, CandidateCount do
		local ball = CandidateCache[i]
		local cache = BallCache[ball]
		if cache and cache.Exists and cache.TTI < BestCandidateTTI and cache.Distance <= cache.ParryAccuracy then
			BestCandidate = ball
			BestCandidateTTI = cache.TTI
		end
	end
end

function UpdateRemotePreparationCache()
	local char, hrp = GetCharacter()
	if char ~= _CachedCharacter or hrp ~= _CachedHrp then
		_CachedCharacter = char
		_CachedHrp = hrp
		_CachedCharFrame = BallCacheFrame
		for _, cache in pairs(BallCache) do
			cache.Dirty = true
		end
	end

	local cam = workspace.CurrentCamera
	if cam then
		local mousePos = UserInputService:GetMouseLocation()
		local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
		local cursorCFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + ray.Direction * 100)

		if cursorCFrame ~= _CachedCursorCFrame then
			_CachedCursorCFrame = cursorCFrame
			_CachedCursorFrame = BallCacheFrame
		end

		local curveCFrame = Main.curve.get_cframe()
		if curveCFrame ~= _CachedCurveCFrame then
			_CachedCurveCFrame = curveCFrame
			_CachedCurveFrame = BallCacheFrame
		end

		_CachedMouseScreenPos[1] = mousePos.X
		_CachedMouseScreenPos[2] = mousePos.Y
		_CachedMouseFrame = BallCacheFrame
	end
end

function WorkerB()
	local emergencyCandidate = nil
	local instantCandidate = nil
	local emergencyTTI = math.huge
	local instantSpeed = -1

	for ball, cache in pairs(BallCache) do
		if not cache.Exists or not cache.RealBall or cache.Frozen then continue end
		if cache.Target ~= Player.Name then continue end
		if IsProjectileExecuted(ball) then continue end
		if cache.Speed < 3 then continue end

		if cache.InstantCandidate then
			if cache.Speed > instantSpeed then
				instantCandidate = ball
				instantSpeed = cache.Speed
			end
		end

		if cache.Distance <= CLOSE_RANGE_EMERGENCY_DIST or cache.TTI < 0.03 then
			if cache.TTI < emergencyTTI then
				emergencyCandidate = ball
				emergencyTTI = cache.TTI
			end
		end
	end

	RuntimeState.EmergencyCandidate = emergencyCandidate
	RuntimeState.InstantCandidate = instantCandidate
end

function GetProjectileState(projectile)
	if not projectile then return nil end
	if not projectile.Parent then return "completed" end
	if not projectile:GetAttribute("realBall") then return nil end
	return "eligible"
end

function GetProjectileLifecycle(projectile)
	if not projectile then return nil end
	return ProjectileLifecycle[projectile]
end

function SetProjectileLifecycle(projectile, phase)
	if not projectile then return end
	ProjectileLifecycle[projectile] = phase
end

function IsProjectileExecuted(projectile)
	if not projectile then return false end
	return ProjectileLifecycle[projectile] == "executed"
end

function DispatchParry(projectile, force, source, skipCooldown, skipLifecycle)
	if not FireParryRequest then
		return false
	end
	if not skipLifecycle and projectile then
		if IsProjectileExecuted(projectile) then
			return false
		end
		SetProjectileLifecycle(projectile, "executed")
	end
	local ok = FireParryRequest(force, source, skipCooldown, projectile)
	if ok and projectile and not skipLifecycle then
		ParriedBalls[projectile] = os.clock()
	end
	return ok
end

BallCurveState = setmetatable({}, { __mode = "k" })

function linear_predict(a, b, time_volume)
	return a + (b - a) * time_volume
end

function IsProjectileCurved(projectile, cachedZoomies, cachedPrim, cachedPing)
	if not projectile then return false end

	local zoomies = cachedZoomies
	if not zoomies then
		zoomies = projectile:FindFirstChild('zoomies')
	end
	if not zoomies then return false end

	local velocity = zoomies.VectorVelocity
	if not velocity or velocity.Magnitude <= 0 then return false end

	local prim = cachedPrim
	if not prim then
		local char = Player.Character
		prim = char and (char.PrimaryPart or char:FindFirstChild('HumanoidRootPart'))
	end
	if not prim then return false end

	local direction = (prim.Position - projectile.Position).Unit
	local ballDirection = velocity.Unit
	local dot = direction:Dot(ballDirection)
	local speed = velocity.Magnitude
	local speedThreshold = math.min(speed / 100, 40)

	local directionDifference = (ballDirection - velocity).Unit
	local directionSimilarity = direction:Dot(directionDifference)
	local dotDifference = dot - directionSimilarity
	local distance = (prim.Position - projectile.Position).Magnitude

	local ping = cachedPing or GetPing() or 0
	local dotThreshold = 0.5 - (ping / 1000)
	local reachTime = distance / math.max(speed, 0.001) - (ping / 1000)

	local ballDistanceThreshold = 15 - math.min(distance / 1000, 15) + speedThreshold

	local clampedDot = math.clamp(dot, -1, 1)
	local radians = math.rad(math.asin(clampedDot))

	local state = BallCurveState[projectile]
	if not state then
		state = { __lerp_radians = 0, __last_warping = tick(), __curving = tick() }
		BallCurveState[projectile] = state
	end
	state.__lerp_radians = linear_predict(state.__lerp_radians, radians, 0.8)

	if speed > 0 and reachTime > ping / 10 then
		ballDistanceThreshold = math.max(ballDistanceThreshold - 15, 15)
	end

	if distance < ballDistanceThreshold then return false end
	if dotDifference < dotThreshold then return true end

	if state.__lerp_radians < 0.018 then
		state.__last_warping = tick()
	end

	if (tick() - state.__last_warping) < (reachTime / 1.5) then
		return true
	end

	if (tick() - state.__curving) < (reachTime / 1.5) then
		return true
	end

	return dot < dotThreshold
end

function ComputeVantaSpamRadius(projectile)
	if not projectile then return 0 end

	velocity = GetBallVelocity(projectile)
	if not velocity or velocity.Magnitude <= 0 then return 0 end

	char = Player.Character
	if not char or not char.PrimaryPart then return 0 end

	toPlayer = (char.PrimaryPart.Position - projectile.Position)
	distToBall = toPlayer.Magnitude
	if distToBall <= 0 then return 0 end

	speed = velocity.Magnitude
	dot = toPlayer.Unit:Dot(velocity.Unit)
	pingMs = GetPing() or 0
	baseRadius = pingMs + math.min(speed / 6, 6)

	if distToBall > baseRadius then
		return 0
	end

	dotBonus = 5 - math.min(speed / 5, 5)
	dotPenalty = math.clamp(dot, -1, 0) * dotBonus
	return baseRadius - dotPenalty
end

function ValidateProjectile(projectile)
	if not projectile then return false, "no-projectile" end
	if not projectile.Parent then return false, "destroyed" end

	realBall = projectile:GetAttribute("realBall")
	if realBall == false then return false, "not-real-ball" end

	if projectile:GetAttribute("Frozen") == true then return false, "frozen" end

	target = GetBallTarget(projectile)
	isTargetingMe = target == Player.Name

	char = Player.Character
	if not char then return false, "no-character" end

	hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false, "no-hrp" end

	velocity = GetBallVelocity(projectile)
	speed = velocity and velocity.Magnitude or 0

	distance = (projectile.Position - hrp.Position).Magnitude

	if speed <= 0 and distance > 50 then return false, "stopped-far" end
	if distance > AutoParry.MaxParryDistance + 100 and speed < 500 then return false, "too-far-slow" end

	if not isTargetingMe then
		if AutoParry.ParryFOV < 360 then
			local cam = workspace.CurrentCamera
			if cam then
				local toProjectile = (projectile.Position - cam.CFrame.Position).Unit
				local inFront = cam.CFrame.LookVector:Dot(toProjectile)
				local fovRad = math.rad(AutoParry.ParryFOV * 0.5)
				if inFront < math.cos(fovRad) then
					return false, "outside-fov"
				end
			end
		end
	end

	return true, isTargetingMe and "self" or "other"
end

function GetAdaptiveThreshold(projectile, hrp, ping)
	baseThreshold = 1.05 - math.min(AutoParry.Threshold, 0.95)

	pingSeconds = math.min(ping / 1000, 0.2)
	baseThreshold = baseThreshold + pingSeconds

	if AutoParry.TickRateAware then
		local tickRate = RuntimeState.ServerTickRate
		local tickTime = 1 / math.max(tickRate, 30)
		baseThreshold = baseThreshold + tickTime * 0.5
	end

	if AutoParry.SmartLeadEnabled then
		local velocity = GetBallVelocity(projectile)
		local speed = velocity and velocity.Magnitude or 0
		if speed > 300 then
			baseThreshold = baseThreshold + math.min(speed * 0.00008, 0.06)
		end
	end

	return math.max(baseThreshold, 0.15)
end

function SmoothValue(current, target, alpha, dt)
	alpha = alpha or 0.2
	dt = dt or 1/60
	factor = 1 - (1 - alpha) ^ (dt * 60)
	return current + (target - current) * math.min(factor, 1)
end

function IsInFieldOfView(projectile, hrpPosition)
	if AutoParry.ParryFOV >= 360 then return true end

	cam = workspace.CurrentCamera
	if not cam or not projectile then return true end

	directionToBall = (projectile.Position - cam.CFrame.Position).Unit
	inFront = cam.CFrame.LookVector:Dot(directionToBall)
	fovAngle = math.rad(AutoParry.ParryFOV * 0.5)

	return inFront >= math.cos(fovAngle)
end

function FindReplicatedRemote(SettingName)
	local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if not RemotesFolder then
		return nil
	end

	return RemotesFolder:FindFirstChild(SettingName)
end

function FindAbilityButton()
	local PlayerGui = Player:FindFirstChildOfClass("PlayerGui") or PlayerGui
	local HotbarGui = PlayerGui and PlayerGui:FindFirstChild("Hotbar")
	return HotbarGui and HotbarGui:FindFirstChild("Ability") or nil
end

function IsAbilityReady()
	local AbilityButton = FindAbilityButton()
	local AbilityGradient = AbilityButton and AbilityButton:FindFirstChild("UIGradient")
	local OffsetVector = AbilityGradient and AbilityGradient.Offset
	return OffsetVector and OffsetVector.Y == 0.5
end

function AbilityReadyAlias()
	return IsAbilityReady()
end

function AlwaysTrue()
	return true
end

function GetAlivePlayerPositions()
	local PlayerPositions = {}

	for Index, OtherPlayer in ipairs(Players:GetPlayers()) do
		if OtherPlayer ~= Player then
			local Character = OtherPlayer.Character
			local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
			local humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if hrp and humanoid and humanoid.Health > 0 then
				PlayerPositions[OtherPlayer.Name] = hrp.Position
			end
		end
	end

	local AliveFolder = workspace:FindFirstChild("Alive")

	if AliveFolder then
		for Index, AliveModel in ipairs(AliveFolder:GetChildren()) do
			if AliveModel.Name ~= Player.Name then
				local hrp = AliveModel:FindFirstChild("HumanoidRootPart")
				local humanoid = AliveModel:FindFirstChildOfClass("Humanoid")

				if hrp and humanoid and humanoid.Health > 0 then
					PlayerPositions[AliveModel.Name] = hrp.Position
				end
			end
		end
	end

	return PlayerPositions
end

function GetClosestAliveByDistance()
	char = Player.Character
	if not char then return nil end
	hrp = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChildWhichIsA('BasePart')
	if not hrp then return nil end
	aliveFolder = workspace:FindFirstChild('Alive')
	if not aliveFolder then return nil end
	closest = nil
	best = math.huge
	for _, m in ipairs(aliveFolder:GetChildren()) do
		if m ~= Player.Character then
			local part = m:FindFirstChild('HumanoidRootPart') or m:FindFirstChildWhichIsA('BasePart')
			if part then
				local d = (part.Position - hrp.Position).Magnitude
				if d < best then
					best = d
					closest = m
				end
			end
		end
	end
	return closest
end

function ExecuteAutoAbility()
	if not AutoParry.AutoAbilityEnabled then return false end
	if not IsAbilityReady() then return false end
	local Character = Player.Character
	if not Character then return false end
	local Abilities = Character:FindFirstChild("Abilities")
	if not Abilities then return false end
	for _, ability in Abilities:GetChildren() do
		local name = ability.Name
		if (name == "Raging Deflection" or name == "Rapture" or name == "Calming Deflection" or name == "Aerodynamic Slash" or name == "Fracture" or name == "Death Slash") and ability.Enabled then
			local AbilityRemote = ReplicatedStorage and ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("AbilityButtonPress")
			if AbilityRemote and AbilityRemote:IsA("RemoteEvent") then
				AbilityRemote:FireServer()
				task.delay(2.432, function()
					local DeathSlashRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DeathSlashShootActivation")
					if DeathSlashRemote and DeathSlashRemote:IsA("RemoteEvent") then
						DeathSlashRemote:FireServer(true)
					end
				end)
				return true
			end
		end
	end
	return false
end

function ExecuteForceSkill()
	if ExecuteAutoAbility() then return true end
	return false
end

function IsTriggerBotActive()
	return RuntimeState.TriggerBotEnabled
end

function IsBallTargetingPlayer(Ball)
	if not Ball then return false end
	if Ball:GetAttribute("realBall") ~= true then return false end
	if Ball:GetAttribute("Frozen") == true then return false end
	return GetBallTarget(Ball) == Player.Name
end

function FindAnyTargetBall()
	local PrimaryBall = FindTargetedBall()

	if PrimaryBall and IsBallTargetingPlayer(PrimaryBall) then
		return PrimaryBall
	end

	local TrainingBall = FindTrainingBall()

	if TrainingBall and IsBallTargetingPlayer(TrainingBall) then
		return TrainingBall
	end

	return nil
end

function ExecuteTriggerBot()
	return false
end

function FindAnyBallForAliveCheck()
	local PrimaryBall = FindTargetedBall()

	if PrimaryBall and IsBallTargetingPlayer(PrimaryBall) then
		return PrimaryBall
	end

	local TrainingBall = FindTrainingBall()

	if TrainingBall and IsBallTargetingPlayer(TrainingBall) then
		return TrainingBall
	end

	return nil
end

function IsBallNearAnyPlayer(Ball, DetectRadius)
	if not Ball then
		return false
	end

	for Index, OtherPlayer in ipairs(Players:GetPlayers()) do
		if OtherPlayer ~= Player then
			local Character = OtherPlayer.Character
			local hrp = Character and Character:FindFirstChild("HumanoidRootPart")

			if hrp and (hrp.Position - Ball.Position).Magnitude <= DetectRadius then
				return true
			end
		end
	end

	local AliveFolder = workspace:FindFirstChild("Alive")

	if AliveFolder then
		for Index, AliveModel in ipairs(AliveFolder:GetChildren()) do
			if AliveModel.Name ~= Player.Name then
				local hrp = AliveModel:FindFirstChild("HumanoidRootPart")
				local humanoid = AliveModel:FindFirstChildOfClass("Humanoid")

				if hrp and humanoid and humanoid.Health > 0 and (hrp.Position - Ball.Position).Magnitude <= DetectRadius then
					return true
				end
			end
		end
	end

	return false
end

function GetPlayerPosition(AliveModel)
	if not AliveModel or AliveModel == Player.Character or AliveModel.Name == Player.Name then
		return nil, false
	end

	local humanoid = AliveModel:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health <= 0 then
		return nil, false
	end

	local ActorInstance = AliveModel:IsA("Actor") and AliveModel or AliveModel:FindFirstChildWhichIsA("Actor", true)
	local hrp = AliveModel:FindFirstChild("HumanoidRootPart", true)
	if hrp and hrp:IsA("BasePart") then
		return hrp.Position, ActorInstance ~= nil
	end

	if ActorInstance then
		local ActorHRP = ActorInstance:FindFirstChild("HumanoidRootPart", true)
		if ActorHRP and ActorHRP:IsA("BasePart") then
			return ActorHRP.Position, true
		end

		local ActorBasePart = ActorInstance:FindFirstChildWhichIsA("BasePart", true)
		if ActorBasePart then
			return ActorBasePart.Position, true
		end
	end

	local BasePart = AliveModel:FindFirstChildWhichIsA("BasePart", true)
	return BasePart and BasePart.Position or nil, ActorInstance ~= nil
end

function CheckHighVelocityAliveSpam(Ball, BallSpeed)
	local AliveFolder = workspace:FindFirstChild("Alive")
	if not AliveFolder or not Ball then
		RuntimeState.HighVelocityAliveSpamActive = false
		return false
	end

	local CloseRadius = 15
	local FarRadius = 18
	local FarDetected = false
	local CloseDetected = false

	for Index, AliveModel in ipairs(AliveFolder:GetChildren()) do
		local Position, isActor = GetPlayerPosition(AliveModel)
		if Position then
			local SpeedThreshold = isActor and 1150 or 1200
			local distance = (Position - Ball.Position).Magnitude

			if BallSpeed >= SpeedThreshold and distance <= FarRadius then
				FarDetected = true
				if distance <= CloseRadius then
					CloseDetected = true
				end
			end
		end
	end

	if RuntimeState.HighVelocityAliveSpamActive then
		RuntimeState.HighVelocityAliveSpamActive = FarDetected
	else
		RuntimeState.HighVelocityAliveSpamActive = CloseDetected
	end

	return RuntimeState.HighVelocityAliveSpamActive
end

function ClampSpamMultiplier(SpamMultiplier, boosted)
	local ClampedMultiplier = math.clamp(math.floor(SafeToNumber(SpamMultiplier, 1)), 1, 50)
	local MaxLimit = boosted and 50 or 34

	return math.clamp(ClampedMultiplier, 1, MaxLimit)
end

 	function ExecuteSpamBurst(Source, SpamMultiplier, ForceOverride, boosted, projectile)
	local CurrentTime = os.clock()
	local SpamCooldown = boosted and 0.08 or RuntimeState.SpamParryCooldown

	if not ForceOverride and CurrentTime - RuntimeState.LastAnyParryRequest < RuntimeState.AutoSpamAfterCoreDelay then
		return false
	end

	if CurrentTime - RuntimeState.LastSpamParryRequest < SpamCooldown then
		return false
	end


	if projectile and IsProjectileExecuted(projectile) then
		return false
	end

	if CurrentTime - RuntimeState.SpamRemoteWindowStart >= 1 then
		RuntimeState.SpamRemoteWindowStart = CurrentTime
		RuntimeState.SpamRemoteCount = 0
	end

	local SpamCount = ClampSpamMultiplier(SpamMultiplier, boosted == true)
	local ParryFired = false

	for Index = 1, SpamCount do
		if RuntimeState.SpamRemoteCount >= RuntimeState.SpamRemoteLimit then
			break
		end

		if DispatchParry(projectile, true, Source, true, true) then
			RuntimeState.SpamRemoteCount += 1
			ParryFired = true
		end
	end

 	if ParryFired then
 		RuntimeState.LastSpamParryRequest = CurrentTime
 		if projectile then
 			ParriedBalls[projectile] = CurrentTime
 			SetProjectileLifecycle(projectile, "executed")
 		end
 	end

 	return ParryFired
 end

function ExecuteAutoSpam()
	if not AutoParry.AutoSpamEnabled then return false end
	if not LocalPlayer.Character or LocalPlayer.Character ~= workspace:FindFirstChild("Alive") then return false end

	local Ball = FindTargetedBall()
	if not Ball then return false end

	if not Ball:FindFirstChild("zoomies") then return false end
	if Ball:GetAttribute("target") ~= Player.Name then return false end

	local ballVelocity = Ball.AssemblyLinearVelocity or Vector3.zero
	if ballVelocity.Magnitude == 0 then return false end

	local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local direction = (hrp.Position - Ball.Position)
	if direction.Magnitude == 0 then return false end
	local dot = direction.Unit:Dot(ballVelocity.Unit)
	local distance = Player:DistanceFromCharacter(Ball.Position)

	local ping = GetPing()
	local pingThreshold = math.clamp(ping / 40, 1, 16)
	local maximumSpamDistance = pingThreshold + math.min(ballVelocity.Magnitude / 6, 95)

	if dot > -0.25 and distance > maximumSpamDistance then return false end
	if distance > maximumSpamDistance then return false end

	local pulsed = Player.Character:GetAttribute("Pulsed")
	if pulsed then return false end

	local cps = math.clamp(SafeToNumber(AutoParry.AutoSpamMultiplier, 100), 1, 2000)
	local interval = 1 / cps

	RuntimeState.SpamAccumulator = (RuntimeState.SpamAccumulator or 0) + RuntimeState.FrameDelta
	if RuntimeState.SpamAccumulator < interval then
		return false
	end

	local count = 0
	while RuntimeState.SpamAccumulator >= interval do
		RuntimeState.SpamAccumulator = RuntimeState.SpamAccumulator - interval
		count = count + 1
		if count >= 50 then break end
	end

 	for _ = 1, count do
 		if RuntimeState.SpamRemoteCount >= RuntimeState.SpamRemoteLimit then break end
		local curveCFrame = Main.curve and Main.curve.get_cframe and Main.curve.get_cframe()
 		local result = ParryRemote.fire(curveCFrame)
 		if result then
 			RuntimeState.SpamRemoteCount += 1
 		end
 	end
 
 	return true
 end
 
 function ExecuteHighVelocityAliveSpam()
	if not AutoParry.Enabled then
		RuntimeState.HighVelocityAliveSpamActive = false
		return false
	end

	local Ball = FindTargetedBall() or FindTrainingBall()
	if not Ball then
		RuntimeState.HighVelocityAliveSpamActive = false
		return false
	end

	local velocity = GetBallVelocity(Ball)
	local BallSpeed = velocity and velocity.Magnitude or 0
	if BallSpeed < 1150 then
		RuntimeState.HighVelocityAliveSpamActive = false
		return false
	end

	if not CheckHighVelocityAliveSpam(Ball, BallSpeed) then
		return false
	end

	return ExecuteSpamBurst("high-velocity-alive-spam", AutoParry.AutoSpamMultiplier, true, true, Ball)
end

function ExecuteManualSpam()
	if not AutoParry.ManualSpamActive then return false end
	if not LocalPlayer.Character or LocalPlayer.Character.Parent ~= Alive then return false end

	local cps = math.clamp(SafeToNumber(AutoParry.ManualSpamMultiplier, 100), 1, 2000)
	local interval = 1 / cps

	RuntimeState.SpamAccumulator = (RuntimeState.SpamAccumulator or 0) + RuntimeState.FrameDelta
	if RuntimeState.SpamAccumulator < interval then
		return false
	end

	local count = 0
	while RuntimeState.SpamAccumulator >= interval do
		RuntimeState.SpamAccumulator = RuntimeState.SpamAccumulator - interval
		count = count + 1
		if count >= 50 then break end
	end

	if AutoParry.ManualSpamPlayAnimation then
		pcall(Main.animation.play_grab_parry_force)
	end

	local curveCFrame = Main.curve and Main.curve.get_cframe and Main.curve.get_cframe()
	for _ = 1, count do
		if RuntimeState.SpamRemoteCount >= RuntimeState.SpamRemoteLimit then break end
		local result = ParryRemote.fire(curveCFrame)
		if result then
			RuntimeState.SpamRemoteCount += 1
		end
	end

	return true
end

RuntimeState.SpamQueueLastProcess = os.clock()

function ProcessSpamQueue()
	if RuntimeState.SpamQueueProcessing then
		if os.clock() - (RuntimeState.SpamQueueProcessingStarted or 0) < 1 then
			return
		end
		RuntimeState.SpamQueueProcessing = false
	end
	if #RuntimeState.SpamQueue == 0 then return end

	RuntimeState.SpamQueueProcessing = true
	RuntimeState.SpamQueueProcessingStarted = os.clock()

	local CurrentTime = os.clock()
	local dt = CurrentTime - RuntimeState.SpamQueueLastProcess
	local maxThisFrame = math.floor(RuntimeState.SpamQueueRateLimit * dt)

	if maxThisFrame <= 0 then
		RuntimeState.SpamQueueProcessing = false
		return
	end

	local processed = 0
	local batchLimit = math.min(maxThisFrame, RuntimeState.SpamQueueBatchSize)
	while #RuntimeState.SpamQueue > 0 and processed < batchLimit do
		local task = table.remove(RuntimeState.SpamQueue, 1)
		if task and task.remote and task.remote.Parent and task.args then
			local ok = pcall(function()
				if task.remote:IsA("RemoteEvent") then
					task.remote:FireServer(unpack(task.args))
				elseif task.remote:IsA("RemoteFunction") then
					task.remote:InvokeServer(unpack(task.args))
				end
			end)
			if ok then
				processed += 1
			end
		end
	end

	RuntimeState.SpamQueueLastProcess = CurrentTime
	RuntimeState.SpamQueueProcessing = false

	if #RuntimeState.SpamQueue > 0 then
		task.defer(ProcessSpamQueue)
	end
end

function UpdateManualSpamButtonUI()
	local btn = RuntimeState.ManualSpamButton
	if not btn then
		return
	end

	local StatusLabel = btn:FindFirstChild("Status")
	local TitleLabel = btn:FindFirstChild("Title")
	local btnStroke = btn:FindFirstChild("UIStroke")

	local isOn = AutoParry.ManualSpamActive
	if StatusLabel then
		StatusLabel.Text = isOn and "ON" or "OFF"
	end

	local accent = isOn and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 45, 55)
	if btnStroke then
		btnStroke.Color = accent
	end
	if TitleLabel then
		TitleLabel.TextColor3 = accent
	end
	if StatusLabel then
		StatusLabel.TextColor3 = accent
		StatusLabel.BackgroundColor3 = isOn and Color3.fromRGB(32, 50, 40) or Color3.fromRGB(32, 38, 51)
	end
end

function DestroyManualSpamUI()
	if RuntimeState.ManualSpamGui then
		RuntimeState.ManualSpamGui:Destroy()
	end

	RuntimeState.ManualSpamGui = nil
	RuntimeState.ManualSpamButton = nil
	AutoParry.ManualSpamActive = false
end

function CreateManualSpamButton()
	if not IsMobile() then
		DestroyManualSpamUI()
		return
	end

	if RuntimeState.ManualSpamGui and RuntimeState.ManualSpamButton then
		UpdateManualSpamButtonUI()
		return
	end

	local v41 = Instance.new("ScreenGui")
	v41.Name = "HyperionManualSpam"
	v41.ResetOnSpawn = false
	v41.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	v41.Parent = PlayerGui

	local ManualSpamButton = Instance.new("TextButton")
	ManualSpamButton.Name = "ManualSpamButton"
	ManualSpamButton.Size = UDim2.fromOffset(200, 44)
	ManualSpamButton.Position = UDim2.new(0.5, -100, 0.65, 0)
	ManualSpamButton.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
	ManualSpamButton.BackgroundTransparency = 0.15
	ManualSpamButton.BorderSizePixel = 0
	ManualSpamButton.Text = ""
	ManualSpamButton.Active = true
	ManualSpamButton.Selectable = true
	ManualSpamButton.Draggable = true
	ManualSpamButton.Parent = v41

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = ManualSpamButton

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = Color3.fromRGB(255, 45, 55)
	btnStroke.Transparency = 0.3
	btnStroke.Thickness = 1
	btnStroke.Parent = ManualSpamButton

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -16, 1, 0)
	title.Position = UDim2.fromOffset(10, 0)
	title.BackgroundTransparency = 1
	title.Text = "Manual Spam"
	title.TextColor3 = Color3.fromRGB(255, 45, 55)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.Parent = ManualSpamButton

	local StatusLabel = Instance.new("TextButton")
	StatusLabel.Name = "Status"
	StatusLabel.Size = UDim2.fromOffset(52, 26)
	StatusLabel.Position = UDim2.new(1, -60, 0.5, -13)
	StatusLabel.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
	StatusLabel.BackgroundTransparency = 0
	StatusLabel.BorderSizePixel = 0
	StatusLabel.Text = "OFF"
	StatusLabel.TextColor3 = Color3.fromRGB(255, 45, 55)
	StatusLabel.Font = Enum.Font.GothamBold
	StatusLabel.TextSize = 12
	StatusLabel.AutoButtonColor = false
	StatusLabel.Parent = ManualSpamButton

	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(0, 4)
	sCorner.Parent = StatusLabel

	StatusLabel.MouseButton1Click:Connect(function()
		AutoParry.ManualSpamActive = not AutoParry.ManualSpamActive
		UpdateManualSpamButtonUI()
		if AutoParry.ManualSpamNotify then
			NotifyToggleState("Manual Spam", AutoParry.ManualSpamActive)
		end
	end)

	RuntimeState.ManualSpamGui = v41
	RuntimeState.ManualSpamButton = ManualSpamButton
	UpdateManualSpamButtonUI()
end

function UpdateManualSpamButtonVisibility()
	if IsMobile() then
		CreateManualSpamButton()
	else
		DestroyManualSpamUI()
	end
end

function SetManualSpamButtonEnabled(value)
	UpdateManualSpamButtonVisibility()
end

function DestroyTriggerBotUI()
	if RuntimeState.TriggerBotGui then
		RuntimeState.TriggerBotGui:Destroy()
		RuntimeState.TriggerBotGui = nil
		RuntimeState.TriggerBotButton = nil
	end
end

function CreateTriggerBotButton()
	if not IsMobile() then
		DestroyTriggerBotUI()
		return
	end
	if RuntimeState.TriggerBotGui and RuntimeState.TriggerBotButton then
		return
	end
	local sg = Instance.new("ScreenGui")
	sg.Name = "HyperionTriggerBot"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = PlayerGui

	local btn = Instance.new("TextButton")
	btn.Name = "TriggerBotButton"
	btn.Size = UDim2.fromOffset(160, 44)
	btn.Position = UDim2.new(0.5, -80, 0.82, 0)
	btn.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
	btn.BackgroundTransparency = 0.15
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.Active = true
	btn.Selectable = true
	btn.Draggable = true
	btn.Parent = sg

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = Color3.fromRGB(255, 45, 55)
	btnStroke.Transparency = 0.3
	btnStroke.Thickness = 1
	btnStroke.Parent = btn

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -16, 1, 0)
	title.Position = UDim2.fromOffset(8, 0)
	title.BackgroundTransparency = 1
	title.Text = "TriggerBot"
	title.TextColor3 = Color3.fromRGB(255, 45, 55)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.Parent = btn

	local status = Instance.new("TextButton")
	status.Name = "Status"
	status.Size = UDim2.fromOffset(52, 26)
	status.Position = UDim2.new(1, -60, 0.5, -13)
	status.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
	status.BackgroundTransparency = 0
	status.BorderSizePixel = 0
	status.Text = "OFF"
	status.TextColor3 = Color3.fromRGB(255, 45, 55)
	status.Font = Enum.Font.GothamBold
	status.TextSize = 12
	status.AutoButtonColor = false
	status.Parent = btn

	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(0, 4)
	sCorner.Parent = status

	status.MouseButton1Click:Connect(function()
		if not AutoParry.TriggerBotEnabled then
			AutoParry.TriggerBotEnabled = true
			NotifyToggleState("TriggerBot", true)
		else
			AutoParry.TriggerBotEnabled = false
			NotifyToggleState("TriggerBot", false)
		end
		UpdateTriggerBotButtonUI()
	end)

	RuntimeState.TriggerBotGui = sg
	RuntimeState.TriggerBotButton = btn
	UpdateTriggerBotButtonUI()
end

function UpdateTriggerBotButtonUI()
	local btn = RuntimeState.TriggerBotButton
	if not btn then return end
	local status = btn:FindFirstChild("Status")
	local title = btn:FindFirstChild("Title")
	local btnStroke = btn:FindFirstChild("UIStroke")
	local isOn = AutoParry.TriggerBotEnabled
	if status then
		status.Text = isOn and "ON" or "OFF"
	end
	local accent = isOn and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 45, 55)
	if btnStroke then
		btnStroke.Color = accent
	end
	if title then
		title.TextColor3 = accent
	end
	if status then
		status.TextColor3 = accent
		status.BackgroundColor3 = isOn and Color3.fromRGB(32, 50, 40) or Color3.fromRGB(32, 38, 51)
	end
end

function UpdateTriggerBotButtonVisibility()
	if IsMobile() then
		CreateTriggerBotButton()
	else
		DestroyTriggerBotUI()
	end
end

DetectionConnections = {}
v227 = false
v228 = 0

function DisconnectDetectionEvent(SettingName)
	if DetectionConnections[SettingName] then
		DetectionConnections[SettingName]:Disconnect()
		DetectionConnections[SettingName] = nil
	end
end

function ConnectDetectionEvent(PathSegments, RemoteMethod, callback)
	DisconnectDetectionEvent(RemoteMethod)

	local DetectionRemote = ReplicatedStorage
	for Index, SettingName in ipairs(PathSegments) do
		DetectionRemote = DetectionRemote and DetectionRemote:FindFirstChild(SettingName)
	end

	if DetectionRemote and DetectionRemote:IsA("RemoteEvent") then
		DetectionConnections[RemoteMethod] = DetectionRemote.OnClientEvent:Connect(callback)
		return true
	end

	return false
end

function SetInfinityDetection(value)
	AutoParry.InfinityDetectionEnabled = value == true
	NotifyToggleState("Infinity Detection", AutoParry.InfinityDetectionEnabled)
end

function SetSlashesOfFuryDetection(value)
	AutoParry.SlashesOfFuryDetectionEnabled = value == true
	NotifyToggleState("Slashes Of Fury Detection", AutoParry.SlashesOfFuryDetectionEnabled)
end

function HyperionPort.SetAerodynamicSlash(value)
	AutoParry.AerodynamicSlashEnabled = value == true
	NotifyToggleState("Aerodynamic Slash Detection", AutoParry.AerodynamicSlashEnabled)
end

function IsLocalPlayerArg(value)
	return value == Player
		or value == Player.Name
		or value == Player.UserId
		or (typeof(value) == "Instance" and value.Name == Player.Name)
end

function SetTimeHoleDetection(value)
	AutoParry.TimeHoleDetectionEnabled = value == true
	NotifyToggleState("Time Hole Detection", AutoParry.TimeHoleDetectionEnabled)
end

function SetDeathSlashDetection(value)
	AutoParry.DeathSlashDetectionEnabled = value == true
	NotifyToggleState("Death Slash Detection", AutoParry.DeathSlashDetectionEnabled)
end

function SetSingularityDetection(value)
	AutoParry.SingularityDetectionEnabled = value == true
	NotifyToggleState("Singularity Detection", AutoParry.SingularityDetectionEnabled)
end

function ShouldSkipAutoParryCalculations()
	return not AutoParry.Enabled
end

function ExecuteSlashesOfFuryParry()
	if v227 then
		return
	end

	v227 = true
	v228 = 0

	task.spawn(function()
		while v227 and AutoParry.SlashesOfFuryDetectionEnabled do
			if v228 >= math.max(1, math.floor(SafeToNumber(AutoParry.SlashesOfFuryMaxParryCount, 36))) then
				break
			end

			if type(ManualSpamFireParry) == "function" then
				ManualSpamFireParry()
			end
			v228 += 1
			task.wait(math.clamp(SafeToNumber(AutoParry.SlashesOfFuryParryDelay, 0.05), 0.05, 0.25))
		end

		v227 = false
	end)
end

ShownDetectionNotifications = {}

DETECTION_ABILITY_MAP = {
	Infinity = "InfinityDetectionEnabled",
	Time_Hole = "TimeHoleDetectionEnabled",
	Death_Slash = "DeathSlashDetectionEnabled",
	Singularity = "SingularityDetectionEnabled",
	Aerodynamic_Slash = "AerodynamicSlashEnabled",
}

DetectionMonitorConnection = nil
function StartAbilityDetectionMonitor()
	if DetectionMonitorConnection then
		DetectionMonitorConnection:Disconnect()
	end
	ShownDetectionNotifications = {}

	DetectionMonitorConnection = RunService.Heartbeat:Connect(function()
		if not _startupComplete then return end
		local AliveFolder = workspace:FindFirstChild("Alive")
		if not AliveFolder then return end

		local now = os.clock()
		local abilitiesInUse = {}

		for _, player in Players:GetPlayers() do
			if player ~= Player then
				local char = player.Character or (AliveFolder:FindFirstChild(player.Name))
				if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
					local equippedAbility = player:GetAttribute("EquippedAbility")
					if equippedAbility then
						local normalizedKey = equippedAbility:gsub("%s+", "_")
						for abilityName, configKey in pairs(DETECTION_ABILITY_MAP) do
							if normalizedKey == abilityName then
								abilitiesInUse[configKey] = true
								local notifyKey = player.UserId .. "_" .. abilityName
								if not ShownDetectionNotifications[notifyKey] then
									ShownDetectionNotifications[notifyKey] = now
									ShowNotification("Ability Detection\n" .. player.Name .. " is using " .. abilityName)
								end
							end
						end
					end
				end
			end
		end


		for key, stamp in pairs(ShownDetectionNotifications) do
			if now - stamp > 30 then
				ShownDetectionNotifications[key] = nil
			end
		end
	end)
end

function InitSpecialDetections()

	local v237 = ReplicatedStorage:FindFirstChild("Packages")
	v237 = v237 and v237:FindFirstChild("_Index")
	v237 = v237 and v237:FindFirstChild("sleitnick_net@0.1.0")
	v237 = v237 and v237:FindFirstChild("net")
	local v238 = v237 and v237:FindFirstChild("RE/SlashesOfFuryParry")
	local SlashesActivateRemote = v237 and v237:FindFirstChild("RE/SlashesOfFuryActivate")
	local SlashesEndRemote = v237 and v237:FindFirstChild("RE/SlashesOfFuryEnd")
	local SlashesCatchRemote = v237 and v237:FindFirstChild("RE/SlashesOfFuryCatch")

	DisconnectDetectionEvent("DetectionSlashesOfFury")
	if v238 and v238:IsA("RemoteEvent") then
		DetectionConnections.DetectionSlashesOfFury = v238.OnClientEvent:Connect(function()
			if AutoParry.SlashesOfFuryDetectionEnabled then
				ExecuteSlashesOfFuryParry()
			end
		end)
	end

	DisconnectDetectionEvent("DetectionSlashesOfFuryActivate")
	if SlashesActivateRemote and SlashesActivateRemote:IsA("RemoteEvent") then
		DetectionConnections.DetectionSlashesOfFuryActivate = SlashesActivateRemote.OnClientEvent:Connect(function(ActiveFlag)
			if IsLocalPlayerArg(ActiveFlag) then
				RuntimeState.SlashesOfFuryActive = true
				v228 = 0
			end
		end)
	end

	DisconnectDetectionEvent("DetectionSlashesOfFuryEnd")
	if SlashesEndRemote and SlashesEndRemote:IsA("RemoteEvent") then
		DetectionConnections.DetectionSlashesOfFuryEnd = SlashesEndRemote.OnClientEvent:Connect(function()
			RuntimeState.SlashesOfFuryActive = false
			v228 = 0
		end)
	end

	DisconnectDetectionEvent("DetectionSlashesOfFuryCatch")
	if SlashesCatchRemote and SlashesCatchRemote:IsA("RemoteEvent") then
		DetectionConnections.DetectionSlashesOfFuryCatch = SlashesCatchRemote.OnClientEvent:Connect(function()
			if AutoParry.SlashesOfFuryDetectionEnabled then
				ExecuteSlashesOfFuryParry()
			end
		end)
	end


	ConnectDetectionEvent({ "Remotes", "InfinityBall" }, "DetectionInfinityBall", function(ActiveFlag, ParryStateChanged)
		RuntimeState.InfinityOwner = ActiveFlag
		RuntimeState.InfinityActive = ParryStateChanged == true
	end)

	ConnectDetectionEvent({ "Remotes", "DeathBall" }, "DetectionDeathSlash", function(ActiveFlag, ParryStateChanged)
		RuntimeState.DeathSlashActive = ParryStateChanged == true
	end)

	ForceParam = v237 and v237:FindFirstChild("RE/TimeHoleActivate")
	TimeHoleDeactivateRemote = v237 and v237:FindFirstChild("RE/TimeHoleDeactivate")

	DisconnectDetectionEvent("DetectionTimeHoleActivate")
	if ForceParam and ForceParam:IsA("RemoteEvent") then
		DetectionConnections.DetectionTimeHoleActivate = ForceParam.OnClientEvent:Connect(function(ActiveFlag)
			if IsLocalPlayerArg(ActiveFlag) then
				RuntimeState.TimeHoleActive = true
			end
		end)
	end

	DisconnectDetectionEvent("DetectionTimeHoleDeactivate")
	if TimeHoleDeactivateRemote and TimeHoleDeactivateRemote:IsA("RemoteEvent") then
		DetectionConnections.DetectionTimeHoleDeactivate = TimeHoleDeactivateRemote.OnClientEvent:Connect(function()
			RuntimeState.TimeHoleActive = false
		end)
	end


	StartAbilityDetectionMonitor()
end

parryExecutedFlags = {}
function resetParryFlags()
	parryExecutedFlags = {}
end

function vUnifiedParryCheck()
	local Ball = FindTargetedBall()
	if not Ball then return false end
	if IsProjectileExecuted(Ball) then return false end
	local _, hrp = GetCharacter()
	if not hrp then return false end
	local distance, speed, eta = UpdateBallStats(Ball, hrp)
	if not distance then return false end
	local threshold = SafeToNumber(AutoParry.CFrameDetectorSize, 15)
	if AutoParry.MinParryEnabled then
		threshold = SafeToNumber(AutoParry.MinDetectorSize, 5)
	end
	if distance > threshold then return false end
	if speed <= 0 then return false end
	return true
end

function ExecuteLowSpeedParry()
	local Ball = FindTargetedBall()
	if not Ball then return end
	local _, hrp = GetCharacter()
	if not hrp then return end
	local distance, speed, eta = UpdateBallStats(Ball, hrp)
	if not distance then return end
	local deadzone = SafeToNumber(AutoParry.LowSpeedDeadzone, 10)
	if distance <= deadzone and speed > 0 then
		DispatchParry(Ball, AutoParry.ParryForce or 1, "LowSpeed", false, false)
	end
end

function CalculateAdaptiveThreshold(value, DefaultValue, Randomize)
	local v246 = math.clamp(SafeToNumber(value, DefaultValue), 0.05, 1)
	local v247 = math.clamp(1.05 - v246, 0.05, 1)

	if Randomize then
		v247 = math.clamp(v247 * (math.random(70, 130) / 100), 0.05, 1)
	end

	return v247
end

function CoreParryCheck(ForceParam)
	local Ball = FindTargetedBall()
	if not Ball then return end
	if IsProjectileExecuted(Ball) then return end
	local _, hrp = GetCharacter()
	if not hrp then return end
	local distance, speed, eta = UpdateBallStats(Ball, hrp)
	if not distance then return end
	local threshold = SafeToNumber(AutoParry.CFrameDetectorSize, 15)
	if distance <= threshold and speed > 0 then
		DispatchParry(Ball, ForceParam or AutoParry.ParryForce or 1, "Core", false, false)
	end
end

function UpdateCFrameDetector()
end

function ExecuteCFrameParry()
	local Ball = FindTargetedBall()
	if not Ball then return end
	if IsProjectileExecuted(Ball) then return end
	local _, hrp = GetCharacter()
	if not hrp then return end
	local distance, speed, eta = UpdateBallStats(Ball, hrp)
	if not distance then return end
	local threshold = SafeToNumber(AutoParry.CFrameDetectorSize, 15)
	if distance <= threshold and speed > 0 then
		DispatchParry(Ball, AutoParry.ParryForce or 1, "CFrame", false, false)
	end
end

function ExecuteMinParry()
	local Ball = FindTargetedBall()
	if not Ball then return end
	if IsProjectileExecuted(Ball) then return end
	local _, hrp = GetCharacter()
	if not hrp then return end
	local distance, speed, eta = UpdateBallStats(Ball, hrp)
	if not distance then return end
	local threshold = SafeToNumber(AutoParry.MinDetectorSize, 5)
	if distance <= threshold and speed > 0 then
		DispatchParry(Ball, AutoParry.ParryForce or 1, "Min", false, false)
	end
end

function CloseRangeSustainedParry()
	local Ball = FindTargetedBall()
	if not Ball then return end
	if IsProjectileExecuted(Ball) then return end
	local _, hrp = GetCharacter()
	if not hrp then return end
	local distance, speed, eta = UpdateBallStats(Ball, hrp)
	if not distance then return end
	local threshold = SafeToNumber(AutoParry.CFrameDetectorSize, 15)
	if distance <= threshold and speed > 0 then
		DispatchParry(Ball, AutoParry.ParryForce or 1, "Sustained", false, false)
	end
end

function SetAutoParryEnabled(value)
	AutoParry.Enabled = value == true
	ResetAllParryFlags()
	MarkConfigDirty()
	NotifyToggleState("Auto Parry", AutoParry.Enabled)
end

function ToggleAutoParry()
	SetAutoParryEnabled(not AutoParry.Enabled)
end

function SetTriggerBot(value)
	RuntimeState.TriggerBotEnabled = value == true
	MarkConfigDirty()
	NotifyToggleState("Triggerbot", RuntimeState.TriggerBotEnabled)
	UpdateTriggerBotButtonUI()

	if RuntimeState.TriggerBotEnabled then
		if not RuntimeState.TriggerBotConnection then
			RuntimeState.TriggerBotConnection = HyperionPort.PreRenderPath:Connect(function()
				if not RuntimeState.TriggerBotEnabled then return end

				local character = Player.Character
				local hrp = character and character:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				if hrp:FindFirstChild("SingularityCape") then return end

				local ball = FindTargetedBall()
				if not ball then return end

				if GetBallTarget(ball) ~= Player.Name then return end

				pcall(Main.animation.play_grab_parry_force)
				local triggerCurveCFrame = Main.curve and Main.curve.get_cframe and Main.curve.get_cframe()
				pcall(ParryRemote.fire, triggerCurveCFrame)
				RuntimeState.TriggerBotParryTime = tick()
			end)
		end
	else
		if RuntimeState.TriggerBotConnection then
			RuntimeState.TriggerBotConnection:Disconnect()
			RuntimeState.TriggerBotConnection = nil
		end
		RuntimeState.TriggerBotParries = 0
	end
end

function SetAutoSpam(value)
	AutoParry.AutoSpamEnabled = value == true
	MarkConfigDirty()
	NotifyToggleState("Auto Spam", AutoParry.AutoSpamEnabled)
end

function SetAIWalk(value)
	AutoParry.AIWalkEnabled = value == true
	ClearWalkTarget()
	MarkConfigDirty()
	NotifyToggleState("AI Auto Walk", AutoParry.AIWalkEnabled)
end

function ToggleAutoSpam()
	SetAutoSpam(not AutoParry.AutoSpamEnabled)
end

function ToggleAIWalk()
	SetAIWalk(not AutoParry.AIWalkEnabled)
end

function ToggleTriggerBot()
	SetTriggerBot(not AutoParry.TriggerBotEnabled)
end

function DestroySphereVisual()
	if RuntimeState.SpherePart then
		RuntimeState.SpherePart:Destroy()
		RuntimeState.SpherePart = nil
	end
end

function UpdateSphereVisual()
	if not AutoParry.ShowSphere then
		DestroySphereVisual()
		return
	end

	local Index, hrp = GetCharacter()

	if not hrp then
		DestroySphereVisual()
		return
	end

	local DetectorRadius = SafeToNumber(AutoParry.LowSpeedDeadzone, 10)

	if AutoParry.Mode == "CFrame" then
		DetectorRadius = SafeToNumber(AutoParry.CFrameDetectorSize, 15)
	elseif AutoParry.MinParryEnabled then
		DetectorRadius = SafeToNumber(AutoParry.MinDetectorSize, 5)
	end

	if not RuntimeState.SpherePart or not RuntimeState.SpherePart.Parent then
		RuntimeState.SpherePart = Instance.new("Part")
		RuntimeState.SpherePart.Name = "HyperionDetectorSphere"
		RuntimeState.SpherePart.Shape = Enum.PartType.Ball
		RuntimeState.SpherePart.Anchored = true
		RuntimeState.SpherePart.CanCollide = false
		RuntimeState.SpherePart.CanTouch = false
		RuntimeState.SpherePart.CanQuery = false
		RuntimeState.SpherePart.CastShadow = false
		RuntimeState.SpherePart.Material = Enum.Material.ForceField
		RuntimeState.SpherePart.Transparency = 0.65
		RuntimeState.SpherePart.Color = Color3.fromRGB(120, 140, 255)
		RuntimeState.SpherePart.Parent = workspace
	end

	RuntimeState.SpherePart.Size = Vector3.new(DetectorRadius * 2, DetectorRadius * 2, DetectorRadius * 2)
	RuntimeState.SpherePart.CFrame = hrp.CFrame
end

function SaveStatusBarPosition()
	if not RuntimeState.StatusFrame then
		return
	end

	AutoParry.StatusBarPosition = {
		XScale = RuntimeState.StatusFrame.Position.X.Scale,
		XOffset = RuntimeState.StatusFrame.Position.X.Offset,
		YScale = RuntimeState.StatusFrame.Position.Y.Scale,
		YOffset = RuntimeState.StatusFrame.Position.Y.Offset
	}

	MarkConfigDirty()
end

function MakeDraggable(Frame)
	if not Frame or not Frame:IsA("GuiObject") then return end
	local IsDragging = false
	local DragStartPos = nil
	local DragOriginalPos = nil

	Frame.InputBegan:Connect(function(v223)
		if v223.UserInputType == Enum.UserInputType.MouseButton1 or v223.UserInputType == Enum.UserInputType.Touch then
			IsDragging = true
			DragStartPos = v223.Position
			DragOriginalPos = Frame.Position

			v223.Changed:Connect(function()
				if v223.UserInputState == Enum.UserInputState.End then
					IsDragging = false
					SaveStatusBarPosition()
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(v223)
		if not IsDragging then return end

		if v223.UserInputType == Enum.UserInputType.MouseMovement or v223.UserInputType == Enum.UserInputType.Touch then
			local DragDelta = v223.Position - DragStartPos

			Frame.Position = UDim2.new(
				DragOriginalPos.X.Scale,
				DragOriginalPos.X.Offset + DragDelta.X,
				DragOriginalPos.Y.Scale,
				DragOriginalPos.Y.Offset + DragDelta.Y
			)
		end
	end)
end

function GetStatusBarColor()
	return Color3.fromRGB(
		math.clamp(math.floor(SafeToNumber(AutoParry.StatusBarColorR, 150)), 0, 255),
		math.clamp(math.floor(SafeToNumber(AutoParry.StatusBarColorG, 105)), 0, 255),
		math.clamp(math.floor(SafeToNumber(AutoParry.StatusBarColorB, 255)), 0, 255)
	)
end

function GetStatusBarTextColor()
	return Color3.fromRGB(
		math.clamp(math.floor(SafeToNumber(AutoParry.StatusBarTextR, 245)), 0, 255),
		math.clamp(math.floor(SafeToNumber(AutoParry.StatusBarTextG, 245)), 0, 255),
		math.clamp(math.floor(SafeToNumber(AutoParry.StatusBarTextB, 255)), 0, 255)
	)
end

function UpdateStatusBarAppearance()
	if not RuntimeState.StatusFrame then
		return
	end

	local StatusColor = GetStatusBarColor()
	RuntimeState.StatusFrame.BackgroundColor3 = StatusColor
	RuntimeState.StatusFrame.BackgroundTransparency = math.clamp(SafeToNumber(AutoParry.StatusBarTransparency, 0.38), 0, 0.9)

	if RuntimeState.StatusStroke then
		RuntimeState.StatusStroke.Color = StatusColor
		RuntimeState.StatusStroke.Transparency = 0.22
	end

	if RuntimeState.StatusGradient then
		RuntimeState.StatusGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.15, StatusColor),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(32, 32, 45)),
			ColorSequenceKeypoint.new(1, StatusColor)
		})
	end

	if RuntimeState.StatusShineGradient then
		RuntimeState.StatusShineGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), StatusColor)
	end

	if RuntimeState.StatusText then
		RuntimeState.StatusText.TextColor3 = GetStatusBarTextColor()
	end
end

function CreateOrUpdateStatusBar()
	if RuntimeState.StatusGui then
		UpdateStatusBarAppearance()
		return
	end

	RuntimeState.StatusGui = Instance.new("ScreenGui")
	RuntimeState.StatusGui.Name = "HyperionStatusBar"
	RuntimeState.StatusGui.ResetOnSpawn = false
	RuntimeState.StatusGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	RuntimeState.StatusGui.Parent = PlayerGui

	RuntimeState.StatusFrame = Instance.new("Frame")
	RuntimeState.StatusFrame.Name = "LiquidGlassBar"
	RuntimeState.StatusFrame.Size = UDim2.new(0, 470, 0, 34)
	RuntimeState.StatusFrame.Position = UDim2.new(
		SafeToNumber(AutoParry.StatusBarPosition.XScale, 0.5),
		SafeToNumber(AutoParry.StatusBarPosition.XOffset, -235),
		SafeToNumber(AutoParry.StatusBarPosition.YScale, 0),
		SafeToNumber(AutoParry.StatusBarPosition.YOffset, 12)
	)
	RuntimeState.StatusFrame.BackgroundColor3 = GetStatusBarColor()
	RuntimeState.StatusFrame.BackgroundTransparency = math.clamp(SafeToNumber(AutoParry.StatusBarTransparency, 0.38), 0, 0.9)
	RuntimeState.StatusFrame.BorderSizePixel = 0
	RuntimeState.StatusFrame.ClipsDescendants = true
	RuntimeState.StatusFrame.Parent = RuntimeState.StatusGui

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 16)
	Corner.Parent = RuntimeState.StatusFrame

	RuntimeState.StatusStroke = Instance.new("UIStroke")
	RuntimeState.StatusStroke.Color = GetStatusBarColor()
	RuntimeState.StatusStroke.Thickness = 1.5
	RuntimeState.StatusStroke.Transparency = 0.22
	RuntimeState.StatusStroke.Parent = RuntimeState.StatusFrame

	RuntimeState.StatusGradient = Instance.new("UIGradient")
	RuntimeState.StatusGradient.Rotation = 18
	RuntimeState.StatusGradient.Parent = RuntimeState.StatusFrame

	RuntimeState.StatusShine = Instance.new("Frame")
	RuntimeState.StatusShine.Name = "LiquidShine"
	RuntimeState.StatusShine.BackgroundTransparency = 0.55
	RuntimeState.StatusShine.BorderSizePixel = 0
	RuntimeState.StatusShine.Size = UDim2.new(1, -18, 0, 11)
	RuntimeState.StatusShine.Position = UDim2.new(0, 9, 0, 4)
	RuntimeState.StatusShine.Parent = RuntimeState.StatusFrame

	local ShineCorner = Instance.new("UICorner")
	ShineCorner.CornerRadius = UDim.new(1, 0)
	ShineCorner.Parent = RuntimeState.StatusShine

	RuntimeState.StatusShineGradient = Instance.new("UIGradient")
	RuntimeState.StatusShineGradient.Rotation = 0
	RuntimeState.StatusShineGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.55, 0.85),
		NumberSequenceKeypoint.new(1, 1)
	})
	RuntimeState.StatusShineGradient.Parent = RuntimeState.StatusShine

	RuntimeState.StatusText = Instance.new("TextLabel")
	RuntimeState.StatusText.Size = UDim2.fromScale(1, 1)
	RuntimeState.StatusText.BackgroundTransparency = 1
	RuntimeState.StatusText.TextColor3 = GetStatusBarTextColor()
	RuntimeState.StatusText.TextStrokeTransparency = 0.6
	RuntimeState.StatusText.Font = Enum.Font.GothamSemibold
	RuntimeState.StatusText.TextSize = 13
	RuntimeState.StatusText.Text = "Hyperion  â€¢ Private dev build ".."  â€¢  0 FPS  â€¢  0 MS"
	RuntimeState.StatusText.Parent = RuntimeState.StatusFrame

	UpdateStatusBarAppearance()
	MakeDraggable(RuntimeState.StatusFrame)
end

function UpdateStatusBar()
	if not AutoParry.ShowStatusBar then
		if RuntimeState.StatusGui then
			RuntimeState.StatusGui.Enabled = false
		end

		return
	end

	CreateOrUpdateStatusBar()

	if RuntimeState.StatusGui then
		RuntimeState.StatusGui.Enabled = true
	end

	UpdateStatusBarAppearance()

	if RuntimeState.StatusText then
		RuntimeState.StatusText.Text = "Hyperion  â€¢  Private dev build ".."  â€¢  " .. tostring(RuntimeState.Fps) .. " FPS  â€¢  " .. tostring(GetPing()) .. " MS"
	end
end

function GetVisualColor()
	return Color3.fromRGB(
		math.clamp(math.floor(SafeToNumber(AutoParry.VisualColorR, 140)), 0, 255),
		math.clamp(math.floor(SafeToNumber(AutoParry.VisualColorG, 100)), 0, 255),
		math.clamp(math.floor(SafeToNumber(AutoParry.VisualColorB, 255)), 0, 255)
	)
end

function MakeColor3(RedVal, GreenVal, BlueVal, DefaultValue)
	DefaultValue = DefaultValue or GetVisualColor()

	return Color3.fromRGB(
		math.clamp(math.floor(SafeToNumber(RedVal, DefaultValue.R * 255)), 0, 255),
		math.clamp(math.floor(SafeToNumber(GreenVal, DefaultValue.G * 255)), 0, 255),
		math.clamp(math.floor(SafeToNumber(BlueVal, DefaultValue.B * 255)), 0, 255)
	)
end

function GetBallTrailColor()
	return MakeColor3(AutoParry.BallTrailColorR, AutoParry.BallTrailColorG, AutoParry.BallTrailColorB, GetVisualColor())
end

function GetBallGlowColor()
	return MakeColor3(AutoParry.BallGlowColorR, AutoParry.BallGlowColorG, AutoParry.BallGlowColorB, GetVisualColor())
end

function GetCharacterTrailColor()
	return MakeColor3(AutoParry.CharacterTrailColorR, AutoParry.CharacterTrailColorG, AutoParry.CharacterTrailColorB, GetVisualColor())
end

ParryFXRainbowHue = 0
SwordRainbowHue = 0

function UpdateRainbowColors()
	if AutoParry.ParryFXRainbow then
		ParryFXRainbowHue = (ParryFXRainbowHue + 0.005) % 1
		local c = Color3.fromHSV(ParryFXRainbowHue, 1, 1)
		AutoParry.ParryFXColorR = math.floor(c.R * 255)
		AutoParry.ParryFXColorG = math.floor(c.G * 255)
		AutoParry.ParryFXColorB = math.floor(c.B * 255)
	end
	if AutoParry.SwordRainbow then
		SwordRainbowHue = (SwordRainbowHue + 0.005) % 1
		local c = Color3.fromHSV(SwordRainbowHue, 1, 1)
		AutoParry.SwordColorR = math.floor(c.R * 255)
		AutoParry.SwordColorG = math.floor(c.G * 255)
		AutoParry.SwordColorB = math.floor(c.B * 255)
	end
end

function GetJumpCircleColor()
	return MakeColor3(AutoParry.JumpCircleColorR, AutoParry.JumpCircleColorG, AutoParry.JumpCircleColorB, GetVisualColor())
end

function GetOrCreateVisualFolder()
	if RuntimeState.VisualFolder and RuntimeState.VisualFolder.Parent then
		return RuntimeState.VisualFolder
	end

	RuntimeState.VisualFolder = Instance.new("Folder")
	RuntimeState.VisualFolder.Name = "HyperionVisuals"
	RuntimeState.VisualFolder.Parent = workspace
	return RuntimeState.VisualFolder
end

function FadeOutAndDestroy(BasePart, Duration)
	Duration = math.max(0.05, SafeToNumber(Duration, 1))

	task.spawn(function()
		local FadeStartTime = os.clock()

		while BasePart and BasePart.Parent do
			local ProgressRatio = (os.clock() - FadeStartTime) / Duration

			if ProgressRatio >= 1 then
				break
			end

			if BasePart:IsA("BasePart") then
				BasePart.Transparency = math.clamp(0.15 + ProgressRatio * 0.85, 0, 1)
			end

			task.wait()
		end

		if BasePart and BasePart.Parent then
			BasePart:Destroy()
		end
	end)
end

function FadeOutFolder(TargetInstance, Duration)
	Duration = math.max(0.05, SafeToNumber(Duration, 1))

	task.spawn(function()
		local FadeStartTime = os.clock()

		while TargetInstance and TargetInstance.Parent do
			local ProgressRatio = (os.clock() - FadeStartTime) / Duration

			if ProgressRatio >= 1 then
				break
			end

			for Index, ChildInstance in ipairs(TargetInstance:GetDescendants()) do
				if ChildInstance:IsA("Beam") then
					ChildInstance.Transparency = NumberSequence.new(math.clamp(0.08 + ProgressRatio * 0.92, 0, 1))
				elseif ChildInstance:IsA("BasePart") then
					ChildInstance.Transparency = 1
				end
			end

			task.wait()
		end

		if TargetInstance and TargetInstance.Parent then
			TargetInstance:Destroy()
		end
	end)
end

function CreateAttachmentPoint(ParentFolder, SettingName, Position)
	local BasePart = Instance.new("Part")
	BasePart.Name = SettingName
	BasePart.Anchored = true
	BasePart.CanCollide = false
	BasePart.CanTouch = false
	BasePart.CanQuery = false
	BasePart.CastShadow = false
	BasePart.Transparency = 1
	BasePart.Size = Vector3.new(0.05, 0.05, 0.05)
	BasePart.CFrame = CFrame.new(Position)
	BasePart.Parent = ParentFolder

	local Attachment = Instance.new("Attachment")
	Attachment.Parent = BasePart

	return Attachment
end

function CreateBeam(SettingName, StartPos, EndPos, DefaultThickness, BeamWidth, Duration, Color)
	local SegmentLength = (EndPos - StartPos).Magnitude

	if SegmentLength < 0.01 then
		return
	end

	local BeamFolder = Instance.new("Folder")
	BeamFolder.Name = SettingName
	BeamFolder.Parent = GetOrCreateVisualFolder()

	local Attachment0 = CreateAttachmentPoint(BeamFolder, SettingName .. "Start", StartPos)
	local Attachment1 = CreateAttachmentPoint(BeamFolder, SettingName .. "End", EndPos)
	local BeamWidth = math.max(0.02, SafeToNumber(BeamWidth, SafeToNumber(DefaultThickness, 0.2)))

	local Beam = Instance.new("Beam")
	Beam.Name = SettingName .. "Line"
	Beam.Attachment0 = Attachment0
	Beam.Attachment1 = Attachment1
	Beam.Width0 = BeamWidth
	Beam.Width1 = BeamWidth
	Beam.Color = ColorSequence.new(Color or GetVisualColor())
	Beam.Transparency = NumberSequence.new(0.08)
	Beam.LightEmission = 0.75
	Beam.LightInfluence = 0
	Beam.FaceCamera = true
	Beam.Segments = 1
	Beam.Parent = BeamFolder

	FadeOutFolder(BeamFolder, Duration)
end

function GetPositionFromInstance(TargetInstance)
	if not TargetInstance then
		return nil
	end

	if TargetInstance:IsA("BasePart") then
		return TargetInstance.Position
	end

	if TargetInstance:IsA("Model") then
		local PrimaryOrPart = TargetInstance.PrimaryPart or TargetInstance:FindFirstChildWhichIsA("BasePart", true)
		return PrimaryOrPart and PrimaryOrPart.Position or nil
	end

	local BasePart = TargetInstance:FindFirstChildWhichIsA("BasePart", true)
	return BasePart and BasePart.Position or nil
end

function GetBasePartFromInstance(TargetInstance)
	if not TargetInstance then
		return nil
	end

	if TargetInstance:IsA("BasePart") then
		return TargetInstance
	end

	if TargetInstance:IsA("Model") then
		return TargetInstance.PrimaryPart or TargetInstance:FindFirstChildWhichIsA("BasePart", true)
	end

	return TargetInstance:FindFirstChildWhichIsA("BasePart", true)
end

function IsBallInstance(TargetInstance)
	if not TargetInstance then
		return false
	end

	local SettingName = tostring(TargetInstance.Name):lower()
	return SettingName:find("ball") ~= nil
		or TargetInstance:GetAttribute("realBall") == true
		or TargetInstance:FindFirstChild("zoomies", true) ~= nil
end

function FindAnyBallPart()
	local Ball = FindTargetedBall() or FindTrainingBall()

	local BasePart = GetBasePartFromInstance(Ball)
	if BasePart then
		return BasePart
	end

	for Index, FolderNames in ipairs({ "Balls", "TrainingBalls", "Runtime" }) do
		local BallsFolder = workspace:FindFirstChild(FolderNames)
		if BallsFolder then
			for Index, ChildInstance in ipairs(BallsFolder:GetChildren()) do
				BasePart = GetBasePartFromInstance(ChildInstance)
				if BasePart and IsBallInstance(ChildInstance) then
					return BasePart
				end
			end
		end
	end

	for Index, ChildInstance in ipairs(workspace:GetChildren()) do
		if IsBallInstance(ChildInstance) then
			BasePart = GetBasePartFromInstance(ChildInstance)
			if BasePart then
				return BasePart
			end
		end
	end

	return nil
end

function DestroyBallTrail()
	if RuntimeState.BallTrailObject then
		RuntimeState.BallTrailObject:Destroy()
		RuntimeState.BallTrailObject = nil
	end

	if RuntimeState.BallTrailAttachment0 then
		RuntimeState.BallTrailAttachment0:Destroy()
		RuntimeState.BallTrailAttachment0 = nil
	end

	if RuntimeState.BallTrailAttachment1 then
		RuntimeState.BallTrailAttachment1:Destroy()
		RuntimeState.BallTrailAttachment1 = nil
	end

	RuntimeState.BallTrailBall = nil
	RuntimeState.LastBallTrailPosition = nil
end

function GetOrCreateBallTrail(BallPart)
	if RuntimeState.BallTrailObject
		and RuntimeState.BallTrailObject.Parent
		and RuntimeState.BallTrailBall == BallPart
		and RuntimeState.BallTrailAttachment0
		and RuntimeState.BallTrailAttachment1 then
		return RuntimeState.BallTrailObject
	end

	DestroyBallTrail()

	local Attachment0 = Instance.new("Attachment")
	Attachment0.Name = "HyperionBallTrailA0"
	Attachment0.Parent = BallPart

	local Attachment1 = Instance.new("Attachment")
	Attachment1.Name = "HyperionBallTrailA1"
	Attachment1.Parent = BallPart

	local Trail = Instance.new("Trail")
	Trail.Name = "HyperionBallTrail"
	Trail.Attachment0 = Attachment0
	Trail.Attachment1 = Attachment1
	Trail.FaceCamera = true
	Trail.LightEmission = 0.8
	Trail.LightInfluence = 0
	Trail.MinLength = 0.05
	Trail.Parent = BallPart

	RuntimeState.BallTrailAttachment0 = Attachment0
	RuntimeState.BallTrailAttachment1 = Attachment1
	RuntimeState.BallTrailObject = Trail
	RuntimeState.BallTrailBall = BallPart

	return Trail
end

function UpdateBallTrail()
	if not AutoParry.BallTrailEnabled then
		DestroyBallTrail()
		return
	end

	local BallPart = FindAnyBallPart()

	if not BallPart or not BallPart.Parent then
		DestroyBallTrail()
		return
	end

	local Trail = GetOrCreateBallTrail(BallPart)
	if not Trail then
		return
	end

	local HorizontalThickness = math.max(0.05, SafeToNumber(AutoParry.BallTrailHorizontalThickness, SafeToNumber(AutoParry.BallTrailThickness, 0.2)) * 2)
	local VerticalThickness = math.max(0.05, SafeToNumber(AutoParry.BallTrailVerticalThickness, 0.2))
	local OffsetVector = VerticalThickness
	local Color = GetBallTrailColor()

	RuntimeState.BallTrailAttachment0.Position = Vector3.new(0, OffsetVector, 0)
	RuntimeState.BallTrailAttachment1.Position = Vector3.new(0, -OffsetVector, 0)
	Trail.Color = ColorSequence.new(Color)
	Trail.Lifetime = math.clamp(SafeToNumber(AutoParry.BallTrailLifetime, 1.2), 0.1, 10)
	Trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, HorizontalThickness),
		NumberSequenceKeypoint.new(1, 0)
	})
	Trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 1)
	})
	Trail.Enabled = true
end

function DestroyBallGlow()
	if RuntimeState.BallGlowLight then
		RuntimeState.BallGlowLight:Destroy()
		RuntimeState.BallGlowLight = nil
	end

	if RuntimeState.BallGlowPart then
		RuntimeState.BallGlowPart:Destroy()
		RuntimeState.BallGlowPart = nil
	end

	RuntimeState.BallGlowBall = nil
end

function GetOrCreateBallGlow(BallPart)
	if RuntimeState.BallGlowLight
		and RuntimeState.BallGlowLight.Parent
		and RuntimeState.BallGlowBall == BallPart then
		return RuntimeState.BallGlowLight
	end

	DestroyBallGlow()

	local Light = Instance.new("PointLight")
	Light.Name = "HyperionBallGlow"
	Light.Range = 18
	Light.Brightness = 3
	Light.Color = GetBallGlowColor()
	Light.Parent = BallPart

	local GlowPart = Instance.new("Part")
	GlowPart.Name = "HyperionBallGlowVisual"
	GlowPart.Size = Vector3.new(4.5, 4.5, 4.5)
	GlowPart.Shape = Enum.PartType.Ball
	GlowPart.Transparency = 0.65
	GlowPart.Material = Enum.Material.Neon
	GlowPart.Color = GetBallGlowColor()
	GlowPart.CanCollide = false
	GlowPart.CanQuery = false
	GlowPart.Anchored = true
	GlowPart.Parent = BallPart

	RuntimeState.BallGlowLight = Light
	RuntimeState.BallGlowPart = GlowPart
	RuntimeState.BallGlowBall = BallPart

	return Light
end

function UpdateBallGlow()
	if not AutoParry.BallGlowEnabled then
		DestroyBallGlow()
		return
	end

	local BallPart = FindAnyBallPart()
	if not BallPart or not BallPart.Parent then
		DestroyBallGlow()
		return
	end

	local Light = GetOrCreateBallGlow(BallPart)
	if not Light then
		return
	end

	local color = GetBallGlowColor()
	Light.Color = color

	if RuntimeState.BallGlowPart and RuntimeState.BallGlowPart.Parent == BallPart then
		RuntimeState.BallGlowPart.Color = color
		RuntimeState.BallGlowPart.Transparency = 0.65
	end
end

function DestroyCharacterTrail()
	if RuntimeState.CharacterTrailObject then
		RuntimeState.CharacterTrailObject:Destroy()
		RuntimeState.CharacterTrailObject = nil
	end

	if RuntimeState.CharacterTrailAttachment0 then
		RuntimeState.CharacterTrailAttachment0:Destroy()
		RuntimeState.CharacterTrailAttachment0 = nil
	end

	if RuntimeState.CharacterTrailAttachment1 then
		RuntimeState.CharacterTrailAttachment1:Destroy()
		RuntimeState.CharacterTrailAttachment1 = nil
	end

	RuntimeState.CharacterTrailPart = nil
	RuntimeState.LastCharacterTrailPosition = nil
end

function GetOrCreateCharacterTrail(hrp)
	if RuntimeState.CharacterTrailObject
		and RuntimeState.CharacterTrailObject.Parent
		and RuntimeState.CharacterTrailPart == hrp
		and RuntimeState.CharacterTrailAttachment0
		and RuntimeState.CharacterTrailAttachment1 then
		return RuntimeState.CharacterTrailObject
	end

	DestroyCharacterTrail()

	local Attachment0 = Instance.new("Attachment")
	Attachment0.Name = "HyperionCharacterTrailA0"
	Attachment0.Parent = hrp

	local Attachment1 = Instance.new("Attachment")
	Attachment1.Name = "HyperionCharacterTrailA1"
	Attachment1.Parent = hrp

	local Trail = Instance.new("Trail")
	Trail.Name = "HyperionCharacterTrail"
	Trail.Attachment0 = Attachment0
	Trail.Attachment1 = Attachment1
	Trail.FaceCamera = true
	Trail.LightEmission = 0.65
	Trail.LightInfluence = 0
	Trail.MinLength = 0.05
	Trail.Parent = hrp

	RuntimeState.CharacterTrailAttachment0 = Attachment0
	RuntimeState.CharacterTrailAttachment1 = Attachment1
	RuntimeState.CharacterTrailObject = Trail
	RuntimeState.CharacterTrailPart = hrp

	return Trail
end

function UpdateCharacterTrail()
	if not AutoParry.CharacterTrailEnabled then
		DestroyCharacterTrail()
		return
	end

	local Index, hrp = GetCharacter()

	if not hrp or not hrp.Parent then
		DestroyCharacterTrail()
		return
	end

	local Trail = GetOrCreateCharacterTrail(hrp)
	if not Trail then
		return
	end

	local HorizontalThickness = math.max(0.05, SafeToNumber(AutoParry.CharacterTrailHorizontalThickness, SafeToNumber(AutoParry.CharacterTrailThickness, 0.25)) * 2)
	local VerticalThickness = math.max(0.05, SafeToNumber(AutoParry.CharacterTrailVerticalThickness, 0.25))
	local OffsetVector = VerticalThickness

	RuntimeState.CharacterTrailAttachment0.Position = Vector3.new(0, OffsetVector, 0)
	RuntimeState.CharacterTrailAttachment1.Position = Vector3.new(0, -OffsetVector, 0)
	Trail.Color = ColorSequence.new(GetCharacterTrailColor())
	Trail.Lifetime = math.clamp(SafeToNumber(AutoParry.CharacterTrailLifetime, 1.2), 0.1, 10)
	Trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, HorizontalThickness),
		NumberSequenceKeypoint.new(1, 0)
	})
	Trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.08),
		NumberSequenceKeypoint.new(1, 1)
	})
	Trail.Enabled = true
end

function CreateJumpCircle(Position)
	local Radius = math.max(1, SafeToNumber(AutoParry.JumpCircleSize, 8))
	local HorizontalThickness = math.max(0.02, SafeToNumber(AutoParry.JumpCircleThickness, 0.08))
	local SegmentCount = 40
	local CircleFolder = Instance.new("Folder")
	CircleFolder.Name = "JumpCircle"
	CircleFolder.Parent = GetOrCreateVisualFolder()

	for SegmentIndex = 1, SegmentCount do
		local StartAngle = ((SegmentIndex - 1) / SegmentCount) * math.pi * 2
		local EndAngle = (SegmentIndex / SegmentCount) * math.pi * 2
		local StartPos = Position + Vector3.new(math.cos(StartAngle) * Radius, 0, math.sin(StartAngle) * Radius)
		local EndPos = Position + Vector3.new(math.cos(EndAngle) * Radius, 0, math.sin(EndAngle) * Radius)
		local Attachment0 = CreateAttachmentPoint(CircleFolder, "JumpCircleStart", StartPos)
		local Attachment1 = CreateAttachmentPoint(CircleFolder, "JumpCircleEnd", EndPos)

		local Beam = Instance.new("Beam")
		Beam.Name = "JumpCircleLine"
		Beam.Attachment0 = Attachment0
		Beam.Attachment1 = Attachment1
		Beam.Width0 = HorizontalThickness
		Beam.Width1 = HorizontalThickness
		Beam.Color = ColorSequence.new(GetJumpCircleColor())
		Beam.Transparency = NumberSequence.new(0.08)
		Beam.LightEmission = 0.75
		Beam.LightInfluence = 0
		Beam.FaceCamera = true
		Beam.Segments = 1
		Beam.Parent = CircleFolder
	end

	FadeOutFolder(CircleFolder, AutoParry.JumpCircleLifetime)
end

function UpdateJumpCircle()
	if not AutoParry.JumpCircleEnabled then
		RuntimeState.LastJumpState = false
		return
	end

	local Character, hrp = GetCharacter()

	if not Character or not hrp then
		RuntimeState.LastJumpState = false
		return
	end

	local humanoid = Character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		RuntimeState.LastJumpState = false
		return
	end

	local IsJumping = humanoid:GetState() == Enum.HumanoidStateType.Jumping

	if IsJumping and not RuntimeState.LastJumpState and os.clock() - RuntimeState.LastJumpCircleTime > 0.15 then
		RuntimeState.LastJumpCircleTime = os.clock()
		CreateJumpCircle(hrp.Position - Vector3.new(0, 2.8, 0))
	end

	RuntimeState.LastJumpState = IsJumping
end

function DestroySnow()
	if RuntimeState.SnowGui then
		RuntimeState.SnowGui:Destroy()
		RuntimeState.SnowGui = nil
	end

	table.clear(RuntimeState.Snowflakes)
end

function EnsureSnowGui()
	if RuntimeState.SnowGui then
		return
	end

	RuntimeState.SnowGui = Instance.new("ScreenGui")
	RuntimeState.SnowGui.Name = "HyperionSnow"
	RuntimeState.SnowGui.ResetOnSpawn = false
	RuntimeState.SnowGui.IgnoreGuiInset = true
	RuntimeState.SnowGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	RuntimeState.SnowGui.DisplayOrder = 999999
	RuntimeState.SnowGui.Parent = PlayerGui
end

function EnsureSnowflakes()
	EnsureSnowGui()

	local Camera = workspace.CurrentCamera
	local ViewportSize = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
	local ScreenWidth = math.max(1, math.floor(ViewportSize.X))
	local ScreenHeight = math.max(1, math.floor(ViewportSize.Y))
	local SnowCount = math.max(1, math.floor(SafeToNumber(AutoParry.SnowCount, 45)))

	while #RuntimeState.Snowflakes < SnowCount do
		local Snowflake = Instance.new("TextLabel")
		Snowflake.Name = "Snowflake"
		Snowflake.BackgroundTransparency = 1
		Snowflake.Text = "*"
		Snowflake.TextColor3 = GetVisualColor()
		Snowflake.TextStrokeTransparency = 0.5
		Snowflake.Font = Enum.Font.GothamBold
		Snowflake.TextSize = SafeToNumber(AutoParry.SnowSize, 14)
		Snowflake.Size = UDim2.fromOffset(24, 24)
		Snowflake.Position = UDim2.fromOffset(math.random(0, ScreenWidth), math.random(-ScreenHeight, 0))
		Snowflake.Parent = RuntimeState.SnowGui

		table.insert(RuntimeState.Snowflakes, {
			Label = Snowflake,
			X = math.random(0, ScreenWidth),
			Y = math.random(-ScreenHeight, 0),
			Drift = math.random(-20, 20) / 10
		})
	end

	while #RuntimeState.Snowflakes > SnowCount do
		local Snowflake = table.remove(RuntimeState.Snowflakes)

		if Snowflake and Snowflake.Label then
			Snowflake.Label:Destroy()
		end
	end
end

function UpdateSnow(DeltaTime)
	if not AutoParry.SnowEnabled then
		DestroySnow()
		return
	end

	EnsureSnowflakes()

	local Camera = workspace.CurrentCamera
	local ViewportSize = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
	local BallSpeed = SafeToNumber(AutoParry.SnowSpeed, 120)
	local Color = GetVisualColor()

	for Index, Snowflake in ipairs(RuntimeState.Snowflakes) do
		local Label = Snowflake.Label

		if Label and Label.Parent then
			Snowflake.Y += BallSpeed * DeltaTime
			Snowflake.X += Snowflake.Drift * DeltaTime * 20

			if Snowflake.Y > ViewportSize.Y + 30 then
				Snowflake.Y = -30
				Snowflake.X = math.random(0, math.max(1, math.floor(ViewportSize.X)))
			end

			if Snowflake.X > ViewportSize.X + 30 then
				Snowflake.X = -30
			elseif Snowflake.X < -30 then
				Snowflake.X = ViewportSize.X + 30
			end

			Label.TextColor3 = Color
			Label.TextSize = SafeToNumber(AutoParry.SnowSize, 14)
			Label.Position = UDim2.fromOffset(Snowflake.X, Snowflake.Y)
		end
	end
end

function DestroyChinaHat()
	local Character = Player.Character
	local HeadPart = Character and Character:FindFirstChild("Head")

	if HeadPart then
		for Index, ChildInstance in ipairs(HeadPart:GetChildren()) do
			if ChildInstance:IsA("Attachment") and (ChildInstance.Name:find("HatBase") or ChildInstance.Name == "HatApex") then
				ChildInstance:Destroy()
			end
		end
	end

	if RuntimeState.ChinaHatFolder then
		RuntimeState.ChinaHatFolder:Destroy()
		RuntimeState.ChinaHatFolder = nil
	end

	table.clear(RuntimeState.ChinaHatParts)
	ChinaHatCacheKey = ""
end

function CreateChinaHatBeam(SettingName, ParentFolder, Attachment0, Attachment1, BeamWidth, Color)
	local Beam = Instance.new("Beam")
	Beam.Name = SettingName
	Beam.Attachment0 = Attachment0
	Beam.Attachment1 = Attachment1
	Beam.Width0 = BeamWidth
	Beam.Width1 = BeamWidth
	Beam.Color = ColorSequence.new(Color)
	Beam.Transparency = NumberSequence.new(0.08)
	Beam.LightEmission = 0.55
	Beam.FaceCamera = true
	Beam.Parent = ParentFolder
	return Beam
end

function RebuildChinaHat(HeadPart, CacheKey, RotationOffset)
	DestroyChinaHat()

	RuntimeState.ChinaHatFolder = Instance.new("Folder")
	RuntimeState.ChinaHatFolder.Name = "HyperionChinaHat"
	RuntimeState.ChinaHatFolder.Parent = HeadPart

	local SegmentCount = 18
	local Radius = math.max(0.5, SafeToNumber(AutoParry.ChinaHatRadius, 2.6))
	local ChinaHatHeight = SafeToNumber(AutoParry.ChinaHatHeight, 0.8)
	local HorizontalThickness = math.max(0.01, SafeToNumber(AutoParry.ChinaHatThickness, 0.05))
	local Color = GetVisualColor()
	local BaseYOffset = 0.9

	local ApexAttachment = Instance.new("Attachment")
	ApexAttachment.Name = "HatApex"
	ApexAttachment.Position = Vector3.new(0, BaseYOffset + ChinaHatHeight, 0)
	ApexAttachment.Parent = HeadPart

	local BaseAttachments = {}

	for BaseIndex = 1, SegmentCount do
		local RandomAngle = ((BaseIndex - 1) / SegmentCount) * math.pi * 2 + RotationOffset
		local Attachment = Instance.new("Attachment")
		Attachment.Name = "HatBase" .. i
		Attachment.Position = Vector3.new(math.cos(RandomAngle) * Radius, BaseYOffset, math.sin(RandomAngle) * Radius)
		Attachment.Parent = HeadPart
		BaseAttachments[BaseIndex] = Attachment
	end

	for BaseIndex = 1, SegmentCount do
		local NextIndex = (BaseIndex % SegmentCount) + 1
		CreateChinaHatBeam("Rim" .. i, RuntimeState.ChinaHatFolder, BaseAttachments[BaseIndex], BaseAttachments[NextIndex], HorizontalThickness, Color)

		if BaseIndex % 3 == 0 then
			CreateChinaHatBeam("Spoke" .. i, RuntimeState.ChinaHatFolder, ApexAttachment, BaseAttachments[BaseIndex], HorizontalThickness, Color)
		end
	end

	ChinaHatCacheKey = CacheKey
end

function UpdateChinaHat(DeltaTime)
	if not AutoParry.ChinaHatEnabled then
		DestroyChinaHat()
		return
	end

	local Character = Player.Character
	local HeadPart = Character and Character:FindFirstChild("Head")

	if not HeadPart then
		DestroyChinaHat()
		return
	end

	local SpinSpeed = SafeToNumber(AutoParry.ChinaHatSpinSpeed, 1)

	if SpinSpeed > 0 then
		RuntimeState.ChinaHatRotation += SpinSpeed * DeltaTime
	end

	local CacheKey = table.concat({
		tostring(HeadPart),
		tostring(math.floor(SafeToNumber(AutoParry.ChinaHatRadius, 2.6) * 10)),
		tostring(math.floor(SafeToNumber(AutoParry.ChinaHatHeight, 0.8) * 10)),
		tostring(math.floor(SafeToNumber(AutoParry.ChinaHatThickness, 0.05) * 100)),
		tostring(math.floor(SafeToNumber(AutoParry.VisualColorR, 140))),
		tostring(math.floor(SafeToNumber(AutoParry.VisualColorG, 100))),
		tostring(math.floor(SafeToNumber(AutoParry.VisualColorB, 255))),
		tostring(math.floor((RuntimeState.ChinaHatRotation % (math.pi * 2)) * 4))
	}, ":")

	if not RuntimeState.ChinaHatFolder or not RuntimeState.ChinaHatFolder.Parent or ChinaHatCacheKey ~= CacheKey then
		if SpinSpeed > 0 and os.clock() - ChinaHatLastRebuildTime < 0.08 and RuntimeState.ChinaHatFolder and RuntimeState.ChinaHatFolder.Parent then
			return
		end

		ChinaHatLastRebuildTime = os.clock()
		RebuildChinaHat(HeadPart, CacheKey, RuntimeState.ChinaHatRotation)
	end
end

function SaveOriginalLighting()
	if RuntimeState.OriginalLighting then
		return
	end

	RuntimeState.OriginalLighting = {
		Brightness = Lighting.Brightness,
		ClockTime = Lighting.ClockTime,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient
	}
end

function UpdateAtmosphere()
	if AutoParry.AtmosphereEnabled then
		if not RuntimeState.AtmosphereEffect or not RuntimeState.AtmosphereEffect.Parent then
			RuntimeState.AtmosphereEffect = Instance.new("Atmosphere")
			RuntimeState.AtmosphereEffect.Name = "HyperionAtmosphere"
			RuntimeState.AtmosphereEffect.Parent = Lighting
		end

		RuntimeState.AtmosphereEffect.Density = math.clamp(SafeToNumber(AutoParry.AtmosphereDensity, 0.35), 0, 1)
		RuntimeState.AtmosphereEffect.Color = GetVisualColor()
	else
		if RuntimeState.AtmosphereEffect then
			RuntimeState.AtmosphereEffect:Destroy()
			RuntimeState.AtmosphereEffect = nil
		end
	end
end

function UpdateLighting()
	if AutoParry.WorldLightingEnabled then
		SaveOriginalLighting()
		Lighting.Brightness = SafeToNumber(AutoParry.LightingBrightness, 3)
		Lighting.ClockTime = math.clamp(SafeToNumber(AutoParry.LightingClockTime, 14), 0, 24)
		Lighting.Ambient = GetVisualColor()
		Lighting.OutdoorAmbient = GetVisualColor()
	else
		if RuntimeState.OriginalLighting then
			Lighting.Brightness = RuntimeState.OriginalLighting.Brightness
			Lighting.ClockTime = RuntimeState.OriginalLighting.ClockTime
			Lighting.Ambient = RuntimeState.OriginalLighting.Ambient
			Lighting.OutdoorAmbient = RuntimeState.OriginalLighting.OutdoorAmbient
			RuntimeState.OriginalLighting = nil
		end
	end
end

function UpdateSaturation()
	if AutoParry.SaturationEnabled then
		if not RuntimeState.SaturationEffect or not RuntimeState.SaturationEffect.Parent then
			RuntimeState.SaturationEffect = Instance.new("ColorCorrectionEffect")
			RuntimeState.SaturationEffect.Name = "HyperionSaturation"
			RuntimeState.SaturationEffect.Parent = Lighting
		end

		RuntimeState.SaturationEffect.Saturation = math.clamp(SafeToNumber(AutoParry.SaturationAmount, 0.35), -1, 1)
	else
		if RuntimeState.SaturationEffect then
			RuntimeState.SaturationEffect:Destroy()
			RuntimeState.SaturationEffect = nil
		end
	end
end

function GetSky()
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if not sky then
		sky = Instance.new("Sky")
		sky.Name = "HyperionSky"
		sky.Parent = Lighting
	end
	return sky
end

function NormalizeAssetId(value)
	if type(value) ~= "string" then return "" end
	local v = value:match("^%s*(.-)%s*$")
	if v == "" then return "" end
	local id = v:match("rbxassetid://(%d+)") or v:match("^%d+$")
	if id then return "rbxassetid://" .. id end
	return v
end

function UpdateAllVisuals(DeltaTime)
	pcall(UpdateBallTrail)
	pcall(UpdateCharacterTrail)
	pcall(UpdateJumpCircle)
	pcall(UpdateSnow, DeltaTime)
	pcall(UpdateChinaHat, DeltaTime)
	pcall(UpdateAtmosphere)
	pcall(UpdateLighting)
	pcall(UpdateSaturation)
	pcall(UpdateTargetLockRing, DeltaTime)
	pcall(UpdateDistanceRing, DeltaTime)
	pcall(UpdateNotificationBlur)
end

function HyperionPort.DestroyTargetLockRing()
	if RuntimeState.TargetLockRing then
		RuntimeState.TargetLockRing:Destroy()
		RuntimeState.TargetLockRing = nil
	end
	RuntimeState.TargetLockRingFade = 0
	RuntimeState.TargetLockRingTargetFade = 0
end

function UpdateTargetLockRing(DeltaTime)
	if not AutoParry.TargetLockRingEnabled then
		RuntimeState.TargetLockRingTargetFade = 0
		if RuntimeState.TargetLockRingFade <= 0.001 then
			HyperionPort.DestroyTargetLockRing()
			return
		end
	end

	local targetHrp
	if AutoParry.TargetLockRingEnabled and targetHrp then
		RuntimeState.TargetLockRingTargetFade = 1
	else
		RuntimeState.TargetLockRingTargetFade = 0
	end

	RuntimeState.TargetLockRingFade = SmoothValue(RuntimeState.TargetLockRingFade, RuntimeState.TargetLockRingTargetFade, 0.12, DeltaTime)

	if RuntimeState.TargetLockRingFade <= 0.001 and RuntimeState.TargetLockRingTargetFade == 0 then
		HyperionPort.DestroyTargetLockRing()
		return
	end

	if not RuntimeState.TargetLockRing then
		local part = Instance.new("Part")
		part.Name = "HyperionTargetLockRing"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Locked = true
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(1, 1, 1)
		part.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.RingHandle
		mesh.Parent = part

		RuntimeState.TargetLockRing = part
		RuntimeState.TargetLockRing.Mesh = mesh
	end

	local ring = RuntimeState.TargetLockRing
	local mesh = ring.Mesh
	local radius = math.max(0.5, SafeToNumber(AutoParry.TargetLockRingRadius, 3.2))
	local thickness = math.max(0.02, SafeToNumber(AutoParry.TargetLockRingThickness, 0.35))

	RuntimeState.TargetLockRingPulse = (RuntimeState.TargetLockRingPulse + DeltaTime * 1.4) % (math.pi * 2)
	local breathe = 1 + math.sin(RuntimeState.TargetLockRingPulse) * 0.06
	local rot = RuntimeState.TargetLockRingPulse * 0.9

	ring.CFrame = targetHrp.CFrame * CFrame.Angles(0, rot, 0) * CFrame.new(0, 0, 0)
	mesh.Scale = Vector3.new(radius * 2 * breathe, radius * 2 * breathe, thickness * breathe)

	local color
	if AutoParry.ParryFXRainbow then
		color = Color3.fromHSV((ParryFXRainbowHue) % 1, 1, 1)
	else
		color = GetUIColor("Accent")
	end

	ring.Color = color
	local fade = RuntimeState.TargetLockRingFade
	ring.Transparency = 1 - fade
	mesh.VertexColor = Vector3.new(color.R, color.G, color.B)
end

function HyperionPort.DestroyDistanceRing()
	if RuntimeState.DistanceRing then
		RuntimeState.DistanceRing:Destroy()
		RuntimeState.DistanceRing = nil
	end
	RuntimeState.DistanceRingRadius = SafeToNumber(AutoParry.DistanceRingRadius, 18)
end

function SmoothRadiusToward(current, target, dt)
	local speed = math.clamp(dt * 6, 0, 1)
	return current + (target - current) * speed
end

function UpdateDistanceRing(DeltaTime)
	if not AutoParry.DistanceRingEnabled then
		if RuntimeState.DistanceRing then
			HyperionPort.DestroyDistanceRing()
		end
		return
	end

	local _, hrp = GetCharacter()
	if not hrp then
		if RuntimeState.DistanceRing then
			RuntimeState.DistanceRing.Transparency = 1
		end
		return
	end

	local targetRadius = math.max(1, SafeToNumber(AutoParry.DistanceRingRadius, 18))
	RuntimeState.DistanceRingRadius = SmoothRadiusToward(RuntimeState.DistanceRingRadius, targetRadius, DeltaTime)

	if not RuntimeState.DistanceRing then
		local part = Instance.new("Part")
		part.Name = "HyperionDistanceRing"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Locked = true
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(1, 1, 1)
		part.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.RingHandle
		mesh.Parent = part

		RuntimeState.DistanceRing = part
		RuntimeState.DistanceRing.Mesh = mesh
	end

	local ring = RuntimeState.DistanceRing
	local mesh = ring.Mesh
	local r = RuntimeState.DistanceRingRadius
	local thickness = math.max(0.05, SafeToNumber(AutoParry.DistanceRingThickness, 0.6))

	RuntimeState.DistanceRingPulse = (RuntimeState.DistanceRingPulse + DeltaTime * 2) % (math.pi * 2)
	local pulse = AutoParry.DistanceRingPulse and (1 + math.sin(RuntimeState.DistanceRingPulse) * 0.04) or 1

	ring.CFrame = hrp.CFrame
	mesh.Scale = Vector3.new(r * 2 * pulse, r * 2 * pulse, thickness)

	local color = GetUIColor("Accent")
	ring.Color = color
	mesh.VertexColor = Vector3.new(color.R, color.G, color.B)

	local camPos = workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position
	local dist = camPos and (camPos - hrp.Position).Magnitude or 50
	local opacity = math.clamp(0.85 - (dist - 20) / 220, 0.18, 0.85)
	ring.Transparency = 1 - opacity
end

function GetUIColor(ColorType)
	if ColorType == "Accent" then
		return Color3.fromRGB(math.floor(SafeToNumber(AutoParry.AccentColorR, 255)), math.floor(SafeToNumber(AutoParry.AccentColorG, 40)), math.floor(SafeToNumber(AutoParry.AccentColorB, 40)))
	elseif ColorType == "Background" then
		return Color3.fromRGB(math.floor(SafeToNumber(AutoParry.UIBackgroundR, 18)), math.floor(SafeToNumber(AutoParry.UIBackgroundG, 16)), math.floor(SafeToNumber(AutoParry.UIBackgroundB, 28)))
	end

	return Color3.fromRGB(math.floor(SafeToNumber(AutoParry.UIFontR, 235)), math.floor(SafeToNumber(AutoParry.UIFontG, 235)), math.floor(SafeToNumber(AutoParry.UIFontB, 245)))
end

function ApplyUITheme()
	-- Vape UI has its own fixed theme; Frost theme application removed.
	-- Accent color lives in AutoParry.AccentColorR/G/B and is used by visuals.
end

function FormatImageAsset(value)
	value = tostring(value or "")

	if value == "" then
		return ""
	end

	if tonumber(value) then
		return "rbxassetid://" .. value
	end

	return value
end

function DestroyCustomLogo()
	if RuntimeState.CustomLogoGui then
		RuntimeState.CustomLogoGui:Destroy()
		RuntimeState.CustomLogoGui = nil
		RuntimeState.CustomLogoImage = nil
	end
end

function UpdateCustomUILogo()
	if not AutoParry.CustomImageEnabled or tostring(AutoParry.CustomImage or "") == "" then
		DestroyCustomLogo()
		return
	end

	if not RuntimeState.CustomLogoGui then
		RuntimeState.CustomLogoGui = Instance.new("ScreenGui")
		RuntimeState.CustomLogoGui.Name = "HyperionCustomImage"
		RuntimeState.CustomLogoGui.ResetOnSpawn = false
		RuntimeState.CustomLogoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		RuntimeState.CustomLogoGui.Parent = PlayerGui

		RuntimeState.CustomLogoImage = Instance.new("ImageLabel")
		RuntimeState.CustomLogoImage.BackgroundTransparency = 1
		RuntimeState.CustomLogoImage.Position = UDim2.new(0, 18, 0, 84)
		RuntimeState.CustomLogoImage.Parent = RuntimeState.CustomLogoGui
	end

	local DetectorRadius = math.clamp(SafeToNumber(AutoParry.CustomImageSize, 56), 24, 180)
	RuntimeState.CustomLogoImage.Size = UDim2.fromOffset(DetectorRadius, DetectorRadius)
	RuntimeState.CustomLogoImage.Image = FormatImageAsset(AutoParry.CustomImage)
end

function HyperionPort.GetMediaExtensionFromSource(value)
	value = tostring(value or ""):lower()
	local clean = value:match("^([^%?#]+)") or value
	local ext = clean:match("%.([%w]+)$")

	if ext and #ext <= 5 then
		return ext
	end

	return nil
end

function HyperionPort.GetMediaTypeFromExtension(ext)
	ext = tostring(ext or ""):lower()

	if ext == "mp4" or ext == "webm" or ext == "mov" then
		return "video"
	end

	return "image"
end

function HyperionPort.DetectMediaExtension(data, value, contentType)
	local ext = HyperionPort.GetMediaExtensionFromSource(value)
	local content = tostring(contentType or ""):lower()

	if content:find("gif", 1, true) then return "gif" end
	if content:find("png", 1, true) then return "png" end
	if content:find("jpeg", 1, true) or content:find("jpg", 1, true) then return "jpg" end
	if content:find("webp", 1, true) then return "webp" end
	if content:find("mp4", 1, true) then return "mp4" end
	if content:find("webm", 1, true) then return "webm" end
	if content:find("quicktime", 1, true) then return "mov" end

	if type(data) == "string" and #data >= 12 then
		if data:sub(1, 6) == "GIF87a" or data:sub(1, 6) == "GIF89a" then return "gif" end
		if data:byte(1) == 137 and data:sub(2, 4) == "PNG" then return "png" end
		if data:byte(1) == 255 and data:byte(2) == 216 and data:byte(3) == 255 then return "jpg" end
		if data:sub(1, 4) == "RIFF" and data:sub(9, 12) == "WEBP" then return "webp" end
		if data:sub(5, 8) == "ftyp" then return ext == "mov" and "mov" or "mp4" end
		if data:byte(1) == 26 and data:byte(2) == 69 and data:byte(3) == 223 and data:byte(4) == 163 then return "webm" end
	end

	return ext or "png"
end

function HyperionPort.FetchMedia(value)
	local requestFunction = request or syn and syn.request or http_request

	if type(requestFunction) == "function" then
		local url = value
		local maxRedirects = 5

		for redirect = 1, maxRedirects do
			local ok, response = pcall(requestFunction, {
				Url = url,
				Method = "GET"
			})

			if not (ok and type(response) == "table") then
				break
			end

			local statusCode = response.StatusCode or response.statusCode or response.status_code or 200
			local headers = response.Headers or response.headers or {}
			local location = headers["Location"] or headers["location"] or headers["Location"]

			if (statusCode >= 300 and statusCode < 400) and location and location ~= "" then
				url = location
				if redirect < maxRedirects then
					continue
				end
			end

			local body = response.Body or response.body
			local contentType = headers["Content-Type"] or headers["content-type"] or headers["content-Type"]

			if type(body) == "string" and body ~= "" then
				local contentLower = tostring(contentType or ""):lower()

				if contentLower:find("text/html") or contentLower:find("text/plain") then
					if #body < 1024 or body:sub(1, 15):lower():find("<html") or body:sub(1, 15):lower():find("<!doc") then
						return nil, "html_page"
					end
				end

				return body, contentType
			end

			break
		end
	end

	local ok, data = pcall(function()
		return game:HttpGet(value, true)
	end)

	if ok and type(data) == "string" and data ~= "" then
		if data:sub(1, 15):lower():find("<html") or data:sub(1, 15):lower():find("<!doc") then
			return nil, "html_page"
		end

		return data, nil
	end

	return nil, nil
end

StoredModuleBackgrounds = {}

function HyperionPort.AdjustModuleBackgrounds(transparent)
	-- No-op on Vape UI (no Frost module backgrounds to adjust)
end

function HyperionPort.SetWindowContainerTransparent(transparent)
	-- No-op on Vape UI (window transparency handled by the framework)
end

function HyperionPort.GetHumanoidAndRoot()
	local Character = Player.Character
	if not Character then return nil, nil end

	return Character:FindFirstChildOfClass("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
end

function HyperionPort.CaptureOriginalCharacterValues(humanoid)
	if HyperionPort.OriginalCharacterValues or not humanoid then return end

	HyperionPort.OriginalCharacterValues = {
		WalkSpeed = humanoid.WalkSpeed,
		JumpPower = humanoid.JumpPower,
		JumpHeight = humanoid.JumpHeight,
		HipHeight = humanoid.HipHeight,
		AutoRotate = humanoid.AutoRotate
	}
end

function HyperionPort.RestoreCharacterModifiers()
	local humanoid = HyperionPort.GetHumanoidAndRoot()

	if humanoid and HyperionPort.OriginalCharacterValues then
		humanoid.WalkSpeed = HyperionPort.OriginalCharacterValues.WalkSpeed or 16
		if humanoid.UseJumpPower then
			humanoid.JumpPower = HyperionPort.OriginalCharacterValues.JumpPower or 50
		else
			humanoid.JumpHeight = HyperionPort.OriginalCharacterValues.JumpHeight or 7.2
		end
		humanoid.HipHeight = HyperionPort.OriginalCharacterValues.HipHeight or 0
		humanoid.AutoRotate = HyperionPort.OriginalCharacterValues.AutoRotate ~= false
	end

	workspace.Gravity = HyperionPort.OriginalGravity or 196.2
end

function HyperionPort.UpdateInfiniteJumpConnection()
	if HyperionPort.InfiniteJumpConnection then
		HyperionPort.InfiniteJumpConnection:Disconnect()
		HyperionPort.InfiniteJumpConnection = nil
	end

	if AutoParry.CharacterModifierEnabled and AutoParry.InfiniteJumpEnabled then
		HyperionPort.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
			local humanoid = HyperionPort.GetHumanoidAndRoot()
			if humanoid and AutoParry.CharacterModifierEnabled and AutoParry.InfiniteJumpEnabled then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end
end

function HyperionPort.ApplyCharacterModifiers()
	local humanoid, root = HyperionPort.GetHumanoidAndRoot()
	if not humanoid then return end

	HyperionPort.CaptureOriginalCharacterValues(humanoid)

	if AutoParry.WalkSpeedEnabled then
		humanoid.WalkSpeed = SafeToNumber(AutoParry.WalkSpeedValue, 36)
	end

	if AutoParry.JumpPowerEnabled then
		local JumpPowerValue = SafeToNumber(AutoParry.JumpPowerValue, 50)
		if humanoid.UseJumpPower then
			humanoid.JumpPower = JumpPowerValue
		else
			humanoid.JumpHeight = JumpPowerValue * 0.144
		end
	end

	if AutoParry.HipHeightEnabled then
		humanoid.HipHeight = SafeToNumber(AutoParry.HipHeightValue, 0)
	end

	if AutoParry.GravityEnabled then
		workspace.Gravity = SafeToNumber(AutoParry.GravityValue, 196.2)
	end

	if AutoParry.SpinEnabled and root then
		humanoid.AutoRotate = false
		HyperionPort.SpinAngle = (HyperionPort.SpinAngle + SafeToNumber(AutoParry.SpinSpeed, 5)) % 360
		root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(HyperionPort.SpinAngle), 0)
	elseif HyperionPort.OriginalCharacterValues then
		humanoid.AutoRotate = HyperionPort.OriginalCharacterValues.AutoRotate ~= false
	end
end

function HyperionPort.SetCharacterModifier(value)
	AutoParry.CharacterModifierEnabled = value == true

	if HyperionPort.CharacterConnection then
		HyperionPort.CharacterConnection:Disconnect()
		HyperionPort.CharacterConnection = nil
	end

	if AutoParry.CharacterModifierEnabled then
		HyperionPort.SpinAngle = 0
		HyperionPort.CharacterConnection = RunService.Heartbeat:Connect(HyperionPort.ApplyCharacterModifiers)
	else
		HyperionPort.RestoreCharacterModifiers()
		HyperionPort.OriginalCharacterValues = nil
		HyperionPort.SpinAngle = 0
	end

	HyperionPort.UpdateInfiniteJumpConnection()
end

function HyperionPort.SetFOV(value)
	AutoParry.FOVEnabled = value == true

	if HyperionPort.FOVConnection then
		HyperionPort.FOVConnection:Disconnect()
		HyperionPort.FOVConnection = nil
	end

	if AutoParry.FOVEnabled then
		HyperionPort.FOVConnection = RunService.RenderStepped:Connect(function()
			local Camera = workspace.CurrentCamera
			if Camera then
				Camera.FieldOfView = SafeToNumber(AutoParry.CameraFOV, 70)
			end
		end)
	elseif workspace.CurrentCamera then
		workspace.CurrentCamera.FieldOfView = 70
	end
end

HEADLESS_MESH_ID = "rbxassetid://1095708"
KORBLOX_MESH_ID = "rbxassetid://101851696"
KORBLOX_TEXTURE_ID = "rbxassetid://101851254"

function HyperionPort.ApplyHeadlessKorbloxDescription(Character)
	Character = Character or Player.Character
	if not Character then return false end

	local head = Character:FindFirstChild("Head")
	local rightLeg = Character:FindFirstChild("Right Leg")

	if AutoParry.HeadlessEnabled then
		if head then
			head.Transparency = 1
			head.CanCollide = false

			local face = head:FindFirstChildOfClass("Decal")
			if face then
				if not head:GetAttribute("HyperionOriginalFace") then
					head:SetAttribute("HyperionOriginalFace", face.Texture)
				end
				face:Destroy()
			end

			for _, item in ipairs(head:GetChildren()) do
				if item:IsA("Decal") or item:IsA("Texture") then
					item.Transparency = 1
				end
			end

			local existingMesh = head:FindFirstChild("HyperionHeadlessMesh")
			if not existingMesh then
				local mesh = Instance.new("SpecialMesh")
				mesh.Name = "HyperionHeadlessMesh"
				mesh.MeshType = Enum.MeshType.FileMesh
				mesh.MeshId = HEADLESS_MESH_ID
				mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
				mesh.Parent = head
			end
		end
	elseif head then
		head.Transparency = 0
		head.CanCollide = false

		local savedFace = head:GetAttribute("HyperionOriginalFace")
		if savedFace and not head:FindFirstChildOfClass("Decal") then
			local face = Instance.new("Decal")
			face.Name = "face"
			face.Texture = savedFace
			face.Parent = head
		end

		for _, item in ipairs(head:GetChildren()) do
			if item.Name == "HyperionHeadlessMesh" then
				item:Destroy()
			elseif item:IsA("Decal") or item:IsA("Texture") then
				item.Transparency = 0
			end
		end
	end

	if AutoParry.KorbloxEnabled then
		if rightLeg then
			local existingMesh = rightLeg:FindFirstChild("HyperionKorbloxMesh")
			if not existingMesh then
				local mesh = Instance.new("SpecialMesh")
				mesh.Name = "HyperionKorbloxMesh"
				mesh.MeshType = Enum.MeshType.FileMesh
				mesh.MeshId = KORBLOX_MESH_ID
				mesh.TextureId = KORBLOX_TEXTURE_ID
				mesh.Scale = Vector3.new(0.96, 0.96, 0)
				mesh.Parent = rightLeg
			end
		end
	elseif rightLeg then
		for _, item in ipairs(rightLeg:GetChildren()) do
			if item.Name == "HyperionKorbloxMesh" then
				item:Destroy()
			end
		end
	end

	return true
end

function HyperionPort.SetHeadlessOnly(value)
	AutoParry.HeadlessEnabled = value == true
	HyperionPort.ApplyHeadlessKorbloxDescription(Player.Character)
	NotifyToggleState("Headless", AutoParry.HeadlessEnabled)
end

function HyperionPort.SetKorbloxOnly(value)
	AutoParry.KorbloxEnabled = value == true
	HyperionPort.ApplyHeadlessKorbloxDescription(Player.Character)
	NotifyToggleState("Korblox", AutoParry.KorbloxEnabled)
end

AvatarChangerState = {
	Connection = nil,
	AppliedName = "",
	Applying = "",
}

AvatarChanger = {}

local AVATAR_CHANGER_TAG = "HyperionAvatarChanger"
local AvatarChangerHeadlessMeshId = "rbxassetid://1095708"
local AvatarChangerKorbloxMeshIds = { 101851696, 139607718 }
local AvatarChangerHeadlessHeadIds = { 15093053680 }

function AvatarChanger.GetNumericId(value)
	if type(value) == "number" then
		return value
	end

	if type(value) == "string" then
		return tonumber(value:match("%d+"))
	end

	return nil
end

function AvatarChanger.FindHandleAttachment(handle)
	for _, child in ipairs(handle:GetChildren()) do
		if child:IsA("Attachment") then
			return child
		end
	end

	return nil
end

function AvatarChanger.FindCharacterAttachment(character, attachmentName)
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("Attachment")
			and descendant.Name == attachmentName
			and descendant.Parent:IsA("BasePart") then

			return descendant
		end
	end

	return nil
end

function AvatarChanger.AttachAccessory(accessory, character)
	local handle = accessory:FindFirstChild("Handle")

	if not handle or not handle:IsA("BasePart") then
		return false
	end

	local handleAttachment = AvatarChanger.FindHandleAttachment(handle)

	if not handleAttachment then
		return false
	end

	local characterAttachment = AvatarChanger.FindCharacterAttachment(character, handleAttachment.Name)

	if not characterAttachment then
		return false
	end

	handle.Anchored = false
	handle.CanCollide = false
	handle.Massless = true
	handle.LocalTransparencyModifier = 0

	handle.CFrame =
		characterAttachment.Parent.CFrame
		* characterAttachment.CFrame
		* handleAttachment.CFrame:Inverse()

	local oldWeld = handle:FindFirstChild("AccessoryWeld")

	if oldWeld then
		oldWeld:Destroy()
	end

	local weld = Instance.new("Weld")
	weld.Name = "AccessoryWeld"
	weld.Part0 = handle
	weld.Part1 = characterAttachment.Parent
	weld.C0 = handleAttachment.CFrame
	weld.C1 = characterAttachment.CFrame
	weld.Parent = handle

	return true
end

function AvatarChanger.IsKorbloxDescription(desc)
	if not desc then
		return false
	end

	local rightLegId = AvatarChanger.GetNumericId(desc.RightLeg)

	if not rightLegId then
		return false
	end

	for _, knownId in ipairs(AvatarChangerKorbloxMeshIds) do
		if rightLegId == knownId then
			return true
		end
	end


	return rightLegId ~= nil
end

function AvatarChanger.IsHeadlessDescription(desc)
	if not desc then
		return false
	end

	local headId = AvatarChanger.GetNumericId(desc.Head)

	if not headId or headId == 0 then
		return true
	end

	for _, knownId in ipairs(AvatarChangerHeadlessHeadIds) do
		if headId == knownId then
			return true
		end
	end

	return false
end

function AvatarChanger.ApplyHeadless(targetHead, enabled)
	if not targetHead then
		return
	end

	if enabled then
		targetHead.Transparency = 1
		targetHead.CanCollide = false

		local face = targetHead:FindFirstChild("face")

		if face and face:IsA("Decal") then
			face:Destroy()
		end

		for _, item in ipairs(targetHead:GetChildren()) do
			if item:IsA("Decal") or item:IsA("Texture") then
				item.Transparency = 1
			end
		end

		if not targetHead:FindFirstChild("HyperionHeadlessMesh") then
			local mesh = Instance.new("SpecialMesh")
			mesh.Name = "HyperionHeadlessMesh"
			mesh.MeshType = Enum.MeshType.FileMesh
			mesh.MeshId = AvatarChangerHeadlessMeshId
			mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
			mesh.Parent = targetHead
		end
	else
		targetHead.Transparency = 0
		targetHead.CanCollide = false

		for _, item in ipairs(targetHead:GetChildren()) do
			if item.Name == "HyperionHeadlessMesh" then
				item:Destroy()
			elseif item:IsA("Decal") or item:IsA("Texture") then
				item.Transparency = 0
			end
		end
	end
end

function AvatarChanger.CopySpecialMesh(sourceMesh, targetPart)
	if not sourceMesh or not targetPart or not targetPart:IsA("BasePart") then
		return false
	end

	local targetMesh = targetPart:FindFirstChild("HyperionCopiedBodyMesh")

	if targetMesh and not targetMesh:IsA("SpecialMesh") then
		targetMesh:Destroy()
		targetMesh = nil
	end

	if not targetMesh then
		targetMesh = Instance.new("SpecialMesh")
		targetMesh.Name = "HyperionCopiedBodyMesh"
		targetMesh.Parent = targetPart
	end

	targetMesh.MeshType = sourceMesh.MeshType
	targetMesh.MeshId = sourceMesh.MeshId
	targetMesh.TextureId = sourceMesh.TextureId
	targetMesh.Scale = sourceMesh.Scale
	targetMesh.Offset = sourceMesh.Offset
	targetMesh.VertexColor = sourceMesh.VertexColor

	return true
end

function AvatarChanger.CopyBodyPartAppearance(sourcePart, targetPart)
	if not sourcePart or not targetPart
		or not sourcePart:IsA("BasePart") or not targetPart:IsA("BasePart") then
		return false
	end

	targetPart.Color = sourcePart.Color
	targetPart.Material = sourcePart.Material

	if sourcePart:IsA("MeshPart") and targetPart:IsA("MeshPart") then
		targetPart.MeshId = sourcePart.MeshId
		targetPart.TextureID = sourcePart.TextureID

		if sourcePart.RenderFidelity then
			targetPart.RenderFidelity = sourcePart.RenderFidelity
		end

		return true
	end

	local sourceMesh = sourcePart:FindFirstChildOfClass("SpecialMesh")

	if sourceMesh then
		return AvatarChanger.CopySpecialMesh(sourceMesh, targetPart)
	end

	return false
end

function AvatarChanger.GetBodyPartNames(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
		return {
			"Head",
			"Torso",
			"Left Arm",
			"Right Arm",
			"Left Leg",
			"Right Leg",
		}
	end

	return {
		"Head",
		"UpperTorso",
		"LowerTorso",

		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",

		"RightUpperArm",
		"RightLowerArm",
		"RightHand",

		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot",

		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
	}
end

function AvatarChanger.ClearApplied(character)
	if not character then
		return
	end

	for _, item in ipairs(character:GetChildren()) do
		if CollectionService:HasTag(item, AVATAR_CHANGER_TAG) then
			pcall(function()
				item:Destroy()
			end)
		end
	end
end

function AvatarChanger.CopyAccessoriesAndClothing(sourceModel, character)
	for _, item in ipairs(sourceModel:GetChildren()) do
		if item:IsA("Accessory")
			or item:IsA("Shirt")
			or item:IsA("Pants")
			or item:IsA("ShirtGraphic")
			or item:IsA("BodyColors") then

			local clone = item:Clone()
			CollectionService:AddTag(clone, AVATAR_CHANGER_TAG)
			clone.Parent = character

			if clone:IsA("Accessory") then
				task.defer(function()
					AvatarChanger.AttachAccessory(clone, character)
				end)
			end
		end
	end
end

function AvatarChanger.CopyFace(sourceModel, character)
	local sourceHead = sourceModel:FindFirstChild("Head")
	local targetHead = character:FindFirstChild("Head")

	if not sourceHead or not targetHead then
		return
	end

	local sourceFace = sourceHead:FindFirstChild("face")
	local targetFace = targetHead:FindFirstChild("face")

	if sourceFace and targetFace
		and sourceFace:IsA("Decal")
		and targetFace:IsA("Decal") then

		targetFace.Texture = sourceFace.Texture
		targetFace.Transparency = sourceFace.Transparency
	elseif sourceFace and sourceFace:IsA("Decal") then
		local newFace = sourceFace:Clone()
		newFace.Name = "face"

		if targetFace then
			targetFace:Destroy()
		end

		newFace.Parent = targetHead
	end
end

function AvatarChanger.CopyBodyColors(sourceModel, character)
	local sourceColors = sourceModel:FindFirstChildOfClass("BodyColors")

	if not sourceColors then
		return
	end

	local targetColors = character:FindFirstChildOfClass("BodyColors")

	if not targetColors then
		targetColors = Instance.new("BodyColors")
		targetColors.Parent = character
	end

	targetColors.HeadColor3 = sourceColors.HeadColor3
	targetColors.TorsoColor3 = sourceColors.TorsoColor3
	targetColors.LeftArmColor3 = sourceColors.LeftArmColor3
	targetColors.RightArmColor3 = sourceColors.RightArmColor3
	targetColors.LeftLegColor3 = sourceColors.LeftLegColor3
	targetColors.RightLegColor3 = sourceColors.RightLegColor3
end

function AvatarChanger.CopyR6CharacterMeshes(sourceModel, character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		return
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("CharacterMesh") then
			child:Destroy()
		end
	end

	for _, child in ipairs(sourceModel:GetChildren()) do
		if child:IsA("CharacterMesh") then
			local clone = child:Clone()
			CollectionService:AddTag(clone, AVATAR_CHANGER_TAG)
			clone.Parent = character
		end
	end
end

function AvatarChanger.CopyBodyParts(sourceModel, character)
	for _, partName in ipairs(AvatarChanger.GetBodyPartNames(character)) do
		local sourcePart = sourceModel:FindFirstChild(partName)
		local targetPart = character:FindFirstChild(partName)

		if sourcePart and targetPart then
			AvatarChanger.CopyBodyPartAppearance(sourcePart, targetPart)
		end
	end
end

function AvatarChanger.ApplyKorbloxFromGeneratedModel(sourceModel, character)
	if not sourceModel or not character then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return false
	end

	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		local sourceCharacterMesh = nil

		for _, child in ipairs(sourceModel:GetChildren()) do
			if child:IsA("CharacterMesh")
				and child.BodyPart == Enum.BodyPart.RightLeg then

				sourceCharacterMesh = child
				break
			end
		end

		if sourceCharacterMesh then
			for _, child in ipairs(character:GetChildren()) do
				if child:IsA("CharacterMesh")
					and child.BodyPart == Enum.BodyPart.RightLeg then

					child:Destroy()
				end
			end

			local clonedCharacterMesh = sourceCharacterMesh:Clone()
			CollectionService:AddTag(clonedCharacterMesh, AVATAR_CHANGER_TAG)
			clonedCharacterMesh.Parent = character
			return true
		end

		return false
	end


	local copied = false

	for _, partName in ipairs({
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
	}) do
		local sourcePart = sourceModel:FindFirstChild(partName)
		local targetPart = character:FindFirstChild(partName)

		if sourcePart and targetPart then
			if AvatarChanger.CopyBodyPartAppearance(sourcePart, targetPart) then
				copied = true
			end
		end
	end

	return copied
end

function AvatarChanger.CreateSourceModel(desc, targetCharacter)
	local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil
	end

	local ok, model = pcall(function()
		return Players:CreateHumanoidModelFromDescription(desc, humanoid.RigType)
	end)

	if not ok or not model then
		return nil
	end

	model.Name = "HyperionFetchedAvatar"
	model.Parent = workspace

	return model
end

function HyperionPort.ApplyAvatarLook(targetName)
	targetName = tostring(targetName or "")
	targetName = targetName:match("^%s*(.-)%s*$") or ""


	if AvatarChangerState.Applying ~= "" and AvatarChangerState.Applying == targetName then
		return
	end

	AvatarChangerState.Applying = targetName

	task.spawn(function()
		local ok, err = pcall(function()

			local resolveName = targetName
			if targetName == "" or targetName:lower() == "none" then
				resolveName = Player.Name
			end

			local character = Player.Character or Player.CharacterAdded:Wait()
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				return
			end

			ShowNotification("Avatar Changer: applying look from " .. resolveName .. "...", 2, "info")

			local okUserId, userId = pcall(function()
				return Players:GetUserIdFromNameAsync(resolveName)
			end)

			if not okUserId or not userId then
				error("could not resolve player '" .. resolveName .. "' (" .. tostring(userId) .. ")")
			end

			local okDesc, desc = pcall(function()
				return Players:GetHumanoidDescriptionFromUserId(userId)
			end)

			if not okDesc or not desc then
				error("failed to load the avatar of '" .. resolveName .. "' (" .. tostring(desc) .. ")")
			end

			local sourceModel = AvatarChanger.CreateSourceModel(desc, character)

			if not sourceModel then
				error("failed to build the avatar model for '" .. resolveName .. "' (assets could not be fetched)")
			end


			AvatarChanger.ClearApplied(character)


			local copySucceeded = false
			local copyFailedCount = 0

			local function SafeCopy(step)
				local stepOk = pcall(step)
				if stepOk then
					copySucceeded = true
				else
					copyFailedCount += 1
				end
			end

			SafeCopy(function() AvatarChanger.CopyAccessoriesAndClothing(sourceModel, character) end)
			SafeCopy(function() AvatarChanger.CopyFace(sourceModel, character) end)
			SafeCopy(function() AvatarChanger.CopyBodyColors(sourceModel, character) end)
			SafeCopy(function() AvatarChanger.CopyR6CharacterMeshes(sourceModel, character) end)
			SafeCopy(function() AvatarChanger.CopyBodyParts(sourceModel, character) end)

			local targetHead = character:FindFirstChild("Head")
			SafeCopy(function()
				AvatarChanger.ApplyHeadless(targetHead, AvatarChanger.IsHeadlessDescription(desc))
			end)

			if AvatarChanger.IsKorbloxDescription(desc) then
				SafeCopy(function()
					AvatarChanger.ApplyKorbloxFromGeneratedModel(sourceModel, character)
				end)
			end

			sourceModel:Destroy()


			if AutoParry.HeadlessEnabled or AutoParry.KorbloxEnabled then
				SafeCopy(function()
					HyperionPort.ApplyHeadlessKorbloxDescription(character)
				end)
			end

			AvatarChangerState.AppliedName = targetName

			if not copySucceeded then
				error("could not apply the look of '" .. resolveName .. "' (" .. copyFailedCount .. " step(s) failed)")
			end

			if resolveName ~= Player.Name then
				if copyFailedCount == 0 then
					ShowNotification("Avatar Changer: copied look from " .. resolveName, 3, "success")
				else
					ShowNotification("Avatar Changer: applied look from " .. resolveName .. " (" .. copyFailedCount .. " step(s) failed)", 4, "warning")
				end
			else
				ShowNotification("Avatar Changer: reset to your own look", 3)
			end
		end)

		AvatarChangerState.Applying = ""

		if not ok then
			ShowNotification("Avatar Changer: " .. tostring(err), 4, "error")
		end
	end)
end

function HyperionPort.SetAvatarChanger(value)
	AutoParry.AvatarChangerEnabled = value == true

	if AutoParry.AvatarChangerEnabled then
		if not AvatarChangerState.Connection then
			AvatarChangerState.Connection = Player.CharacterAdded:Connect(function(char)
				if AutoParry.AvatarChangerEnabled then
					AvatarChangerState.Applying = ""
					local character = char or Player.Character
					task.spawn(function()
						if not character then return end
						local humanoid = character:FindFirstChildOfClass("Humanoid")
							or character:WaitForChild("Humanoid", 5)
						if not humanoid then return end
						humanoid:WaitForChild("RootPart", 5)

						HyperionPort.ApplyAvatarLook(AutoParry.AvatarChangerName)
						for _, retryDelay in ipairs({ 1, 2.5 }) do
							task.wait(retryDelay)
							if not AutoParry.AvatarChangerEnabled then return end
							if AutoParry.AvatarChangerName == "" then return end
							if Player.Character == character then
								AvatarChangerState.Applying = ""
								HyperionPort.ApplyAvatarLook(AutoParry.AvatarChangerName)
							end
						end
					end)
				end
			end)
		end

		HyperionPort.ApplyAvatarLook(AutoParry.AvatarChangerName)
	else
		if AvatarChangerState.Connection then
			AvatarChangerState.Connection:Disconnect()
			AvatarChangerState.Connection = nil
		end

		if AvatarChangerState.AppliedName ~= "" then
			HyperionPort.ApplyAvatarLook("")
		end

		AvatarChangerState.AppliedName = ""
	end

	MarkConfigDirty()
	NotifyToggleState("Avatar Changer", AutoParry.AvatarChangerEnabled)
end

function HyperionPort.ClearAbilityESP()
	for Index, v385 in pairs(HyperionPort.AbilityESPBillboards) do
		if v385 then
			v385:Destroy()
		end
	end

	table.clear(HyperionPort.AbilityESPBillboards)
	table.clear(HyperionPort.PlayerAbilityStates)

	for player, conns in pairs(HyperionPort.AbilityAttributeWatchers) do
		for _, conn in ipairs(conns) do
			conn:Disconnect()
		end
	end
	table.clear(HyperionPort.AbilityAttributeWatchers)
	table.clear(HyperionPort.PlayerAbilityAttributes)

	if HyperionPort.AbilityESPPlayerConn then
		HyperionPort.AbilityESPPlayerConn:Disconnect()
		HyperionPort.AbilityESPPlayerConn = nil
	end
	if HyperionPort.AbilityESPRemovingConn then
		HyperionPort.AbilityESPRemovingConn:Disconnect()
		HyperionPort.AbilityESPRemovingConn = nil
	end
end

function HyperionPort.UpdateDevTags()
	for _, OtherPlayer in ipairs(Players:GetPlayers()) do
		local Character = OtherPlayer.Character
		local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
		local humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local devBillboard = HyperionPort.DevTagBillboards[OtherPlayer]

		if hrp and humanoid and humanoid.Health > 0 then
			if not devBillboard or not devBillboard.Parent then
				devBillboard = Instance.new("BillboardGui")
				devBillboard.Name = "HyperionDevTag"
				devBillboard.Adornee = hrp
				devBillboard.Size = UDim2.new(0, 200, 0, 28)
				devBillboard.StudsOffset = Vector3.new(3, 1.5, 0)
				devBillboard.AlwaysOnTop = true
				devBillboard.Parent = hrp

				local row = Instance.new("Frame")
				row.Name = "Row"
				row.Size = UDim2.new(1, 0, 1, 0)
				row.BackgroundTransparency = 1
				row.Parent = devBillboard

				local layout = Instance.new("UIListLayout")
				layout.FillDirection = Enum.FillDirection.Horizontal
				layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				layout.VerticalAlignment = Enum.VerticalAlignment.Center
				layout.Padding = UDim.new(0, 4)
				layout.Parent = row

				local icon = Instance.new("ImageLabel")
				icon.Name = "Icon"
				icon.Size = UDim2.fromOffset(22, 22)
				icon.BackgroundTransparency = 1
				icon.Image = CustomIconFallback
				icon.Parent = row

				local label = Instance.new("TextLabel")
				label.Name = "Label"
				label.Size = UDim2.new(0, 0, 1, 0)
				label.AutomaticSize = Enum.AutomaticSize.X
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.GothamBold
				label.TextSize = 14
				label.Text = "Dev"
				label.TextColor3 = Color3.fromRGB(255, 215, 0)
				label.TextStrokeTransparency = 0.3
				label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				label.TextXAlignment = Enum.TextXAlignment.Center
				label.Parent = row

				HyperionPort.DevTagBillboards[OtherPlayer] = devBillboard
			end

			local isDev = false
			for _, devName in ipairs(HyperionPort.DevUsernames) do
				if OtherPlayer.Name:lower() == devName:lower() then
					isDev = true
					break
				end
			end
			if devBillboard:FindFirstChild("Row") then
				devBillboard.Row.Visible = isDev
			end
		else
			if devBillboard then
				devBillboard:Destroy()
				HyperionPort.DevTagBillboards[OtherPlayer] = nil
			end
		end
	end
end

function HyperionPort.UpdateAbilityESP()
	if not AutoParry.AbilityESPEnabled then
		return
	end

	for Index, OtherPlayer in ipairs(Players:GetPlayers()) do
		if OtherPlayer ~= Player then
			local Character = OtherPlayer.Character
			local head = Character and Character:FindFirstChild("Head")
			local humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			local billboard = HyperionPort.AbilityESPBillboards[OtherPlayer]

			if head and humanoid and humanoid.Health > 0 then
				if not billboard or not billboard.Parent then
					billboard = Instance.new("BillboardGui")
					billboard.Name = "HyperionAbilityESP"
					billboard.Adornee = head
					billboard.Size = UDim2.new(0, 200, 0, 62)
					billboard.StudsOffset = Vector3.new(0, 3.5, 0)
					billboard.AlwaysOnTop = true
					billboard.ClipsDescendants = false
					billboard.Parent = head

					local layout = Instance.new("UIListLayout")
					layout.FillDirection = Enum.FillDirection.Vertical
					layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					layout.VerticalAlignment = Enum.VerticalAlignment.Center
					layout.Padding = UDim.new(0, 1)
					layout.Parent = billboard

					local row1 = Instance.new("Frame")
					row1.Name = "Row1"
					row1.Size = UDim2.new(1, 0, 0, 28)
					row1.BackgroundTransparency = 1
					row1.Parent = billboard

					local row1Layout = Instance.new("UIListLayout")
					row1Layout.FillDirection = Enum.FillDirection.Horizontal
					row1Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					row1Layout.VerticalAlignment = Enum.VerticalAlignment.Center
					row1Layout.Padding = UDim.new(0, 4)
					row1Layout.Parent = row1

				local nameLabel = Instance.new("TextLabel")
					nameLabel.Name = "PlayerName"
					nameLabel.Size = UDim2.new(1, 0, 0, 14)
					nameLabel.BackgroundTransparency = 1
					nameLabel.Font = Enum.Font.GothamBold
					nameLabel.TextSize = 11
					nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					nameLabel.TextStrokeTransparency = 0.4
					nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					nameLabel.TextXAlignment = Enum.TextXAlignment.Center
					nameLabel.Parent = billboard

				local icon = Instance.new("ImageLabel")
				icon.Name = "Icon"
				icon.Size = UDim2.fromOffset(28, 28)
				icon.BackgroundTransparency = 1
				icon.Parent = row1

				local iconFallback = Instance.new("TextLabel")
				iconFallback.Name = "IconFallback"
				iconFallback.Size = UDim2.fromOffset(28, 28)
				iconFallback.BackgroundTransparency = 0
				iconFallback.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
				iconFallback.Font = Enum.Font.GothamBold
				iconFallback.TextSize = 16
				iconFallback.Text = "?"
				iconFallback.TextColor3 = Color3.fromRGB(255, 255, 255)
				iconFallback.Visible = false
				iconFallback.Parent = row1

				local fallbackCorner = Instance.new("UICorner")
				fallbackCorner.CornerRadius = UDim.new(0, 6)
				fallbackCorner.Parent = iconFallback

				local versionLabel = Instance.new("TextLabel")
					versionLabel.Name = "Version"
					versionLabel.Size = UDim2.new(0, 40, 0, 28)
					versionLabel.BackgroundTransparency = 1
					versionLabel.Font = Enum.Font.GothamBold
					versionLabel.TextSize = 15
					versionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					versionLabel.TextStrokeTransparency = 0.35
					versionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					versionLabel.TextXAlignment = Enum.TextXAlignment.Left
					versionLabel.Parent = row1
				local cdLabel = Instance.new("TextLabel")
					cdLabel.Name = "Cooldown"
					cdLabel.Size = UDim2.new(1, 0, 0, 16)
					cdLabel.BackgroundTransparency = 1
					cdLabel.Font = Enum.Font.GothamBold
					cdLabel.TextSize = 13
					cdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					cdLabel.TextStrokeTransparency = 0.35
					cdLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					cdLabel.TextXAlignment = Enum.TextXAlignment.Center
					cdLabel.Visible = false
					cdLabel.Parent = billboard

					local durLabel = Instance.new("TextLabel")
					durLabel.Name = "Duration"
					durLabel.Size = UDim2.new(1, 0, 0, 16)
					durLabel.BackgroundTransparency = 1
					durLabel.Font = Enum.Font.GothamBold
					durLabel.TextSize = 13
					durLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					durLabel.TextStrokeTransparency = 0.35
					durLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					durLabel.TextXAlignment = Enum.TextXAlignment.Center
					durLabel.Visible = false
					durLabel.Parent = billboard

					HyperionPort.AbilityESPBillboards[OtherPlayer] = billboard
				end

				local nameLabel = billboard:FindFirstChild("PlayerName")
				local icon = billboard:FindFirstChild("Row1") and billboard:FindFirstChild("Row1"):FindFirstChild("Icon")
				local iconFallback = billboard:FindFirstChild("Row1") and billboard:FindFirstChild("Row1"):FindFirstChild("IconFallback")
				local versionLabel = billboard:FindFirstChild("Row1") and billboard:FindFirstChild("Row1"):FindFirstChild("Version")
				local cdLabel = billboard:FindFirstChild("Cooldown")
				local durLabel = billboard:FindFirstChild("Duration")

				if nameLabel then
					nameLabel.Text = OtherPlayer.DisplayName
				end

				if icon and iconFallback and versionLabel and cdLabel and durLabel then
					local attrState = HyperionPort.PlayerAbilityAttributes[OtherPlayer]
					local equippedAbility = OtherPlayer:GetAttribute("EquippedAbility")
					local activeAbility = Character:GetAttribute("Ability")
					local attrAbilityName = attrState and attrState.abilityName
					local abilityName = equippedAbility or activeAbility or attrAbilityName
					local data, matchedKey = FindAbilityData(abilityName)

					if abilityName and abilityName ~= "" and data and matchedKey then
						local imageAsset = GetAbilityImage(data.image, matchedKey)
						if imageAsset then
							icon.Image = imageAsset
							icon.ImageTransparency = 0
							icon.Visible = true
							iconFallback.Visible = false
						else
							icon.Image = ""
							icon.Visible = false
							iconFallback.Text = abilityName:sub(1, 1):upper()
							iconFallback.Visible = true
						end

						local upgradeVal = attrState and attrState.upgrade
						if upgradeVal == nil then
							local upgrades = OtherPlayer.Upgrades
							if type(upgrades) == "table" then
								upgradeVal = upgrades[abilityName]
								if upgradeVal == nil then upgradeVal = upgrades[matchedKey] end
							else
								local upgradesFolder = OtherPlayer:FindFirstChild("Upgrades")
								if upgradesFolder then
									local upgradeChild = upgradesFolder:FindFirstChild(abilityName) or upgradesFolder:FindFirstChild(matchedKey)
									if upgradeChild then
										upgradeVal = upgradeChild.Value
									end
								end
							end
						end
						upgradeVal = (type(upgradeVal) == "number" and upgradeVal >= 0) and upgradeVal or 0
						local versionIndex = math.max(0, upgradeVal) + 1
						local versionKey = "V" .. tostring(versionIndex)

						versionLabel.Text = versionKey
						versionLabel.Visible = true

						local stateFromHook = HyperionPort.PlayerAbilityStates[OtherPlayer]
						local now = os.clock()

						local effectiveActiveEnd = attrState and attrState.activeEnd or stateFromHook and stateFromHook.activeEnd
						local effectiveCdEnd = attrState and attrState.cooldownEnd or stateFromHook and stateFromHook.cdEnd
						local abilityActive = attrState and attrState.abilityActive

						if AutoParry.ActiveTimerEnabled and effectiveActiveEnd then
							local remaining = effectiveActiveEnd - now
							if remaining > 0 then
								durLabel.Text = "Active: " .. string.format("%.1f", remaining) .. "s"
								durLabel.Visible = true
							else
								if attrState then attrState.activeEnd = nil end
								if stateFromHook then stateFromHook.activeEnd = nil end
								if attrState then attrState.abilityActive = false end
								durLabel.Visible = false
							end
						elseif AutoParry.ActiveTimerEnabled and abilityActive then
							durLabel.Text = "Active"
							durLabel.Visible = true
						elseif not AutoParry.ActiveTimerEnabled then
							durLabel.Visible = false
						else
							durLabel.Visible = false
						end

						if AutoParry.CooldownTimerEnabled and effectiveCdEnd then
							local cdRemaining = effectiveCdEnd - now
							if cdRemaining > 0 then
								cdLabel.Text = "CD: " .. string.format("%.1f", cdRemaining) .. "s"
								cdLabel.Visible = true
							else
								if attrState then attrState.cooldownEnd = nil end
								if stateFromHook then stateFromHook.cdEnd = nil end
								cdLabel.Visible = false
							end
						elseif not AutoParry.CooldownTimerEnabled then
							cdLabel.Visible = false
						else
							cdLabel.Visible = false
						end
					else
						icon.Visible = false
						iconFallback.Visible = false
						versionLabel.Text = "?"
						versionLabel.Visible = true
						cdLabel.Visible = false
						durLabel.Visible = false
					end

				end
		elseif billboard then
			billboard:Destroy()
			HyperionPort.AbilityESPBillboards[OtherPlayer] = nil
		end
	end
end
end

function FetchDevUsernames()
	local success, data = pcall(game.HttpGet, game, DEV_USERS_URL)
	if success and type(data) == "string" and data ~= "" then
		local list = {}
		for line in data:gmatch("[^\r\n]+") do
			local trimmed = line:match("^%s*(.-)%s*$")
			if trimmed ~= "" then
				table.insert(list, trimmed)
			end
		end
		HyperionPort.DevUsernames = list
	end
	HyperionPort.DevDataLastFetch = os.clock()
end

function HyperionPort.SetAbilityESP(value)
	AutoParry.AbilityESPEnabled = value == true
	HyperionPort.AbilityESPLoopToken = (HyperionPort.AbilityESPLoopToken or 0) + 1

	if HyperionPort.AbilityESPConnection then
		HyperionPort.AbilityESPConnection:Disconnect()
		HyperionPort.AbilityESPConnection = nil
	end

	HyperionPort.ClearAbilityESP()

	if AutoParry.AbilityESPEnabled then
		InitAbilityRemoteHooks()

		FetchDevUsernames()
		local v387 = HyperionPort.AbilityESPLoopToken
		task.spawn(function()
			while AutoParry.AbilityESPEnabled and HyperionPort.AbilityESPLoopToken == v387 do
				HyperionPort.UpdateAbilityESP()
				if os.clock() - HyperionPort.DevDataLastFetch >= 30 then
					FetchDevUsernames()
				end
				task.wait()
			end
		end)
	end
end

function HyperionPort.DestroyInfoPanel()
	if HyperionPort.BallVelocityGui then
		HyperionPort.BallVelocityGui:Destroy()
		HyperionPort.BallVelocityGui = nil
	end
end

function HyperionPort.SaveInfoPanelPosition()
	local panel = HyperionPort.BallVelocityGui and HyperionPort.BallVelocityGui:FindFirstChild("Panel")
	if panel then
		AutoParry.InfoPanelPosition = {
			XOffset = panel.Position.X.Offset,
			YOffset = panel.Position.Y.Offset
		}
		MarkConfigDirty()
	end
end

function HyperionPort.CreateInfoPanel()
	HyperionPort.DestroyInfoPanel()

	local pos = AutoParry.InfoPanelPosition or {XOffset = 12, YOffset = 12}
	local lineH = 20

	local v41 = Instance.new("ScreenGui")
	v41.Name = "HyperionInfoPanel"
	v41.ResetOnSpawn = false
	v41.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	v41.Parent = PlayerGui

	local Frame = Instance.new("Frame")
	Frame.Name = "Panel"
	Frame.Position = UDim2.fromOffset(pos.XOffset or 12, pos.YOffset or 12)
	Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
	Frame.BackgroundTransparency = 0.15
	Frame.BorderSizePixel = 0
	Frame.Active = true
	Frame.Selectable = true
	Frame.Parent = v41

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = Frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 45, 55)
	stroke.Transparency = 0.3
	stroke.Thickness = 1
	stroke.Parent = Frame

	local dragStart, dragPos
	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragStart = input.Position
			dragPos = Frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragStart = nil
					HyperionPort.SaveInfoPanelPosition()
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragStart then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			Frame.Position = UDim2.new(
				dragPos.X.Scale,
				dragPos.X.Offset + delta.X,
				dragPos.Y.Scale,
				dragPos.Y.Offset + delta.Y
			)
		end
	end)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(8, 5)
	title.Size = UDim2.new(1, -16, 0, 16)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 12
	title.TextColor3 = Color3.fromRGB(255, 45, 55)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Information"
	title.Parent = Frame

	local yOff = 25

	local speedLabel = Instance.new("TextLabel")
	speedLabel.Name = "BallSpeed"
	speedLabel.BackgroundTransparency = 1
	speedLabel.Position = UDim2.fromOffset(8, yOff)
	speedLabel.Size = UDim2.new(1, -16, 0, lineH)
	speedLabel.Font = Enum.Font.Gotham
	speedLabel.TextSize = 12
	speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedLabel.TextXAlignment = Enum.TextXAlignment.Left
	speedLabel.Text = "Speed: 0"
	speedLabel.Visible = AutoParry.ShowBallSpeed
	speedLabel.Parent = Frame
	yOff += lineH

	local fpsLabel = Instance.new("TextLabel")
	fpsLabel.Name = "FPS"
	fpsLabel.BackgroundTransparency = 1
	fpsLabel.Position = UDim2.fromOffset(8, yOff)
	fpsLabel.Size = UDim2.new(1, -16, 0, lineH)
	fpsLabel.Font = Enum.Font.Gotham
	fpsLabel.TextSize = 12
	fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
	fpsLabel.Text = "FPS: 0"
	fpsLabel.Visible = AutoParry.ShowFPSInInfo
	fpsLabel.Parent = Frame
	yOff += lineH

	local pingLabel = Instance.new("TextLabel")
	pingLabel.Name = "Real Ping"
	pingLabel.BackgroundTransparency = 1
	pingLabel.Position = UDim2.fromOffset(8, yOff)
	pingLabel.Size = UDim2.new(1, -16, 0, lineH)
	pingLabel.Font = Enum.Font.Gotham
	pingLabel.TextSize = 12
	pingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	pingLabel.TextXAlignment = Enum.TextXAlignment.Left
	pingLabel.Text = "Real Ping: 0ms"
	pingLabel.Visible = AutoParry.ShowPingInInfo
	pingLabel.Parent = Frame

	local lines = 1
	if AutoParry.ShowBallSpeed then lines = lines + 1 end
	if AutoParry.ShowFPSInInfo then lines = lines + 1 end
	if AutoParry.ShowPingInInfo then lines = lines + 1 end
	Frame.Size = UDim2.fromOffset(200, 6 + lines * lineH)
	title.Visible = true

	HyperionPort.BallVelocityGui = v41
end

function HyperionPort.UpdateInfoPanel()
	if not HyperionPort.BallVelocityGui then return end

	local Frame = HyperionPort.BallVelocityGui:FindFirstChild("Panel")
	if not Frame then return end

	local speedLabel = Frame:FindFirstChild("BallSpeed")
	local fpsLabel = Frame:FindFirstChild("FPS")
	local pingLabel = Frame:FindFirstChild("Real Ping")

	if speedLabel then



		local TargetBall = FindTargetedBall()
		local Ball
		if TargetBall then
			Ball = TargetBall
		else
			local balls = Main.ball.get_all()
			Ball = balls and balls[1]
		end

		if Ball then
			if Ball ~= HyperionPort.BallVelocityLastBall then
				local oldBall = HyperionPort.BallVelocityLastBall
				if oldBall and _ballTrackerData[oldBall] and _ballTrackerData[oldBall].hasEverHadVelocity then
					local oldData = _ballTrackerData[oldBall]
					_ballTrackerData[Ball] = {
						lastValid = oldData.lastValid,
						zeroCount = 0,
						hasEverHadVelocity = true,
					}
					_ballTrackerData[oldBall] = nil
				end
				HyperionPort.BallVelocityLastBall = Ball
				HyperionPort.BallVelocityPeak = 0
			end
			local velocity = GetSmoothedBallVelocity(Ball) or Vector3.zero
			local mag = velocity.Magnitude
			HyperionPort.BallVelocityPeak = math.max(HyperionPort.BallVelocityPeak or 0, mag)
			speedLabel.Text = string.format("Speed: %.1f | Peak: %.1f", mag, HyperionPort.BallVelocityPeak)
		else
			speedLabel.Text = "Speed: 0"
			HyperionPort.BallVelocityLastBall = nil
		end
	end

	if fpsLabel then
		fpsLabel.Text = "FPS: " .. tostring(RuntimeState.Fps or 0)
	end

	if pingLabel then
		pingLabel.Text = "Ping: " .. tostring(GetPing()) .. "ms"
	end
end

UnstableConnectionGui = nil
function HyperionPort.UpdateUnstableConnection()
	local ping = GetPing()
	if ping > 140 then
		if not UnstableConnectionGui then
			local gui = Instance.new("ScreenGui")
			gui.Name = "HyperionUnstableConnection"
			gui.ResetOnSpawn = false
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.Parent = PlayerGui

			local label = Instance.new("TextLabel")
			label.Name = "Warning"
			label.Size = UDim2.fromOffset(240, 30)
			label.Position = UDim2.new(0.5, -120, 0, 8)
			label.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
			label.BorderColor3 = Color3.fromRGB(255, 45, 55)
			label.TextColor3 = Color3.fromRGB(255, 45, 55)
			label.Font = Enum.Font.GothamBold
			label.TextSize = 14
			label.Text = "[!] Unstable Connection."
			label.Parent = gui

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = label

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(255, 45, 55)
			stroke.Thickness = 1
			stroke.Parent = label

			UnstableConnectionGui = gui
		end

		local t = AutoParry.UITransparency or 0
		local label = UnstableConnectionGui.Warning
		if label then
			label.BackgroundTransparency = 0.12 + t * 0.88
			label.TextTransparency = t
			local stroke = label:FindFirstChild("UIStroke")
			if stroke then
				stroke.Transparency = 0.5 + t * 0.5
			end
		end
	elseif UnstableConnectionGui then
		UnstableConnectionGui:Destroy()
		UnstableConnectionGui = nil
	end
end

function HyperionPort.SetInfoPanel(value)
	local enabled = value == true and (AutoParry.ShowBallSpeed or AutoParry.ShowFPSInInfo or AutoParry.ShowPingInInfo)

	if HyperionPort.InfoPanelConnection then
		HyperionPort.InfoPanelConnection:Disconnect()
		HyperionPort.InfoPanelConnection = nil
	end

	HyperionPort.DestroyInfoPanel()
	HyperionPort.BallVelocityPeak = 0
	HyperionPort.BallVelocityLastBall = nil

	if enabled then
		HyperionPort.CreateInfoPanel()
		HyperionPort.InfoPanelConnection = RunService.RenderStepped:Connect(function()
			HyperionPort.UpdateInfoPanel()
		end)
	end
end

function HyperionPort.DisconnectNoRenderConnections()
	local NoRenderConnectionNames = {
		"NoRenderConnection",
		"NoRenderWorkspaceConnection",
		"NoRenderLightingConnection",
		"NoRenderPlayerScriptsConnection",
		"NoRenderLoopConnection"
	}

	for Index, RemoteMethod in ipairs(NoRenderConnectionNames) do
		local v88 = HyperionPort[RemoteMethod] or RuntimeState[RemoteMethod]
		if v88 then
			v88:Disconnect()
			HyperionPort[RemoteMethod] = nil
			RuntimeState[RemoteMethod] = nil
		end
	end
end

function HyperionPort.StoreNoRenderObject(NoRenderInstance)
	RuntimeState.NoRenderOriginalObjects = RuntimeState.NoRenderOriginalObjects or {}
	if RuntimeState.NoRenderOriginalObjects[NoRenderInstance] then
		return RuntimeState.NoRenderOriginalObjects[NoRenderInstance]
	end

	local ConfigTable = {}
	local function StoreNoRenderProperty(PropName)
		pcall(function()
			local value = NoRenderInstance[PropName]
			if value ~= nil then
				ConfigTable[PropName] = value
			end
		end)
	end

	StoreNoRenderProperty("Enabled")
	StoreNoRenderProperty("Disabled")

	if next(ConfigTable) then
		RuntimeState.NoRenderOriginalObjects[NoRenderInstance] = ConfigTable
		return ConfigTable
	end

	return nil
end

function HyperionPort.IsNoRenderBallObject(NoRenderInstance)
	local DetectionRemote = NoRenderInstance

	while DetectionRemote and DetectionRemote ~= workspace do
		if DetectionRemote.Name == "Balls" or DetectionRemote.Name == "TrainingBalls" then
			return true
		end

		if IsBallInstance(DetectionRemote) then
			return true
		end

		DetectionRemote = DetectionRemote.Parent
	end

	return false
end

function HyperionPort.IsNoRenderPlayerObject(NoRenderInstance)
	local current = NoRenderInstance
	while current and current ~= workspace do
		if current:IsA("Model") and Players:GetPlayerFromCharacter(current) then
			return true
		end
		current = current.Parent
	end
	return false
end

function HyperionPort.ApplyNoRenderObject(NoRenderInstance)
	if not NoRenderInstance or not NoRenderInstance.Parent then
		return
	end

	if NoRenderInstance == RuntimeState.NoRenderEffect then
		return
	end

	if HyperionPort.IsNoRenderBallObject(NoRenderInstance) then
		return
	end

	if HyperionPort.IsNoRenderPlayerObject(NoRenderInstance) then
		return
	end

	local ClassName = NoRenderInstance.ClassName
	local IsEffectObject = ClassName == "ParticleEmitter"
		or ClassName == "Trail"
		or ClassName == "Beam"
		or ClassName == "Fire"
		or ClassName == "Smoke"
		or ClassName == "Sparkles"
		or ClassName == "Highlight"
		or ClassName == "SurfaceAppearance"
		or NoRenderInstance:IsA("PostEffect")

	if IsEffectObject then
		HyperionPort.StoreNoRenderObject(NoRenderInstance)
		pcall(function()
			NoRenderInstance.Enabled = false
		end)
	end

	if ClassName == "MeshPart" then
		HyperionPort.StoreNoRenderObject(NoRenderInstance)
		pcall(function()
			NoRenderInstance.TextureID = ""
			NoRenderInstance.Material = Enum.Material.SmoothPlastic
		end)
	end

	if ClassName == "Part" or ClassName == "UnionOperation" then
		if not NoRenderInstance:IsA("BasePart") then return end
		local isDecorative = not NoRenderInstance.Anchored
			and NoRenderInstance.Name ~= "Handle"
			and NoRenderInstance.Parent and NoRenderInstance.Parent:IsA("Tool") == false
		if isDecorative then
			pcall(function()
				NoRenderInstance.Material = Enum.Material.SmoothPlastic
			end)
		end
	end

	if NoRenderInstance:IsA("LocalScript") then
		local LowerName = string.lower(NoRenderInstance.Name)
		local LowerParentName = NoRenderInstance.Parent and string.lower(NoRenderInstance.Parent.Name) or ""
		if LowerName:find("fx", 1, true)
			or LowerName:find("effect", 1, true)
			or LowerName:find("vfx", 1, true)
			or LowerParentName:find("effectscripts", 1, true) then
			HyperionPort.StoreNoRenderObject(NoRenderInstance)
			pcall(function()
				NoRenderInstance.Disabled = true
			end)
		end
	end

	if ClassName == "Decal" or ClassName == "Texture" then
		HyperionPort.StoreNoRenderObject(NoRenderInstance)
		pcall(function()
			NoRenderInstance.Transparency = 1
		end)
	end
end

function HyperionPort.QueueNoRenderObject(NoRenderInstance)
	if not NoRenderInstance or RuntimeState.NoRenderQueued[NoRenderInstance] then
		return
	end

	RuntimeState.NoRenderQueued[NoRenderInstance] = true
	table.insert(RuntimeState.NoRenderQueue, NoRenderInstance)
end

function HyperionPort.QueueNoRenderDescendants(root)
	if not root then
		return
	end

	HyperionPort.QueueNoRenderObject(root)

	for Index, NoRenderInstance in ipairs(root:GetDescendants()) do
		HyperionPort.QueueNoRenderObject(NoRenderInstance)
	end
end

function HyperionPort.ProcessNoRenderQueue()
	if not AutoParry.NoRenderEnabled then
		return
	end

	local CurrentTime = os.clock()
	if CurrentTime - RuntimeState.NoRenderLastQueueStep < 0.25 then
		return
	end

	RuntimeState.NoRenderLastQueueStep = CurrentTime

	for Index = 1, 8 do
		local NoRenderInstance = table.remove(RuntimeState.NoRenderQueue, 1)
		if not NoRenderInstance then
			break
		end

		RuntimeState.NoRenderQueued[NoRenderInstance] = nil
		HyperionPort.ApplyNoRenderObject(NoRenderInstance)
	end
end

function HyperionPort.ApplyNoRenderUserGraphics()
	if not RuntimeState.NoRenderOriginalGraphicsSettings then
		RuntimeState.NoRenderOriginalGraphicsSettings = {}

		pcall(function()
			local UserGameSettings = UserSettings():GetService("UserGameSettings")
			RuntimeState.NoRenderOriginalGraphicsSettings.SavedQualityLevel = UserGameSettings.SavedQualityLevel
		end)

		pcall(function()
			RuntimeState.NoRenderOriginalGraphicsSettings.RenderingQualityLevel = settings().Rendering.QualityLevel
		end)
	end

	pcall(function()
		UserGameSettings = UserSettings():GetService("UserGameSettings")
		UserGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
	end)

	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end)
end

function HyperionPort.ApplyNoRenderLowGraphics()
	HyperionPort.ApplyNoRenderUserGraphics()

	if not RuntimeState.NoRenderOriginalLighting then
		RuntimeState.NoRenderOriginalLighting = {
			Brightness = Lighting.Brightness,
			ClockTime = Lighting.ClockTime,
			GlobalShadows = Lighting.GlobalShadows,
			FogEnd = Lighting.FogEnd,
			FogStart = Lighting.FogStart,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient
		}

		pcall(function()
			RuntimeState.NoRenderOriginalLighting.ExposureCompensation = Lighting.ExposureCompensation
		end)
		pcall(function()
			RuntimeState.NoRenderOriginalLighting.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
		end)
		pcall(function()
			RuntimeState.NoRenderOriginalLighting.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
		end)
		pcall(function()
			RuntimeState.NoRenderOriginalLighting.ShadowSoftness = Lighting.ShadowSoftness
		end)
		pcall(function()
			RuntimeState.NoRenderOriginalLighting.Technology = Lighting.Technology
		end)
	end

	Lighting.Brightness = 1.5
	Lighting.ClockTime = 14
	Lighting.GlobalShadows = false
	Lighting.FogStart = 0
	Lighting.FogEnd = 100000
	Lighting.Ambient = Color3.fromRGB(120, 120, 120)
	Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120)
	pcall(function()
		Lighting.ExposureCompensation = 0
	end)
	pcall(function()
		Lighting.EnvironmentDiffuseScale = 0
	end)
	pcall(function()
		Lighting.EnvironmentSpecularScale = 0
	end)
	pcall(function()
		Lighting.ShadowSoftness = 0
	end)
	pcall(function()
		Lighting.Technology = Enum.Technology.Compatibility
	end)

	Terrain = workspace:FindFirstChildOfClass("Terrain")
	if Terrain then
		if not RuntimeState.NoRenderOriginalTerrain then
			RuntimeState.NoRenderOriginalTerrain = {
				WaterWaveSize = Terrain.WaterWaveSize,
				WaterWaveSpeed = Terrain.WaterWaveSpeed,
				WaterReflectance = Terrain.WaterReflectance,
				WaterTransparency = Terrain.WaterTransparency
			}

			pcall(function()
				RuntimeState.NoRenderOriginalTerrain.Decoration = Terrain.Decoration
			end)
		end

		Terrain.WaterWaveSize = 0
		Terrain.WaterWaveSpeed = 0
		Terrain.WaterReflectance = 0
		Terrain.WaterTransparency = 1
		pcall(function()
			Terrain.Decoration = false
			Terrain.Collision = false
		end)
	end

	Lighting.ShadowSoftness = 0
	pcall(function()
		Lighting.Technology = Enum.Technology.Compatibility
	end)

	if not RuntimeState.NoRenderEffect or not RuntimeState.NoRenderEffect.Parent then
		RuntimeState.NoRenderEffect = Instance.new("ColorCorrectionEffect")
		RuntimeState.NoRenderEffect.Name = "HyperionNoRenderUgly"
		RuntimeState.NoRenderEffect.Parent = Lighting
	end

	RuntimeState.NoRenderEffect.Enabled = true
	RuntimeState.NoRenderEffect.Brightness = 0
	RuntimeState.NoRenderEffect.Contrast = -0.25
	RuntimeState.NoRenderEffect.Saturation = -0.75
	RuntimeState.NoRenderEffect.TintColor = Color3.fromRGB(255, 255, 255)
end

function HyperionPort.ApplyNoRenderPass()
	HyperionPort.ApplyNoRenderLowGraphics()
end

function HyperionPort.RestoreNoRenderObjects()
	for NoRenderInstance, ConfigTable in pairs(RuntimeState.NoRenderOriginalObjects or {}) do
		if NoRenderInstance then
			if ConfigTable.Parent ~= nil and NoRenderInstance.Parent == nil then
				pcall(function()
					NoRenderInstance.Parent = ConfigTable.Parent
				end)
			end

			if ConfigTable.Enabled ~= nil then
				pcall(function()
					NoRenderInstance.Enabled = ConfigTable.Enabled
				end)
			end

			if ConfigTable.Disabled ~= nil then
				pcall(function()
					NoRenderInstance.Disabled = ConfigTable.Disabled
				end)
			end

		end
	end

	RuntimeState.NoRenderOriginalObjects = {}
end

function HyperionPort.SetNoRender(value)
	AutoParry.NoRenderEnabled = value == true
	HyperionPort.DisconnectNoRenderConnections()

	if AutoParry.NoRenderEnabled then
		HyperionPort.ApplyNoRenderPass()

		RuntimeState.NoRenderWorkspaceConnection = workspace.DescendantAdded:Connect(function(NoRenderInstance)
			HyperionPort.QueueNoRenderObject(NoRenderInstance)
		end)

		RuntimeState.NoRenderLightingConnection = Lighting.DescendantAdded:Connect(function(NoRenderInstance)
			HyperionPort.QueueNoRenderObject(NoRenderInstance)
		end)

		PlayerScripts = Player:FindFirstChild("PlayerScripts")
		if PlayerScripts then
			RuntimeState.NoRenderPlayerScriptsConnection = PlayerScripts.DescendantAdded:Connect(function(NoRenderInstance)
				HyperionPort.QueueNoRenderObject(NoRenderInstance)
			end)
		end

		RuntimeState.NoRenderLoopConnection = RunService.Heartbeat:Connect(function()
			HyperionPort.ProcessNoRenderQueue()
		end)

	else
		RuntimeState.NoRenderQueue = {}
		RuntimeState.NoRenderQueued = {}

		if RuntimeState.NoRenderEffect then
			RuntimeState.NoRenderEffect:Destroy()
			RuntimeState.NoRenderEffect = nil
		end

		HyperionPort.RestoreNoRenderObjects()

		if RuntimeState.NoRenderOriginalLighting then
			Lighting.Brightness = RuntimeState.NoRenderOriginalLighting.Brightness
			Lighting.ClockTime = RuntimeState.NoRenderOriginalLighting.ClockTime
			Lighting.GlobalShadows = RuntimeState.NoRenderOriginalLighting.GlobalShadows
			Lighting.FogEnd = RuntimeState.NoRenderOriginalLighting.FogEnd
			Lighting.FogStart = RuntimeState.NoRenderOriginalLighting.FogStart
			Lighting.Ambient = RuntimeState.NoRenderOriginalLighting.Ambient
			Lighting.OutdoorAmbient = RuntimeState.NoRenderOriginalLighting.OutdoorAmbient
			pcall(function()
				Lighting.ExposureCompensation = RuntimeState.NoRenderOriginalLighting.ExposureCompensation
			end)
			pcall(function()
				Lighting.EnvironmentDiffuseScale = RuntimeState.NoRenderOriginalLighting.EnvironmentDiffuseScale
			end)
			pcall(function()
				Lighting.EnvironmentSpecularScale = RuntimeState.NoRenderOriginalLighting.EnvironmentSpecularScale
			end)
			pcall(function()
				Lighting.ShadowSoftness = RuntimeState.NoRenderOriginalLighting.ShadowSoftness
			end)
			pcall(function()
				Lighting.Technology = RuntimeState.NoRenderOriginalLighting.Technology
			end)
			RuntimeState.NoRenderOriginalLighting = nil
		end

		Terrain = workspace:FindFirstChildOfClass("Terrain")
		if Terrain and RuntimeState.NoRenderOriginalTerrain then
			Terrain.WaterWaveSize = RuntimeState.NoRenderOriginalTerrain.WaterWaveSize
			Terrain.WaterWaveSpeed = RuntimeState.NoRenderOriginalTerrain.WaterWaveSpeed
			Terrain.WaterReflectance = RuntimeState.NoRenderOriginalTerrain.WaterReflectance
			Terrain.WaterTransparency = RuntimeState.NoRenderOriginalTerrain.WaterTransparency
			pcall(function()
				Terrain.Decoration = RuntimeState.NoRenderOriginalTerrain.Decoration
			end)
			RuntimeState.NoRenderOriginalTerrain = nil
		end

		if RuntimeState.NoRenderOriginalGraphicsSettings then
			pcall(function()
				local UserGameSettings = UserSettings():GetService("UserGameSettings")
				UserGameSettings.SavedQualityLevel = RuntimeState.NoRenderOriginalGraphicsSettings.SavedQualityLevel
			end)

			pcall(function()
				settings().Rendering.QualityLevel = RuntimeState.NoRenderOriginalGraphicsSettings.RenderingQualityLevel
			end)

			RuntimeState.NoRenderOriginalGraphicsSettings = nil
		end
	end
end

SkinChanger = {
	SwordInstances = nil,
	SwordsController = nil,
	ParrySuccessFunction = nil,
	ParrySuccessHooked = false
}

function GetSkinName()
	return tostring(AutoParry.SkinName or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function FetchSwordList()
	local RawContent = HttpGetContent(SWORD_LIST_URL)
	local SwordList = {}
	local Seen = {}
	RawContent = tostring(RawContent or ""):gsub("local%s+[%w_]+%s*=", ""):gsub("return", "")

	for SwordMatch in RawContent:gmatch("[^,\r\n]+") do
		local SwordName = tostring(SwordMatch or "")
		SwordName = SwordName:gsub("^[%s,%{%}%[%]\"']+", "")
		SwordName = SwordName:gsub("[%s,%{%}%[%]\"']+$", "")

		if SwordName ~= "" and SwordName ~= Version and not Seen[SwordName] then
			Seen[SwordName] = true
			table.insert(SwordList, SwordName)
		end
	end

	table.sort(SwordList, function(ItemA, ItemB)
		return tostring(ItemA):lower() < tostring(ItemB):lower()
	end)

	if #SwordList == 0 then
		return { "None" }
	end

	return SwordList
end

function EnsureSwordInstances()
	if SkinChanger.SwordInstances then
		return SkinChanger.SwordInstances
	end

	local SharedFolder = ReplicatedStorage:FindFirstChild("Shared")
	local ReplicatedInstances = SharedFolder and SharedFolder:FindFirstChild("ReplicatedInstances")
	local SwordsModule = ReplicatedInstances and ReplicatedInstances:FindFirstChild("Swords")

	if not SwordsModule then
		return nil
	end

	local v2, module = pcall(require, SwordsModule)
	if v2 and module then
		SkinChanger.SwordInstances = module
		return module
	end

	return nil
end

function FindSwordsController()
	if SkinChanger.SwordsController then
		return SkinChanger.SwordsController
	end

	local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	local FireSwordInfoRemote = RemotesFolder and RemotesFolder:FindFirstChild("FireSwordInfo")

	if not FireSwordInfoRemote or not getconnections then
		return nil
	end

	pcall(function()
		for Index, v88 in ipairs(getconnections(FireSwordInfoRemote.OnClientEvent)) do
			if v88.Function and islclosure and islclosure(v88.Function) and getupvalues then
				local Upvalues = getupvalues(v88.Function)
				if #Upvalues == 1 and type(Upvalues[1]) == "table" then
					SkinChanger.SwordsController = Upvalues[1]
					break
				end
			end
		end
	end)

	return SkinChanger.SwordsController
end

SkinChanger.UnlockAllSwordsEnabled = false
SkinChanger.UnlockAllLoopActive = false
SkinChanger.UnlockAllButtonReady = false
SkinChanger.UnlockAllNotified = false
SkinChanger.UnlockAllEquippedName = ""

local function IsRealSwordName(name)
	if type(name) ~= "string" or name == "" then
		return false
	end
	local SwordInstances = EnsureSwordInstances()
	if not SwordInstances then

		return true
	end
	local ok, sword = pcall(function()
		return SwordInstances:GetSword(name)
	end)
	return ok and sword ~= nil
end

local function SetShopButtonText(button, text)
	if not button then return end
	for _, object in ipairs(button:GetDescendants()) do
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			object.Text = text
		end
	end
	if button:IsA("TextButton") then button.Text = text end
end

local function GetShopButtonText(button)
	if not button then return "" end
	if button:IsA("TextButton") then return button.Text end
	for _, object in ipairs(button:GetDescendants()) do
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			return object.Text
		end
	end
	return ""
end

local function GetShopSwordName(shop)
	local name = ""
	pcall(function()
		local holder = shop:FindFirstChild("Holder")
		local info = holder and holder:FindFirstChild("InfoBG")
		local label = info and info:FindFirstChild("Namer")
		if label and label:IsA("TextLabel") then name = label.Text end
	end)
	return name
end

local function IsSwordPageActive(pages, swordPage)
	if not pages or not swordPage then return false end
	if not swordPage.Visible then return false end

	for _, other in ipairs(pages:GetChildren()) do
		if other ~= swordPage and other:IsA("GuiObject") and other.Visible then
			return false
		end
	end
	return true
end

local function CountSwordCards(page)
	local seen = {}
	local count = 0
	for _, child in ipairs(page:GetDescendants()) do
		if child.Name == "Lock" and child:IsA("GuiObject") then
			local card = child.Parent
			if card and card:IsA("GuiObject") and not seen[card] then
				seen[card] = true
				count = count + 1
			end
		elseif child.Name == "HyperionUnlockSwordHook" then
			local card = child.Parent
			if card and card:IsA("GuiObject") and not seen[card] then
				seen[card] = true
				count = count + 1
			end
		end
	end
	return count
end

local function EquipShopSword(shop, button)
	local itemName = GetShopSwordName(shop)
	if itemName == "" or itemName == "Title" then return end
	if not IsRealSwordName(itemName) then return end

	SkinChanger.UnlockAllEquippedName = itemName
	SetShopButtonText(button, "Equipped")

	UnlockAllState.EquippedSword = itemName
	UnlockSaveStore()

	AutoParry.SkinName = itemName
	AutoParry.SkinChangerEnabled = true
	pcall(ApplySkinChanger)
	pcall(MarkConfigDirty)
end

local function EquipShopExplosion(shop, button)
	local itemName = GetShopSwordName(shop)
	if itemName == "" or itemName == "Title" then return end

	SkinChanger.UnlockAllEquippedName = itemName
	SetShopButtonText(button, "Equipped")

	UnlockAllState.EquippedExplosion = itemName
	UnlockSaveStore()

	local character = Player.Character
	local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
	if root then
		UnlockPlayExplosion(itemName, root.Position)
	end
	ShowNotification("Explosion set: " .. itemName .. " (plays on your kills)", 3)
end

local function EquipShopItem(pageKind, shop, button)
	if pageKind == "Explosion" then
		EquipShopExplosion(shop, button)
	else
		EquipShopSword(shop, button)
	end
end

local function GetActiveShopPageKind(pages)
	for _, pageKind in ipairs({ "Sword", "Explosion" }) do
		local page = pages and pages:FindFirstChild(pageKind)
		if page and page:IsA("GuiObject") and page.Visible then
			return pageKind, page
		end
	end
	return nil, nil
end

local function UnlockShopSwords(shop)
	SkinChanger.UnlockAllButtonReady = false
	SkinChanger.UnlockAllNotified = false

	while shop.Parent and SkinChanger.UnlockAllSwordsEnabled do
		local holder = shop:FindFirstChild("Holder")
		local pages = holder and holder:FindFirstChild("Pages")

		if pages then
			for _, pageKind in ipairs({ "Sword", "Explosion" }) do
				local page = pages:FindFirstChild(pageKind)
				if page then
					local header = page:FindFirstChild("HeaderTitle")
					if header then header.Visible = false end

					for _, child in ipairs(page:GetDescendants()) do
						if child.Name == "Lock" and child:IsA("GuiObject") then
							child.Visible = false
							local card = child.Parent
							if card and card:IsA("GuiObject") then
								if card.Parent and card.Parent.Name == "Unowned" then
									local owned = page:FindFirstChild("Owned", true)
									if owned and owned:IsA("GuiObject") then card.Parent = owned end
								end

								if not card:FindFirstChild("HyperionUnlockSwordHook") then
									local tag = Instance.new("BoolValue")
									tag.Name = "HyperionUnlockSwordHook"
									tag.Parent = card
								end
							end
						end
					end
				end
			end

			if not SkinChanger.UnlockAllNotified then
				SkinChanger.UnlockAllNotified = true
				task.spawn(function()
					task.wait(5)
					if not SkinChanger.UnlockAllSwordsEnabled then return end
					ShowNotification("Successfully unlocked all swords", 3)
					SkinChanger.UnlockAllButtonReady = true
				end)
			end

			local info = holder and holder:FindFirstChild("InfoBG")
			local button = info and (info:FindFirstChild("BuyButton") or info:FindFirstChild("EquipButton"))
			if not button and info then
				for _, object in ipairs(info:GetChildren()) do
					if (object:IsA("TextButton") or object:IsA("ImageButton"))
						and not object.Name:lower():find("close", 1, true) then
						button = object
						break
					end
				end
			end

			if button then
				local activeKind = GetActiveShopPageKind(pages)
				local selectedName = GetShopSwordName(shop)
				local validSelection = selectedName ~= "" and selectedName ~= "Title"
					and (activeKind == "Explosion" or IsRealSwordName(selectedName))
				local showButton = SkinChanger.UnlockAllButtonReady
					and activeKind ~= nil
					and validSelection

				if not button:FindFirstChild("HyperionUnlockEquipHook") then
					local tag = Instance.new("BoolValue")
					tag.Name = "HyperionUnlockEquipHook"
					tag.Parent = button
					button.MouseButton1Click:Connect(function()
						if SkinChanger.UnlockAllSwordsEnabled and SkinChanger.UnlockAllButtonReady then
							local kind = GetActiveShopPageKind(pages)
							EquipShopItem(kind, shop, button)
						end
					end)
				end

				if activeKind then
					button.Visible = showButton
				end
				if showButton then
					local equippedName = (activeKind == "Explosion")
						and UnlockAllState.EquippedExplosion
						or SkinChanger.UnlockAllEquippedName
					local desired = (selectedName == equippedName) and "Equipped" or "Equip"
					local current = GetShopButtonText(button)
					if current ~= desired then
						SetShopButtonText(button, desired)
					end
				end
			end
		end

		task.wait(0.15)
	end
	SkinChanger.UnlockAllLoopActive = false
	SkinChanger.UnlockAllButtonReady = false
end

local NetRootCache
local function GetNetRoot()
	if NetRootCache and NetRootCache.Parent then return NetRootCache end
	local pkgs = ReplicatedStorage and ReplicatedStorage:FindFirstChild("Packages")
	local idx = pkgs and pkgs:FindFirstChild("_Index")
	local net = idx and idx:FindFirstChild("sleitnick_net@0.1.0")
	net = net and net:FindFirstChild("net")
	NetRootCache = net
	return net
end

local function FindNetRemote(kind, name)

	local root = GetNetRoot()
	if root then
		local rf = root:FindFirstChild(kind .. "/" .. name)
		if rf then return rf end
	end

	local wanted = (kind == "RF") and "RemoteFunction" or "RemoteEvent"
	local found
	pcall(function()
		for _, inst in ipairs(game:GetDescendants()) do
			if inst:IsA(wanted) and inst.Name == name then
				found = inst
				break
			end
		end
	end)
	return found
end

function HyperionPort.EquipSwordFinisher(name)
	if type(name) ~= "string" or name == "" then return false end
	if not IsRealSwordName(name) then return false end
	if AutoParry.InstantEquipEnabled then
		return HyperionPort.EquipSwordInstant(name)
	end
	pcall(function()
		local equipSword = FindNetRemote("RF", "RequestEquipSword")
		if equipSword then equipSword:InvokeServer(name) end


		local equipFinisher = FindNetRemote("RF", "RequestEquipFinisher")
		if equipFinisher then
			pcall(function() equipFinisher:InvokeServer(name) end)
		end
	end)

	SkinChanger.UnlockAllEquippedName = name
	AutoParry.SkinName = name
	AutoParry.SkinChangerEnabled = true
	pcall(ApplySkinChanger)
	pcall(MarkConfigDirty)
	return true
end

function HyperionPort.SetUnlockAllSwords(value)
	SkinChanger.UnlockAllSwordsEnabled = value == true
	AutoParry.UnlockAllSwordsEnabled = SkinChanger.UnlockAllSwordsEnabled

	if not SkinChanger.UnlockAllSwordsEnabled then
		SkinChanger.UnlockAllButtonReady = false
		SkinChanger.UnlockAllNotified = false
		AutoParry.InstantEquipEnabled = false
		pcall(function()
			local PlayerGui = Player:FindFirstChild("PlayerGui")
			local shop = PlayerGui and PlayerGui:FindFirstChild("Shop")
			local holder = shop and shop:FindFirstChild("Holder")
			local info = holder and holder:FindFirstChild("InfoBG")
			local button = info and (info:FindFirstChild("BuyButton") or info:FindFirstChild("EquipButton"))
			if button and button:FindFirstChild("HyperionUnlockEquipHook") then
				button.Visible = false
			end
		end)
		NotifyToggleState("Unlock All Sword", false)
		return
	end

	AutoParry.InstantEquipEnabled = true

	if SkinChanger.UnlockAllLoopActive then
		NotifyToggleState("Unlock All Sword", true)
		return
	end
	SkinChanger.UnlockAllLoopActive = true

	task.spawn(function()
		local PlayerGui = Player:WaitForChild("PlayerGui")
		local shop = PlayerGui:FindFirstChild("Shop") or PlayerGui:WaitForChild("Shop", 15)
		if shop and SkinChanger.UnlockAllSwordsEnabled then
			UnlockShopSwords(shop)
		else
			SkinChanger.UnlockAllLoopActive = false
		end
	end)

	task.spawn(function()
		GetUnlockSwordNames()
		while SkinChanger.UnlockAllSwordsEnabled do
			pcall(EnsureUnlockInjectedItems)

			if UnlockAllState.EquippedSword ~= "" and AutoParry.SkinName == "" then
				if IsRealSwordName(UnlockAllState.EquippedSword) then
					AutoParry.SkinName = UnlockAllState.EquippedSword
					AutoParry.SkinChangerEnabled = true
					pcall(ApplySkinChanger)
				end
			end

			StartUnlockKillWatcher()

			task.wait(2)
		end
	end)

	NotifyToggleState("Unlock All Sword", true)
end

function HyperionPort.ToggleSwordStyle()
	local remote = FindNetRemote("RE", "RequestChangeAnimationStyle")
	if not remote then return false end
	pcall(function() remote:FireServer() end)
	return true
end

function HyperionPort.EquipSwordInstant(name)
	if type(name) ~= "string" or name == "" then return false end
	if not IsRealSwordName(name) then return false end


	local equipped = false
	pcall(function()
		local equipSword = FindNetRemote("RF", "RequestEquipSword")
		if equipSword then
			equipSword:InvokeServer(name)
			equipped = true
		end
	end)
	pcall(function()
		local character = Player.Character
		if character and character:GetAttribute("CurrentlyEquippedSword") ~= name then
			character:SetAttribute("CurrentlyEquippedSword", name)
		end
	end)
	SkinChanger.UnlockAllEquippedName = name
	AutoParry.SkinName = name
	AutoParry.SkinChangerEnabled = true
	pcall(ApplySkinChanger)
	pcall(MarkConfigDirty)
	return equipped
end

function GetSlashName(SwordName)
	local SwordInstances = EnsureSwordInstances()
	if not SwordInstances or SwordName == "" then
		return "SlashEffect"
	end

	local v2, swordData = pcall(function()
		return SwordInstances:GetSword(SwordName)
	end)

	if v2 and swordData and swordData.SlashName then
		return swordData.SlashName
	end

	return "SlashEffect"
end

function RefreshSwordChangerVFX()
	local SkinName = GetSkinName()
	if SkinName == "" then
		return
	end

	getgenv().skinChangerEnabled = AutoParry.SkinChangerEnabled
	getgenv().changeSwordModel = true
	getgenv().changeSwordAnimation = true
	getgenv().changeSwordFX = true
	getgenv().swordModel = SkinName
	getgenv().swordAnimations = SkinName
	getgenv().swordFX = SkinName
	getgenv().slashName = GetSlashName(SkinName)
end

function ApplySkinChanger()
	local SkinName = GetSkinName()

	RefreshSwordChangerVFX()

	if not AutoParry.SkinChangerEnabled or SkinName == "" then
		return false
	end

	local Character = Player.Character
	if not Character then
		return false
	end

	local SwordInstances = EnsureSwordInstances()
	if SwordInstances and setupvalue and rawget and getupvalues then
		pcall(function()
			local func = rawget(SwordInstances, "EquipSwordTo")
			if func then
				for idx, val in ipairs(getupvalues(func)) do
					if type(val) == "boolean" then
						setupvalue(func, idx, false)
					end
				end
			end
		end)
	end

	if AutoParry.HeadlessEnabled then
		task.defer(function()
			HyperionPort.ApplyHeadlessKorbloxDescription(Player.Character)
		end)
	end

	if getgenv().changeSwordModel and getgenv().swordModel and getgenv().swordModel ~= "" then
		pcall(function()
			SwordInstances:EquipSwordTo(Character, getgenv().swordModel)
		end)
	end

	SwordsController = FindSwordsController()
	if getgenv().changeSwordAnimation and SwordsController and getgenv().swordAnimations and getgenv().swordAnimations ~= "" then
		pcall(function()
			SwordsController:SetSword(getgenv().swordAnimations)
		end)
	end

	return true
end

	function ApplyParryFXColors()
	if not AutoParry.ParryFXColorEnabled then return end
	c = Color3.fromRGB(AutoParry.ParryFXColorR, AutoParry.ParryFXColorG, AutoParry.ParryFXColorB)
	seq = ColorSequence.new(c)
	descendants = workspace:GetDescendants()
	for i = 1, #descendants do
		local obj = descendants[i]
		if CollectionService:HasTag(obj, "ParryFX") and obj:GetAttribute("ParryFXOwner") == Player.Name then
			pcall(function()
				for _, desc in ipairs(obj:GetDescendants()) do
					if desc:IsA("ParticleEmitter") then desc.Color = seq end
					if desc:IsA("Beam") then desc.Color = seq end
					if desc:IsA("Trail") then desc.Color = seq end
					if desc:IsA("BasePart") then desc.Color = c end
					if desc:IsA("SurfaceAppearance") then desc.Color = c end
				end
				if obj:IsA("BasePart") then obj.Color = c end
			end)
		end
	end
end

function ApplySwordColors()
	if not AutoParry.SwordColorEnabled then return end
	char = Player.Character
	if not char then return end
	c = Color3.fromRGB(AutoParry.SwordColorR, AutoParry.SwordColorG, AutoParry.SwordColorB)
	weapons = GetWeaponModels(char)
	for _, weapon in ipairs(weapons) do
		pcall(function()
			for _, desc in ipairs(weapon:GetDescendants()) do
				if desc:IsA("BasePart") then
					desc.Color = c
					if desc:IsA("MeshPart") then desc.TextureID = "" end
				end
				if desc:IsA("Decal") then desc.Color3 = c end
				if desc:IsA("SurfaceAppearance") then desc.Color = c end
			end
		end)
	end
end

SwordColorConnection = nil
function StartColorLoops()
	if SwordColorConnection then
		SwordColorConnection:Disconnect()
		SwordColorConnection = nil
	end
	frame = 0
	SwordColorConnection = RunService.Heartbeat:Connect(function()
		UpdateRainbowColors()
		ApplySwordColors()
		frame = frame + 1
		if frame % 8 == 0 and (AutoParry.ParryFXColorEnabled or AutoParry.ParryFXRainbow) then
			ApplyParryFXColors()
		end
	end)
end
StartColorLoops()

function HookSkinChangerVFX()
	if SkinChanger.ParrySuccessHooked then
		return
	end

	local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	local ParrySuccessRemote = RemotesFolder and RemotesFolder:FindFirstChild("ParrySuccessAll")
	if not ParrySuccessRemote then
		return
	end

	if getconnections and getinfo then
		pcall(function()
			for Index, v88 in ipairs(getconnections(ParrySuccessRemote.OnClientEvent)) do
				if v88.Function then
					SkinChanger.ParrySuccessFunction = v88.Function
					pcall(function()
						v88:Disable()
					end)
					break
				end
			end
		end)
	end

	ParrySuccessRemote.OnClientEvent:Connect(function(...)
		args = {...}
		SkinName = GetSkinName()

		if tostring(args[4]) ~= Player.Name then
			if SkinChanger.ParrySuccessFunction then
				return SkinChanger.ParrySuccessFunction(unpack(args))
			end
			return
		end

		local vfxName = nil
		local vfxSlashName = nil


		if AutoParry.CustomVFXEnabled and AutoParry.CustomVFXName and AutoParry.CustomVFXName ~= "" and AutoParry.CustomVFXName ~= "None" then
			vfxName = AutoParry.CustomVFXName
			vfxSlashName = GetSlashName(AutoParry.CustomVFXName)
		elseif AutoParry.SkinChangerEnabled and getgenv().changeSwordFX and getgenv().swordFX and getgenv().swordFX ~= "" then
			vfxName = getgenv().swordFX
			vfxSlashName = getgenv().slashName
		end

		if vfxName then
			if vfxSlashName then
				args[1] = vfxSlashName
			end
			args[3] = vfxName
		end

		existingFX = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if CollectionService:HasTag(obj, "ParryFX") then
				existingFX[obj] = true
			end
		end

		if SkinChanger.ParrySuccessFunction then
			SkinChanger.ParrySuccessFunction(unpack(args))
		end

		if AutoParry.ParryFXColorEnabled then
			local c = Color3.fromRGB(AutoParry.ParryFXColorR, AutoParry.ParryFXColorG, AutoParry.ParryFXColorB)
			local seq = ColorSequence.new(c)
			for _, obj in ipairs(workspace:GetDescendants()) do
				if CollectionService:HasTag(obj, "ParryFX") and not existingFX[obj] and obj:GetAttribute("ParryFXOwner") == nil then
					obj:SetAttribute("ParryFXOwner", Player.Name)
					pcall(function()
						for _, desc in ipairs(obj:GetDescendants()) do
							if desc:IsA("ParticleEmitter") then desc.Color = seq end
							if desc:IsA("Beam") then desc.Color = seq end
							if desc:IsA("Trail") then desc.Color = seq end
							if desc:IsA("BasePart") then desc.Color = c end
							if desc:IsA("SurfaceAppearance") then desc.Color = c end
						end
						if obj:IsA("BasePart") then obj.Color = c end
					end)
				end
			end
		end
	end)

	SkinChanger.ParrySuccessHooked = true
end

UnlockAllState = {
	EquippedSword = "",
	EquippedExplosion = "",
	InjectedNotified = false
}

local UNLOCK_STORE_FILE = HYPERION_FOLDER .. "/unlockall.json"

local function UnlockLoadStore()
	pcall(function()
		if type(isfile) == "function" and isfile(UNLOCK_STORE_FILE) then
			local data = HttpService:JSONDecode(readfile(UNLOCK_STORE_FILE))
			if type(data) == "table" then
				UnlockAllState.EquippedSword = tostring(data.EquippedSword or "")
				UnlockAllState.EquippedExplosion = tostring(data.EquippedExplosion or "")
			end
		end
	end)
end

function UnlockSaveStore()
	pcall(function()
		if type(makefolder) == "function" then makefolder(HYPERION_FOLDER) end
		if type(writefile) == "function" then
			writefile(UNLOCK_STORE_FILE, HttpService:JSONEncode({
				EquippedSword = UnlockAllState.EquippedSword,
				EquippedExplosion = UnlockAllState.EquippedExplosion
			}))
		end
	end)
end
UnlockLoadStore()

local UnlockShopCtrl = nil
local function GetUnlockShopController()
	if UnlockShopCtrl ~= nil then return UnlockShopCtrl end
	pcall(function()
		UnlockShopCtrl = require(ReplicatedStorage.Controllers.UI.ShopController)
	end)
	return UnlockShopCtrl
end

local UNLOCK_RARITY_ORDER = { Normal = 0, Common = 0, Duo = 1, Rare = 2, Legendary = 3, Limited = 4, LimitedU = 5, Unique = 6, Secret = 7 }

local function UnlockInvertedName(value)
	return (tostring(value or ""):gsub(".", function(c)
		return string.char(255 - string.byte(c))
	end))
end

local unlockSwordNames = nil
local UNLOCK_GUARANTEED = { ["Witch's Curse"] = true, ["Witch's Broom"] = true, ["Witch's Set"] = true }
function GetUnlockSwordNames()
	if unlockSwordNames ~= nil then return unlockSwordNames end
	local list = {}
	for name in pairs(UNLOCK_GUARANTEED) do
		list[name] = true
	end
	pcall(function()
		local content = game:HttpGet(SWORD_LIST_URL, true)
		if type(content) ~= "string" then return end
		content = content:gsub("local%s+[%w_]+%s*=", ""):gsub("return", "")
		for match in content:gmatch("[^,\r\n]+") do
			local n = tostring(match)
				:gsub("^[%s,%{%}%[%]\"']+", "")
				:gsub("[%s,%{%}%[%]\"']+$", "")
			if n ~= "" and #n <= 64 then list[n] = true end
		end
	end)
	unlockSwordNames = list
	return list
end

function EnsureUnlockInjectedItems()
	pcall(function()
		local ctrl = GetUnlockShopController()
		if not (ctrl and ctrl._virtualItems) then return end
		local swordsModule = EnsureSwordInstances()

		for _, itemType in ipairs({ "Sword", "Explosion" }) do
			local pool = ctrl._virtualItems[itemType]
			if type(pool) == "table" then
				local existing = {}
				for _, entry in pairs(pool) do
					if type(entry) == "table" and entry.Name then
						existing[entry.Name] = true
					end
				end

				local candidates = {}
				if itemType == "Sword" then
					candidates = GetUnlockSwordNames()
					pcall(function()
						local _, col = swordsModule:GetCollection()
						if col then
							for n in pairs(col) do candidates[n] = true end
						end
					end)
				else
					pcall(function()
						local inst = ReplicatedStorage.Shared.ReplicatedInstances:FindFirstChild("Explosions")
						local okM, mod = pcall(require, inst)
						if okM and type(mod) == "table" and mod.Collection then
							for n in pairs(mod.Collection) do candidates[n] = true end
						end
					end)
				end

				local donor
				for _, entry in pairs(pool) do
					if type(entry) == "table" and entry.Name then
						donor = entry
						break
					end
				end
				if donor then
					local added = 0
					for name in pairs(candidates) do
						name = tostring(name)
						if not existing[name] then
							local entry = table.clone(donor)
							entry.Type = itemType
							entry.Name = name
							entry.Item = nil
							entry.Data = nil
							local key = '[["Name","' .. name .. '"]]'
							entry.Key = key
							entry.EffectiveKey = key
							entry.RAPKey = key
							entry.InventoryKey = key
							entry.AlphabeticalName = name
							entry.LowerSearchName = name:lower()
							entry.InvertedName = UnlockInvertedName(name)
							entry.InvertedAlphabeticalName = entry.InvertedName
							local rarity
							pcall(function()
								if itemType == "Sword" and swordsModule then
									local sd = swordsModule:GetSword(name)
									rarity = sd and sd.Rarity or nil
								end
							end)
							local order = UNLOCK_RARITY_ORDER[tostring(rarity)] or 0
							if itemType ~= "Sword" and name ~= "Explosion Normal" then
								order += 1
							end
							entry.Rarity = rarity
							entry.RarityOrder = order
							entry.OriginalLayoutOrder = order * 20000 + added
							entry.LayoutOrder = entry.OriginalLayoutOrder
							entry.IsFavorited = false
							entry.Section = "Unowned"
							entry.ForceHide = false
							entry.Hidden = false
							entry.Name_ = tostring(order) .. "|" .. name
							pool[key] = entry
							pool[name] = entry
							added += 1
						end
					end
					if added > 0 then
						pcall(function()
							local handle = ctrl._inventoryPages and ctrl._inventoryPages[itemType]
							if handle and handle.MarkDirty then
								handle:MarkDirty(nil, true, true)
							end
						end)
						if not UnlockAllState.InjectedNotified then
							UnlockAllState.InjectedNotified = true
							ShowNotification("Injected " .. added .. " missing " .. itemType:lower() .. " entries", 3)
						end
					end
				end
			end
		end
	end)
end

do
	local TweenSvc = game:GetService("TweenService")

	local function normalizeExplosionKey(v)
		return tostring(v or ""):lower():gsub("[^%w]", "")
	end

	local function isPlayableTemplate(instance)
		if typeof(instance) ~= "Instance" then return false end
		if instance:IsA("Configuration") or instance:IsA("ModuleScript") or instance:IsA("Script")
			or instance:IsA("LocalScript") or instance:IsA("BindableFunction")
			or instance:IsA("BindableEvent") or instance:IsA("ObjectValue") then
			return false
		end
		return instance:IsA("Folder") or instance:IsA("Model") or instance:IsA("BasePart")
			or instance:IsA("Attachment") or instance:IsA("Accessory") or instance:IsA("Tool")
			or instance:FindFirstChildWhichIsA("BasePart", true) ~= nil
			or instance:FindFirstChildWhichIsA("ParticleEmitter", true) ~= nil
			or instance:FindFirstChildWhichIsA("Beam", true) ~= nil
			or instance:FindFirstChildWhichIsA("Trail", true) ~= nil
	end

	local function firstPlayable(value, depth, seen)
		if value == nil or depth > 4 then return nil end
		if typeof(value) == "Instance" then
			return isPlayableTemplate(value) and value or nil
		end
		if type(value) ~= "table" then return nil end
		seen = seen or {}
		if seen[value] then return nil end
		seen[value] = true
		for _, k in ipairs({ "VFX", "Effect", "Effects", "Instance", "Model", "Folder", "Explosion", "Object", "Template" }) do
			local cand = firstPlayable(value[k], depth + 1, seen)
			if cand then return cand end
		end
		for _, child in pairs(value) do
			local cand = firstPlayable(child, depth + 1, seen)
			if cand then return cand end
		end
		return nil
	end

	function UnlockResolveExplosionTemplate(name)
		if type(name) ~= "string" or name == "" then return nil end
		local wanted = normalizeExplosionKey(name)

		local shared = ReplicatedStorage:FindFirstChild("Shared")
		local ri = shared and shared:FindFirstChild("ReplicatedInstances")
		local instances = ri and ri:FindFirstChild("Explosions")
		if instances then
			local direct = instances:FindFirstChild(name, true)
			if isPlayableTemplate(direct) then return direct end
			local bindable = instances:FindFirstChild("GetInstance")
			if bindable and bindable:IsA("BindableFunction") then
				local okR, result = pcall(function() return bindable:Invoke(name) end)
				local t = okR and firstPlayable(result, 0, {}) or nil
				if t then return t end
			end
			local okM, mod = pcall(require, instances)
			if okM and type(mod) == "table" then
				local t = firstPlayable(mod[name] or mod[wanted], 0, {})
				if t then return t end
				for _, methodName in ipairs({ "GetInstance", "GetExplosion", "GetExplosionVFX", "GetEffect", "Get" }) do
					local method = mod[methodName]
					if type(method) == "function" then
						for _, withSelf in ipairs({ true, false }) do
							local okC, result = pcall(function()
								if withSelf then return method(mod, name) end
								return method(name)
							end)
							t = okC and firstPlayable(result, 0, {}) or nil
							if t then return t end
						end
					end
				end
			end
		end

		local effects = ReplicatedStorage:FindFirstChild("ExplosionEffects")
		if effects then
			local exact = effects:FindFirstChild(name, true)
			if exact and isPlayableTemplate(exact) then return exact end
			for _, child in ipairs(effects:GetDescendants()) do
				if isPlayableTemplate(child) and normalizeExplosionKey(child.Name) == wanted then
					return child
				end
			end
		end
		return nil
	end

	local function parseVecAttr(value)
		if typeof(value) == "Vector3" then return value end
		if type(value) ~= "string" then return nil end
		local nums = {}
		for numText in value:gmatch("[-+]?%d+%.?%d*") do
			nums[#nums + 1] = tonumber(numText)
			if #nums >= 3 then break end
		end
		if #nums >= 3 then return Vector3.new(nums[1], nums[2], nums[3]) end
		return nil
	end

	local function numAttr(object, names)
		for _, name in ipairs(names) do
			local v = tonumber(object:GetAttribute(name))
			if v then return v end
		end
		return nil
	end

	local function delayedTween(object, delayTime, duration, properties)
		if not next(properties) then return end
		task.delay(delayTime or 0, function()
			if object and object.Parent then
				pcall(function()
					TweenSvc:Create(object,
						TweenInfo.new(math.max(duration or 0.05, 0.05), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						properties):Play()
				end)
			end
		end)
	end

	local function activateClone(root)
		local objects = { root }
		for _, object in ipairs(root:GetDescendants()) do
			objects[#objects + 1] = object
		end
		for _, object in ipairs(objects) do
			local emitDelay = tonumber(object:GetAttribute("EmitDelay")) or tonumber(object:GetAttribute("Delay")) or 0
			local duration = tonumber(object:GetAttribute("Duration")) or tonumber(object:GetAttribute("Time")) or 0.35
			pcall(function()
				if object:IsA("BasePart") then
					object.Anchored = true
					object.CanCollide = false
					object.CanTouch = false
					object.CanQuery = false
					local props = {}
					local sizeTarget = parseVecAttr(object:GetAttribute("Size_Target"))
						or parseVecAttr(object:GetAttribute("Size"))
					local transTarget = tonumber(object:GetAttribute("Transparency_Target"))
						or tonumber(object:GetAttribute("Transparency"))
					if sizeTarget then props.Size = sizeTarget end
					if transTarget then props.Transparency = transTarget end
					delayedTween(object, emitDelay, numAttr(object, { "Size_Time", "Transparency_Time", "Time", "Duration" }), props)
				elseif object:IsA("ParticleEmitter") then
					local emitCount = tonumber(object:GetAttribute("EmitCount"))
						or tonumber(object:GetAttribute("ParticleCount"))
						or tonumber(object:GetAttribute("Count"))
					local emitDuration = tonumber(object:GetAttribute("EmitDuration"))
						or tonumber(object:GetAttribute("DisableIn"))
					local rateTarget = tonumber(object:GetAttribute("Rate_Target"))
					task.delay(emitDelay, function()
						if not (object and object.Parent) then return end
						if emitCount and emitCount > 0 then
							pcall(function() object:Emit(emitCount) end)
						else
							pcall(function() object.Enabled = true end)
							if emitDuration and emitDuration > 0 then
								task.delay(emitDuration, function()
									if object and object.Parent then object.Enabled = false end
								end)
							end
						end
						if rateTarget then delayedTween(object, 0, duration, { Rate = rateTarget }) end
					end)
				elseif object:IsA("Beam") then
					task.delay(emitDelay, function()
						if object and object.Parent then object.Enabled = true end
					end)
					local props = {}
					local width0 = tonumber(object:GetAttribute("Width0"))
					local width1 = tonumber(object:GetAttribute("Width1"))
					if width0 then props.Width0 = width0 end
					if width1 then props.Width1 = width1 end
					delayedTween(object, emitDelay, duration, props)
				elseif object:IsA("Trail") then
					task.delay(emitDelay, function()
						if object and object.Parent then object.Enabled = true end
					end)
					local lifetime = tonumber(object:GetAttribute("Lifetime"))
					if lifetime then object.Lifetime = lifetime end
				elseif object:IsA("Light") then
					task.delay(emitDelay, function()
						if object and object.Parent then object.Enabled = true end
					end)
					local props = {}
					local rangeTarget = tonumber(object:GetAttribute("Range_Target"))
					local brightTarget = tonumber(object:GetAttribute("Brightness_Target"))
					if rangeTarget then props.Range = rangeTarget end
					if brightTarget then props.Brightness = brightTarget end
					delayedTween(object, numAttr(object, { "DelayTime", "Delay" }) or emitDelay,
						numAttr(object, { "Range_Time", "Brightness_Time", "Time", "Duration" }), props)
				elseif object:IsA("Sound") then
					task.delay(tonumber(object:GetAttribute("Delay")) or emitDelay, function()
						if object and object.Parent then
							pcall(function() object:Play() end)
							local volumeTarget = tonumber(object:GetAttribute("Volume_Target"))
							if volumeTarget then delayedTween(object, 0, duration, { Volume = volumeTarget }) end
						end
					end)
				end
			end)
		end
	end

	local lastPlayClock = 0

	function UnlockPlayExplosion(name, position)
		local template = UnlockResolveExplosionTemplate(name)
		if not template or typeof(position) ~= "Vector3" then return false end
		local nowClock = os.clock()
		if nowClock - lastPlayClock < 0.25 then return false end
		lastPlayClock = nowClock

		local clone
		local okClone = pcall(function() clone = template:Clone() end)
		if not okClone or not clone then return false end
		clone.Name = "HyperionUnlockExplosion_" .. name

		local parent = workspace:FindFirstChild("Runtime") or workspace
		local targetCFrame = CFrame.new(position)

		if clone:IsA("Attachment") then
			local folder = Instance.new("Folder")
			folder.Name = clone.Name
			folder.Parent = parent
			local anchor = Instance.new("Part")
			anchor.Anchored = true
			anchor.CanCollide = false
			anchor.CanTouch = false
			anchor.CanQuery = false
			anchor.Transparency = 1
			anchor.Size = Vector3.new(1, 1, 1)
			anchor.CFrame = targetCFrame
			anchor.Parent = folder
			clone.Parent = anchor
		elseif clone:IsA("Model") then
			clone.Parent = parent
			pcall(function() clone:PivotTo(targetCFrame) end)
		elseif clone:IsA("BasePart") then
			clone.Anchored = true
			clone.CanCollide = false
			clone.CFrame = targetCFrame
			clone.Parent = parent
		else
			clone.Parent = parent
			local base = clone:FindFirstChildWhichIsA("BasePart", true)
			if base then
				local offset = targetCFrame.Position - base.Position
				for _, part in ipairs(clone:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Anchored = true
						part.CFrame = part.CFrame + offset
					end
				end
			else
				local anchor = Instance.new("Part")
				anchor.Anchored = true
				anchor.CanCollide = false
				anchor.Transparency = 1
				anchor.Size = Vector3.new(1, 1, 1)
				anchor.CFrame = targetCFrame
				anchor.Parent = clone
			end
		end

		activateClone(clone)
		task.delay(8, function()
			if clone and clone.Parent then clone:Destroy() end
		end)
		return true
	end
end

function StartUnlockKillWatcher()
	if UnlockAllState.KillWatcherActive then return end
	UnlockAllState.KillWatcherActive = true
	task.spawn(function()
		local lastKills = nil
		while SkinChanger.UnlockAllSwordsEnabled do
			task.wait(0.35)
			pcall(function()
				local name = UnlockAllState.EquippedExplosion
				if name == "" then return end
				local ls = Player:FindFirstChild("leaderstats")
				local killsValue = ls and (ls:FindFirstChild("Kills") or ls:FindFirstChild("Kill"))
				if not killsValue then return end
				local current = tonumber(killsValue.Value) or 0
				if lastKills ~= nil and current > lastKills then
					local character = Player.Character
					local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
					if root then
						UnlockPlayExplosion(name, root.Position)
					end
				end
				lastKills = current
			end)
		end
		UnlockAllState.KillWatcherActive = false
	end)
end

LastCharacter = nil
LastRefreshAttempt = 0
function UpdateSkinChangerLoop()
	if not AutoParry.SkinChangerEnabled then
		return
	end

	local character = Player.Character
	if not character then
		return
	end

	local SkinName = GetSkinName()
	local CurrentTime = os.clock()

	local needsRefresh = false
	if character ~= LastCharacter then
		LastCharacter = character
		needsRefresh = true
	else
		local hasSword = character:FindFirstChild("Weapon") or character:FindFirstChild(SkinName)
		if SkinName ~= "" and not hasSword then
			if CurrentTime - LastRefreshAttempt >= 2 then
				needsRefresh = true
			end
		elseif CurrentTime - AutoParry.LastSkinRefresh >= 5 then
			needsRefresh = true
		end
	end

	if needsRefresh then
		LastRefreshAttempt = CurrentTime
		AutoParry.LastSkinRefresh = CurrentTime
		RefreshSwordChangerVFX()
		ApplySkinChanger()
	end

	if SkinName ~= "" and character:FindFirstChild(SkinName) then
		for _, v in ipairs(character:GetChildren()) do
			if v:IsA("Model") and v.Name == "Weapon" and SkinName ~= "Weapon" then
				pcall(function() v:Destroy() end)
			end
		end
	end
end

function CreateUI()
	local HyperionWindow = Library:CreateWindow({
		Title = "Hyperion",
		Center = true,
		AutoShow = true,
		TabPadding = 8,
		MenuFadeTime = 0.2
	})
	if not HyperionWindow then
		warn("[Hyperion] CreateWindow returned nil - aborting UI creation")
		return
	end
	RuntimeState.HyperionWindow = HyperionWindow

	local Tabs = {
		Combat = HyperionWindow:AddTab("Combat", TabIcons.Combat),
		Detections = HyperionWindow:AddTab("Detections", TabIcons.Visuals),
		Visuals = HyperionWindow:AddTab("Visuals", TabIcons.Visuals),
		Player = HyperionWindow:AddTab("Player", TabIcons.Visuals),
		Changer = HyperionWindow:AddTab("Changer", TabIcons.Changer),
		Misc = HyperionWindow:AddTab("Misc", TabIcons.Misc),
		GUI = HyperionWindow:AddTab("GUI", TabIcons.GUI)
	}

	local AutoParryGroup = Tabs.Combat:AddLeftGroupbox("Auto Parry")
	local CurveGroup = Tabs.Combat:AddRightGroupbox("Curve")
	local AutoSpamGroup = Tabs.Combat:AddRightGroupbox("Auto Spam Parry")
	local ManualSpamGroup = Tabs.Combat:AddRightGroupbox("Manual Spam")
	local TriggerbotGroup = Tabs.Combat:AddLeftGroupbox("Triggerbot")

	local InfinityDetectionGroup = Tabs.Detections:AddLeftGroupbox("Infinity Detection")
	local SlashesOfFuryGroup = Tabs.Detections:AddRightGroupbox("Slashes Of Fury Detection")
	local DimFrame = Tabs.Detections:AddLeftGroupbox("Time Hole Detection")
	local PanelFrame = Tabs.Detections:AddRightGroupbox("Death Slash Detection")
	local BarBackground = Tabs.Detections:AddLeftGroupbox("Singularity Detection")
	local AerodynamicSlashGroup = Tabs.Detections:AddRightGroupbox("Aerodynamic Slash Detection")

	local AIWalkGroup = Tabs.Player:AddRightGroupbox("Auto Walk")

	local CameraGroup = Tabs.Visuals:AddRightGroupbox("Camera")

	local InformationGroup = Tabs.Visuals:AddLeftGroupbox("Information")
	local AbilityESPGroup = Tabs.Visuals:AddRightGroupbox("Ability ESP")
	local SwordChangerGroup = Tabs.Changer:AddLeftGroupbox("Sword Changer")
	local HeadlessKorbloxGroup = Tabs.Player:AddLeftGroupbox("Characters")
	local AvatarChangerGroup = Tabs.Player:AddLeftGroupbox("Avatar Changer")

	local ExistingLoader = Tabs.Misc:AddLeftGroupbox("Atmosphere")
	local NoLagGroup = Tabs.Misc:AddLeftGroupbox("No Lag")

	local DiscordInfoGroup = Tabs.Misc:AddRightGroupbox("Discord Information")

	if not _pickerSwatchUpdaters then _pickerSwatchUpdaters = {} end

	local function HexFromRGB(r, g, b)
		return string.format("#%02X%02X%02X", math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
	end

	local function RGBFromHex(hex)
		local h = hex:gsub("#", "")
		if #h == 6 then
			local ok, result = pcall(Color3.fromHex, h)
			if ok then
				return math.floor(result.R * 255), math.floor(result.G * 255), math.floor(result.B * 255)
			end
		end
		return nil
	end

	function CreateColorPicker(Groupbox, UnusedParam, Label, RedConfigKey, GreenConfigKey, BlueConfigKey, IsThemePicker, UpdateFunc)
		local function getCurrentColor()
			return Color3.fromRGB(AutoParry[RedConfigKey] or 255, AutoParry[GreenConfigKey] or 255, AutoParry[BlueConfigKey] or 255)
		end

		local function updateSwatch()
			-- Rebuild the settings panel so the swatch reflects the latest color
			pcall(function()
				local ui = HyperionLibrary._default._ui
				if ui and ui.refreshSettingsPanel then ui:refreshSettingsPanel() end
			end)
		end

		local startColor = getCurrentColor()

		Groupbox:AddColorPicker(Label, {
			Default = getCurrentColor(),
			Callback = function(color)
				startColor = color
				AutoParry[RedConfigKey]   = math.floor(color.R * 255 + 0.5)
				AutoParry[GreenConfigKey] = math.floor(color.G * 255 + 0.5)
				AutoParry[BlueConfigKey]  = math.floor(color.B * 255 + 0.5)
				MarkConfigDirty()
				if IsThemePicker then ApplyUITheme() end
				if type(UpdateFunc) == "function" then pcall(UpdateFunc) end
			end
		})

		table.insert(_pickerSwatchUpdaters, updateSwatch)
	end

	function UpdatePickerSwatches()
		for _, updater in ipairs(_pickerSwatchUpdaters) do
			pcall(updater)
		end
	end

	function CreateVisualsGroupbox(side, text)
		if side == "Right" then
			return Tabs.Visuals:AddRightGroupbox(text)
		end
		return Tabs.Visuals:AddLeftGroupbox(text)
	end
	AIWalkGroup:AddToggle("AIWalkToggle", {
		Text = "AI Auto Walk",
		Default = AutoParry.AIWalkEnabled,
		Callback = function(value)
			SetAIWalk(value)
		end
	})

	AIWalkGroup:AddSlider("AIWalkRadiusSlider", {
		Text = "Walk Radius",
		Default = AutoParry.AIWalkRadius,
		Min = 5,
		Max = 250,
		Rounding = 0,
		Callback = function(value)
			AutoParry.AIWalkRadius = math.max(5, SafeToNumber(value, AutoParry.AIWalkRadius))
			ClearWalkTarget()
			MarkConfigDirty()
		end
	})

	AIWalkGroup:AddSlider("AIWalkDelaySlider", {
		Text = "New Position Delay",
		Default = AutoParry.AIWalkDelay,
		Min = 0.2,
		Max = 15,
		Rounding = 1,
		Callback = function(value)
			AutoParry.AIWalkDelay = math.max(0.2, SafeToNumber(value, AutoParry.AIWalkDelay))
			MarkConfigDirty()
		end
	})

	AIWalkGroup:AddSlider("AIWalkReachSlider", {
		Text = "Reach Distance",
		Default = AutoParry.AIWalkReachDistance,
		Min = 1,
		Max = 25,
		Rounding = 1,
		Callback = function(value)
			AutoParry.AIWalkReachDistance = math.max(1, SafeToNumber(value, AutoParry.AIWalkReachDistance))
			MarkConfigDirty()
		end
	})

	AIWalkGroup:AddButton({
		Text = "Pick Random Position",
		Func = function()
			ClearWalkTarget()
			PickNewWalkTarget()
			ShowNotification("AI picked a random walk position")
		end
	})

AIWalkGroup:AddButton({
	Text = "Stop Walking",
	Func = function()
		SetAIWalk(false)
	end
})

-- ===========================================================================
-- Identity Spoofer (Player Tab - Right Container)
-- ===========================================================================

local ID_SpoofState = {
	Enabled = false,
	Username = "",
	DisplayName = "",
	UserId = 0,
}

local ID_RealUsername = LocalPlayer.Name
local ID_RealDisplayname = LocalPlayer.DisplayName
local ID_RealUserId = LocalPlayer.UserId

local ID_RealNames = {
	[ID_RealUsername:lower()] = true,
	[ID_RealDisplayname:lower()] = true,
	["@" .. ID_RealUsername:lower()] = true,
}

local ID_RealNamePatterns = {
	ID_RealUsername:lower(),
	ID_RealDisplayname:lower(),
}

local function ID_isRealName(text)
	if not text or type(text) ~= "string" then return false end
	local lowerText = text:lower()
	if ID_RealNames[lowerText] ~= nil then return true end
	for _, pattern in ipairs(ID_RealNamePatterns) do
		if lowerText:find(pattern, 1, true) then return true end
	end
	return false
end

local function ID_isRealAvatar(image)
	if not image or type(image) ~= "string" then return false end
	return image:find("rbxthumb://") and image:find("id=" .. tostring(ID_RealUserId))
end

-- Layer 1: __index hook
local ID_originalPlayerIndex
do
	local __guard = false
	local ID_hookFn
	ID_hookFn = newcclosure(function(self, key)
		if __guard then
			if ID_originalPlayerIndex and ID_originalPlayerIndex ~= ID_hookFn then
				return ID_originalPlayerIndex(self, key)
			end
			return nil
		end
		__guard = true
		local result
		if not ID_SpoofState.Enabled then
			result = (ID_originalPlayerIndex and ID_originalPlayerIndex ~= ID_hookFn) and ID_originalPlayerIndex(self, key) or nil
		elseif key == "Name" then result = ID_SpoofState.Username
		elseif key == "DisplayName" then result = ID_SpoofState.DisplayName
		elseif key == "UserId" then result = ID_RealUserId
		else
			result = (ID_originalPlayerIndex and ID_originalPlayerIndex ~= ID_hookFn) and ID_originalPlayerIndex(self, key) or nil
		end
		__guard = false
		return result
	end)
	ID_originalPlayerIndex = hookmetamethod(LocalPlayer, "__index", ID_hookFn)
end

-- Layer 2: InspectAndBuy viewport model patch
local ID_targetHD = nil
pcall(function()
	ID_targetHD = Players:GetHumanoidDescriptionFromUserId(ID_SpoofState.UserId)
end)

local function ID_patchViewportModel(model)
	if not model or not model:IsA("Model") then return end
	if not ID_SpoofState.Enabled then return end
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local hd = hum:FindFirstChildOfClass("HumanoidDescription")
	if not hd then return end
	if not ID_targetHD then return end
	pcall(function()
		hd.Shirt = ID_targetHD.Shirt
		hd.Pants = ID_targetHD.Pants
		pcall(function() hd.Graphic = ID_targetHD.Graphic end)
		hd.Face = ID_targetHD.Face
		hd.Head = ID_targetHD.Head
		hd.LeftArm = ID_targetHD.LeftArm
		hd.RightArm = ID_targetHD.RightArm
		hd.LeftLeg = ID_targetHD.LeftLeg
		hd.RightLeg = ID_targetHD.RightLeg
		hd.Torso = ID_targetHD.Torso
		hd.HatAccessory = ID_targetHD.HatAccessory
		hd.HairAccessory = ID_targetHD.HairAccessory
		hd.FaceAccessory = ID_targetHD.FaceAccessory
		hd.NeckAccessory = ID_targetHD.NeckAccessory
		pcall(function() hd.ShoulderAccessory = ID_targetHD.ShoulderAccessory end)
		hd.FrontAccessory = ID_targetHD.FrontAccessory
		hd.BackAccessory = ID_targetHD.BackAccessory
		hd.WaistAccessory = ID_targetHD.WaistAccessory
		hd.ClimbAnimation = ID_targetHD.ClimbAnimation
		hd.FallAnimation = ID_targetHD.FallAnimation
		hd.IdleAnimation = ID_targetHD.IdleAnimation
		hd.JumpAnimation = ID_targetHD.JumpAnimation
		hd.RunAnimation = ID_targetHD.RunAnimation
		hd.SwimAnimation = ID_targetHD.SwimAnimation
		hd.WalkAnimation = ID_targetHD.WalkAnimation
		hd.Emotes = ID_targetHD.Emotes
	end)
end

local function ID_findAndPatchViewport()
	local inspect = nil
	pcall(function()
		local cg = game.CoreGui
		local rg = cg:FindFirstChild("RobloxGui")
		if rg then inspect = rg:FindFirstChild("InspectAndBuy") end
	end)
	local InspectAndBuy = inspect
	if not InspectAndBuy then return end
	local function search(parent, depth)
		if depth > 25 then return end
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") then
				ID_patchViewportModel(child)
			end
			search(child, depth + 1)
		end
	end
	search(InspectAndBuy, 0)
end

pcall(function()
	local cg = game.CoreGui
	cg.DescendantAdded:Connect(function(desc)
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then
			if desc:GetFullName():find("InspectAndBuy") then
				task.defer(function()
					task.wait(0.5)
					ID_patchViewportModel(desc)
				end)
			end
		end
	end)
end)

-- Layer 3: getHeadshotThumbnail hook
pcall(function()
	local module = game.CorePackages.Workspace.Packages._Workspace.PlayerList.PlayerList.Common.getHeadshotThumbnail
	local original = require(module)
	if original and hookfunction then
		hookfunction(original, function(userId)
			if ID_SpoofState.Enabled then
				return ("rbxthumb://type=AvatarHeadShot&id=%*&w=150&h=150"):format(ID_SpoofState.UserId)
			end
			return original(userId)
		end)
	end
end)

-- Layer 4: setPlayerIconInfo hook (leaderboard)
pcall(function()
	local storeModule = game.CorePackages.Workspace.Packages._Workspace.PlayerIconInfoStore.PlayerIconInfoStore
	local store = require(storeModule)
	local original = store.PlayerIconInfoStore.setPlayerIconInfo
	if original and hookfunction then
		hookfunction(original, function(userId, info)
			if info and info.avatarIcon and ID_SpoofState.Enabled then
				info.avatarIcon = ("rbxthumb://type=Avatar&id=%*&w=100&h=100"):format(ID_SpoofState.UserId)
			end
			return original(userId, info)
		end)
	end
end)

-- Layer 5: UserTile hook (Settings avatar)
pcall(function()
	local module = game.CorePackages.Workspace.Packages._Index.UserTile.UserTile.Components.UserTile
	local original = require(module)
	if original and hookfunction then
		hookfunction(original, function(props)
			if props and props.userId == ID_RealUserId and ID_SpoofState.Enabled then
				props.userId = ID_SpoofState.UserId
			end
			return original(props)
		end)
	end
end)

-- Layer 6: resolveDisplayName hook (Profile Panel)
pcall(function()
	local module = game.CorePackages.Workspace.Packages._Workspace.PlayerList.PlayerList.Common.resolveDisplayName
	local original = require(module)
	if original and hookfunction then
		hookfunction(original, function(player)
			local result = original(player)
			if player == LocalPlayer and ID_SpoofState.Enabled then
				return ID_SpoofState.DisplayName
			end
			return result
		end)
	end
end)

-- Layer 7: buildMenuHeader hook (Profile Panel header)
pcall(function()
	local module = game.CorePackages.Workspace.Packages._Workspace.PlayerList.PlayerList.Common.PlayerContextualMenuStore
	local store = require(module)
	local original = store.buildMenuHeader
	if original and hookfunction then
		hookfunction(original, function(player)
			local result = original(player)
			if result and player == LocalPlayer and ID_SpoofState.Enabled then
				result.displayName = ID_SpoofState.DisplayName
				result.username = "@" .. ID_SpoofState.Username
				result.thumbnail = ("rbxthumb://type=AvatarHeadShot&id=%*&w=150&h=150"):format(ID_SpoofState.UserId)
			end
			return result
		end)
	end
end)

-- Layer 8: Text/Image monitoring
local ID_monitoredLabels = {}
local ID_monitoredImages = {}

local function ID_getSpoofedUrl(originalUrl)
	return originalUrl:gsub("id=" .. tostring(ID_RealUserId), "id=" .. tostring(ID_SpoofState.UserId))
end

local function ID_spoofTextLabel(label)
	if not label then return end
	local text = label.Text
	if not text or type(text) ~= "string" then return end
	if ID_isRealName(text) then
		label.Text = ID_SpoofState.DisplayName
	end
end

local function ID_spoofImageLabel(label)
	if not label then return end
	local image = label.Image
	if ID_isRealAvatar(image) then
		label.Image = ID_getSpoofedUrl(image)
	end
end

local function ID_monitorTextLabel(label)
	if not label or ID_monitoredLabels[label] then return end
	ID_monitoredLabels[label] = true
	ID_spoofTextLabel(label)
	label:GetPropertyChangedSignal("Text"):Connect(function()
		ID_spoofTextLabel(label)
	end)
end

local function ID_monitorImageLabel(label)
	if not label or ID_monitoredImages[label] then return end
	ID_monitoredImages[label] = true
	ID_spoofImageLabel(label)
	label:GetPropertyChangedSignal("Image"):Connect(function()
		ID_spoofImageLabel(label)
	end)
end

local function ID_scanAllUI()
	local ok, descs = pcall(function()
		return game.CoreGui:GetDescendants()
	end)
	if not ok or not descs then return end
	for _, desc in ipairs(descs) do
		if desc:IsA("TextLabel") or desc:IsA("TextButton") then
			ID_monitorTextLabel(desc)
		end
		if desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
			ID_monitorImageLabel(desc)
		end
	end
end

pcall(function()
	local ok, cg = pcall(function() return game:GetService("CoreGui") end)
	if not ok or not cg then return end
	cg.DescendantAdded:Connect(function(desc)
		if desc:IsA("TextLabel") or desc:IsA("TextButton") then
			ID_monitorTextLabel(desc)
		end
		if desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
			ID_monitorImageLabel(desc)
		end
	end)
end)

task.defer(function()
	task.wait(0.5)
	ID_scanAllUI()
end)

local ID_loopActive = false
local function ID_startLoop()
	if ID_loopActive then return end
	ID_loopActive = true
	task.spawn(function()
		while ID_loopActive do
			ID_scanAllUI()
			ID_findAndPatchViewport()
			task.wait(0.5)
		end
	end)
end

local function ID_stopLoop()
	ID_loopActive = false
end

-- UI Controls
local IdentitySpooferGroup = Tabs.Player:AddRightGroupbox("Identity Spoofer")

IdentitySpooferGroup:AddToggle("ID_EnabledToggle", {
	Text = "Identity Spoof",
	Default = false,
	Callback = function(value)
		ID_SpoofState.Enabled = value
		if value then
			ID_startLoop()
			pcall(function() ShowNotification("Identity Spoof enabled", 2, { type = "success" }) end)
		else
			ID_stopLoop()
			pcall(function() ShowNotification("Identity Spoof disabled", 2, { type = "info" }) end)
		end
		MarkConfigDirty()
	end
})

IdentitySpooferGroup:AddInput("ID_UsernameInput", {
	Text = "Username",
	Default = Config.SpoofUsername,
	Placeholder = "Enter username...",
	Numeric = false,
	Finished = false,
	Callback = function(value)
		ID_SpoofState.Username = tostring(value or "")
		Config.SpoofUsername = ID_SpoofState.Username
	end
})

IdentitySpooferGroup:AddInput("ID_DisplayNameInput", {
	Text = "Display Name",
	Default = Config.SpoofDisplayName,
	Placeholder = "Enter display name...",
	Numeric = false,
	Finished = false,
	Callback = function(value)
		ID_SpoofState.DisplayName = tostring(value or "")
		Config.SpoofDisplayName = ID_SpoofState.DisplayName
	end
})

IdentitySpooferGroup:AddInput("ID_UserIdInput", {
	Text = "User ID",
	Default = Config.SpoofUserId > 0 and tostring(Config.SpoofUserId) or "",
	Placeholder = "Enter user ID...",
	Numeric = true,
	Finished = true,
	Callback = function(value)
		local id = tonumber(value)
		if id then
			ID_SpoofState.UserId = id
			Config.SpoofUserId = id
			pcall(function()
				ID_targetHD = Players:GetHumanoidDescriptionFromUserId(id)
			end)
		end
	end
})

local RunService = game:GetService("RunService")

local ViewBallPart = nil
local ViewBallConnection = nil
local ViewBallOriginalCameraSubject = nil

function StartViewBall()
	StopViewBall()

	local camera = workspace.CurrentCamera
	if not camera then return end

	ViewBallOriginalCameraSubject = camera.CameraSubject

	local part = Instance.new("Part")
	part.Name = "HyperionViewBall"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Parent = workspace
	ViewBallPart = part

	camera.CameraSubject = part

	ViewBallConnection = RunService.Heartbeat:Connect(function()
		if not ViewBallPart or not ViewBallPart.Parent then
			StopViewBall()
			return
		end
		local ball = FindTargetedBall() or BestCandidate
		if ball then
			ViewBallPart.CFrame = CFrame.new(ball.Position)
		end
	end)
end

function StopViewBall()
	if ViewBallConnection then
		ViewBallConnection:Disconnect()
		ViewBallConnection = nil
	end

	local camera = workspace.CurrentCamera
	if camera and ViewBallOriginalCameraSubject then
		camera.CameraSubject = ViewBallOriginalCameraSubject
	end
	ViewBallOriginalCameraSubject = nil

	if ViewBallPart then
		ViewBallPart:Destroy()
		ViewBallPart = nil
	end
end

CameraGroup:AddToggle("ViewBallToggle", {
	Text = "View Ball",
	Default = AutoParry.ViewBallEnabled,
	Callback = function(value)
		AutoParry.ViewBallEnabled = value == true
		MarkConfigDirty()
		if value == true then
			StartViewBall()
		else
			StopViewBall()
		end
	end
})

CameraGroup:AddToggle("CameraEnabledToggle", {
		Text = "Camera",
		Default = AutoParry.CameraEnabled,
		Callback = function(value)
			AutoParry.CameraEnabled = value == true
			MarkConfigDirty()
		end
	})

	CameraGroup:AddToggle("FOVToggle", {
		Text = "FOV",
		Default = AutoParry.FOVEnabled,
		Callback = function(value)
			HyperionPort.SetFOV(value)
			MarkConfigDirty()
		end
	})

	CameraGroup:AddSlider("CameraFOVSlider", {
		Text = "Camera FOV",
		Default = AutoParry.CameraFOV,
		Min = 70,
		Max = 120,
		Rounding = 0,
		Callback = function(value)
			AutoParry.CameraFOV = math.clamp(SafeToNumber(value, AutoParry.CameraFOV), 50, 120)
			if AutoParry.FOVEnabled and workspace.CurrentCamera then
				workspace.CurrentCamera.FieldOfView = AutoParry.CameraFOV
			end
			MarkConfigDirty()
		end
	})

	AutoParryGroup:AddToggle("AutoToggle", {
		Text = "Auto Parry",
		Default = AutoParry.Enabled,
		Callback = function(value)
			SetAutoParryEnabled(value)
		end
	})

	AutoParryGroup:AddDropdown("ModeDropdown", {
		Text = "Parry Mode",
		Values = { "Remote", "Keypress" },
		Default = AutoParry.Mode,
		Multi = false,
		Callback = function(value)
			SetAutoParryMode(value)
			ResetAllParryFlags()
			MarkConfigDirty()
		end
	})

	AutoParryGroup:AddSlider("ThresholdSlider", {
		Text = "Parry Accuracy",
		Default = AutoParry.Threshold,
		Min = 0.05,
		Max = 1,
		Rounding = 2,
		Callback = function(value)
			local v = tonumber(value)
			if v == nil then v = AutoParry.Threshold end
			AutoParry.Threshold = math.clamp(v, 0.05, 1)
			MarkConfigDirty()
		end
	})

	local AccuracyRangeContainer
	AutoParryGroup:AddToggle("LowSpeedRandomizedToggle", {
		Text = "Randomized Accuracy",
		Default = AutoParry.RandomAccuracyEnabled,
		Callback = function(value)
			AutoParry.RandomAccuracyEnabled = value == true
			MarkConfigDirty()
			if AccuracyRangeContainer then
				local alpha = value == true and 1 or 0.4
				for _, desc in ipairs(AccuracyRangeContainer:GetDescendants()) do
					if desc:IsA("ImageButton") then
						desc.Active = value == true
						desc.ImageTransparency = alpha
					end
					if desc.Name == "Frame" or desc.Name == "Bar" then
						desc.Active = value == true
					end
					if desc:IsA("TextLabel") then
						desc.TextTransparency = value == true and 0 or 0.6
					end
				end
			end
		end
	})

	do
		local rangeContainer = AutoParryGroup:AddButton({ Text = "Accuracy Range", Func = function() end })
		AccuracyRangeContainer = rangeContainer
		if rangeContainer and rangeContainer:IsA("TextButton") then
			rangeContainer.BackgroundTransparency = 1
			rangeContainer.Text = ""
			rangeContainer.Size = UDim2.new(1, -10, 0, 50)

			local featureContainer = rangeContainer.Parent
			if featureContainer and featureContainer:IsA("Frame") then
				featureContainer.Size = UDim2.new(0, 207, 0, 50)

				local options = featureContainer.Parent
				if options then
					local listLayout = options:FindFirstChildOfClass("UIListLayout")
					local contentY = listLayout and listLayout.AbsoluteContentSize.Y or options.Size.Y.Offset
					local extraHeight = 34
					options.Size = UDim2.new(0, 241, 0, contentY + extraHeight)
					local moduleFrame = options.Parent
					if moduleFrame and moduleFrame.Name == "Module" then
						moduleFrame.Size = UDim2.new(0, 241, 0, moduleFrame.AbsoluteSize.Y + extraHeight)
					end
				end
			end

			local trackHeight = 4
			local thumbSize = 14
			local pad = thumbSize / 2 + 2

			local track = Instance.new("Frame")
			track.Size = UDim2.new(1, -(pad * 2), 0, trackHeight)
			track.Position = UDim2.new(0, pad, 1, -14)
			track.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
			track.BorderSizePixel = 0
			do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 3); c.Parent = track end
			track.Parent = rangeContainer

			local fill = Instance.new("Frame")
			fill.BorderSizePixel = 0
			fill.BackgroundColor3 = Color3.fromRGB(90, 170, 255)
			do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 3); c.Parent = fill end
			fill.Parent = track

			local function makeThumb()
				local t = Instance.new("ImageButton")
				t.Size = UDim2.fromOffset(thumbSize, thumbSize)
				t.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
				t.BorderSizePixel = 0
				t.AutoButtonColor = false
				do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = t end
				t.Parent = rangeContainer
				return t
			end

			local minThumb = makeThumb()
			local maxThumb = makeThumb()

			local minVal = math.clamp(SafeToNumber(AutoParry.RandomAccuracyMin, 0.05), 0.05, 1)
			local maxVal = math.clamp(SafeToNumber(AutoParry.RandomAccuracyMax, 0.95), 0.05, 1)
			if minVal > maxVal then minVal, maxVal = maxVal, minVal end

			local titleLabel = Instance.new("TextLabel")
			titleLabel.Size = UDim2.new(1, -10, 0, 16)
			titleLabel.Position = UDim2.new(0, 5, 0, 2)
			titleLabel.BackgroundTransparency = 1
			titleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
			titleLabel.Font = Enum.Font.Gotham
			titleLabel.TextSize = 12
			titleLabel.TextXAlignment = Enum.TextXAlignment.Left
			titleLabel.Text = "Accuracy Range"
			titleLabel.Parent = rangeContainer

			local valLabel = Instance.new("TextLabel")
			valLabel.Size = UDim2.new(1, -10, 0, 14)
			valLabel.Position = UDim2.new(0, 5, 0, 18)
			valLabel.BackgroundTransparency = 1
			valLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
			valLabel.Font = Enum.Font.Gotham
			valLabel.TextSize = 10
			valLabel.TextXAlignment = Enum.TextXAlignment.Left
			valLabel.Parent = rangeContainer

			local function updateUI()
				local trackSize = track.AbsoluteSize.X
				if trackSize <= 0 then return end
				local spread = 1 - 0.05
				local minPos = (minVal - 0.05) / spread * trackSize
				local maxPos = (maxVal - 0.05) / spread * trackSize
				local trackY = track.AbsolutePosition.Y
				local containerAbsPos = rangeContainer.AbsolutePosition
				local thumbY = trackY - containerAbsPos.Y + trackHeight / 2 - thumbSize / 2
				minThumb.Position = UDim2.new(0, minPos + pad - thumbSize / 2, 0, thumbY)
				maxThumb.Position = UDim2.new(0, maxPos + pad - thumbSize / 2, 0, thumbY)
				fill.Position = UDim2.new(0, minPos, 0, 0)
				fill.Size = UDim2.new(0, math.max(maxPos - minPos, 0), 1, 0)
    valLabel.Text = string.format("%.2f - %.2f", minVal, maxVal)
			end

			dragging = false
			isMin = false

		function onDragEnd()
			if not dragging then return end
			dragging = false
			if not AutoParry.RandomAccuracyEnabled then return end
			AutoParry.RandomAccuracyMin = minVal
			AutoParry.RandomAccuracyMax = maxVal
			MarkConfigDirty()
		end

			local inputEndedConn
			inputEndedConn = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then onDragEnd() end
			end)

			local inputChangedConn
			inputChangedConn = UserInputService.InputChanged:Connect(function(input)
				if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
				if not AutoParry.RandomAccuracyEnabled then return end
				trackPos = track.AbsolutePosition
				trackSize = track.AbsoluteSize.X
				if trackSize <= 0 then return end
				mouse = UserInputService:GetMouseLocation()
				pos = math.clamp((mouse.X - trackPos.X) / trackSize, 0, 1)
				val = math.floor((0.05 + pos * (1 - 0.05)) * 100 + 0.5) / 100
				if isMin then
					minVal = math.min(val, maxVal)
				else
					maxVal = math.max(val, minVal)
				end
				updateUI()
			end)

			minThumb.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if not AutoParry.RandomAccuracyEnabled then return end
					dragging = true; isMin = true
				end
			end)

			maxThumb.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if not AutoParry.RandomAccuracyEnabled then return end
					dragging = true; isMin = false
				end
			end)

		task.defer(updateUI)

		if not AutoParry.RandomAccuracyEnabled then
			minThumb.Active = false
			maxThumb.Active = false
			track.Active = false
			minThumb.ImageTransparency = 0.4
			maxThumb.ImageTransparency = 0.4
			titleLabel.TextTransparency = 0.6
			valLabel.TextTransparency = 0.6
		end

		task.defer(function()
			if AccuracyRangeContainer and AccuracyRangeContainer:IsA("TextButton") then
				local alpha = AutoParry.RandomAccuracyEnabled and 1 or 0.4
				for _, desc in ipairs(AccuracyRangeContainer:GetDescendants()) do
					if desc:IsA("ImageButton") then
						desc.Active = AutoParry.RandomAccuracyEnabled == true
						desc.ImageTransparency = alpha
					end
					if desc.Name == "Frame" or desc.Name == "Bar" then
						desc.Active = AutoParry.RandomAccuracyEnabled == true
					end
					if desc:IsA("TextLabel") then
						desc.TextTransparency = AutoParry.RandomAccuracyEnabled and 0 or 0.6
					end
				end
			end
		end)
	end
end

	AutoParryGroup:AddToggle("PlayAnimationToggle", {
		Text = "Fix Animation",
		Default = AutoParry.PlayAnimationEnabled,
		Callback = function(value)
			AutoParry.PlayAnimationEnabled = value == true
			MarkConfigDirty()
		end
	})

	AutoParryGroup:AddToggle("AutoAbilityToggle", {
		Text = "Auto Ability",
		Default = AutoParry.AutoAbilityEnabled,
		Callback = function(value)
			AutoParry.AutoAbilityEnabled = value == true
			NotifyToggleState("Auto Ability", AutoParry.AutoAbilityEnabled)
			MarkConfigDirty()
		end
	})

	CurveGroup:AddToggle("CurveAntiCurveToggle", {
		Text = "Anti Curve",
		Default = AutoParry.AntiCurveEnabled,
		Callback = function(value)
			AutoParry.AntiCurveEnabled = value == true
			MarkConfigDirty()
		end
	})

	CurveGroup:AddToggle("CurveEnabledToggle", {
		Text = "Auto Curve",
		Default = AutoParry.CurveEnabled,
		Callback = function(value)
			AutoParry.CurveEnabled = value == true
			MarkConfigDirty()
		end
	})

	CurveGroup:AddDropdown("CurveModeDropdown", {
		Text = "Curve Type",
		Values = Main.__config.__curve_names,
		Default = AutoParry.CurveMode,
		Multi = false,
		Callback = function(value)
			if type(value) == "string" then
				AutoParry.CurveMode = value
				AutoParry.CurveModeSelected = {value}
			end
			MarkConfigDirty()
		end
	})

	CurveGroup:AddToggle("CurveHotkeyToggle", {
		Text = "Curve Hotkey",
		Default = AutoParry.CurveHotkeyEnabled,
		Callback = function(value)
			AutoParry.CurveHotkeyEnabled = value == true
			NotifyToggleState("Curve Hotkey", AutoParry.CurveHotkeyEnabled)
			MarkConfigDirty()
		end
	})

	CurveGroup:AddToggle("CurveNotifyHotkeyToggle", {
		Text = "Curve Notify Hotkey",
		Default = AutoParry.CurveNotifyHotkeyEnabled or false,
		Callback = function(value)
			AutoParry.CurveNotifyHotkeyEnabled = value == true
			MarkConfigDirty()
		end
	})

	TriggerbotGroup:AddToggle("TriggerToggle", {
		Text = "Triggerbot",
		Default = AutoParry.TriggerBotEnabled,
		Callback = function(value)
			SetTriggerBot(value)
		end
	})

	TriggerbotGroup:AddSlider("TriggerDelaySlider", {
		Text = "Delay MS",
		Default = AutoParry.TriggerBotDelayMs,
		Min = 0,
		Max = 150,
		Rounding = 0,
		Callback = function(value)
			AutoParry.TriggerBotDelayMs = math.clamp(math.floor(SafeToNumber(value, AutoParry.TriggerBotDelayMs)), 0, 150)
			MarkConfigDirty()
		end
	})

	TriggerbotGroup:AddToggle("TriggerBotPlayAnimationToggle", {
		Text = "Fix Animation",
		Default = AutoParry.TriggerBotPlayAnimation,
		Callback = function(value)
			AutoParry.TriggerBotPlayAnimation = value == true
			MarkConfigDirty()
		end
	})

	InfinityDetectionGroup:AddToggle("InfinityDetectionToggle", {
		Text = "Infinity Detection",
		Default = AutoParry.InfinityDetectionEnabled,
		Callback = function(value)
			SetInfinityDetection(value)
			MarkConfigDirty()
		end
	})

	InfinityDetectionGroup:AddToggle("InfinityNotifyToggle", {
		Text = "Notify",
		Default = AutoParry.InfinityDetectionNotify,
		Callback = function(value)
			AutoParry.InfinityDetectionNotify = value == true
			MarkConfigDirty()
		end
	})

	DimFrame:AddToggle("TimeHoleDetectionToggle", {
		Text = "Time Hole Detection",
		Default = AutoParry.TimeHoleDetectionEnabled,
		Callback = function(value)
			SetTimeHoleDetection(value)
			MarkConfigDirty()
		end
	})

	PanelFrame:AddToggle("DeathSlashDetectionToggle", {
		Text = "Death Slash Detection",
		Default = AutoParry.DeathSlashDetectionEnabled,
		Callback = function(value)
			SetDeathSlashDetection(value)
			MarkConfigDirty()
		end
	})

	BarBackground:AddToggle("SingularityDetectionToggle", {
		Text = "Singularity Detection",
		Default = AutoParry.SingularityDetectionEnabled,
		Callback = function(value)
			SetSingularityDetection(value)
			MarkConfigDirty()
		end
	})

	SlashesOfFuryGroup:AddToggle("SlashesOfFuryDetectionToggle", {
		Text = "Slashes Of Fury Detection",
		Default = AutoParry.SlashesOfFuryDetectionEnabled,
		Callback = function(value)
			SetSlashesOfFuryDetection(value)
			MarkConfigDirty()
		end
	})

	SlashesOfFuryGroup:AddSlider("SlashesOfFuryDelaySlider", {
		Text = "Parry Delay",
		Default = AutoParry.SlashesOfFuryParryDelay,
		Min = 0.05,
		Max = 0.25,
		Rounding = 2,
		Callback = function(value)
			AutoParry.SlashesOfFuryParryDelay = math.clamp(SafeToNumber(value, AutoParry.SlashesOfFuryParryDelay), 0.05, 0.25)
			MarkConfigDirty()
		end
	})

	SlashesOfFuryGroup:AddSlider("SlashesOfFuryCountSlider", {
		Text = "Max Parry Count",
		Default = AutoParry.SlashesOfFuryMaxParryCount,
		Min = 1,
		Max = 100,
		Rounding = 0,
		Callback = function(value)
			AutoParry.SlashesOfFuryMaxParryCount = math.max(1, math.floor(SafeToNumber(value, AutoParry.SlashesOfFuryMaxParryCount)))
			MarkConfigDirty()
		end
	})

	AerodynamicSlashGroup:AddToggle("AerodynamicSlashToggle", {
		Text = "Aerodynamic Slash",
		Default = AutoParry.AerodynamicSlashEnabled,
		Callback = function(value)
			HyperionPort.SetAerodynamicSlash(value)
			MarkConfigDirty()
		end
	})

	AutoSpamGroup:AddToggle("AutoSpamToggle", {
		Text = "Auto Spam",
		Default = AutoParry.AutoSpamEnabled,
		Callback = function(value)
			SetAutoSpam(value)
		end
	})

	AutoSpamGroup:AddSlider("AutoSpamDetectorSlider", {
		Text = "Auto Spam Detector",
		Default = AutoParry.AutoSpamDetectorSize,
		Min = 1,
		Max = 60,
		Rounding = 0,
		Callback = function(value)
			AutoParry.AutoSpamDetectorSize = SafeToNumber(value, AutoParry.AutoSpamDetectorSize)
			MarkConfigDirty()
		end
	})

	AutoSpamGroup:AddSlider("AutoSpamMultiplierSlider", {
		Text = "Auto Spam CPS",
		Default = AutoParry.AutoSpamMultiplier,
		Min = 1,
		Max = 2000,
		Rounding = 0,
		Callback = function(value)
			AutoParry.AutoSpamMultiplier = math.clamp(math.floor(SafeToNumber(value, AutoParry.AutoSpamMultiplier)), 1, 2000)
			MarkConfigDirty()
		end
	})

	if IsMobile() then
		ManualSpamGroup:AddToggle("ManualSpamEnabledToggle", {
			Text = "Manual Spam",
			Default = AutoParry.ManualSpamEnabled,
			Callback = function(value)
				AutoParry.ManualSpamEnabled = value == true
				AutoParry.ManualSpamActive = value == true
				UpdateManualSpamButtonUI()
				MarkConfigDirty()
				NotifyToggleState("Manual Spam", AutoParry.ManualSpamEnabled)
			end
		})

		ManualSpamGroup:AddToggle("ManualSpamButtonToggle", {
			Text = "Manual Spam UI",
			Default = AutoParry.ManualSpamButtonEnabled,
			Callback = function(value)
				SetManualSpamButtonEnabled(value)
				MarkConfigDirty()
			end
		})

		ManualSpamGroup:AddToggle("ManualSpamNotifyToggle", {
			Text = "Spam Notify",
			Default = AutoParry.ManualSpamNotify,
			Callback = function(value)
				AutoParry.ManualSpamNotify = value == true
				MarkConfigDirty()
			end
		})

		ManualSpamGroup:AddToggle("ManualSpamPlayAnimationToggle", {
			Text = "Fix Animation",
			Default = AutoParry.ManualSpamPlayAnimation,
			Callback = function(value)
				AutoParry.ManualSpamPlayAnimation = value == true
				MarkConfigDirty()
			end
		})

		ManualSpamGroup:AddSlider("ManualSpamMultiplierSlider", {
			Text = "Manual Spam CPS",
			Default = AutoParry.ManualSpamMultiplier,
			Min = 1,
			Max = 2000,
			Rounding = 0,
			Callback = function(value)
				AutoParry.ManualSpamMultiplier = math.clamp(math.floor(SafeToNumber(value, AutoParry.ManualSpamMultiplier)), 1, 2000)
				MarkConfigDirty()
			end
		})

		ManualSpamGroup:AddDropdown("ManualSpamMethodDropdown", {
			Text = "Spam Method",
			Values = { "Remote", "Keypress" },
			Default = AutoParry.ManualSpamMethod,
			Multi = false,
			Callback = function(value)
				AutoParry.ManualSpamMethod = NormalizeParryMethod(value)
				MarkConfigDirty()
			end
		})
	else
		AutoParry.ManualSpamButtonEnabled = false
		DestroyManualSpamUI()

		ManualSpamGroup:AddDropdown("ManualSpamMethodDropdown", {
			Text = "Spam Method",
			Values = { "Remote", "Keypress" },
			Default = AutoParry.ManualSpamMethod,
			Multi = false,
			Callback = function(value)
				AutoParry.ManualSpamMethod = NormalizeParryMethod(value)
				MarkConfigDirty()
			end
		})

		ManualSpamGroup:AddToggle("ManualSpamEnabledToggle", {
			Text = "Manual Spam",
			Default = AutoParry.ManualSpamEnabled,
			Callback = function(value)
				AutoParry.ManualSpamEnabled = value == true
				AutoParry.ManualSpamActive = value == true
				UpdateManualSpamButtonUI()
				MarkConfigDirty()
				NotifyToggleState("Manual Spam", AutoParry.ManualSpamEnabled)
			end
		})

		ManualSpamGroup:AddToggle("ManualSpamNotifyToggle", {
			Text = "Spam Notify",
			Default = AutoParry.ManualSpamNotify,
			Callback = function(value)
				AutoParry.ManualSpamNotify = value == true
				MarkConfigDirty()
			end
		})

		ManualSpamGroup:AddToggle("ManualSpamPlayAnimationToggle", {
			Text = "Fix Animation",
			Default = AutoParry.ManualSpamPlayAnimation,
			Callback = function(value)
				AutoParry.ManualSpamPlayAnimation = value == true
				MarkConfigDirty()
			end
		})

		ManualSpamGroup:AddSlider("ManualSpamMultiplierSlider", {
			Text = "Manual Spam CPS",
			Default = AutoParry.ManualSpamMultiplier,
			Min = 1,
			Max = 2000,
			Rounding = 0,
			Callback = function(value)
				AutoParry.ManualSpamMultiplier = math.clamp(math.floor(SafeToNumber(value, AutoParry.ManualSpamMultiplier)), 1, 2000)
				MarkConfigDirty()
			end
		})
	end

	InformationGroup:AddToggle("BallInformationEnabledToggle", {
		Text = "Information Panel",
		Default = AutoParry.BallInformationEnabled,
		Callback = function(value)
			AutoParry.BallInformationEnabled = value == true
			HyperionPort.SetInfoPanel(value)
			MarkConfigDirty()
		end
	})

	InformationGroup:AddToggle("BallSpeedToggle", {
		Text = "Ball Speed",
		Default = AutoParry.ShowBallSpeed,
		Callback = function(value)
			AutoParry.ShowBallSpeed = value == true
			HyperionPort.SetInfoPanel(AutoParry.BallInformationEnabled)
			MarkConfigDirty()
		end
	})

	InformationGroup:AddToggle("ShowFPSInInfoToggle", {
		Text = "Show FPS",
		Default = AutoParry.ShowFPSInInfo,
		Callback = function(value)
			AutoParry.ShowFPSInInfo = value == true
			HyperionPort.SetInfoPanel(AutoParry.BallInformationEnabled)
			MarkConfigDirty()
		end
	})

	InformationGroup:AddToggle("ShowPingInInfoToggle", {
		Text = "Show Ping",
		Default = AutoParry.ShowPingInInfo,
		Callback = function(value)
			AutoParry.ShowPingInInfo = value == true
			HyperionPort.SetInfoPanel(AutoParry.BallInformationEnabled)
			MarkConfigDirty()
		end
	})

	AbilityESPGroup:AddToggle("AbilityESPToggle", {
		Text = "Ability ESP",
		Default = AutoParry.AbilityESPEnabled,
		Callback = function(value)
			HyperionPort.SetAbilityESP(value)
			NotifyToggleState("Ability ESP", AutoParry.AbilityESPEnabled)
			MarkConfigDirty()
		end
	})

	AbilityESPGroup:AddToggle("CooldownTimerToggle", {
		Text = "Cooldown Timer",
		Default = AutoParry.CooldownTimerEnabled,
		Callback = function(value)
			AutoParry.CooldownTimerEnabled = value == true
			MarkConfigDirty()
		end
	})

	AbilityESPGroup:AddToggle("ActiveTimerToggle", {
		Text = "Active Timer",
		Default = AutoParry.ActiveTimerEnabled,
		Callback = function(value)
			AutoParry.ActiveTimerEnabled = value == true
			MarkConfigDirty()
		end
	})

	DiscordInfoGroup:AddButton({
		Text = "Copy Discord",
		Func = function()
			CopyDiscordInvite()
		end
	})

	ExistingLoader:AddToggle("AtmosphereToggle", {
		Text = "Atmosphere",
		Default = AutoParry.AtmosphereEnabled,
		Callback = function(value)
			AutoParry.AtmosphereEnabled = value == true
			UpdateAtmosphere()
			NotifyToggleState("Atmosphere", AutoParry.AtmosphereEnabled)
			MarkConfigDirty()
		end
	})

	ExistingLoader:AddSlider("AtmosphereDensitySlider", {
		Text = "Atmosphere Density",
		Default = AutoParry.AtmosphereDensity,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(value)
			AutoParry.AtmosphereDensity = math.clamp(SafeToNumber(value, AutoParry.AtmosphereDensity), 0, 1)
			UpdateAtmosphere()
			MarkConfigDirty()
		end
	})

	ExistingLoader:AddToggle("WorldLightingToggle", {
		Text = "World Lighting",
		Default = AutoParry.WorldLightingEnabled,
		Callback = function(value)
			AutoParry.WorldLightingEnabled = value == true
			UpdateLighting()
			NotifyToggleState("World Lighting", AutoParry.WorldLightingEnabled)
			MarkConfigDirty()
		end
	})

	ExistingLoader:AddSlider("LightingBrightnessSlider", {
		Text = "Brightness",
		Default = AutoParry.LightingBrightness,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Callback = function(value)
			AutoParry.LightingBrightness = math.clamp(SafeToNumber(value, AutoParry.LightingBrightness), 0, 10)
			UpdateLighting()
			MarkConfigDirty()
		end
	})

	ExistingLoader:AddSlider("LightingClockTimeSlider", {
		Text = "Clock Time",
		Default = AutoParry.LightingClockTime,
		Min = 0,
		Max = 24,
		Rounding = 1,
		Callback = function(value)
			AutoParry.LightingClockTime = math.clamp(SafeToNumber(value, AutoParry.LightingClockTime), 0, 24)
			UpdateLighting()
			MarkConfigDirty()
		end
	})

	ExistingLoader:AddToggle("SaturationToggle", {
		Text = "Saturation",
		Default = AutoParry.SaturationEnabled,
		Callback = function(value)
			AutoParry.SaturationEnabled = value == true
			UpdateSaturation()
			NotifyToggleState("Saturation", AutoParry.SaturationEnabled)
			MarkConfigDirty()
		end
	})

	ExistingLoader:AddSlider("SaturationAmountSlider", {
		Text = "Saturation Amount",
		Default = AutoParry.SaturationAmount,
		Min = -1,
		Max = 1,
		Rounding = 2,
		Callback = function(value)
			AutoParry.SaturationAmount = math.clamp(SafeToNumber(value, AutoParry.SaturationAmount), -1, 1)
			UpdateSaturation()
			MarkConfigDirty()
		end
	})


	SwordChangerGroup:AddToggle("SkinChangerToggle", {
		Text = "Sword Changer",
		Default = AutoParry.SkinChangerEnabled,
		Callback = function(value)
			AutoParry.SkinChangerEnabled = value == true
			ApplySkinChanger()
			MarkConfigDirty()
		end
	})

	allSwordNames = FetchSwordList()
	pcall(function()
		Swords2 = EnsureSwordInstances()
		if Swords2 then
			local _, col = pcall(Swords2.GetCollection, Swords2)
			if col then
				local names = {}
				for n in pairs(col) do names[#names+1] = n end
				table.sort(names)
				allSwordNames = names
			end
		end
	end)

	SwordChangerGroup:AddDropdown("SwordListDropdown", {
		Text = "Sword List",
		Values = allSwordNames,
		Default = GetSkinName() ~= "" and GetSkinName() or "None",
		Callback = function(value)
			SwordName = tostring(value or "")

			if SwordName ~= "" and SwordName ~= "None" then
				AutoParry.SkinName = SwordName
				ApplySkinChanger()
				MarkConfigDirty()
			end
		end
	})

	SwordChangerGroup:AddInput("SkinNameInput", {
		Text = "Sword Name",
		Default = AutoParry.SkinName,
		Placeholder = "",
		Numeric = false,
		Finished = true,
		Callback = function(value)
			AutoParry.SkinName = tostring(value or "")
			ApplySkinChanger()
			MarkConfigDirty()
		end
	})

	local savedKorbloxState = AutoParry.KorbloxEnabled
	local savedHeadlessState = AutoParry.HeadlessEnabled
	local korbloxCheckbox = nil
	local headlessCheckbox = nil


	HeadlessKorbloxGroup:AddToggle("CharacterModuleToggle", {
		Text = "Characters",
		Default = AutoParry.CharacterModuleEnabled,
		Callback = function(value)
			AutoParry.CharacterModuleEnabled = value == true

			if AutoParry.CharacterModuleEnabled then
				AutoParry.KorbloxEnabled = savedKorbloxState
				AutoParry.HeadlessEnabled = savedHeadlessState
				HyperionPort.ApplyHeadlessKorbloxDescription(Player.Character)

				if korbloxCheckbox and korbloxCheckbox.change_state then
					pcall(function() korbloxCheckbox:change_state(AutoParry.KorbloxEnabled) end)
				end
				if headlessCheckbox and headlessCheckbox.change_state then
					pcall(function() headlessCheckbox:change_state(AutoParry.HeadlessEnabled) end)
				end
			else
				savedKorbloxState = AutoParry.KorbloxEnabled
				savedHeadlessState = AutoParry.HeadlessEnabled
				AutoParry.KorbloxEnabled = false
				AutoParry.HeadlessEnabled = false
				HyperionPort.ApplyHeadlessKorbloxDescription(Player.Character)
			end

			MarkConfigDirty()
		end
	})

	korbloxCheckbox = HeadlessKorbloxGroup:AddToggle("KorbloxToggle", {
		Text = "Korblox",
		Default = AutoParry.KorbloxEnabled,
		Callback = function(value)
			HyperionPort.SetKorbloxOnly(value)
			MarkConfigDirty()
		end
	})

	headlessCheckbox = HeadlessKorbloxGroup:AddToggle("HeadlessToggle", {
		Text = "Headless",
		Default = AutoParry.HeadlessEnabled,
		Callback = function(value)
			HyperionPort.SetHeadlessOnly(value)
			MarkConfigDirty()
		end
	})

	local UnlockAllGroup = Tabs.Changer:AddLeftGroupbox("Unlock All")

	UnlockAllGroup:AddToggle("UnlockAllSwordToggle", {
		Text = "Unlock All Sword",
		Default = AutoParry.UnlockAllSwordsEnabled,
		Callback = function(value)
			HyperionPort.SetUnlockAllSwords(value)
			MarkConfigDirty()
		end
	})

	-- ===========================================================================
	-- Profile Spoofer (Changer Tab - Left Container)
	-- ===========================================================================

	local ProfileSpoofState = {
		NameSpoof = false,
		TitleSpoof = false,
		StatsSpoof = false,
		UnlockTitles = false,
		UnlockEmotes = false,
		SpoofDisplayName = "",
		SpoofUsername = "",
		EquippedTitle = nil,
		SpoofedAvatarUrl = nil,
		Stats = { Time = "", Games = "", Kills = "", Wins = "", RAP = "", WinStreak = "" },
	}

	local TitleData = require(ReplicatedStorage.Shared.TitleData)
	local Replion = require(ReplicatedStorage.Packages.Replion)
	local Inventory = require(ReplicatedStorage.Shared.Inventory)

	local TitleList = {}
	for _, v in ipairs(TitleData) do
		table.insert(TitleList, v.Name)
	end

	local ProfileCard = PlayerGui:WaitForChild("ProfileCard")
	local Customize = ProfileCard:WaitForChild("Customize")
	local Profile = Customize:WaitForChild("Profile")
	local PlayerCard = Customize:WaitForChild("PlayerCard")
	local PlayerProfile = Profile:WaitForChild("PlayerProfile")
	local Details = PlayerProfile:WaitForChild("Details")
	local StatsGui = PlayerProfile:WaitForChild("Stats")

	local DataReplion = Replion.Client:WaitReplion("Data")
	local InvClient = Inventory.Client

	-- Profile Spoofer Hooks
	local PS_DataMT = getrawmetatable(DataReplion)
	local PS_origDataGet = PS_DataMT.Get
	PS_DataMT.Get = function(self, path)
		if path and type(path) == "table" then
			if ProfileSpoofState.UnlockTitles and path[1] == "Titles" and path[2] ~= nil then return true end
			if ProfileSpoofState.EquippedTitle and path[1] == "EquippedTitle" then return ProfileSpoofState.EquippedTitle end
		end
		return PS_origDataGet(self, path)
	end

	local PS_origFindItems = InvClient.FindItems
	InvClient.FindItems = function(self, p2, p3, p4)
		if ProfileSpoofState.UnlockEmotes and p2 == "Emote" then return {{Name = p3, Id = p3}} end
		return PS_origFindItems(self, p2, p3, p4)
	end

	local PS_origFindItemsWithKey = InvClient.FindItemsWithKey
	InvClient.FindItemsWithKey = function(self, p2, p3)
		if ProfileSpoofState.UnlockEmotes and p2 == "Emote" then return {{Name = p3, Id = p3}} end
		return PS_origFindItemsWithKey(self, p2, p3)
	end

	local PS_origOwnsItem = InvClient.OwnsItem
	InvClient.OwnsItem = function(self, p2, p3)
		if ProfileSpoofState.UnlockEmotes and p2 == "Emote" then return true end
		return PS_origOwnsItem(self, p2, p3)
	end

	local function PS_getTitleData(name)
		for _, v in ipairs(TitleData) do
			if v.Name == name then return v end
		end
		return nil
	end

	local function PS_restoreNames()
		local d1 = Details:FindFirstChild("DisplayRealName") or Details:FindFirstChild("Username1")
		if d1 then d1.Text = LocalPlayer.DisplayName end
		local un = Details:FindFirstChild("Username")
		if un then un.Text = "@" .. LocalPlayer.Name end
		local cu = PlayerCard:FindFirstChild("Username")
		if cu then cu.Text = LocalPlayer.DisplayName end
	end

	local function PS_fetchUserHeadshot(username)
		local ok, uid = pcall(function() return Players:GetUserIdFromNameAsync(username) end)
		if ok and uid then
			ProfileSpoofState.SpoofedAvatarUrl = ("rbxthumb://type=AvatarHeadShot&id=%*&w=150&h=150"):format(uid)
			return true
		end
		return nil
	end

	local function PS_applyAllSpoofs()
		local Utils = require(ReplicatedStorage.Common.Utils)
		local VC = Utils.ValueConvertor

		if ProfileSpoofState.NameSpoof then
			local d1 = Details:FindFirstChild("DisplayRealName") or Details:FindFirstChild("Username1")
			if d1 and ProfileSpoofState.SpoofDisplayName ~= "" then d1.Text = ProfileSpoofState.SpoofDisplayName end
			local un = Details:FindFirstChild("Username")
			if un and ProfileSpoofState.SpoofUsername ~= "" then un.Text = "@" .. ProfileSpoofState.SpoofUsername end
			local cu = PlayerCard:FindFirstChild("Username")
			if cu and ProfileSpoofState.SpoofDisplayName ~= "" then cu.Text = ProfileSpoofState.SpoofDisplayName end
		end

		if ProfileSpoofState.EquippedTitle then
			local td = PS_getTitleData(ProfileSpoofState.EquippedTitle)
			if td then
				local tl = Details:FindFirstChild("Title")
				if tl then tl.Text = td.Tag.Text; tl.TextColor3 = td.Tag.Color; tl.Visible = true end
				local ct = PlayerCard:FindFirstChild("Title")
				if ct then ct.Text = td.Tag.Text; ct.TextColor3 = td.Tag.Color end
			end
		end

		if ProfileSpoofState.StatsSpoof then
			local function getVal(s)
				if s == nil or s == "" then return nil end
				local n = tonumber(s)
				if n then return VC:AddCommas(n) end
				return tostring(s)
			end

			if StatsGui then
				local v = getVal(ProfileSpoofState.Stats.Kills) if v and StatsGui.Kills and StatsGui.Kills.Amount then StatsGui.Kills.Amount.Text = v end
				local v = getVal(ProfileSpoofState.Stats.Wins) if v and StatsGui.Wins and StatsGui.Wins.Amount then StatsGui.Wins.Amount.Text = v end
				local v = getVal(ProfileSpoofState.Stats.RAP) if v and StatsGui.Rap and StatsGui.Rap.Amount then StatsGui.Rap.Amount.Text = v end
			end
			if PlayerCard then
				local v = getVal(ProfileSpoofState.Stats.Kills) if v then local k = PlayerCard:FindFirstChild("Kills") if k and k.Amount then k.Amount.Text = v .. " Elims" end end
				local v = getVal(ProfileSpoofState.Stats.Wins) if v then local w = PlayerCard:FindFirstChild("Wins") if w and w.Amount then w.Amount.Text = v .. " Wins" end end
			end

			local Achievements = Profile:FindFirstChild("Achievements")
			if Achievements then
				local sf = Achievements:FindFirstChild("Scrollingframe")
				if sf then
					for _, a in ipairs(sf:GetChildren()) do
						if a:IsA("TextButton") then
							local t = a:FindFirstChild("Title")
							local d = a:FindFirstChild("Description")
							if t and d then
								if t.Text == "Time Played" then
									local v = getVal(ProfileSpoofState.Stats.Time)
									if v then
										local n = tonumber(ProfileSpoofState.Stats.Time)
										d.Text = n and VC:FormatShortTime(n) or tostring(ProfileSpoofState.Stats.Time)
									end
								elseif t.Text == "Games Played" then
									local v = getVal(ProfileSpoofState.Stats.Games) if v then d.Text = v end
								elseif t.Text == "Best Win Streak" then
									local v = getVal(ProfileSpoofState.Stats.WinStreak) if v then d.Text = v end
								end
							end
						end
					end
				end
			end

			local char = LocalPlayer.Character
			if char then
				local wsd = char:FindFirstChild("WinStreakDisplay", true)
				if wsd then
					local main = wsd:FindFirstChild("Main")
					if main then
						local val = main:FindFirstChild("Value")
						if val and ProfileSpoofState.Stats.WinStreak ~= "" then
							local v = getVal(ProfileSpoofState.Stats.WinStreak)
							if v then val.Text = "<b><stroke color='rgb(0, 0, 0)' thickness='2'>" .. v .. "</stroke></b>" end
						end
					end
				end
			end
		end

		if ProfileSpoofState.SpoofedAvatarUrl then
			local pfp = PlayerProfile:FindFirstChild("Player")
			if pfp and pfp:IsA("ImageLabel") then pfp.Image = ProfileSpoofState.SpoofedAvatarUrl end
			local cp = PlayerCard:FindFirstChild("Pfp")
			if cp then local av = cp:FindFirstChild("Avatar") if av and av:IsA("ImageLabel") then av.Image = ProfileSpoofState.SpoofedAvatarUrl end end
		end
	end

	local PS_loopActive = false
	local function PS_startLoop()
		if PS_loopActive then return end
		PS_loopActive = true
		task.spawn(function()
			while PS_loopActive do
				if ProfileCard.Enabled then
					PS_applyAllSpoofs()
				end
				task.wait(0.1)
			end
		end)
	end

	local ProfileSpooferGroup = Tabs.Changer:AddLeftGroupbox("Profile Spoofer")

	ProfileSpooferGroup:AddToggle("PS_NameSpoofToggle", {
		Text = "Name Spoof",
		Default = false,
		Callback = function(value)
			ProfileSpoofState.NameSpoof = value
			if not value then PS_restoreNames() end
			if value then PS_startLoop() end
			MarkConfigDirty()
		end
	})

	ProfileSpooferGroup:AddInput("PS_DisplayNameInput", {
		Text = "Display Name",
		Default = "",
		Placeholder = "Enter display name...",
		Numeric = false,
		Finished = false,
		Callback = function(value)
			ProfileSpoofState.SpoofDisplayName = tostring(value or "")
		end
	})

	ProfileSpooferGroup:AddInput("PS_UsernameInput", {
		Text = "Username",
		Default = "",
		Placeholder = "Enter username...",
		Numeric = false,
		Finished = false,
		Callback = function(value)
			ProfileSpoofState.SpoofUsername = tostring(value or "")
		end
	})

	ProfileSpooferGroup:AddInput("PS_AvatarInput", {
		Text = "Avatar Username",
		Default = "",
		Placeholder = "Fetch avatar from username...",
		Numeric = false,
		Finished = true,
		Callback = function(value)
			if tostring(value or "") ~= "" then PS_fetchUserHeadshot(tostring(value)) end
		end
	})

	ProfileSpooferGroup:AddToggle("PS_TitleSpoofToggle", {
		Text = "Title Spoof",
		Default = false,
		Callback = function(value)
			ProfileSpoofState.TitleSpoof = value
			if value then PS_startLoop() end
			MarkConfigDirty()
		end
	})

	ProfileSpooferGroup:AddInput("PS_TitleInput", {
		Text = "Title",
		Default = "",
		Placeholder = "Enter title name...",
		Numeric = false,
		Finished = false,
		Callback = function(value)
			ProfileSpoofState.EquippedTitle = tostring(value or "")
		end
	})

	ProfileSpooferGroup:AddToggle("PS_StatsSpoofToggle", {
		Text = "Stats Spoof",
		Default = false,
		Callback = function(value)
			ProfileSpoofState.StatsSpoof = value
			if value then PS_startLoop() end
			MarkConfigDirty()
		end
	})

	ProfileSpooferGroup:AddInput("PS_TimeInput", {
		Text = "Time (sec)",
		Default = "",
		Placeholder = "...",
		Numeric = false,
		Finished = false,
		Callback = function(value)
			ProfileSpoofState.Stats.Time = tostring(value or "")
		end
	})

	ProfileSpooferGroup:AddInput("PS_GamesInput", {
		Text = "Games",
		Default = "",
		Placeholder = "...",
		Numeric = false,
		Finished = false,
		Callback = function(value)
			ProfileSpoofState.Stats.Games = tostring(value or "")
		end
	})

	ProfileSpooferGroup:AddInput("PS_KillsInput", {
		Text = "Elims",
		Default = "",
		Placeholder = "...",
		Numeric = false,
		Finished = false,
		Callback = function(value)
			ProfileSpoofState.Stats.Kills = tostring(value or "")
		end
	})

	ProfileSpooferGroup:AddInput("PS_WinsInput", {
		Text = "Wins",
		Default = "",
		Placeholder = "...",
		Numeric = false,
		Finished = false,
		Callback = function(value)
			ProfileSpoofState.Stats.Wins = tostring(value or "")
		end
	})

	ProfileSpooferGroup:AddInput("PS_RAPInput", {
		Text = "RAP",
		Default = "",
		Placeholder = "...",
		Numeric = false,
		Finished = false,
		Callback = function(value)
			ProfileSpoofState.Stats.RAP = tostring(value or "")
		end
	})

	ProfileSpooferGroup:AddInput("PS_WinStreakInput", {
		Text = "Win Streak",
		Default = "",
		Placeholder = "...",
		Numeric = false,
		Finished = false,
		Callback = function(value)
			ProfileSpoofState.Stats.WinStreak = tostring(value or "")
		end
	})

	ProfileSpooferGroup:AddToggle("PS_UnlockTitlesToggle", {
		Text = "Unlock Titles",
		Default = false,
		Callback = function(value)
			ProfileSpoofState.UnlockTitles = value
			MarkConfigDirty()
		end
	})

	ProfileSpooferGroup:AddToggle("PS_UnlockEmotesToggle", {
		Text = "Unlock Emotes",
		Default = false,
		Callback = function(value)
			ProfileSpoofState.UnlockEmotes = value
			MarkConfigDirty()
		end
	})

	local StartUpLoader = Tabs.Player:AddLeftGroupbox("Avatar Chams")

	StartUpLoader:AddToggle("AvatarChamsEnabledToggle", {
		Text = "Avatar Chams",
		Default = AutoParry.AvatarChamsEnabled,
		Callback = function(value)
			AutoParry.AvatarChamsEnabled = value == true
			ApplyAvatarChams()
			MarkConfigDirty()
		end
	})

	StartUpLoader:AddToggle("AvatarChamsSelfToggle", {
		Text = "Show Self",
		Default = AutoParry.AvatarChamsSelf,
		Callback = function(value)
			AutoParry.AvatarChamsSelf = value == true
			ApplyAvatarChams()
			MarkConfigDirty()
		end
	})

	StartUpLoader:AddToggle("AvatarChamsOthersToggle", {
		Text = "Show Others",
		Default = AutoParry.AvatarChamsOthers,
		Callback = function(value)
			AutoParry.AvatarChamsOthers = value == true
			ApplyAvatarChams()
			MarkConfigDirty()
		end
	})

	AvatarChangerGroup:AddToggle("AvatarChangerToggle", {
		Text = "Avatar Changer",
		Default = AutoParry.AvatarChangerEnabled,
		Callback = function(value)
			HyperionPort.SetAvatarChanger(value == true)
		end
	})

	AvatarChangerGroup:AddInput("AvatarChangerNameInput", {
		Text = "Avatar Name",
		Default = AutoParry.AvatarChangerName,
		Placeholder = "Player name...",
		Numeric = false,
		Finished = true,
		Callback = function(value)
			AutoParry.AvatarChangerName = tostring(value or "")
			if AutoParry.AvatarChangerEnabled and AutoParry.AvatarChangerName ~= "" then
				HyperionPort.ApplyAvatarLook(AutoParry.AvatarChangerName)
			end
			MarkConfigDirty()
		end
	})

	AvatarChangerGroup:AddButton({
		Text = "Apply Avatar",
		Func = function()
			local name = tostring(AutoParry.AvatarChangerName or ""):match("^%s*(.-)%s*$") or ""
			if name == "" or name:lower() == "none" then
				ShowNotification("Avatar Changer: enter a player name first", 3, "warning")
				return
			end
			HyperionPort.ApplyAvatarLook(name)
		end
	})

	ModuleName = Tabs.Changer:AddRightGroupbox("ParryFX Color")

	ModuleName:AddToggle("ParryFXColorToggle", {
		Text = "Custom ParryFX Color",
		Default = AutoParry.ParryFXColorEnabled,
		Callback = function(value)
			AutoParry.ParryFXColorEnabled = value == true
			if not AutoParry.ParryFXColorEnabled then
				AutoParry.ParryFXRainbow = false
			end
			if AutoParry.ParryFXColorEnabled then ApplyParryFXColors() end
			MarkConfigDirty()
		end
	})

	CreateColorPicker(ModuleName, "ParryFXColor", "ParryFXColor", "ParryFXColorR", "ParryFXColorG", "ParryFXColorB", false, function() if AutoParry.ParryFXColorEnabled then ApplyParryFXColors() end end)

	ModuleName:AddToggle("ParryFXRainbowToggle", {
		Text = "Rainbow",
		Default = AutoParry.ParryFXRainbow,
		Callback = function(value)
			AutoParry.ParryFXRainbow = value == true
			if AutoParry.ParryFXRainbow then
				AutoParry.ParryFXColorEnabled = true
			end
			MarkConfigDirty()
		end
	})

	Progress = Tabs.Changer:AddRightGroupbox("Sword Color")

	Progress:AddToggle("SwordColorToggle", {
		Text = "Custom Sword Color",
		Default = AutoParry.SwordColorEnabled,
		Callback = function(value)
			AutoParry.SwordColorEnabled = value == true
			if not AutoParry.SwordColorEnabled then
				AutoParry.SwordRainbow = false
			end
			if AutoParry.SwordColorEnabled then ApplySwordColors() end
			MarkConfigDirty()
		end
	})

	CreateColorPicker(Progress, "SwordColor", "SwordColor", "SwordColorR", "SwordColorG", "SwordColorB", false, function() if AutoParry.SwordColorEnabled then ApplySwordColors() end end)

	Progress:AddToggle("SwordRainbowToggle", {
		Text = "Rainbow",
		Default = AutoParry.SwordRainbow,
		Callback = function(value)
			AutoParry.SwordRainbow = value == true
			if AutoParry.SwordRainbow then
				AutoParry.SwordColorEnabled = true
			end
			MarkConfigDirty()
		end
	})

	local CustomVFXGroup = Tabs.Changer:AddRightGroupbox("Custom VFX")

	CustomVFXGroup:AddToggle("CustomVFXToggle", {
		Text = "Custom VFX",
		Default = AutoParry.CustomVFXEnabled,
		Callback = function(value)
			AutoParry.CustomVFXEnabled = value == true
			if AutoParry.CustomVFXEnabled and (AutoParry.CustomVFXName == "" or AutoParry.CustomVFXName == "None") then
				ShowNotification("Custom VFX: pick a sword from the list to use its VFX", 3, "info")
			end
			MarkConfigDirty()
		end
	})

	local customVFXValues = { "None" }
	for _, name in ipairs(allSwordNames) do
		if name ~= "None" then
			table.insert(customVFXValues, name)
		end
	end

	CustomVFXGroup:AddDropdown("CustomVFXListDropdown", {
		Text = "VFX List",
		Values = customVFXValues,
		Default = (AutoParry.CustomVFXName ~= "" and AutoParry.CustomVFXName) or "None",
		Multi = false,
		Callback = function(value)
			AutoParry.CustomVFXName = tostring(value or "None")
			MarkConfigDirty()
		end
	})

	vUIKeyGroup = Tabs.GUI:AddLeftGroupbox("UI Keybind")

	vUIKeyGroup:AddDropdown("UIKeyDropdown", {
		Text = "Toggle UI Key",
		Values = { "RightShift", "LeftShift", "RightControl", "LeftControl", "RightAlt", "LeftAlt", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "Insert", "Home", "Delete" },
		Default = tostring(AutoParry.UIKey):gsub("Enum.KeyCode.", ""),
		Multi = false,
		Callback = function(value)
			local keyMap = {
				RightShift = Enum.KeyCode.RightShift,
				LeftShift = Enum.KeyCode.LeftShift,
				RightControl = Enum.KeyCode.RightControl,
				LeftControl = Enum.KeyCode.LeftControl,
				RightAlt = Enum.KeyCode.RightAlt,
				LeftAlt = Enum.KeyCode.LeftAlt,
			}
			AutoParry.UIKey = keyMap[value] or Enum.KeyCode[value] or AutoParry.UIKey
			_G.UIKey = AutoParry.UIKey
			UpdateUIKeyListener()
			MarkConfigDirty()
		end
	})

	local vConfigGroup = Tabs.GUI:AddLeftGroupbox("Config Manager")

	local function CollectConfigValues(includeCurrent)
		local values = { "Autosave" }
		for _, name in ipairs(ListSavedConfigs()) do
			table.insert(values, name)
		end
		if includeCurrent then
			local cur = AutoParry.ActiveConfig or "Autosave"
			if cur ~= "Autosave" and not table.find(values, cur) then
				table.insert(values, cur)
			end
		end
		table.sort(values)
		return values
	end

	local configDropdown = vConfigGroup:AddDropdown("ConfigListDropdown", {
		Text = "Config List",
		Values = CollectConfigValues(true),
		Default = AutoParry.ActiveConfig or GetAutoloadConfig(),
		Multi = false,
		Callback = function(value)
			AutoParry.ActiveConfig = tostring(value)
			MarkConfigDirty()
		end
	})

	local 	function RefreshConfigList()
		local newValues = CollectConfigValues(true)

		local current = AutoParry.ActiveConfig or "Autosave"
		if current ~= "Autosave" and not table.find(newValues, current) then
			current = "Autosave"
		end

		-- Rebuild the Impulse dropdown with fresh values
		pcall(function()
			RebuildVapeDropdown(configDropdown, newValues, current, function(value)
				AutoParry.ActiveConfig = tostring(value)
				MarkConfigDirty()
			end)
		end)

		if _G.UpdateAllUIElements then _G.UpdateAllUIElements() end
		ShowNotification("Config list refreshed")
	end

	vConfigGroup:AddButton({
		Text = "Refresh List",
		Func = function()
			if not HasFileIO() then
				ShowNotification("File IO not supported")
				return
			end

			RefreshConfigList()
		end
	})

	vConfigGroup:AddInput("ConfigNameInput", {
		Text = "Config Name",
		Default = "",
		Placeholder = "Config name",
		Numeric = false,
		Finished = true,
		Callback = function(value)
			AutoParry.PendingConfigName = tostring(value or "")
		end
	})

	vConfigGroup:AddButton({
		Text = "Save Config",
		Func = function()
			if not HasFileIO() then
				ShowNotification("File IO not supported")
				return
			end

			local name = SanitizeConfigName(AutoParry.PendingConfigName)
			if not name then
				name = SanitizeConfigName(AutoParry.ActiveConfig)
			end
			if not name then
				ShowNotification("Enter a config name or select one from the list")
				return
			end

			if SaveNamedConfig(name) then
				AutoParry.ActiveConfig = name
				ShowNotification("Saved config: " .. name)
				RefreshConfigList()
			else
				ShowNotification("Failed to save config")
			end
		end
	})

	vConfigGroup:AddButton({
		Text = "Load Config",
		Func = function()
			if not HasFileIO() then
				ShowNotification("File IO not supported")
				return
			end

			local name = SanitizeConfigName(AutoParry.ActiveConfig)
			if not name then
				name = SanitizeConfigName(AutoParry.PendingConfigName)
			end
			if not name then
				ShowNotification("Select a config from the list")
				return
			end

			if LoadNamedConfig(name) then
				ShowNotification("Loaded config: " .. name)
				if _G.UpdateAllUIElements then
					pcall(_G.UpdateAllUIElements)
				end
			else
				ShowNotification("Failed to load config")
			end
		end
	})

	vConfigGroup:AddButton({
		Text = "Set As Autoload",
		Func = function()
			if not HasFileIO() then
				ShowNotification("File IO not supported")
				return
			end

			local name = SanitizeConfigName(AutoParry.ActiveConfig)
			if not name then
				ShowNotification("Select a config from the list")
				return
			end

			if SetAutoloadConfig(name) then
				ShowNotification("Autoload set: " .. name)
			else
				ShowNotification("Failed to set autoload")
			end
		end
	})

	vNotifyRight = Tabs.GUI:AddRightGroupbox("Notification Position")

	vNotifyRight:AddToggle("NotificationBellToggle", {
		Text = "Notifications",
		Default = _G.HyperionBellEnabled == true,
		Callback = function(value)
			_G.HyperionBellEnabled = value == true
			MarkConfigDirty()
			NotifyToggleState("Notifications", _G.HyperionBellEnabled)
		end
	})

	vNotifyRight:AddDropdown("NotifyVerticalDropdown", {
		Text = "Vertical",
		Values = { "Center", "Top", "Bottom" },
		Default = AutoParry.NotifyVertical or "Center",
		Multi = false,
		Callback = function(value)
			AutoParry.NotifyVertical = tostring(value)
			MarkConfigDirty()
			if _G.UpdateNotificationPosition then _G.UpdateNotificationPosition() end
		end
	})

	vNotifyRight:AddDropdown("NotifyHorizontalDropdown", {
		Text = "Horizontal",
		Values = { "Center", "Left", "Right" },
		Default = AutoParry.NotifyHorizontal or "Center",
		Multi = false,
		Callback = function(value)
			AutoParry.NotifyHorizontal = tostring(value)
			MarkConfigDirty()
			if _G.UpdateNotificationPosition then _G.UpdateNotificationPosition() end
		end
	})

	NoLagGroup:AddToggle("NoRenderToggle", {
		Text = "No Lag",
		Default = AutoParry.NoRenderEnabled,
		Callback = function(value)
			AutoParry.NoRenderEnabled = value == true
			HyperionPort.SetNoRender(value)
			ApplyTextureLag()
			if value then
				InjectFFlags()
				HyperionPort.ApplyNoRenderLowGraphics()
			end
			NotifyToggleState("No Lag", AutoParry.NoRenderEnabled)
			MarkConfigDirty()
		end
	})

	function InjectFFlags()
		pcall(function() setfflag("DFIntTaskSchedulerTargetFps", "9999") end)
		pcall(function() setfflag("FFlagDebugGraphicsDisablePostEffects", "True") end)
		pcall(function() setfflag("FFlagDisableParticleEmitter", "True") end)
		pcall(function() setfflag("FFlagDebugDisableTelemetry", "True") end)
		pcall(function() setfflag("FFlagDebugDisableTelemetryV2", "True") end)
		pcall(function() setfflag("FFlagDebugDisableTelemetryEphemeral", "True") end)
		pcall(function() setfflag("FFlagDebugDisableTelemetryIngest", "True") end)
		pcall(function() setfflag("FFlagDebugDisableTelemetryWeb", "True") end)
		pcall(function() setfflag("FStringDebugSkipClientSharedMemory", "True") end)
		pcall(function() setfflag("DFIntMaxRagdollCount", "0") end)
		pcall(function() setfflag("DFIntDebugFRMQualityLevelOverride", "0") end)
		pcall(function() setfflag("FLogNetwork", "0") end)
		pcall(function() setfflag("DFFlagDebugPhysicsVisualizer", "False") end)
		pcall(function() setfflag("FFlagDebugDisableMegaReplicator", "True") end)
		pcall(function() setfflag("FFlagDebugDisableAncestorDataSharing", "True") end)
		pcall(function() setfflag("DFFlagDisableDPIScale", "True") end)
		pcall(function() setfflag("FFlagDebugDisputableRendering", "True") end)
		pcall(function() setfflag("FFlagDebugDisableUIAnims", "True") end)
		pcall(function() setfflag("FFlagDebugVisualizerDisable", "True") end)
		pcall(function() setfflag("FFlagDebugRenderingRate", "True") end)
		pcall(function() setfflag("DFFlagDebugRenderingSetQuality", "True") end)
		pcall(function() setfflag("DFFlagDebugGraphicsDisableNoise", "True") end)
		pcall(function() setfflag("DFFlagDebugGraphicsDisableSky", "True") end)
		pcall(function() setfflag("DFFlagDebugGraphicsDisableGrass", "True") end)
		pcall(function() setfflag("DFFlagDebugGraphicsDisableShadows", "True") end)
		pcall(function() setfflag("FFlagDebugDisableAnimations", "True") end)
		pcall(function() setfflag("FFlagDebugDisableSound", "True") end)
		pcall(function() setfflag("FFlagDebugDisableRemoteLogs", "True") end)
		pcall(function() setfflag("FFlagDebugLogAll", "False") end)
		pcall(function() setfflag("DFFlagDebugRakNet", "False") end)
		pcall(function() setfflag("FLogNetworkDump", "0") end)
		pcall(function() setfflag("DFFlagDisableReplicatorAll", "True") end)
		pcall(function() setfflag("DFFlagReplicatorParallel", "False") end)
		pcall(function() setfflag("FStringReplicatorConnections", "0") end)
		pcall(function() setfflag("DFIntReplicatorConnectionBandwidth", "0") end)
		pcall(function() setfflag("DFIntReplicatorMaxConnections", "0") end)
		pcall(function() setfflag("DFIntRakNetResendBufferSize", "0") end)
		pcall(function() setfflag("DFIntRakNetSendBufferSize", "0") end)
		pcall(function() setfflag("DFIntRakNetMtuSize", "0") end)
		pcall(function() setfflag("DFIntRakNetDisconnectOnPing", "99999") end)
		pcall(function() setfflag("FFlagRakNetUseTcp", "True") end)
		pcall(function() setfflag("DFFlagRakNetUseV2", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixLoadBalancing", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixConnection", "True") end)
		pcall(function() setfflag("DFIntRakNetTickTime", "1") end)
		pcall(function() setfflag("DFIntRakNetResendTickTime", "1") end)
		pcall(function() setfflag("DFIntRakNetTimeoutTickTime", "600") end)
		pcall(function() setfflag("DFIntRakNetMaxRetries", "0") end)
		pcall(function() setfflag("DFIntRakNetMaxConnections", "0") end)
		pcall(function() setfflag("DFIntRakNetUpdateInterval", "999") end)
		pcall(function() setfflag("DFIntRakNetReliabilityInterval", "999") end)
		pcall(function() setfflag("DFIntRakNetBandwidthLimit", "999999") end)
		pcall(function() setfflag("DFIntRakNetThroughputLimit", "999999") end)
		pcall(function() setfflag("DFIntRakNetThrottleLimit", "999999") end)
		pcall(function() setfflag("DFIntRakNetLatencyLimit", "0") end)
		pcall(function() setfflag("DFIntRakNetJitterLimit", "0") end)
		pcall(function() setfflag("DFIntRakNetPacketLossLimit", "0") end)
		pcall(function() setfflag("DFIntRakNetMaxOutgoingBps", "999999999") end)
		pcall(function() setfflag("DFIntRakNetMaxIncomingBps", "999999999") end)
		pcall(function() setfflag("DFIntRakNetThrottle", "999999999") end)
		pcall(function() setfflag("DFIntRakNetLagCompensation", "0") end)
		pcall(function() setfflag("DFFlagRakNetDisableLagCompensation", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisablePacketAggregation", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableFlowControl", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableCongestionControl", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableBandwidthManagement", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableLatencyManagement", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableJitterManagement", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisablePacketLoss", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableThrottling", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableAutoTuning", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableQoS", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableEncryption", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableCompression", "True") end)
		pcall(function() setfflag("DFFlagRakNetDisableMultiThreading", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixDisconnect", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixReconnect", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixTimeout", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixPing", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixPacketLoss", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixBandwidth", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixLatency", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixJitter", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixFlowControl", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixCongestion", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixThrottling", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixAutoTuning", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixQoS", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixEncryption", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixCompression", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixMultiThreading", "True") end)
		pcall(function() setfflag("DFFlagRakNetFixBwCollapse", "True") end)
		pcall(function() setfflag("DFIntWaitOnRecvFromLoopEndedMS", "100") end)
		ShowNotification("FFlags injected (FPS + Network)")
	end

	ForceRegionReady = false

	RegionCodes = {
		["None"] = "None",
		["US East"] = "USE",
		["US West"] = "USW",
		["Europe"] = "EU",
		["Singapore"] = "SG",
		["Hong Kong"] = "HK",
		["Japan"] = "JP",
		["Brazil"] = "BR",
		["Australia"] = "AU",
	}

	NoLagGroup:AddDropdown("FFlagRegionDropdown", {
		Text = "Force Region",
		Values = { "None", "US East", "US West", "Europe", "Singapore", "Hong Kong", "Japan", "Brazil", "Australia" },
		Default = AutoParry.ForceRegion,
		Multi = false,
		Callback = function(value)
			AutoParry.ForceRegion = tostring(value)
			if not ForceRegionReady then return end
			if value ~= "None" then
				local code = RegionCodes[value] or value
				pcall(function() setfflag("DFStringTeleportRegion", code) end)
				task.spawn(function()
					task.wait(0.5)
					local scriptCode = isfile and isfile("wowok.lua") and "loadstring(readfile('wowok.lua'))()" or (script and script.Source)
					if type(queue_on_teleport) == "function" then
						pcall(queue_on_teleport, scriptCode)
					end
					if type(syn) == "table" and type(syn.queue_on_teleport) == "function" then
						pcall(syn.queue_on_teleport, scriptCode)
					end
					TeleportService:Teleport(game.PlaceId, Player)
				end)
			end
			MarkConfigDirty()
		end
	})

	ForceRegionReady = true

	v438 = CreateVisualsGroupbox("Left", "Ball Trail")

	v438:AddToggle("BallTrailToggle", {
		Text = "Ball Trail",
		Default = AutoParry.BallTrailEnabled,
		Callback = function(value)
			AutoParry.BallTrailEnabled = value == true
			if not AutoParry.BallTrailEnabled then
				DestroyBallTrail()
			end
			NotifyToggleState("Ball Trail", AutoParry.BallTrailEnabled)
			MarkConfigDirty()
		end
	})

	CreateColorPicker(v438, "BallTrailColor", "BallTrailColor", "BallTrailColorR", "BallTrailColorG", "BallTrailColorB", false, UpdateBallTrail)

	v438:AddSlider("BallTrailLifetimeSlider", {
		Text = "Ball Trail Timer",
		Default = AutoParry.BallTrailLifetime,
		Min = 0.1,
		Max = 5,
		Rounding = 1,
		Callback = function(value)
			AutoParry.BallTrailLifetime = SafeToNumber(value, AutoParry.BallTrailLifetime)
			MarkConfigDirty()
		end
	})

	v438:AddSlider("BallTrailVerticalThicknessSlider", {
		Text = "Vertical Thickness",
		Default = AutoParry.BallTrailVerticalThickness,
		Min = 0.02,
		Max = 1,
		Rounding = 2,
		Callback = function(value)
			AutoParry.BallTrailVerticalThickness = SafeToNumber(value, AutoParry.BallTrailVerticalThickness)
			MarkConfigDirty()
		end
	})

	v438:AddSlider("BallTrailHorizontalThicknessSlider", {
		Text = "Horizontal Thickness",
		Default = AutoParry.BallTrailHorizontalThickness,
		Min = 0.02,
		Max = 5,
		Rounding = 2,
		Callback = function(value)
			AutoParry.BallTrailHorizontalThickness = SafeToNumber(value, AutoParry.BallTrailHorizontalThickness)
			UpdateBallTrail()
			MarkConfigDirty()
		end
	})

	vBallGlowGroup = CreateVisualsGroupbox("Left", "Ball Glow")

	vBallGlowGroup:AddToggle("BallGlowToggle", {
		Text = "Ball Glow",
		Default = AutoParry.BallGlowEnabled,
		Callback = function(value)
			AutoParry.BallGlowEnabled = value == true
			if AutoParry.BallGlowEnabled then
				if not RuntimeState.BallGlowConnection then
					RuntimeState.BallGlowConnection = RunService.Heartbeat:Connect(function()
						pcall(UpdateBallGlow)
					end)
				end
			else
				if RuntimeState.BallGlowConnection then
					RuntimeState.BallGlowConnection:Disconnect()
					RuntimeState.BallGlowConnection = nil
				end
				DestroyBallGlow()
			end
			NotifyToggleState("Ball Glow", AutoParry.BallGlowEnabled)
			MarkConfigDirty()
		end
	})

	CreateColorPicker(vBallGlowGroup, "BallGlowColor", "BallGlowColor", "BallGlowColorR", "BallGlowColorG", "BallGlowColorB", false, UpdateBallGlow)

	vBallGlowGroup:AddSlider("BallGlowHueSlider", {
		Text = "Hue",
		Default = 0,
		Min = 0,
		Max = 360,
		Rounding = 0,
		Callback = function(value)
			local hue = math.clamp(SafeToNumber(value, 0), 0, 360)
			local color = GetBallGlowColor()
			local h, s, v = Color3.toHSV(color)
			local newColor = Color3.fromHSV(hue / 360, s, v)
			AutoParry.BallGlowColorR = math.floor(newColor.R * 255)
			AutoParry.BallGlowColorG = math.floor(newColor.G * 255)
			AutoParry.BallGlowColorB = math.floor(newColor.B * 255)
			UpdateBallGlow()
			MarkConfigDirty()
		end
	})

	vBallGlowGroup:AddSlider("BallGlowSaturationSlider", {
		Text = "Saturation",
		Default = 100,
		Min = 0,
		Max = 100,
		Rounding = 0,
		Callback = function(value)
			local sat = math.clamp(SafeToNumber(value, 100), 0, 100)
			local color = GetBallGlowColor()
			local h, s, v = Color3.toHSV(color)
			local newColor = Color3.fromHSV(h, sat / 100, v)
			AutoParry.BallGlowColorR = math.floor(newColor.R * 255)
			AutoParry.BallGlowColorG = math.floor(newColor.G * 255)
			AutoParry.BallGlowColorB = math.floor(newColor.B * 255)
			UpdateBallGlow()
			MarkConfigDirty()
		end
	})

	v439 = CreateVisualsGroupbox("Right", "Character Trail")

	v439:AddToggle("CharacterTrailToggle", {
		Text = "Character Trail",
		Default = AutoParry.CharacterTrailEnabled,
		Callback = function(value)
			AutoParry.CharacterTrailEnabled = value == true
			if not AutoParry.CharacterTrailEnabled then
				DestroyCharacterTrail()
			end
			NotifyToggleState("Character Trail", AutoParry.CharacterTrailEnabled)
			MarkConfigDirty()
		end
	})

	CreateColorPicker(v439, "CharacterTrailColor", "CharacterTrailColor", "CharacterTrailColorR", "CharacterTrailColorG", "CharacterTrailColorB", false, UpdateCharacterTrail)

	v439:AddSlider("CharacterTrailLifetimeSlider", {
		Text = "Character Trail Timer",
		Default = AutoParry.CharacterTrailLifetime,
		Min = 0.1,
		Max = 5,
		Rounding = 1,
		Callback = function(value)
			AutoParry.CharacterTrailLifetime = SafeToNumber(value, AutoParry.CharacterTrailLifetime)
			MarkConfigDirty()
		end
	})

	v439:AddSlider("CharacterTrailVerticalThicknessSlider", {
		Text = "Vertical Thickness",
		Default = AutoParry.CharacterTrailVerticalThickness,
		Min = 0.02,
		Max = 5,
		Rounding = 2,
		Callback = function(value)
			AutoParry.CharacterTrailVerticalThickness = SafeToNumber(value, AutoParry.CharacterTrailVerticalThickness)
			MarkConfigDirty()
		end
	})

	v439:AddSlider("CharacterTrailHorizontalThicknessSlider", {
		Text = "Horizontal Thickness",
		Default = AutoParry.CharacterTrailHorizontalThickness,
		Min = 0.02,
		Max = 5,
		Rounding = 2,
		Callback = function(value)
			AutoParry.CharacterTrailHorizontalThickness = SafeToNumber(value, AutoParry.CharacterTrailHorizontalThickness)
			UpdateCharacterTrail()
			MarkConfigDirty()
		end
	})

	v440 = CreateVisualsGroupbox("Right", "Jump Trail")

	v440:AddToggle("JumpTrailToggle", {
		Text = "Jump Trail",
		Default = AutoParry.JumpCircleEnabled,
		Callback = function(value)
			AutoParry.JumpCircleEnabled = value == true
			NotifyToggleState("Jump Trail", AutoParry.JumpCircleEnabled)
			MarkConfigDirty()
		end
	})

	CreateColorPicker(v440, "JumpTrailColor", "JumpTrailColor", "JumpCircleColorR", "JumpCircleColorG", "JumpCircleColorB", false, UpdateJumpCircle)

	v440:AddSlider("JumpTrailLifetimeSlider", {
		Text = "Jump Trail Timer",
		Default = AutoParry.JumpCircleLifetime,
		Min = 0.1,
		Max = 3,
		Rounding = 1,
		Callback = function(value)
			AutoParry.JumpCircleLifetime = SafeToNumber(value, AutoParry.JumpCircleLifetime)
			MarkConfigDirty()
		end
	})

	v440:AddSlider("JumpTrailSizeSlider", {
		Text = "Jump Trail Size",
		Default = AutoParry.JumpCircleSize,
		Min = 1,
		Max = 20,
		Rounding = 1,
		Callback = function(value)
			AutoParry.JumpCircleSize = SafeToNumber(value, AutoParry.JumpCircleSize)
			MarkConfigDirty()
		end
	})

	v440:AddSlider("JumpTrailThicknessSlider", {
		Text = "Jump Trail Thickness",
		Default = AutoParry.JumpCircleThickness,
		Min = 0.02,
		Max = 1,
		Rounding = 2,
		Callback = function(value)
			AutoParry.JumpCircleThickness = SafeToNumber(value, AutoParry.JumpCircleThickness)
			MarkConfigDirty()
		end
	})
end

local UIKeyListener
function UpdateUIKeyListener()
	if UIKeyListener then
		UIKeyListener:Disconnect()
		UIKeyListener = nil
	end
	UIKeyListener = UserInputService.InputBegan:Connect(function(v223, HeadlessKorbloxGroup)
	if v223.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	if v223.KeyCode == AutoParry.UIKey then
		-- Toggle the Vape (Impulse) UI visibility
		RuntimeState.UIVisible = not (RuntimeState.UIVisible ~= false)
		pcall(function()
			local ui = HyperionLibrary._default and HyperionLibrary._default._ui
			if ui and ui.screen then
				ui.screen.Enabled = RuntimeState.UIVisible
			end
		end)
		return
	end

	if RuntimeState.ColorPickerOpen then
		return
	end

	if AutoParry.AutoParryKey and v223.KeyCode == AutoParry.AutoParryKey then
		ToggleAutoParry()
		return
	end

	if AutoParry.AutoSpamKey and v223.KeyCode == AutoParry.AutoSpamKey then
		ToggleAutoSpam()
		return
	end

	if AutoParry.ManualSpamEnabled and not IsMobile() and AutoParry.ManualSpamKey and v223.KeyCode == AutoParry.ManualSpamKey then
		AutoParry.ManualSpamActive = not AutoParry.ManualSpamActive
		UpdateManualSpamButtonUI()
		if AutoParry.ManualSpamNotify then
			NotifyToggleState("Manual Spam", AutoParry.ManualSpamActive)
		end

		return
	end

	if AutoParry.CurveHotkeyEnabled and AutoParry.CurveEnabled then
		local numberKeys = {
			[Enum.KeyCode.One] = 1,
			[Enum.KeyCode.Two] = 2,
			[Enum.KeyCode.Three] = 3,
			[Enum.KeyCode.Four] = 4,
			[Enum.KeyCode.Five] = 5,
			[Enum.KeyCode.Six] = 6,
		}
		local idx = numberKeys[v223.KeyCode]
		if idx then
			local names = Main.__config.__curve_names
			if idx <= #names then
				local newMode = names[idx]
				AutoParry.CurveMode = newMode
				AutoParry.CurveModeSelected = {newMode}
				NotifyToggleState("Curve: " .. newMode, true)
				MarkConfigDirty()
				return
			end
		end
	end
end)
end

UpdateUIKeyListener()

InputEndedConn = UserInputService.InputEnded:Connect(function(v223)
	if v223.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

end)

_G.AutoParryController = AutoParry

_G.SetAutoParry = function(value)
	SetAutoParryEnabled(value)
end

_G.ToggleAutoParry = function()
	ToggleAutoParry()
end

_G.GetAutoParry = function()
	return AutoParry.Enabled
end

_G.SetParryMode = function(value)
	SetAutoParryMode(value)
	ResetAllParryFlags()
	MarkConfigDirty()
	return AutoParry.Mode
end

_G.GetParryMode = function()
	return AutoParry.Mode
end

_G.SetTriggerBot = function(value)
	SetTriggerBot(value)
end

_G.ToggleTriggerBot = function()
	ToggleTriggerBot()
end

_G.GetTriggerBot = function()
	return AutoParry.TriggerBotEnabled
end

_G.GetTriggerBotActive = function()
	return IsTriggerBotActive()
end

_G.SetAutoSpam = function(value)
	SetAutoSpam(value)
end

_G.ToggleAutoSpam = function()
	ToggleAutoSpam()
end

_G.GetAutoSpam = function()
	return AutoParry.AutoSpamEnabled
end

_G.SetForceSkill = function(value)
	AutoParry.ForceSkillEnabled = value == true
	MarkConfigDirty()
end

_G.GetForceSkill = function()
	return AutoParry.ForceSkillEnabled
end

_G.GetForceSkillCooldown = function()
	return AbilityReadyAlias()
end

_G.SetAIWalk = function(value)
	SetAIWalk(value)
end

_G.ToggleAIWalk = function()
	ToggleAIWalk()
end

_G.GetAIWalk = function()
	return AutoParry.AIWalkEnabled
end

_G.PickAIWalkTarget = function()
	ClearWalkTarget()
	PickNewWalkTarget()
end

_G.SetSkinChanger = function(value, SkinName)
	AutoParry.SkinChangerEnabled = value == true
	if SkinName ~= nil then
		AutoParry.SkinName = tostring(SkinName or "")
	end
	return ApplySkinChanger()
end

_G.SetSwordChanger = _G.SetSkinChanger

_G.SetSwordName = function(SwordName)
	AutoParry.SkinName = tostring(SwordName or "")
	RefreshSwordChangerVFX()
	MarkConfigDirty()
	return ApplySkinChanger()
end

_G.SetHeadless = function(value)
	HyperionPort.SetHeadless(value)
	MarkConfigDirty()
	return AutoParry.HeadlessEnabled
end

_G.SetCharacterModifier = function(value)
	AutoParry.CharacterModifierEnabled = false
	HyperionPort.SetCharacterModifier(false)
	MarkConfigDirty()
	return false
end

_G.SetAbilityESP = function(value)
	HyperionPort.SetAbilityESP(value)
	MarkConfigDirty()
end

_G.SetBallVelocityPanel = function(value)
	AutoParry.BallVelocityEnabled = false
	HyperionPort.SetInfoPanel(false)
	MarkConfigDirty()
	return false
end

_G.SetNoRender = function(value)
	HyperionPort.SetNoRender(value)
	MarkConfigDirty()
end

_G.SetAntiLag = function(value)
	HyperionPort.SetNoRender(value)
	MarkConfigDirty()
end

_G.SetAutoParryKey = function(EnumItem)
	AutoParry.AutoParryKey = StringToKeyCode(EnumItem)
	MarkConfigDirty()
end

_G.SetAutoSpamKey = function(EnumItem)
	AutoParry.AutoSpamKey = StringToKeyCode(EnumItem)
	MarkConfigDirty()
end

_G.SetManualSpamKey = function(EnumItem)
	AutoParry.ManualSpamKey = StringToKeyCode(EnumItem)
	MarkConfigDirty()
end

_G.SetManualSpamMode = function(CurveMode)
	AutoParry.ManualSpamActive = true
	UpdateManualSpamButtonUI()
	MarkConfigDirty()
	return AutoParry.ManualSpamActive
end

_G.GetManualSpamMode = function()
	return AutoParry.ManualSpamActive and "Toggle" or "Hold"
end

_G.SetManualSpamMethod = function(OrbitGroup)
	AutoParry.ManualSpamMethod = NormalizeParryMethod(OrbitGroup)
	MarkConfigDirty()
	return AutoParry.ManualSpamMethod
end

_G.GetManualSpamMethod = function()
	return AutoParry.ManualSpamMethod
end

_G.SetManualSpamButton = function(value)
	SetManualSpamButtonEnabled(value)
	MarkConfigDirty()
end

_G.SetTriggerBotDelay = function(DelayMs)
	AutoParry.TriggerBotDelayMs = math.clamp(math.floor(tonumber(DelayMs) or 0), 0, 150)
	MarkConfigDirty()
end

_G.GetInputMode = function()
	return IsMobile() and "Mobile" or "PC"
end

_G.SetDeadzone = function(value)
	AutoParry.LowSpeedDeadzone = math.clamp(tonumber(value) or 10, 1, 10)
	AutoParry.LowSpeedParried = false
	MarkConfigDirty()
end

function RunStartupModule(ModuleName, callback)
	local ok, err = pcall(callback)
	if not ok then
		warn("[Hyperion] Startup module failed: " .. tostring(ModuleName) .. " - " .. tostring(err))
	end
end

function DisableRemovedConfigLayers()
	AutoParry.CustomImageEnabled = false
	AutoParry.PanicParryEnabled = false
	AutoParry.LowSpeedDeadzoneEnabled = true
	AutoParry.MinParryEnabled = false
	AutoParry.ManualSpamActive = false
	AutoParry.ShowStatusBar = false
	AutoParry.ShowSphere = false
	AutoParry.CharacterModifierEnabled = false
	AutoParry.BallVelocityEnabled = false
	AutoParry.SnowEnabled = false
	AutoParry.ChinaHatEnabled = false
	AutoParry.InfiniteJumpEnabled = false
	AutoParry.SpinEnabled = false
	AutoParry.WalkSpeedEnabled = false
	AutoParry.JumpPowerEnabled = false
	AutoParry.GravityEnabled = false
	AutoParry.HipHeightEnabled = false
	DestroySphereVisual()
	UpdateCharacterTrail()
	UpdateJumpCircle()
	UpdateSnow(0)
	UpdateChinaHat(0)
	DestroyCustomLogo()
	UpdateAtmosphere()
	UpdateLighting()
	UpdateSaturation()
	ClearWalkTarget()
	ResetAllParryFlags()
end

function StartupLoadHook()
	HookSkinChangerVFX()
end

function StartupLoadConfig()
	local autoload = GetAutoloadConfig()
	if autoload ~= "Autosave" then
		if LoadNamedConfig(autoload) then
			AutoParry.ActiveConfig = autoload
		else
			LoadConfig()
		end
	else
		LoadConfig()
	end
	DisableRemovedConfigLayers()
end

function StartupLoadAutoParry()
	ResetAllParryFlags()
	InitBallTracking()
	InitSpecialDetections()
end

function StartupLoadTriggerbot()
	UpdateTriggerBotButtonVisibility()
end

function StartupLoadSpam()
	AutoParry.ManualSpamActive = false
	UpdateManualSpamButtonVisibility()
	UpdateTriggerBotButtonVisibility()
end

function StartupLoadAIWalk()
	ClearWalkTarget()
end

function StartupLoadVisuals()
	ApplyUITheme()
	_G.UIKey = AutoParry.UIKey
end

function StartupLoadPlayer()
	HyperionPort.SetFOV(AutoParry.FOVEnabled)
	HyperionPort.SetCharacterModifier(false)
	HyperionPort.UpdateInfiniteJumpConnection()
	if AutoParry.CharacterModuleEnabled then
		HyperionPort.ApplyHeadlessKorbloxDescription(Player.Character)
	end
	if AutoParry.AvatarChangerEnabled then
		HyperionPort.SetAvatarChanger(true)
	end
	if AutoParry.UnlockAllSwordsEnabled then
		HyperionPort.SetUnlockAllSwords(true)
	end
end

function StartupLoadESP()
	HyperionPort.SetAbilityESP(AutoParry.AbilityESPEnabled)
	HyperionPort.SetInfoPanel(AutoParry.BallInformationEnabled)
	HyperionPort.SetNoRender(AutoParry.NoRenderEnabled)
end

function StartupLoadSkinChanger()
	ApplySkinChanger()
end

function StartupLoadUI()
    CreateUI()
end

function StartupLoadAutoSave()
	StartAutoSave()
end

EXEC_COUNT_FILE = ASSETS_FOLDER .. "/exec_count.json"
function StartupLoadExecutionLog()
	local hwid = "unknown"
	local ok, hw = pcall(gethwid)
	if ok then hwid = tostring(hw) end
	local execName = "unknown"
	local ok2, name = pcall(identifyexecutor)
	if ok2 then execName = tostring(name) end

	local ASSET_DIR = ASSETS_FOLDER
	local LOG_FILE = ASSET_DIR .. "/log.json"

	local count = 1
	local logData = {}
	if type(isfile) == "function" and isfile(LOG_FILE) then
		local ok3, data = pcall(function()
			return HttpService:JSONDecode(readfile(LOG_FILE))
		end)
		if ok3 and type(data) == "table" and data.count then
			count = data.count + 1
			logData = data
		end
	end

	logData.HWID = hwid
	logData.Executor = execName
	logData.count = count
	logData.Username = Player.Name
	logData.DisplayName = Player.DisplayName

	if type(isfolder) == "function" and not isfolder(ASSET_DIR) then
		pcall(makefolder, ASSET_DIR)
	end
	if type(writefile) == "function" then
		pcall(function()
			writefile(LOG_FILE, HttpService:JSONEncode(logData))
		end)
	end
	placeId = game.PlaceId
	jobId = game.JobId
	serverLink = "https://www.roblox.com/games/" .. placeId .. "/--?jobId=" .. jobId
	serverRegion = "Unknown"
	pcall(function()
		loc = game:GetService("TeleportService"):GetServerLocation()
		if loc then
			local name = tostring(loc):match("TeleportLocation%.(.+)") or tostring(loc)
			local RegionNames = {
				EastUS = "US East", WestUS = "US West",
				Europe = "Europe", Singapore = "Singapore",
				HongKong = "Hong Kong", Japan = "Japan",
				Brazil = "Brazil", Australia = "Australia",
				USE = "US East", USW = "US West",
				EU = "Europe", SG = "Singapore",
				HK = "Hong Kong", JP = "Japan",
				BR = "Brazil", AU = "Australia"
			}
			serverRegion = RegionNames[name] or name
		end
	end)

	payload = {
		embeds = {{
			title = "Execution Log",
			color = 16728385,
			thumbnail = {url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Player.UserId .. "&width=420&height=420&format=png"},
			fields = {
				{name = "Time", value = os.date("%Y-%m-%d %H:%M:%S"), inline = true},
				{name = "Count", value = tostring(count), inline = true},
				{name = "Username", value = "||" .. Player.Name .. " (" .. Player.DisplayName .. ")||", inline = false},
				{name = "HWID", value = hwid, inline = false},
				{name = "Executor", value = execName, inline = false},
				{name = "Game ID", value = tostring(placeId), inline = true},
				{name = "Job ID", value = "```" .. jobId .. "```", inline = false},
				{name = "Server", value = "[Join Server](" .. serverLink .. ")", inline = false},
				{name = "Region", value = serverRegion, inline = true}
			},
			footer = {text = "Hyperion"}
		}}
	}
	task.spawn(function()
		task.wait(3)
		pcall(function()
			data = game:HttpGet("https://thumbnails.roblox.com/GetCustomIcon/users/avatar-headshot?userIds=" .. Player.UserId .. "&size=420x420&format=Png&isCircular=false")
			if type(data) == "string" and data ~= "" then
				local ok2, json = pcall(HttpService.JSONDecode, HttpService, data)
				if ok2 and json and json.data and json.data[1] and json.data[1].imageUrl then
					payload.embeds[1].thumbnail.url = json.data[1].imageUrl
				end
			end
		end)
		showIp = false
		showLocation = false
		location = "Unknown"
		ip = "Unknown"
		if false then
			local okLoc, locData = pcall(function()
				return game:HttpGet("http://ip-api.com/json/?fields=query,country,city,regionName", true)
			end)
			if okLoc and locData then
				local okJson, locJson = pcall(function()
					return HttpService:JSONDecode(locData)
				end)
				if okJson and locJson then
					if locJson.query then ip = locJson.query end
					local parts = {}
					if locJson.city then table.insert(parts, locJson.city) end
					if locJson.regionName then table.insert(parts, locJson.regionName) end
					if locJson.country then table.insert(parts, locJson.country) end
					if #parts > 0 then location = table.concat(parts, ", ") end
				end
			end
		end
		if showIp then
			payload.embeds[1].fields[#payload.embeds[1].fields + 1] = {name = "IP", value = "||" .. ip .. "||", inline = false}
		end
		if showLocation then
			payload.embeds[1].fields[#payload.embeds[1].fields + 1] = {name = "Location", value = location, inline = false}
		end
		logData.IP = "removed"
		logData.Location = "removed"
		req = request or syn and syn.request or http_request
		if type(req) == "function" and Config.WebhookUrl ~= "" then
			pcall(req, {
				Url = Config.WebhookUrl,
				Method = "POST",
				Headers = {["Content-Type"] = "application/json"},
				Body = HttpService:JSONEncode(payload)
			})
		end
	end)
end

function RunStartupLoader()
	RunStartupModule("hook", StartupLoadHook)
	RunStartupModule("config", StartupLoadConfig)
	RunStartupModule("auto_parry", StartupLoadAutoParry)
	RunStartupModule("triggerbot", StartupLoadTriggerbot)
	RunStartupModule("spam", StartupLoadSpam)
	RunStartupModule("ai_walk", StartupLoadAIWalk)
	RunStartupModule("visuals", StartupLoadVisuals)
	RunStartupModule("player", StartupLoadPlayer)
	RunStartupModule("esp", StartupLoadESP)
	RunStartupModule("skin_changer", StartupLoadSkinChanger)
	RunStartupModule("exec_log", StartupLoadExecutionLog)
	RunStartupModule("ui", StartupLoadUI)
	RunStartupModule("autosave", StartupLoadAutoSave)

	InitAbilityRemoteHooks()

	task.defer(function()
		ShowNotification("Welcome, " .. Player.Name .. ".")
	end)
end

RunStartupLoader()
_startupComplete = true

task.defer(function()
	task.wait(0.5)
	ApplyAvatarChams()
end)

FetchDevUsernames()
task.spawn(function()
    HyperionPort.DevTagsActive = true
    while HyperionPort.DevTagsActive do
        HyperionPort.UpdateDevTags()
        if os.clock() - HyperionPort.DevDataLastFetch >= 30 then
            FetchDevUsernames()
        end
        task.wait(0.5)
    end
end)

HyperionPort.PreRenderPath = RunService.Heartbeat

pcall(function()
	if RunService.PreRender then
		HyperionPort.PreRenderPath = RunService.PreRender
	end
end)

task.spawn(function()
	if type(isfile) ~= "function" or type(writefile) ~= "function" then return end
	if type(makefolder) == "function" then
		pcall(function() makefolder(ASSETS_FOLDER) end)
		pcall(function() makefolder(ASSETS_FOLDER .. "/Ability") end)
	end
	for key in pairs(AbilityData) do
		local filePath = ASSETS_FOLDER .. "/Ability/" .. key .. ".png"
		if not isfile(filePath) then
			local ok, data = pcall(function()
				return game:HttpGet("https://raw.githubusercontent.com/x-l-v/BladeBallAbility/main/" .. key .. ".png")
			end)
			if ok and type(data) == "string" and #data > 100 then
				writefile(filePath, data)
			end
		end
	end
end)

SCHEDULER_HORIZON = 0.030
COMMIT_WINDOW = 0.030
COMMIT_RETRY_TIMEOUT = 0.150
PARRY_BALL_COOLDOWN = 0.500
NOT_APPROACHING_LIMIT = 3
CLOSE_RANGE_EMERGENCY_DIST = 12
ADAPTIVE_ALPHA_MIN = 0.10
ADAPTIVE_ALPHA_MAX = 0.60
ADAPTIVE_TTI_MAX = 0.50

function computeSchedulerDelay()
	dt = RuntimeState.FrameDelta or 1/60
	return 0.5 * dt + 0.017
end

function computeAdaptiveGain(tti)
	t = math.clamp(tti / ADAPTIVE_TTI_MAX, 0, 1)
	return ADAPTIVE_ALPHA_MIN + (ADAPTIVE_ALPHA_MAX - ADAPTIVE_ALPHA_MIN) * (1 - t)
end

function accuracyBuffer(accuracy)
	v = math.clamp(accuracy, 0.05, 1)
	return math.clamp(1.05 - v, 0.05, 1)
end

SchedulerState = {
	IDLE = "IDLE",
	TRACKING = "TRACKING",
	COMMITTED = "COMMITTED",
	FIRED = "FIRED",
	WAITING = "WAITING",
	READY = "READY",
	EXPIRED = "EXPIRED",
}

ScheduledParries = setmetatable({}, { __mode = "k" })
ParriedBalls = setmetatable({}, { __mode = "k" })

SchedulerEntry = {}
SchedulerEntry.__index = SchedulerEntry

function SchedulerEntry.new(ball, rawTti, rawCvel, rawPing, distance, ballPos, hrpPos, velocity, curved, speed, target, hrp, accuracy, now)
	now = now or os.clock()
	local buffer = accuracyBuffer(accuracy)
	local leadTime = buffer + (rawPing / 1000) * 1.5 + computeSchedulerDelay()
	local deadline = now + rawTti - leadTime

	local self = setmetatable({
		ball = ball,
		createdAt = now,
		state = SchedulerState.TRACKING,

		smoothedTti = rawTti,
		smoothedCvel = rawCvel,
		smoothedPing = rawPing,
		deadline = deadline,
		committed = 0,
		gain = computeAdaptiveGain(rawTti),

		rawTti = rawTti,
		rawCvel = rawCvel,
		rawPing = rawPing,
		distance = distance,
		ballPos = ballPos,
		hrpPos = hrpPos,
		curved = curved,
		speed = speed,
		target = target,

		execTime = deadline,
		timer = nil,
		scheduleTime = now,
		closingVel = rawCvel,
		interceptPos = ballPos + velocity * rawTti,
		hrpPos = hrpPos,

		fired = false,
		notApproachingFrames = 0,
		committedAt = 0,
		retryCount = 0,

	}, SchedulerEntry)

	return self
end

function SchedulerEntry:update(rawTti, rawCvel, rawPing, distance, ballPos, hrpPos, velocity, curved, speed, target, hrp, accuracy, now)
	now = now or os.clock()

	self.rawTti = rawTti
	self.rawCvel = rawCvel
	self.rawPing = rawPing
	self.distance = distance
	self.ballPos = ballPos
	self.hrpPos = hrpPos
	self.curved = curved
	self.speed = speed
	self.target = target

	self.closingVel = rawCvel
	self.execTime = self.deadline
	self.interceptPos = ballPos + velocity * rawTti

	if self.state ~= SchedulerState.TRACKING then return end

	local gain = computeAdaptiveGain(self.smoothedTti)
	self.gain = gain

	self.smoothedTti = self.smoothedTti + gain * (rawTti - self.smoothedTti)
	self.smoothedCvel = self.smoothedCvel + gain * (rawCvel - self.smoothedCvel)
	self.smoothedPing = self.smoothedPing + 0.10 * (rawPing - self.smoothedPing)

	local buffer = accuracyBuffer(accuracy)
	local leadTime = buffer + (self.smoothedPing / 1000) * 1.5 + computeSchedulerDelay()
	self.deadline = now + self.smoothedTti - leadTime
	self.execTime = self.deadline
	self.closingVel = self.smoothedCvel
	self.interceptPos = ballPos + velocity * self.smoothedTti

	if self.deadline <= now + COMMIT_WINDOW then
		self:commit(now)
	end
end

function SchedulerEntry:commit(now)
	if self.state ~= SchedulerState.TRACKING then return end
	self.committed = self.deadline
	self.committedAt = now
	self.state = SchedulerState.COMMITTED
end

function SchedulerEntry:cancel(reason)
	self.state = SchedulerState.IDLE
	ScheduledParries[self.ball] = nil
end

function SchedulerEntry:fire(now)
	now = now or os.clock()
	if self.fired then return true end
	if self.state ~= SchedulerState.COMMITTED then return false end

	self.retryCount = self.retryCount + 1
	if now - self.committedAt > COMMIT_RETRY_TIMEOUT then
		ParriedBalls[self.ball] = now
		self:cancel("retry-timeout")
		return false
	end

	local ball = self.ball
	local ok = false
	local mode = NormalizeParryMethod(AutoParry.Mode)

	if mode ~= "Keypress" then
		ok = DispatchParry(ball, ball, "AutoParry", false, false) == true
	else
		local block_btn = FindBlockButton()
		if block_btn then
			for _, conn in ipairs(getconnections(block_btn.Activated)) do
				conn:Fire()
			end
			ok = true
		end
	end

	if ok then
		self.fired = true
		self.state = SchedulerState.FIRED
		ParriedBalls[self.ball] = now
		ScheduledParries[self.ball] = nil
	end

	return ok
end

function cancelStaleEntries(hrp, hrpPos, myName)
	local specialBlocked = (AutoParry.InfinityDetectionEnabled and RuntimeState.InfinityActive)
		or (AutoParry.DeathSlashDetectionEnabled and RuntimeState.DeathSlashActive)
		or (AutoParry.TimeHoleDetectionEnabled and RuntimeState.TimeHoleActive)
		or (AutoParry.SlashesOfFuryDetectionEnabled and RuntimeState.SlashesOfFuryActive)
	local hasSingularity = hrp:FindFirstChild('SingularityCape') ~= nil

	for ball, entry in pairs(ScheduledParries) do
		if type(entry) ~= "table" or not entry.ball then
			ScheduledParries[ball] = nil
			continue
		end
		if not ball.Parent then
			entry:cancel("destroyed")
		elseif ball:GetAttribute("realBall") ~= true then
			entry:cancel("not-real-ball")
		elseif GetBallTarget(ball) ~= myName then
			entry:cancel("target-change")
		elseif not specialBlocked and not hasSingularity and not (BallCache[ball] and BallCache[ball].HasComboCounter) then
			local cache = BallCache[ball]
			local velocity = cache and cache.Velocity or GetBallVelocity(ball)
			if velocity and velocity.Magnitude > 0 then
				local dirToPlayer = (hrpPos - (cache and cache.Position or ball.Position)).Unit

				local rawCvel = velocity:Dot(dirToPlayer)
				if rawCvel < -5 then
					entry.notApproachingFrames = (entry.notApproachingFrames or 0) + 1
					if entry.notApproachingFrames >= NOT_APPROACHING_LIMIT then
						entry:cancel("not-approaching-3x")
					end
				else
					if entry.notApproachingFrames > 0 then entry.notApproachingFrames = 0 end
				end
			end
		end
	end
end

function processBallPhase2(hrpPos, myName, hrp, now, rawPing, buffer, maxDist, accuracy, specialBlocked, hasSingularity)
	local playerVel = hrp.Velocity or Vector3.zero

	for ball, cache in pairs(BallCache) do
		if not cache.Exists then continue end
		if not cache.RealBall then continue end
		if cache.Frozen then continue end
		if cache.Target ~= myName then continue end
		if cache.HasComboCounter then continue end
		if IsProjectileExecuted(ball) then continue end
		if cache.InstantCandidate then continue end

		local aero = cache.AeroVFX
		if aero and aero.Parent == ball then
			cache.AeroVFX = nil
			aero:Destroy()
			RuntimeState.TornadoTime = tick()
		end

		local velocity = cache.Velocity
		if not velocity or velocity.Magnitude < 3 then continue end

		local distance = cache.Distance
		if distance > maxDist then continue end

		local dx = hrpPos - cache.Position
		local dotV = velocity.X * dx.X + velocity.Y * dx.Y + velocity.Z * dx.Z


		local rawCvel = distance > 0.0001 and dotV / distance or 0
		if rawCvel <= 0 and distance > CLOSE_RANGE_EMERGENCY_DIST then continue end


		local compCvel = distance > 0.0001 and (dotV - (playerVel.X * dx.X + playerVel.Y * dx.Y + playerVel.Z * dx.Z)) / distance or 0
		local effectiveCvel = compCvel
		if AutoParry.AntiCurveEnabled and cache.IsCurved and compCvel > 30 and cache.Speed > 100 then
			local curvePenalty = math.min(compCvel / 400, 0.4)
			effectiveCvel = compCvel * (1 - curvePenalty)
		end
		local rawTti = distance / math.max(effectiveCvel, 0.001)
		if rawTti <= 0 then continue end

		local frameDt = RuntimeState.FrameDelta or 1/60



		if distance <= CLOSE_RANGE_EMERGENCY_DIST and rawCvel > 0 then
			DispatchParry(ball, ball, "AutoParry", true, false)
			continue
		end

		if rawTti > 2 then continue end

		local curved = cache.IsCurved
		local leadTime = buffer + (rawPing / 1000) * 1.5 + computeSchedulerDelay()
		local horizon = rawTti - leadTime

		local entry = ScheduledParries[ball]

		if entry then
			if entry.state == SchedulerState.TRACKING then
				entry:update(rawTti, compCvel, rawPing, distance, cache.Position, hrpPos, velocity, curved, cache.Speed, myName, hrp, accuracy, now)
			end
			if entry.state == SchedulerState.COMMITTED and not entry.fired and now + frameDt >= entry.committed then
				entry:fire(now)
			end
		else
			if ParriedBalls[ball] and now - ParriedBalls[ball] < PARRY_BALL_COOLDOWN then
			elseif horizon > SCHEDULER_HORIZON then
			else
				if rawTti < 0.03 then
					DispatchParry(ball, ball, "AutoParry", true, false)
					continue
				end

				local newEntry = SchedulerEntry.new(ball, rawTti, compCvel, rawPing, distance, cache.Position, hrpPos, velocity, curved, cache.Speed, myName, hrp, accuracy, now)
				ScheduledParries[ball] = newEntry

				if newEntry.deadline <= now then
					newEntry:commit(now)
					newEntry:fire(now)
				elseif newEntry.deadline <= now + frameDt then
					newEntry:commit(now)
					newEntry:fire(now)
				elseif newEntry.deadline <= now + COMMIT_WINDOW then
					newEntry:commit(now)
				end
			end
		end
	end
end

function processPhase3(now)
	for ball, entry in pairs(ScheduledParries) do
		if type(entry) ~= "table" then
			ScheduledParries[ball] = nil
			continue
		end
		if entry.state == SchedulerState.COMMITTED and not entry.fired and now >= entry.committed then
			entry:fire(now)
		end
	end
end

function schedulerHeartbeat()
	if not AutoParry.Enabled then return false end
	if AutoParry.TriggerBotEnabled and IsTriggerBotActive() then return true end
	local _, hrp = GetCharacter()
	if not hrp then return false end

	cancelStaleEntries(hrp, hrp.Position, Player.Name)

	WorkerB()

	local emergencyCandidate = RuntimeState.EmergencyCandidate
	local instantCandidate = RuntimeState.InstantCandidate

	if emergencyCandidate and emergencyCandidate.Parent then
		local cache = BallCache[emergencyCandidate]
		if cache and cache.Exists and not IsProjectileExecuted(emergencyCandidate) then
			DispatchParry(emergencyCandidate, emergencyCandidate, "AutoParry", true, false)
		end
		RuntimeState.EmergencyCandidate = nil
	end

	if instantCandidate and instantCandidate ~= emergencyCandidate and instantCandidate.Parent then
		local cache = BallCache[instantCandidate]
		if cache and cache.Exists and not IsProjectileExecuted(instantCandidate) then
			DispatchParry(instantCandidate, instantCandidate, "AutoParry", true, false)
		end
		RuntimeState.InstantCandidate = nil
	end

	local now = os.clock()
	local rawPing = GetPing() or 0
	local accuracy = math.clamp(SafeToNumber(AutoParry.Threshold, 0.5), 0.05, 0.95)
	local buffer = accuracyBuffer(accuracy)
	local maxDist = AutoParry.MaxParryDistance or 250

	local specialBlocked = (AutoParry.InfinityDetectionEnabled and RuntimeState.InfinityActive)
		or (AutoParry.DeathSlashDetectionEnabled and RuntimeState.DeathSlashActive)
		or (AutoParry.TimeHoleDetectionEnabled and RuntimeState.TimeHoleActive)
		or (AutoParry.SlashesOfFuryDetectionEnabled and RuntimeState.SlashesOfFuryActive)
	local hasSingularity = hrp:FindFirstChild('SingularityCape') ~= nil

	processBallPhase2(hrp.Position, Player.Name, hrp, now, rawPing, buffer, maxDist, accuracy, specialBlocked, hasSingularity)
	processPhase3(now)

	return true
end

function ExecuteAutoParry()
	return schedulerHeartbeat()
end

HyperionPort.AutoParryConnection = HyperionPort.PreRenderPath:Connect(function()
	local CurrentTime = os.clock()

	RuntimeState.FrameDelta = RuntimeState.LastFrameTime > 0 and (CurrentTime - RuntimeState.LastFrameTime) or 1/60
	RuntimeState.LastFrameTime = CurrentTime


	UpdateBallCache()
	RuntimeState.FrameCounter += 1
	if RuntimeState.FrameCounter % 2 == 0 then
		UpdateBallPhysicsCache()
		UpdateCandidateCache()
		UpdateBestCandidate()
		UpdateRemotePreparationCache()
	end

	local _, hrp = GetCharacter()
	local Ball = BestCandidate
	local TargetedBall = FindTargetedBall()
	if CurrentTime - RuntimeState.LastFpsClock >= 1 then
		RuntimeState.Fps = RuntimeState.FrameCounter
		RuntimeState.FrameCounter = 0
		RuntimeState.LastFpsClock = CurrentTime
	end

	if AutoParry.TickRateAware and CurrentTime - RuntimeState.LastTickCheck >= 2 then
		RuntimeState.LastTickCheck = CurrentTime
		local ping = GetPing()
		if ping > 0 then
			local estimatedTickRate = math.clamp(math.floor(1000 / ping * 3), 30, 120)
			RuntimeState.ServerTickRate = SmoothValue(RuntimeState.ServerTickRate, estimatedTickRate, 0.05, RuntimeState.FrameDelta)
		end
	end


	local ActiveFlag = false
	local ActiveFlag = false
	if not ActiveFlag and ExecuteManualSpam() then
		ActiveFlag = true
	end
	if not ActiveFlag and ExecuteForceSkill() then
		ActiveFlag = true
	end
	if not ActiveFlag and ExecuteAutoSpam() then
		ActiveFlag = true
	elseif not ActiveFlag and ExecuteAutoParry() then
		ActiveFlag = true
	end


	UpdateSkinChangerLoop()
	ExecuteAIWalk()
	UpdateSphereVisual()

	local dt = math.clamp(CurrentTime - RuntimeState.LastVisualUpdateClock, 0, 1/15)
	RuntimeState.LastVisualUpdateClock = CurrentTime
	UpdateAllVisuals(dt)
	HyperionPort.UpdateUnstableConnection()

end)

getgenv().FireParryRequest = FireParryRequest

_G.UpdateAllUIElements = function()
	pcall(function()
		if AutoParry.ViewBallEnabled then
			StartViewBall()
		else
			StopViewBall()
		end
	end)

	pcall(function()
		if AutoParry.BallGlowEnabled then
			if not RuntimeState.BallGlowConnection then
				RuntimeState.BallGlowConnection = RunService.Heartbeat:Connect(function()
					pcall(UpdateBallGlow)
				end)
			end
			UpdateBallGlow()
		else
			if RuntimeState.BallGlowConnection then
				RuntimeState.BallGlowConnection:Disconnect()
				RuntimeState.BallGlowConnection = nil
	end
		DestroyBallGlow()
	end
	end)
end

task.defer(function()
	pcall(_G.UpdateAllUIElements)
end)

getgenv().Main = Main
