local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options

local Window = Library:CreateWindow({
    Title = "TrashHub - 项目三角洲",
    Footer = "TrashHub",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Player = Window:AddTab("玩家", "user"),
    Weapon = Window:AddTab("武器", "sword"),
    ESP = Window:AddTab("透视", "eye"),
    Aimbot = Window:AddTab("瞄准", "crosshair"),
    World = Window:AddTab("世界", "globe"),
    Other = Window:AddTab("其他", "box"),
    Settings = Window:AddTab("设置", "settings"),
}

local P = game:GetService("Players")
local R = game:GetService("RunService")
local W = game:GetService("Workspace")
local C = workspace.CurrentCamera
local LS = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")
local I = game:GetService("UserInputService")
local LP = P.LocalPlayer

local Settings = {
    aim = { e = 0, p = "Head", s = 1, f = 100, r = 1000, w = 0, c = 0, ps = "All", sm = "Raycast", hc = 100, ut = 0, pr = "FOV", wb = 0, t = 0 },
    esp = { e = 0, c = Color3.new(1,1,1), it = 0, itc = Color3.new(0,1,0) },
    ply = { sp = 0, sv = 36, fl = 0, fv = 5, jp = 0, jv = 70, inf = 0, nh = 0, ns = 0, fb = 0, tp = 0, tpv = 10, rot = 0, rotv = 30, bh = 0, bhv = 2, up = 0, upv = 0, tpk = 0, tpkv = 350, nf = 0, nfs = 0, shsil = 0, shs = 17, os = 0, invb = 0, repb = 0, visor = 0, gas = 0 },
    wep = { nr = 0, nsd = 0, ie = 0, bt = 0, btc = Color3.new(1,1,1), btd = 0.5, sk = 0, skn = "Anton", skbl = {stock=1,front=1,sight=1,mag=1,handle=1,muzzle=1,extra=1,root=1}, hs = 0, hsid = "Default", hsv = 1 },
    wld = { nf = 0, nc = 0, amb = 0, ambc = Color3.new(1,0.5,0), ambrgb = 0, ambrs = 0.5, time = 0, tv = "12:00:00", fol = 0, clc = 0, clcc = Color3.new(0.2,0.06,0.37), clct = 0.25 },
    oth = { mod = 0, cheat = 0, inv = 0, invv = 0, invf = 0, invp = 0, itemf = 0, iteml = {} }
}

local function getChar() return LP.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar() return c and c:FindFirstChild("Humanoid") end
local function isEnemy(p)
    if p == LP then return false end
    if LP.Team and p.Team and LP.Team == p.Team then return false end
    return true
end
local function getEnemies()
    local t = {}
    for _, p in pairs(P:GetPlayers()) do
        if isEnemy(p) then
            local c = p.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local h = c:FindFirstChild("Humanoid")
                if h and h.Health > 0 then table.insert(t, p) end
            end
        end
    end
    return t
end
local function hasObstacle(plr, pos)
    if not C then return true end
    local origin = C.CFrame.Position
    local dir = (pos - origin).Unit
    local dist = (pos - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {getChar(), C}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    local res = W:Raycast(origin, dir * dist, params)
    if res then
        local hit = res.Instance
        local hitPlr = P:GetPlayerFromCharacter(hit:FindFirstAncestorOfClass("Model"))
        return (hitPlr and hitPlr ~= plr) or (not hitPlr)
    end
    return false
end
local function getTargetInFOV()
    local root = getRoot()
    if not root or not C then return nil, nil end
    local fov = Settings.aim.f
    local center = Vector2.new(C.ViewportSize.X / 2, C.ViewportSize.Y / 2)
    local closestTarget, closestPos = nil, nil
    local closestDist = fov
    for _, p in pairs(getEnemies()) do
        local targetPart = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local dist = (targetPart.Position - root.Position).Magnitude
            if dist <= Settings.aim.r then
                local screenPos, onScreen = C:WorldToViewportPoint(targetPart.Position)
                if onScreen and screenPos.Z > 0 then
                    local d = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if d <= fov then
                        local blocked = false
                        if Settings.aim.w == 1 then blocked = hasObstacle(p, targetPart.Position) end
                        if not blocked and d < closestDist then
                            closestDist = d
                            closestTarget = p
                            closestPos = targetPart.Position
                        end
                    end
                end
            end
        end
    end
    return closestTarget, closestPos
end
local function aimbotLoop()
    if Settings.aim.e == 0 then return end
    local _, targetPos = getTargetInFOV()
    if targetPos then
        pcall(function()
            local camPos = C.CFrame.Position
            if (targetPos - camPos).Magnitude < 0.001 then return end
            local look = CFrame.lookAt(camPos, targetPos)
            if Settings.aim.s > 1 then
                local speed = math.clamp((Settings.aim.s / 500) * 0.2, 0.02, 0.2)
                C.CFrame = C.CFrame:Lerp(look, speed)
            else
                C.CFrame = look
            end
        end)
    end
end
local fovCircle = nil
local function updateFOVCircle()
    if not fovCircle then return end
    local frame = fovCircle:FindFirstChild("F")
    if frame then
        local sz = Settings.aim.f * 2
        frame.Size = UDim2.new(0, sz, 0, sz)
        frame.Position = UDim2.new(0.5, -Settings.aim.f, 0.5, -Settings.aim.f)
        local _, t = getTargetInFOV()
        frame.UIStroke.Color = t and Color3.new(0,1,0) or Color3.new(1,0,0)
    end
end
local function createFOVCircle()
    if fovCircle then pcall(function() fovCircle:Destroy() end) end
    local parent = game:GetService("CoreGui") or LP:FindFirstChild("PlayerGui")
    if not parent then return end
    fovCircle = Instance.new("ScreenGui")
    fovCircle.Name = "TF"
    fovCircle.Parent = parent
    fovCircle.ResetOnSpawn = false
    fovCircle.Enabled = (Settings.aim.ut == 1)
    local frame = Instance.new("Frame")
    frame.Name = "F"
    frame.Size = UDim2.new(0, Settings.aim.f * 2, 0, Settings.aim.f * 2)
    frame.Position = UDim2.new(0.5, -Settings.aim.f, 0.5, -Settings.aim.f)
    frame.BackgroundTransparency = 1
    frame.Parent = fovCircle
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1,0)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = frame
    task.spawn(function()
        while fovCircle and fovCircle.Parent and Settings.aim.ut == 1 do
            pcall(updateFOVCircle)
            task.wait(0.1)
        end
    end)
end
local function setAimbotEnabled(state)
    if Connections.Aimbot then Connections.Aimbot:Disconnect() end
    if state then
        Connections.Aimbot = R.RenderStepped:Connect(aimbotLoop)
    else
        Connections.Aimbot = nil
    end
end
local currentSilentTarget = nil
local function getSilentTarget()
    local c = getChar()
    if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local root = getRoot()
    if not root then return nil end
    local candidates = {}
    local targetMode = Settings.aim.ps
    local function processModel(model)
        if Settings.aim.t == 1 and model.Team and model.Team == LP.Team then return end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local part = model:FindFirstChild(Settings.aim.p) or model:FindFirstChild("HumanoidRootPart")
        if not part then return end
        if Settings.aim.c == 1 then
            local origin = C.CFrame.Position
            local direction = part.Position - origin
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {c, part.Parent}
            if W:Raycast(origin, direction.Unit * direction.Magnitude, params) then return end
        end
        local dist = (root.Position - part.Position).Magnitude
        if dist > Settings.aim.r then return end
        table.insert(candidates, {model=model, part=part, dist=dist, health=hum.Health})
    end
    if targetMode == "Player" or targetMode == "All" then
        for _, p in pairs(P:GetPlayers()) do
            if p ~= LP and p.Character then processModel(p.Character) end
        end
    end
    if targetMode == "NPC" or targetMode == "All" then
        for _, v in pairs(W:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and not P:GetPlayerFromCharacter(v) then
                processModel(v)
            end
        end
    end
    if #candidates == 0 then return nil end
    table.sort(candidates, function(a,b)
        local pri = Settings.aim.pr
        if pri == "Health" then return a.health < b.health
        elseif pri == "Distance" then return a.dist < b.dist end
        return a.dist < b.dist
    end)
    return candidates[1].part
end
local oldNamecall, oldIndex, oldRayNew = nil, nil, nil
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local method = getnamecallmethod()
    local args = {...}
    local self = args[1]
    if Settings.aim.e == 1 and not checkcaller() and math.random() <= Settings.aim.hc / 100 and currentSilentTarget then
        local curMethod = Settings.aim.sm
        if (method == "FindPartOnRayWithIgnoreList" and curMethod == method) or
           (method == "FindPartOnRayWithWhitelist" and curMethod == method) or
           ((method == "FindPartOnRay" or method == "findPartOnRay") and curMethod:lower() == method:lower()) then
            if args[2] and args[2].Origin then
                if Settings.aim.wb == 1 then return currentSilentTarget, currentSilentTarget.Position end
                local dir = (currentSilentTarget.Position - args[2].Origin).Unit * 1000
                args[2] = Ray.new(args[2].Origin, dir)
                return oldNamecall(unpack(args))
            end
        elseif method == "Raycast" and curMethod == method then
            if args[2] and args[3] then
                if Settings.aim.wb == 1 then
                    local dir = (currentSilentTarget.Position - args[2]).Unit * 1000
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Include
                    params.FilterDescendantsInstances = {currentSilentTarget.Parent}
                    return oldNamecall(args[1], args[2], dir, params)
                end
                args[3] = (currentSilentTarget.Position - args[2]).Unit * 1000
                return oldNamecall(unpack(args))
            end
        elseif (method == "ScreenPointToRay" or method == "ViewportPointToRay") and curMethod == method and self == C then
            return Ray.new(C.CFrame.Position, (currentSilentTarget.Position - C.CFrame.Position).Unit)
        end
    end
    return oldNamecall(...)
end))
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, idx)
    if self == LP:GetMouse() and not checkcaller() and Settings.aim.e == 1 and Settings.aim.sm == "Mouse.Hit/Target" and currentSilentTarget then
        if idx:lower() == "hit" then return currentSilentTarget.CFrame end
    end
    return oldIndex(self, idx)
