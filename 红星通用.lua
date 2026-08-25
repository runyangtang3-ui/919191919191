local RunService = game:GetService("RunService")

-- WindUI 加载
local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))

local WindUI
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    if ok then
        WindUI = result
    else
        if cloneref(game:GetService("RunService")):IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- 全局服务
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- ==================== 变量定义 ====================
-- 速度
local TargetWalkSpeed = 16
local SpeedEnabled = false
local OriginalWalkSpeed = 16

-- 跳跃
local CustomJumpEnabled = false
local CustomJumpValue = 50
local OriginalJump = 50
local InfiniteJumpEnabled = false

-- 飞行
local Flying = false
local FlySpeed = 50
local FlyGui = nil
local FlyBodyGyro = nil
local FlyBodyVelocity = nil
local flyUpPressed, flyDownPressed, flyLeftPressed, flyRightPressed = false, false, false, false

-- 透视
local ESP_Players = false
local ESP_NPCs = false
local ESP_ShowName = false
local ESP_ShowDistance = false
local ESP_ShowHealth = false
local ESP_Highlights = {}
local ESP_Billboards = {}

-- ==================== 速度功能 ====================
function SetSpeedEnabled(enabled)
    SpeedEnabled = enabled
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = enabled and TargetWalkSpeed or OriginalWalkSpeed
    end
end

function SetSpeedValue(value)
    TargetWalkSpeed = math.clamp(value, 0, 400)
    if SpeedEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = TargetWalkSpeed
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if SpeedEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = TargetWalkSpeed
        end
    end
    if CustomJumpEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = CustomJumpValue
            hum.JumpHeight = CustomJumpValue * (7.2 / 50)
        end
    end
end)
-- ==================== 跳跃功能 ====================
function SetJumpEnabled(enabled)
    CustomJumpEnabled = enabled
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if enabled then
            hum.UseJumpPower = true
            hum.JumpPower = CustomJumpValue
            hum.JumpHeight = CustomJumpValue * (7.2 / 50)
        else
            hum.JumpPower = OriginalJump
            hum.JumpHeight = OriginalJump * (7.2 / 50)
        end
    end
end

function SetJumpValue(value)
    CustomJumpValue = math.clamp(value, 50, 600)
    if CustomJumpEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = CustomJumpValue
            hum.JumpHeight = CustomJumpValue * (7.2 / 50)
        end
    end
end

RunService.RenderStepped:Connect(function()
    -- 跳跃高度强制锁定
    if CustomJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = CustomJumpValue
                hum.JumpHeight = CustomJumpValue * (7.2 / 50)
            end
        end
    end
    -- 无限跳跃检测
    if InfiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    hum.Jump = true
                end
            end
        end
    end
end)
-- ==================== 飞行功能 ====================
function CreateFlyGui()
    if FlyGui then return FlyGui end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FlyControl"
    gui.Parent = game.CoreGui
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 180, 0, 200)
    frame.Position = UDim2.new(0.5, -90, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "飞行控制"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.Parent = frame

    -- 方向按钮
    local btnSize = 50
    local gap = 5
    local startX = (180 - 3 * btnSize - 2 * gap) / 2

    local function createDirectionButton(x, y, text)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, btnSize, 0, btnSize)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 20
        btn.Parent = frame
        return btn
    end

    local upBtn = createDirectionButton(startX + btnSize + gap, 40, "↑")
    local downBtn = createDirectionButton(startX + btnSize + gap, 40 + btnSize + gap, "↓")
    local leftBtn = createDirectionButton(startX, 40 + btnSize + gap, "←")
    local rightBtn = createDirectionButton(startX + 2 * (btnSize + gap), 40 + btnSize + gap, "→")

    -- 速度标签
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -20, 0, 20)
    speedLabel.Position = UDim2.new(0, 10, 0, 40 + 2 * (btnSize + gap) + 10)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "速度: 50"
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.Font = Enum.Font.SourceSans
    speedLabel.TextSize = 14
    speedLabel.Parent = frame

    -- 减速按钮
    local decBtn = Instance.new("TextButton")
    decBtn.Size = UDim2.new(0, 40, 0, 30)
    decBtn.Position = UDim2.new(0, 20, 0, 40 + 2 * (btnSize + gap) + 35)
    decBtn.Text = "-"
    decBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    decBtn.TextColor3 = Color3.new(1, 1, 1)
    decBtn.Font = Enum.Font.SourceSansBold
    decBtn.TextSize = 18
    decBtn.Parent = frame

    -- 加速按钮
    local incBtn = Instance.new("TextButton")
    incBtn.Size = UDim2.new(0, 40, 0, 30)
    incBtn.Position = UDim2.new(0, 120, 0, 40 + 2 * (btnSize + gap) + 35)
    incBtn.Text = "+"
    incBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    incBtn.TextColor3 = Color3.new(1, 1, 1)
    incBtn.Font = Enum.Font.SourceSansBold
    incBtn.TextSize = 18
    incBtn.Parent = frame

    -- 关闭按钮
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 30)
    closeBtn.Position = UDim2.new(0, 10, 0, 40 + 2 * (btnSize + gap) + 70)
    closeBtn.Text = "关闭飞行"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 14
    closeBtn.Parent = frame

    -- 绑定方向按钮按下/松开事件
    local function bindButton(btn, flag)
        btn.MouseButton1Down:Connect(function()
            if flag == "up" then flyUpPressed = true
            elseif flag == "down" then flyDownPressed = true
            elseif flag == "left" then flyLeftPressed = true
            elseif flag == "right" then flyRightPressed = true
            end
        end)
        btn.MouseButton1Up:Connect(function()
            if flag == "up" then flyUpPressed = false
            elseif flag == "down" then flyDownPressed = false
            elseif flag == "left" then flyLeftPressed = false
            elseif flag == "right" then flyRightPressed = false
            end
        end)
        btn.MouseLeave:Connect(function()
            if flag == "up" then flyUpPressed = false
            elseif flag == "down" then flyDownPressed = false
            elseif flag == "left" then flyLeftPressed = false
            elseif flag == "right" then flyRightPressed = false
            end
        end)
    end

    bindButton(upBtn, "up")
    bindButton(downBtn, "down")
    bindButton(leftBtn, "left")
    bindButton(rightBtn, "right")

    -- 速度调节
    local function setFlySpeed(v)
        FlySpeed = math.clamp(v, 10, 200)
        speedLabel.Text = "速度: " .. FlySpeed
    end
    decBtn.MouseButton1Click:Connect(function() setFlySpeed(FlySpeed - 10) end)
    incBtn.MouseButton1Click:Connect(function() setFlySpeed(FlySpeed + 10) end)
    closeBtn.MouseButton1Click:Connect(function() StopFly() end)

    FlyGui = gui
    return gui
