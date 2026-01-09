local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UTG_WinStyle_Final_2026"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Переменные
local lastPos = nil
local tpType = "CFrame"
local infiniteTP = false
local tpConnection = nil
local infMode = false
local sideOffset = CFrame.new(0, 4, 0) 

-- Функция телепорта
local function universalTeleport(targetCFrame, useOffset)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local finalCF = useOffset and (targetCFrame * sideOffset) or targetCFrame
    
    if tpType == "CFrame" then hrp.CFrame = finalCF
    elseif tpType == "Tween" then TweenService:Create(hrp, TweenInfo.new(0.3), {CFrame = finalCF}):Play()
    elseif tpType == "Pivot" then char:PivotTo(finalCF)
    elseif tpType == "Safe Offset" then hrp.CFrame = finalCF * CFrame.new(0, 6, 0)
    end
end

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 340)
MainFrame.Active = true
MainFrame.ClipsDescendants = true

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
TopBar.Size = UDim2.new(1, 0, 0, 25)

-- КНОПКА СТОП
local StopBtn = Instance.new("TextButton")
StopBtn.Parent = MainFrame
StopBtn.Size = UDim2.new(1, -10, 0, 35)
StopBtn.Position = UDim2.new(0, 5, 1, -85)
StopBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
StopBtn.Text = "СТОП ТЕЛЕПОРТ"
StopBtn.Visible = false
StopBtn.ZIndex = 500
StopBtn.MouseButton1Click:Connect(function()
    infiniteTP = false
    StopBtn.Visible = false
    if tpConnection then tpConnection:Disconnect() end
end)

-- НАСТРОЙКИ
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Parent = MainFrame
SettingsFrame.Position = UDim2.new(0, 0, 0, 25)
SettingsFrame.Size = UDim2.new(1, 0, 1, -70)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 100

-- ВЫБОР СТОРОНЫ (Ручное создание для надежности)
local SideList = Instance.new("ScrollingFrame")
SideList.Parent = SettingsFrame
SideList.Size = UDim2.new(0.95, 0, 0, 130)
SideList.Position = UDim2.new(0.025, 0, 0.45, 0)
SideList.Visible = false
SideList.ZIndex = 300
SideList.CanvasSize = UDim2.new(0, 0, 0, 200)
SideList.BackgroundColor3 = Color3.fromRGB(160, 160, 160)

local function addSideBtn(name, cf, pos)
    local b = Instance.new("TextButton")
    b.Parent = SideList
    b.Size = UDim2.new(1, -10, 0, 28)
    b.Position = UDim2.new(0, 5, 0, pos)
    b.Text = name
    b.ZIndex = 301
    b.MouseButton1Click:Connect(function() sideOffset = cf SideList.Visible = false end)
end

addSideBtn("ВПЕРЕД", CFrame.new(0, 0, -6), 0)
addSideBtn("НАЗАД", CFrame.new(0, 0, 6), 30)
addSideBtn("ВВЕРХ", CFrame.new(0, 8, 0), 60)
addSideBtn("ВНИЗ", CFrame.new(0, -8, 0), 90)
addSideBtn("ЛЕВО", CFrame.new(-8, 0, 0), 120)
addSideBtn("ПРАВО", CFrame.new(8, 0, 0), 150)

-- ВЫБОР ТИПА ТП (Ручное создание)
local TypeList = Instance.new("ScrollingFrame")
TypeList.Parent = SettingsFrame
TypeList.Size = UDim2.new(0.95, 0, 0, 100)
TypeList.Position = UDim2.new(0.025, 0, 0.45, 0)
TypeList.Visible = false
TypeList.ZIndex = 300
TypeList.CanvasSize = UDim2.new(0, 0, 0, 130)
TypeList.BackgroundColor3 = Color3.fromRGB(160, 160, 160)

local function addTypeBtn(name, pos)
    local b = Instance.new("TextButton")
    b.Parent = TypeList
    b.Size = UDim2.new(1, -10, 0, 28)
    b.Position = UDim2.new(0, 5, 0, pos)
    b.Text = name
    b.ZIndex = 301
    b.MouseButton1Click:Connect(function() tpType = name TypeList.Visible = false end)
end

addTypeBtn("CFrame", 0)
addTypeBtn("Tween", 30)
addTypeBtn("Pivot", 60)
addTypeBtn("Safe Offset", 90)

-- Кнопки управления в меню настроек
local InfT = Instance.new("TextButton")
InfT.Parent = SettingsFrame
InfT.Size = UDim2.new(0.9, 0, 0, 32)
InfT.Position = UDim2.new(0.05, 0, 0.05, 0)
InfT.Text = "БЕСКОНЕЧНО: ВЫКЛ"
InfT.ZIndex = 110
InfT.MouseButton1Click:Connect(function()
    infMode = not infMode
    InfT.Text = "БЕСКОНЕЧНО: "..(infMode and "ВКЛ" or "ВЫКЛ")
    InfT.BackgroundColor3 = infMode and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 150, 150)
