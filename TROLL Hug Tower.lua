-- =================================================================
-- CONFIGURATION: TROLL Hug Tower Roblox Script (Mobile Optimized UI)
-- Game: 😈 TROLL Hug Tower (PlaceId: 103037106396302)
-- Developer: Trash Container
-- =================================================================
local GameName = "TROLL Hug Tower"
local CreatorName = "Badshah Scripts"

-- Global Feature States
_G.InfiniteJumpActive = false
_G.FlyActive = false
_G.FlySpeed = 50

local Features = {
    {
        Type = "Button",
        Name = "Instant Win",
        Callback = function()
            task.spawn(function()
                pcall(function()
                    local player = game.Players.LocalPlayer
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not hrp then return end

                    -- A. Collect all Checkpoints & Platforms sorted by Height
                    local stageParts = {}
                    local topPart = nil
                    local highestY = -999999

                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local pname = obj.Name:lower()
                            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                            
                            -- Detect Checkpoints & Win areas
                            if pname:find("win") or parentName:find("win") or pname:find("finish") or parentName:find("finish") or pname:find("top") or pname:find("end") or pname:find("summit") or pname:find("victory") or pname:find("stage") or pname:find("checkpoint") or pname:find("crown") then
                                table.insert(stageParts, obj)
                                if obj.Position.Y > highestY then
                                    highestY = obj.Position.Y
                                    topPart = obj
                                end
                            elseif obj:FindFirstChildOfClass("TouchTransmitter") and obj.Position.Y > highestY and obj.Position.Y > 50 then
                                highestY = obj.Position.Y
                                topPart = obj
                            end
                        end
                    end

                    -- Sort stage parts from lowest to highest
                    table.sort(stageParts, function(a, b)
                        return a.Position.Y < b.Position.Y
                    end)

                    -- B. Sequentially Touch Checkpoints (Bypasses Anti-Skip Checks)
                    if firetouchinterest then
                        for _, part in ipairs(stageParts) do
                            pcall(function()
                                firetouchinterest(hrp, part, 0)
                                firetouchinterest(hrp, part, 1)
                            end)
                        end
                    end

                    -- C. Teleport Safely to Highest Point / Win Platform
                    if topPart then
                        -- Spawn a temporary invisible safe floor under player so they don't fall
                        local safePlatform = Instance.new("Part")
                        safePlatform.Name = "SafeWinPlatform"
                        safePlatform.Size = Vector3.new(20, 1, 20)
                        safePlatform.Anchored = true
                        safePlatform.CanCollide = true
                        safePlatform.Transparency = 0.8
                        safePlatform.Color = Color3.fromRGB(168, 85, 247)
                        safePlatform.CFrame = topPart.CFrame + Vector3.new(0, 1, 0)
                        safePlatform.Parent = workspace

                        -- Teleport player directly onto the platform
                        hrp.CFrame = topPart.CFrame + Vector3.new(0, 4, 0)
                        hrp.Velocity = Vector3.new(0, 0, 0)

                        -- Repeatedly touch Win Pad
                        if firetouchinterest then
                            for _ = 1, 5 do
                                firetouchinterest(hrp, topPart, 0)
                                task.wait(0.05)
                                firetouchinterest(hrp, topPart, 1)
                            end
                        end

                        -- Trigger ProximityPrompts if on the win pad
                        if fireproximityprompt then
                            for _, prompt in ipairs(topPart:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then
                                    fireproximityprompt(prompt, 0)
                                end
                            end
                            if topPart.Parent then
                                for _, prompt in ipairs(topPart.Parent:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then
                                        fireproximityprompt(prompt, 0)
                                    end
                                end
                            end
                        end

                        -- Clean up safe platform after 5 seconds
                        task.delay(5, function()
                            pcall(function() safePlatform:Destroy() end)
                        end)
                    end

                    -- D. Fire Win Remotes in ReplicatedStorage
                    for _, container in ipairs({game:GetService("ReplicatedStorage"), workspace}) do
                        for _, remote in ipairs(container:GetDescendants()) do
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                local rname = remote.Name:lower()
                                if rname:find("win") or rname:find("finish") or rname:find("reach") or rname:find("claim") or rname:find("reward") or rname:find("tower") or rname:find("complete") then
                                    pcall(function()
                                        if remote:IsA("RemoteEvent") then
                                            remote:FireServer()
                                            remote:FireServer(true)
                                            remote:FireServer("Win")
                                            remote:FireServer(1)
                                        elseif remote:IsA("RemoteFunction") then
                                            remote:InvokeServer()
                                            remote:InvokeServer("Win")
                                        end
                                    end)
                                end
                            end
                        end
                    end

                    -- Notification feedback
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = CreatorName,
                            Text = "Teleported to Top & Win Claimed!",
                            Duration = 3
                        })
                    end)
                end)
            end)
            print("[TROLL Hug Tower] Enhanced Instant Win Executed!")
        end
    },
    {
        Type = "Toggle",
        Name = "Fly",
        Default = false,
        Callback = function(state)
            _G.FlyActive = state
            print("[TROLL Hug Tower] Fly:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Infinite Jump",
        Default = false,
        Callback = function(state)
            _G.InfiniteJumpActive = state
            print("[TROLL Hug Tower] Infinite Jump:", state)
        end
    }
}

