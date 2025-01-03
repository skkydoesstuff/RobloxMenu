local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/matas3535/PoopLibrary/main/Library.lua"))()

local window = Library:New({Name = "Skkys GUI", Accent = Color3.fromRGB(25, 240, 100)})

local mainPage = window:Page({Name = "General"})
local settingsPage = window:Page({Name = "Settings"})

local mainSection = mainPage:Section({Name = "Main", Side = "Left"})

local generalSpeed, generalJump, generalNoclip = mainPage:MultiSection({Sections = {"Speed", "Jump", "Noclip"}, Side = "Left", Size = 200})
local settingsMain = settingsPage:Section({Name = "Main", Side = "Left"})
local player = game.Players.LocalPlayer
local char, humanoid, hrp

-- Update references for character and humanoid
local function updateCharacterReferences()
    char = player.Character or player.CharacterAdded:Wait()
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(updateCharacterReferences)
updateCharacterReferences()

-- Functions to set speed and jump power
local function setSpeed(amount)
    if humanoid then
        humanoid.WalkSpeed = amount
    end
end

local function setJump(amount)
    if humanoid then
        humanoid.JumpHeight = amount
    end
end

local function noclip()
    if char then
        for i,v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end

local function clip()
    if char then
        for i,v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
end

-- Speed Settings
local speedToggled = false
local speedEnabled = false
local speed = nil

generalSpeed:Toggle({
    Name = "Enabled",
    Default = false,
    Pointer = "Speed_Enabled",
    Callback = function(bool)
        speedEnabled = bool
        if bool == false then
            speedToggled = false
            setSpeed(16)
        end
    end
})

:Keybind({
    Default = Enum.KeyCode.X,
    Name = "Speed",
    Mode = "Toggle",
    Pointer = "Speed_Bind",
    Callback = function()
        if not speedEnabled then return end
        speedToggled = not speedToggled
        if speedToggled then
            setSpeed(speed or 16) -- Default to 16 if speed is nil
        else
            setSpeed(16) -- Reset to default speed
        end
    end
})

generalSpeed:Slider({
    Name = "Amount",
    Minimum = 1,
    Maximum = 1000,
    Default = 16,
    Decimals = 0.1,
    Pointer = "Speed_Amount",
    Callback = function(num)
        speed = num
        if speedToggled then setSpeed(speed) end
    end
})

-- Jump Settings
local jumpToggled = false
local jumpEnabled = false
local jump = nil
local originalJumpPower = humanoid and humanoid.JumpPower or 50 -- Store the default jump power

generalJump:Toggle({
    Name = "Enabled",
    Default = false,
    Pointer = "Jump_Enabled",
    Callback = function(bool)
        jumpEnabled = bool
        if bool == false then
            jumpToggled = false
            setJump(7.2)
        end
    end
})

:Keybind({
    Default = Enum.KeyCode.X,
    Name = "Jump",
    Mode = "Toggle",
    Pointer = "Jump_Bind",
    Callback = function()
        if not jumpEnabled then return end
        jumpToggled = not jumpToggled
        if jumpToggled then
            setJump(jump or originalJumpPower) -- Use slider value or original
        else
            setJump(originalJumpPower) -- Reset to original jump power
        end
    end
})

generalJump:Slider({
    Name = "Amount",
    Minimum = 1,
    Maximum = 1000,
    Default = 50, -- Set a reasonable default
    Decimals = 0.1,
    Pointer = "Jump_Amount",
    Callback = function(num)
        jump = num
        if jumpToggled then setJump(jump) end
    end
})

-- noclip

local noclipEnabled = false
local noclipToggled = false

generalNoclip:Toggle({
    Name = "Enabled",
    Default = false,
    Pointer = "Noclip_Enabled",
    Callback = function(bool)
        noclipEnabled = bool
        if not bool then noclipToggled = false end
    end
})

:Keybind({
    Default = Enum.KeyCode.X,
    Name = "Noclip",
    Mode = "Toggle",
    Pointer = "Noclip_Bind",
    Callback = function()
        if noclipEnabled then
            noclipToggled = not noclipToggled
            if noclipToggled then
                noclip()
            else
                clip()
            end
        end
    end
})

print(window.keybindslist:Visibility())

window:Initialize()

player.CharacterRemoving:Connect(function()
    speedToggled = false
    jumpToggled = false
end)