end

function StartFly()
    if Flying then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    Flying = true
    CreateFlyGui()
    FlyGui.Enabled = true

    -- 创建飞行物理
    local gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(1, 1, 1) * 400000
    gyro.P = 10000
    gyro.D = 100
    gyro.CFrame = root.CFrame
    gyro.Parent = root
    FlyBodyGyro = gyro

    local vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(1, 1, 1) * 400000
    vel.Velocity = Vector3.zero
    vel.Parent = root
    FlyBodyVelocity = vel

    hum.PlatformStand = true
end

function StopFly()
    if not Flying then return end
    Flying = false
    if FlyGui then FlyGui.Enabled = false end
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
    flyUpPressed, flyDownPressed, flyLeftPressed, flyRightPressed = false, false, false, false
end

-- 飞行移动处理
RunService.RenderStepped:Connect(function()
    if not Flying or not FlyBodyVelocity or not FlyBodyGyro then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local move = Vector3.zero
    local cam = Camera.CFrame
    local forward = cam.LookVector
    local right = cam.RightVector

    if flyUpPressed then move += forward end
    if flyDownPressed then move -= forward end
    if flyLeftPressed then move -= right end
    if flyRightPressed then move += right end

    FlyBodyVelocity.Velocity = move * FlySpeed
    FlyBodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + cam.LookVector)