end))
oldRayNew = hookfunction(Ray.new, newcclosure(function(origin, direction)
    if Settings.aim.e == 1 and Settings.aim.sm == "Ray" and currentSilentTarget and not checkcaller() and math.random() <= Settings.aim.hc / 100 then
        return oldRayNew(origin, (currentSilentTarget.Position - origin).Unit * 1000)
    end
    return oldRayNew(origin, direction)
end))
local flyConnection = nil
local function startFly()
    if flyConnection then flyConnection:Disconnect() end
    local c = getChar()
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local head = c:FindFirstChild("Head")
    if not hum or not head then return end
    hum.PlatformStand = true
    head.Anchored = true
    flyConnection = R.Heartbeat:Connect(function(dt)
        if Settings.ply.fl == 0 or not getChar() then
            stopFly()
            return
        end
        local c = getChar()
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local head = c and c:FindFirstChild("Head")
        if not hum or not head then
            stopFly()
            return
        end
        local moveDir = hum.MoveDirection * (Settings.ply.fv * dt * 50)
        local headCF = head.CFrame
        local camCF = C.CFrame
        local offset = headCF:ToObjectSpace(camCF).Position
        camCF = camCF * CFrame.new(-offset.X, -offset.Y, -offset.Z + 1)
        local objSpace = CFrame.new(camCF.Position, Vector3.new(headCF.X, camCF.Y, headCF.Z)):VectorToObjectSpace(moveDir)
        head.CFrame = CFrame.new(headCF.Position) * (camCF - camCF.Position) * CFrame.new(objSpace)
    end)
end
local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    local c = getChar()
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        local head = c:FindFirstChild("Head")
        if head then head.Anchored = false end
    end
end
local rotateThread = nil
local function startRotate()
    if rotateThread then task.cancel(rotateThread) end
    rotateThread = task.spawn(function()
        local last = os.clock()
        while Settings.ply.rot == 1 do
            local now = os.clock()
            local dt = now - last
            last = now
            local sp = Settings.ply.rotv
            if sp > 0 and dt > 0 then
                local r = getRoot()
                if r then
                    r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(sp * dt), 0)
                end
            end
            task.wait()
        end
    end)
end
local function stopRotate()
    if rotateThread then
        task.cancel(rotateThread)
        rotateThread = nil
    end
end
local bunnyHopThread = nil
local originalWalkSpeed = 16
local function startBunnyHop()
    if bunnyHopThread then task.cancel(bunnyHopThread) end
    bunnyHopThread = task.spawn(function()
        local lastJump = 0
        while Settings.ply.bh == 1 do
            local h = getHum()
            local r = getRoot()
            if h and r then
                local moving = h.MoveDirection.Magnitude > 0.1
                local onGround = h.FloorMaterial ~= Enum.Material.Air
                if moving and onGround and (tick() - lastJump) > 0.3 then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                    lastJump = tick()
                    if h.WalkSpeed ~= Settings.ply.bhv * 16 then
                        originalWalkSpeed = h.WalkSpeed
                        h.WalkSpeed = Settings.ply.bhv * 16
                    end
                elseif not moving and h.WalkSpeed ~= originalWalkSpeed then
                    h.WalkSpeed = originalWalkSpeed
                end
            end
            task.wait(0.05)
        end
        local h = getHum()
        if h then h.WalkSpeed = originalWalkSpeed end
    end)
end
local function stopBunnyHop()
    if bunnyHopThread then
        task.cancel(bunnyHopThread)
        bunnyHopThread = nil
    end
    local h = getHum()
    if h then h.WalkSpeed = originalWalkSpeed end
end
local function initInfiniteJump()
    if Settings.ply.inf == 1 then
        if Connections.InfiniteJump then Connections.InfiniteJump:Disconnect() end
        Connections.InfiniteJump = I.JumpRequest:Connect(function()
            if Settings.ply.inf == 1 then
                local h = getHum()
                if h and h:GetState() == Enum.HumanoidStateType.Landed then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if Connections.InfiniteJump then Connections.InfiniteJump:Disconnect() end
    end
end
local function setNoFog()
    if Settings.ply.nf == 1 then LS.FogEnd = 9e9 else LS.FogEnd = 100000 end
end
local function setNoClouds()
    if Settings.wld.nc == 1 then
        local c = W.Terrain:FindFirstChild("Clouds")
        if c then c.Enabled = false end
    else
        local c = W.Terrain:FindFirstChild("Clouds")
        if c then c.Enabled = true end
    end
end
local function setAmbient()
    if Settings.wld.amb == 1 then LS.Ambient = Settings.wld.ambc else LS.Ambient = Color3.new(0,0,0) end
end
local function setTimeOfDay()
    if Settings.wld.time == 1 then LS.TimeOfDay = Settings.wld.tv end
end
local function setFullBright()
    if Settings.ply.fb == 1 then
        LS.Brightness = 10
        LS.OutdoorAmbient = Color3.new(1,1,1)
        LS.Ambient = Color3.new(1,1,1)
    else
        LS.Brightness = 2
        LS.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
        LS.Ambient = Color3.new(0.5,0.5,0.5)
    end
end
local espHighlights = { players = {}, npcs = {} }
local function createHighlight(obj, color, name)
    if not obj then return nil, nil end
    local h = Instance.new("Highlight")
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0.2
    h.Adornee = obj
    h.Parent = obj
    local b = Instance.new("BillboardGui")
    b.Name = "E"
    b.Adornee = obj
    b.Size = UDim2.new(0,100,0,20)
    b.StudsOffset = Vector3.new(0,2,0)
    b.AlwaysOnTop = true
    b.Parent = obj
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,0,1,0)
    t.BackgroundTransparency = 1
    t.Text = name
    t.TextColor3 = Color3.new(1,1,1)
    t.TextStrokeTransparency = 0.5
    t.Font = Enum.Font.GothamBold
    t.TextSize = 12
    t.TextScaled = true
    t.Parent = b
    return h, b
