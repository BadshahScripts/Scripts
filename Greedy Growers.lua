-- =================================================================
-- CONFIGURATION: Greedy Growers Script (Badshah Mobile UI)
-- =================================================================
local GameName = "Greedy Growers"
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
_G.AutoBuySeedsActive = false
_G.AutoPlantActive = false
_G.AutoHarvestActive = false
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
        Name = "Auto Buy Best Seeds",
        Default = false,
        Callback = function(state)
            _G.AutoBuySeedsActive = state
            print("[Greedy Growers] Auto Buy Best Seeds set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Plant",
        Default = false,
        Callback = function(state)
            _G.AutoPlantActive = state
            print("[Greedy Growers] Auto Plant set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Harvest",
        Default = false,
        Callback = function(state)
            _G.AutoHarvestActive = state
            print("[Greedy Growers] Auto Harvest set to:", state)
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
        _G.AutoBuySeedsActive = false
        _G.AutoPlantActive = false
        _G.AutoHarvestActive = false
        
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
-- UNIVERSAL INTERACTION HELPERS (PROMPTS & REMOTES)
-- =================================================================
local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end
    end)
end

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
-- 1. AUTO BUY BEST SEEDS ENGINE (RIVER SEEDS & SHOP PROMPTS)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.3)
        if _G.AutoBuySeedsActive then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                -- LAYER 1: River Floating Seeds & Prompts
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local pText = string.lower(obj.ActionText or "")
                        local oText = string.lower(obj.ObjectText or "")
                        local parentName = string.lower(obj.Parent and obj.Parent.Name or "")
                        
                        if string.find(pText, "seed") or string.find(pText, "buy") or string.find(pText, "take") or
                           string.find(pText, "grab") or string.find(pText, "collect") or string.find(oText, "seed") or
                           string.find(parentName, "seed") or string.find(parentName, "river") then
                            triggerPrompt(obj)
                        end
                    elseif obj:IsA("TouchTransmitter") and root then
                        local part = obj.Parent
                        if part and part:IsA("BasePart") then
                            local n = string.lower(part.Name)
                            if string.find(n, "seed") or string.find(n, "fruit") or string.find(n, "drop") then
                                if firetouchinterest then
                                    firetouchinterest(part, root, 0)
                                    task.wait()
                                    firetouchinterest(part, root, 1)
                                end
                            end
                        end
                    end
                end

                -- LAYER 2: Seed Remote Dispatcher (High Tier Seeds: Void, Cosmic, Divine, Legendary)
                fireGameRemotes(
                    {"buyseed", "purchaseseed", "getseed", "takeseed", "riverseed", "claimseed", "buy", "purchase"},
                    {
                        {"Void"}, {"Cosmic"}, {"Divine"}, {"Legendary"}, {"Golden"}, {"Epic"}, {"Rare"},
                        {"Best"}, {"All"}, {1}, {true}, {}
                    }
                )

                -- LAYER 3: GUI Shop Seed Auto-Clicker
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, btn in ipairs(playerGui:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and not btn:IsDescendantOf(ScreenGui) and btn.Parent ~= ScreenGui then
                            local bName = string.lower(btn.Name)
                            local bText = (btn:IsA("TextButton") and string.lower(btn.Text)) or ""
                            
                            if not string.find(bName, "card_") and not string.find(bName, "minimize") and not string.find(bName, "close") then
                                if (string.find(bName, "seed") and string.find(bName, "buy")) or
                                   (string.find(bText, "buy") and string.find(bText, "seed")) or
                                   string.find(bName, "buybest") or string.find(bText, "buy best") then
                                    pcall(function()
                                        if firesignal then
                                            firesignal(btn.MouseButton1Click)
                                            firesignal(btn.Activated)
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

-- =================================================================
-- 2. AUTO PLANT SEEDS ENGINE (SOIL / PLOTS / FARMS)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.4)
        if _G.AutoPlantActive then
            pcall(function()
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if char and humanoid and root then
                    -- 1. Auto-Equip Seed from Backpack
                    local seedTool = char:FindFirstChildOfClass("Tool")
                    if not seedTool or not string.find(string.lower(seedTool.Name), "seed") then
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        if backpack then
                            for _, tool in ipairs(backpack:GetChildren()) do
                                if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "seed") or string.find(string.lower(tool.Name), "plant")) then
                                    humanoid:EquipTool(tool)
                                    seedTool = tool
                                    break
                                end
                            end
                        end
                    end

                    -- 2. Trigger Plant Prompts on Dirt / Plots
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            local pText = string.lower(obj.ActionText or "")
                            local oText = string.lower(obj.ObjectText or "")
                            local parentName = string.lower(obj.Parent and obj.Parent.Name or "")
                            
                            if string.find(pText, "plant") or string.find(pText, "sow") or string.find(pText, "place") or
                               string.find(oText, "soil") or string.find(oText, "dirt") or string.find(oText, "plot") or
                               string.find(parentName, "plot") or string.find(parentName, "soil") or string.find(parentName, "dirt") or string.find(parentName, "spot") then
                                triggerPrompt(obj)
                            end
                        end
                    end

                    -- 3. Tool Click Activation (If holding seed tool)
                    if seedTool then
                        pcall(function()
                            seedTool:Activate()
                            VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                        end)
                    end

                    -- 4. Remote Event Plant Dispatcher
                    fireGameRemotes(
                        {"plant", "plantseed", "sow", "placeseed", "useseed", "sowseed", "farmplant"},
                        {
                            {},
                            {"Void Seed"}, {"Cosmic Seed"}, {"Divine Seed"}, {"Golden Seed"}, {"Seed"},
                            {1}, {2}, {3}, {4}, {5},
                            {true}
                        }
                    )
                end
            end)
        end
    end
