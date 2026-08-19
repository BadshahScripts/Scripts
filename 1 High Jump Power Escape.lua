-- =================================================================
-- CONFIGURATION: +1 High Jump Power Escape Script (Badshah Mobile UI)
-- =================================================================
local GameName = "High Jump Escape"
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
_G.AutoRebirthActive = false
_G.InfiniteJumpActive = false
_G.WalkSpeedValue = 16

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
        Name = "Auto Rebirth",
        Default = false,
        Callback = function(state)
            _G.AutoRebirthActive = state
            print("[High Jump Escape] Auto Rebirth set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Infinite Jump",
        Default = false,
        Callback = function(state)
            _G.InfiniteJumpActive = state
            print("[High Jump Escape] Infinite Jump set to:", state)
        end
    },
    {
        Type = "Slider",
        Name = "WalkSpeed",
        Min = 16,
        Max = 200,
        Default = 16,
        Callback = function(value)
            _G.WalkSpeedValue = value
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = value
                end
            end)
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

-- Close Button (20x20)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0.5, -10)
CloseButton.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
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
CloseText.Text = "×"
CloseText.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseText.Font = Enum.Font.GothamBold
CloseText.TextSize = 13
CloseText.TextXAlignment = Enum.TextXAlignment.Center
CloseText.TextYAlignment = Enum.TextYAlignment.Center
CloseText.Parent = CloseButton

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
ContentContainer.Position = UDim2.new(0, 8, 0, 42)
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
        Checkbox.BackgroundColor3 = Color3.fromRGB(15, 14, 22)
        Checkbox.BorderSizePixel = 0
        Checkbox.Parent = Card

        local CheckboxCorner = Instance.new("UICorner")
        CheckboxCorner.CornerRadius = UDim.new(0, 4)
        CheckboxCorner.Parent = Checkbox

        local Checkmark = Instance.new("TextLabel")
        Checkmark.Size = UDim2.new(1, 0, 1, 0)
        Checkmark.BackgroundTransparency = 1
        Checkmark.Text = "✓"
        Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
        Checkmark.Font = Enum.Font.GothamBold
        Checkmark.TextSize = 11
        Checkmark.TextTransparency = 1
        Checkmark.TextXAlignment = Enum.TextXAlignment.Center
        Checkmark.TextYAlignment = Enum.TextYAlignment.Center
        Checkmark.Parent = Checkbox

        local isToggled = feature.Default or false

        local function updateToggle(state)
            isToggled = state
            local targetBg = state and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(15, 14, 22)
            local targetTrans = state and 0 or 1
            TweenService:Create(Checkbox, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
            TweenService:Create(Checkmark, TweenInfo.new(0.2), {TextTransparency = targetTrans}):Play()
            if feature.Callback then
                task.spawn(function()
                    feature.Callback(isToggled)
                end)
            end
        end

        if isToggled then
            Checkbox.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
            Checkmark.TextTransparency = 0
        end

        Card.MouseButton1Click:Connect(function()
            updateToggle(not isToggled)
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
        ValueLabel.Text = tostring(feature.Default or feature.Min)
        ValueLabel.TextColor3 = Color3.fromRGB(191, 127, 255)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 11
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
        ValueLabel.Parent = Card

        local SliderTrack = Instance.new("Frame")
        SliderTrack.Name = "SliderTrack"
        SliderTrack.Size = UDim2.new(1, -20, 0, 4)
        SliderTrack.Position = UDim2.new(0, 10, 0, 30)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(15, 14, 22)
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Parent = Card

        local SliderTrackCorner = Instance.new("UICorner")
        SliderTrackCorner.CornerRadius = UDim.new(1, 0)
        SliderTrackCorner.Parent = SliderTrack

        local defaultPct = ((feature.Default or feature.Min) - feature.Min) / (feature.Max - feature.Min)
        defaultPct = math.clamp(defaultPct, 0, 1)

        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "SliderFill"
        SliderFill.Size = UDim2.new(defaultPct, 0, 1, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderTrack

        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(1, 0)
        SliderFillCorner.Parent = SliderFill

        local SliderHandle = Instance.new("Frame")
        SliderHandle.Name = "SliderHandle"
        SliderHandle.Size = UDim2.new(0, 10, 0, 10)
        SliderHandle.Position = UDim2.new(defaultPct, -5, 0.5, -5)
        SliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderHandle.BorderSizePixel = 0
        SliderHandle.Parent = SliderTrack

        local SliderHandleCorner = Instance.new("UICorner")
        SliderHandleCorner.CornerRadius = UDim.new(1, 0)
        SliderHandleCorner.Parent = SliderHandle

        local isDragging = false

        local function updateSlider(input)
            local trackAbsPos = SliderTrack.AbsolutePosition.X
            local trackAbsSize = SliderTrack.AbsoluteSize.X
            local relativeX = input.Position.X - trackAbsPos
            local percentage = math.clamp(relativeX / trackAbsSize, 0, 1)
            local value = math.floor(feature.Min + (feature.Max - feature.Min) * percentage)

            SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            SliderHandle.Position = UDim2.new(percentage, -5, 0.5, -5)
            ValueLabel.Text = tostring(value)

            if feature.Callback then
                task.spawn(function()
                    feature.Callback(value)
                end)
            end
        end

        Card.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                updateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
    end
end

-- =================================================================
-- WINDOW DRAGGING ENGINE
-- =================================================================
local isDraggingWindow = false
local dragStartPos
local frameStartPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingWindow = true
        dragStartPos = input.Position
        frameStartPos = MainWindow.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingWindow = false
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

-- =================================================================
-- ANIMATIONS (Fade-In, Minimize, Close)
-- =================================================================

-- 1. Fade-in Launch Animation
MainWindow.Size = UDim2.new(0, 0, 0, 0)
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(
    MainWindow,
    TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {
        Size = UDim2.new(0, 220, 0, windowHeight),
        Position = UDim2.new(0.5, -110, 0.5, -windowHeight/2)
    }
):Play()

-- 2. Minimize Functionality
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeText.Text = "+"
        ContentContainer.Visible = false
        Footer.Visible = false
        TweenService:Create(
            MainWindow,
            TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 220, 0, 42)}
        ):Play()
    else
        MinimizeText.Text = "-"
        local tween = TweenService:Create(
            MainWindow,
            TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 220, 0, windowHeight)}
        )
        tween:Play()
        tween.Completed:Connect(function()
            if not isMinimized then
                ContentContainer.Visible = true
                Footer.Visible = true
            end
        end)
    end
