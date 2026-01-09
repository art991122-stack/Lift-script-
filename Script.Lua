local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UTG_WinStyle_Final_2026"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Переменные
local lastPos = nil
local tpType = "CFrame"
local infiniteTP = false
local tpConnection = nil
local infMode = false

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 340)
MainFrame.Active = true
MainFrame.ClipsDescendants = true

-- Заголовок (Синий Windows)
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 128)
TopBar.Size = UDim2.new(1, 0, 0, 25)

-- ФУНКЦИЯ УНИВЕРСАЛЬНОГО ТП
local function universalTeleport(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if tpType == "CFrame" then hrp.CFrame = targetCFrame
    elseif tpType == "Tween" then TweenService:Create(hrp, TweenInfo.new(0.3), {CFrame = targetCFrame}):Play()
    elseif tpType == "Pivot" then char:PivotTo(targetCFrame)
    elseif tpType == "Safe Offset" then hrp.CFrame = targetCFrame * CFrame.new(0, 6, 0)
    end
end

-- НАСТРОЙКИ (Кнопка S)
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Parent = MainFrame
SettingsFrame.Position = UDim2.new(0, 0, 0, 25)
SettingsFrame.Size = UDim2.new(1, 0, 1, -70)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 100 -- ПОВЕРХ ВСЕГО

local TypeList = Instance.new("ScrollingFrame")
TypeList.Parent = SettingsFrame
TypeList.Size = UDim2.new(0.9, 0, 0, 120)
TypeList.Position = UDim2.new(0.05, 0, 0.45, 0)
TypeList.Visible = false
TypeList.ZIndex = 110
TypeList.CanvasSize = UDim2.new(0, 0, 0, 180)

local types = {"CFrame", "Tween", "Pivot", "Safe Offset"}
for i, name in ipairs(types) do
    local b = Instance.new("TextButton")
    b.Parent = TypeList
    b.Size = UDim2.new(1, -10, 0, 30)
    b.Position = UDim2.new(0, 0, 0, (i-1)*31)
    b.Text = name
    b.ZIndex = 111
    b.MouseButton1Click:Connect(function() tpType = name TypeList.Visible = false end)
end

local InfT = Instance.new("TextButton")
InfT.Parent = SettingsFrame
InfT.Size = UDim2.new(0.9, 0, 0, 35)
InfT.Position = UDim2.new(0.05, 0, 0.05, 0)
InfT.Text = "Infinite TP: OFF"
InfT.ZIndex = 101
InfT.MouseButton1Click:Connect(function() 
    infMode = not infMode 
    InfT.Text = "Infinite TP: "..(infMode and "ON" or "OFF")
    InfT.BackgroundColor3 = infMode and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 150, 150)
end)

local TSel = Instance.new("TextButton")
TSel.Parent = SettingsFrame
TSel.Size = UDim2.new(0.9, 0, 0, 35)
TSel.Position = UDim2.new(0.05, 0, 0.25, 0)
TSel.Text = "ВЫБРАТЬ ТИП ТП"
TSel.ZIndex = 101
TSel.MouseButton1Click:Connect(function() TypeList.Visible = not TypeList.Visible end)

-- СПИСОК ИГРОКОВ
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 5, 0, 30)
ScrollFrame.Size = UDim2.new(0, 210, 0, 230)
ScrollFrame.Active = true 

local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollFrame

-- КНОПКА СТОП (ZIndex выше списка)
local StopBtn = Instance.new("TextButton")
StopBtn.Parent = MainFrame
StopBtn.Size = UDim2.new(1, -10, 0, 30)
StopBtn.Position = UDim2.new(0, 5, 1, -80)
StopBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
StopBtn.Text = "СТОП ТЕЛЕПОРТ"
StopBtn.Visible = false
StopBtn.ZIndex = 50
StopBtn.MouseButton1Click:Connect(function() infiniteTP = false StopBtn.Visible = false if tpConnection then tpConnection:Disconnect() end end)

-- ОБНОВЛЕНИЕ СПИСКА
local function updateList()
    for _, v in pairs(ScrollFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -5, 0, 30)
            b.Text = p.DisplayName
            b.Parent = ScrollFrame
            b.MouseButton1Click:Connect(function()
                lastPos = LocalPlayer.Character.HumanoidRootPart.CFrame
                if not infMode then universalTeleport(p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0))
                else
                    if tpConnection then tpConnection:Disconnect() end
                    infiniteTP = true
                    StopBtn.Visible = true
                    tpConnection = RunService.Heartbeat:Connect(function()
                        if infiniteTP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            universalTeleport(p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0))
                        else stopInfinite() end
                    end)
                end
            end)
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 5)
end

-- НИЖНЯЯ ПАНЕЛЬ (Крыша / Назад)
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
        universalTeleport(CFrame.new((ray and ray.Position or char.HumanoidRootPart.Position + Vector3.new(0, 100, 0)) + Vector3.new(0, 4, 0)))
    end
end)

local BackBtn = Instance.new("TextButton")
BackBtn.Parent = BottomBar
BackBtn.Size = UDim2.new(0.45, 0, 0.8, 0)
BackBtn.Position = UDim2.new(0.52, 0, 0.1, 0)
BackBtn.Text = "ВЕРНУТЬСЯ"
BackBtn.MouseButton1Click:Connect(function() if lastPos then universalTeleport(lastPos) end end)

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

-- DRAG
local d, s, sp
TopBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then d = true s = i.Position sp = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
    local del = i.Position - s
    MainFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y)
end end)
UserInputService.InputEnded:Connect(function() d = false end)

updateList()
