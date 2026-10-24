-- Candy Farm Build a Boat
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local CONFIG = {
    AFK_POSITION = Vector3.new(274.7, 23.1, 796.3),
    CANDY_LOCATIONS = {
        Vector3.new(274.7, 23.1, 796.3), Vector3.new(185.6, 23.1, 824.5),
        Vector3.new(-310.4, 23.1, 797.0), Vector3.new(-364.4, 25.3, 815.0),
        Vector3.new(110.8, 23.1, -343.8), Vector3.new(161.8, 23.1, -290.1),
        Vector3.new(-237.4, 21.1, -356.7), Vector3.new(-316.5, 23.1, -238.0),
        Vector3.new(216.2, 23.1, 485.5), Vector3.new(325.2, 23.1, 485.0),
        Vector3.new(194.6, 23.1, 99.3), Vector3.new(254.4, 23.2, 142.0),
        Vector3.new(-295.1, 23.1, 441.4), Vector3.new(294.3, 22.1, -230.0),
        Vector3.new(-359.3, 23.1, 83.7), Vector3.new(-434.8, 23.1, 438.9),
        Vector3.new(282.7, 23.1, 453.6),
    },
    TP_SPEED = 3.5, AFK_MODE = true, WAIT_AT_CANDY = 1.2, TP_HEIGHT_OFFSET = 3,
}

local running = false
local candyIndex = 1
local currentTab = "main"
local AccentColor = Color3.fromRGB(255, 120, 0)

local function getHRP() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function teleportTo(pos)
    local hrp = getHRP()
    if not hrp then return false end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, CONFIG.TP_HEIGHT_OFFSET, 0))
    return true
end

local function startFarm()
    if running then return end
    running = true
    task.spawn(function()
        while running do
            if CONFIG.AFK_MODE then
                teleportTo(CONFIG.AFK_POSITION)
                task.wait(CONFIG.TP_SPEED)
            end
            for i = 1, 3 do
                if not running then break end
                local candyPos = CONFIG.CANDY_LOCATIONS[candyIndex]
                if not candyPos then break end
                teleportTo(candyPos)
                task.wait(CONFIG.WAIT_AT_CANDY)
                candyIndex = candyIndex + 1
                if candyIndex > #CONFIG.CANDY_LOCATIONS then candyIndex = 1 end
                task.wait(CONFIG.TP_SPEED + math.random(-10, 10) / 10)
            end
            if CONFIG.AFK_MODE and running then
                teleportTo(CONFIG.AFK_POSITION)
                task.wait(3)
            end
        end
    end)
end

local function stopFarm() running = false end
local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)

if _G.CandyFarmGui then pcall(function() _G.CandyFarmGui:Destroy() end) end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CandyFarmGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ok then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
_G.CandyFarmGui = ScreenGui

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 360, 0, 460)
Main.Position = UDim2.new(0.5, -180, 0.5, -230)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(50, 50, 60)
MainStroke.Thickness = 2

local Banner = Instance.new("Frame", Main)
Banner.Size = UDim2.new(1, 0, 0, 80)
Banner.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Banner.BorderSizePixel = 0
Banner.ClipsDescendants = true

local BannerGradient = Instance.new("UIGradient", Banner)
BannerGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, AccentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))}
BannerGradient.Rotation = 45

local Title = Instance.new("TextLabel", Banner)
Title.Size = UDim2.new(1, -80, 0, 30)
Title.Position = UDim2.new(0, 15, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "CANDY FARM BUILD A BOAT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", Banner)
SubTitle.Size = UDim2.new(1, -80, 0, 20)
SubTitle.Position = UDim2.new(0, 15, 0, 40)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Premium Auto-Farm Hub"
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Banner)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local dragging, dragStart, startPos, targetPos
Banner.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = UserInputService:GetMouseLocation(); startPos = Main.Position; targetPos = startPos
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = UserInputService:GetMouseLocation() - dragStart
        targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging and targetPos then
        Main.Position = UDim2.new(targetPos.X.Scale, Main.Position.X.Offset + (targetPos.X.Offset - Main.Position.X.Offset) * 0.5, targetPos.Y.Scale, Main.Position.Y.Offset + (targetPos.Y.Offset - Main.Position.Y.Offset) * 0.5)
    end
