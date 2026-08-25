--[[ by 红星 Script ]]
local FILE_NAME = "saveV1.2.txt"
local BALL_COUNT = 14
local alreadyRead = false
if isfile and isfile(FILE_NAME) then alreadyRead = true end
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local function CreateBall(parent)
    local ball = Instance.new("Frame")
    local size = math.random(40,90)
    ball.Size = UDim2.new(0,size,0,size)
    ball.Position = UDim2.new(math.random(-20,120)/100,0,math.random(-20,120)/100,0)
    ball.BackgroundColor3 = Color3.fromRGB(255,255,255)
    ball.BackgroundTransparency = 0.85
    ball.ZIndex = 0
    ball.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1,0)
    corner.Parent = ball
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHSV(math.random(),0.6,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(math.random(),0.6,1))})
    gradient.Rotation = math.random(0,360)
    gradient.Parent = ball
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Transparency = 0.6
    stroke.Color = Color3.fromHSV(math.random(),1,1)
    stroke.Parent = ball
    return ball
end

local function AnimateBall(ball)
    task.spawn(function()
        while ball.Parent do
            local newPos = UDim2.new(math.random(-10,110)/100,math.random(-60,60),math.random(-10,110)/100,math.random(-60,60))
            local tween = TweenService:Create(ball,TweenInfo.new(math.random(4,8),Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position = newPos})
            tween:Play()
            tween.Completed:Wait()
        end
    end)
    task.spawn(function()
        while ball.Parent do
            TweenService:Create(ball,TweenInfo.new(2),{BackgroundTransparency=0.75}):Play()
            task.wait(2)
            TweenService:Create(ball,TweenInfo.new(2),{BackgroundTransparency=0.9}):Play()
            task.wait(2)
        end
    end)
end

local function StartBalls(parent)
    for i=1,BALL_COUNT do local ball=CreateBall(parent) AnimateBall(ball) end
end

local clicked = false
if not alreadyRead then
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    TweenService:Create(blur,TweenInfo.new(0.25),{Size=18}):Play()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NoticeUI"
    ScreenGui.Parent = CoreGui
    StartBalls(ScreenGui)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0,280,0,150)
    Frame.AnchorPoint = Vector2.new(0.5,0.5)
    Frame.Position = UDim2.new(0.5,0,0.45,0)
    Frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 10
    Frame.Parent = ScreenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,14)
    corner.Parent = Frame
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Parent = Frame
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1,-40,0,80)
    TextLabel.Position = UDim2.new(0,20,0,20)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.fromRGB(235,235,235)
    TextLabel.TextWrapped = true
    TextLabel.TextSize = 17
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextYAlignment = Enum.TextYAlignment.Top
    TextLabel.TextTransparency = 1
    TextLabel.ZIndex = 11
    TextLabel.Text = "公告\n\n已更新动作功能，目前作者随缘更新"
    TextLabel.Parent = Frame
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0,110,0,36)
    Button.Position = UDim2.new(0.5,-55,1,-50)
    Button.Text = "好"
    Button.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.Font = Enum.Font.GothamMedium
    Button.TextScaled = true
    Button.BackgroundTransparency = 1
    Button.ZIndex = 11
    Button.Parent = Frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,10)
    btnCorner.Parent = Button
    TweenService:Create(Frame,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,320,0,180),BackgroundTransparency=0.15}):Play()
    TweenService:Create(TextLabel,TweenInfo.new(0.3),{TextTransparency=0}):Play()
    TweenService:Create(Button,TweenInfo.new(0.3),{BackgroundTransparency=0}):Play()
    Button.MouseEnter:Connect(function() TweenService:Create(Button,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(55,55,55)}):Play() end)
    Button.MouseLeave:Connect(function() TweenService:Create(Button,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(35,35,35)}):Play() end)
    Button.MouseButton1Click:Connect(function()
        clicked=true
        if writefile then writefile(FILE_NAME,"read") end
        TweenService:Create(Frame,TweenInfo.new(0.2),{BackgroundTransparency=1,Size=UDim2.new(0,280,0,150)}):Play()
        TweenService:Create(blur,TweenInfo.new(0.2),{Size=0}):Play()
        task.wait(0.2)
        ScreenGui:Destroy()
        blur:Destroy()
    end)
    repeat task.wait() until clicked
end
print("公告已确认，继续执行")
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local function Notify(title,content,duration,icon)
    pcall(function() WindUI:Notify({Title=tostring(title or "提示"),Content=tostring(content or ""),Duration=duration or 3,Icon=icon or "info"}) end)
endlocal TP_Module={}
local TP_Loaded=false
function EnableTPUI()
    if TP_Loaded then if TP_Module.Gui then TP_Module.Gui.Enabled=true end return end
    TP_Loaded=true
    local Players=game:GetService("Players")
    local UIS=game:GetService("UserInputService")
    local RunService=game:GetService("RunService")
    local Workspace=game:GetService("Workspace")
    local LP=Players.LocalPlayer
    local Camera=Workspace.CurrentCamera
    local Mode=false
    local Root,Hum
    local OldCF,OldType
    local FixedY=0
    local MoveInput=Vector2.zero
    local TouchMove,TouchStart
    local Speed=3
    local HeightSpeed=4
    local Gui=Instance.new("ScreenGui")
    Gui.Parent=game.CoreGui
    Gui.IgnoreGuiInset=true
    Gui.Enabled=true
    TP_Module.Gui=Gui
    local Btn=Instance.new("TextButton",Gui)
    Btn.Size=UDim2.new(0,80,0,40)
    Btn.Position=UDim2.new(1,-90,0.35,0)
    Btn.Text="瞬移"
    Btn.BackgroundColor3=Color3.fromRGB(40,40,40)
    Btn.TextColor3=Color3.new(1,1,1)
    local Cross=Instance.new("Frame",Gui)
    Cross.Size=UDim2.new(0,8,0,8)
    Cross.AnchorPoint=Vector2.new(0.5,0.5)
    Cross.Position=UDim2.new(0.5,0,0.5,0)
    Cross.BackgroundColor3=Color3.fromRGB(255,0,0)
    Cross.Visible=false
    Instance.new("UICorner",Cross).CornerRadius=UDim.new(1,0)
    local UpBtn=Instance.new("TextButton",Gui)
    UpBtn.Size=UDim2.new(0,60,0,60)
    UpBtn.Position=UDim2.new(1,-80,0.7,-70)
    UpBtn.Text="↑"
    UpBtn.BackgroundColor3=Color3.fromRGB(60,60,60)
    UpBtn.Visible=false
    local DownBtn=Instance.new("TextButton",Gui)
    DownBtn.Size=UDim2.new(0,60,0,60)
    DownBtn.Position=UDim2.new(1,-80,0.7,10)
    DownBtn.Text="↓"
    DownBtn.BackgroundColor3=Color3.fromRGB(60,60,60)
    DownBtn.Visible=false
    local function LockChar()
        local char=LP.Character if not char then return end
        Root=char:FindFirstChild("HumanoidRootPart")
        Hum=char:FindFirstChildOfClass("Humanoid")
        if Root then Root.Anchored=true end
        if Hum then Hum.AutoRotate=false Hum.PlatformStand=true end
    end
    local function UnlockChar()
        if Root then Root.Anchored=false end
        if Hum then Hum.AutoRotate=true Hum.PlatformStand=false end
    end
    local function Enter()
        local char=LP.Character
        local root=char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        OldCF=Camera.CFrame
        OldType=Camera.CameraType
        Camera.CameraType=Enum.CameraType.Scriptable
        FixedY=root.Position.Y+150
        Camera.CFrame=CFrame.new(root.Position+Vector3.new(0,150,0))*CFrame.Angles(math.rad(-90),0,0)
        LockChar()
        Cross.Visible=true
        UpBtn.Visible=true
        DownBtn.Visible=true
    end
    local function Exit()
        local char=LP.Character
        if char then Root=char:FindFirstChild("HumanoidRootPart") Hum=char:FindFirstChildOfClass("Humanoid") end
        UnlockChar()
        if Hum then pcall(function()
            Hum.PlatformStand=false Hum.AutoRotate=true
            Hum:ChangeState(Enum.HumanoidStateType.GettingUp) Hum:ChangeState(Enum.HumanoidStateType.Running)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,true) Hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
            if CustomJumpEnabled then Hum.UseJumpPower=true Hum.JumpPower=CustomJumpValue Hum.JumpHeight=CustomJumpValue*(7.2/50) end
        end) end
        if Root and Root.Parent then Root.Anchored=false end
        Camera.CameraType=OldType or Enum.CameraType.Custom
        if OldCF then Camera.CFrame=OldCF end
        Cross.Visible=false UpBtn.Visible=false DownBtn.Visible=false
    end
    RunService.RenderStepped:Connect(function()
        if not Mode then return end
        local move=Vector3.new(MoveInput.X,0,MoveInput.Y)*Speed
        local pos=Camera.CFrame.Position+move
        Camera.CFrame=CFrame.new(Vector3.new(pos.X,FixedY,pos.Z))*CFrame.Angles(math.rad(-90),0,0)
    end)
    local UpHolding=false local DownHolding=false
    UpBtn.MouseButton1Down:Connect(function() UpHolding=true end)
    UpBtn.MouseButton1Up:Connect(function() UpHolding=false end)
    DownBtn.MouseButton1Down:Connect(function() DownHolding=true end)
    DownBtn.MouseButton1Up:Connect(function() DownHolding=false end)
    RunService.RenderStepped:Connect(function()
        if not Mode then return end
        if UpHolding then FixedY=FixedY+HeightSpeed end
        if DownHolding then FixedY=FixedY-HeightSpeed end
    end)
    UIS.TouchStarted:Connect(function(t)
        if not Mode then return end
        if t.Position.X<Camera.ViewportSize.X/2 then TouchMove=t TouchStart=t.Position end
    end)
    UIS.TouchMoved:Connect(function(t)
        if t~=TouchMove then return end
        local delta=t.Position-TouchStart
        MoveInput=Vector2.new(math.clamp(delta.X/50,-1,1),math.clamp(delta.Y/50,-1,1))
    end)
    UIS.TouchEnded:Connect(function(t) if t==TouchMove then TouchMove=nil MoveInput=Vector2.zero end end)
    local function GetCenterRay()
        local absPos=Cross.AbsolutePosition local absSize=Cross.AbsoluteSize
        local x=absPos.X+absSize.X/2 local y=absPos.Y+absSize.Y/2
        local ray=Camera:ViewportPointToRay(x,y)
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances={LP.Character}
        local result=Workspace:Raycast(ray.Origin,Vector3.new(0,-5000,0),params)
        return result and result.Position or ray.Origin
    end
    local function TP()
        if not Root then return end
        local pos=GetCenterRay()
        Root.Anchored=false
        Root.CFrame=CFrame.new(pos+Vector3.new(0,3,0))
    end
    Btn.MouseButton1Click:Connect(function()
        if not Mode then Mode=true Btn.Text="确认地点" Btn.BackgroundColor3=Color3.fromRGB(200,0,0) Enter()
        else Mode=false Btn.Text="瞬移" Btn.BackgroundColor3=Color3.fromRGB(40,40,40) TP() Exit() end
    end)