end
local function clearPlayerESP()
    for _, data in pairs(espHighlights.players) do
        if data.h and data.h.Parent then data.h:Destroy() end
        if data.b and data.b.Parent then data.b:Destroy() end
    end
    espHighlights.players = {}
end
local function clearNPCESP()
    for _, data in pairs(espHighlights.npcs) do
        if data.h and data.h.Parent then data.h:Destroy() end
        if data.b and data.b.Parent then data.b:Destroy() end
    end
    espHighlights.npcs = {}
end
local function refreshPlayerESP()
    if Settings.esp.e == 0 then return end
    clearPlayerESP()
    for _, p in pairs(P:GetPlayers()) do
        if p ~= LP and isEnemy(p) then
            local c = p.Character
            if c then
                local h, b = createHighlight(c, Settings.esp.c, p.Name)
                if h then table.insert(espHighlights.players, {h=h, b=b}) end
            end
        end
    end
end
local function refreshNPCESP()
    if Settings.esp.it == 0 then return end
    clearNPCESP()
    for _, v in pairs(W:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and not P:GetPlayerFromCharacter(v) then
            local h, b = createHighlight(v, Settings.esp.itc, v.Name)
            if h then table.insert(espHighlights.npcs, {h=h, b=b}) end
        end
    end
end
local function setESPEnabled(state)
    if state then
        refreshPlayerESP()
        refreshNPCESP()
    else
        clearPlayerESP()
        clearNPCESP()
    end
end
local function setThirdPerson()
    if Settings.ply.tp == 1 then
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMaxZoomDistance = Settings.ply.tpv
    else
        LP.CameraMode = Enum.CameraMode.LockFirstPerson
    end
end
local invScreenGui, invScrollingFrame = nil, nil
local function createInventoryGui()
    if invScreenGui then invScreenGui:Destroy() end
    local cg = game:GetService("CoreGui")
    invScreenGui = Instance.new("ScreenGui")
    invScreenGui.Name = "InvView"
    invScreenGui.Parent = cg
    invScreenGui.ResetOnSpawn = false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,300,0,400)
    frame.Position = UDim2.new(0.5,-150,0.5,-200)
    frame.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
    frame.BackgroundTransparency = 0.2
    frame.Parent = invScreenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = frame
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,30)
    title.Text = "库存查看"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    local scroller = Instance.new("ScrollingFrame")
    scroller.Size = UDim2.new(1,0,1,-30)
    scroller.Position = UDim2.new(0,0,0,30)
    scroller.BackgroundTransparency = 1
    scroller.Parent = frame
    scroller.CanvasSize = UDim2.new(0,0,0,0)
    invScrollingFrame = scroller
    return invScreenGui
end
local function showInventory(target)
    if not target then return end
    local inv = nil
    if target.Character and target.Character:FindFirstChild("Humanoid") then
        inv = target:FindFirstChild("Inventory")
    else
        inv = RS.Players:FindFirstChild(target.Name) and RS.Players[target.Name]:FindFirstChild("Inventory")
    end
    if not inv then return end
    createInventoryGui()
    if not invScrollingFrame then return end
    for _, child in pairs(invScrollingFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    local y = 0
    local function addItem(name, amount)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0,25)
        label.Position = UDim2.new(0,0,0,y)
        label.Text = name .. (amount and amount > 1 and " x" .. amount or "")
        label.TextColor3 = Color3.new(1,1,1)
        label.BackgroundTransparency = 0.8
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = invScrollingFrame
        y = y + 25
    end
    for _, it in pairs(inv:GetChildren()) do
        local amt = it:GetAttribute("Amount") or 1
        local nm = it.Name
        if it:FindFirstChild("Inventory") then
            for _, sub in pairs(it.Inventory:GetChildren()) do
                local subAmt = sub:GetAttribute("Amount") or 1
                addItem(sub.Name, subAmt)
            end
        else
            addItem(nm, amt)
        end
    end
    invScrollingFrame.CanvasSize = UDim2.new(0,0,0,y)
    invScreenGui.Enabled = true