-- =================================================================
-- CORE SERVICES & PLAYER SETUP
-- =================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Startup Notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = CreatorName,
        Text = "TROLL Hug Tower Script Loaded!",
        Duration = 4
    })
end)

-- Anti-AFK Protection
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end)
    end)
end)

-- =================================================================
-- AUTOMATION ENGINES
-- =================================================================

-- 1. INFINITE JUMP ENGINE
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJumpActive and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end
end)

-- 2. SMOOTH FLY ENGINE (Mobile & PC Joystick / Keyboard)
task.spawn(function()
    while true do
        task.wait(0.05)
        if _G.FlyActive then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local camera = Workspace.CurrentCamera
                
                if hrp and hum and camera then
                    local bv = hrp:FindFirstChild("TowerFlyBV") or Instance.new("BodyVelocity")
                    bv.Name = "TowerFlyBV"
                    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    bv.Parent = hrp
                    
                    local bg = hrp:FindFirstChild("TowerFlyBG") or Instance.new("BodyGyro")
                    bg.Name = "TowerFlyBG"
                    bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                    bg.P = 10000
                    bg.Parent = hrp
                    
                    hum.PlatformStand = true
                    bg.CFrame = camera.CFrame
                    
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        bv.Velocity = camera.CFrame.LookVector * (_G.FlySpeed or 50)
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
                    local bv = hrp:FindFirstChild("TowerFlyBV")
                    if bv then bv:Destroy() end
                    local bg = hrp:FindFirstChild("TowerFlyBG")
                    if bg then bg:Destroy() end
                end
            end)
        end
    end
end)

-- Fly Respawn Cleanup
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if not _G.FlyActive then
        local hrp = newChar:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("TowerFlyBV")
            if bv then bv:Destroy() end
            local bg = hrp:FindFirstChild("TowerFlyBG")
            if bg then bg:Destroy() end
        end
    end
end)

-- =================================================================
-- UI GENERATOR ENGINE (Mobile Optimized #0F0E16 - 220px Width)
-- =================================================================

-- Safe UI Parent getter
local function GetUIContainer()
    local success, res = pcall(function()
        if gethui then return gethui() end
        if syn and syn.protect_gui then return CoreGui end
        return CoreGui
    end)
    if success and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local UIContainer = GetUIContainer()

-- Cleanup previous UI instances
for _, name in ipairs({"TrollHugTowerUI_Badshah", "RobloxScriptUI_Badshah", "JunejoHubUI_HugTower"}) do
    pcall(function()
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end)
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrollHugTowerUI_Badshah"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    pcall(function()
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    end)
else
    ScreenGui.Parent = UIContainer
end

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

-- Header Frame
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1
Header.Parent = MainWindow

-- Title Label (Lavender Purple GothamBold)
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

-- Minimize Button
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

-- Close Button
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
CloseText.Text = "×"
CloseText.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseText.Font = Enum.Font.GothamBold
CloseText.TextSize = 14
CloseText.TextXAlignment = Enum.TextXAlignment.Center
CloseText.TextYAlignment = Enum.TextYAlignment.Center
CloseText.Parent = CloseButton

-- Divider Line
local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(1, -20, 0, 1)
Divider.Position = UDim2.new(0, 10, 0, 42)
Divider.BackgroundColor3 = Color3.fromRGB(30, 28, 42)
Divider.BorderSizePixel = 0
Divider.Parent = MainWindow

-- Content Container
local Container
if scrollEnabled then
    Container = Instance.new("ScrollingFrame")
    Container.ScrollBarThickness = 2
    Container.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
    Container.CanvasSize = UDim2.new(0, 0, 0, totalContentHeight)
else
    Container = Instance.new("Frame")
end
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 0, containerHeight)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ClipsDescendants = true
Container.Parent = MainWindow

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.Parent = Container