end)
-- ==================== 透视功能 ====================
local function ClearESP()
    for _, hl in pairs(ESP_Highlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    for _, bb in pairs(ESP_Billboards) do
        if bb and bb.Parent then bb:Destroy() end
    end
    ESP_Highlights = {}
    ESP_Billboards = {}
end

local function UpdateESP()
    ClearESP()
    if not (ESP_Players or ESP_NPCs) then return end

    local function processModel(model, isPlayer)
        if model == LocalPlayer.Character then return end
        local hum = model:FindFirstChildOfClass("Humanoid")
        local hrp = model:FindFirstChild("HumanoidRootPart")
        local head = model:FindFirstChild("Head")
        if hum and hrp then
            -- 添加高亮
            local hl = Instance.new("Highlight")
            hl.FillColor = isPlayer and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Parent = model
            table.insert(ESP_Highlights, hl)

            -- 添加信息显示
            if ESP_ShowName or ESP_ShowDistance or ESP_ShowHealth then
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 200, 0, 60)
                bill.StudsOffset = Vector3.new(0, 2.5, 0)
                bill.AlwaysOnTop = true
                bill.Parent = head or hrp
                table.insert(ESP_Billboards, bill)

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.new(1, 1, 1)
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 14
                label.Parent = bill

                local function updateText()
                    local parts = {}
                    if ESP_ShowName then
                        table.insert(parts, model.Name)
                    end
                    if ESP_ShowDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        table.insert(parts, string.format("距离: %.1f", dist))
                    end
                    if ESP_ShowHealth then
                        table.insert(parts, "血量: " .. math.floor(hum.Health))
                    end
                    label.Text = table.concat(parts, "\n")
                end
                updateText()
                RunService.Heartbeat:Connect(function()
                    if bill.Parent then updateText() end
                end)
            end
        end
    end

    -- 玩家
    if ESP_Players then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                processModel(player.Character, true)
            end
        end
    end

    -- NPC
    if ESP_NPCs then
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
                local isPlayerChar = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character == model then isPlayerChar = true break end
                end
                if not isPlayerChar and model ~= LocalPlayer.Character then
                    processModel(model, false)
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESP_Players then UpdateESP() end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    if ESP_Players or ESP_NPCs then UpdateESP() end
end)
-- ==================== 自瞄功能 ====================
local AimEnabled = false
local AimFOV = 100
local AimSmoothness = 8
local AimVisibleOnly = true

-- 自瞄圈 UI
local AimGui = Instance.new("ScreenGui")
AimGui.Parent = game.CoreGui
AimGui.IgnoreGuiInset = true

local AimCircle = Instance.new("Frame")
AimCircle.Size = UDim2.new(0, AimFOV * 2, 0, AimFOV * 2)
AimCircle.AnchorPoint = Vector2.new(0.5, 0.5)
AimCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
AimCircle.BackgroundTransparency = 1
AimCircle.BorderSizePixel = 0
AimCircle.Visible = false
Instance.new("UICorner", AimCircle).CornerRadius = UDim.new(1, 0)

local AimStroke = Instance.new("UIStroke")
AimStroke.Thickness = 1.5
AimStroke.Color = Color3.fromRGB(255, 0, 0)
AimStroke.Parent = AimCircle
AimCircle.Parent = AimGui

local function GetNearestTarget()
    local bestTarget = nil
    local bestDist = AimFOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist <= AimFOV then
                            local visible = true
                            if AimVisibleOnly then
                                local rayOrigin = Camera.CFrame.Position
                                local rayDir = (hrp.Position - rayOrigin).Unit * 500
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                                local rayResult = workspace:Raycast(rayOrigin, rayDir, rayParams)
                                if rayResult and rayResult.Instance and not rayResult.Instance:IsDescendantOf(char) then
                                    visible = false
                                end
                            end
                            if visible and dist < bestDist then
                                bestDist = dist
                                bestTarget = hrp
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