end
local Connections = {}
local function mainLoop()
    R.RenderStepped:Connect(function()
        if Settings.ply.sp == 1 then
            local h = getHum()
            if h then h.WalkSpeed = Settings.ply.sv end
        end
        if Settings.aim.e == 1 then currentSilentTarget = getSilentTarget() end
        aimbotLoop()
        if Settings.wld.ambrgb == 1 and Settings.wld.amb == 1 then
            LS.Ambient = Color3.fromHSV(tick() % 1 / Settings.wld.ambrs, 1, 1)
        end
        if Settings.ply.up == 1 then
            pcall(function() RS.Remotes.UpdateTilt:FireServer(Settings.ply.upv) end)
        end
        if Settings.ply.tpk == 1 and I:IsKeyDown(Enum.KeyCode.T) then
            local r = getRoot()
            if r then
                r.Velocity = Vector3.new(r.Velocity.X, Settings.ply.tpkv + math.random(-15,15), r.Velocity.Z)
            end
        end
        if Settings.ply.shsil == 1 and Settings.ply.sh == 1 then
            local h = getHum()
            if h then
                h.WalkSpeed = 0
                h.JumpPower = 0
            end
        elseif Settings.ply.shsil == 0 and Settings.ply.sh == 1 then
            local h = getHum()
            if h then h.WalkSpeed = Settings.ply.shs / 1.3 end
        end
        if Settings.ply.nfs == 1 and getChar() then
            local h = getHum()
            if h then h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end
        end
        if Settings.oth.itemf == 1 then
            for _, p in pairs(P:GetPlayers()) do
                if p ~= LP then
                    local inv = RS.Players:FindFirstChild(p.Name) and RS.Players[p.Name]:FindFirstChild("Inventory")
                    if inv then
                        for _, it in pairs(inv:GetChildren()) do
                            if it:FindFirstChild("Inventory") then
                                for _, sub in pairs(it.Inventory:GetChildren()) do
                                    if Settings.oth.iteml[sub.Name] then
                                        Library:Notify({Title="物品查找", Description=p.Name .. " 拥有 " .. sub.Name, Time=3})
                                    end
                                end
                            else
                                if Settings.oth.iteml[it.Name] then
                                    Library:Notify({Title="物品查找", Description=p.Name .. " 拥有 " .. it.Name, Time=3})
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
local function restoreDefault()
    Settings = {
        aim = {e=0}, esp = {e=0},
        ply = {sp=0,fl=0,jp=0,inf=0,nh=0,ns=0,nd=0,fb=0,tp=0,rot=0,bh=0,up=0,tpk=0,nf=0},
        wep = {nr=0,nsd=0,ie=0,bt=0,sk=0,hs=0},
        wld = {nf=0,nc=0,amb=0,time=0,fol=0,clc=0},
        oth = {inv=0,itemf=0}
    }
    local h = getHum()
    if h then
        h.WalkSpeed = 16
        h.JumpPower = 50
    end
    stopFly()
    if Connections.InfiniteJump then Connections.InfiniteJump:Disconnect() end
    stopRotate()
    stopBunnyHop()
    setAimbotEnabled(false)
    if fovCircle then fovCircle.Enabled = false end
    setESPEnabled(false)
end

local colorPresets = {"白色","红色","绿色","蓝色","黄色","青色","紫色","橙色","黑色"}
local colorValues = {
    ["白色"] = Color3.fromRGB(255,255,255),
    ["红色"] = Color3.fromRGB(255,0,0),
    ["绿色"] = Color3.fromRGB(0,255,0),
    ["蓝色"] = Color3.fromRGB(0,0,255),
    ["黄色"] = Color3.fromRGB(255,255,0),
    ["青色"] = Color3.fromRGB(0,255,255),
    ["紫色"] = Color3.fromRGB(128,0,128),
    ["橙色"] = Color3.fromRGB(255,165,0),
    ["黑色"] = Color3.fromRGB(0,0,0),
}
local function CreateColorDropdown(group, id, name, currentColor, callback, tooltip)
    if not currentColor then currentColor = Color3.new(1,1,1) end
    local curName = "白色"
    for cname, col in pairs(colorValues) do
        if col.R == currentColor.R and col.G == currentColor.G and col.B == currentColor.B then
            curName = cname
            break
        end
    end
    group:AddDropdown("Color_" .. id, {
        Text = name,
        Values = colorPresets,
        Default = curName,
        Tooltip = tooltip or "",
        Callback = function(Value)
            if callback then callback(colorValues[Value]) end
        end
    })
end

local fpsLabel = Library:AddDraggableLabel("TrashHub | 60 fps")

local function createUI()
    local playerGroup = Tabs.Player:AddLeftGroupbox("移动", "zap")
    playerGroup:AddToggle("SpeedToggle", {
        Text = "加速",
        Default = Settings.ply.sp == 1,
        Callback = function(v)
            Settings.ply.sp = v and 1 or 0
            local h = getHum()
            if h then h.WalkSpeed = v and Settings.ply.sv or 16 end
        end
    })
    playerGroup:AddSlider("SpeedValue", {
        Text = "速度值",
        Default = Settings.ply.sv,
        Min = 16,
        Max = 200,
        Callback = function(v)
            Settings.ply.sv = v
            if Settings.ply.sp == 1 then
                local h = getHum()
                if h then h.WalkSpeed = v end
            end
        end
    })
    playerGroup:AddToggle("FlyToggle", {
        Text = "飞行",
        Default = Settings.ply.fl == 1,
        Callback = function(v)
            Settings.ply.fl = v and 1 or 0
            if v then startFly() else stopFly() end
        end
    })
    playerGroup:AddSlider("FlySpeed", {
        Text = "飞行速度",
        Default = Settings.ply.fv,
        Min = 1,
        Max = 10,
        Callback = function(v) Settings.ply.fv = v end
    })
    playerGroup:AddToggle("JumpToggle", {
        Text = "高跳",
        Default = Settings.ply.jp == 1,
        Callback = function(v)
            Settings.ply.jp = v and 1 or 0
            local h = getHum()
            if h then h.JumpPower = v and Settings.ply.jv or 50 end
        end
    })
    playerGroup:AddSlider("JumpPower", {
        Text = "跳跃高度",
        Default = Settings.ply.jv,
        Min = 30,
        Max = 200,
        Callback = function(v)
            Settings.ply.jv = v
            if Settings.ply.jp == 1 then
                local h = getHum()
                if h then h.JumpPower = v end
            end
        end
    })
    playerGroup:AddToggle("InfJumpToggle", {
        Text = "无限跳跃",
        Default = Settings.ply.inf == 1,
        Callback = function(v)
            Settings.ply.inf = v and 1 or 0
            initInfiniteJump()
        end
    })
    playerGroup:AddToggle("BunnyHopToggle", {
        Text = "兔子跳",
        Default = Settings.ply.bh == 1,
        Callback = function(v)
            Settings.ply.bh = v and 1 or 0
            if v then startBunnyHop() else stopBunnyHop() end
        end
    })
    playerGroup:AddSlider("BHopMultiplier", {
        Text = "加速倍率",
        Default = Settings.ply.bhv,
        Min = 1,
        Max = 5,
        Callback = function(v) Settings.ply.bhv = v end
    })
    playerGroup:AddToggle("RotateToggle", {
        Text = "旋转",
        Default = Settings.ply.rot == 1,
        Callback = function(v)
            Settings.ply.rot = v and 1 or 0
            if v then startRotate() else stopRotate() end
        end
    })
    playerGroup:AddSlider("RotateSpeed", {
        Text = "旋转速度",
        Default = Settings.ply.rotv,
        Min = 30,
        Max = 360,
        Callback = function(v) Settings.ply.rotv = v end
    })
    playerGroup:AddToggle("OmniSprintToggle", {
        Text = "全方位冲刺",
        Default = Settings.ply.os == 1,
        Callback = function(v) Settings.ply.os = v and 1 or 0 end
    })
    playerGroup:AddToggle("SilentSpeedToggle", {
        Text = "静默加速",
        Default = Settings.ply.shsil == 1,
        Callback = function(v) Settings.ply.shsil = v and 1 or 0 end
    })
    playerGroup:AddSlider("SilentSpeedValue", {
        Text = "加速速度",
        Default = Settings.ply.shs,
        Min = 5,
        Max = 17,
        Callback = function(v) Settings.ply.shs = v end
    })
    playerGroup:AddToggle("NoFallDmgToggle", {
        Text = "无坠落伤害",
        Default = Settings.ply.nfs == 1,
        Callback = function(v) Settings.ply.nfs = v and 1 or 0 end
    })

    local visualGroup = Tabs.Player:AddRightGroupbox("视觉", "eye")
    visualGroup:AddToggle("NightVisionToggle", {
        Text = "夜视",
        Default = Settings.ply.nh == 1,
        Callback = function(v)
            Settings.ply.nh = v and 1 or 0
            LS.Ambient = v and Color3.new(1,1,1) or Color3.new(0,0,0)
            LS.Brightness = v and 2 or 0.5
        end
    })
    visualGroup:AddToggle("NoShadowsToggle", {
        Text = "无阴影",
        Default = Settings.ply.ns == 1,
        Callback = function(v)
            Settings.ply.ns = v and 1 or 0
            LS.GlobalShadows = not v
        end
    })
    visualGroup:AddToggle("NoFogToggle", {
        Text = "无雾",
        Default = Settings.ply.nf == 1,
        Callback = function(v)
            Settings.ply.nf = v and 1 or 0
            setNoFog()
        end
    })
    visualGroup:AddToggle("FullBrightToggle", {
        Text = "全亮",
        Default = Settings.ply.fb == 1,
        Callback = function(v)
            Settings.ply.fb = v and 1 or 0
            setFullBright()
        end
    })
    visualGroup:AddToggle("ThirdPersonToggle", {
        Text = "第三人称",
        Default = Settings.ply.tp == 1,
        Callback = function(v)
            Settings.ply.tp = v and 1 or 0
            setThirdPerson()
        end
    })
    visualGroup:AddSlider("TPDistance", {
        Text = "第三人称距离",
        Default = Settings.ply.tpv,
        Min = 5,
        Max = 50,
        Callback = function(v)
            Settings.ply.tpv = v
            if Settings.ply.tp == 1 then LP.CameraMaxZoomDistance = v end
        end
    })
    visualGroup:AddToggle("NoVisorToggle", {
        Text = "无面罩/闪光",
        Default = Settings.ply.visor == 1,
        Callback = function(v)
            Settings.ply.visor = v and 1 or 0
            local ng = LP.PlayerGui:FindFirstChild("NoInsetGui")
            if ng and ng.MainFrame and ng.MainFrame.ScreenEffects then
                local se = ng.MainFrame.ScreenEffects
                if se.Visor then se.Visor.Visible = not v end
                if se.HelmetMask then se.HelmetMask.Visible = not v end
                if se.Mask then se.Mask.Visible = not v end
                if se.Flashbang then se.Flashbang.Visible = not v end
            end
        end
    })
    visualGroup:AddToggle("NoInvBlurToggle", {
        Text = "无库存模糊",
        Default = Settings.ply.invb == 1,
        Callback = function(v)
            Settings.ply.invb = v and 1 or 0
            if LS:FindFirstChild("InventoryBlur") then LS.InventoryBlur.Size = v and 0 or 20 end
        end
    })
    visualGroup:AddToggle("NoRepairBlurToggle", {
        Text = "无修理模糊",
        Default = Settings.ply.repb == 1,
        Callback = function(v)
            Settings.ply.repb = v and 1 or 0
            local vm = C:FindFirstChild("ViewModel")
            if vm and vm.Item and vm.Item.Attachments and vm.Item.Attachments.Sight and vm.Item.Attachments.Sight.Reapir and vm.Item.Attachments.Sight.Reapir.Reticle and vm.Item.Attachments.Sight.Reapir.Reticle.PrismScopeGui then
                local r = vm.Item.Attachments.Sight.Reapir.Reticle.PrismScopeGui.Sight.StaticLCD
                if r then r.Visible = not v end
            end
        end
    })
    visualGroup:AddToggle("GasMaskMuteToggle", {
        Text = "防毒面具静音",
        Default = Settings.ply.gas == 1,
        Callback = function(v) Settings.ply.gas = v and 1 or 0 end
    })
    visualGroup:AddToggle("UpperCornerToggle", {
        Text = "上角修改",
        Default = Settings.ply.up == 1,
        Callback = function(v) Settings.ply.up = v and 1 or 0 end
    })
    visualGroup:AddSlider("UpperCornerValue", {
        Text = "上角值",
        Default = Settings.ply.upv,
        Min = -160,
        Max = 160,
        Callback = function(v)
            Settings.ply.upv = v
            if Settings.ply.up == 1 then pcall(function() RS.Remotes.UpdateTilt:FireServer(v) end) end
        end
    })
    visualGroup:AddToggle("TPKillToggle", {
        Text = "TP杀",
        Default = Settings.ply.tpk == 1,
        Callback = function(v) Settings.ply.tpk = v and 1 or 0 end
    })
    visualGroup:AddSlider("TPKillSpeed", {
        Text = "TP杀速度",
        Default = Settings.ply.tpkv,
        Min = 50,
        Max = 1000,
        Callback = function(v) Settings.ply.tpkv = v end
    })

    local wepGroup = Tabs.Weapon:AddLeftGroupbox("修改", "wrench")
    wepGroup:AddToggle("NoRecoilToggle", {
        Text = "无后座",
        Default = Settings.wep.nr == 1,
        Callback = function(v)
            Settings.wep.nr = v and 1 or 0
            for _, a in pairs(RS.AmmoTypes:GetChildren()) do
                if v then a:SetAttribute("RecoilStrength", 0) else a:SetAttribute("RecoilStrength", a:GetAttribute("RecoilStrength") or 1) end
            end
        end
    })
    wepGroup:AddToggle("NoSpreadToggle", {
        Text = "无散布",
        Default = Settings.wep.nsd == 1,
        Callback = function(v)
            Settings.wep.nsd = v and 1 or 0
            for _, a in pairs(RS.AmmoTypes:GetChildren()) do
                if v then
                    a:SetAttribute("AccuracyDeviation", 0)
                    a:SetAttribute("ProjectileDrop", 0)
                else
                    a:SetAttribute("AccuracyDeviation", a:GetAttribute("AccuracyDeviation") or 1)
                end
            end
        end
    })
    wepGroup:AddToggle("InstantReloadToggle", {
        Text = "瞬间换弹",
        Default = Settings.wep.ie == 1,
        Callback = function(v) Settings.wep.ie = v and 1 or 0 end
    })
    wepGroup:AddToggle("BulletTraceToggle", {
        Text = "弹道追踪",
        Default = Settings.wep.bt == 1,
        Callback = function(v) Settings.wep.bt = v and 1 or 0 end
    })
    CreateColorDropdown(wepGroup, "TraceColor", "追踪颜色", Settings.wep.btc, function(v)
        Settings.wep.btc = v
    end)
    wepGroup:AddSlider("TraceDuration", {
        Text = "追踪持续时间",
        Default = Settings.wep.btd,
        Min = 0.1,
        Max = 2,
        Rounding = 1,
        Callback = function(v) Settings.wep.btd = v end
    })
    wepGroup:AddToggle("HitSoundToggle", {
        Text = "自定义命中音效",
        Default = Settings.wep.hs == 1,
        Callback = function(v) Settings.wep.hs = v and 1 or 0 end
    })
    wepGroup:AddDropdown("HitSoundSelect", {
        Text = "命中音效",
        Values = {"Default","Rust","Neverlose","Gamesense","Bubble","Ding","Bruh","CS 1.6","Windows XP","TeamFortress","Toilet","FAAHH"},
        Default = Settings.wep.hsid,
        Callback = function(v) Settings.wep.hsid = v end
    })
    wepGroup:AddSlider("HitSoundVolume", {
        Text = "音效音量",
        Default = Settings.wep.hsv,
        Min = 0,
        Max = 1,
        Rounding = 1,
        Callback = function(v) Settings.wep.hsv = v end
    })

    local skinGroup = Tabs.Weapon:AddRightGroupbox("皮肤", "palette")
    skinGroup:AddToggle("SkinToggle", {
        Text = "皮肤更换",
        Default = Settings.wep.sk == 1,
        Callback = function(v) Settings.wep.sk = v and 1 or 0 end
    })
    skinGroup:AddDropdown("SkinSelect", {
        Text = "皮肤",
        Values = {"Anton","Banana","SpaceSuit","Valentine","Crusader","Freedom","Artic","Nutcracker","Watergun","Serpant","Galaxy","Hunter","Permafrost","Thunder","GiftWrap","Shoreline","Ancient","AnodizedRed","DeltaAnime","PeaceWalker","Anarchy","Blackout","Tan","TigerStripe","VOLK","Woodland","Pineapple","Apollo","Shark","Devil","Dialbo","Melon","WhiteDeath"},
        Default = Settings.wep.skn,
        Callback = function(v) Settings.wep.skn = v end
    })
    skinGroup:AddDropdown("SkinBlacklist", {
        Text = "黑名单部件",
        Values = {"Stock","Front","Sight","Magazine","Handle","Muzzle","Extra","ItemRoot"},
        Multi = true,
        Default = (function()
            local res = {}
            for k,v in pairs(Settings.wep.skbl) do if v == 0 then table.insert(res, k) end end
            return res
        end)(),
        Callback = function(v)
            for k in pairs(Settings.wep.skbl) do Settings.wep.skbl[k] = 1 end
            for _, n in pairs(v) do Settings.wep.skbl[n] = 0 end
        end
    })

    local pEspGroup = Tabs.ESP:AddLeftGroupbox("玩家", "users")
    pEspGroup:AddToggle("ESPEnable", {
        Text = "启用ESP",
        Default = Settings.esp.e == 1,
        Callback = function(v) Settings.esp.e = v and 1 or 0 setESPEnabled(v) end
    })
    pEspGroup:AddSlider("ESPMaxDist", {
        Text = "最大距离",
        Default = Settings.esp.x,
        Min = 50,
        Max = 500,
        Callback = function(v) Settings.esp.x = v end
    })
    CreateColorDropdown(pEspGroup, "ESPBoxColor", "方框颜色", Settings.esp.c, function(v)
        Settings.esp.c = v
        if Settings.esp.e == 1 then setESPEnabled(true) end
    end)
    pEspGroup:AddToggle("ESPName", {
        Text = "显示名称",
        Default = Settings.esp.n == 1,
        Callback = function(v) Settings.esp.n = v and 1 or 0 setESPEnabled(Settings.esp.e == 1) end
    })
    pEspGroup:AddToggle("ESPHealth", {
        Text = "显示血量",
        Default = Settings.esp.h == 1,
        Callback = function(v) Settings.esp.h = v and 1 or 0 setESPEnabled(Settings.esp.e == 1) end
    })
    pEspGroup:AddToggle("ESPDistance", {
        Text = "显示距离",
        Default = Settings.esp.d == 1,
        Callback = function(v) Settings.esp.d = v and 1 or 0 setESPEnabled(Settings.esp.e == 1) end
    })
    pEspGroup:AddToggle("ESPSkeleton", {
        Text = "显示骨骼",
        Default = Settings.esp.s == 1,
        Callback = function(v) Settings.esp.s = v and 1 or 0 end
    })
    pEspGroup:AddToggle("ESPWeapon", {
        Text = "显示武器",
        Default = Settings.esp.we == 1,
        Callback = function(v) Settings.esp.we = v and 1 or 0 end
    })
    pEspGroup:AddToggle("ESPBox", {
        Text = "显示方框",
        Default = Settings.esp.b == 1,
        Callback = function(v) Settings.esp.b = v and 1 or 0 end
    })
    pEspGroup:AddToggle("ESPChams", {
        Text = "Chams",
        Default = Settings.esp.ch == 1,
        Callback = function(v) Settings.esp.ch = v and 1 or 0 end
    })
    CreateColorDropdown(pEspGroup, "ChamsColor", "Chams颜色", Settings.esp.chc, function(v)
        Settings.esp.chc = v
    end)
    pEspGroup:AddToggle("ESPChamsAlways", {
        Text = "总是显示Chams",
        Default = Settings.esp.chh == 1,
        Callback = function(v) Settings.esp.chh = v and 1 or 0 end
    })
    pEspGroup:AddToggle("ESPChamsVisible", {
        Text = "仅可见时显示",
        Default = Settings.esp.chv == 1,
        Callback = function(v) Settings.esp.chv = v and 1 or 0 end
    })

    local oEspGroup = Tabs.ESP:AddRightGroupbox("其他", "box")
    oEspGroup:AddToggle("ESPItems", {
        Text = "物品ESP",
        Default = Settings.esp.it == 1,
        Callback = function(v) Settings.esp.it = v and 1 or 0 refreshNPCESP() end
    })
    CreateColorDropdown(oEspGroup, "ItemColor", "物品颜色", Settings.esp.itc, function(v)
        Settings.esp.itc = v
        if Settings.esp.it == 1 then refreshNPCESP() end
    end)
    oEspGroup:AddToggle("ESPContainers", {
        Text = "容器ESP",
        Default = Settings.esp.cq == 1,
        Callback = function(v) Settings.esp.cq = v and 1 or 0 end
    })
    CreateColorDropdown(oEspGroup, "ContainerColor", "容器颜色", Settings.esp.cqc, function(v)
        Settings.esp.cqc = v
    end)
    oEspGroup:AddToggle("ESPExfil", {
        Text = "撤离点ESP",
        Default = Settings.esp.ex == 1,
        Callback = function(v) Settings.esp.ex = v and 1 or 0 end
    })
    CreateColorDropdown(oEspGroup, "ExfilColor", "撤离点颜色", Settings.esp.exc, function(v)
        Settings.esp.exc = v
    end)
    oEspGroup:AddToggle("ESPQuest", {
        Text = "任务ESP",
        Default = Settings.esp.qs == 1,
        Callback = function(v) Settings.esp.qs = v and 1 or 0 end
    })
    CreateColorDropdown(oEspGroup, "QuestColor", "任务颜色", Settings.esp.qsc, function(v)
        Settings.esp.qsc = v
    end)
    oEspGroup:AddToggle("ESPVehicle", {
        Text = "载具ESP",
        Default = Settings.esp.ve == 1,
        Callback = function(v) Settings.esp.ve = v and 1 or 0 end
    })
    CreateColorDropdown(oEspGroup, "VehicleColor", "载具颜色", Settings.esp.vec, function(v)
        Settings.esp.vec = v
    end)
    oEspGroup:AddToggle("ESPAI", {
        Text = "AI高亮",
        Default = Settings.esp.ai == 1,
        Callback = function(v)
            Settings.esp.ai = v and 1 or 0
            if v then refreshNPCESP() else clearNPCESP() end
        end
    })
    CreateColorDropdown(oEspGroup, "AIColor", "AI颜色", Settings.esp.aic, function(v)
        Settings.esp.aic = v
    end)
    oEspGroup:AddToggle("ESPNameAI", {
        Text = "AI名牌",
        Default = Settings.esp.ain == 1,
        Callback = function(v) Settings.esp.ain = v and 1 or 0 end
    })
    CreateColorDropdown(oEspGroup, "AINameColor", "AI名牌颜色", Settings.esp.aicn, function(v)
        Settings.esp.aicn = v
    end)

    local normGroup = Tabs.Aimbot:AddLeftGroupbox("普通自瞄", "crosshair")
    normGroup:AddToggle("AimbotEnable", {
        Text = "启用自瞄",
        Default = Settings.aim.e == 1,
        Callback = function(v) Settings.aim.e = v and 1 or 0 setAimbotEnabled(v) end
    })
    normGroup:AddToggle("ShowFOV", {
        Text = "显示FOV",
        Default = Settings.aim.ut == 1,
        Callback = function(v)
            Settings.aim.ut = v and 1 or 0
            if v then createFOVCircle() elseif fovCircle then fovCircle.Enabled = false end
        end
    })
    normGroup:AddSlider("FOVSize", {
        Text = "FOV大小",
        Default = Settings.aim.f,
        Min = 30,
        Max = 500,
        Callback = function(v)
            Settings.aim.f = v
            if Settings.aim.ut == 1 then createFOVCircle() end
        end
    })
    normGroup:AddToggle("AimbotWallCheck", {
        Text = "掩体判断",
        Default = Settings.aim.w == 1,
        Callback = function(v) Settings.aim.w = v and 1 or 0 end
    })
    normGroup:AddToggle("AimbotSmooth", {
        Text = "平滑自瞄",
        Default = Settings.aim.s > 1,
        Callback = function(v) Settings.aim.s = v and 3 or 1 end
    })
    normGroup:AddSlider("AimbotSpeed", {
        Text = "自瞄速度",
        Default = Settings.aim.s,
        Min = 1,
        Max = 50,
        Callback = function(v) Settings.aim.s = v end
    })
    normGroup:AddSlider("AimbotRange", {
        Text = "自瞄距离",
        Default = Settings.aim.r,
        Min = 100,
        Max = 5000,
        Callback = function(v) Settings.aim.r = v end
    })
    normGroup:AddToggle("AimbotPrediction", {
        Text = "自瞄预测",
        Default = Settings.aim.pre == 1,
        Callback = function(v) Settings.aim.pre = v and 1 or 0 end
    })
    normGroup:AddToggle("AimbotSticky", {
        Text = "粘性瞄准",
        Default = Settings.aim.st == 1,
        Callback = function(v) Settings.aim.st = v and 1 or 0 end
    })
    normGroup:AddToggle("AutoShoot", {
        Text = "自动射击",
        Default = Settings.aim.as == 1,
        Callback = function(v) Settings.aim.as = v and 1 or 0 end
    })
    normGroup:AddDropdown("AutoShootMode", {
        Text = "自动射击模式",
        Values = {"常规","瞬击(需静默)"},
        Default = (Settings.aim.ast == 0) and "常规" or "瞬击(需静默)",
        Callback = function(v) Settings.aim.ast = (v == "常规") and 0 or 1 end
    })
    normGroup:AddToggle("InstantHit", {
        Text = "瞬击",
        Default = Settings.aim.ih == 1,
        Callback = function(v) Settings.aim.ih = v and 1 or 0 end
    })
    normGroup:AddSlider("InstantHitDelay", {
        Text = "瞬击延迟",
        Default = Settings.aim.ihd,
        Min = 0.01,
        Max = 0.5,
        Rounding = 2,
        Callback = function(v) Settings.aim.ihd = v end
    })
    normGroup:AddToggle("ShowAimTarget", {
        Text = "显示瞄准目标",
        Default = Settings.aim.tr == 1,
        Callback = function(v) Settings.aim.tr = v and 1 or 0 end
    })
    CreateColorDropdown(normGroup, "TraceLineColor", "追踪线颜色", Settings.aim.trc, function(v)
        Settings.aim.trc = v
    end)
    normGroup:AddSlider("TraceLineWidth", {
        Text = "追踪线宽度",
        Default = Settings.aim.trd,
        Min = 1,
        Max = 5,
        Callback = function(v) Settings.aim.trd = v end
    })

    local silGroup = Tabs.Aimbot:AddRightGroupbox("静默自瞄", "target")
    silGroup:AddToggle("SilentAimEnable", {
        Text = "启用静默",
        Default = Settings.aim.sm ~= 0,
        Callback = function(v) Settings.aim.sm = v and "Raycast" or 0 end
    })
    silGroup:AddDropdown("SilentTargetType", {
        Text = "目标种类",
        Values = {"玩家","NPC","所有"},
        Default = (function()
            if Settings.aim.ps == "Player" then return "玩家"
            elseif Settings.aim.ps == "NPC" then return "NPC"
            else return "所有" end
        end)(),
        Callback = function(v)
            if v == "玩家" then Settings.aim.ps = "Player"
            elseif v == "NPC" then Settings.aim.ps = "NPC"
            else Settings.aim.ps = "All" end
        end
    })
    silGroup:AddDropdown("SilentTargetPart", {
        Text = "目标部位",
        Values = {"Head","HumanoidRootPart"},
        Default = Settings.aim.p,
        Callback = function(v) Settings.aim.p = v end
    })
    silGroup:AddDropdown("SilentPriority", {
        Text = "优先模式",
        Values = {"准星最近","距离最近","最低血量"},
        Default = (function()
            if Settings.aim.pr == "Distance" then return "距离最近"
            elseif Settings.aim.pr == "Health" then return "最低血量"
            else return "准星最近" end
        end)(),
        Callback = function(v)
            if v == "距离最近" then Settings.aim.pr = "Distance"
            elseif v == "最低血量" then Settings.aim.pr = "Health"
            else Settings.aim.pr = "FOV" end
        end
    })
    silGroup:AddDropdown("SilentMethod", {
        Text = "静默方式",
        Values = {"Raycast","FindPartOnRay","ScreenPointToRay","Mouse.Hit/Target"},
        Default = Settings.aim.sm,
        Callback = function(v) Settings.aim.sm = v end
    })
    silGroup:AddSlider("SilentHitChance", {
        Text = "命中率",
        Default = Settings.aim.hc,
        Min = 0,
        Max = 100,
        Callback = function(v) Settings.aim.hc = v end
    })
    silGroup:AddToggle("SilentVisibility", {
        Text = "可见性检查",
        Default = Settings.aim.c == 1,
        Callback = function(v) Settings.aim.c = v and 1 or 0 end
    })
    silGroup:AddToggle("SilentWallbang", {
        Text = "穿墙",
        Default = Settings.aim.wb == 1,
        Callback = function(v) Settings.aim.wb = v and 1 or 0 end
    })
    silGroup:AddToggle("SilentTeamCheck", {
        Text = "团队检查",
        Default = Settings.aim.t == 1,
        Callback = function(v) Settings.aim.t = v and 1 or 0 end
    })

    local envGroup = Tabs.World:AddLeftGroupbox("环境", "globe")
    envGroup:AddToggle("NoFogWorld", {
        Text = "无雾",
        Default = Settings.wld.nf == 1,
        Callback = function(v) Settings.wld.nf = v and 1 or 0 setNoFog() end
    })
    envGroup:AddToggle("NoClouds", {
        Text = "无云",
        Default = Settings.wld.nc == 1,
        Callback = function(v) Settings.wld.nc = v and 1 or 0 setNoClouds() end
    })
    envGroup:AddToggle("NoLeaves", {
        Text = "无树叶",
        Default = Settings.wld.fol == 1,
        Callback = function(v)
            Settings.wld.fol = v and 1 or 0
            for _, o in pairs(W:GetDescendants()) do
                if o:IsA("BasePart") and o.Material == Enum.Material.Foliage then
                    o.Transparency = v and 1 or 0
                end
            end
        end
    })
    envGroup:AddToggle("CloudModify", {
        Text = "云彩修改",
        Default = Settings.wld.clc == 1,
        Callback = function(v)
            Settings.wld.clc = v and 1 or 0
            local c = W.Terrain:FindFirstChild("Clouds")
            if c and v then
                c.Color = Settings.wld.clcc
                c.Density = Settings.wld.clct
            end
        end
    })
    CreateColorDropdown(envGroup, "CloudColor", "云彩颜色", Settings.wld.clcc, function(v)
        Settings.wld.clcc = v
        if Settings.wld.clc == 1 then
            local c = W.Terrain:FindFirstChild("Clouds")
            if c then c.Color = v end
        end
    end)
    envGroup:AddSlider("CloudDensity", {
        Text = "云彩密度",
        Default = Settings.wld.clct,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(v)
            Settings.wld.clct = v
            if Settings.wld.clc == 1 then
                local c = W.Terrain:FindFirstChild("Clouds")
                if c then c.Density = v end
            end
        end
    })
    envGroup:AddDropdown("Skybox", {
        Text = "天空盒",
        Values = {"默认","夜晚","银河","粉色天空","橙色日落","紫色太空","春季天空"},
        Default = Settings.wld.skyv,
        Callback = function(v)
            Settings.wld.skyv = v
            local s = LS:FindFirstChildOfClass("Sky")
            if not s then s = Instance.new("Sky") s.Parent = LS end
            if v == "夜晚" then
                s.SkyboxBk = "rbxassetid://15470149279"
                s.SkyboxDn = "rbxassetid://15470151245"
                s.SkyboxFt = "rbxassetid://15470153860"
                s.SkyboxLf = "rbxassetid://15470155938"
                s.SkyboxRt = "rbxassetid://15470158022"
                s.SkyboxUp = "rbxassetid://15470160563"
            elseif v == "银河" then
                s.SkyboxBk = "rbxassetid://159454299"
                s.SkyboxDn = "rbxassetid://159454296"
                s.SkyboxFt = "rbxassetid://159454293"
                s.SkyboxLf = "rbxassetid://159454286"
                s.SkyboxRt = "rbxassetid://159454300"
                s.SkyboxUp = "rbxassetid://159454288"
            elseif v == "粉色天空" then
                s.SkyboxBk = "rbxassetid://271042516"
                s.SkyboxDn = "rbxassetid://271077243"
                s.SkyboxFt = "rbxassetid://271042556"
                s.SkyboxLf = "rbxassetid://271042310"
                s.SkyboxRt = "rbxassetid://271042467"
                s.SkyboxUp = "rbxassetid://271077958"
            elseif v == "橙色日落" then
                s.SkyboxBk = "rbxassetid://458016711"
                s.SkyboxDn = "rbxassetid://458016826"
                s.SkyboxFt = "rbxassetid://458016532"
                s.SkyboxLf = "rbxassetid://458016655"
                s.SkyboxRt = "rbxassetid://458016782"
                s.SkyboxUp = "rbxassetid://458016792"
            elseif v == "紫色太空" then
                s.SkyboxBk = "rbxassetid://14543264135"
                s.SkyboxDn = "rbxassetid://14543358958"
                s.SkyboxFt = "rbxassetid://14543257810"
                s.SkyboxLf = "rbxassetid://14543275895"
                s.SkyboxRt = "rbxassetid://14543280890"
                s.SkyboxUp = "rbxassetid://14543371676"
            elseif v == "春季天空" then
                s.SkyboxBk = "rbxassetid://12216109205"
                s.SkyboxDn = "rbxassetid://12216109875"
                s.SkyboxFt = "rbxassetid://12216109489"
                s.SkyboxLf = "rbxassetid://12216110170"
                s.SkyboxRt = "rbxassetid://12216110471"
                s.SkyboxUp = "rbxassetid://12216108877"
            else
                s:Destroy()
            end
        end
    })
    envGroup:AddToggle("AmbientMod", {
        Text = "环境光修改",
        Default = Settings.wld.amb == 1,
        Callback = function(v) Settings.wld.amb = v and 1 or 0 setAmbient() end
    })
    CreateColorDropdown(envGroup, "AmbientColor", "环境光颜色", Settings.wld.ambc, function(v)
        Settings.wld.ambc = v
        if Settings.wld.amb == 1 then setAmbient() end
    end)
    envGroup:AddToggle("RGBAmbient", {
        Text = "RGB环境光",
        Default = Settings.wld.ambrgb == 1,
        Callback = function(v) Settings.wld.ambrgb = v and 1 or 0 end
    })
    envGroup:AddSlider("RGBSpeed", {
        Text = "RGB速度",
        Default = Settings.wld.ambrs,
        Min = 0.1,
        Max = 1.25,
        Rounding = 2,
        Callback = function(v) Settings.wld.ambrs = v end
    })
    envGroup:AddToggle("TimeMod", {
        Text = "时间修改",
        Default = Settings.wld.time == 1,
        Callback = function(v) Settings.wld.time = v and 1 or 0 setTimeOfDay() end
    })
    envGroup:AddSlider("TimeValue", {
        Text = "时间",
        Default = (function()
            local h = tonumber(Settings.wld.tv:match("^(%d+)")) or 12
            return h
        end)(),
        Min = 0,
        Max = 24,
        Callback = function(v)
            Settings.wld.tv = string.format("%02d:00:00", v)
            if Settings.wld.time == 1 then setTimeOfDay() end
        end
    })

    local detGroup = Tabs.Other:AddLeftGroupbox("检测", "shield")
    detGroup:AddToggle("AdminDetect", {
        Text = "管理员检测",
        Default = Settings.oth.mod == 1,
        Callback = function(v) Settings.oth.mod = v and 1 or 0 end
    })
    detGroup:AddToggle("CheaterDetect", {
        Text = "作弊者检测",
        Default = Settings.oth.cheat == 1,
        Callback = function(v) Settings.oth.cheat = v and 1 or 0 end
    })

    local invGroup = Tabs.Other:AddRightGroupbox("库存", "box")
    invGroup:AddToggle("InvViewer", {
        Text = "库存查看器",
        Default = Settings.oth.inv == 1,
        Callback = function(v) Settings.oth.inv = v and 1 or 0 end
    })
    invGroup:AddToggle("InvValue", {
        Text = "显示库存价值",
        Default = Settings.oth.invv == 1,
        Callback = function(v) Settings.oth.invv = v and 1 or 0 end
    })
    invGroup:AddToggle("InvFull", {
        Text = "完整库存显示",
        Default = Settings.oth.invf == 1,
        Callback = function(v) Settings.oth.invf = v and 1 or 0 end
    })
    invGroup:AddToggle("InvTarget", {
        Text = "显示目标",
        Default = Settings.oth.invp == 1,
        Callback = function(v) Settings.oth.invp = v and 1 or 0 end
    })
    invGroup:AddButton({
        Text = "查看目标库存",
        Func = function()
            if Settings.oth.inv == 1 then
                local tar = nil
                for _, p in pairs(P:GetPlayers()) do
                    if p ~= LP and isEnemy(p) then
                        tar = p
                        break
                    end
                end
                if tar then showInventory(tar) end
            end
        end
    })

    local itemGroup = Tabs.Other:AddLeftGroupbox("物品查找", "search")
    itemGroup:AddToggle("ItemFinder", {
        Text = "物品查找器",
        Default = Settings.oth.itemf == 1,
        Callback = function(v) Settings.oth.itemf = v and 1 or 0 end
    })
    itemGroup:AddDropdown("ItemWhitelist", {
        Text = "物品白名单",
        Values = {"TFZ98S","R700","M4","AsVal","PKM","FlareGun","SPSh44","Gold","GoldWatch","RepairKit"},
        Multi = true,
        Default = (function()
            local res = {}
            for k,_ in pairs(Settings.oth.iteml) do table.insert(res, k) end
            return res
        end)(),
        Callback = function(v)
            Settings.oth.iteml = {}
            for _, n in pairs(v) do Settings.oth.iteml[n] = 1 end
        end
    })

    local settingsGroup = Tabs.Settings:AddLeftGroupbox("配置管理", "settings")
    settingsGroup:AddButton({
        Text = "关闭所有功能",
        Func = restoreDefault
    })
    settingsGroup:AddDivider()
    settingsGroup:AddButton({
        Text = "保存配置",
        Func = function()
            SaveManager:Save()
            Library:Notify({Title="配置管理", Description="配置已保存", Time=2})
        end
    })
    settingsGroup:AddButton({
        Text = "加载配置",
        Func = function()
            SaveManager:Load()
            Library:Notify({Title="配置管理", Description="配置已加载", Time=2})
        end
    })
    settingsGroup:AddButton({
        Text = "卸载脚本",
        Func = function()
            Library:Unload()
        end
    })
end

createUI()

Library.ToggleKeybind = Enum.KeyCode.RightShift

task.spawn(function()
    task.wait(0.5)
    pcall(function()
        ThemeManager:SetLibrary(Library)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        ThemeManager:SetFolder("TrashHub_ProjectDelta")
        SaveManager:SetFolder("TrashHub_ProjectDelta")
        SaveManager:SetSubFolder("ProjectDelta")
        SaveManager:BuildConfigSection(Tabs.Settings)
        ThemeManager:ApplyToTab(Tabs.Settings)
        SaveManager:LoadAutoloadConfig()
    end)
end)

local RunService = game:GetService('RunService')
local frameTimer = tick()
local frameCounter = 0
local fps = 60
RunService.RenderStepped:Connect(function()
    frameCounter = frameCounter + 1
    if (tick() - frameTimer) >= 1 then
        fps = frameCounter
        frameTimer = tick()
        frameCounter = 0
    end
    pcall(function()
        fpsLabel:SetText("TrashHub | " .. math.floor(fps) .. " fps")
    end)
end)

mainLoop()

task.spawn(function()
    if Settings.aim.e == 1 then setAimbotEnabled(true) end
    if Settings.aim.ut == 1 then createFOVCircle() end
    if Settings.esp.e == 1 then setESPEnabled(true) end
    if Settings.ply.fl == 1 then startFly() end
    if Settings.ply.rot == 1 then startRotate() end
    if Settings.ply.bh == 1 then startBunnyHop() end
    if Settings.ply.nf == 1 then setNoFog() end
    if Settings.wld.nc == 1 then setNoClouds() end
    if Settings.wld.amb == 1 then setAmbient() end
    if Settings.wld.time == 1 then setTimeOfDay() end
    if Settings.ply.fb == 1 then setFullBright() end
    if Settings.ply.nh == 1 then LS.Ambient = Color3.new(1,1,1) LS.Brightness = 2 end
    if Settings.ply.ns == 1 then LS.GlobalShadows = false end
    if Settings.ply.inf == 1 then initInfiniteJump() end
    if Settings.ply.tp == 1 then setThirdPerson() end
end)

Library:Notify({Title = "TrashHub", Description = "加载完成", Time = 3})