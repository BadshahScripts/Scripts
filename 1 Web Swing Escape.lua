-- =================================================================
-- CONFIGURATION: +1 Web Swing Escape Script (Badshah Mobile UI)
-- =================================================================
local GameName = "+1 Web Swing Escape"
local CreatorName = "Badshah Scripts"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Global Feature State Flags
_G.FlyActive = false
_G.FlySpeed = 50
_G.AutoSpeedActive = false
_G.AutoRebirthActive = false
_G.InfJumpActive = false

-- UI Feature List Definition (Toggles & Sliders)
local Features = {
    {
        Type = "Toggle",
        Name = "Fly",
        Default = false,
        Callback = function(state)
            _G.FlyActive = state
            print("[+1 Web Swing Escape] Fly set to:", state)
        end
    },
    {
        Type = "Slider",
        Name = "Fly Speed",
        Min = 10,
        Max = 200,
        Default = 50,
        Callback = function(val)
            _G.FlySpeed = val
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Speed Farm",
        Default = false,
        Callback = function(state)
            _G.AutoSpeedActive = state
            print("[+1 Web Swing Escape] Auto Speed Farm set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Rebirth",
        Default = false,
        Callback = function(state)
            _G.AutoRebirthActive = state
            print("[+1 Web Swing Escape] Auto Rebirth set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Inf Jump",
        Default = false,
        Callback = function(state)
            _G.InfJumpActive = state
            print("[+1 Web Swing Escape] Inf Jump set to:", state)
        end
    }
}

-- =================================================================
-- STARTUP NOTIFICATIONS & ANTI-AFK
-- =================================================================
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Badshah Scripts",
        Text = "+1 Web Swing Escape Script Loaded!",
        Duration = 5
    })
end)

-- Anti-AFK Kick Protection
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)

-- Auto Redeem Active Promo Codes
task.spawn(function()
    task.wait(1.5)
    pcall(function()
        local activeCodes = {
            "SPEED", "LAUNCH", "SWING", "WINNER", "CITY", "RACE",
            "WELCOME", "BUGFIX", "WINS", "100LIKES", "500LIKES", "1KLIKES", "BOOST"
        }
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = string.lower(obj.Name)
                if string.find(n, "code") or string.find(n, "redeem") then
                    for _, code in ipairs(activeCodes) do
                        pcall(function()
                            if obj:IsA("RemoteEvent") then
                                obj:FireServer(code)
                            elseif obj:IsA("RemoteFunction") then
                                obj:InvokeServer(code)
                            end
                        end)
                    end
                end
            end
        end
    end)
end)

-- =================================================================
-- DYNAMIC NETWORK INTERACTION & AUTOMATION HOOKS
-- =================================================================
_G.CapturedSpeedRemote = nil
_G.CapturedSpeedArgs = {}

_G.CapturedRebirthRemote = nil
_G.CapturedRebirthArgs = {}

pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "FireServer" or method == "InvokeServer" then
                local name = string.lower(self.Name)
                if string.find(name, "speed") or string.find(name, "swing") or string.find(name, "train") or string.find(name, "click") or string.find(name, "web") then
                    _G.CapturedSpeedRemote = self
                    _G.CapturedSpeedArgs = args
                elseif string.find(name, "rebirth") or string.find(name, "prestige") or string.find(name, "ascend") then
                    _G.CapturedRebirthRemote = self
                    _G.CapturedRebirthArgs = args
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

-- =================================================================
-- 1. FLY SYSTEM (MOBILE TOUCH JOYSTICK & PC KEYBOARD COMPATIBLE)
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
                    local bv = hrp:FindFirstChild("WebFlyBV") or Instance.new("BodyVelocity")
                    bv.Name = "WebFlyBV"
                    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    bv.Parent = hrp
                    
                    local bg = hrp:FindFirstChild("WebFlyBG") or Instance.new("BodyGyro")
                    bg.Name = "WebFlyBG"
                    bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                    bg.P = 10000
                    bg.Parent = hrp
                    
                    hum.PlatformStand = true
                    bg.CFrame = camera.CFrame
                    
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        local flyVel = camera.CFrame.LookVector * (_G.FlySpeed or 50)
                        if math.abs(moveDir.Z) < 0.2 and math.abs(moveDir.X) > 0.5 then
                            flyVel = camera.CFrame.RightVector * (_G.FlySpeed or 50) * (moveDir.X > 0 and 1 or -1)
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
                    local bv = hrp:FindFirstChild("WebFlyBV")
                    if bv then bv:Destroy() end
                    local bg = hrp:FindFirstChild("WebFlyBG")
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
            local bv = hrp:FindFirstChild("WebFlyBV")
            if bv then bv:Destroy() end
            local bg = hrp:FindFirstChild("WebFlyBG")
            if bg then bg:Destroy() end
        end
    end
