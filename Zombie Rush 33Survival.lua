--[[
    ===================================================================
    BADSHAH SCRIPTS - ZOMBIE RUSH SURVIVAL
    Place ID: 82457571485380
    Theme: Signature Dark-Purple Badshah UI
    Features:
      - 👁️ ESP (Wallhack + Name + Health + Distance)
      - 🛸 Safe Float Mode (Hover in air above zombies)
      - ⚔️ Auto Farm / Kill Aura (Auto-target & Attack)
      - 🎯 Hitbox Expander (Big Zombie Head/Body)
      - ⚡ Movement (WalkSpeed Slider, Infinite Jump)
    ===================================================================
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- GUI Parent Protection
local function getGuiParent()
    local success, parent = pcall(function()
        return gethui and gethui() or CoreGui
    end)
    if success and parent then
        return parent
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Config Variables
local Config = {
    ESP = false,
    Float = false,
    FloatHeight = 12,
    AutoFarm = false,
    HitboxExpander = false,
    HitboxSize = 8,
    WalkSpeed = 16,
    InfiniteJump = false
}

local ESPObjects = {}
local FloatBodyVelocity = nil

-- ==========================================
-- 🧟 HELPER: ZOMBIE DETECTION
-- ==========================================
local function isZombie(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Head")
    
    if humanoid and rootPart and humanoid.Health > 0 then
        local nameLower = model.Name:lower()
        if nameLower:find("zombie") or nameLower:find("boss") or nameLower:find("enemy") or nameLower:find("undead") or nameLower:find("runner") or nameLower:find("tank") or not Players:FindFirstChild(model.Name) then
            return true
        end
    end
    return false
end

local function getZombies()
    local zombies = {}
    local folders = {
        Workspace:FindFirstChild("Zombies"),
        Workspace:FindFirstChild("Enemies"),
        Workspace:FindFirstChild("NPCs"),
        Workspace:FindFirstChild("Mobs"),
        Workspace:FindFirstChild("Entities"),
        Workspace
    }
    
    for _, folder in ipairs(folders) do
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if isZombie(child) and not table.find(zombies, child) then
                    table.insert(zombies, child)
                end
            end
        end
    end
    return zombies
end

local function getClosestZombie()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not root then return nil end
    
    local closest = nil
    local shortestDist = math.huge
    
    for _, zombie in ipairs(getZombies()) do
        local zHumanoid = zombie:FindFirstChildOfClass("Humanoid")
        local zRoot = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head") or zombie:FindFirstChild("Torso")
        
        if zHumanoid and zHumanoid.Health > 0 and zRoot then
            local dist = (zRoot.Position - root.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = zombie
            end
        end
    end
    return closest, shortestDist
end

-- ==========================================
-- 👁️ 1. ESP FEATURE
-- ==========================================
local function createESP(zombie)
    if ESPObjects[zombie] then return end
    
    local root = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head")
    local hum = zombie:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "BadshahESP_Highlight"
    highlight.Adornee = zombie
    highlight.FillColor = Color3.fromRGB(186, 133, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = zombie
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BadshahESP_Billboard"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = zombie
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "InfoLabel"
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextColor3 = Color3.fromRGB(186, 133, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Text = zombie.Name .. " | " .. math.floor(hum.Health) .. " HP"
    nameLabel.Parent = billboard
    
    ESPObjects[zombie] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = nameLabel
    }
end

local function removeESP(zombie)
    if ESPObjects[zombie] then
        pcall(function()
            if ESPObjects[zombie].Highlight then ESPObjects[zombie].Highlight:Destroy() end
            if ESPObjects[zombie].Billboard then ESPObjects[zombie].Billboard:Destroy() end
        end)
        ESPObjects[zombie] = nil
    end
end

local function clearAllESP()
    for zombie, _ in pairs(ESPObjects) do
        removeESP(zombie)
    end
end

RunService.RenderStepped:Connect(function()
    if Config.ESP then
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        for _, zombie in ipairs(getZombies()) do
            local hum = zombie:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not ESPObjects[zombie] then
                    createESP(zombie)
                else
                    local zRoot = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head")
                    if zRoot and myRoot and ESPObjects[zombie].Label then
                        local dist = math.floor((zRoot.Position - myRoot.Position).Magnitude)
                        ESPObjects[zombie].Label.Text = string.format("%s\n[%d HP] - %dm", zombie.Name, math.floor(hum.Health), dist)
                    end
                end
            else
                removeESP(zombie)
            end
        end
    else
        if next(ESPObjects) ~= nil then
            clearAllESP()
        end
    end
end)

-- ==========================================
-- 🛸 2. FLOAT FEATURE
-- ==========================================
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if Config.Float then
        if not FloatBodyVelocity then
            FloatBodyVelocity = Instance.new("BodyVelocity")
            FloatBodyVelocity.Name = "BadshahFloatVelocity"
            FloatBodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            FloatBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            FloatBodyVelocity.Parent = root
        end
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local rayResult = Workspace:Raycast(root.Position, Vector3.new(0, -100, 0), raycastParams)
        if rayResult then
            local targetY = rayResult.Position.Y + Config.FloatHeight
            local diff = targetY - root.Position.Y
            FloatBodyVelocity.Velocity = Vector3.new(0, diff * 6, 0)
        else
            FloatBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    else
        if FloatBodyVelocity then
            FloatBodyVelocity:Destroy()
            FloatBodyVelocity = nil
        end
    end
end)

-- ==========================================
-- ⚔️ 3. AUTO FARM LOOP
-- ==========================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.AutoFarm then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local zombie, dist = getClosestZombie()
                if zombie then
                    local zRoot = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head") or zombie:FindFirstChild("Torso")
                    local zHum = zombie:FindFirstChildOfClass("Humanoid")
                    
                    if zRoot and zHum and zHum.Health > 0 then
                        if not Config.Float then
                            root.CFrame = CFrame.new(zRoot.Position + Vector3.new(0, 9, 0), zRoot.Position)
                        end
                        
                        local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        if tool and tool.Parent == LocalPlayer.Backpack then
                            hum:EquipTool(tool)
                        end
                        
                        if tool then
                            tool:Activate()
                        end
                        
                        local head = zombie:FindFirstChild("Head") or zRoot
                        if head then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 🎯 4. HITBOX EXPANDER
-- ==========================================
RunService.RenderStepped:Connect(function()
    if Config.HitboxExpander then
        for _, zombie in ipairs(getZombies()) do
            local head = zombie:FindFirstChild("Head")
            local root = zombie:FindFirstChild("HumanoidRootPart")
            local targetPart = head or root
            
            if targetPart then
                targetPart.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                targetPart.Transparency = 0.7
                targetPart.BrickColor = BrickColor.new("Bright violet")
                targetPart.Material = Enum.Material.Neon
                targetPart.CanCollide = false
            end
        end
    end
end)

-- ==========================================
-- ⚡ 5. INFINITE JUMP
-- ==========================================
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ===================================================================
-- 🎨 BADSHAH SCRIPTS SIGNATURE DARK PURPLE UI
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BadshahUI_ZombieRush"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiParent()

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 420)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 20, 33)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 38, 62)
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

-- Dragging
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Zombie Rush Survival"
Title.TextColor3 = Color3.fromRGB(186, 133, 255)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local BtnContainer = Instance.new("Frame")
BtnContainer.Name = "BtnContainer"
BtnContainer.Size = UDim2.new(0, 56, 0, 24)
BtnContainer.Position = UDim2.new(1, -66, 0, 9)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Parent = Header

local BtnLayout = Instance.new("UIListLayout")
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
BtnLayout.Padding = UDim.new(0, 6)
BtnLayout.Parent = BtnContainer

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.BackgroundColor3 = Color3.fromRGB(36, 30, 48)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200, 190, 220)
MinBtn.TextSize = 14
MinBtn.AutoButtonColor = false
MinBtn.Parent = BtnContainer

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.BackgroundColor3 = Color3.fromRGB(36, 30, 48)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(200, 190, 220)
CloseBtn.TextSize = 15
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = BtnContainer

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Scroll List Container
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, -24, 1, -80)
ContentScroll.Position = UDim2.new(0, 12, 0, 44)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 58, 92)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = ContentScroll

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 2)
ContentPadding.PaddingBottom = UDim.new(0, 6)
ContentPadding.Parent = ContentScroll

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 30)
Footer.Position = UDim2.new(0, 0, 1, -30)
Footer.BackgroundTransparency = 1
Footer.Font = Enum.Font.GothamBold
Footer.Text = "Created By: Badshah Scripts"
Footer.TextColor3 = Color3.fromRGB(186, 133, 255)
Footer.TextSize = 12
Footer.Parent = MainFrame

