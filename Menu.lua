local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/skkydoesstuff/RobloxMenu/refs/heads/main/SplixCustom.lua"))()
local rs = game:GetService("RunService")

local window = library:new({textsize = 13.5, font = Enum.Font.RobotoMono, name = "YES", color = Color3.fromRGB(225, 58, 81)})

local tab = window:page({name = "YES2"})

local generalSection = tab:section({name = "General", side = "left", size = 250})
local settingsSection = tab:section({name = "Settings", side = "right", size = 250})

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local h = char:WaitForChild("Humanoid")

local speedEnabled = false
local defaultMultiplier = 0.5
local walkSpeedMultiplier = defaultMultiplier

local function handleSpeed(dt)
    if speedEnabled then
        local moveDirection = char.Humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (moveDirection * walkSpeedMultiplier * dt)
        end
    end
end

local speedToggle = generalSection:keybind({name = "Toggle Speed Keybind", def = nil, callback = function(value)
        speedEnabled = value
    end,

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

-- Main function

rs.Stepped:Connect(function(_, dt)
    handleSpeed(dt)
end)

-- Set player variables

player.CharacterAdded:Connect(function(character)
    char = character
    hrp = char:WaitForChild("HumanoidRootPart")
    h = char:WaitForChild("Humanoid")
end)
