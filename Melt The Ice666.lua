-- Melt The Ice Script Hub
-- UI Design & Features by Badshah Scripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Global Feature Flags
local Flags = {
    AutoMelt = false,
    AutoCollect = false,
    AutoRebirth = false,
    WalkSpeed = 16
}

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeltTheIceHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 370)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 20, 37)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 16)
UICorner_Main.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 0, 35)
Title.Position = UDim2.new(0, 16, 0, 12)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Melt The Ice"
Title.TextColor3 = Color3.fromRGB(170, 95, 255)
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -40, 0, 15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(242, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

local UICorner_Close = Instance.new("UICorner")
UICorner_Close.CornerRadius = UDim.new(0, 8)
UICorner_Close.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -74, 0, 15)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 52)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame

local UICorner_Min = Instance.new("UICorner")
UICorner_Min.CornerRadius = UDim.new(0, 8)
UICorner_Min.Parent = MinBtn

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    MainFrame:TweenSize(minimized and UDim2.new(0, 320, 0, 55) or UDim2.new(0, 320, 0, 370), "Out", "Quad", 0.2, true)
end)

-- Toggle Component Helper
local function createToggle(name, yPos, flagKey)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -32, 0, 42)
    Row.Position = UDim2.new(0, 16, 0, yPos)
    Row.BackgroundColor3 = Color3.fromRGB(33, 27, 49)
    Row.Parent = MainFrame

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 10)
    RowCorner.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(225, 225, 235)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Box = Instance.new("TextButton")
    Box.Size = UDim2.new(0, 24, 0, 24)
    Box.Position = UDim2.new(1, -32, 0.5, -12)
    Box.BackgroundColor3 = Flags[flagKey] and Color3.fromRGB(170, 95, 255) or Color3.fromRGB(42, 35, 62)
    Box.Text = Flags[flagKey] and "✓" or ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.GothamBold
    Box.TextSize = 14
    Box.Parent = Row

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = Box

    Box.MouseButton1Click:Connect(function()
        Flags[flagKey] = not Flags[flagKey]
        Box.Text = Flags[flagKey] and "✓" or ""
        Box.BackgroundColor3 = Flags[flagKey] and Color3.fromRGB(170, 95, 255) or Color3.fromRGB(42, 35, 62)
    end)
end

-- Render UI Items
createToggle("Auto Melt", 58, "AutoMelt")
createToggle("Auto Collect Drops", 108, "AutoCollect")
createToggle("Auto Rebirth", 158, "AutoRebirth")

-- WalkSpeed Slider
local SliderRow = Instance.new("Frame")
SliderRow.Size = UDim2.new(1, -32, 0, 65)
SliderRow.Position = UDim2.new(0, 16, 0, 208)
SliderRow.BackgroundColor3 = Color3.fromRGB(33, 27, 49)
SliderRow.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 10)
SliderCorner.Parent = SliderRow

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 120, 0, 25)
SpeedLabel.Position = UDim2.new(0, 12, 0, 8)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SliderRow

local ValueLabel = Instance.new("TextLabel")
ValueLabel.Size = UDim2.new(0, 50, 0, 25)
ValueLabel.Position = UDim2.new(1, -62, 0, 8)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Font = Enum.Font.GothamBold
ValueLabel.Text = "16"
ValueLabel.TextColor3 = Color3.fromRGB(170, 95, 255)
ValueLabel.TextSize = 14
ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
ValueLabel.Parent = SliderRow

local Track = Instance.new("Frame")
Track.Size = UDim2.new(1, -24, 0, 4)
Track.Position = UDim2.new(0, 12, 0, 44)
Track.BackgroundColor3 = Color3.fromRGB(48, 40, 70)
Track.BorderSizePixel = 0
Track.Parent = SliderRow

local Dot = Instance.new("TextButton")
Dot.Size = UDim2.new(0, 16, 0, 16)
Dot.Position = UDim2.new(0, 0, 0.5, -8)
Dot.BackgroundColor3 = Color3.fromRGB(240, 240, 255)
Dot.Text = ""
Dot.Parent = Track

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = Dot

local dragging = false
local minSpeed = 16
local maxSpeed = 150

local function updateSlider(input)
    local posX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
    Dot.Position = UDim2.new(posX, -8, 0.5, -8)
    Flags.WalkSpeed = math.floor(minSpeed + ((maxSpeed - minSpeed) * posX))
    ValueLabel.Text = tostring(Flags.WalkSpeed)
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Flags.WalkSpeed
    end
end

Dot.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 30)
Footer.Position = UDim2.new(0, 0, 1, -35)
Footer.BackgroundTransparency = 1
Footer.Font = Enum.Font.GothamBold
Footer.Text = "Made By Badshah Scripts"
Footer.TextColor3 = Color3.fromRGB(150, 85, 230)
Footer.TextSize = 13
Footer.Parent = MainFrame

-- Automation Loops & Core Mechanics

-- 1. WalkSpeed Enforcer Loop
task.spawn(function()
    while task.wait(0.2) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if LocalPlayer.Character.Humanoid.WalkSpeed ~= Flags.WalkSpeed then
                LocalPlayer.Character.Humanoid.WalkSpeed = Flags.WalkSpeed
            end
        end
    end
end)

-- 2. Auto-Melt Loop (Tool Activation & Remote Scanning)
task.spawn(function()
    while task.wait(0.1) do
        if Flags.AutoMelt and LocalPlayer.Character then
            -- Equip tool if available
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool and tool.Parent ~= LocalPlayer.Character then
                tool.Parent = LocalPlayer.Character
            end
            if tool then
                tool:Activate()
            end
            
            -- Generic Melt Remote trigger fallback
            for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("melt") or v.Name:lower():find("hit") or v.Name:lower():find("click")) then
                    pcall(function() v:FireServer() end)
                end
            end
        end
    end
end)

-- 3. Auto-Collect Drops Loop
task.spawn(function()
    while task.wait(0.3) do
        if Flags.AutoCollect and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("BasePart") and (item.Name:lower():find("drop") or item.Name:lower():find("coin") or item.Name:lower():find("token") or item.Name:lower():find("reward")) then
                    pcall(function()
                        item.CFrame = hrp.CFrame
                    end)
                end
            end
        end
    end
end)

-- 4. Auto-Rebirth Loop
task.spawn(function()
    while task.wait(1.5) do
        if Flags.AutoRebirth then
            for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and v.Name:lower():find("rebirth") then
                    pcall(function()
                        if v:IsA("RemoteEvent") then
                            v:FireServer()
                        else
                            v:InvokeServer()
                        end
                    end)
                end
            end
        end
    end
end)