RunService.RenderStepped:Connect(function(deltaTime)
    if not AimEnabled then
        AimCircle.Visible = false
        return
    end

    AimCircle.Visible = true
    AimCircle.Size = UDim2.new(0, AimFOV * 2, 0, AimFOV * 2)

    local target = GetNearestTarget()
    if target then
        local desiredCF = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        local alpha = math.clamp(1 / AimSmoothness, 0.01, 1)
        Camera.CFrame = Camera.CFrame:Lerp(desiredCF, alpha * deltaTime * 60)
    end
end)
-- ==================== 创建主窗口 ====================
local Window = WindUI:CreateWindow({
    Title = "红星中心",
    Icon = "solar:star-bold-duotone",
    NewElements = true,
    HideSearchBar = true,
    Size = UDim2.fromOffset(680, 620),
    OpenButton = {
        Title = "打开红星中心",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.75,
        Color = ColorSequence.new(
            Color3.fromHex("#FF4B4B"),
            Color3.fromHex("#FF9F43")
        ),
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

-- ==================== 主页标签页 ====================
local MainTab = Window:Tab({
    Title = "主页",
    Desc = "红星中心公告",
    Icon = "solar:home-2-bold",
    IconColor = Color3.fromHex("#FF5E5E"),
    IconShape = "Square",
    Border = true,
})

local NoticeSection = MainTab:Section({
    Title = "📢 公告",
})

NoticeSection:Section({
    Title = "欢迎使用红星中心 喜欢的话可以加群 1106456119",
    TextSize = 16,
    TextTransparency = 0.2,
    FontWeight = Enum.FontWeight.Medium,
})

NoticeSection:Space()

NoticeSection:Button({
    Title = "点击复制群号",
    Icon = "solar:copy-bold",
    Color = Color3.fromHex("#FF5E5E"),
    Justify = "Center",
    Callback = function()
        setclipboard("1106456119")
        pcall(function()
            WindUI:Notify({
                Title = "复制成功",
                Content = "群号 1106456119 已复制到剪贴板",
                Icon = "check-circle",
                Duration = 3,
            })
        end)
    end,
})

NoticeSection:Button({
    Title = "复制完整公告",
    Icon = "solar:document-text-bold",
    Color = Color3.fromHex("#4A90E2"),
    Justify = "Center",
    Callback = function()
        setclipboard("欢迎使用红星中心 喜欢的话可以加群 1106456119")
        pcall(function()
            WindUI:Notify({
                Title = "复制成功",
                Content = "公告内容已复制",
                Icon = "check-circle",
                Duration = 3,
            })
        end)
    end,
})

-- ==================== 通用标签页 ====================
local GeneralTab = Window:Tab({
    Title = "通用",
    Desc = "通用功能",
    Icon = "solar:settings-bold",
    IconColor = Color3.fromHex("#257AF7"),
    IconShape = "Square",
    Border = true,
})

local GeneralSection = GeneralTab:Section({
    Title = "通用功能",
})

GeneralSection:Toggle({
    Title = "启用速度修改",
    Default = false,
    Callback = function(value)
        SetSpeedEnabled(value)
    end,
})

GeneralSection:Slider({
    Title = "移动速度",
    Min = 16,
    Max = 400,
    Default = 16,
    Callback = function(value)
        SetSpeedValue(value)
    end,
})

GeneralSection:Toggle({
    Title = "启用跳跃修改",
    Default = false,
    Callback = function(value)
        SetJumpEnabled(value)
    end,
})

GeneralSection:Slider({
    Title = "跳跃高度",
    Min = 50,
    Max = 600,
    Default = 50,
    Callback = function(value)
        SetJumpValue(value)
    end,
})

GeneralSection:Toggle({
    Title = "无限跳跃",
    Default = false,
    Callback = function(value)
        InfiniteJumpEnabled = value
    end,
})

GeneralSection:Button({
    Title = "切换飞行",
    Icon = "solar:rocket-bold",
    Color = Color3.fromHex("#9B59B6"),
    Justify = "Center",
    Callback = function()
        if not Flying then
            StartFly()
        else
            StopFly()
        end
    end,
})

-- ==================== 自瞄标签页 ====================
local AimTab = Window:Tab({
    Title = "自瞄",
    Desc = "自瞄功能",
    Icon = "solar:target-bold",
    IconColor = Color3.fromHex("#EF4F1D"),
    IconShape = "Square",
    Border = true,
})

local AimSection = AimTab:Section({
    Title = "自瞄设置",
})

AimSection:Toggle({
    Title = "启用自瞄",
    Default = false,
    Callback = function(value)
        AimEnabled = value
        if not value then
            AimCircle.Visible = false
        end
    end,
})

AimSection:Slider({
    Title = "自瞄圈大小",
    Min = 50,
    Max = 300,
    Default = 100,
    Callback = function(value)
        AimFOV = value
    end,
})

AimSection:Slider({
    Title = "平滑度",
    Min = 1,
    Max = 20,
    Default = 8,
    Callback = function(value)
        AimSmoothness = value
    end,
})

AimSection:Toggle({
    Title = "出掩体才锁定",
    Default = true,
    Callback = function(value)
        AimVisibleOnly = value
    end,
})

-- ==================== 透视标签页 ====================
local EspTab = Window:Tab({
    Title = "透视",
    Desc = "透视功能",
    Icon = "solar:eye-bold",
    IconColor = Color3.fromHex("#10C550"),
    IconShape = "Square",
    Border = true,
})

local EspSection = EspTab:Section({
    Title = "透视设置",
})

EspSection:Toggle({
    Title = "透视真人",
    Default = false,
    Callback = function(value)
        ESP_Players = value
        UpdateESP()
    end,
})

EspSection:Toggle({
    Title = "透视NPC",
    Default = false,
    Callback = function(value)
        ESP_NPCs = value
        UpdateESP()
    end,
})

EspSection:Toggle({
    Title = "显示名字",
    Default = false,
    Callback = function(value)
        ESP_ShowName = value
        UpdateESP()
    end,
})

EspSection:Toggle({
    Title = "显示距离",
    Default = false,
    Callback = function(value)
        ESP_ShowDistance = value
        UpdateESP()
    end,
})

EspSection:Toggle({
    Title = "显示血量",
    Default = false,
    Callback = function(value)
        ESP_ShowHealth = value
        UpdateESP()
    end,
})