end)

-- =================================================================
-- 2. AUTO SPEED FARM (+1 SPEED GENERATOR & WEB SHOOTER CLICKER)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.03)
        if _G.AutoSpeedActive then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")

                -- A. Auto Equip Web Shooter / Tool from Backpack
                if LocalPlayer:FindFirstChild("Backpack") and char and hum then
                    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            hum:EquipTool(tool)
                            break
                        end
                    end
                end

                -- B. Activate Equipped Tool (Web Shooter)
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            pcall(function() tool:Activate() end)
                        end
                    end
                end

                -- C. Simulate Micro-Movement to trigger "+1 speed per step/move"
                if hum and root and not _G.FlyActive then
                    hum:Move(Vector3.new(0.01, 0, 0.01), false)
                end

                -- D. Virtual Clicks
                pcall(function()
                    VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                end)

                -- E. Fire ClickDetectors & ProximityPrompts for Speed Stations
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ClickDetector") then
                        pcall(function()
                            if fireclickdetector then
                                fireclickdetector(obj)
                            end
                        end)
                    elseif obj:IsA("ProximityPrompt") then
                        pcall(function()
                            obj.HoldDuration = 0
                            if fireproximityprompt then
                                fireproximityprompt(obj, 0)
                            end
                        end)
                    end
                end

                -- F. Touch Speed / Boost Pads in Workspace
                if root and firetouchinterest then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("TouchTransmitter") then
                            local part = obj.Parent
                            if part and part:IsA("BasePart") then
                                local pname = string.lower(part.Name .. (part.Parent and part.Parent.Name or ""))
                                if string.find(pname, "speed") or string.find(pname, "orb") or string.find(pname, "boost") or string.find(pname, "swing") or string.find(pname, "train") then
                                    pcall(function()
                                        firetouchinterest(root, part, 0)
                                        task.wait(0.002)
                                        firetouchinterest(root, part, 1)
                                    end)
                                end
                            end
                        end
                    end
                end

                -- G. Fire Hooked or Direct Speed Remotes
                if _G.CapturedSpeedRemote then
                    pcall(function()
                        if _G.CapturedSpeedRemote:IsA("RemoteEvent") then
                            _G.CapturedSpeedRemote:FireServer(unpack(_G.CapturedSpeedArgs))
                        elseif _G.CapturedSpeedRemote:IsA("RemoteFunction") then
                            _G.CapturedSpeedRemote:InvokeServer(unpack(_G.CapturedSpeedArgs))
                        end
                    end)
                end

                for _, container in ipairs({ReplicatedStorage, workspace}) do
                    for _, item in ipairs(container:GetDescendants()) do
                        if item:IsA("RemoteEvent") or item:IsA("RemoteFunction") then
                            local lname = string.lower(item.Name)
                            if string.find(lname, "speed") or string.find(lname, "swing") or string.find(lname, "click") or string.find(lname, "gain") or string.find(lname, "train") or string.find(lname, "shoot") then
                                pcall(function()
                                    if item:IsA("RemoteEvent") then
                                        item:FireServer()
                                        item:FireServer(1)
                                        item:FireServer(true)
                                    elseif item:IsA("RemoteFunction") then
                                        item:InvokeServer()
                                        item:InvokeServer(1)
                                        item:InvokeServer(true)
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 3. AUTO REBIRTH
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.AutoRebirthActive then
            pcall(function()
                -- A. Direct Hooked Remote
                if _G.CapturedRebirthRemote then
                    pcall(function()
                        if _G.CapturedRebirthRemote:IsA("RemoteEvent") then
                            _G.CapturedRebirthRemote:FireServer(unpack(_G.CapturedRebirthArgs))
                        elseif _G.CapturedRebirthRemote:IsA("RemoteFunction") then
                            _G.CapturedRebirthRemote:InvokeServer(unpack(_G.CapturedRebirthArgs))
                        end
                    end)
                end

                -- B. Rebirth Remotes in ReplicatedStorage
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local n = string.lower(obj.Name)
                        if string.find(n, "rebirth") or string.find(n, "prestige") or string.find(n, "ascend") or string.find(n, "reset") then
                            pcall(function()
                                if obj:IsA("RemoteEvent") then
                                    obj:FireServer()
                                    obj:FireServer(1)
                                    obj:FireServer(true)
                                elseif obj:IsA("RemoteFunction") then
                                    obj:InvokeServer()
                                    obj:InvokeServer(1)
                                    obj:InvokeServer(true)
                                end
                            end)
                        end
                    end
                end

                -- C. ProximityPrompts for Rebirth Stations
                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local pName = string.lower(prompt.Name .. (prompt.Parent and prompt.Parent.Name or ""))
                        if string.find(pName, "rebirth") or string.find(pName, "prestige") then
                            prompt.HoldDuration = 0
                            if fireproximityprompt then
                                fireproximityprompt(prompt, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =================================================================
-- 4. INFINITE JUMP
-- =================================================================
UserInputService.JumpRequest:Connect(function()
    if _G.InfJumpActive then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- =================================================================
-- MOBILE OPTIMIZED UI ENGINE (BADSHAH TEMPLATE)
-- =================================================================
local CoreGui = game:GetService("CoreGui")

pcall(function()
    if CoreGui:FindFirstChild("BadshahWebSwingGui") then
        CoreGui.BadshahWebSwingGui:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BadshahWebSwingGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Layout Math & Dimensions
local windowWidth = 220
local headerHeight = 42
local footerHeight = 25
local cardPadding = 6
local maxContainerHeight = 180

local totalCardsHeight = 0
for i, feature in ipairs(Features) do
    if feature.Type == "Slider" then
        totalCardsHeight = totalCardsHeight + 46
    else
        totalCardsHeight = totalCardsHeight + 35
    end
    if i < #Features then
        totalCardsHeight = totalCardsHeight + cardPadding
    end
end

local containerHeight = math.min(totalCardsHeight, maxContainerHeight)
local windowHeight = headerHeight + containerHeight + footerHeight + 12

-- Main Container Window
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, windowWidth, 0, windowHeight)
MainWindow.Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
MainWindow.BackgroundColor3 = Color3.fromRGB(15, 14, 22) -- #0F0E16
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 38, 62)
MainStroke.Thickness = 1.2
MainStroke.Parent = MainWindow

-- Header Frame
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, headerHeight)
Header.BackgroundColor3 = Color3.fromRGB(24, 22, 34) -- #181622
Header.BorderSizePixel = 0
Header.ZIndex = 5
Header.Parent = MainWindow

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

-- Header Bottom Straight Edge Cover
local HeaderCover = Instance.new("Frame")
HeaderCover.Size = UDim2.new(1, 0, 0, 8)
HeaderCover.Position = UDim2.new(0, 0, 1, -8)
HeaderCover.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
HeaderCover.BorderSizePixel = 0
HeaderCover.ZIndex = 5
HeaderCover.Parent = Header

-- Header Title
local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -65, 1, 0)
HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = GameName
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextSize = 12
HeaderTitle.Font = Enum.Font.SourceSansBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 6
HeaderTitle.Parent = Header

-- Close Button (Red Square)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -26, 0.5, -10)
CloseButton.BackgroundColor3 = Color3.fromRGB(239, 83, 80)
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 12
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.ZIndex = 7
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