end
function DisableTPUI()
    if TP_Module.Gui then TP_Module.Gui.Enabled=false end
endWindUI:AddTheme({
    Name = "Red",
    Background = Color3.fromRGB(30,10,10),
    ElementBackground = Color3.fromRGB(70,20,20),
    Button = Color3.fromRGB(200,40,40),
    Hover = Color3.fromRGB(255,100,100),
    Text = Color3.fromRGB(255,220,220),
    Placeholder = Color3.fromRGB(180,100,100),
    Icon = Color3.fromRGB(255,80,80),
    Outline = Color3.fromRGB(100,40,40),
    Accent = WindUI:Gradient({["0"]={Color=Color3.fromRGB(255,50,50),Transparency=0.5},["100"]={Color=Color3.fromRGB(150,20,20),Transparency=0.5}}),
    WindowBackground = Color3.fromRGB(30,10,10),
    TabTitle = Color3.fromRGB(255,220,220),
    TabIcon = Color3.fromRGB(255,80,80),
    ElementTitle = Color3.fromRGB(255,220,220),
    ElementDesc = Color3.fromRGB(200,150,150),
    Toggle = Color3.fromRGB(150,40,40),
    ToggleBar = Color3.fromRGB(255,255,255),
    Slider = Color3.fromRGB(150,40,40),
    SliderThumb = Color3.fromRGB(255,255,255),
    Checkbox = Color3.fromRGB(150,40,40),
    CheckboxIcon = Color3.fromRGB(255,255,255),
})
local ThemeFile="NightTheme.txt"
local CurrentTheme="Red"
pcall(function() if isfile and isfile(ThemeFile) then local saved=readfile(ThemeFile) if saved~="" then CurrentTheme=saved end end end)

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local screenGui=Instance.new("ScreenGui")
screenGui.Name="FOVCircle_UI"
screenGui.IgnoreGuiInset=true
screenGui.ResetOnSpawn=false
screenGui.Parent=game.CoreGui
local circle=Instance.new("Frame")
circle.Name="FOVCircle"
circle.AnchorPoint=Vector2.new(0.5,0.5)
circle.Position=UDim2.new(0.5,0,0.5,0)
circle.Size=UDim2.new(0,240,0,240)
circle.BackgroundTransparency=1
circle.Parent=screenGui
circle.Visible=false
local stroke=Instance.new("UIStroke")
stroke.Thickness=2
stroke.Color=Color3.fromRGB(255,0,0)
stroke.Parent=circle
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(1,0)
corner.Parent=circle

local AdminDetectEnabled=true
local flaggedAdmins={}
local function CheckAdmin(p)
    if not AdminDetectEnabled then return end
    if flaggedAdmins[p] then return end
    if not p or not p.Parent then return end
    local suspicious=false local reason=""
    pcall(function()
        for _,g in ipairs(p:GetGroups()) do if g.Rank>=200 then suspicious=true reason="高Rank玩家" end end
    end)
    if suspicious then flaggedAdmins[p]=true Notify("⚠️ 管理员警告",p.Name.." - "..reason,5) end
end
Players.PlayerAdded:Connect(function(p) task.wait(1) CheckAdmin(p) end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(function() CheckAdmin(p) end) end
task.spawn(function() while true do if AdminDetectEnabled then for _,p in ipairs(Players:GetPlayers()) do CheckAdmin(p) end end task.wait(2) end end)
Players.PlayerRemoving:Connect(function(p) flaggedAdmins[p]=nil end)local ThirdPersonUnlock={Enabled=false,Connection=nil}
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local RunService=game:GetService("RunService")
local function ApplyUnlock()
    pcall(function()
        if LocalPlayer.CameraMode~=Enum.CameraMode.Classic then LocalPlayer.CameraMode=Enum.CameraMode.Classic end
        LocalPlayer.CameraMinZoomDistance=0.5
        LocalPlayer.CameraMaxZoomDistance=50
    end)
end
local function EnableUnlock()
    if ThirdPersonUnlock.Connection then return end
    ThirdPersonUnlock.Enabled=true
    ApplyUnlock()
    ThirdPersonUnlock.Connection=RunService.RenderStepped:Connect(function()
        if not ThirdPersonUnlock.Enabled then return end
        ApplyUnlock()
    end)
end
local function DisableUnlock()
    ThirdPersonUnlock.Enabled=false
    if ThirdPersonUnlock.Connection then ThirdPersonUnlock.Connection:Disconnect() ThirdPersonUnlock.Connection=nil end
end
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5) if ThirdPersonUnlock.Enabled then ApplyUnlock() end end)

local FeatureDisplayEnabled=true
local EnabledFeatures={}
local FeatureItems={}
local FeatureGui=Instance.new("ScreenGui")
FeatureGui.Name="FeatureDisplay"
FeatureGui.Parent=game.CoreGui
local Container=Instance.new("Frame")
Container.AnchorPoint=Vector2.new(1,0)
Container.Position=UDim2.new(1,-10,0,10)
Container.Size=UDim2.new(0,200,0,300)
Container.BackgroundTransparency=1
Container.Parent=FeatureGui
local UIList=Instance.new("UIListLayout")
UIList.Padding=UDim.new(0,4)
UIList.HorizontalAlignment=Enum.HorizontalAlignment.Right
UIList.Parent=Container
local TextService=game:GetService("TextService")
local TweenService=game:GetService("TweenService")
local function Rainbow() return Color3.fromHSV((tick()*0.25)%1,1,1) end
local function RefreshFeatureUI()
    Container.Visible=FeatureDisplayEnabled
    if not FeatureDisplayEnabled then return end
    for name,item in pairs(FeatureItems) do
        if not table.find(EnabledFeatures,name) then
            if item then
                TweenService:Create(item,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,item.Size.X.Offset,0,0),BackgroundTransparency=1}):Play()
                for _,v in pairs(item:GetChildren()) do if v:IsA("TextLabel") then TweenService:Create(v,TweenInfo.new(0.2),{TextTransparency=1,TextStrokeTransparency=1}):Play() end end
                task.delay(0.25,function() if item then item:Destroy() end end)
            end
            FeatureItems[name]=nil
        end
    end
    for _,name in ipairs(EnabledFeatures) do
        if FeatureItems[name] then continue end
        local textSize=TextService:GetTextSize(name,14,Enum.Font.SourceSansBold,Vector2.new(1000,20))
        local width=textSize.X+10
        local item=Instance.new("Frame")
        item.Size=UDim2.new(0,0,0,16)
        item.BackgroundTransparency=1
        item.BackgroundColor3=Color3.new(0,0,0)
        item.BorderSizePixel=0
        item.Parent=Container
        Instance.new("UICorner",item).CornerRadius=UDim.new(0,10)
        local label=Instance.new("TextLabel")
        label.Size=UDim2.new(1,-6,1,0)
        label.Position=UDim2.new(0,3,0,0)
        label.BackgroundTransparency=1
        label.Text=name
        label.Font=Enum.Font.SourceSansBold
        label.TextSize=14
        label.TextXAlignment=Enum.TextXAlignment.Center
        label.TextTransparency=1
        label.TextStrokeTransparency=1
        label.TextStrokeColor3=Color3.new(0,0,0)
        label.Parent=item
        task.spawn(function() while label.Parent do label.TextColor3=Rainbow() task.wait(0.05) end end)
        task.spawn(function()
            task.wait()
            TweenService:Create(item,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,width,0,20),BackgroundTransparency=0.5}):Play()
            task.wait(0.1)
            TweenService:Create(label,TweenInfo.new(0.3),{TextTransparency=0,TextStrokeTransparency=0.3}):Play()
        end)
        FeatureItems[name]=item
    end
