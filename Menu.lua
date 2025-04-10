local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/skkydoesstuff/RobloxMenu/refs/heads/main/SplixCustom.lua"))()
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local window = library:new({textsize = 13.5, font = Enum.Font.RobotoMono, name = "YES", color = Color3.fromRGB(225, 58, 81)})

local tab = window:page({name = "YES2"})

local generalSection = tab:section({name = "General", side = "left", size = 250})
local settingsSection = tab:section({name = "Settings", side = "right", size = 250})

local players = game:GetService("Players")
local localPlayer = game.Players.LocalPlayer
local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local defaultJumpHeight = humanoid.JumpHeight
local speedEnabled = false
local defaultMultiplier = 0.5
local walkSpeedMultiplier = defaultMultiplier

local partFlyEnabled = false
local partFlySpeed = 10
local moveDirection = Vector3.new(0, 0, 0)
local safetyPart = nil

local espEnabled = false

local partFolder = Instance.new("Folder")
partFolder.Name = "PartFolder"
partFolder.Parent = workspace

local AimbotEnabled = false
local AimbotFOV = 100 -- radius in pixels
local AimbotKey = Enum.KeyCode.E
local AimPart = "Head" -- part to aim at

-- Create the FOV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(225, 58, 81)
fovCircle.Thickness = 1
fovCircle.Radius = AimbotFOV
fovCircle.Transparency = 0.6
fovCircle.Filled = false
fovCircle.Visible = true

local Mouse = localPlayer:GetMouse()

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimbotFOV

    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
            local part = player.Character[AimPart]
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
            
            -- make sure it's on screen and screenPos is valid
            if onScreen and screenPos then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                local distance = (mousePos - targetPos).Magnitude

                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end

        fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        fovCircle.Radius = AimbotFOV
        fovCircle.Visible = AimbotEnabled
    end

    return closestPlayer
end

local function updateFlyMovement(dt)
    if not partFlyEnabled or not safetyPart then return end
    
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
    
    -- Normalize and apply speed with smoothing
    if newMoveDirection.Magnitude > 0 then
        newMoveDirection = newMoveDirection.Unit * partFlySpeed
    end
    
    -- Update position with interpolation to prevent sudden movements
    local targetPosition = safetyPart.Position + (newMoveDirection * dt)
    safetyPart.Position = safetyPart.Position:Lerp(targetPosition, 0.5)
    
    -- Update character position with offset and orientation
    local targetCFrame = CFrame.new(safetyPart.Position + Vector3.new(0, 3, 0))
    hrp.CFrame = hrp.CFrame:Lerp(targetCFrame, 0.5)
    
    -- Prevent velocity-based flinging
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
end

local function startPartFly()
    if safetyPart then return end
    
    safetyPart = Instance.new("Part")
    safetyPart.Size = Vector3.new(2, 0.5, 2)
    safetyPart.Anchored = true
    safetyPart.CanCollide = false  -- Changed to false to prevent bouncing
    safetyPart.Transparency = 0.5
    safetyPart.BrickColor = BrickColor.new("Bright blue")
    safetyPart.Name = "SafetyPart"
    safetyPart.Parent = partFolder

    partFlyEnabled = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    humanoid.JumpHeight = 0
    
    -- Initialize position smoothly
    safetyPart.Position = hrp.Position - Vector3.new(0, 3.25, 0)
    
    -- Modified physics properties to reduce flinging
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(0.1, 0, 0, 0, 0)
        end
    end
end

local espObjects = {}

local function stopPartFly()
    if safetyPart then
        safetyPart:Destroy()
        safetyPart = nil
    end
    partFolder:ClearAllChildren()
    partFlyEnabled = false
    
    -- Smooth transition when stopping flight
    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    task.wait(0.1)
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    humanoid.JumpHeight = defaultJumpHeight
    
    -- Restore default physics properties
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
        end
    end
end