-- Minimize Button (Dark Purple Square)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -50, 0.5, -10)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(38, 35, 52)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeButton.TextSize = 14
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.ZIndex = 7
MinimizeButton.Parent = Header

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 5)
MinimizeCorner.Parent = MinimizeButton

-- Window Dragging Logic (Supports Mobile Touch & PC Mouse)
local dragging = false
local dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainWindow.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Minimize & Close Toggle Logic
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetHeight = isMinimized and headerHeight or windowHeight
    MinimizeButton.Text = isMinimized and "+" or "-"
    TweenService:Create(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, windowWidth, 0, targetHeight)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(MainWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(MainWindow.Position.X.Scale, MainWindow.Position.X.Offset + windowWidth/2, MainWindow.Position.Y.Scale, MainWindow.Position.Y.Offset + windowHeight/2)
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

-- Container & Layout
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -16, 0, containerHeight)
Container.Position = UDim2.new(0, 8, 0, headerHeight + 6)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 2
Container.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
Container.CanvasSize = UDim2.new(0, 0, 0, totalCardsHeight)
Container.Parent = MainWindow

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, cardPadding)
UIListLayout.Parent = Container

-- Footer Frame
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, footerHeight)
Footer.Position = UDim2.new(0, 0, 1, -footerHeight)
Footer.BackgroundTransparency = 1
Footer.BorderSizePixel = 0
Footer.Parent = MainWindow