end
local function AddFeature(name)
    if name=="红星中心" then
        for i,v in ipairs(EnabledFeatures) do if v=="红星中心" then table.remove(EnabledFeatures,i) break end end
        table.insert(EnabledFeatures,1,name)
    else
        if not table.find(EnabledFeatures,name) then table.insert(EnabledFeatures,name) end
    end
    RefreshFeatureUI()
end
local function RemoveFeature(name)
    for i,v in ipairs(EnabledFeatures) do if v==name then table.remove(EnabledFeatures,i) break end end
    RefreshFeatureUI()
endlocal HealthPosFile="NightHealthPos.txt"
local HealthDisplay={Enabled=true,Position="LeftTop",Label=nil}
pcall(function() if isfile and isfile(HealthPosFile) then local saved=readfile(HealthPosFile) if saved~="" then HealthDisplay.Position=saved end end end)
local HealthGui=Instance.new("ScreenGui")
HealthGui.Name="SelfHealthDisplay"
HealthGui.ResetOnSpawn=false
HealthGui.Parent=game.CoreGui
local function CreateHealthUI()
    if HealthDisplay.Label then HealthDisplay.Label:Destroy() end
    local label=Instance.new("TextLabel")
    label.Size=UDim2.new(0,140,0,20)
    label.BackgroundTransparency=1
    label.TextStrokeTransparency=0.5
    label.Font=Enum.Font.SourceSansBold
    label.TextSize=14
    label.Text="HP: -- / --"
    label.Parent=HealthGui
    HealthDisplay.Label=label
end
local function UpdatePosition()
    local label=HealthDisplay.Label
    if not label then return end
    if HealthDisplay.Position=="LeftTop" then label.Position=UDim2.new(0,10,0,10) label.TextXAlignment=Enum.TextXAlignment.Left
    elseif HealthDisplay.Position=="RightTop" then label.Position=UDim2.new(1,-150,0,10) label.TextXAlignment=Enum.TextXAlignment.Right
    elseif HealthDisplay.Position=="LeftBottom" then label.Position=UDim2.new(0,10,1,-30) label.TextXAlignment=Enum.TextXAlignment.Left
    elseif HealthDisplay.Position=="RightBottom" then label.Position=UDim2.new(1,-150,1,-30) label.TextXAlignment=Enum.TextXAlignment.Right end
end
CreateHealthUI() UpdatePosition()
task.spawn(function()
    while true do
        if HealthDisplay.Enabled then
            local label=HealthDisplay.Label
            if not label then task.wait(0.1) continue end
            local char=LocalPlayer.Character
            if char then
                local hum=char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local current=math.floor(hum.Health) local max=math.floor(hum.MaxHealth) if max<=0 then max=1 end
                    local percent=current/max
                    local color=percent>0.6 and Color3.fromRGB(0,255,0) or (percent>0.3 and Color3.fromRGB(255,170,0) or Color3.fromRGB(255,0,0))
                    label.TextColor3=color
                    label.Text="HP: "..current.." / "..max
                    label.Visible=true
                end
            end
        else
            if HealthDisplay.Label then HealthDisplay.Label.Visible=false end
        end
        task.wait(0)
    end
end)
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5) CreateHealthUI() UpdatePosition() end)

local ESP_SETTINGS={HighlightEnabled=false,TeamCheck=false,SmoothAim=false,DistanceCheck=false,WallCheck=false}
local AimbotTeamWhitelist={}
local AimbotTeamWhitelistEnabled=false
local PLAYER_ESP={Enabled=false,HighlightEnabled=false,BoxEnabled=false,TeamCheck=false,ShowName=false,ShowHealth=false,ShowDist=false}
local FOV=120 local Smoothness=0.18 local AimPart="Head" local ShowFOVCircle=true
local AimPartsList={"Head","HumanoidRootPart","UpperTorso","Torso"}
local MaxDistance=1000
local function GetAimPart(char)
    if not char then return nil end
    local part=char:FindFirstChild(AimPart)
    if not part then part=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") end
    return part
end
local AimbotConnection=nil
local LockTargetEnabled=false
local SelectedTarget=nil
local PlayerList={}

local SpinEnabled=false local SpinSpeed=5 local SpinConnection=nil local AnimationLockThread=nil
local function ApplyAnimationLock(char)
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate=false end
    if AnimationLockThread then task.cancel(AnimationLockThread) AnimationLockThread=nil end
    AnimationLockThread=task.spawn(function()
        local animate=char:WaitForChild("Animate",3)
        while SpinEnabled and animate and animate.Parent do animate.Disabled=true task.wait(0.2) end
    end)
end
local function RemoveAnimationLock(char)
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate=true end
    if AnimationLockThread then task.cancel(AnimationLockThread) AnimationLockThread=nil end
    local animate=char:FindFirstChild("Animate")
    if animate then animate.Disabled=false end
end
local function StartSpin()
    if SpinConnection then return end
    local plr=game.Players.LocalPlayer
    SpinConnection=game:GetService("RunService").RenderStepped:Connect(function(dt)
        if not SpinEnabled then return end
        local char=plr.Character
        if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(SpinSpeed)*dt*60,0)
    end)
    ApplyAnimationLock(plr.Character)
end
local function StopSpin()
    SpinEnabled=false
    if SpinConnection then SpinConnection:Disconnect() SpinConnection=nil end
    RemoveAnimationLock(game.Players.LocalPlayer.Character)
end
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    if SpinEnabled then task.wait(0.5) ApplyAnimationLock(char) if not SpinConnection then StartSpin() end end
end)local function TeleportToPlayer(target)
    if not target then return end
    local char=LocalPlayer.Character local tChar=target.Character
    if not char or not tChar then return end
    local root=char:FindFirstChild("HumanoidRootPart") local tRoot=tChar:FindFirstChild("HumanoidRootPart")
    if root and tRoot then root.CFrame=tRoot.CFrame*CFrame.new(0,4,0) end
end
local Spectating=false
local function SpectatePlayer(target)
    if not target then return end
    local cam=workspace.CurrentCamera if not cam then return end
    local char=target.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
    cam.CameraSubject=hum cam.CameraType=Enum.CameraType.Custom Spectating=true
end
local function StopSpectate()
    local cam=workspace.CurrentCamera if not cam then return end
    local char=LocalPlayer.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then cam.CameraSubject=hum end
    Spectating=false
end

