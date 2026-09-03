--[[
    Impulse UI Framework - Demo / Example Usage
    Run this in a Roblox executor to see the UI in action.
]]

local Impulse

-- Load from URL
if game and game.HttpGet then
    local url = "https://raw.githubusercontent.com/thecoolersyn/vapev4clientnew/refs/heads/main/src.lua"
    local ok, content = pcall(game.HttpGet, game, url)
    if ok and content then
        local fn, err = loadstring(content)
        if fn then
            local ok2, result = pcall(fn)
            if ok2 and result then
                Impulse = result
            else
                warn("[Impulse] Module execution failed:", tostring(result))
            end
        else
            warn("[Impulse] Compile error:", tostring(err))
        end
    else
        warn("[Impulse] Failed to download from URL")
    end
else
    warn("[Impulse] game.HttpGet not available")
end

if not Impulse then
    error("Impulse framework not found")
end

-------------------------------------------------------------------------------
-- Create Categories (Module Tabs)
-------------------------------------------------------------------------------
local Combat = Impulse.CreateModule("Combat", {
    Icon = "Swords",
    Order = 1
})

local Render = Impulse.CreateModule("Render", {
    Icon = "Eye",
    Order = 2
})

local Utility = Impulse.CreateModule("Utility", {
    Icon = "Zap",
    Order = 3
})

local World = Impulse.CreateModule("World", {
    Icon = "Box",
    Order = 4
})

local Blatant = Impulse.CreateModule("Blatant", {
    Icon = "Target",
    Order = 5
})

-------------------------------------------------------------------------------
-- Combat Modules
-------------------------------------------------------------------------------
local AutoParry = Combat:Add("Auto Parry", {
    Description = "Automatically parries incoming attacks.",
    Default = false,
    Favorite = true
})

AutoParry:AddToggle("Enabled", {
    Default = false,
    Callback = function(value)
        print("Auto Parry enabled:", value)
    end
})

AutoParry:AddToggle("Perfect Parry", {
    Default = false,
    Callback = function(value)
        print("Perfect Parry:", value)
    end
})

AutoParry:AddSlider("Range", {
    Min = 1,
    Max = 100,
    Default = 25,
    Decimals = 1,
    Callback = function(value)
        print("Range:", value)
    end
})

AutoParry:AddDropdown("Mode", {
    Options = {"Closest", "Smart", "All"},
    Default = "Smart",
    Callback = function(value)
        print("Mode:", value)
    end
})

AutoParry:AddKeybind("Keybind", {
    Default = Enum.KeyCode.V
})

local Triggerbot = Combat:Add("Triggerbot", {
    Description = "Automatically fires when aiming at enemies."
})

Triggerbot:AddToggle("Enabled", { Default = false })
Triggerbot:AddSlider("FOV", { Min = 0, Max = 1000, Default = 200, Decimals = 0 })
Triggerbot:AddDropdown("Target", {"Head", "Torso", "Random"}, "Head")
Triggerbot:AddToggle("Team Check", { Default = true })

local KillAura = Combat:Add("Kill Aura", {
    Description = "Automatically attacks nearby players."
})

KillAura:AddToggle("Enabled", { Default = false })
KillAura:AddSlider("Range", { Min = 5, Max = 50, Default = 15, Decimals = 0 })
KillAura:AddSlider("APS", { Min = 1, Max = 20, Default = 10, Decimals = 0 })
KillAura:AddToggle("Silent Aim", { Default = false })
KillAura:AddMultiDropdown("Weapons", {
    Options = {"Sword", "Gun", "Bow", "Fists"},
    Default = {"Sword"}
})

-------------------------------------------------------------------------------
-- Render Modules
-------------------------------------------------------------------------------
local ESP = Render:Add("ESP", {
    Description = "Shows player outlines through walls."
})

ESP:AddToggle("Enabled", { Default = false })
ESP:AddColorPicker("Color", { Default = Color3.fromRGB(100, 220, 160) })
ESP:AddSlider("Thickness", { Min = 1, Max = 5, Default = 2, Decimals = 0 })
ESP:AddDropdown("Style", {"Outline", "Fill", "Glow"}, "Outline")
ESP:AddToggle("Show Health", { Default = true })
ESP:AddToggle("Show Distance", { Default = true })

local Tracers = Render:Add("Tracers", {
    Description = "Draws lines to nearby players."
})

