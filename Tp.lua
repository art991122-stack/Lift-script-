local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = workspace.CurrentCamera

-- Очистка старой версии 2026
if Player:WaitForChild("PlayerGui"):FindFirstChild("TP_BLOCK_V30_FIXED") then
    Player.PlayerGui.TP_BLOCK_V30_FIXED:Destroy()
end

local sg = Instance.new("ScreenGui", Player.PlayerGui)
sg.Name = "TP_BLOCK_V30_FIXED"
sg.ResetOnSpawn = false

local blocks = {}
local routeQueue = {}

-- [[ СТИЛЬ ]] --
local OLD_COLORS = {
    Main = Color3.fromRGB(163, 162, 165), 
    Top = Color3.fromRGB(51, 51, 51),     
    Button = Color3.fromRGB(220, 220, 220), 
    Green = Color3.fromRGB(0, 255, 0),    
    Blue = Color3.fromRGB(0, 0, 255),     
    Red = Color3.fromRGB(255, 0, 0),      
    Font = Enum.Font.Legacy,               
}

-- [[ ФУНКЦИИ ]] --

local function lookAtBlock(part, state)
    if state then
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(part.Position + Vector3.new(0, 15, 15), part.Position)
        local h = Instance.new("SelectionBox", part); h.Name = "ViewH"; h.Color3 = Color3.new(1,1,0); h.LineThickness = 0.05
    else
        Camera.CameraType = Enum.CameraType.Custom
        if part:FindFirstChild("ViewH") then part.ViewH:Destroy() end
    end
end

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

-- ПЛАВНЫЙ ТЕЛЕПОРТ (ИСПРАВЛЕННАЯ ВЫСОТА)
local function universalTP(targetPart, freezeTime)
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        local targetRoot = root
        if hum and hum.SeatPart then
            local v = hum.SeatPart.Parent
            while v and not v:IsA("Model") do v = v.Parent end
            targetRoot = (v and v.PrimaryPart) or hum.SeatPart
        end

        -- Смещение: targetPart (центр столба) -> вниз на 2.5 (к платформе) -> вверх на 3 (над платформой)
        local targetCFrame = targetPart.CFrame * CFrame.new(0, 0.5, 0) 
        
        local tween = TweenService:Create(targetRoot, TweenInfo.new(1, Enum.EasingStyle.Sine), {CFrame = targetCFrame})
        
        tween:Play()
        tween.Completed:Wait()
        
        if freezeTime then
            targetRoot.Anchored = true
            task.wait(freezeTime)
            targetRoot.Anchored = false
        end
        return targetRoot
    end
end

local function createOldButton(text, pos, size, parent, color)
    local btn = Instance.new("TextButton", parent)
    btn.Text = text:upper(); btn.Position = pos; btn.Size = size; btn.Font = OLD_COLORS.Font; btn.TextSize = 14; btn.BackgroundColor3 = color or OLD_COLORS.Button; btn.BorderSizePixel = 2; btn.BorderColor3 = Color3.new(0,0,0); btn.TextColor3 = Color3.new(0,0,0)
    return btn
end

-- [[ ГЛАВНОЕ ОКНО ]] --
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 200, 0, 300); main.Position = UDim2.new(0.5, -210, 0.5, -150); main.BackgroundColor3 = OLD_COLORS.Main; main.BorderSizePixel = 4; main.BorderColor3 = Color3.new(0,0,0); main.Active = true

local top = Instance.new("Frame", main); top.Size = UDim2.new(1, 0, 0, 25); top.BackgroundColor3 = OLD_COLORS.Top; top.BorderSizePixel = 0
makeDraggable(main, top)

local title = Instance.new("TextLabel", top); title.Size = UDim2.new(1, -85, 1, 0); title.Text = " ТП БЛОК V30"; title.Font = OLD_COLORS.Font; title.TextColor3 = Color3.new(1,1,1); title.TextXAlignment = Enum.TextXAlignment.Left; title.BackgroundTransparency = 1

local bHideInner = createOldButton("_", UDim2.new(1, -75, 0, 0), UDim2.new(0, 25, 1, 0), top, OLD_COLORS.Button)
local bMinimize = createOldButton("-", UDim2.new(1, -50, 0, 0), UDim2.new(0, 25, 1, 0), top, OLD_COLORS.Button)
local bClose = createOldButton("X", UDim2.new(1, -25, 0, 0), UDim2.new(0, 25, 1, 0), top, OLD_COLORS.Red)

local btnRestore = createOldButton("[ + ]", UDim2.new(0.5, -30, 0, 10), UDim2.new(0, 60, 0, 30), sg, OLD_COLORS.Green)
btnRestore.Visible = false

local content = Instance.new("Frame", main); content.Size = UDim2.new(1,0,1,-25); content.Position = UDim2.new(0,0,0,25); content.BackgroundTransparency = 1
local scroll = Instance.new("ScrollingFrame", content); scroll.Size = UDim2.new(1, -20, 0, 120); scroll.Position = UDim2.new(0, 10, 0, 10); scroll.BackgroundColor3 = Color3.new(1,1,1); scroll.BorderSizePixel = 2; Instance.new("UIListLayout", scroll)
local btnCreate = createOldButton("Создать точку", UDim2.new(0, 10, 0, 140), UDim2.new(1, -20, 0, 35), content, OLD_COLORS.Green)
local btnRouteOpen = createOldButton("Маршрут", UDim2.new(0, 10, 0, 180), UDim2.new(1, -20, 0, 35), content, OLD_COLORS.Blue)
local btnClear = createOldButton("Удалить всё", UDim2.new(0, 10, 0, 220), UDim2.new(1, -20, 0, 35), content, OLD_COLORS.Main)

