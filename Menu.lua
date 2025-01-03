local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/skkydoesstuff/RobloxMenu/refs/heads/main/SplixCustom.lua"))()
local rs = game:GetService("RunService")

local window = library:new({textsize = 13.5, font = Enum.Font.RobotoMono, name = "YES", color = Color3.fromRGB(225, 58, 81)})

local tab = window:page({name = "YES2"})

local generalSection = tab:section({name = "General", side = "left", size = 250})
local settingsSection = tab:section({name = "Settings", side = "right", size = 250})

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local speedEnabled = false
local defaultMultiplier = 0.5
local walkSpeedMultiplier = defaultMultiplier

local infiniteJumpEnabled = false

local userInputService = game:GetService("UserInputService")

local function handleSpeed(dt)
    local moveDirection = char.Humanoid.MoveDirection
    if moveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (moveDirection * walkSpeedMultiplier * dt)
    end
end

local function enableInfiniteJump()
    userInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function toggleInfiniteJump()
    infiniteJumpEnabled = not infiniteJumpEnabled
end

local infiniteJumpToggle = generalSection:keybind({
    name = "Toggle Infinite Jump Keybind",
    def = nil,
    callback = function() end,
    onPressCallback = function()
        toggleInfiniteJump()
    end
})

local speedToggle = generalSection:keybind({
    name = "Toggle Speed Keybind",
    def = nil,  -- Define default key if needed
    callback = function() end,
    onPressCallback = function()
        speedEnabled = not speedEnabled
    end
})

generalSection:slider({
    name = "Walk Speed",
    def = defaultMultiplier,
    min = 0,
    max = 1000,
    callback = function(value)
        walkSpeedMultiplier = value
    end
})

local MenuKeybind = settingsSection:keybind({
    name = "Toggle Menu Keybind",
    def = nil,  -- Define default key if needed
    callback = function(key)
        window.key = key
    end,
})

rs.Stepped:Connect(function(_, dt)
    if speedEnabled then
        handleSpeed(dt)
    end
end)

player.CharacterAdded:Connect(function(character)
    char = character
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    enableInfiniteJump()
end)

enableInfiniteJump()  -- Enable infinite jump for the current character
