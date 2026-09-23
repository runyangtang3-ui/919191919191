-- 红星中心 | WindUI + Patriot 密钥系统（30卡密）
local RunService = game:GetService("RunService")
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 卡密列表（30个卡密，前缀HXNB）
local ValidKeys = {
	"HXNB-7K3M-9Q2X-4F8A",
	"HXNB-2R8T-5L1P-9C6W",
	"HXNB-4J9N-7V3K-1M5Q",
	"HXNB-8F2D-6H4S-3B7G",
	"HXNB-3C6V-9X1Z-7N2M",
	"HXNB-5T8R-2W4Q-8J1K",
	"HXNB-6Y7U-4I9O-1L3P",
	"HXNB-9E2R-7T5Y-6U8I",
	"HXNB-1Q6W-3E9R-5T7Y",
	"HXNB-8A4S-2D6F-9G7H",
	"HXNB-7Z3X-5C8V-1B2N",
	"HXNB-4M9J-6K2L-8O3P",
	"HXNB-2W5E-9R1T-7Y4U",
	"HXNB-5H8G-3F6D-1S2A",
	"HXNB-9J6K-4L7M-2N8B",
	"HXNB-1Q5W-8E3R-6T9Y",
	"HXNB-7U4I-2O9P-5A6S",
	"HXNB-3D8F-1G7H-4J2K",
	"HXNB-6L9M-8N3B-2V5C",
	"HXNB-9X2Z-7C4V-1B6N",
	"HXNB-4M7J-5K9L-8O2P",
	"HXNB-2W8E-3R6T-1Y5U",
	"HXNB-7H4G-9F2D-6S8A",
	"HXNB-1J5K-3L7M-4N9B",
	"HXNB-8V2C-5X7Z-6B3N",
	"HXNB-3Q6W-9E1R-2T4Y",
	"HXNB-5I8O-7P2A-4S6D",
	"HXNB-9U3Y-1T5R-8E2W",
	"HXNB-2B6N-7M4K-3J9L",
	"HXNB-6C8V-5X2Z-4A7S",
}

-- 设备标识获取
local function getDeviceId()
	local success, result = pcall(function()
		return game:GetService("RbxAnalyticsService"):GetClientId()
	end)
	if success and result then
		return tostring(result)
	end
	if identifyexecutor then
		return identifyexecutor() .. "_" .. LocalPlayer.UserId
	end
	return tostring(LocalPlayer.UserId) .. "_" .. tostring(game.PlaceId)
end

-- 本地存储
local function saveBinding(key, deviceId)
	if not writefile then return false end
	writefile("RedStarHub_kami.txt", HttpService:JSONEncode({key = key, deviceId = deviceId}))
	return true
end

local function loadBinding()
	if not readfile or not isfile or not isfile("RedStarHub_kami.txt") then
		return nil
	end
	local success, content = pcall(function() return readfile("RedStarHub_kami.txt") end)
	if not success then return nil end
	local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
	if not ok then return nil end
	return data
end

-- 验证绑定
local function validateBinding()
	local binding = loadBinding()
	if binding then
		if binding.deviceId == getDeviceId() then
			return true, binding.key
		else
			return false, "此卡密已绑定其他设备"
		end
	end
	return false, nil
end

local isBound, bindResult = validateBinding()
if not isBound and bindResult then
	warn("[红星中心] " .. bindResult)
	if not RunService:IsStudio() then
		LocalPlayer:Kick(bindResult)
	end
	return
end

local boundKey = bindResult

-- 加载 WindUI
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

-- 加载 Patriot UI
local Patriot
do
	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/SyndromeXph/Patriot-Key-System-Ui-Library/refs/heads/main/PatriotUi.luau"))()
	end)
	if ok then
		Patriot = result
	else
		warn("[红星中心] Patriot UI 加载失败")
		return
	end
end

-- 颜色
local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Grey = Color3.fromHex("#83889E")
local Blue = Color3.fromHex("#257AF7")
local Red = Color3.fromHex("#EF4F1D")