end)

local TSelBtn = Instance.new("TextButton")
TSelBtn.Parent = SettingsFrame
TSelBtn.Size = UDim2.new(0.9, 0, 0, 32)
TSelBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
TSelBtn.Text = "ТИП ТЕЛЕПОРТА"
TSelBtn.ZIndex = 110
TSelBtn.MouseButton1Click:Connect(function() TypeList.Visible = not TypeList.Visible SideList.Visible = false end)

local SideBtn = Instance.new("TextButton")
SideBtn.Parent = SettingsFrame
SideBtn.Size = UDim2.new(0.9, 0, 0, 32)
SideBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
SideBtn.Text = "СТОРОНА ТП"
SideBtn.ZIndex = 110
SideBtn.MouseButton1Click:Connect(function() SideList.Visible = not SideList.Visible TypeList.Visible = false end)

-- СПИСОК ИГРОКОВ
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 5, 0, 30)
ScrollFrame.Size = UDim2.new(0, 210, 0, 230)
local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollFrame

local function updateList()
    for _, v in pairs(ScrollFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -5, 0, 30)
            b.Text = p.DisplayName
            b.Parent = ScrollFrame
            b.MouseButton1Click:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then lastPos = LocalPlayer.Character.HumanoidRootPart.CFrame end
                if not infMode then 
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then universalTeleport(p.Character.HumanoidRootPart.CFrame, true) end
                else
                    if tpConnection then tpConnection:Disconnect() end
                    infiniteTP = true
                    StopBtn.Visible = true
                    tpConnection = RunService.Heartbeat:Connect(function()
                        if infiniteTP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            universalTeleport(p.Character.HumanoidRootPart.CFrame, true)
                        else
                            infiniteTP = false StopBtn.Visible = false if tpConnection then tpConnection:Disconnect() end
                        end
                    end)
                end
            end)
        end
    end
end

-- НИЖНЯЯ ПАНЕЛЬ
local BottomBar = Instance.new("Frame")
BottomBar.Parent = MainFrame
BottomBar.Size = UDim2.new(1, 0, 0, 45)
BottomBar.Position = UDim2.new(0, 0, 1, -45)

local RoofBtn = Instance.new("TextButton")
RoofBtn.Parent = BottomBar
RoofBtn.Size = UDim2.new(0.45, 0, 0.8, 0)
RoofBtn.Position = UDim2.new(0.03, 0, 0.1, 0)
RoofBtn.Text = "НА КРЫШУ"
RoofBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        lastPos = char.HumanoidRootPart.CFrame
        local ray = workspace:Raycast(char.HumanoidRootPart.Position + Vector3.new(0, 300, 0), Vector3.new(0, -350, 0))
        universalTeleport(CFrame.new((ray and ray.Position or char.HumanoidRootPart.Position + Vector3.new(0, 100, 0)) + Vector3.new(0, 4, 0)), false)
    end
end)

local BackBtn = Instance.new("TextButton")
BackBtn.Parent = BottomBar
BackBtn.Size = UDim2.new(0.45, 0, 0.8, 0)
BackBtn.Position = UDim2.new(0.52, 0, 0.1, 0)
BackBtn.Text = "ВЕРНУТЬСЯ"
BackBtn.MouseButton1Click:Connect(function() if lastPos then universalTeleport(lastPos, false) end end)

-- ВЕРХНИЕ КНОПКИ
local function createTopBtn(t, x, c)
    local b = Instance.new("TextButton")
    b.Parent = TopBar
    b.Text = t
    b.Position = UDim2.new(x, 0, 0.1, 0)
    b.Size = UDim2.new(0.1, 0, 0.8, 0)
    b.MouseButton1Click:Connect(c)
end
createTopBtn("X", 0.88, function() ScreenGui:Destroy() end)
createTopBtn("_", 0.76, function()
    local isMin = MainFrame.Size.Y.Offset > 30
    MainFrame.Size = isMin and UDim2.new(0, 220, 0, 25) or UDim2.new(0, 220, 0, 340)
    ScrollFrame.Visible, BottomBar.Visible, SettingsFrame.Visible = not isMin, not isMin, false
end)
createTopBtn("S", 0.64, function() SettingsFrame.Visible = not SettingsFrame.Visible ScrollFrame.Visible = not SettingsFrame.Visible end)
createTopBtn("R", 0.52, updateList)

-- ПЕРЕТАСКИВАНИЕ
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function() dragging = false end)

updateList()