-- Minimize & Close
local minimized = false
local originalSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, originalSize.X.Offset, 0, 42)
        }):Play()
        ContentScroll.Visible = false
        Footer.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = originalSize
        }):Play()
        task.delay(0.1, function()
            ContentScroll.Visible = true
            Footer.Visible = true
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = MainFrame.Position + UDim2.new(0, MainFrame.AbsoluteSize.X/2, 0, MainFrame.AbsoluteSize.Y/2)
    }):Play()
    task.wait(0.25)
    clearAllESP()
    ScreenGui:Destroy()
end)

-- ==========================================
-- UI CONTROLS GENERATOR
-- ==========================================
local function AddToggle(name, default, callback)
    local state = default or false
    callback = callback or function() end

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "_Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 48)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(36, 30, 48)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ContentScroll

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleFrame

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(1, -56, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 14, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Font = Enum.Font.GothamMedium
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(225, 220, 235)
    ToggleLabel.TextSize = 13.5
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local Box = Instance.new("Frame")
    Box.Name = "Box"
    Box.Size = UDim2.new(0, 22, 0, 22)
    Box.Position = UDim2.new(1, -36, 0.5, -11)
    Box.BackgroundColor3 = state and Color3.fromRGB(186, 133, 255) or Color3.fromRGB(28, 23, 38)
    Box.BorderSizePixel = 0
    Box.Parent = ToggleFrame

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = Box

    local Checkmark = Instance.new("TextLabel")
    Checkmark.Name = "Checkmark"
    Checkmark.Size = UDim2.new(1, 0, 1, 0)
    Checkmark.BackgroundTransparency = 1
    Checkmark.Font = Enum.Font.GothamBold
    Checkmark.Text = "✓"
    Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
    Checkmark.TextSize = 13
    Checkmark.TextTransparency = state and 0 or 1
    Checkmark.Parent = Box

    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""
    ClickBtn.Parent = ToggleFrame

    local function update(newState)
        state = newState
        local targetBg = state and Color3.fromRGB(186, 133, 255) or Color3.fromRGB(28, 23, 38)
        local targetTrans = state and 0 or 1
        TweenService:Create(Box, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = targetBg}):Play()
        TweenService:Create(Checkmark, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {TextTransparency = targetTrans}):Play()
        callback(state)
    end

    ClickBtn.MouseButton1Click:Connect(function()
        update(not state)
    end)