end)

-- 3. Close Functionality
CloseButton.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(
        MainWindow,
        TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(MainWindow.Position.X.Scale, MainWindow.Position.X.Offset + 110, MainWindow.Position.Y.Scale, MainWindow.Position.Y.Offset + windowHeight/2)
        }
    )
    closeTween:Play()
    closeTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

-- =================================================================
-- STARTUP NOTIFICATIONS & ANTI-AFK PROTECTION
-- =================================================================
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Badshah Scripts",
        Text = "+1 High Jump Power Loaded Successfully!",
        Duration = 5
    })
end)

-- Anti-AFK Kick Protection
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end)
end)

-- Auto WalkSpeed Loop
task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(function()
            if _G.WalkSpeedValue and _G.WalkSpeedValue ~= 16 then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    if LocalPlayer.Character.Humanoid.WalkSpeed ~= _G.WalkSpeedValue then
                        LocalPlayer.Character.Humanoid.WalkSpeed = _G.WalkSpeedValue
                    end
                end
            end
        end)
    end
end)

-- =================================================================
-- UNIVERSAL REMOTE DISPATCHER ENGINE
-- =================================================================
local function fireGameRemotes(keywords, argsList)
    local searchContainers = {ReplicatedStorage, workspace}
    if LocalPlayer:FindFirstChild("PlayerGui") then
        table.insert(searchContainers, LocalPlayer.PlayerGui)
    end

    local char = LocalPlayer.Character
    if char then
        table.insert(searchContainers, char)
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        table.insert(searchContainers, backpack)
    end

    for _, container in ipairs(searchContainers) do
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = string.lower(obj.Name)
                for _, kw in ipairs(keywords) do
                    if string.find(n, kw) then
                        for _, argSet in ipairs(argsList) do
                            pcall(function()
                                if obj:IsA("RemoteEvent") then
                                    if type(argSet) == "table" then
                                        obj:FireServer(unpack(argSet))
                                    elseif argSet ~= nil then
                                        obj:FireServer(argSet)
                                    else
                                        obj:FireServer()
                                    end
                                elseif obj:IsA("RemoteFunction") then
                                    if type(argSet) == "table" then
                                        obj:InvokeServer(unpack(argSet))
                                    elseif argSet ~= nil then
                                        obj:InvokeServer(argSet)
                                    else
                                        obj:InvokeServer()
                                    end
                                end
                            end)
                        end
                        break
                    end
                end
            end
        end
    end
end

-- =================================================================
-- 1. ADVANCED AUTO REBIRTH ENGINE (MULTI-LAYERED & ZERO DELAY)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(1.0)
        if _G.AutoRebirthActive then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")

                -- LAYER 1: Comprehensive Remote & Knit Service Dispatcher
                fireGameRemotes(
                    {
                        "rebirth", "dorebirth", "buyrebirth", "requestrebirth", "prestige",
                        "rankup", "evolve", "reset", "playerrebirth", "claimrebirth", "onrebirth", "doprestige"
                    },
                    {
                        {},
                        {1}, {2}, {3}, {5}, {10},
                        {true},
                        {"1"}, {"Rebirth"}, {"Prestige"},
                        {1, true}, {"Rebirth", 1}, {"All"}
                    }
                )

                -- LAYER 2: Game GUI Rebirth Button Auto-Trigger (Excludes Badshah UI)
                if playerGui then
                    for _, obj in ipairs(playerGui:GetDescendants()) do
                        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and not obj:IsDescendantOf(ScreenGui) and obj.Parent ~= ScreenGui then
                            local bName = string.lower(obj.Name)
                            local bText = (obj:IsA("TextButton") and string.lower(obj.Text)) or ""

                            if not string.find(bName, "card_") and not string.find(bName, "minimize") and not string.find(bName, "close") then
                                local isRebirthBtn = (
                                    string.find(bName, "rebirth") or string.find(bName, "prestige") or
                                    string.find(bText, "rebirth") or string.find(bText, "prestige") or
                                    string.find(bText, "re-birth") or (string.find(bName, "buy") and string.find(bName, "rebirth"))
                                )

                                if isRebirthBtn then
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

                -- LAYER 3: Workspace Rebirth Pads & Zone Touch Interaction
                if root then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "rebirthpad") or string.find(n, "rebirthzone") or string.find(n, "prestigepad") or string.find(n, "rebirthcircle") then
                                if firetouchinterest then
                                    firetouchinterest(obj, root, 0)
                                    task.wait()
                                    firetouchinterest(obj, root, 1)
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
-- 2. INFINITE JUMP ENGINE (MOBILE & PC FRIENDLY)
-- =================================================================
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJumpActive then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

print("========================================")
print("[Badshah Scripts] " .. GameName .. " Loaded Successfully!")
print("========================================")