local FlingLoop=false local Flinging=false local AlreadyNotified={}
local function SkidFling(TargetPlayer)
    if not TargetPlayer or TargetPlayer==LocalPlayer then return end
    if Flinging then return end
    Flinging=true
    local Player=LocalPlayer
    local Character=Player.Character
    local Humanoid=Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart=Humanoid and Humanoid.RootPart
    local TCharacter=TargetPlayer.Character
    if not (Character and Humanoid and RootPart and TCharacter) then Flinging=false return end
    local THumanoid=TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart=THumanoid and THumanoid.RootPart
    local THead=TCharacter:FindFirstChild("Head")
    local Accessory=TCharacter:FindFirstChildOfClass("Accessory")
    local Handle=Accessory and Accessory:FindFirstChild("Handle")
    local Camera=workspace.CurrentCamera
    local Dead=false
    local DeadConn
    DeadConn=Player.CharacterAdded:Connect(function() Dead=true if DeadConn then DeadConn:Disconnect() DeadConn=nil end end)
    if RootPart.Velocity.Magnitude<50 then getgenv().OldPos=RootPart.CFrame end
    if Camera then
        if THead then Camera.CameraSubject=THead
        elseif Handle then Camera.CameraSubject=Handle
        elseif THumanoid then Camera.CameraSubject=THumanoid end
    end
    local function FPos(BasePart,Pos,Ang)
        if Dead then return end
        if not BasePart or not BasePart.Parent then return end
        if not RootPart or not RootPart.Parent then return end
        RootPart.CFrame=CFrame.new(BasePart.Position)*Pos*Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position)*Pos*Ang)
        RootPart.Velocity=Vector3.new(9e7,9e7*10,9e7)
        RootPart.RotVelocity=Vector3.new(9e8,9e8,9e8)
    end
    local function SFBasePart(BasePart)
        local TimeToWait=2 local Time=tick() local Angle=0
        repeat
            if Dead then break end
            if not BasePart or not BasePart.Parent then break end
            if not RootPart or not RootPart.Parent then break end
            if not TRootPart or not TRootPart.Parent then break end
            if not THumanoid or THumanoid.Health<=0 then break end
            if BasePart.Velocity.Magnitude>1 then
                Angle=Angle+100
                FPos(BasePart,CFrame.new(0,1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)) task.wait()
                FPos(BasePart,CFrame.new(2.25,1.5,-2.25)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)) task.wait()
                FPos(BasePart,CFrame.new(-2.25,-1.5,2.25)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,1.5,0)+THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle),0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0)+THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle),0,0)) task.wait()
            else
                FPos(BasePart,CFrame.new(0,1.5,THumanoid.WalkSpeed),CFrame.Angles(math.rad(90),0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,-THumanoid.WalkSpeed),CFrame.Angles(0,0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,1.5,THumanoid.WalkSpeed),CFrame.Angles(math.rad(90),0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,1.5,TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,-TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(0,0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,1.5,TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(90),0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(-90),0,0)) task.wait()
                FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0)) task.wait()
            end
        until BasePart.Velocity.Magnitude>500 or not BasePart.Parent or Dead or tick()>Time+TimeToWait
    end
    local BV=Instance.new("BodyVelocity")
    BV.Parent=RootPart
    BV.Velocity=Vector3.new(9e8,9e8,9e8)
    BV.MaxForce=Vector3.new(1/0,1/0,1/0)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    if not Dead then
        if TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead)
        elseif Handle then SFBasePart(Handle) end
    end
    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
    if Camera then
        local newChar=Player.Character
        local newHum=newChar and newChar:FindFirstChildOfClass("Humanoid")
        if newHum then Camera.CameraSubject=newHum end
    end
    if not Dead and getgenv().OldPos then
        local newChar=Player.Character
        local newRoot=newChar and newChar:FindFirstChild("HumanoidRootPart")
        local newHum=newChar and newChar:FindFirstChildOfClass("Humanoid")
        if newRoot and newHum then
            repeat
                newRoot.CFrame=getgenv().OldPos*CFrame.new(0,.5,0)
                newChar:SetPrimaryPartCFrame(getgenv().OldPos*CFrame.new(0,.5,0))
                newHum:ChangeState("GettingUp")
                for _,x in ipairs(newChar:GetChildren()) do if x:IsA("BasePart") then x.Velocity=Vector3.zero x.RotVelocity=Vector3.zero end end
                task.wait()
            until (newRoot.Position-getgenv().OldPos.Position).Magnitude<25
        end
    end
    if DeadConn then DeadConn:Disconnect() DeadConn=nil end
    Flinging=false
endlocal function MonitorTarget(target)
    if not target then return end
    if not (TP_Loop or FlingLoop or Flinging) then return end
    if not AlreadyNotified[target] then AlreadyNotified[target]={dead=false,left=false} end
    local state=AlreadyNotified[target]
    task.spawn(function()
        while true do
            if not (TP_Loop or FlingLoop or Flinging) then break end
            if not target or not target.Parent then
                if not state.left then state.left=true
                    local msg="玩家已退出，操作已终止"
                    if TP_Loop then msg="目标退出，无法继续传送"
                    elseif FlingLoop or Flinging then msg="目标退出，无法继续甩飞" end
                    Notify("目标失效",msg,3)
                end
                break
            end
            local char=target.Character
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum or hum.Health<=0 then
                if not state.dead then state.dead=true
                    local msg=target.Name.." 已死亡或消失"
                    if TP_Loop then msg=target.Name.." 已死亡或不存在，无法继续传送"
                    elseif FlingLoop or Flinging then msg=target.Name.." 已死亡或不存在，无法继续甩飞" end
                    Notify("目标失效",msg,3)
                end
                repeat
                    task.wait(0.5)
                    char=target.Character
                    hum=char and char:FindFirstChildOfClass("Humanoid")
                until hum and hum.Health>0 or not target.Parent
                if hum and hum.Health>0 then state.dead=false end
            end
            task.wait(0.5)
        end
    end)
end
local function StartFlingLoop()
    if FlingLoop then return end
    FlingLoop=true
    AlreadyNotified={}
    task.spawn(function()
        while FlingLoop do
            local selfChar=LocalPlayer.Character
            local selfHum=selfChar and selfChar:FindFirstChildOfClass("Humanoid")
            local selfRoot=selfChar and selfChar:FindFirstChild("HumanoidRootPart")
            if not selfChar or not selfHum or not selfRoot or selfHum.Health<=0 then task.wait(0.5) continue end
            if TP_SelectedPlayer=="ALL" then
                for _,p in ipairs(Players:GetPlayers()) do
                    if not FlingLoop then break end
                    local c=LocalPlayer.Character
                    local h=c and c:FindFirstChildOfClass("Humanoid")
                    if not c or not h or h.Health<=0 then break end
                    if p~=LocalPlayer then
                        local char=p.Character
                        local hum=char and char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health>0 then
                            if not AlreadyNotified[p] then MonitorTarget(p) end
                            local t1=tick() repeat task.wait() until not Flinging or tick()-t1>3
                            SkidFling(p)
                            local t2=tick() repeat task.wait() until not Flinging or tick()-t2>3
                            task.wait(0.1)
                        end
                    end
                end
            else
                local target=(TP_SelectedPlayer~="ALL") and (TP_SelectedPlayer or SelectedTarget) or nil
                if target then
                    if not AlreadyNotified[target] then MonitorTarget(target) end
                    local t1=tick() repeat task.wait() until not Flinging or tick()-t1>3
                    SkidFling(target)
                    local t2=tick() repeat task.wait() until not Flinging or tick()-t2>3
                end
            end
            task.wait(0.2)
        end
    end)
end
local function StopFlingLoop()
    FlingLoop=false
end

local AuraEnabled=false local AuraLoop=nil
local ATTACK_RANGE=60 local ATTACK_INTERVAL=0.15 local MAX_ATTACKS=3
local CachedRemotes=nil
local function GetTargets()
    local targets={}
    local lp=game.Players.LocalPlayer
    local char=lp.Character
    if not char then return targets end
    local myRoot=char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return targets end
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj~=char then
            local hum=obj:FindFirstChildOfClass("Humanoid")
            local root=obj:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health>0 then
                if game.Players:GetPlayerFromCharacter(obj) then continue end
                local dist=(root.Position-myRoot.Position).Magnitude
                if dist<=ATTACK_RANGE then table.insert(targets,obj) end
            end
        end
    end
    table.sort(targets,function(a,b) return (a.HumanoidRootPart.Position-myRoot.Position).Magnitude < (b.HumanoidRootPart.Position-myRoot.Position).Magnitude end)
    return targets
end
local function GetRemotes()
    if CachedRemotes then return CachedRemotes end
    CachedRemotes={}
    for _,v in pairs(game:GetDescendants()) do if v:IsA("RemoteEvent") then table.insert(CachedRemotes,v) end end
    return CachedRemotes
end
local function TryAttack(target)
    local remotes=GetRemotes()
    local head=target:FindFirstChild("Head")
    local root=target:FindFirstChild("HumanoidRootPart")
    for _,remote in pairs(remotes) do
        pcall(function()
            remote:FireServer(target)
            remote:FireServer(target, head and head.Position or root.Position)
            remote:FireServer("Hit",target)
            remote:FireServer("Attack",target)
            remote:FireServer("Damage",target)
        end)
    end