local routeWin = Instance.new("Frame", sg); routeWin.Size = UDim2.new(0, 200, 0, 300); routeWin.Position = UDim2.new(0.5, 10, 0.5, -150); routeWin.BackgroundColor3 = OLD_COLORS.Main; routeWin.BorderSizePixel = 4; routeWin.Visible = false
local rTop = Instance.new("Frame", routeWin); rTop.Size = UDim2.new(1, 0, 0, 25); rTop.BackgroundColor3 = OLD_COLORS.Blue; makeDraggable(routeWin, rTop)
local rScroll = Instance.new("ScrollingFrame", routeWin); rScroll.Size = UDim2.new(1, -20, 0, 120); rScroll.Position = UDim2.new(0, 10, 0, 35); rScroll.BackgroundColor3 = Color3.new(1,1,1); rScroll.BorderSizePixel = 2; Instance.new("UIListLayout", rScroll)
local btnAutoRoute = createOldButton("Авто-Маршрут", UDim2.new(0, 10, 0, 165), UDim2.new(1, -20, 0, 35), routeWin, Color3.fromRGB(255, 170, 0))
local btnGo = createOldButton("Идти", UDim2.new(0, 10, 0, 205), UDim2.new(0, 85, 0, 35), routeWin, OLD_COLORS.Green)
local btnResetRoute = createOldButton("Сброс", UDim2.new(1, -95, 0, 205), UDim2.new(0, 85, 0, 35), routeWin, OLD_COLORS.Red)

-- [[ ЛОГИКА ]] --
local function updateRouteWin()
    for _, v in pairs(rScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for i, b in ipairs(blocks) do
        local btn = createOldButton("Блок "..i, UDim2.new(0,0,0,0), UDim2.new(1,0,0,25), rScroll)
        local function refresh() local pos = table.find(routeQueue, b) btn.Text = "БЛОК "..i..(pos and " ["..pos.."]" or "") end
        refresh()
        btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then lookAtBlock(b, true) end end)
        btn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then lookAtBlock(b, false) end end)
        btn.MouseButton1Click:Connect(function() if not table.find(routeQueue, b) then table.insert(routeQueue, b) refresh() end end)
    end
end

btnCreate.MouseButton1Click:Connect(function()
    local char = Player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local folder = Instance.new("Model", workspace); folder.Name = "PointV30_"..(#blocks+1)
        local color = BrickColor.random()

        local b = Instance.new("Part", folder); b.Size = Vector3.new(1, 5, 1); b.TopSurface = "Studs"; b.BottomSurface = "Inlet"; b.Transparency = 0.3; b.CanCollide = false; b.Anchored = true; b.CFrame = hrp.CFrame; b.BrickColor = color
        
        local plat = Instance.new("Part", folder)
        plat.Size = Vector3.new(3, 1, 3)
        plat.CFrame = b.CFrame * CFrame.new(0, -2.5, 0) 
        plat.BrickColor = color 
        plat.Transparency = 0.5 
        plat.Anchored = true
        plat.TopSurface = "Studs"
        plat.Name = "Platform"
        
        table.insert(blocks, b)
        local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1,0,0,30); f.BackgroundTransparency = 1
        local tp = createOldButton("ТП", UDim2.new(0,0,0,0), UDim2.new(0.45,0,1,0), f)
        local del = createOldButton("Удалить", UDim2.new(0.55,0,0,0), UDim2.new(0.45,0,1,0), f, OLD_COLORS.Red)
        
        tp.MouseButton1Click:Connect(function() universalTP(b, 0.5) end)
        del.MouseButton1Click:Connect(function() folder:Destroy(); f:Destroy(); updateRouteWin(); for idx, v in pairs(blocks) do if v == b then table.remove(blocks, idx) break end end end)
    end
end)

btnGo.MouseButton1Click:Connect(function() for _, b in ipairs(routeQueue) do if b and b.Parent then universalTP(b, 1) end end end)
btnAutoRoute.MouseButton1Click:Connect(function() for _, b in ipairs(blocks) do if b and b.Parent then universalTP(b, 1) end end end)
btnRouteOpen.MouseButton1Click:Connect(function() updateRouteWin(); routeWin.Visible = not routeWin.Visible end)
btnResetRoute.MouseButton1Click:Connect(function() routeQueue = {}; updateRouteWin() end)
btnClear.MouseButton1Click:Connect(function() for _, b in pairs(blocks) do if b.Parent then b.Parent:Destroy() end end; blocks = {}; routeQueue = {}; scroll:ClearAllChildren(); Instance.new("UIListLayout", scroll) end)

bHideInner.MouseButton1Click:Connect(function()
    local isCollapsed = main.Size.Y.Offset < 40
    main.Size = isCollapsed and UDim2.new(0, 200, 0, 300) or UDim2.new(0, 200, 0, 25)
    content.Visible = isCollapsed
end)

bMinimize.MouseButton1Click:Connect(function() main.Visible = false; routeWin.Visible = false; btnRestore.Visible = true end)
btnRestore.MouseButton1Click:Connect(function() main.Visible = true; btnRestore.Visible = false end)
bClose.MouseButton1Click:Connect(function() for _, b in pairs(blocks) do if b.Parent then b.Parent:Destroy() end end; sg:Destroy() end)