end)

-- =================================================================
-- 3. AUTO HARVEST ENGINE (TREES, CROPS, MUTATIONS & FRUITS)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.25)
        if _G.AutoHarvestActive then
            pcall(function()
                -- LAYER 1: Trigger ProximityPrompts on Trees, Crops, Fruits & Plots
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local pText = string.lower(obj.ActionText or "")
                        local oText = string.lower(obj.ObjectText or "")
                        local parentName = string.lower(obj.Parent and obj.Parent.Name or "")
                        
                        if string.find(pText, "harvest") or string.find(pText, "pick") or string.find(pText, "collect") or
                           string.find(pText, "bank") or string.find(pText, "claim") or string.find(pText, "cut") or
                           string.find(oText, "tree") or string.find(oText, "crop") or string.find(oText, "fruit") or
                           string.find(parentName, "tree") or string.find(parentName, "fruit") or string.find(parentName, "crop") then
                            triggerPrompt(obj)
                        end
                    end
                end

                -- LAYER 2: Remote Event Harvest / Bank Dispatcher
                fireGameRemotes(
                    {
                        "harvest", "harvesttree", "collecttree", "bankcrop", "claimfruit",
                        "pickfruit", "harvestcrop", "bankfruit", "collectfruit", "sellfruit"
                    },
                    {
                        {},
                        {1}, {2}, {3}, {4}, {5},
                        {true},
                        {"All"}, {"Plot"}, {"Tree"}
                    }
                )

                -- LAYER 3: GUI Harvest / Bank Auto-Clicker
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, btn in ipairs(playerGui:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and not btn:IsDescendantOf(ScreenGui) and btn.Parent ~= ScreenGui then
                            local bName = string.lower(btn.Name)
                            local bText = (btn:IsA("TextButton") and string.lower(btn.Text)) or ""
                            
                            if not string.find(bName, "card_") and not string.find(bName, "minimize") and not string.find(bName, "close") then
                                if string.find(bName, "harvest") or string.find(bName, "bank") or string.find(bName, "collect") or
                                   string.find(bText, "harvest") or string.find(bText, "bank") or string.find(bText, "claim") then
                                    pcall(function()
                                        if firesignal then
                                            firesignal(btn.MouseButton1Click)
                                            firesignal(btn.Activated)
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

-- =================================================================
-- 4. WALKSPEED CONTROLLER (RENDERSTEPPED CONSTANT ENFORCER)
-- =================================================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and _G.WalkSpeedValue and _G.WalkSpeedValue > 16 then
                if humanoid.WalkSpeed ~= _G.WalkSpeedValue then
                    humanoid.WalkSpeed = _G.WalkSpeedValue
                end
            end
        end
    end)
end)

-- Startup visual notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Badshah Scripts",
        Text = "Greedy Growers script loaded successfully!",
        Duration = 5
    })
end)

print("========================================")
print("[Badshah Scripts] " .. GameName .. " Loaded Successfully!")
print("========================================")
