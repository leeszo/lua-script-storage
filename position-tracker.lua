
-- Locate Position And Tracker
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SAVE_FILE = "tptool_points.txt"
local savedPositions = {}
local currentTab = "main"
local AccentColor = Color3.fromRGB(255, 120, 0)
local VISUAL = { CorSeta = Color3.fromRGB(255, 255, 255), AlturaSeta = 80, Neon = true }

local function loadPoints()
    if readfile and isfile then
        local ok, exists = pcall(isfile, SAVE_FILE)
        if ok and exists then
            local ok2, content = pcall(readfile, SAVE_FILE)
            if ok2 and content then
                for line in content:gmatch("[^\r\n]+") do
                    local x, y, z = line:match("([%-%d%.]+),([%-%d%.]+),([%-%d%.]+)")
                    if x and y and z then table.insert(savedPositions, Vector3.new(tonumber(x), tonumber(y), tonumber(z))) end
                end
            end
        end
    end
end
local function savePoints()
    if writefile then
        local text = ""
        for _, pos in ipairs(savedPositions) do text = text .. string.format("%.1f,%.1f,%.1f\n", pos.X, pos.Y, pos.Z) end
        pcall(writefile, SAVE_FILE, text)
    end
end
loadPoints()

local ArrowFolder = Workspace:FindFirstChild("PointArrows")
if ArrowFolder then ArrowFolder:Destroy() end
ArrowFolder = Instance.new("Folder", Workspace); ArrowFolder.Name = "PointArrows"
local currentArrow, arrowConnection = nil, nil

local function showArrow(pos)
    if currentArrow then currentArrow:Destroy() end
    if arrowConnection then arrowConnection:Disconnect() end
    local model = Instance.new("Model", ArrowFolder); currentArrow = model
    local root = Instance.new("Part", model)
    root.Size = Vector3.new(1, 1, 1); root.Transparency = 1; root.Anchored = true; root.CanCollide = false
    root.CFrame = CFrame.new(pos + Vector3.new(0, VISUAL.AlturaSeta, 0)); model.PrimaryPart = root

    local arrow = Instance.new("Part", model)
    arrow.Size = Vector3.new(10, 10, 10)
    arrow.Material = VISUAL.Neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
    arrow.Color = VISUAL.CorSeta; arrow.Anchored = true; arrow.CanCollide = false
    local mesh = Instance.new("SpecialMesh", arrow)
    mesh.MeshType = Enum.MeshType.Arrow; mesh.Scale = Vector3.new(4, 4, 4)
    arrow.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(180))
    
    if VISUAL.Neon then
        local light = Instance.new("PointLight", arrow)
        light.Color = VISUAL.CorSeta; light.Range = 50; light.Brightness = 4
    end

    local basePos, t = root.Position, 0
    arrowConnection = RunService.Heartbeat:Connect(function(dt)
        if not model.Parent then arrowConnection:Disconnect() return end
        t = t + dt
        local newY = basePos.Y + math.sin(t * 3) * 3
        root.CFrame = CFrame.new(basePos.X, newY, basePos.Z) * CFrame.Angles(0, t * 2, 0)
    end)
    task.delay(10, function() if model and model.Parent then model:Destroy() end if arrowConnection then arrowConnection:Disconnect() end end)
end

if _G.GrabberGui then pcall(function() _G.GrabberGui:Destroy() end) end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrabberGui"; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ok then ScreenGui.Parent = player:WaitForChild("PlayerGui") end
_G.GrabberGui = ScreenGui

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 380, 0, 460); Main.Position = UDim2.new(0, 50, 0, 50)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Main.BorderSizePixel = 0; Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = Color3.fromRGB(50, 50, 60); MainStroke.Thickness = 2

local Banner = Instance.new("Frame", Main)
Banner.Size = UDim2.new(1, 0, 0, 80); Banner.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Banner.BorderSizePixel = 0; Banner.ClipsDescendants = true
local BannerGradient = Instance.new("UIGradient", Banner)
BannerGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, AccentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))}
BannerGradient.Rotation = 45