local function updateESP()
    for i, v in pairs(players:GetChildren()) do
        if v.Character and v.Character:FindFirstChild("Head") then
            if not espObjects[v] then
                -- Create the Highlight
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP"
                highlight.Parent = v.Character
                highlight.Adornee = v.Character
                highlight.FillTransparency = 0.5  -- You can adjust transparency if needed
                highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- Color of the highlight
                
                -- Create the BillboardGui
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Name = "PlayerLabel"
                billboardGui.Size = UDim2.new(0, 200, 0, 50)  -- Adjust size as needed
                billboardGui.StudsOffset = Vector3.new(0, 2, 0)  -- Adjust height above head
                billboardGui.Adornee = v.Character:WaitForChild("Head")
                billboardGui.AlwaysOnTop = true
                
                -- Create the TextLabel
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "Label"
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = v.Name  -- You can change this to display different text
                textLabel.TextColor3 = Color3.new(1, 1, 1)  -- White text
                textLabel.TextScaled = true  -- Automatically scales the text size
                textLabel.Font = Enum.Font.GothamBold
                textLabel.Parent = billboardGui
                
                -- Parent the BillboardGui to the Player's Head
                billboardGui.Parent = v.Character:WaitForChild("Head")
                
                -- Store the ESP objects to prevent recreating them
                espObjects[v] = {highlight = highlight, billboardGui = billboardGui}
            end
        end
    end
end


local function removeESP(playerToRemove)
    if playerToRemove then
        -- Remove ESP for the specific player
        local esp = espObjects[playerToRemove]
        if esp then
            -- Destroy the Highlight and BillboardGui
            if esp.highlight then
                esp.highlight:Destroy()
            end
            if esp.billboardGui then
                esp.billboardGui:Destroy()
            end
            -- Remove the player from espObjects table
            espObjects[playerToRemove] = nil
        end
    else
        -- Remove ESP for all players
        for player, esp in pairs(espObjects) do
            if esp.highlight then
                esp.highlight:Destroy()
            end
            if esp.billboardGui then
                esp.billboardGui:Destroy()
            end
            espObjects[player] = nil
        end
    end
end

-- UI elements (same as before)
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

generalSection:keybind({
    name = "Toggle ESP",
    def = nil,
    callback = function() end,
    onPressCallback = function()
        espEnabled = not espEnabled
        if not espEnabled then
            removeESP()
        end
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

    if espEnabled then
        updateESP()
    else
        removeESP()
    end
end)

-- Character respawn handling
localPlayer.CharacterAdded:Connect(function(character)
    char = character
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    
    if partFlyEnabled then
        stopPartFly()
        task.wait(0.5)  -- Wait for character to fully load
        startPartFly()
    end
end)

players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        -- Re-create ESP when player respawns
        updateESP()
    end)
end)

generalSection:keybind({
    name = "Aim Lock Keybind",
    def = nil,
    callback = function() end,
    onPressCallback = function()
        AimbotEnabled = not AimbotEnabled
    end
})

generalSection:slider({
    name = "Aim Lock FOV",
    def = 100,
    min = 0,
    max = 1000,
    callback = function(value)
        AimbotFOV = value
    end
})

generalSection:dropdown({
    name = "Aim Lock Part",
    def = "Head", -- default selected option
    max = 3, -- max visible options before scrolling
    options = {"Head", "HumanoidRootPart", "Torso"},
    callback = function(selected)
        AimPart = selected
    end
})

-- Variable to track if the right mouse button is being held
local isRightClicking = false

-- Detect when right-click is pressed or released
uis.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right click
        isRightClicking = true
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right click
        isRightClicking = false
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    -- Update FOV circle position based on mouse position
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + (AimbotFOV/2))
    fovCircle.Radius = AimbotFOV
    fovCircle.Visible = AimbotEnabled

    if AimbotEnabled and isRightClicking then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            workspace.CurrentCamera.CFrame = CFrame.new(
                workspace.CurrentCamera.CFrame.Position,
                target.Character[AimPart].Position
            )
        end
    end
end)