end)

local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(1, -30, 0, 35)
TabContainer.Position = UDim2.new(0, 15, 0, 90)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabContainer.BorderSizePixel = 0
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)

local function criarAba(nome, posX)
    local b = Instance.new("TextButton", TabContainer)
    b.Size = UDim2.new(0.5, -4, 1, -4)
    b.Position = UDim2.new(posX, 2, 0, 2)
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.Text = nome
    b.TextColor3 = Color3.fromRGB(150, 150, 160)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end
local TabMainBtn = criarAba("Farm", 0)
local TabConfigBtn = criarAba("Settings", 0.5)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -30, 1, -140)
Content.Position = UDim2.new(0, 15, 0, 135)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true

local TabMain = Instance.new("Frame", Content)
TabMain.Size = UDim2.new(1, 0, 1, 0); TabMain.BackgroundTransparency = 1
local TabConfig = Instance.new("Frame", Content)
TabConfig.Size = UDim2.new(1, 0, 1, 0); TabConfig.BackgroundTransparency = 1; TabConfig.Position = UDim2.new(1, 0, 0, 0)

local ToggleBtn = Instance.new("TextButton", TabMain)
ToggleBtn.Size = UDim2.new(1, 0, 0, 50); ToggleBtn.Position = UDim2.new(0, 0, 0, 10)
ToggleBtn.BackgroundColor3 = AccentColor; ToggleBtn.Text = "START FARM"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16; ToggleBtn.BorderSizePixel = 0
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local TglStroke = Instance.new("UIStroke", ToggleBtn); TglStroke.Color = Color3.fromRGB(255,255,255); TglStroke.Transparency = 0.5

ToggleBtn.MouseButton1Click:Connect(function()
    if running then stopFarm(); TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = AccentColor}):Play(); ToggleBtn.Text = "START FARM"
    else startFarm(); TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 50, 150)}):Play(); ToggleBtn.Text = "STOP FARM" end
end)

local AfkBtn = Instance.new("TextButton", TabMain)
AfkBtn.Size = UDim2.new(1, 0, 0, 45); AfkBtn.Position = UDim2.new(0, 0, 0, 75)
AfkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); AfkBtn.Text = "AFK Mode: ON"
AfkBtn.TextColor3 = Color3.fromRGB(255, 255, 255); AfkBtn.Font = Enum.Font.GothamBold
AfkBtn.BorderSizePixel = 0
Instance.new("UICorner", AfkBtn).CornerRadius = UDim.new(0, 8)
AfkBtn.MouseButton1Click:Connect(function()
    CONFIG.AFK_MODE = not CONFIG.AFK_MODE
    AfkBtn.Text = CONFIG.AFK_MODE and "AFK Mode: ON" or "AFK Mode: OFF"
    AfkBtn.TextColor3 = CONFIG.AFK_MODE and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
end)

local SpeedLabel = Instance.new("TextLabel", TabMain)
SpeedLabel.Size = UDim2.new(1, 0, 0, 20); SpeedLabel.Position = UDim2.new(0, 0, 0, 140)
SpeedLabel.BackgroundTransparency = 1; SpeedLabel.Text = "TP Speed: 3.5s"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200); SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local SliderBg = Instance.new("TextButton", TabMain)
SliderBg.Size = UDim2.new(1, 0, 0, 25); SliderBg.Position = UDim2.new(0, 0, 0, 170)
SliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35); SliderBg.Text = ""; SliderBg.BorderSizePixel = 0
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.Size = UDim2.new(0.35, 0, 1, 0); SliderFill.BackgroundColor3 = AccentColor; SliderFill.BorderSizePixel = 0
Instance.new("UICorner", SliderFill).Cor
