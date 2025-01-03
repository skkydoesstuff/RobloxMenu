local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/skkydoesstuff/RobloxMenu/refs/heads/main/SplixCustom.lua"))()
local window = library:new({textsize = 13.5,font = Enum.Font.RobotoMono,name = "Skkys Gui",color = Color3.fromRGB(225,58,81), size = Vector2.new(600, 1000)})

task.wait(0.1) -- Wait for UI to initialize
if window.outline then
    window.outline.Size = UDim2.new(0, 600, 0, 1000)
    
    -- Also resize the inner frames to match
    if window.outline2 then
        window.outline2.Size = UDim2.new(1, -4, 1, -4)
    end
    
    -- Adjust other container frames
    if window.tabs then
        window.tabs.Size = UDim2.new(1, 0, 1, -20)
    end
end

local tab = window:page({name = "General"})

local player = game.Players.LocalPlayer
local char = player.Character
local hrp = char:WaitForChild("HumanoidRootPart")
local h = char:WaitForChild("Humanoid")

local LocalPlayerSection = tab:section({name = "Local Player",side = "left",size = 250})
local LocalPlayerSection2 = tab:section({name = "Local Player2",side = "left",size = 250})
local LocalPlayerSection3 = tab:section({name = "Local Player3",side = "left",size = 250})

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

