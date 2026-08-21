-- =================================================================
-- CONFIGURATION: Slap to Survive Script (Badshah Mobile UI)
-- =================================================================
local GameName = "Slap to Survive"
local CreatorName = "Badshah Scripts"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Global Feature State Flags
_G.AutoSlapActive = false
_G.SafeSpotActive = false
_G.AutoUpgradeActive = false
_G.FloatActive = false
_G.FloatHeight = 10

-- Prevent duplicate UI
if CoreGui:FindFirstChild("RobloxScriptUI_Badshah") then
    CoreGui.RobloxScriptUI_Badshah:Destroy()
end
if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("RobloxScriptUI_Badshah") then
    LocalPlayer.PlayerGui.RobloxScriptUI_Badshah:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RobloxScriptUI_Badshah"
ScreenGui.ResetOnSpawn = false

local success, _ = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- UI Feature List Definition (Toggles & Sliders)
local Features = {
    {
        Type = "Toggle",
        Name = "Auto Slap",
        Default = false,
        Callback = function(state)
            _G.AutoSlapActive = state
            print("[Slap to Survive] Auto Slap set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Safe Spot Teleport",
        Default = false,
        Callback = function(state)
            _G.SafeSpotActive = state
            print("[Slap to Survive] Safe Spot Teleport set to:", state)
            
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if state and root then
                    -- Save return position
                    _G.SavedSafeSpotReturnCFrame = root.CFrame
                    
                    -- Create client safe floating platform if not exists
                    local platform = workspace:FindFirstChild("Badshah_SafePlatform")
                    if not platform then
                        platform = Instance.new("Part")
                        platform.Name = "Badshah_SafePlatform"
                        platform.Size = Vector3.new(16, 2, 16)
                        platform.Anchored = true
                        platform.CanCollide = true
                        platform.Material = Enum.Material.Neon
                        platform.Color = Color3.fromRGB(168, 85, 247)
                        platform.Transparency = 0.5
                        platform.Position = Vector3.new(root.Position.X, root.Position.Y + 45, root.Position.Z)
                        platform.Parent = workspace
                    end
                    root.CFrame = platform.CFrame + Vector3.new(0, 4, 0)
                else
                    -- Restore position and clean platform
                    local platform = workspace:FindFirstChild("Badshah_SafePlatform")
                    if platform then
                        platform:Destroy()
                    end
                    if _G.SavedSafeSpotReturnCFrame and root then
                        root.CFrame = _G.SavedSafeSpotReturnCFrame
                    end
                end
            end)
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Upgrade",
        Default = false,
        Callback = function(state)
            _G.AutoUpgradeActive = state
            print("[Slap to Survive] Auto Upgrade (Tools & Stats) set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Float",
        Default = false,
        Callback = function(state)
            _G.FloatActive = state
            print("[Slap to Survive] Float set to:", state)
            
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart")
            if state and root then
                task.spawn(function()
                    local initialY = root.Position.Y
                    while _G.FloatActive do
                        task.wait()
                        if char and root then
                            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                            root.CFrame = CFrame.new(root.Position.X, initialY + (_G.FloatHeight or 10), root.Position.Z)
                        end
                    end
                end)
            end
        end
    },
    {
        Type = "Slider",
        Name = "Float Height",
        Min = 0,
        Max = 50,
        Default = 10,
        Callback = function(value)
            _G.FloatHeight = value
        end
    }
}

-- Calculate Window Height dynamically
local totalContentHeight = 0
for _, feature in ipairs(Features) do
    if feature.Type == "Slider" then
        totalContentHeight = totalContentHeight + 46 + 6
    else
        totalContentHeight = totalContentHeight + 35 + 6
    end
end
if totalContentHeight > 0 then
    totalContentHeight = totalContentHeight - 6
end

local maxContainerHeight = 180
local containerHeight = totalContentHeight
local scrollEnabled = false

if totalContentHeight > maxContainerHeight then
    containerHeight = maxContainerHeight
    scrollEnabled = true
end

local windowHeight = 42 + containerHeight + 16 + 25 -- Header + Container + Padding + Footer

-- Main Window (220px width - Mobile Optimized)
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 220, 0, windowHeight)
MainWindow.Position = UDim2.new(0.5, -110, 0.5, -windowHeight/2)
MainWindow.BackgroundColor3 = Color3.fromRGB(15, 14, 22)
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Active = true
MainWindow.Parent = ScreenGui