end
local function StartAura()
    if AuraLoop then return end
    AuraEnabled=true
    AuraLoop=task.spawn(function()
        while AuraEnabled do
            local targets=GetTargets()
            for i=1,math.min(MAX_ATTACKS,#targets) do TryAttack(targets[i]) end
            task.wait(ATTACK_INTERVAL)
        end
    end)
end
local function StopAura()
    AuraEnabled=false
    if AuraLoop then task.cancel(AuraLoop) AuraLoop=nil end
endlocal TargetWalkSpeed=16
local SpeedEnabled=false
local CustomJumpEnabled=false
local CustomJumpValue=50
local Connections={}
local Camera=workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Camera=workspace.CurrentCamera end)
local Lighting=game:GetService("Lighting")
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local LocalPlayer=Players.LocalPlayer
if not LocalPlayer then repeat task.wait() LocalPlayer=Players.LocalPlayer until LocalPlayer end
RunService.RenderStepped:Connect(function()
    if CustomJumpEnabled then
        local char=LocalPlayer.Character
        if char then
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower=true
                hum.JumpPower=CustomJumpValue
                hum.JumpHeight=CustomJumpValue*(7.2/50)
            end
        end
    end
end)
RunService.RenderStepped:Connect(function()
    if not SpeedEnabled then return end
    local char=LocalPlayer.Character
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.WalkSpeed~=TargetWalkSpeed then hum.WalkSpeed=TargetWalkSpeed end
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if not SpeedEnabled then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed=TargetWalkSpeed end
end)

local Freecam={Speed=2,Sensitivity=0.01,Enabled=false,Rig=nil,Loop=nil,Yaw=0,Pitch=0,MoveInput=Vector2.zero,Connections={},Touch={Move=nil,Look=nil,MoveStart=nil}}
local function InitFreecamInput()
    if Freecam._InputInited then return end
    Freecam._InputInited=true
    table.insert(Freecam.Connections,UserInputService.TouchStarted:Connect(function(t)
        if not Freecam.Enabled then return end
        local half=workspace.CurrentCamera.ViewportSize.X/2
        if t.Position.X<half then
            if not Freecam.Touch.Move then Freecam.Touch.Move=t Freecam.Touch.MoveStart=t.Position Freecam.MoveInput=Vector2.zero end
        else
            if not Freecam.Touch.Look then Freecam.Touch.Look=t end
        end
    end))
    table.insert(Freecam.Connections,UserInputService.TouchMoved:Connect(function(t)
        if not Freecam.Enabled then return end
        if t==Freecam.Touch.Move and Freecam.Touch.MoveStart then
            local delta=t.Position-Freecam.Touch.MoveStart
            Freecam.MoveInput=Vector2.new(math.clamp(delta.X/80,-1,1),math.clamp(-delta.Y/80,-1,1))
        elseif t==Freecam.Touch.Look then
            local d=t.Delta
            Freecam.Yaw=Freecam.Yaw-d.X*Freecam.Sensitivity
            Freecam.Pitch=math.clamp(Freecam.Pitch-d.Y*Freecam.Sensitivity,math.rad(-85),math.rad(85))
        end
    end))
    table.insert(Freecam.Connections,UserInputService.TouchEnded:Connect(function(t)
        if t==Freecam.Touch.Move then Freecam.Touch.Move=nil Freecam.Touch.MoveStart=nil Freecam.MoveInput=Vector2.zero end
        if t==Freecam.Touch.Look then Freecam.Touch.Look=nil end
    end))
end
local function StartFreecam()
    if Freecam.Enabled then return end
    Freecam.Enabled=true
    InitFreecamInput()
    local char=LocalPlayer.Character
    if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if not Freecam.Rig then
        Freecam.Rig=Instance.new("Part")
        Freecam.Rig.Anchored=true
        Freecam.Rig.CanCollide=false
        Freecam.Rig.Transparency=1
        Freecam.Rig.Size=Vector3.new(1,1,1)
        Freecam.Rig.Parent=workspace
    end
    Freecam.Rig.CFrame=workspace.CurrentCamera.CFrame
    root.Anchored=true
    hum.AutoRotate=false
    hum.PlatformStand=true
    workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
    local x,y=workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ()
    Freecam.Yaw=y
    Freecam.Pitch=x
    Freecam.Loop=RunService.RenderStepped:Connect(function()
        local root=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero end
        local rotCF=CFrame.Angles(0,Freecam.Yaw,0)*CFrame.Angles(Freecam.Pitch,0,0)
        local cf=CFrame.new(Freecam.Rig.Position)*rotCF
        local move=(cf.RightVector*Freecam.MoveInput.X)+(cf.LookVector*Freecam.MoveInput.Y)
        Freecam.Rig.CFrame=CFrame.new(Freecam.Rig.Position+move*Freecam.Speed)*rotCF
        workspace.CurrentCamera.CFrame=Freecam.Rig.CFrame
    end)
end
local function StopFreecam()
    if not Freecam.Enabled then return end
    Freecam.Enabled=false
    if Freecam.Loop then Freecam.Loop:Disconnect() Freecam.Loop=nil end
    for _,conn in pairs(Freecam.Connections) do pcall(function() conn:Disconnect() end) end
    Freecam.Connections={}
    Freecam._InputInited=false
    Freecam.MoveInput=Vector2.zero
    Freecam.Touch.Move=nil
    Freecam.Touch.Look=nil
    local char=LocalPlayer.Character
    if char then
        local root=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if root then root.Anchored=false end
        if hum then hum.AutoRotate=true hum.PlatformStand=false end
    end
    workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
endlocal OriginalWalkSpeed=16
local OriginalJump=50
local InfiniteJumpEnabled=false
local FastRunSpeed=0
local FastRunConnection=nil
task.spawn(function()
    local char=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum=char:WaitForChild("Humanoid")
    OriginalWalkSpeed=hum.WalkSpeed
    OriginalJump=(hum.JumpPower>0) and hum.JumpPower or hum.JumpHeight
end)
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local character=LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

local OriginalLighting={
    Brightness=Lighting.Brightness,
    Ambient=Lighting.Ambient,
    OutdoorAmbient=Lighting.OutdoorAmbient,
    FogStart=Lighting.FogStart,
    FogEnd=Lighting.FogEnd,
    FogColor=Lighting.FogColor,
    ClockTime=Lighting.ClockTime,
    GlobalShadows=Lighting.GlobalShadows,
    EnvironmentDiffuseScale=Lighting.EnvironmentDiffuseScale or 1,
    EnvironmentSpecularScale=Lighting.EnvironmentSpecularScale or 0,
    ColorShift_Top=Lighting.ColorShift_Top,
    ColorShift_Bottom=Lighting.ColorShift_Bottom,
    ExposureCompensation=Lighting.ExposureCompensation
}
local OriginalAtmosphere={}

local NPCESP={Enabled=false,Color=Color3.fromRGB(0,162,255),Highlights={}}
local function GetNPCPart(model)
    if not model then return nil end
    if model:FindFirstChild("HumanoidRootPart") then return model.HumanoidRootPart end
    for _,part in pairs(model:GetDescendants()) do if part:IsA("BasePart") then return part end end
    return nil
end
local function AddNPCESP(model)
    if not model then return end
    local existing=NPCESP.Highlights[model]
    if existing then
        if existing.Parent then return else NPCESP.Highlights[model]=nil end
    end
    if not model:FindFirstChildWhichIsA("Humanoid") then return end
    if game.Players:GetPlayerFromCharacter(model) then return end
    local part=GetNPCPart(model)
    if not part then return end
    local success,hl=pcall(function()
        local h=Instance.new("Highlight")
        h.Name="NPCESP"
        task.defer(function() if model and model.Parent then h.Adornee=model end end)
        h.FillColor=NPCESP.Color
        h.OutlineColor=Color3.fromRGB(255,255,255)
        h.FillTransparency=0.4
        h.OutlineTransparency=0
        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent=game.CoreGui
        return h
    end)
    if success and hl then
        NPCESP.Highlights[model]=hl
        task.delay(1,function() if hl and hl.Parent and (not hl.Adornee or hl.Adornee~=model) then pcall(function() hl.Adornee=model end) end end)
        pcall(function()
            hl.AncestryChanged:Connect(function(_,parent)
                if not parent then pcall(function() hl:Destroy() end) NPCESP.Highlights[model]=nil end
            end)
        end)
    end
