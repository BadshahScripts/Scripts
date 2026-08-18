-- =================================================================
-- CONFIGURATION: Fish For Junk Roblox Script (Mobile Optimized UI)
-- Game: [🎣] Fish For Junk (PlaceId: 132010220154773)
-- Developer: Lucky Blockers!
-- =================================================================
local GameName = "Fish For Junk"
local CreatorName = "Badshah Scripts"

-- Global Feature States
_G.AutoCastActive = false
_G.AutoSellActive = false
_G.FlyActive = false
_G.FlySpeed = 50

local Features = {
    {
        Type = "Toggle",
        Name = "Auto Cast & Fish",
        Default = false,
        Callback = function(state)
            _G.AutoCastActive = state
            print("[Fish For Junk] Auto Cast & Fish:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Sell Junk",
        Default = false,
        Callback = function(state)
            _G.AutoSellActive = state
            print("[Fish For Junk] Auto Sell Junk:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Fly",
        Default = false,
        Callback = function(state)
            _G.FlyActive = state
            print("[Fish For Junk] Fly:", state)
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
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Startup Notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = CreatorName,
        Text = "Fish For Junk Script Loaded!",
        Duration = 4
    })
end)

-- Anti-AFK Protection (Prevents 20-minute idle disconnects)
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

-- 1. CLEAN AUTO CAST & FISH ENGINE
task.spawn(function()
    while true do
        task.wait(0.25)
        if _G.AutoCastActive then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local hrp = char:FindFirstChild("HumanoidRootPart")

                -- 1. Silent Tool Equip (tool.Parent = char does NOT open backpack UI)
                local equippedTool = char:FindFirstChildOfClass("Tool")
                if not equippedTool and backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            local tName = tool.Name:lower()
                            if tName:find("rod") or tName:find("fish") or tName:find("starter") or tName:find("junk") or tName:find("pole") then
                                tool.Parent = char
                                equippedTool = tool
                                break
                            end
                        end
                    end
                end

                -- 2. Direct Tool Activation (Clean & Silent Cast)
                if equippedTool then
                    equippedTool:Activate()
                    
                    -- Trigger only tool-specific internal cast events
                    for _, sub in ipairs(equippedTool:GetDescendants()) do
                        if sub:IsA("RemoteEvent") then
                            local sname = sub.Name:lower()
                            if sname:find("cast") or sname:find("reel") or sname:find("bite") or sname:find("pull") then
                                sub:FireServer()
                                sub:FireServer(100)
                                sub:FireServer(true)
                                if hrp then sub:FireServer(hrp.Position + hrp.CFrame.LookVector * 20) end
                            end
                        end
                    end
                end

                -- 3. Dedicated Cast & Reel Remotes Only (Safe list)
                local targetCastPos = hrp and (hrp.Position + hrp.CFrame.LookVector * 25) or Vector3.new(0, 0, 0)
                for _, container in ipairs({ReplicatedStorage, Workspace}) do
                    if container and _G.AutoCastActive then
                        for _, remote in ipairs(container:GetDescendants()) do
                            if remote:IsA("RemoteEvent") then
                                local rname = remote.Name:lower()
                                -- Only fire exact cast / reel events, NEVER fire generic inventory / bag / fish remotes
                                if rname == "cast" or rname == "reel" or rname == "castline" or rname == "reeline" or rname == "castrod" or rname == "reelrod" or rname:find("castline") or rname:find("rodcast") or rname:find("rodreel") then
                                    pcall(function()
                                        remote:FireServer()
                                        remote:FireServer(100)
                                        remote:FireServer(true)
                                        remote:FireServer("Cast")
                                        remote:FireServer("Reel")
                                        remote:FireServer("Perfect")
                                        remote:FireServer(targetCastPos)
                                    end)
                                end
                            end
                        end
                    end
                end

                -- 4. Auto-Close any Backpack / Inventory / Odds GUIs that pop up
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, obj in ipairs(playerGui:GetDescendants()) do
                        if obj:IsA("GuiObject") and obj.Visible then
                            local oname = obj.Name:lower()
                            if oname == "inventory" or oname == "backpack" or oname:find("itemodds") or oname:find("odds") or (oname:find("inv") and not oname:find("main")) then
                                obj.Visible = false
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. AUTO SELL JUNK ENGINE
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoSellActive then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                -- A. Remotes for Selling
                local searchContainers = {ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui"), Workspace}
                for _, container in ipairs(searchContainers) do
                    if container and _G.AutoSellActive then
                        for _, remote in ipairs(container:GetDescendants()) do
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                local rname = remote.Name:lower()
                                if rname:find("sell") or rname:find("merchant") or rname:find("trade") or rname:find("cashout") or rname:find("dump") then
                                    pcall(function()
                                        if remote:IsA("RemoteEvent") then
                                            remote:FireServer()
                                            remote:FireServer("All")
                                            remote:FireServer(true)
                                        elseif remote:IsA("RemoteFunction") then
                                            remote:InvokeServer()
                                            remote:InvokeServer("All")
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
                
                -- B. Workspace Sell Pads & TouchTransmitters
                if hrp and firetouchinterest then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not _G.AutoSellActive then break end
                        if obj:IsA("TouchTransmitter") then
                            local pad = obj.Parent
                            if pad and pad:IsA("BasePart") then
                                local pname = pad.Name:lower()
                                local parentName = pad.Parent and pad.Parent.Name:lower() or ""
                                if pname:find("sell") or parentName:find("sell") or pname:find("merchant") or parentName:find("merchant") or pname:find("shop") or parentName:find("shop") then
                                    pcall(function()
                                        firetouchinterest(hrp, pad, 0)
                                        task.wait()
                                        firetouchinterest(hrp, pad, 1)
                                    end)
                                end
                            end
                        end
                    end
                end
                
                -- C. ProximityPrompts for Selling / Merchant
                if fireproximityprompt then
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if not _G.AutoSellActive then break end
                        if prompt:IsA("ProximityPrompt") then
                            local promptText = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                            if promptText:find("sell") or promptText:find("merchant") or promptText:find("cash") then
                                pcall(function()
                                    fireproximityprompt(prompt, 0)
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. SMOOTH FLY ENGINE (Mobile & PC Compatible)
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
                    -- Attach BodyVelocity & BodyGyro for stable physics flight
                    local bv = hrp:FindFirstChild("JunkFlyBV") or Instance.new("BodyVelocity")
                    bv.Name = "JunkFlyBV"
                    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                    bv.Parent = hrp
                    
                    local bg = hrp:FindFirstChild("JunkFlyBG") or Instance.new("BodyGyro")
                    bg.Name = "JunkFlyBG"
                    bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                    bg.P = 10000
                    bg.Parent = hrp
                    
                    hum.PlatformStand = true
                    bg.CFrame = camera.CFrame
                    
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        bv.Velocity = camera.CFrame.LookVector * _G.FlySpeed
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        else
            -- Clean up fly forces when disabled
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand = false
                end
                if hrp then
                    local bv = hrp:FindFirstChild("JunkFlyBV")
                    if bv then bv:Destroy() end
                    local bg = hrp:FindFirstChild("JunkFlyBG")
                    if bg then bg:Destroy() end
                end
            end)
        end
    end
end)

-- Handle Character Respawn for Fly cleanup
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if not _G.FlyActive then
        local hrp = newChar:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("JunkFlyBV")
            if bv then bv:Destroy() end
            local bg = hrp:FindFirstChild("JunkFlyBG")
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
for _, name in ipairs({"RobloxScriptUI_Badshah", "JunejoHubUI_FishForJunk", "FishForJunkUI_Badshah"}) do
    pcall(function()
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end)
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishForJunkUI_Badshah"
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

-- Title Label
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

-- Content Container (Scrolling or Standard Frame)
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

    elseif feature.Type == "Slider" then
        local Card = Instance.new("Frame")
        Card.Name = feature.Name .. "_SliderCard"
        Card.Size = UDim2.new(1, 0, 0, 46)
        Card.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
        Card.BorderSizePixel = 0
        Card.LayoutOrder = i
        Card.Parent = Container

        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 8)
        CardCorner.Parent = Card

        local CardLabel = Instance.new("TextLabel")
        CardLabel.Name = "Label"
        CardLabel.Size = UDim2.new(1, -50, 0, 20)
        CardLabel.Position = UDim2.new(0, 10, 0, 4)
        CardLabel.BackgroundTransparency = 1
        CardLabel.Text = feature.Name
        CardLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        CardLabel.Font = Enum.Font.GothamMedium
        CardLabel.TextSize = 11
        CardLabel.TextXAlignment = Enum.TextXAlignment.Left
        CardLabel.TextYAlignment = Enum.TextYAlignment.Center
        CardLabel.Parent = Card

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Name = "Value"
        ValueLabel.Size = UDim2.new(0, 35, 0, 20)
        ValueLabel.Position = UDim2.new(1, -45, 0, 4)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(feature.Default)
        ValueLabel.TextColor3 = Color3.fromRGB(168, 85, 247)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 11
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
        ValueLabel.Parent = Card

        local Track = Instance.new("TextButton")
        Track.Name = "Track"
        Track.Size = UDim2.new(1, -20, 0, 4)
        Track.Position = UDim2.new(0, 10, 0, 30)
        Track.BackgroundColor3 = Color3.fromRGB(35, 32, 48)
        Track.BorderSizePixel = 0
        Track.AutoButtonColor = false
        Track.Text = ""
        Track.Parent = Card

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track

        local Fill = Instance.new("Frame")
        Fill.Name = "Fill"
        local initialPercent = math.clamp((feature.Default - feature.Min) / (feature.Max - feature.Min), 0, 1)
        Fill.Size = UDim2.new(initialPercent, 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
        Fill.BorderSizePixel = 0
        Fill.Parent = Track

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill

        local Handle = Instance.new("Frame")
        Handle.Name = "Handle"
        Handle.Size = UDim2.new(0, 10, 0, 10)
        Handle.Position = UDim2.new(1, -5, 0.5, -5)
        Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Handle.BorderSizePixel = 0
        Handle.Parent = Fill

        local HandleCorner = Instance.new("UICorner")
        HandleCorner.CornerRadius = UDim.new(1, 0)
        HandleCorner.Parent = Handle

        local isDragging = false

        local function updateSlider(input)
            local trackAbsPos = Track.AbsolutePosition.X
            local trackAbsSize = Track.AbsoluteSize.X
            local mouseX = input.Position.X
            local percent = math.clamp((mouseX - trackAbsPos) / trackAbsSize, 0, 1)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            local value = math.floor(feature.Min + (feature.Max - feature.Min) * percent)
            ValueLabel.Text = tostring(value)
            if feature.Callback then
                task.spawn(feature.Callback, value)
            end
        end

        Track.InputBegan:Connect(function(input)
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