local MainWindowCorner = Instance.new("UICorner")
MainWindowCorner.CornerRadius = UDim.new(0, 12)
MainWindowCorner.Parent = MainWindow

local MainWindowStroke = Instance.new("UIStroke")
MainWindowStroke.Thickness = 1
MainWindowStroke.Color = Color3.fromRGB(30, 28, 42)
MainWindowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainWindowStroke.Parent = MainWindow

-- Header Frame (42px)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1
Header.Parent = MainWindow

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -65, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = GameName
TitleLabel.TextColor3 = Color3.fromRGB(191, 127, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
TitleLabel.Parent = Header

-- Minimize Button (20x20)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "Minimize"
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -48, 0.5, -10)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.AutoButtonColor = false
MinimizeButton.Text = ""
MinimizeButton.Parent = Header

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeButton

local MinimizeText = Instance.new("TextLabel")
MinimizeText.Size = UDim2.new(1, 0, 1, 0)
MinimizeText.BackgroundTransparency = 1
MinimizeText.Text = "-"
MinimizeText.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeText.Font = Enum.Font.GothamBold
MinimizeText.TextSize = 13
MinimizeText.TextXAlignment = Enum.TextXAlignment.Center
MinimizeText.TextYAlignment = Enum.TextYAlignment.Center
MinimizeText.Parent = MinimizeButton

-- Close Button (20x20 - Coral/Red Accent)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -24, 0.5, -10)
CloseButton.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseButton.BorderSizePixel = 0
CloseButton.AutoButtonColor = false
CloseButton.Text = ""
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local CloseText = Instance.new("TextLabel")
CloseText.Size = UDim2.new(1, 0, 1, 0)
CloseText.BackgroundTransparency = 1
CloseText.Text = "X"
CloseText.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseText.Font = Enum.Font.GothamBold
CloseText.TextSize = 12
CloseText.TextXAlignment = Enum.TextXAlignment.Center
CloseText.TextYAlignment = Enum.TextYAlignment.Center
CloseText.Parent = CloseButton

-- Divider Line
local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(1, -20, 0, 1)
Divider.Position = UDim2.new(0, 10, 0, 41)
Divider.BackgroundColor3 = Color3.fromRGB(30, 28, 42)
Divider.BorderSizePixel = 0
Divider.Parent = MainWindow

-- Content Container
local ContentContainer
if scrollEnabled then
    ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.ScrollBarThickness = 2
    ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, totalContentHeight)
else
    ContentContainer = Instance.new("Frame")
end

ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -16, 0, containerHeight)
ContentContainer.Position = UDim2.new(0, 8, 0, 48)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainWindow

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 6)
Layout.Parent = ContentContainer

-- Footer Frame (25px)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundTransparency = 1
Footer.Parent = MainWindow

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 1, 0)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "Created By: Badshah Scripts"
FooterLabel.TextColor3 = Color3.fromRGB(191, 127, 255)
FooterLabel.Font = Enum.Font.GothamBold
FooterLabel.TextSize = 10
FooterLabel.TextXAlignment = Enum.TextXAlignment.Center
FooterLabel.TextYAlignment = Enum.TextYAlignment.Center
FooterLabel.Parent = Footer