-- Dynamic Component Generators
for i, feature in ipairs(Features) do
    if feature.Type == "Toggle" then
        local Card = Instance.new("TextButton")
        Card.Name = feature.Name .. "_Card"
        Card.Size = UDim2.new(1, 0, 0, 35)
        Card.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
        Card.BorderSizePixel = 0
        Card.AutoButtonColor = false
        Card.Text = ""
        Card.LayoutOrder = i
        Card.Parent = Container

        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 8)
        CardCorner.Parent = Card

        local CardLabel = Instance.new("TextLabel")
        CardLabel.Name = "Label"
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
        Checkbox.Position = UDim2.new(1, -26, 0.5, -8)
        Checkbox.BackgroundColor3 = feature.Default and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(35, 32, 48)
        Checkbox.BorderSizePixel = 0
        Checkbox.Parent = Card

        local CheckboxCorner = Instance.new("UICorner")
        CheckboxCorner.CornerRadius = UDim.new(0, 4)
        CheckboxCorner.Parent = Checkbox

        local Checkmark = Instance.new("TextLabel")
        Checkmark.Name = "Checkmark"
        Checkmark.Size = UDim2.new(1, 0, 1, 0)
        Checkmark.BackgroundTransparency = 1
        Checkmark.Text = "✓"
        Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
        Checkmark.Font = Enum.Font.GothamBold
        Checkmark.TextSize = 10
        Checkmark.TextTransparency = feature.Default and 0 or 1
        Checkmark.TextXAlignment = Enum.TextXAlignment.Center
        Checkmark.TextYAlignment = Enum.TextYAlignment.Center
        Checkmark.Parent = Checkbox

        local isToggled = feature.Default or false

        local function updateToggle()
            if isToggled then
                TweenService:Create(Checkbox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(168, 85, 247)}):Play()
                TweenService:Create(Checkmark, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
            else
                TweenService:Create(Checkbox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 32, 48)}):Play()
                TweenService:Create(Checkmark, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            end
            if feature.Callback then
                task.spawn(feature.Callback, isToggled)
            end
        end

        Card.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            updateToggle()
        end)

        Card.MouseEnter:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 29, 45)}):Play()
        end)
        Card.MouseLeave:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 22, 34)}):Play()
        end)

    elseif feature.Type == "Button" then
        local Card = Instance.new("TextButton")
        Card.Name = feature.Name .. "_ButtonCard"
        Card.Size = UDim2.new(1, 0, 0, 35)
        Card.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
        Card.BorderSizePixel = 0
        Card.AutoButtonColor = false
        Card.Text = ""
        Card.LayoutOrder = i
        Card.Parent = Container

        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 8)
        CardCorner.Parent = Card

        local CardLabel = Instance.new("TextLabel")
        CardLabel.Name = "Label"
        CardLabel.Size = UDim2.new(1, 0, 1, 0)
        CardLabel.BackgroundTransparency = 1
        CardLabel.Text = feature.Name
        CardLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        CardLabel.Font = Enum.Font.GothamMedium
        CardLabel.TextSize = 11
        CardLabel.TextXAlignment = Enum.TextXAlignment.Center
        CardLabel.TextYAlignment = Enum.TextYAlignment.Center
        CardLabel.Parent = Card

        Card.MouseButton1Click:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(168, 85, 247)}):Play()
            task.delay(0.1, function()
                TweenService:Create(Card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 22, 34)}):Play()
            end)
            if feature.Callback then
                task.spawn(feature.Callback)
            end
        end)

        Card.MouseEnter:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 29, 45)}):Play()
        end)
        Card.MouseLeave:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 22, 34)}):Play()
        end)
    end
end

-- Footer
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

-- =================================================================
-- WINDOW DRAGGING (Mobile & PC Touch / Mouse)
-- =================================================================
local isWindowDragging = false
local dragStartPos = nil
local frameStartPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isWindowDragging = true
        dragStartPos = input.Position
        frameStartPos = MainWindow.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isWindowDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isWindowDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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

-- Launch Fade-In Animation
MainWindow.Size = UDim2.new(0, 0, 0, 0)
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(MainWindow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 220, 0, windowHeight),
    Position = UDim2.new(0.5, -110, 0.5, -windowHeight/2)
}):Play()

-- Minimize Toggle Animation
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeText.Text = "+"
        Container.Visible = false
        Footer.Visible = false
        Divider.Visible = false
        TweenService:Create(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 220, 0, 42)
        }):Play()
    else
        MinimizeText.Text = "-"
        local expandTween = TweenService:Create(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 220, 0, windowHeight)
        })
        expandTween:Play()
        expandTween.Completed:Connect(function()
            if not isMinimized then
                Container.Visible = true
                Footer.Visible = true
                Divider.Visible = true
            end
        end)
    end
end)

-- Close Animation (Smooth Collapse & Destroy)
CloseButton.MouseButton1Click:Connect(function()
    local currentPos = MainWindow.Position
    local currentSize = MainWindow.Size
    local targetPos = UDim2.new(currentPos.X.Scale, currentPos.X.Offset + currentSize.X.Offset/2, currentPos.Y.Scale, currentPos.Y.Offset + currentSize.Y.Offset/2)
    
    local closeTween = TweenService:Create(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = targetPos
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)
