local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/skkydoesstuff/RobloxMenu/refs/heads/main/SplixCustom.lua"))()
local window = library:new({textsize = 13.5,font = Enum.Font.RobotoMono,name = "Skkys Gui",color = Color3.fromRGB(225,58,81)})

local tab = window:page({name = "General"})

local player = game.Players.LocalPlayer
local char = player.Character
local hrp = char:WaitForChild("HumanoidRootPart")
local h = char:WaitForChild("Humanoid")

local LocalPlayerSection = tab:section({name = "Local Player",side = "left",size = 250})

local defaultWalkSpeed = h.WalkSpeed
local defaultJumpHeight = h.JumpHeight

local speedToggleEnabled = false
local speedEnabled = false
local speedVal = defaultWalkSpeed

local jumpToggleEnabled = false
local jumpEnabled = false
local jumpVal = defaultJumpHeight

local noclipToggleEnabled = false
local noclipEnabled = false

local function setSpeed(val)
    h.Walkspeed = val
end

local function setJumpHeight(val)
    h.JumpHeight = val
end

LocalPlayerSection:toggle({name = "Speed",def = false,callback = function(value)
    speedToggleEnabled = value
    if not value then
        speedEnabled = false
    end
end})
:keybind({name = "speed",def = nil,callback = function(value)
    if not speedToggleEnabled then return end
    speedEnabled = value
    if speedEnabled then
        setSpeed(speedVal)
    else
        setSpeed(defaultWalkSpeed)
    end
end})

LocalPlayerSection:slider({name = "Amount", def = defaultWalkSpeed, min = defaultWalkSpeed, max = 1000, callback = function(val) 
    speedVal = val
    if speedEnabled then setSpeed(speedVal) end
end})