Tracers:AddToggle("Enabled", { Default = false })
Tracers:AddColorPicker("Color", { Default = Color3.fromRGB(255, 255, 255) })
Tracers:AddDropdown("Origin", {"Top", "Middle", "Bottom"}, "Bottom")
Tracers:AddSlider("Thickness", { Min = 1, Max = 3, Default = 1, Decimals = 0 })

local Chams = Render:Add("Chams", {
    Description = "Applies material overrides to characters."
})

Chams:AddToggle("Enabled", { Default = false })
Chams:AddDropdown("Material", {"ForceField", "Neon", "Glass", "SmoothPlastic"}, "ForceField")
Chams:AddColorPicker("Color", { Default = Color3.fromRGB(255, 100, 100) })
Chams:AddSlider("Transparency", { Min = 0, Max = 1, Default = 0, Decimals = 2 })

-------------------------------------------------------------------------------
-- Utility Modules
-------------------------------------------------------------------------------
local Sprint = Utility:Add("Sprint", {
    Description = "Hold to sprint faster."
})

Sprint:AddToggle("Enabled", { Default = false })
Sprint:AddSlider("Speed", { Min = 16, Max = 50, Default = 24, Decimals = 0 })
Sprint:AddKeybind("Keybind", { Default = Enum.KeyCode.LeftShift })

local AutoClicker = Utility:Add("AutoClicker", {
    Description = "Automatically clicks under configured conditions."
})

AutoClicker:AddToggle("Enabled", { Default = false })
AutoClicker:AddDropdown("Trigger mode", {"Hold to click", "Always", "Toggle"}, "Hold to click")
AutoClicker:AddToggle("Break blocks", { Default = true })
AutoClicker:AddSlider("Break blocks delay", { Min = 0, Max = 20, Default = 10, Decimals = 0 })
AutoClicker:AddToggle("Break blocks whitelist", { Default = false })
AutoClicker:AddSlider("CPS", { Min = 1, Max = 20, Default = 13.7, Decimals = 1 })
AutoClicker:AddDropdown("Randomization", {"None", "Basic", "Extra", "Extra+"}, "Extra+")
AutoClicker:AddToggle("Jitter", { Default = false })
AutoClicker:AddToggle("Limit items", { Default = false })

-------------------------------------------------------------------------------
-- World Modules
-------------------------------------------------------------------------------
local Scaffold = World:Add("Scaffold", {
    Description = "Automatically places blocks below you."
})

Scaffold:AddToggle("Enabled", { Default = false })
Scaffold:AddSlider("Blocks/s", { Min = 1, Max = 20, Default = 10, Decimals = 0 })
Scaffold:AddToggle("Tower", { Default = false })
Scaffold:AddDropdown("Block", {"Obsidian", "Endstone", "Netherite"}, "Obsidian")

-------------------------------------------------------------------------------
-- Blatant Modules
-------------------------------------------------------------------------------
local Fly = Blatant:Add("Fly", {
    Description = "Allows you to fly."
})

Fly:AddToggle("Enabled", { Default = false })
Fly:AddSlider("Speed", { Min = 1, Max = 100, Default = 50, Decimals = 0 })
Fly:AddDropdown("Mode", {"Vanilla", "Glide", "Boost"}, "Vanilla")
Fly:AddToggle("Anti-Kick", { Default = true })

local Speed = Blatant:Add("Speed", {
    Description = "Move faster than normal."
})

Speed:AddToggle("Enabled", { Default = false })
Speed:AddSlider("Multiplier", { Min = 1, Max = 10, Default = 2, Decimals = 1 })
Speed:AddDropdown("Mode", {"Velocity", "CFrame"}, "Velocity")

-------------------------------------------------------------------------------
-- Module Callbacks
-------------------------------------------------------------------------------
AutoParry:OnToggle(function(enabled)
    print("[Callback] Auto Parry toggled:", enabled)
end)

-------------------------------------------------------------------------------
-- Create the Window
-------------------------------------------------------------------------------
Impulse.CreateWindow({
    Name = "Impulse"
})

-------------------------------------------------------------------------------
-- Create some default configs
-------------------------------------------------------------------------------
local Config = Impulse.GetConfig()
if not Config:Exists("Default") then
    Config:Create("Default")
end
if not Config:Exists("Legit") then
    Config:Create("Legit")
end
if not Config:Exists("Blatant") then
    Config:Create("Blatant")
end

print("Impulse UI Framework loaded successfully!")
print("Categories:", #Impulse.GetCategories())
print("Modules:", #Impulse.GetModules())