-- Construct Feature Cards (Toggles & Sliders)
for i, feature in ipairs(Features) do
    if feature.Type == "Toggle" then
        local Card = Instance.new("TextButton")
        Card.Name = "Card_" .. feature.Name
        Card.Size = UDim2.new(1, 0, 0, 35)
        Card.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
        Card.BorderSizePixel = 0
        Card.AutoButtonColor = false
        Card.Text = ""
        Card.LayoutOrder = i
        Card.Parent = ContentContainer

        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 8)
        CardCorner.Parent = Card

        local CardStroke = Instance.new("UIStroke")
        CardStroke.Thickness = 1
        CardStroke.Color = Color3.fromRGB(36, 33, 50)
        CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        CardStroke.Parent = Card

        local CardLabel = Instance.new("TextLabel")
        CardLabel.Size = UDim2.new(1, -40, 1, 0)
        CardLabel.Position = UDim2.new(0, 10, 0, 0)
        CardLabel.BackgroundTransparency = 1
        CardLabel.Text = feature.Name
        CardLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        CardLabel.Font = Enum.Font.GothamMedium
        CardLabel.TextSize = 11
        CardLabel.TextXAlignment = Enum.TextXAlignment.Left
        CardLabel.TextYAlignment = Enum.TextYAlignment.Center
        CardLabel.Parent = Card

        local Checkbox = Instance.new("Frame")
        Checkbox.Name = "Checkbox"
        Checkbox.Size = UDim2.new(0, 16, 0, 16)
        Checkbox.Position = UDim2.new(1, -24, 0.5, -8)
        Checkbox.BackgroundColor3 = Color3.fromRGB(30, 26, 44)
        Checkbox.BorderSizePixel = 0
        Checkbox.Parent = Card

        local CheckboxCorner = Instance.new("UICorner")
        CheckboxCorner.CornerRadius = UDim.new(0, 5)
        CheckboxCorner.Parent = Checkbox

        local Checkmark = Instance.new("TextLabel")
        Checkmark.Size = UDim2.new(1, 0, 1, 0)
        Checkmark.BackgroundTransparency = 1
        Checkmark.Text = utf8.char(10003)
        Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
        Checkmark.Font = Enum.Font.GothamBold
        Checkmark.TextSize = 11
        Checkmark.TextTransparency = 1
        Checkmark.TextXAlignment = Enum.TextXAlignment.Center
        Checkmark.TextYAlignment = Enum.TextYAlignment.Center
        Checkmark.Parent = Checkbox

        local isToggled = feature.Default or false

        local function updateToggle(anim)
            local targetBg = isToggled and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(30, 26, 44)
            local targetTrans = isToggled and 0 or 1

            if anim then
                TweenService:Create(Checkbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = targetBg
                }):Play()
                TweenService:Create(Checkmark, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextTransparency = targetTrans
                }):Play()
            else
                Checkbox.BackgroundColor3 = targetBg
                Checkmark.TextTransparency = targetTrans
            end
        end

        updateToggle(false)

        Card.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            updateToggle(true)

            -- Click Feedback Animation
            local originalColor = Color3.fromRGB(24, 22, 34)
            local clickColor = Color3.fromRGB(34, 30, 48)
            TweenService:Create(Card, TweenInfo.new(0.1), {BackgroundColor3 = clickColor}):Play()
            task.delay(0.1, function()
                TweenService:Create(Card, TweenInfo.new(0.15), {BackgroundColor3 = originalColor}):Play()
            end)

            if feature.Callback then
                feature.Callback(isToggled)
            end
        end)

    elseif feature.Type == "Slider" then
        local Card = Instance.new("Frame")
        Card.Name = "Card_" .. feature.Name
        Card.Size = UDim2.new(1, 0, 0, 46)
        Card.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
        Card.BorderSizePixel = 0
        Card.LayoutOrder = i
        Card.Parent = ContentContainer

        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 8)
        CardCorner.Parent = Card

        local CardStroke = Instance.new("UIStroke")
        CardStroke.Thickness = 1
        CardStroke.Color = Color3.fromRGB(36, 33, 50)
        CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        CardStroke.Parent = Card

        local CardLabel = Instance.new("TextLabel")
        CardLabel.Size = UDim2.new(1, -50, 0, 16)
        CardLabel.Position = UDim2.new(0, 10, 0, 6)
        CardLabel.BackgroundTransparency = 1
        CardLabel.Text = feature.Name
        CardLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        CardLabel.Font = Enum.Font.GothamMedium
        CardLabel.TextSize = 11
        CardLabel.TextXAlignment = Enum.TextXAlignment.Left
        CardLabel.TextYAlignment = Enum.TextYAlignment.Center
        CardLabel.Parent = Card

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 40, 0, 16)
        ValueLabel.Position = UDim2.new(1, -48, 0, 6)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(feature.Default or feature.Min or 0)
        ValueLabel.TextColor3 = Color3.fromRGB(191, 127, 255)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 11
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
        ValueLabel.Parent = Card

        local SliderTrack = Instance.new("Frame")
        SliderTrack.Name = "SliderTrack"
        SliderTrack.Size = UDim2.new(1, -20, 0, 4)
        SliderTrack.Position = UDim2.new(0, 10, 0, 28)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(30, 26, 44)
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Parent = Card

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = SliderTrack

        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "SliderFill"
        SliderFill.Size = UDim2.new(0, 0, 1, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderTrack

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = SliderFill

        local SliderHandle = Instance.new("Frame")
        SliderHandle.Name = "SliderHandle"
        SliderHandle.Size = UDim2.new(0, 10, 0, 10)
        SliderHandle.Position = UDim2.new(0, -5, 0.5, -5)
        SliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderHandle.BorderSizePixel = 0
        SliderHandle.Parent = SliderFill

        local HandleCorner = Instance.new("UICorner")
        HandleCorner.CornerRadius = UDim.new(1, 0)
        HandleCorner.Parent = SliderHandle

        local min = feature.Min or 0
        local max = feature.Max or 100
        local defaultVal = feature.Default or min
        local currentVal = defaultVal

        local function setSliderValue(val, triggerCallback)
            val = math.clamp(val, min, max)
            currentVal = val
            local percent = (val - min) / (max - min)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderHandle.Position = UDim2.new(1, -5, 0.5, -5)
            ValueLabel.Text = tostring(math.floor(val))

            if triggerCallback and feature.Callback then
                feature.Callback(val)
            end
        end

        setSliderValue(defaultVal, false)

        local isDragging = false
        local function updateDrag(input)
            local trackAbsPos = SliderTrack.AbsolutePosition.X
            local trackAbsSize = SliderTrack.AbsoluteSize.X
            if trackAbsSize > 0 then
                local relativeX = math.clamp(input.Position.X - trackAbsPos, 0, trackAbsSize)
                local percent = relativeX / trackAbsSize
                local newVal = min + (max - min) * percent
                setSliderValue(newVal, true)
            end
        end

        SliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                updateDrag(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateDrag(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)
    end
end

-- Window Minimize Functionality
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetHeight = isMinimized and 42 or windowHeight
    MinimizeText.Text = isMinimized and "+" or "-"

    TweenService:Create(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 220, 0, targetHeight)
    }):Play()
