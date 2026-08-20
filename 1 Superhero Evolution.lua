-- =================================================================
-- CONFIGURATION: +1 Superhero Evolution Script (Mobile & PC)
-- =================================================================
local GameName = "Superhero Evolution"
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
_G.AutoPowerTrainActive = false
_G.AutoRebirthActive = false
_G.FlyActive = false
_G.FlySpeed = 60
_G.NoclipActive = false

-- Metamethod Remote Capture Storage
_G.CapturedPowerRemote = nil
_G.CapturedPowerArgs = nil
_G.CapturedRebirthRemote = nil
_G.CapturedRebirthArgs = nil

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
        Name = "Auto Power Train",
        Default = false,
        Callback = function(state)
            _G.AutoPowerTrainActive = state
            print("[Superhero Evolution] Auto Power Train set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Rebirth",
        Default = false,
        Callback = function(state)
            _G.AutoRebirthActive = state
            print("[Superhero Evolution] Auto Rebirth set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Fly Mode",
        Default = false,
        Callback = function(state)
            _G.FlyActive = state
            print("[Superhero Evolution] Fly Mode set to:", state)
        end
    },
    {
        Type = "Slider",
        Name = "Fly Speed",
        Min = 20,
        Max = 250,
        Default = 60,
        Callback = function(value)
            _G.FlySpeed = value
        end
    },
    {
        Type = "Toggle",
        Name = "Noclip",
        Default = false,
        Callback = function(state)
            _G.NoclipActive = state
            print("[Superhero Evolution] Noclip set to:", state)
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
CloseText.Text = utf8.char(215)
CloseText.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseText.Font = Enum.Font.GothamBold
CloseText.TextSize = 13
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
FooterLabel.Text = "Created By: " .. CreatorName
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

        local function updateToggleState(animate)
            if isToggled then
                if animate then
                    TweenService:Create(Checkbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(168, 85, 247)}):Play()
                    TweenService:Create(Checkmark, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
                else
                    Checkbox.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
                    Checkmark.TextTransparency = 0
                end
            else
                if animate then
                    TweenService:Create(Checkbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 26, 44)}):Play()
                    TweenService:Create(Checkmark, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
                else
                    Checkbox.BackgroundColor3 = Color3.fromRGB(30, 26, 44)
                    Checkmark.TextTransparency = 1
                end
            end
        end

        updateToggleState(false)

        Card.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            updateToggleState(true)
            
            -- Brief card flash
            local originalColor = Card.BackgroundColor3
            TweenService:Create(Card, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(32, 28, 48)}):Play()
            task.delay(0.12, function()
                TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = originalColor}):Play()
            end)

            if feature.Callback then
                feature.Callback(isToggled)
            end
        end)

    elseif feature.Type == "Slider" then
        local Card = Instance.new("Frame")
        Card.Name = "SliderCard_" .. feature.Name
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

        local TitleLabelSlider = Instance.new("TextLabel")
        TitleLabelSlider.Size = UDim2.new(1, -60, 0, 18)
        TitleLabelSlider.Position = UDim2.new(0, 10, 0, 6)
        TitleLabelSlider.BackgroundTransparency = 1
        TitleLabelSlider.Text = feature.Name
        TitleLabelSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabelSlider.Font = Enum.Font.GothamMedium
        TitleLabelSlider.TextSize = 11
        TitleLabelSlider.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabelSlider.TextYAlignment = Enum.TextYAlignment.Center
        TitleLabelSlider.Parent = Card

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 45, 0, 18)
        ValueLabel.Position = UDim2.new(1, -55, 0, 6)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(feature.Default or feature.Min)
        ValueLabel.TextColor3 = Color3.fromRGB(191, 127, 255)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 11
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
        ValueLabel.Parent = Card

        local SliderTrack = Instance.new("TextButton")
        SliderTrack.Name = "SliderTrack"
        SliderTrack.Size = UDim2.new(1, -20, 0, 4)
        SliderTrack.Position = UDim2.new(0, 10, 0, 32)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(34, 30, 48)
        SliderTrack.BorderSizePixel = 0
        SliderTrack.AutoButtonColor = false
        SliderTrack.Text = ""
        SliderTrack.Parent = Card

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = SliderTrack

        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "SliderFill"
        local initialPercent = math.clamp(((feature.Default or feature.Min) - feature.Min) / (feature.Max - feature.Min), 0, 1)
        SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderTrack

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = SliderFill

        local SliderHandle = Instance.new("Frame")
        SliderHandle.Name = "SliderHandle"
        SliderHandle.Size = UDim2.new(0, 10, 0, 10)
        SliderHandle.Position = UDim2.new(1, -5, 0.5, -5)
        SliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderHandle.BorderSizePixel = 0
        SliderHandle.Parent = SliderFill

        local HandleCorner = Instance.new("UICorner")
        HandleCorner.CornerRadius = UDim.new(1, 0)
        HandleCorner.Parent = SliderHandle

        local isDragging = false

        local function updateSlider(inputPosition)
            local trackAbsPos = SliderTrack.AbsolutePosition.X
            local trackAbsSize = SliderTrack.AbsoluteSize.X
            local percent = math.clamp((inputPosition.X - trackAbsPos) / trackAbsSize, 0, 1)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            
            local val = math.floor(feature.Min + (feature.Max - feature.Min) * percent)
            ValueLabel.Text = tostring(val)
            
            if feature.Callback then
                feature.Callback(val)
            end
        end

        SliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                updateSlider(input.Position)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input.Position)
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
        Divider.Visible = false
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
                Divider.Visible = true
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
        Text = "+1 Superhero Evolution Loaded!",
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

