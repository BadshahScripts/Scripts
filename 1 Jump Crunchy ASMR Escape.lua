-- =================================================================
-- CONFIGURATION: +1 Jump Crunchy ASMR Escape Script (Badshah Mobile UI)
-- =================================================================
local GameName = "Jump Crunchy ASMR"
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
_G.AutoJumpActive = false
_G.AutoRebirthActive = false
_G.InfWinsActive = false
_G.InfiniteJumpActive = false

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
        Name = "Inf Wins",
        Default = false,
        Callback = function(state)
            _G.InfWinsActive = state
            print("[Jump Crunchy ASMR] Inf Wins set to:", state)
            
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not state then
                    local plat = workspace:FindFirstChild("Badshah_PeakPlatform")
                    if plat then plat:Destroy() end
                end
            end)
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Jump",
        Default = false,
        Callback = function(state)
            _G.AutoJumpActive = state
            print("[Jump Crunchy ASMR] Auto Jump set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Rebirth",
        Default = false,
        Callback = function(state)
            _G.AutoRebirthActive = state
            print("[Jump Crunchy ASMR] Auto Rebirth set to:", state)
        end
    },
    {
        Type = "Toggle",
        Name = "Infinite Jump",
        Default = false,
        Callback = function(state)
            _G.InfiniteJumpActive = state
            print("[Jump Crunchy ASMR] Infinite Jump set to:", state)
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
        _G.AutoJumpActive = false
        _G.AutoRebirthActive = false
        _G.InfWinsActive = false
        _G.InfiniteJumpActive = false
        
        local plat = workspace:FindFirstChild("Badshah_PeakPlatform")
        if plat then plat:Destroy() end
        
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
-- UNIVERSAL REMOTE DISPATCHER HELPER
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
-- 1. AUTO JUMP ENGINE (+1 JUMP POWER FARM ONLY - NO WIN PADS)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(0.08)
        if _G.AutoJumpActive then
            pcall(function()
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if char and humanoid and root and humanoid.Health > 0 then
                    -- Layer 1: Force Jump State & Click Simulation
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)

                    -- Layer 2: Remote Event Jump Dispatcher
                    fireGameRemotes(
                        {"addjump", "givejump", "jumppower", "train", "click", "step", "crunch", "asmr", "squishy"},
                        {
                            {},
                            {1}, {5}, {10}, {50},
                            {true},
                            {"Jump"}, {"Click"}
                        }
                    )

                    -- Layer 3: Touch Trampolines / Bounce Pads ONLY (Explicitly exclude Win pads)
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local n = string.lower(obj.Name)
                            if (string.find(n, "trampoline") or string.find(n, "bounce")) and not string.find(n, "win") then
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
-- 2. INF WINS ENGINE (STRICT +1,000,000 WINS TOP PAD ONLY TELEPORT)
-- =================================================================
local cached1MPad = nil
local cached1MCFrame = nil
local lastScanTime = 0

-- Check if text or name represents low tier wins (e.g., +1, +2, +5, +100, etc.)
local function isLowTierWin(text, name)
    local t = string.lower(text or "")
    local n = string.lower(name or "")
    
    if string.find(t, "1000000") or string.find(t, "1,000,000") or string.find(t, "1m") or string.find(n, "1000000") or string.find(n, "1m") then
        return false -- This is the 1M pad!
    end

    if string.find(t, "+1 win") or string.find(t, "+2 win") or string.find(t, "+5 win") or
       string.find(t, "+10 win") or string.find(t, "+25 win") or string.find(t, "+50 win") or
       string.find(t, "+100 win") or string.find(t, "+250 win") or string.find(t, "+500 win") or
       string.find(t, "+1k") or string.find(t, "+5k") or string.find(t, "+10k") or
       string.find(n, "win1") or string.find(n, "pad1") or string.find(n, "start") then
        return true -- Low tier win pad to ignore!
    end

    return false
end

local function findExact1MillionWinPad()
    local bestPad = nil
    local bestCFrame = nil
    local maxPriority = -1
    local highestY = -999999

    -- 1. Exact Gui Text Match for +1000000 Wins
    for _, gui in ipairs(workspace:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            local text = string.lower(gui.Text)
            if string.find(text, "1000000") or string.find(text, "1,000,000") or string.find(text, "1m") then
                local adornee = gui:FindFirstAncestorWhichIsA("BasePart")
                if not adornee and gui.Parent and gui.Parent:IsA("BillboardGui") then
                    adornee = gui.Parent.Adornee or gui.Parent.Parent:FindFirstChildWhichIsA("BasePart") or gui.Parent:FindFirstAncestorWhichIsA("BasePart")
                end
                if adornee and adornee:IsA("BasePart") and adornee.Position.Y > 200 then
                    return adornee, adornee.CFrame
                end
            end
        end
    end

    -- 2. Find by Part Name & Position (Ignore all pads below 400 studs or with low tier text)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character or ScreenGui) then
            local n = string.lower(obj.Name)
            local pY = obj.Position.Y

            -- Only consider elevated parts near the peak of the tower
            if pY > 300 then
                local isLow = false
                for _, child in ipairs(obj:GetDescendants()) do
                    if child:IsA("TextLabel") and isLowTierWin(child.Text, n) then
                        isLow = true
                        break
                    end
                end

                if not isLow then
                    local priority = pY -- The higher the altitude, the higher the priority!
                    if string.find(n, "1000000") or string.find(n, "1m") or string.find(n, "million") then
                        priority = priority + 10000
                    end
                    if string.find(n, "win") or string.find(n, "pad") or string.find(n, "finish") or string.find(n, "top") then
                        priority = priority + 2000
                    end

                    if priority > maxPriority then
                        maxPriority = priority
                        highestY = pY
                        bestPad = obj
                        bestCFrame = obj.CFrame
                    end
                end
            end
        end
    end

    -- 3. Highest BasePart at the Top Peak of the Tower
    if not bestPad or highestY < 300 then
        local maxY = -99999
        local topObj = nil
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Parent:FindFirstChildOfClass("Humanoid") then
                if part.Position.Y > maxY then
                    maxY = part.Position.Y
                    topObj = part
                end
            end
        end
        if topObj and maxY > 200 then
            bestPad = topObj
            bestCFrame = topObj.CFrame
        end
    end

    return bestPad, bestCFrame
end

task.spawn(function()
    local toggleStep = false
    while true do
        task.wait(0.08)
        if _G.InfWinsActive then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")

                if char and root and humanoid and humanoid.Health > 0 then
                    -- Periodically scan for the +1M pad
                    if not cached1MPad or not cached1MPad.Parent or (tick() - lastScanTime > 2) then
                        local pad, cf = findExact1MillionWinPad()
                        if pad and cf then
                            cached1MPad = pad
                            cached1MCFrame = cf
                        end
                        lastScanTime = tick()
                    end

                    -- If found, lock and teleport exclusively onto the 1M Win Pad
                    if cached1MCFrame then
                        toggleStep = not toggleStep
                        local yOff = toggleStep and 2.0 or 0.6
                        root.CFrame = cached1MCFrame + Vector3.new(0, yOff, 0)
                        root.Velocity = Vector3.new(0, 0, 0)

                        -- Touch ONLY the 1M Pad
                        if cached1MPad and firetouchinterest then
                            firetouchinterest(cached1MPad, root, 0)
                            task.wait()
                            firetouchinterest(cached1MPad, root, 1)
                        end
                    else
                        -- If not yet scanned at ground, teleport high up into tower peak to stream it in
                        if root.Position.Y < 1000 then
                            root.CFrame = CFrame.new(root.Position.X, 3500, root.Position.Z)
                            root.Velocity = Vector3.new(0, 0, 0)
                            task.wait(0.3)
                        end
                    end

                    -- Remote Dispatcher exclusively for 1,000,000 Wins
                    fireGameRemotes(
                        {
                            "win", "claimwin", "addwin", "givewin", "escape",
                            "completetower", "claimtrophy", "finish", "getwin", "collectwin", "awardwin"
                        },
                        {
                            {1000000},
                            {999999},
                            {"1000000"},
                            {"1M"},
                            {1000000, true},
                            {"All", 1000000},
                            {true},
                            {}
                        }
                    )
                end
            end)
        end
    end
end)

