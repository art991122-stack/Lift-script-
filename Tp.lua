local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local sg = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
sg.Name = "FinalScript_MobilePC_2026"
sg.ResetOnSpawn = false

local blocks = {}
local routeQueue = {}

-- === УНИВЕРСАЛЬНОЕ ДВИЖЕНИЕ ===
local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- === ФУНКЦИЯ УДАЛЕНИЯ ВСЕГО ===
local function clearEverything()
    for _, b in pairs(blocks) do if b then b:Destroy() end end
    blocks = {}
    routeQueue = {}
end

-- === ГЛАВНОЕ ОКНО ===
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 180, 0, 260); main.Position = UDim2.new(0.5, -200, 0.5, -130); main.BackgroundColor3 = Color3.fromRGB(30, 30, 30); main.Active = true

local top = Instance.new("Frame", main); top.Size = UDim2.new(1, 0, 0, 30); top.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
makeDraggable(main, top)

local bHide = Instance.new("TextButton", top); bHide.Size = UDim2.new(0,30,0,30); bHide.Position = UDim2.new(1,-60,0,0); bHide.Text = "_"; bHide.BackgroundColor3 = Color3.fromRGB(70,70,70); bHide.TextColor3 = Color3.new(1,1,1)
local bClose = Instance.new("TextButton", top); bClose.Size = UDim2.new(0,30,0,30); bClose.Position = UDim2.new(1,-30,0,0); bClose.Text = "X"; bClose.BackgroundColor3 = Color3.fromRGB(150,0,0); bClose.TextColor3 = Color3.new(1,1,1)

local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -10, 0.4, 0); scroll.Position = UDim2.new(0, 5, 0, 35); scroll.BackgroundColor3 = Color3.fromRGB(20,20,20); Instance.new("UIListLayout", scroll)

local btnCreate = Instance.new("TextButton", main); btnCreate.Size = UDim2.new(1, -10, 0, 30); btnCreate.Position = UDim2.new(0, 5, 0.55, 5); btnCreate.Text = "СОЗДАТЬ"; btnCreate.BackgroundColor3 = Color3.fromRGB(0,100,0); btnCreate.TextColor3 = Color3.new(1,1,1)
local btnRouteOpen = Instance.new("TextButton", main); btnRouteOpen.Size = UDim2.new(1, -10, 0, 30); btnRouteOpen.Position = UDim2.new(0, 5, 0.7, 5); btnRouteOpen.Text = "МАРШРУТ"; btnRouteOpen.BackgroundColor3 = Color3.fromRGB(0,80,150); btnRouteOpen.TextColor3 = Color3.new(1,1,1)
local btnClear = Instance.new("TextButton", main); btnClear.Size = UDim2.new(1, -10, 0, 30); btnClear.Position = UDim2.new(0, 5, 0.85, 5); btnClear.Text = "УБРАТЬ ВСЕ"; btnClear.BackgroundColor3 = Color3.fromRGB(70,70,70); btnClear.TextColor3 = Color3.new(1,1,1)

-- === ОКНО МАРШРУТА ===
local routeWin = Instance.new("Frame", sg); routeWin.Size = UDim2.new(0, 180, 0, 260); routeWin.Position = UDim2.new(0.5, 20, 0.5, -130); routeWin.BackgroundColor3 = Color3.fromRGB(40, 40, 40); routeWin.Visible = false; routeWin.Active = true
local rTop = Instance.new("Frame", routeWin); rTop.Size = UDim2.new(1, 0, 0, 30); rTop.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
makeDraggable(routeWin, rTop)

