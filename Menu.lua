local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/skkydoesstuff/RobloxMenu/refs/heads/main/SplixCustom.lua"))()
local window = library:new({textsize = 13.5,font = Enum.Font.RobotoMono,name = "YES",color = Color3.fromRGB(225,58,81)})
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
local speed = defaultWalkSpeed

local jumpToggleEnabled = false
local jumpEnabled = false
local jumpHeight = defaultJumpHeight

local noclipToggleEnabled = false
local noclipEnabled = false

LocalPlayerSection:toggle({name = "Speed",def = false,callback = function(value)

end})