-- =================================================================
-- METAMETHOD REMOTE SNIFFER (Captures In-Game Events & Remotes)
-- =================================================================
pcall(function()
    local gmt = getrawmetatable(game)
    if gmt and setreadonly then
        setreadonly(gmt, false)
        local oldNamecall = gmt.__namecall
        gmt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = string.lower(self.Name)
                if string.find(remoteName, "power") or string.find(remoteName, "train") or string.find(remoteName, "click") or string.find(remoteName, "strength") or string.find(remoteName, "energy") or string.find(remoteName, "punch") then
                    _G.CapturedPowerRemote = self
                    _G.CapturedPowerArgs = args
                elseif string.find(remoteName, "rebirth") or string.find(remoteName, "prestige") or string.find(remoteName, "ascend") then
                    _G.CapturedRebirthRemote = self
                    _G.CapturedRebirthArgs = args
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(gmt, true)
    end
end)

-- =================================================================
-- 1. FLY SYSTEM (MOBILE JOYSTICK & PC KEYBOARD COMPATIBLE)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.03)
        if _G.FlyActive then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local camera = workspace.CurrentCamera
                
                if hrp and hum and camera then
                    local bv = hrp:FindFirstChild("HeroFlyBV") or Instance.new("BodyVelocity")
                    bv.Name = "HeroFlyBV"
                    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    bv.Parent = hrp
                    
                    local bg = hrp:FindFirstChild("HeroFlyBG") or Instance.new("BodyGyro")
                    bg.Name = "HeroFlyBG"
                    bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                    bg.P = 10000
                    bg.Parent = hrp
                    
                    hum.PlatformStand = true
                    bg.CFrame = camera.CFrame
                    
                    local speed = _G.FlySpeed or 60
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        local flyVel = camera.CFrame.LookVector * speed
                        if math.abs(moveDir.Z) < 0.2 and math.abs(moveDir.X) > 0.5 then
                            flyVel = camera.CFrame.RightVector * speed * (moveDir.X > 0 and 1 or -1)
                        end
                        bv.Velocity = flyVel
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        else
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand = false
                end
                if hrp then
                    local bv = hrp:FindFirstChild("HeroFlyBV")
                    if bv then bv:Destroy() end
                    local bg = hrp:FindFirstChild("HeroFlyBG")
                    if bg then bg:Destroy() end
                end
            end)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if not _G.FlyActive then
        local hrp = newChar:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("HeroFlyBV")
            if bv then bv:Destroy() end
            local bg = hrp:FindFirstChild("HeroFlyBG")
            if bg then bg:Destroy() end
        end
    end