local Title = Instance.new("TextLabel", Banner)
Title.Size = UDim2.new(1, -80, 0, 30); Title.Position = UDim2.new(0, 15, 0, 15)
Title.BackgroundTransparency = 1; Title.Text = "LOCATE POSITION AND TRACKER"; Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack; Title.TextSize = 20; Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", Banner)
SubTitle.Size = UDim2.new(1, -80, 0, 20); SubTitle.Position = UDim2.new(0, 15, 0, 40)
SubTitle.BackgroundTransparency = 1; SubTitle.Text = "Advanced Waypoint System"
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200); SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextSize = 12; SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Banner)
CloseBtn.Size = UDim2.new(0, 26, 0, 26); CloseBtn.Position = UDim2.new(1, -36, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local dragging, dragStart, startPos, targetPos
Banner.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = UserInputService:GetMouseLocation(); startPos = Main.Position; targetPos = startPos end
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
TabContainer.Size = UDim2.new(1, -30, 0, 35); TabContainer.Position = UDim2.new(0, 15, 0, 90)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30); TabContainer.BorderSizePixel = 0
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)

local function criarAba(nome, posX)
    local b = Instance.new("TextButton", TabContainer)
    b.Size = UDim2.new(0.33, -4, 1, -4); b.Position = UDim2.new(posX, 2, 0, 2)
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30); b.Text = nome; b.TextColor3 = Color3.fromRGB(150, 150, 160)
    b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6); return b
end
local TabMainBtn = criarAba("Shortcuts", 0)
local TabListBtn = criarAba("Waypoints", 0.33)
local TabConfigBtn = criarAba("Settings", 0.66)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -30, 1, -140); Content.Position = UDim2.new(0, 15, 0, 135)
Content.BackgroundTransparency = 1; Content.ClipsDescendants = true

local TabMain = Instance.new("Frame", Content); TabMain.Size = UDim2.new(1, 0, 1, 0); TabMain.BackgroundTransparency = 1
local TabList = Instance.new("Frame", Content); TabList.Size = UDim2.new(1, 0, 1, 0); TabList.BackgroundTransparency = 1; TabList.Position = UDim2.new(1, 0, 0, 0)
local TabConfig = Instance.new("Frame", Content); TabConfig.Size = UDim2.new(1, 0, 1, 0); TabConfig.BackgroundTransparency = 1; TabConfig.Position = UDim2.new(2, 0, 0, 0)

local function criarConfigBtn(txt, posY, callback)
    local b = Instance.new("TextButton", TabConfig)
    b.Size = UDim2.new(1, 0, 0, 35); b.Position = UDim2.new(0, 0, 0, posY)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35); b.Text = txt; b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(callback); return b
end

criarConfigBtn("Arrow Color: White", 5, function() VISUAL.CorSeta = Color3.fromRGB(255, 255, 255) end)
criarConfigBtn("Arrow Color: Red", 45, function() VISUAL.CorSeta = Color3.fromRGB(255, 50, 50) end)
criarConfigBtn("Arrow Color: Green", 85, function() VISUAL.CorSeta = Color3.fromRGB(50, 255, 50) end)
criarConfigBtn("Arrow Height: High (80)", 130, function() VISUAL.AlturaSeta = 80 end)
criarConfigBtn("Arrow Height: Low (40)", 170, function() VISUAL.AlturaSeta = 40 end)
criarConfigBtn("Neon Material: ON", 215, function() VISUAL.Neon = true end)
criarConfigBtn("Neon Material: OFF", 255, function() VISUAL.Neon = false end)

local function refreshList()
    for _, c in ipairs(TabList:GetChildren()) do if c:IsA("ScrollingFrame") then c:Destroy() end end
    local listFrame = Instance.new("ScrollingFrame", TabList)
    listFrame.Size = UDim2.new(1, 0, 1, 0); listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    listFrame.BorderSizePixel = 0; listFrame.ScrollBarThickness = 3
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)
    local layout = Instance.new("UIListLayout", listFrame); layout.Padding = UDim.new(0, 4)

    for i, pos in ipairs(savedPositions) do
        local item = Instance.new("TextButton", listFrame)
        item.Size = UDim2.new(1, -8, 0, 32); item.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        item.Text = string.format("  %d. %.1f, %.1f, %.1f", i, pos.X, pos.Y, pos.Z)
        item.TextColor3 = Color3.fromRGB(200, 200, 210); item.Font = Enum.Font.Code
        item.TextSize = 12; item.TextXAlignment = Enum.TextXAlignment.Left; item.BorderSizePixel = 0
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
        
        item.MouseButton1Click:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end; showArrow(pos)
        end)

        local remBtn = Instance.new("TextButton", item)
        remBtn.Size = UDim2.new(0, 28, 1, -6); remBtn.Position = UDim2.new(1, -32, 0, 3)
        remBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40); remBtn.Text = "X"; remBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        remBtn.Font = Enum.Font.GothamBold; remBtn.TextSize = 12; remBtn.BorderSizePixel = 0
        Instance.new("UICorner", remBtn).CornerRadius = UDim.new(0, 3)
        
        remBtn.MouseButton1Click:Connect(function()
            table.remove(savedPositions, i)
            savePoints()
            refreshList()
        end)
    end
    listFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