local FooterText = Instance.new("TextLabel")
FooterText.Size = UDim2.new(1, 0, 1, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "Made By " .. CreatorName
FooterText.TextColor3 = Color3.fromRGB(168, 85, 247) -- Purple Accent
FooterText.TextSize = 11
FooterText.Font = Enum.Font.SourceSansBold
FooterText.TextXAlignment = Enum.TextXAlignment.Center
FooterText.Parent = Footer

-- =================================================================
-- COMPONENT BUILDERS (TOGGLES & SLIDERS)
-- =================================================================
local function createToggle(config)
    local Card = Instance.new("Frame")
    Card.Name = config.Name .. "_Card"
    Card.Size = UDim2.new(1, 0, 0, 35)
    Card.BackgroundColor3 = Color3.fromRGB(24, 22, 34) -- #181622
    Card.BorderSizePixel = 0
    Card.Parent = Container

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -45, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name
    Label.TextColor3 = Color3.fromRGB(240, 240, 255)
    Label.TextSize = 11
    Label.Font = Enum.Font.SourceSansBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    local Checkbox = Instance.new("Frame")
    Checkbox.Name = "Checkbox"
    Checkbox.Size = UDim2.new(0, 16, 0, 16)
    Checkbox.Position = UDim2.new(1, -26, 0.5, -8)
    Checkbox.BackgroundColor3 = Color3.fromRGB(38, 35, 52)
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
    Checkmark.TextSize = 11
    Checkmark.Font = Enum.Font.SourceSansBold
    Checkmark.TextTransparency = 1
    Checkmark.Parent = Checkbox

    local state = config.Default or false

    local function updateState(newState)
        state = newState
        TweenService:Create(Checkbox, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = state and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(38, 35, 52)
        }):Play()
        TweenService:Create(Checkmark, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = state and 0 or 1
        }):Play()

        task.spawn(function()
            pcall(config.Callback, state)
        end)
    end

    if state then updateState(true) end

    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""
    ClickBtn.Parent = Card

    ClickBtn.MouseButton1Click:Connect(function()
        updateState(not state)
    end)

    Card.MouseEnter:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(34, 30, 48)
        }):Play()
    end)

    Card.MouseLeave:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(24, 22, 34)
        }):Play()
    end)
end

local function createSlider(config)
    local Card = Instance.new("Frame")
    Card.Name = config.Name .. "_Slider"
    Card.Size = UDim2.new(1, 0, 0, 46)
    Card.BackgroundColor3 = Color3.fromRGB(24, 22, 34) -- #181622
    Card.BorderSizePixel = 0
    Card.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Card

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -12, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name .. ": " .. tostring(config.Default)
    Label.TextColor3 = Color3.fromRGB(240, 240, 255)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.Parent = Card

    local Track = Instance.new("TextButton")
    Track.Name = "Track"
    Track.Size = UDim2.new(1, -20, 0, 4)
    Track.Position = UDim2.new(0, 10, 0, 28)
    Track.BackgroundColor3 = Color3.fromRGB(38, 35, 52)
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Parent = Card

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 2)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 2)
    FillCorner.Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 8, 0, 8)
    Knob.Position = UDim2.new(1, -4, 0.5, -4)
    Knob.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    Knob.BorderSizePixel = 0
    Knob.Parent = Fill

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local minVal = config.Min or 0
    local maxVal = config.Max or 100
    local currentVal = config.Default or minVal

    local function updateValue(val, animate)
        currentVal = math.clamp(val, minVal, maxVal)
        local displayVal = math.round(currentVal)
        Label.Text = config.Name .. ": " .. tostring(displayVal)

        local percentage = (currentVal - minVal) / (maxVal - minVal)
        local targetSize = UDim2.new(percentage, 0, 1, 0)

        if animate then
            TweenService:Create(Fill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = targetSize
            }):Play()
        else
            Fill.Size = targetSize
        end

        task.spawn(function()
            pcall(config.Callback, displayVal)
        end)
    end

    updateValue(currentVal, false)

    local isDragging = false

    local function processInput(input)
        local trackWidth = Track.AbsoluteSize.X
        if trackWidth > 0 then
            local relativeX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, trackWidth)
            local percentage = relativeX / trackWidth
            local newValue = minVal + (maxVal - minVal) * percentage
            updateValue(newValue, false)
        end
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            processInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            processInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    Card.MouseEnter:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(34, 30, 48)
        }):Play()
    end)

    Card.MouseLeave:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(24, 22, 34)
        }):Play()
    end)
end

-- Render All Components
for _, feature in ipairs(Features) do
    if feature.Type == "Slider" then
        createSlider(feature)
    else
        createToggle(feature)
    end
end

-- Open Scale-Up Animation
MainWindow.Size = UDim2.new(0, 0, 0, 0)
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)

local openTween = TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, windowWidth, 0, windowHeight),
    Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
})
openTween:Play()