-- =================================================================
-- 3. AUTO REBIRTH ENGINE (MULTI-LAYER REBIRTH DISPATCHER)
-- =================================================================
task.spawn(function()
    while true do
        task.wait(1.5)
        if _G.AutoRebirthActive then
            pcall(function()
                -- LAYER 1: Remote Event Invocations
                fireGameRemotes(
                    {
                        "rebirth", "dorebirth", "buyrebirth", "requestrebirth", "prestige",
                        "rankup", "evolve", "playerrebirth", "claimrebirth", "onrebirth"
                    },
                    {
                        {},
                        {1}, {2}, {3}, {5}, {10},
                        {true},
                        {"1"}, {"Rebirth"}, {"Prestige"},
                        {1, true}, {"All"}
                    }
                )

                -- LAYER 2: In-Game GUI Rebirth Button Clicker
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, btn in ipairs(playerGui:GetDescendants()) do
                        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and not btn:IsDescendantOf(ScreenGui) and btn.Parent ~= ScreenGui then
                            local bName = string.lower(btn.Name)
                            local bText = (btn:IsA("TextButton") and string.lower(btn.Text)) or ""

                            if not string.find(bName, "card_") and not string.find(bName, "minimize") and not string.find(bName, "close") then
                                local isRebirthBtn = (
                                    string.find(bName, "rebirth") or string.find(bName, "prestige") or
                                    string.find(bText, "rebirth") or string.find(bText, "prestige") or
                                    string.find(bText, "re-birth")
                                )

                                if isRebirthBtn then
                                    pcall(function()
                                        if firesignal then
                                            firesignal(btn.MouseButton1Click)
                                            firesignal(btn.Activated)
                                        end
                                        if getconnections then
                                            for _, con in ipairs(getconnections(btn.MouseButton1Click)) do
                                                con:Fire()
                                            end
                                            for _, con in ipairs(getconnections(btn.Activated)) do
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

-- =================================================================
-- 4. INFINITE JUMP ENGINE (MOBILE & PC JUMP REQUEST LISTENER)
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

-- Startup visual notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Badshah Scripts",
        Text = "+1 Jump Crunchy ASMR Escape script loaded!",
        Duration = 5
    })
end)

print("========================================")
print("[Badshah Scripts] " .. GameName .. " Loaded Successfully!")
print("========================================")