end
local function RemoveNPCESP(model) if not model then return end if NPCESP.Highlights[model] then pcall(function() if NPCESP.Highlights[model] and NPCESP.Highlights[model].Parent then NPCESP.Highlights[model]:Destroy() end end) NPCESP.Highlights[model]=nil end end
local function UpdateNPCESPColor(color) NPCESP.Color=color for model,hl in pairs(NPCESP.Highlights) do if hl and hl.Parent then pcall(function() hl.FillColor=color end) else NPCESP.Highlights[model]=nil end end end
local function ToggleNPCESP(state)
    NPCESP.Enabled=state
    if state then
        task.spawn(function() for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("Model") then task.spawn(AddNPCESP,obj) end end end)
        if not Connections.NPC then Connections.NPC=workspace.DescendantAdded:Connect(function(child) task.delay(0.5,function() if child and child:IsA("Model") then AddNPCESP(child) elseif child and child:IsA("Humanoid") and child.Parent then AddNPCESP(child.Parent) end end) end) end
        task.spawn(function() while NPCESP.Enabled do for model,hl in pairs(NPCESP.Highlights) do if not model or not model.Parent or not hl or not hl.Parent then NPCESP.Highlights[model]=nil end end for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("Model") then AddNPCESP(obj) end end task.wait(2) end end)
    else
        local toRemove={} for model,_ in pairs(NPCESP.Highlights) do table.insert(toRemove,model) end
        for _,model in ipairs(toRemove) do RemoveNPCESP(model) end
        if Connections.NPC then pcall(function() Connections.NPC:Disconnect() end) Connections.NPC=nil end
    end
end

local function ClearPlayerESP()
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj.Name=="PlayerESP_Highlight" or obj.Name=="PlayerESP_Info" or obj.Name=="PlayerESP_Box" then obj:Destroy() end
    end
end
local function UpdatePlayerESP()
    if not PLAYER_ESP.Enabled then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local char=p.Character
            local hum=char:FindFirstChild("Humanoid")
            local head=char:FindFirstChild("Head")
            local root=char:FindFirstChild("HumanoidRootPart")
            if hum and head and root and hum.Health>-500 then
                local isTeam=(p.Team==LocalPlayer.Team)
                local filtered=PLAYER_ESP.TeamCheck and isTeam
                local color=p.TeamColor.Color
                local high=char:FindFirstChild("PlayerESP_Highlight")
                if PLAYER_ESP.HighlightEnabled then
                    if not high then high=Instance.new("Highlight",char) high.Name="PlayerESP_Highlight" end
                    high.FillColor=color high.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                elseif high then high:Destroy() end
                local box=char:FindFirstChild("PlayerESP_Box")
                if PLAYER_ESP.BoxEnabled and not filtered then
                    if not box then
                        box=Instance.new("BillboardGui",char) box.Name="PlayerESP_Box" box.Size=UDim2.new(4.5,0,6,0) box.AlwaysOnTop=true box.Adornee=root
                        local f=Instance.new("Frame",box) f.Size=UDim2.new(1,0,1,0) f.BackgroundTransparency=1
                        local s=Instance.new("UIStroke",f) s.Thickness=1.5
                    end
                    box.Frame.UIStroke.Color=color
                elseif box then box:Destroy() end
                local info=char:FindFirstChild("PlayerESP_Info")
                if not filtered then
                    if not info then
                        info=Instance.new("BillboardGui",char) info.Name="PlayerESP_Info" info.Size=UDim2.new(0,200,0,50) info.AlwaysOnTop=true info.Adornee=head info.ExtentsOffset=Vector3.new(0,3.5,0)
                        local txt=Instance.new("TextLabel",info) txt.Name="Label" txt.Size=UDim2.new(1,0,1,0) txt.BackgroundTransparency=1 txt.RichText=true txt.TextStrokeTransparency=0.5 txt.Font=Enum.Font.GothamMedium
                    end
                    local text=""
                    if PLAYER_ESP.ShowName then text="<font color='#ffffff'><b>"..p.DisplayName.."</b></font>\n" end
                    if PLAYER_ESP.ShowHealth then local hp=math.floor(hum.Health) local hpColor=(hp>50 and "#55ff55" or "#ff5555") text=text.."<font color='"..hpColor.."'>HP: "..hp.."</font> " end
                    if PLAYER_ESP.ShowDist then local dist=math.floor((Camera.CFrame.Position-root.Position).Magnitude) text=text.."<font color='#ffffff'>| "..dist.."m</font>" end
                    info.Label.Text=text
                elseif info then info:Destroy() end
            end
        end
    end
endlocal DevESP={Enabled=true,Targets={["ylt351"]=true,["ylt410"]=true},Objects={}}
local function RainbowColor(t) return Color3.fromHSV((tick()*0.2+t)%1,1,1) end
local function AddDevESP(player)
    if player==game.Players.LocalPlayer then return end
    if not DevESP.Enabled then return end
    if not DevESP.Targets[player.Name] then return end
    local function apply(character)
        if not character then return end
        local head=character:WaitForChild("Head",5)
        if not head then return end
        if head:FindFirstChild("DevTag") then head:FindFirstChild("DevTag"):Destroy() end
        if DevESP.Objects[player] then pcall(function() DevESP.Objects[player].Billboard:Destroy() end) DevESP.Objects[player]=nil end
        local bb=Instance.new("BillboardGui")
        bb.Name="DevTag"
        bb.Adornee=head
        bb.Size=UDim2.new(0,140,0,28)
        bb.StudsOffset=Vector3.new(0,3,0)
        bb.AlwaysOnTop=true
        bb.Parent=head
        local bg=Instance.new("Frame")
        bg.Size=UDim2.new(1,0,1,0)
        bg.BackgroundTransparency=0.2
        bg.BorderSizePixel=0
        bg.Parent=bb
        local corner=Instance.new("UICorner")
        corner.CornerRadius=UDim.new(0,8)
        corner.Parent=bg
        local gradient=Instance.new("UIGradient")
        gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.2,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.4,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(0.6,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.8,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,255))})
        gradient.Parent=bg
        local txt=Instance.new("TextLabel")
        txt.Size=UDim2.new(1,-10,1,-6)
        txt.Position=UDim2.new(0,5,0,3)
        txt.BackgroundTransparency=1
        txt.Text="红星中心开发者"
        txt.TextScaled=false
        txt.TextSize=13
        txt.Font=Enum.Font.SourceSansBold
        txt.TextStrokeTransparency=0.4
        txt.TextColor3=Color3.new(1,1,1)
        txt.Parent=bg
        DevESP.Objects[player]={Billboard=bb,Text=txt}
        task.spawn(function() while DevESP.Objects[player] and txt.Parent do local c=RainbowColor(0) pcall(function() txt.TextColor3=c end) task.wait(0.1) end end)
    end
    if player.Character then apply(player.Character) end
    player.CharacterAdded:Connect(function(char) task.wait(1) apply(char) end)
end
for _,plr in ipairs(game.Players:GetPlayers()) do AddDevESP(plr) end
game.Players.PlayerAdded:Connect(AddDevESP)

local VisualModule={NormalNightVision=false,SuperNightVision=false,NoFog=false}
local function ApplyNormalNightVision(enable)
    VisualModule.NormalNightVision=enable
    if enable then
        Lighting.Brightness=10 Lighting.Ambient=Color3.fromRGB(220,220,220) Lighting.OutdoorAmbient=Color3.fromRGB(220,220,220)
        Lighting.EnvironmentDiffuseScale=1 Lighting.EnvironmentSpecularScale=1 Lighting.GlobalShadows=false Lighting.ClockTime=8
        Lighting.ColorShift_Top=Color3.new(0,0,0) Lighting.ColorShift_Bottom=Color3.new(0,0,0)
        Notify("普通夜视开启","成功",2)
    else
        for k,v in pairs(OriginalLighting) do pcall(function() Lighting[k]=v end) end
        Notify("普通夜视关闭","成功",2)
    end
end
local function ApplySuperNightVision(enable)
    VisualModule.SuperNightVision=enable
    if enable then
        Lighting.Brightness=70 Lighting.Ambient=Color3.fromRGB(255,255,255) Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        Lighting.GlobalShadows=false Lighting.ClockTime=12 Lighting.FogEnd=100000 Lighting.EnvironmentDiffuseScale=1
        Notify("超级夜视开启","成功",2)
    else
        for k,v in pairs(OriginalLighting) do pcall(function() Lighting[k]=v end) end
        Notify("超级夜视关闭","成功",2)
    end
end
local function ApplyNoFog(enable)
    VisualModule.NoFog=enable
    if enable then
        Lighting.FogStart=0 Lighting.FogEnd=math.huge Lighting.FogColor=Color3.fromRGB(200,200,220)
        for _,obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("Atmosphere") then
                if not OriginalAtmosphere[obj] then OriginalAtmosphere[obj]={Density=obj.Density,Offset=obj.Offset,Glare=obj.Glare,Haze=obj.Haze} end
                pcall(function() obj.Density=0 obj.Offset=0 obj.Glare=0 obj.Haze=0 end)
            end
        end
        Notify("去雾开启","成功",2)
    else
        Lighting.FogStart=OriginalLighting.FogStart Lighting.FogEnd=OriginalLighting.FogEnd Lighting.FogColor=OriginalLighting.FogColor
        for obj,props in pairs(OriginalAtmosphere) do if obj and obj.Parent then pcall(function() obj.Density=props.Density obj.Offset=props.Offset obj.Glare=props.Glare obj.Haze=props.Haze end) end end
        OriginalAtmosphere={}
        Notify("去雾关闭","成功",2)
    end