end

local btnGravar = Instance.new("TextButton", TabMain)
btnGravar.Size = UDim2.new(1, 0, 0, 45); btnGravar.Position = UDim2.new(0, 0, 0, 10)
btnGravar.BackgroundColor3 = AccentColor; btnGravar.Text = "SAVE POSITION [G]"
btnGravar.TextColor3 = Color3.fromRGB(255, 255, 255); btnGravar.Font = Enum.Font.GothamBold
btnGravar.TextSize = 14; btnGravar.BorderSizePixel = 0
Instance.new("UICorner", btnGravar).CornerRadius = UDim.new(0, 8)
btnGravar.MouseButton1Click:Connect(function()
    table.insert(savedPositions, mouse.Hit.Position)
    savePoints()
    refreshList()
    showArrow(mouse.Hit.Position)
end)

local btnSeta = Instance.new("TextButton", TabMain)
btnSeta.Size = UDim2.new(1, 0, 0, 45); btnSeta.Position = UDim2.new(0, 0, 0, 65)
btnSeta.BackgroundColor3 = Color3.fromRGB(30, 30, 35); btnSeta.Text = "SHOW ARROW [H]"
btnSeta.TextColor3 = Color3.fromRGB(255, 255, 255); btnSeta.Font = Enum.Font.GothamBold
btnSeta.TextSize = 14; btnSeta.BorderSizePixel = 0
Instance.new("UICorner", btnSeta).CornerRadius = UDim.new(0, 8)
btnSeta.MouseButton1Click:Connect(function() showArrow(mouse.Hit.Position) end)

local btnCopiar = Instance.new("TextButton", TabMain)
btnCopiar.Size = UDim2.new(1, 0, 0, 45); btnCopiar.Position = UDim2.new(0, 0, 0, 120)
btnCopiar.BackgroundColor3 = Color3.fromRGB(30, 30, 35); btnCopiar.Text = "COPY ALL WAYPOINTS"
btnCopiar.TextColor3 = Color3.fromRGB(255, 255, 255); btnCopiar.Font = Enum.Font.GothamBold
btnCopiar.TextSize = 14; btnCopiar.BorderSizePixel = 0
Instance.new("UICorner", btnCopiar).CornerRadius = UDim.new(0, 8)
btnCopiar.MouseButton1Click:Connect(function()
    local txt = "{\n"
    for i, pos in ipairs(savedPositions) do txt = txt .. string.format("    Vector3.new(%.1f, %.1f, %.1f), -- #%d\n", pos.X, pos.Y, pos.Z, i) end
    txt = txt .. "}"
    if setclipboard then setclipboard(txt) end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.G then
        table.insert(savedPositions, mouse.Hit.Position)
        savePoints(); refreshList(); showArrow(mouse.Hit.Position)
    end
    if input.KeyCode == Enum.KeyCode.H then showArrow(mouse.Hit.Position) end
    if input.KeyCode == Enum.KeyCode.J then savedPositions = {}; savePoints(); refreshList() end
end)

local tabs = {main = TabMainBtn, list = TabListBtn, config = TabConfigBtn}
local tabScreens = {main = TabMain, list = TabList, config = TabConfig}
local tabX = {main = 0, list = 1, config = 2}

local function MudarAba(id)
    currentTab = id
    for k, tela in pairs(tabScreens) do
        local targetX = (k == id) and tabX[k] or (tabX[k] > tabX[id] and 3 or -3)
        TweenService:Create(tela, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(targetX, 0, 0, 0)}):Play()
    end
    for k, btn in pairs(tabs) do
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = (k == id) and AccentColor or Color3.fromRGB(25, 25, 30),
            TextColor3 = (k == id) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
        }):Play()
    end
    if id == "list" then refreshList() end
end

TabMainBtn.MouseButton1Click:Connect(function() MudarAba("main") end)
TabListBtn.MouseButton1Click:Connect(function() MudarAba("list") end)
TabConfigBtn.MouseButton1Click:Connect(function() MudarAba("config") end)
