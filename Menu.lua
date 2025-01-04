local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/skkydoesstuff/RobloxMenu/refs/heads/main/SplixCustom.lua"))()
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local window = library:new({textsize = 13.5, font = Enum.Font.RobotoMono, name = "YES", color = Color3.fromRGB(225, 58, 81)})

local tab = window:page({name = "YES2"})

local generalSection = tab:section({name = "General", side = "left", size = 250})
local settingsSection = tab:section({name = "Settings", side = "right", size = 250})

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local defaultJumpHeight = humanoid.JumpHeight
local speedEnabled = false
local defaultMultiplier = 0.5
local walkSpeedMultiplier = defaultMultiplier

local partFlyEnabled = false
local partFlySpeed = 10
local moveDirection = Vector3.new(0, 0, 0)

-- Create the safety part
local safetyPart = Instance.new("Part")
safetyPart.Size = Vector3.new(2, 0.5, 2)
safetyPart.Anchored = true
safetyPart.CanCollide = true
safetyPart.Transparency = 0.5
safetyPart.BrickColor = BrickColor.new("Bright blue")
safetyPart.Name = "SafetyPart"
safetyPart.Parent = workspace

-- Improved flying logic
local function updateFlyMovement(dt)
    if not partFlyEnabled then return end
    
    -- Get input for all directions
    local newMoveDirection = Vector3.new(0, 0, 0)
    
    -- Vertical movement
    if uis:IsKeyDown(Enum.KeyCode.Space) then
        newMoveDirection = newMoveDirection + Vector3.new(0, 1, 0)
    end
    if uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl) then
        newMoveDirection = newMoveDirection + Vector3.new(0, -1, 0)
    end
    
    -- Horizontal movement based on camera
    local camera = workspace.CurrentCamera
    if camera then
        if uis:IsKeyDown(Enum.KeyCode.W) or uis:IsKeyDown(Enum.KeyCode.S) or 
           uis:IsKeyDown(Enum.KeyCode.A) or uis:IsKeyDown(Enum.KeyCode.D) then
            local lookVector = camera.CFrame.LookVector
            local rightVector = camera.CFrame.RightVector
            
            if uis:IsKeyDown(Enum.KeyCode.W) then
                newMoveDirection = newMoveDirection + Vector3.new(lookVector.X, 0, lookVector.Z)
            end
            if uis:IsKeyDown(Enum.KeyCode.S) then
                newMoveDirection = newMoveDirection - Vector3.new(lookVector.X, 0, lookVector.Z)
            end
            if uis:IsKeyDown(Enum.KeyCode.A) then
                newMoveDirection = newMoveDirection - rightVector
            end
            if uis:IsKeyDown(Enum.KeyCode.D) then
                newMoveDirection = newMoveDirection + rightVector
            end
        end
    end
    
    -- Normalize and apply speed
    if newMoveDirection.Magnitude > 0 then
        newMoveDirection = newMoveDirection.Unit * partFlySpeed
    end
    
    -- Update position of both the safety part and the player
    safetyPart.Position = safetyPart.Position + (newMoveDirection * dt)
    hrp.CFrame = CFrame.new(safetyPart.Position + Vector3.new(0, 3, 0)) -- Offset to keep player above part
end

-- Toggle flying
local function startPartFly()
    safetyPart.CanCollide = true
    partFlyEnabled = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    humanoid.JumpHeight = 0
    
    -- Initialize position
    safetyPart.Position = hrp.Position - Vector3.new(0, 3, 0)
    
    -- Disable character physics
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        end
    end
end

local function stopPartFly()
    safetyPart.CanCollide = false
    partFlyEnabled = false
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    humanoid.JumpHeight = defaultJumpHeight
    
    -- Restore character physics
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
        end
    end
end

-- UI elements
generalSection:keybind({
    name = "Speed Keybind",
    def = nil,
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

generalSection:keybind({
    name = "Toggle Part Fly",
    def = nil,
    callback = function() end,
    onPressCallback = function() 
        if partFlyEnabled then
            stopPartFly()
        else
            startPartFly()
        end
    end
})

generalSection:slider({
    name = "Part Fly Speed",
    def = partFlySpeed,
    min = 0,
    max = 1000,
    callback = function(value)
        partFlySpeed = value
    end
})

settingsSection:keybind({
    name = "Toggle Menu Keybind",
    def = nil,
    callback = function(key)
        window.key = key
    end,
})

-- Main update loop
rs.Heartbeat:Connect(function(dt)
    if speedEnabled then
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (moveDirection * walkSpeedMultiplier * dt)
        end
    end
    
    if partFlyEnabled then
        updateFlyMovement(dt)
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(character)
    char = character
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    
    -- Reset flying state if it was enabled
    if partFlyEnabled then
        stopPartFly()
    end
end)