end
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if VisualModule.NormalNightVision then ApplyNormalNightVision(true) end
    if VisualModule.SuperNightVision then ApplySuperNightVision(true) end
    if VisualModule.NoFog then ApplyNoFog(true) end
end)

local AntiFall2Enabled=false local AntiFall2Connection=nil
local function StartAntiFall2(character)
    if AntiFall2Connection then AntiFall2Connection:Disconnect() AntiFall2Connection=nil end
    local root=character:WaitForChild("HumanoidRootPart")
    local lastY=root.Position.Y
    local CHECK_INTERVAL=14
    AntiFall2Connection=game:GetService("RunService").Heartbeat:Connect(function()
        if not AntiFall2Enabled then return end
        if not character.Parent then return end
        local currentPosition=root.Position
        local fallDistance=lastY-currentPosition.Y
        if fallDistance>=CHECK_INTERVAL then
            local currentVel=root.AssemblyLinearVelocity
            root.CFrame=root.CFrame*CFrame.new(0,-0.5,0)
            root.AssemblyLinearVelocity=Vector3.new(currentVel.X,-10,currentVel.Z)
            lastY=root.Position.Y
        end
        if currentPosition.Y>lastY then lastY=currentPosition.Y end
    end)
end
LocalPlayer.CharacterAdded:Connect(function(char) task.wait(0.5) StartAntiFall2(char) end)
if LocalPlayer.Character then StartAntiFall2(LocalPlayer.Character) end

local AntiFallEnabled=false local AntiFallConnection=nil
local function StartAntiFall(character)
    local root=character:WaitForChild("HumanoidRootPart")
    if AntiFallConnection then AntiFallConnection:Disconnect() AntiFallConnection=nil end
    AntiFallConnection=RunService.Heartbeat:Connect(function()
        if not AntiFallEnabled then return end
        if not root or not root.Parent then return end
        local velocity=root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity=Vector3.zero
        RunService.RenderStepped:Wait()
        root.AssemblyLinearVelocity=velocity
    end)
end
local function ToggleAntiFall(state)
    AntiFallEnabled=state
    if state then
        local char=LocalPlayer.Character
        if char then StartAntiFall(char) end
        Notify("防摔落伤害","已开启",1)
    else
        if AntiFallConnection then AntiFallConnection:Disconnect() AntiFallConnection=nil end
        Notify("防摔落伤害","已关闭",1)
    end
end
LocalPlayer.CharacterAdded:Connect(function(char) if AntiFallEnabled then StartAntiFall(char) end end)local Window = WindUI:CreateWindow({
    Title="红星中心",
    Icon="solar:moon-bold",
    Author="作者:红星",
    Folder="NightHub",
    Size=UDim2.fromOffset(520,420),
    Transparent=true,
    Theme=CurrentTheme,
    NewElements=true,
    OpenButton={CornerRadius=UDim.new(1,0),Scale=1,Draggable=true,Color=ColorSequence.new(Color3.fromRGB(200,40,40),Color3.fromRGB(255,80,80))},
    SideBarWidth=150,
    ScrollBarEnabled=false,
    User={Enabled=true,Anonymous=false}
})
pcall(function() WindUI:SetTheme(CurrentTheme) end)
Window:Tag({Title="红星中心V1.1",Icon="github",Color=Color3.fromRGB(255,204,0),Radius=8})

local MainTab=Window:Tab({Title="公告",Icon="megaphone",Locked=false})
MainTab:Paragraph({Title="欢迎使用红星中心",Desc=""})
MainTab:Button({Title="复制QQ群",Callback=function() if setclipboard then setclipboard("1106456119") end end})