end)

-- =================================================================
-- 2. AUTO POWER TRAIN ENGINE (+1 POWER GENERATOR & CLICKER)
-- =================================================================
local powerKeywords = {
    "power", "train", "addpower", "gainpower", "givepower", "click", "punch", "strength", "energy", "tap", "farm"
}

task.spawn(function()
    while true do
        task.wait(0.03)
        if _G.AutoPowerTrainActive then
            pcall(function()
                -- A. Fire Sniffed Captured Remote
                if _G.CapturedPowerRemote then
                    pcall(function()
                        if _G.CapturedPowerRemote:IsA("RemoteEvent") then
                            _G.CapturedPowerRemote:FireServer(unpack(_G.CapturedPowerArgs or {}))
                        elseif _G.CapturedPowerRemote:IsA("RemoteFunction") then
                            _G.CapturedPowerRemote:InvokeServer(unpack(_G.CapturedPowerArgs or {}))
                        end
                    end)
                end

                -- B. Deep Scan ReplicatedStorage Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local n = string.lower(obj.Name)
                        for _, kw in ipairs(powerKeywords) do
                            if string.find(n, kw) then
                                pcall(function()
                                    if obj:IsA("RemoteEvent") then
                                        obj:FireServer()
                                        obj:FireServer(1)
                                        obj:FireServer(true)
                                    elseif obj:IsA("RemoteFunction") then
                                        task.spawn(function()
                                            pcall(function()
                                                obj:InvokeServer()
                                                obj:InvokeServer(1)
                                            end)
                                        end)
                                    end
                                end)
                                break
                            end
                        end
                    end
                end

                -- C. Auto Equip and Activate Tools
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if LocalPlayer:FindFirstChild("Backpack") and hum then
                    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            hum:EquipTool(tool)
                            break
                        end
                    end
                end
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool:Activate()
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 3. NOCLIP ENGINE
-- =================================================================
RunService.Stepped:Connect(function()
    if _G.NoclipActive then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- =================================================================
-- 4. AUTO REBIRTH ENGINE
-- =================================================================
local rebirthKeywords = {
    "rebirth", "dorebirth", "buyrebirth", "prestige", "ascend", "rebirthremote", "rebirthevent", "rebirthfunction"
}

task.spawn(function()
    while true do
        task.wait(0.4)
        if _G.AutoRebirthActive then
            pcall(function()
                -- Fire Captured Rebirth Remote
                if _G.CapturedRebirthRemote then
                    pcall(function()
                        if _G.CapturedRebirthRemote:IsA("RemoteEvent") then
                            _G.CapturedRebirthRemote:FireServer(unpack(_G.CapturedRebirthArgs or {}))
                        elseif _G.CapturedRebirthRemote:IsA("RemoteFunction") then
                            _G.CapturedRebirthRemote:InvokeServer(unpack(_G.CapturedRebirthArgs or {}))
                        end
                    end)
                end

                -- Scan ReplicatedStorage for Rebirth Remotes
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local n = string.lower(obj.Name)
                        for _, kw in ipairs(rebirthKeywords) do
                            if string.find(n, kw) then
                                pcall(function()
                                    if obj:IsA("RemoteEvent") then
                                        obj:FireServer()
                                        obj:FireServer(1)
                                        obj:FireServer(true)
                                    elseif obj:IsA("RemoteFunction") then
                                        task.spawn(function()
                                            pcall(function()
                                                obj:InvokeServer()
                                                obj:InvokeServer(1)
                                            end)
                                        end)
                                    end
                                end)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)