end)

-- Window Close Functionality
CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(MainWindow, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(MainWindow.Position.X.Scale, MainWindow.Position.X.Offset + 110, MainWindow.Position.Y.Scale, MainWindow.Position.Y.Offset + (windowHeight/2))
    }):Play()
    task.delay(0.22, function()
        -- Reset game states and cleanup
        _G.AutoSlapActive = false
        _G.SafeSpotActive = false
        _G.AutoUpgradeActive = false
        _G.FloatActive = false
        
        local platform = workspace:FindFirstChild("Badshah_SafePlatform")
        if platform then platform:Destroy() end
        
        ScreenGui:Destroy()
    end)
end)

-- Smooth Window Dragging Logic (Mobile & PC)
local isDraggingWindow = false
local dragStartPos = nil
local frameStartPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingWindow = true
        dragStartPos = input.Position
        frameStartPos = MainWindow.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDraggingWindow = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        MainWindow.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)

-- Startup Opening Pop-in Animation
MainWindow.Size = UDim2.new(0, 0, 0, 0)
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 220, 0, windowHeight),
    Position = UDim2.new(0.5, -110, 0.5, -windowHeight/2)
}):Play()

-- =================================================================
-- REMOTE DISPATCHER HELPER (Universal Remote Invoker)
-- =================================================================
local function fireGameRemotes(remoteKeywords, argPayloads)
    local fired = {}
    local function checkAndFire(obj)
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and not fired[obj] then
            local objName = string.lower(obj.Name)
            local matched = false
            for _, kw in ipairs(remoteKeywords) do
                if string.find(objName, kw) then
                    matched = true
                    break
                end
            end
            if matched then
                fired[obj] = true
                for _, args in ipairs(argPayloads) do
                    pcall(function()
                        if obj:IsA("RemoteEvent") then
                            obj:FireServer(unpack(args))
                        elseif obj:IsA("RemoteFunction") then
                            task.spawn(function()
                                obj:InvokeServer(unpack(args))
                            end)
                        end
                    end)
                end
            end
        end
    end

    for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
        checkAndFire(descendant)
    end
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
            checkAndFire(descendant)
        end
    end
end