-- 创建主窗口
function createMainWindow()
	local Window = WindUI:CreateWindow({
		Title = "红星中心",
		Folder = "RedStarHub",
		Icon = "solar:folder-2-bold-duotone",
		NewElements = true,
		HideSearchBar = false,

		OpenButton = {
			Title = "hx 打开红星中心",
			CornerRadius = UDim.new(1, 0),
			StrokeThickness = 3,
			Enabled = true,
			Draggable = true,
			OnlyMobile = false,
			Scale = 0.5,

			Color = ColorSequence.new(
				Color3.fromHex("#30FF6A"),
				Color3.fromHex("#e7ff2f")
			),
		},
		Topbar = {
			Height = 44,
			ButtonsType = "Mac",
		},
	})

	Window:Tag({
		Title = "v" .. WindUI.Version,
		Icon = "github",
		Color = Color3.fromHex("#1c1c1c"),
		Border = true,
	})

	-- 首页
	local HomeTab = Window:Tab({
		Title = "首页",
		Desc = "欢迎使用红星中心",
		Icon = "solar:info-square-bold",
		IconColor = Grey,
		IconShape = "Square",
		Border = true,
	})

	local HomeSection = HomeTab:Section({
		Title = "红星中心",
	})

	HomeSection:Section({
		Title = "欢迎使用红星中心付费版",
		TextSize = 22,
		FontWeight = Enum.FontWeight.SemiBold,
	})

	-- 公告：国庆倒计时
	HomeSection:Section({
		Title = "公告",
		TextSize = 18,
		FontWeight = Enum.FontWeight.SemiBold,
	})

	local CountdownPara = HomeSection:Paragraph({
		Title = "距离国庆节还有：计算中...",
		Desc = "",
		Image = "solar:calendar-bold",
	})

	task.spawn(function()
		local function getTarget()
			local now = os.time()
			local year = tonumber(os.date("%Y", now))
			-- 北京时间 10月1日 00:00 = UTC 9月30日 16:00
			local target = os.time({year = year, month = 9, day = 30, hour = 16, min = 0, sec = 0})
			if now >= target then
				target = os.time({year = year + 1, month = 9, day = 30, hour = 16, min = 0, sec = 0})
			end
			return target
		end

		local target = getTarget()
		while true do
			local now = os.time()
			if now >= target then
				target = getTarget()
			end
			local diff = target - now
			local days = math.floor(diff / 86400)
			local hours = math.floor((diff % 86400) / 3600)
			local minutes = math.floor((diff % 3600) / 60)
			local seconds = diff % 60
			CountdownPara:Set({
				Title = string.format("距离国庆节还有：%d天 %d小时 %d分钟 %d秒", days, hours, minutes, seconds)
			})
			task.wait(1)
		end
	end)

	-- 服务器
	local ServerTab = Window:Tab({
		Title = "服务器",
		Desc = "服务器功能",
		Icon = "solar:folder-2-bold-duotone",
		IconColor = Grey,
		IconShape = "Square",
		Border = true,
	})

	local ServerSection = ServerTab:Section({
		Title = "服务器功能",
	})

	ServerSection:Button({
		Title = "重新加入服务器",
		Color = Red,
		Callback = function()
			local ts = game:GetService("TeleportService")
			ts:Teleport(game.PlaceId, LocalPlayer)
		end,
	})

	ServerSection:Button({
		Title = "复制服务器 ID",
		Color = Yellow,
		Callback = function()
			setclipboard(game.JobId)
		end,
	})

	ServerSection:Button({
		Title = "显示服务器信息",
		Color = Grey,
		Callback = function()
			print("服务器 ID:", game.JobId)
			print("地点 ID:", game.PlaceId)
			print("玩家数:", #Players:GetPlayers())
			print("最大玩家数:", Players.MaxPlayers)
		end,
	})

	-- 支持服务器
	local SupportServerTab = Window:Tab({
		Title = "支持服务器",
		Desc = "支持的服务器脚本",
		Icon = "solar:folder-2-bold-duotone",
		IconColor = Grey,
		IconShape = "Square",
		Border = true,
	})

	local SupportServerSection = SupportServerTab:Section({
		Title = "支持的服务器",
		Scrollable = true,
	})

	SupportServerSection:Button({
		Title = "最坚强的战场",
		Color = Red,
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/runyangtang3-ui/Good/refs/heads/main/%E6%9C%80%E5%9D%9A%E5%BC%BA"))()
		end,
	})

	SupportServerSection:Button({
		Title = "采集一座山",
		Color = Yellow,
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/runyangtang3-ui/SYNb/refs/heads/main/%E6%B1%89%E5%8C%96%E7%89%88%E5%BC%80%E5%B1%B1.lua"))()
		end,
	})

	SupportServerSection:Button({
		Title = "TTK枪战服务器",
		Color = Grey,
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/runyangtang3-ui/jjb/refs/heads/main/TT%E6%B5%8B%E8%AF%95.lua"))()
		end,
	})

	SupportServerSection:Button({
		Title = "CS go",
		Color = Blue,
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/runyangtang3-ui/Good/refs/heads/main/%E5%A4%A9%E7%BD%A1.lua"))()
		end,
	})

	SupportServerSection:Button({
		Title = "神奇一击无冷却",
		Color = Green,
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/runyangtang3-ui/SYNb/refs/heads/main/%E7%A5%9E%E5%A5%87.lua"))()
		end,
	})

	SupportServerSection:Button({
		Title = "狙击竞技场",
		Color = Purple,
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/runyangtang3-ui/Good/refs/heads/main/%E7%8B%99%E5%87%BB%E7%AB%9E%E6%8A%80%E5%9C%BA.lua"))()
		end,
	})

	SupportServerSection:Button({
		Title = "重型钓鱼 感谢🐾蛙QwQ🐾让我缝合",
		Color = Color3.fromHex("#FF9500"),
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/runyangtang3-ui/jjb/refs/heads/main/%E9%87%8D%E5%9E%8B%E9%92%93%E9%B1%BC.lua"))()
		end,
	})

	SupportServerSection:Button({
		Title = "死铁轨 感谢🐾蛙QwQ🐾让我缝合",
		Color = Color3.fromHex("#00BCD4"),
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/runyangtang3-ui/jjb/refs/heads/main/%E6%AD%BB%E4%BA%A1%E8%BD%A8%E8%BF%B9.lua"))()
		end,
	})

	SupportServerSection:Button({
		Title = "CS go无后座无UI",
		Color = Color3.fromHex("#FF69B4"),
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/runyangtang3-ui/SYNb/refs/heads/main/csgo.lua"))()
		end,
	})

	SupportServerSection:Button({
		Title = "CS go好用中文脚本",
		Color = Color3.fromHex("#50C878"),
		Callback = function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/runyangtang3-ui/SYNb/refs/heads/main/%E9%9C%B8%E5%A4%A9%E6%90%AC%E8%BF%90.lua"))()
		end,
	})
end

-- Patriot 配置
Patriot.Appearance = {
	Title = "红星中心密钥系统",
	Subtitle = "请输入密钥",
	Icon = "rbxassetid://0",
	IconSize = UDim2.new(0, 30, 0, 30)
}

Patriot.Links = {
	GetKey = "https://www.qq.com",
	Discord = ""
}

Patriot.Storage = {
	FileName = "Patriot_Key",
	Remember = true,
	AutoLoad = false
}

Patriot.Options = {
	Keyless = false,
	Blur = true,
	Draggable = true
}

Patriot.Theme = {
	Accent = Color3.fromRGB(255, 0, 0),
	AccentHover = Color3.fromRGB(255, 50, 50),
	Background = Color3.fromRGB(20, 0, 0),
	Header = Color3.fromRGB(30, 0, 0),
	Input = Color3.fromRGB(40, 0, 0),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(200, 150, 150),
	Success = Color3.fromRGB(50, 255, 50),
	Error = Color3.fromRGB(255, 60, 60),
	Warning = Color3.fromRGB(255, 200, 50),
	StatusIdle = Color3.fromRGB(180, 50, 50),
	Discord = Color3.fromRGB(255, 0, 0),
	DiscordHover = Color3.fromRGB(255, 50, 50),
	Divider = Color3.fromRGB(60, 0, 0),
	Pending = Color3.fromRGB(50, 0, 0)
}

Patriot.Changelog = {}
Patriot.Shop = {
	Enabled = false,
	Icon = "",
	Title = "获取高级版",
	Subtitle = "即时交付",
	ButtonText = "购买",
	Link = ""
}

-- 本地验证
Patriot.Callbacks.OnVerify = function(key)
	if table.find(ValidKeys, key) then
		local binding = loadBinding()
		if binding and binding.deviceId ~= getDeviceId() then
			return { valid = false, error = "ALREADY_BOUND", message = "此卡密已绑定其他设备" }
		end
		if not saveBinding(key, getDeviceId()) then
			return { valid = false, error = "SAVE_FAILED", message = "卡密绑定失败，请更换执行器" }
		end
		return true
	else
		return { valid = false, error = "INVALID_KEY", message = "卡密无效" }
	end
end

Patriot.Callbacks.OnSuccess = function()
	print("验证成功")
	createMainWindow()
end

Patriot.Callbacks.OnFail = function(errorMsg)
	print("验证失败:", errorMsg)
end

Patriot.Callbacks.OnClose = function()
	print("用户关闭验证窗口")
end

-- 主流程
if boundKey then
	createMainWindow()
else
	Patriot:Launch()

	task.spawn(function()
		task.wait(0.8)
		local playerGui = LocalPlayer:WaitForChild("PlayerGui")
		local targetButton = nil
		for _, gui in ipairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") then
				for _, obj in ipairs(gui:GetDescendants()) do
					if obj:IsA("TextButton") then
						local text = obj.Text:lower()
						if text:find("get key") or text:find("获取密钥") then
							targetButton = obj
							break
						end
					end
				end
			end
			if targetButton then break end
		end

		if targetButton then
			targetButton.Text = "加入QQ群 1106456119"
			for _, conn in ipairs(getconnections(targetButton.MouseButton1Click)) do
				conn:Disconnect()
			end
			targetButton.MouseButton1Click:Connect(function()
				pcall(function() setclipboard("1106456119") end)
				local hint = Instance.new("TextLabel")
				hint.Size = UDim2.new(0, 200, 0, 20)
				hint.Position = UDim2.new(0.5, -100, 0.5, -10)
				hint.BackgroundTransparency = 1
				hint.Text = "群号已复制！"
				hint.TextColor3 = Color3.fromRGB(255, 255, 255)
				hint.Font = Enum.Font.SourceSansBold
				hint.TextSize = 14
				hint.Parent = targetButton.Parent
				task.delay(2, function() hint:Destroy() end)
			end)
		else
			warn("未找到获取密钥按钮")
		end
	end)
end