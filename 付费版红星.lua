-- 红星中心 | WindUI Script（白名单系统 + 首页 + 服务器 + 支持服务器）
local RunService = game:GetService("RunService")
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))

-- // 白名单系统
local Whitelist = {
	"jjb1169", -- 你的名字
	"ugvjjuyf", -- 白名单
	"tpi_io", -- 白名单
	"cjicji2414",-- 白名单
	"MKQoew51",--白名单
	-- 在这里添加更多白名单玩家，例如：
	-- "玩家名字2",
	-- "玩家名字3",
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 检查当前玩家是否在白名单中
if not table.find(Whitelist, LocalPlayer.Name) then
	-- 不在白名单中，提示并停止脚本
	warn("[红星中心] 你没有权限使用此脚本！")
	if not RunService:IsStudio() then
		LocalPlayer:Kick("你没有权限使用红星中心")
	else
		print("[红星中心] 当前玩家 '" .. LocalPlayer.Name .. "' 不在白名单中")
	end
	return -- 停止执行
end

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
			WindUI =
				loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
		end
	end
end

-- // 颜色
local Red = Color3.fromHex("#FF3B30")
local Yellow = Color3.fromHex("#FFD60A")
local Grey = Color3.fromHex("#83889E")

-- // 主窗口
local Window = WindUI:CreateWindow({
	Title = "红星中心",
	Folder = "RedStarHub",
	Icon = "solar:folder-2-bold-duotone",
	NewElements = true,
	HideSearchBar = false,

	OpenButton = {
		Title = "打开红星中心",
		CornerRadius = UDim.new(1, 0),
		StrokeThickness = 3,
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.8,

		Color = ColorSequence.new(Red, Color3.fromHex("#FFD60A")),
	},

	Topbar = {
		Height = 44,
		ButtonsType = "Mac",
	},
})

-- // 版本标签
Window:Tag({
	Title = "红星中心 v" .. WindUI.Version,
	Icon = "github",
	Color = Red,
	Border = true,
})

-- // 首页 Tab
local HomeTab = Window:Tab({
	Title = "首页",
	Desc = "欢迎使用红星中心",
	Icon = "solar:info-square-bold",
	IconColor = Red,
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

-- // 服务器 Tab
local ServerTab = Window:Tab({
	Title = "服务器",
	Desc = "服务器功能",
	Icon = "solar:folder-2-bold-duotone",
	IconColor = Red,
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
		local placeId = game.PlaceId
		ts:Teleport(placeId, LocalPlayer)
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

-- // 支持服务器 Tab
local SupportServerTab = Window:Tab({
	Title = "支持服务器",
	Desc = "支持的服务器脚本",
	Icon = "solar:folder-2-bold-duotone",
	IconColor = Red,
	IconShape = "Square",
	Border = true,
})

local SupportServerSection = SupportServerTab:Section({
	Title = "支持的服务器",
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