end

local function AddSlider(name, min, max, default, callback)
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)
    callback = callback or function() end
    local value = default

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name .. "_Slider"
    SliderFrame.Size = UDim2.new(1, 0, 0, 58)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(36, 30, 48)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = ContentScroll

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 10)
    SliderCorner.Parent = SliderFrame

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "Label"
    SliderLabel.Size = UDim2.new(1, -60, 0, 24)
    SliderLabel.Position = UDim2.new(0, 14, 0, 8)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Font = Enum.Font.GothamMedium
    SliderLabel.Text = name
    SliderLabel.TextColor3 = Color3.fromRGB(225, 220, 235)
    SliderLabel.TextSize = 13.5
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Name = "Value"
    ValueLabel.Size = UDim2.new(0, 50, 0, 24)
    ValueLabel.Position = UDim2.new(1, -64, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = tostring(value)
    ValueLabel.TextColor3 = Color3.fromRGB(186, 133, 255)
    ValueLabel.TextSize = 13.5
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame

    local Track = Instance.new("Frame")
    Track.Name = "Track"
    Track.Size = UDim2.new(1, -28, 0, 4)
    Track.Position = UDim2.new(0, 14, 0, 40)
    Track.BackgroundColor3 = Color3.fromRGB(25, 20, 34)
    Track.BorderSizePixel = 0
    Track.Parent = SliderFrame

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    local initialPercent = (default - min) / (max - min)
    Fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(186, 133, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local sliding = false
    local function updateSlider(input)
        local trackAbsPos = Track.AbsolutePosition.X
        local trackAbsSize = Track.AbsoluteSize.X
        local mousePos = input.Position.X
        local percent = math.clamp((mousePos - trackAbsPos) / trackAbsSize, 0, 1)
        value = math.floor(min + (max - min) * percent)
        ValueLabel.Text = tostring(value)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Knob.Position = UDim2.new(percent, 0, 0.5, 0)
        callback(value)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
end

-- ==========================================
-- 🚀 REGISTER UI ELEMENTS
-- ==========================================
AddToggle("Zombie ESP (Wallhack)", false, function(state)
    Config.ESP = state
end)

AddToggle("Auto Farm (Kill Nearest)", false, function(state)
    Config.AutoFarm = state
end)

AddToggle("Safe Float Mode", false, function(state)
    Config.Float = state
    if not state and FloatBodyVelocity then
        FloatBodyVelocity:Destroy()
        FloatBodyVelocity = nil
    end
end)

AddSlider("Float Height", 5, 25, 12, function(val)
    Config.FloatHeight = val
end)

AddToggle("Hitbox Expander", false, function(state)
    Config.HitboxExpander = state
end)

AddSlider("Hitbox Size", 3, 20, 8, function(val)
    Config.HitboxSize = val
end)

AddToggle("Infinite Jump", false, function(state)
    Config.InfiniteJump = state
end)

AddSlider("WalkSpeed", 16, 120, 16, function(val)
    Config.WalkSpeed = val
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = val
    end
end)