-- =================================================================
-- 1. AUTO SLAP ENGINE (AUTO ATTACK SURROUNDING ENEMIES & EQUIP WEAPON)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.08)
        if _G.AutoSlapActive then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                
                if char and root and humanoid and humanoid.Health > 0 then
                    -- 1. Equip Slapper / Weapon / Glove if unequipped
                    local tool = char:FindFirstChildOfClass("Tool")
                    if not tool then
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        if backpack then
                            for _, t in ipairs(backpack:GetChildren()) do
                                if t:IsA("Tool") then
                                    humanoid:EquipTool(t)
                                    tool = t
                                    break
                                end
                            end
                        end
                    end

                    -- 2. Find closest and surrounding enemy models in Workspace
                    local attackRadius = 35
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj ~= char then
                            local enemyHum = obj:FindFirstChildOfClass("Humanoid")
                            local enemyRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso") or obj:FindFirstChild("Head")
                            
                            -- Verify it is an enemy (Not a player)
                            local isPlayer = Players:GetPlayerFromCharacter(obj) ~= nil
                            if not isPlayer and enemyHum and enemyHum.Health > 0 and enemyRoot then
                                local dist = (enemyRoot.Position - root.Position).Magnitude
                                if dist <= attackRadius then
                                    -- Layer 1: Activate Tool
                                    if tool then
                                        pcall(function()
                                            tool:Activate()
                                        end)
                                        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                                        if handle and firetouchinterest then
                                            pcall(function()
                                                firetouchinterest(handle, enemyRoot, 0)
                                                task.wait()
                                                firetouchinterest(handle, enemyRoot, 1)
                                            end)
                                        end
                                    end

                                    -- Layer 2: Virtual Click Simulation
                                    pcall(function()
                                        VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                                    end)

                                    -- Layer 3: Remote Event Slap Dispatcher
                                    fireGameRemotes(
                                        {"slap", "hit", "attack", "damage", "strike", "punch", "swing", "slapper", "weaponhit"},
                                        {
                                            {obj},
                                            {enemyRoot},
                                            {obj, enemyRoot.Position},
                                            {enemyHum},
                                            {1},
                                            {true}
                                        }
                                    )
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 2. AUTO UPGRADE ENGINE (TOOLS, SLAPPERS, GLOVES, WEAPONS & STATS)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(1.2)
        if _G.AutoUpgradeActive then
            pcall(function()
                -- LAYER 1: Remote Invocations for Tools, Weapons, Gloves & Stats
                fireGameRemotes(
                    {
                        "upgradetool", "buytool", "buyslapper", "buyweapon", "buyglove",
                        "upgradeglove", "upgradeslapper", "unlocktool", "unlockglove", "crafttool",
                        "equipbest", "buybest", "upgrade", "buyupgrade", "upgradestat", "upgradedamage",
                        "upgradehealth", "upgradespeed", "purchaseupgrade", "upgradeslap", "levelup"
                    },
                    {
                        {},
                        {"Tool"}, {"Weapon"}, {"Glove"}, {"Slapper"}, {"Sword"},
                        {"Damage"}, {"Health"}, {"Speed"}, {"Slap"},
                        {1}, {2}, {3}, {4}, {5}, {10},
                        {true},
                        {"All"}, {"BuyAll"}
                    }
                )

                -- LAYER 2: GUI Button Auto-Clicker (Tools, Gloves, Weapons & Shop Upgrades)
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, obj in ipairs(playerGui:GetDescendants()) do
                        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and not obj:IsDescendantOf(ScreenGui) and obj.Parent ~= ScreenGui then
                            local bName = string.lower(obj.Name)
                            local bText = (obj:IsA("TextButton") and string.lower(obj.Text)) or ""

                            if not string.find(bName, "card_") and not string.find(bName, "minimize") and not string.find(bName, "close") then
                                local isUpgradeOrToolBtn = (
                                    string.find(bName, "upgrade") or string.find(bName, "buy") or
                                    string.find(bName, "tool") or string.find(bName, "weapon") or
                                    string.find(bName, "glove") or string.find(bName, "slapper") or
                                    string.find(bName, "stat") or string.find(bName, "equip") or
                                    string.find(bText, "upgrade") or string.find(bText, "buy") or
                                    string.find(bText, "tool") or string.find(bText, "glove") or
                                    string.find(bText, "slapper") or string.find(bText, "weapon") or
                                    string.find(bText, "level up") or string.find(bText, "purchase")
                                )

                                if isUpgradeOrToolBtn then
                                    pcall(function()
                                        if firesignal then
                                            firesignal(obj.MouseButton1Click)
                                            firesignal(obj.Activated)
                                        end
                                        if getconnections then
                                            for _, con in ipairs(getconnections(obj.MouseButton1Click)) do
                                                con:Fire()
                                            end
                                            for _, con in ipairs(getconnections(obj.Activated)) do
                                                con:Fire()
                                            end
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Startup visual notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Badshah Scripts",
        Text = "Slap to Survive script loaded successfully!",
        Duration = 5
    })
end)

print("========================================")
print("[Badshah Scripts] " .. GameName .. " Loaded Successfully!")
print("========================================")