local TabOther=Window:Tab({Title="通用",Icon="info",Locked=false})
TabOther:Button({Title="一键飞行",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/flyab.lua"))() end) if ok then Notify("成功","飞行已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="枪械飞行",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/fly"))() end) if ok then Notify("成功","枪械飞行已加载",2) else Notify("错误",tostring(err),3) end end})
local NoclipConnection=nil local CharacterConnection=nil local OriginalCollision={}
TabOther:Toggle({Title="穿墙",Default=false,Callback=function(enabled)
    if enabled then
        OriginalCollision={}
        if CharacterConnection then CharacterConnection:Disconnect() end
        CharacterConnection=LocalPlayer.CharacterAdded:Connect(function() OriginalCollision={} end)
        if NoclipConnection then NoclipConnection:Disconnect() end
        NoclipConnection=RunService.Stepped:Connect(function()
            local character=LocalPlayer.Character
            if not character then return end
            for _,part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if OriginalCollision[part]==nil then OriginalCollision[part]=part.CanCollide end
                    part.CanCollide=false
                end
            end
        end)
        AddFeature("穿墙")
    else
        if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection=nil end
        if CharacterConnection then CharacterConnection:Disconnect() CharacterConnection=nil end
        for part,state in pairs(OriginalCollision) do if typeof(part)=="Instance" and part.Parent then part.CanCollide=state end end
        OriginalCollision={}
        RemoveFeature("穿墙")
    end
end})
TabOther:Toggle({Title="自由视角",Default=false,Callback=function(v) if v then StartFreecam() Notify("自由视角","已开启",2) AddFeature("自由视角") else StopFreecam() Notify("自由视角","已关闭",2) RemoveFeature("自由视角") end end})
TabOther:Slider({Title="自由视角速度",Value={Min=1,Max=20,Default=2},Increment=0.5,Callback=function(value) Freecam.Speed=value end})
TabOther:Toggle({Title="防摔落伤害",Default=false,Callback=function(v) ToggleAntiFall(v) if v then AddFeature("防摔") else RemoveFeature("防摔") end end})
TabOther:Toggle({Title="防摔落伤害2（1没用再开）",Default=false,Callback=function(state) AntiFall2Enabled=state if state then Notify("防摔落伤害2","已开启",3) AddFeature("防摔落伤害2") else Notify("防摔落伤害2","已关闭",3) RemoveFeature("防摔落伤害2") end end})
TabOther:Toggle({Title="闪电尖兵大招（瞬移）",Default=false,Callback=function(v) if v then EnableTPUI() AddFeature("瞬移") else DisableTPUI() RemoveFeature("瞬移") end end})
TabOther:Button({Title="卡服脚本",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/卡服.lua"))() end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="静默自瞄",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/odhdshhe/bu/refs/heads/main/%E6%9C%88%E4%BA%AE%E5%8A%A0%E5%AF%86%E8%BF%87%E7%9A%84%E6%9E%97%E7%9A%84%E8%87%AA%E7%9E%84.lua"))() end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="甩飞所有",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/甩飞"))() end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="r6道馆",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))() end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="r15道馆",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))() end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="无敌少侠飞行",Callback=function() local UIS=game:GetService("UserInputService") if UIS.TouchEnabled and not UIS.KeyboardEnabled then local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/MobileFly.lua"))() end) if ok then Notify("成功","手机飞行已加载",2) else Notify("错误",tostring(err),3) end else local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/FlyR15.lua"))() end) if ok then Notify("成功","PC飞行已加载",2) else Notify("错误",tostring(err),3) end end end})
TabOther:Button({Title="黑洞",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/黑洞"))() end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="红星自瞄",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/ye%20aimbot"))() end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="红星中心测试版",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/fyukvdrf"))() end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="fe变车（有些动画关不掉）",Callback=function() local ok,err=pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-SILLY-CAR-V1-48227"))() end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Toggle({Title="强制第三人称",Default=false,Callback=function(v) if v then EnableUnlock() AddFeature("第三人称") else DisableUnlock() RemoveFeature("第三人称") end end})
TabOther:Button({Title="绕过群组检测",Callback=function() local ok,err=pcall(function() local getnamecallmethod=getnamecallmethod local Speaker=cloneref(game:GetService("Players")).LocalPlayer local OldNameCall OldNameCall=hookmetamethod(game,"__namecall",function(self,...) if self~=Speaker or getnamecallmethod()~="IsInGroup" then return OldNameCall(self,...) end return true end) hookfunction(Speaker.IsInGroup,function(self,...) return true end) end) if ok then Notify("成功","已绕过",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="一键清屏（有独立UI可关闭）",Callback=function() local ok,err=pcall(function() --完整代码略（原脚本已有） end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})
TabOther:Button({Title="点击传送工具（红星中心重制版）",Callback=function() local ok,err=pcall(function() local Players=game:GetService("Players") local Workspace=game:GetService("Workspace") local LocalPlayer=Players.LocalPlayer local Mouse=LocalPlayer:GetMouse() local Camera=Workspace.CurrentCamera local Tool=Instance.new("Tool") Tool.Name="点击传送道具" Tool.RequiresHandle=false Tool.Activated:Connect(function() local Character=LocalPlayer.Character if not Character then return end local HRP=Character:FindFirstChild("HumanoidRootPart") if not HRP then return end local params=RaycastParams.new() params.FilterDescendantsInstances={Character} params.FilterType=Enum.RaycastFilterType.Blacklist local unitRay=Camera:ScreenPointToRay(Mouse.X,Mouse.Y) local rayOrigin=unitRay.Origin local rayDirection=unitRay.Direction*100000 local result=Workspace:Raycast(rayOrigin,rayDirection,params) if not result then warn("点到空气，取消传送") return end local hitPos=result.Position+Vector3.new(0,3,0) HRP.CFrame=CFrame.new(hitPos) end) Tool.Parent=LocalPlayer:WaitForChild("Backpack") end) if ok then Notify("成功","已加载",2) else Notify("错误",tostring(err),3) end end})

local TabVisual=Window:Tab({Title="透视功能",Icon="eye",Locked=false})
TabVisual:Paragraph({Title="提示",Desc="旧互动少但中文，新版更多但英文"})
TabVisual:Toggle({Title="NPC透视",Default=false,Callback=function(v) ToggleNPCESP(v) if v then AddFeature("NPC透视") else RemoveFeature("NPC透视") end end})
TabVisual:Toggle({Title="旧版互动透视",Default=false,Callback=function(v) ToggleInteractESP(v) if v then AddFeature("互动透视") else RemoveFeature("互动透视") end end})
TabVisual:Toggle({Title="新版互动透视",Default=false,Callback=function(v) ToggleNewInteractESP(v) if v then AddFeature("新版互动透视") else RemoveFeature("新版互动透视") end end})
TabVisual:Button({Title="刷新新版ESP",Callback=function() ToggleNewInteractESP(false) task.wait(0.2) ToggleNewInteractESP(true) end})
TabVisual:Toggle({Title="玩家透视",Default=false,Callback=function(v) PLAYER_ESP.Enabled=v if not v then ClearPlayerESP() end if v then AddFeature("玩家透视") else RemoveFeature("玩家透视") end end})
TabVisual:Toggle({Title="高亮",Default=false,Callback=function(v) PLAYER_ESP.HighlightEnabled=v end})
TabVisual:Toggle({Title="方框",Default=false,Callback=function(v) PLAYER_ESP.BoxEnabled=v end})
TabVisual:Toggle({Title="名字",Default=false,Callback=function(v) PLAYER_ESP.ShowName=v end})
TabVisual:Toggle({Title="血量",Default=false,Callback=function(v) PLAYER_ESP.ShowHealth=v end})
TabVisual:Toggle({Title="距离",Default=false,Callback=function(v) PLAYER_ESP.ShowDist=v end})
TabVisual:Toggle({Title="队伍检测",Default=false,Callback=function(v) PLAYER_ESP.TeamCheck=v end})

local TabAimbot=Window:Tab({Title="自瞄",Icon="target",Locked=false})
TabAimbot:Toggle({Title="自瞄开关",Default=false,Callback=function(v) ESP_SETTINGS.HighlightEnabled=v if circle then circle.Visible=v end if v then AddFeature("自瞄") else RemoveFeature("自瞄") end end})
local FOVToggle=TabAimbot:Toggle({Title="显示FOV圈",Default=true,Callback=function(v) ShowFOVCircle=v end})
task.delay(0.1,function() if FOVToggle then FOVToggle:Set(ShowFOVCircle) end end)
TabAimbot:Toggle({Title="队伍检测",Default=ESP_SETTINGS.TeamCheck,Callback=function(v) ESP_SETTINGS.TeamCheck=v end})
TabAimbot:Toggle({Title="墙体检测",Default=ESP_SETTINGS.WallCheck,Callback=function(v) ESP_SETTINGS.WallCheck=v end})
TabAimbot:Slider({Title="自瞄范围(FOV)",Value={Min=10,Max=700,Default=FOV},Increment=10,Callback=function(v) FOV=v end})
TabAimbot:Slider({Title="最大距离",Value={Min=50,Max=6000,Default=MaxDistance},Increment=50,Callback=function(v) MaxDistance=v end})
TabAimbot:Toggle({Title="平滑自瞄",Default=ESP_SETTINGS.SmoothAim,Callback=function(v) ESP_SETTINGS.SmoothAim=v end})
local AimPartDropdown=TabAimbot:Dropdown({Title="瞄准部位",Values=AimPartsList,Default=nil,Callback=function(v) if typeof(v)=="table" then v=v.Value or v[1] end if v then AimPart=v end end})
task.defer(function() AimPart="Head" end)
TabAimbot:Toggle({Title="指定自瞄目标",Default=false,Callback=function(v) LockTargetEnabled=v end})
local PlayerDropdown=nil local AimbotPlayerList={}
local function RefreshAimbotPlayerList()
    AimbotPlayerList={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(AimbotPlayerList,p.Name) end end
    local lastSelected=SelectedTarget and SelectedTarget.Name or nil
    if PlayerDropdown then PlayerDropdown:Refresh(AimbotPlayerList,lastSelected)
    else PlayerDropdown=TabAimbot:Dropdown({Title="选择玩家",Values=AimbotPlayerList,Default=lastSelected,Callback=function(v) if typeof(v)=="table" then v=v.Value or v[1] end if not v then return end local target=Players:FindFirstChild(v) if target then SelectedTarget=target end end}) end
end
TabAimbot:Button({Title="刷新玩家列表",Callback=RefreshAimbotPlayerList})
TabAimbot:Toggle({Title="启用团队白名单",Default=false,Callback=function(v) AimbotTeamWhitelistEnabled=v end})
local TeamDropdown=nil
local function RefreshTeamList()
    local teams={}for _,t in ipairs(game:GetService("Teams"):GetTeams()) do table.insert(teams,t.Name) end
    if TeamDropdown then TeamDropdown:Refresh(teams,{})
    else TeamDropdown=TabAimbot:Dropdown({Title="自瞄团队白名单",Values=teams,Value={},Multi=true,AllowNone=true,Callback=function(selected) AimbotTeamWhitelist={} for _,teamName in ipairs(selected) do AimbotTeamWhitelist[teamName]=true end end}) end
end
TabAimbot:Button({Title="刷新团队列表",Callback=RefreshTeamList})
task.delay(1,function() RefreshTeamList() RefreshAimbotPlayerList() end)

AimbotConnection=RunService.RenderStepped:Connect(function()
    if circle then
        local size=FOV*2
        circle.Size=UDim2.new(0,size,0,size)
        local shouldShow=ESP_SETTINGS.HighlightEnabled and ShowFOVCircle
        if circle.Visible~=shouldShow then circle.Visible=shouldShow end
    end
    if not Camera then return end
    if not ESP_SETTINGS.HighlightEnabled then return end
    local target=getTarget()
    if target and target.Character then
        local part=GetAimPart(target.Character)
        if part then
            local camPos=Camera.CFrame.Position
            local direction=(part.Position-camPos).Unit
            local newCF=CFrame.new(camPos,camPos+direction)
            if ESP_SETTINGS.SmoothAim then Camera.CFrame=Camera.CFrame:Lerp(newCF,Smoothness)
            else Camera.CFrame=newCF end
        end
    end
end)

RunService.Heartbeat:Connect(function() if PLAYER_ESP.Enabled then UpdatePlayerESP() end end)

WindUI:Notify({Title="脚本加载成功",Content="红星中心 v1.2",Duration=3,Icon="bird"})

task.wait(0.3)
local Main=Window.UIElements.Main
for _,v in ipairs(Main:GetDescendants()) do if v:IsA("UIStroke") and v.Name=="RainbowBorder" then v:Destroy() end end
local Stroke=Instance.new("UIStroke")
Stroke.Name="RainbowBorder"
Stroke.Thickness=3.5
Stroke.Color=Color3.new(1,1,1)
Stroke.LineJoinMode=Enum.LineJoinMode.Round
Stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
Stroke.Parent=Main
local Gradient=Instance.new("UIGradient")
Gradient.Name="RainbowGradient"
Gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.16,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.66,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})
Gradient.Parent=Stroke
local currentAngle=0
local rotSpeed=150
RunService.RenderStepped:Connect(function(dt) if Stroke and Stroke.Parent then currentAngle=(currentAngle+dt*rotSpeed)%360 Gradient.Rotation=currentAngle end end)
Stroke.Enabled=true
Stroke.Transparency=0
local Corner=Main:FindFirstChildOfClass("UICorner")
if not Corner then Corner=Instance.new("UICorner") Corner.CornerRadius=UDim.new(0,12) Corner.Parent=Main end

loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/djejhebr"))()
```