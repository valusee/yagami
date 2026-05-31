local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "yagami.cc",
    Footer = "version: 1.1",
    Icon = nil,
    NotifySide = "Right",
    DisableSearch = true,
})

local Tabs = {
    Main = Window:AddTab("Main", nil),
    Camera = Window:AddTab("Camera", nil),
    Visuals = Window:AddTab("Visuals", nil),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldindex = gmt.__index
    gmt.__index = newcclosure(function(self,b)
    if b == "FieldOfView" then
        return 70
    end
    return oldindex(self,b)
end)

local function IsEnemy(target)
    if not target or not target.Character then return false end
    local humanoid = target.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    return target:GetAttribute("Team") ~= LocalPlayer:GetAttribute("Team") or target:GetAttribute("Team") == nil
end

local function GetTarget()
    local mouse = LocalPlayer:GetMouse()
    local ray = Camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
    if result and result.Instance then
        local model = result.Instance:FindFirstAncestorWhichIsA("Model")
        if model then
            local player = Players:GetPlayerFromCharacter(model)
            if player and IsEnemy(player) then
                return true
            end
        end
    end
    return false
end

local TBconnection

local LGBAim = Tabs.Main:AddLeftGroupbox("Aim")

local TBToggle = LGBAim:AddToggle("TriggerBot", {
    Text = "Triggerbot",
    Default = false,
    Tooltip = "Shoots automatically when enemy in crosshair"
})

TBToggle:OnChanged(function(state)
    if state then
        TBconnection = RunService.RenderStepped:Connect(function()
            if GetTarget() then
                mouse1click()
            end
        end)
    else
        if TBconnection then
            TBconnection:Disconnect()
            TBconnection = nil
        end
    end
end)

local LGBCam = Tabs.Camera:AddLeftGroupbox("Camera Manipulation")

local FovSlider = LGBCam:AddSlider("FovSlider", {
    Text = "Field of View",
    Default = 70,
    Min = 30,
    Max = 120,
    Rounding = 0,
    Prefix = "FOV ",
})

local fovC

FovSlider:OnChanged(function(val)
    if fovC then fovC:Disconnect() end
    Camera.FieldOfView = val
    fovC = Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
    if Camera.FieldOfView ~= val then
        Camera.FieldOfView = val
    end
    end)
end)

local AntiFlash = LGBCam:AddToggle("AntiFlashbang", {
    Text = "Anti Flashbang",
    Default = false,
    Tooltip = "Toggles the flashbang effect."
})

AntiFlash:OnChanged(function(state)
    if state then
        LocalPlayer.PlayerScripts.PlayerBase.FlashbangEffect.Enabled = false
    else
        LocalPlayer.PlayerScripts.PlayerBase.FlashbangEffect.Enabled = true
    end
end)

local LGBEsp = Tabs.Visuals:AddLeftGroupbox("ESP")

local function addESP(char)
    if char:FindFirstChild("ESP") then char:FindFirstChild("ESP"):Destroy() end

    local function addit()
        local plr = Players:GetPlayerFromCharacter(char)
        if plr:GetAttribute("Team") == LocalPlayer:GetAttribute("Team") then return end

        local Highlight = Instance.new("Highlight")
        Highlight.Name = "ESP"
        Highlight.FillColor = Color3.fromRGB(255, 0, 255)
        Highlight.FillTransparency = 0.65
        Highlight.OutlineTransparency = 1
        Highlight.Parent = char
    end

    task.spawn(addit)
end

RefreshEsp = task.spawn(function()
    while task.wait(5) do
        for each, plr in pairs(Players:GetPlayers()) do
            local Character = plr.Character or plr.CharacterAdded:Wait()
            addESP(Character)
        end
    end
end)

local ChamsToggle = LGBEsp:AddToggle("Chams Toggle", {
    Text = "Chams",
    Default = false,
    Tooltip = "Toggles the Extrasensory Perception."
})

ChamsToggle:OnChanged(function(state)
    if state then
        RefreshEsp = task.spawn(function()
            while task.wait(5) do
                for each, plr in pairs(Players:GetPlayers()) do
                    if plr == LocalPlayer then return end
                    local Character = plr.Character or plr.CharacterAdded:Wait()
                    addESP(Character)
                end
            end
        end)
    else
        if RefreshEsp then
            RefreshEsp:Disconnect()
            RefreshEsp = nil
        end
    end
end)