local rScroll = Instance.new("ScrollingFrame", routeWin); rScroll.Size = UDim2.new(1, -10, 0.6, 0); rScroll.Position = UDim2.new(0, 5, 0, 35); rScroll.BackgroundColor3 = Color3.fromRGB(20,20,20); Instance.new("UIListLayout", rScroll)
local btnGo = Instance.new("TextButton", routeWin); btnGo.Size = UDim2.new(0.48, 0, 0, 30); btnGo.Position = UDim2.new(0, 3, 0.85, 0); btnGo.Text = "ИДТИ"; btnGo.BackgroundColor3 = Color3.fromRGB(0,150,0); btnGo.TextColor3 = Color3.new(1,1,1)
local btnResetRoute = Instance.new("TextButton", routeWin); btnResetRoute.Size = UDim2.new(0.48, 0, 0, 30); btnResetRoute.Position = UDim2.new(0.5, 2, 0.85, 0); btnResetRoute.Text = "РЕСЕТ"; btnResetRoute.BackgroundColor3 = Color3.fromRGB(150,0,0); btnResetRoute.TextColor3 = Color3.new(1,1,1)

-- === ЛОГИКА ===
local function smoothTP(p)
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and p then
        local t = TweenService:Create(char.HumanoidRootPart, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {CFrame = p.CFrame})
        t:Play(); return t
    end
end

local function updateRouteWin()
    for _, v in pairs(rScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for i, b in ipairs(blocks) do
        local btn = Instance.new("TextButton", rScroll); btn.Size = UDim2.new(1,0,0,25); btn.BackgroundColor3 = Color3.fromRGB(60,60,60); btn.TextColor3 = Color3.new(1,1,1)
        local function refresh() local pos = table.find(routeQueue, b) btn.Text = "Блок #"..i..(pos and " ["..pos.."]" or "") end
        refresh(); btn.MouseButton1Click:Connect(function() if not table.find(routeQueue, b) then table.insert(routeQueue, b) refresh() end end)
    end
end

btnCreate.MouseButton1Click:Connect(function()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local b = Instance.new("Part", workspace)
        b.Size = Vector3.new(1, 5, 1); b.Transparency = 0.5; b.CanCollide = false; b.Anchored = true
        b.Position = hrp.Position -- СПАВН ВНУТРИ ИГРОКА
        b.BrickColor = BrickColor.random()
        table.insert(blocks, b)
        local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1,0,0,25); f.BackgroundTransparency = 1
        local tp = Instance.new("TextButton", f); tp.Size = UDim2.new(0.45,0,0.9,0); tp.Text = "ТП"; tp.BackgroundColor3 = Color3.fromRGB(0,60,120); tp.TextColor3 = Color3.new(1,1,1)
        local del = Instance.new("TextButton", f); del.Size = UDim2.new(0.45,0,0.9,0); del.Position = UDim2.new(0.5,0,0,0); del.Text = "X"; del.BackgroundColor3 = Color3.fromRGB(120,0,0); del.TextColor3 = Color3.new(1,1,1)
        tp.MouseButton1Click:Connect(function() smoothTP(b) end)
        del.MouseButton1Click:Connect(function() 
            b:Destroy(); f:Destroy(); 
            for idx, v in pairs(blocks) do if v == b then table.remove(blocks, idx) break end end
            for idx, v in pairs(routeQueue) do if v == b then table.remove(routeQueue, idx) break end end
        end)
    end
end)

btnRouteOpen.MouseButton1Click:Connect(function() updateRouteWin(); routeWin.Visible = not routeWin.Visible end)
btnResetRoute.MouseButton1Click:Connect(function() routeQueue = {}; updateRouteWin() end)
btnGo.MouseButton1Click:Connect(function() for _, b in ipairs(routeQueue) do local tw = smoothTP(b) if tw then tw.Completed:Wait() end task.wait(0.2) end end)

btnClear.MouseButton1Click:Connect(function()
    clearEverything(); scroll:ClearAllChildren(); Instance.new("UIListLayout", scroll); routeWin.Visible = false
end)

bHide.MouseButton1Click:Connect(function()
    local isH = main.Size.Y.Offset < 40
    main:TweenSize(isH and UDim2.new(0,180,0,260) or UDim2.new(0,180,0,30), "Out", "Quad", 0.2, true)
end)

-- ЗАКРЫТИЕ С УДАЛЕНИЕМ БЛОКОВ
bClose.MouseButton1Click:Connect(function() 
    clearEverything()
    sg:Destroy() 
end)
