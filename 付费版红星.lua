已添加“音乐”标签页，包含搜索播放、停止功能，以及你提供的所有音乐列表。

```lua
-- 红星中心 | WindUI Script
local RunService = game:GetService("RunService")
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))

local Whitelist = {
	"jjb1169",
	"ugvjjuyf",
	"tpi_io",
	"MKQoew51",
	"m0NESY114514",
	"FFH_001",
	"Jamsswi",
	"zyz_z020",
	"qin1478",
	"thHV121",
	"jjsz2211",
	"zds19299124683",
	"jay798777",
	"jay798000",
	"honikml",
	"THQngedqx",
	"rydtyrscvvh",
	"xuzhiyong2065",
	"mount rng",
	"zyb_d7344",
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not table.find(Whitelist, LocalPlayer.Name) then
	warn("[红星中心] 你没有权限使用此脚本！")
	if not RunService:IsStudio() then
		LocalPlayer:Kick("你没有权限使用红星中心")
	else
		print("[红星中心] 当前玩家 '" .. LocalPlayer.Name .. "' 不在白名单中")
	end
	return
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

local Red = Color3.fromHex("#FF3B30")
local Yellow = Color3.fromHex("#FFD60A")
local Grey = Color3.fromHex("#83889E")
local Blue = Color3.fromHex("#257AF7")
local Green = Color3.fromHex("#10C550")
local Purple = Color3.fromHex("#7775F2")

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

Window:Tag({
	Title = "红星中心 v" .. WindUI.Version,
	Icon = "github",
	Color = Red,
	Border = true,
})

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

-- // 音乐 Tab
local MusicTab = Window:Tab({
	Title = "音乐",
	Desc = "音乐播放器",
	Icon = "solar:folder-2-bold-duotone",
	IconColor = Red,
	IconShape = "Square",
	Border = true,
})

local MusicSection = MusicTab:Section({
	Title = "音乐播放器",
})

local currentSound = nil

local function playMusic(id)
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
	end
	currentSound = Instance.new("Sound")
	currentSound.SoundId = "rbxassetid://" .. id
	currentSound.Parent = game:GetService("SoundService")
	currentSound:Play()
end

MusicSection:Textbox({
	Title = "搜索音乐ID",
	Placeholder = "输入音乐ID",
	Callback = function(text)
		local id = tonumber(text)
		if id then
			playMusic(id)
		end
	end,
})

MusicSection:Button({
	Title = "停止播放",
	Color = Red,
	Callback = function()
		if currentSound then
			currentSound:Stop()
			currentSound:Destroy()
			currentSound = nil
		end
	end,
})

local MusicList = {
	{id = "74173898692517", name = "唐人"},
	{id = "82736875196779", name = "牵丝戏"},
	{id = "75361870687357", name = "辞九门"},
	{id = "132524361907107", name = "把回忆"},
	{id = "102072818475050", name = "李昊"},
	{id = "79277371759525", name = "雨爱"},
	{id = "78963341533467", name = "雨泪"},
	{id = "88304207692432", name = "武家坡"},
	{id = "103206233912047", name = "你好，知道犯什么"},
	{id = "109693244185458", name = "1Q00"},
	{id = "114372452919028", name = "山楂树"},
	{id = "89795630567186", name = "陈浩南"},
	{id = "100856301638837", name = "落泪"},
	{id = "117225633780122", name = "海底"},
	{id = "110803009828636", name = "张信哲"},
	{id = "83422989427201", name = "错位时空"},
	{id = "111568038897020", name = "求佛"},
	{id = "80487039269735", name = "悠闲"},
	{id = "124044109756641", name = "精卫"},
	{id = "111027647468458", name = "迷人的危险"},
	{id = "120145064597801", name = "安和桥"},
	{id = "78626388620444", name = "做事要讲良心"},
	{id = "126922220277198", name = "redeye"},
	{id = "118896961448948", name = "后继者"},
	{id = "107341259483191", name = "lovestory"},
	{id = "96590819329722", name = "会呼吸的痛"},
	{id = "125615482496831", name = "青衣"},
	{id = "114476517052805", name = "铡美案"},
	{id = "114476517052805", name = "铡美案"},
	{id = "138765729162919", name = "蜜雪"},
	{id = "128967751535556", name = "nig"},
	{id = "84348087757554", name = "嘉豪"},
	{id = "113879832755091", name = "大运"},
	{id = "113665010217108", name = "鸟之诗"},
	{id = "78707318606182", name = "大江大海"},
	{id = "79122285852432", name = "朋友的酒"},
	{id = "81381619096029", name = "小幸运"},
	{id = "116497979556639", name = "不得不爱"},
	{id = "112341295870756", name = "印度"},
	{id = "117642670292492", name = "我也不知道"},
	{id = "104923055259541", name = "你最近过的还好吗"},
	{id = "118957335322667", name = "共和时代"},
	{id = "135894830596180", name = "alone"},
	{id = "102757438805863", name = "骷髅"},
	{id = "113529393452088", name = "嘉豪"},
	{id = "2138529498012691", name = "豪大大"},
	{id = "119341948158777", name = "芒种"},
	{id = "110094177703357", name = "演员"},
	{id = "106036175444448", name = "红昭愿"},
	{id = "129089071772937", name = "桃花诺"},
	{id = "97285892199649", name = "把回忆"},
	{id = "81179274770282", name = "燕无歇"},
	{id = "93310151880263", name = "出山"},
	{id = "112834898401032", name = "离开我的依赖"},
	{id = "121374695318782", name = "彩虹小白马好像不能用了"},
	{id = "93898237895661", name = "得吃"},
	{id = "96144381780240", name = "拼好歌"},
	{id = "99498025749186", name = "起风了"},
	{id = "115023114157591", name = "辞九门"},
	{id = "132049153370517", name = "应该是莫问归期"},
	{id = "82518513365412", name = "川普"},
	{id = "1845918435", name = "国歌"},
	{id = "1840297174", name = "國歌"},
	{id = "124597524602869", name = "进步"},
	{id = "132772094469180", name = "游京"},
	{id = "103001052289903", name = "伤感"},
	{id = "3068736836", name = "教員"},
	{id = "121336636707861", name = "豪庭"},
	{id = "115262512648819", name = "漂移"},
	{id = "99519218846428", name = "科比"},
	{id = "130437050908450", name = "氛围"},
	{id = "138570939058838", name = "唯一"},
	{id = "134786908423441", name = "大东北"},
	{id = "124523430035974", name = "山歌"},
	{id = "5409360995", name = "新新"},
	{id = "3033155249", name = "悠闲"},
	{id = "135324082524426", name = "兰亭序"},
	{id = "126954452322127", name = "军中绿花"},
	{id = "89711807693889", name = "进击巨人"},
	{id = "91550314012338", name = "奈克赛斯主题曲"},
	{id = "93995930463751", name = "瞬DJ"},
	{id = "82485901858938", name = "小半原版"},
	{id = "79952652433579", name = "父亲"},
	{id = "99498025749186", name = "起风了di"},
	{id = "112834898401032", name = "离开我的依赖DJ"},
	{id = "79277371759525", name = "代码雨爱"},
	{id = "138570939058838", name = "唯一"},
	{id = "74180922359181", name = "啊米诺丝"},
	{id = "136536224579450", name = "冲刺"},
	{id = "80701295792893", name = "乌鲁鲁"},
	{id = "131309848078328", name = "buibuibui"},
	{id = "104923055259541", name = "还好吗"},
	{id = "99960601736776", name = "鸳鸯戏+1280"},
	{id = "98850529016454", name = "坠落"},
	{id = "87859225614251", name = "瓦瓦"},
	{id = "121832229737638", name = "猪妞"},
	{id = "124597524602869", name = "进步小曲"},
	{id = "95489036869789", name = "馕馕馕"},
	{id = "96590819329722", name = "会呼吸的痛"},
	{id = "110094177703357", name = "演员"},
	{id = "88457346646245", name = "福瑞"},
	{id = "134786908423441", name = "大东北"},
	{id = "132049153370517", name = "凌烈的刀锋出寒冬"},
	{id = "93898237895661", name = "得吃"},
	{id = "78626388620444", name = "讲良心"},
	{id = "102862957328067", name = "拜刀马"},
	{id = "100856301638837", name = "猜不透"},
	{id = "124384558101360", name = "辞九门回忆"},
	{id = "82152175089703", name = "单吃蛋"},
	{id = "132913406368504", name = "酒驾驾"},
	{id = "122569721737706", name = "哈喽大家好"},
	{id = "111431923179857", name = "我拿那个小刀"},
	{id = "132218995427356", name = "浴室"},
	{id = "109693244185458", name = "1Q00进行曲"},
	{id = "7418628592", name = "cnm"},
	{id = "132772094469180", name = "游京"},
	{id = "122407020110484", name = "爱情讯息DJ"},
	{id = "133260572775867", name = "萝莉进行曲炸麦"},
	{id = "78963341533467", name = "落泪"},
	{id = "124384558101360", name = "误闯天家DJ版"},
	{id = "111647270157086", name = "中长跑进行曲"},
	{id = "139960831487271", name = "晚安布布进行曲"},
	{id = "72230346939164", name = "库里之歌（柚子厨版）"},
	{id = "140648740956700", name = "苦茶子"},
	{id = "128815249670543", name = "大哥小曲哈基米版"},
	{id = "109138957141221", name = "情绪回收站FUNK"},
	{id = "117642670292492", name = "哈基米哦南北绿豆"},
	{id = "87918578744719", name = "大悲咒哈基米"},
	{id = "96491894597654", name = "灵感菇菇菇嘎嘎"},
	{id = "110019502835548", name = "donk哈基米"},
	{id = "78472074436234", name = "太空曼波"},
	{id = "80712503354465", name = "地狱列车"},
	{id = "95969253144150", name = "青衣Dj版"},
	{id = "8449305114", name = "嘲笑"},
	{id = "8324338507", name = "钢管落地"},
	{id = "115734731038400", name = "救救我"},
	{id = "117225633780122", name = "悲伤"},
	{id = "137981831377836", name = "我的假牙"},
	{id = "140248480403863", name = "moon"},
	{id = "131649148795563", name = "不值得Dj"},
	{id = "74085216274793", name = "寂寞"},
	{id = "111027647468458", name = "迷人的危险dj阿智"},
	{id = "130426362745916", name = "难得真兄弟 哈基米版"},
	{id = "81137321144573", name = "中长跑九万字"},
	{id = "74173898692517", name = "唐人恋曲"},
	{id = "114372452919028", name = "山楂树之恋"},
	{id = "126774078187195", name = "关注塔菲谢谢喵"},
	{id = "105743569519803", name = "休闲"},
	{id = "74941412980904", name = "森林"},
	{id = "1845962816", name = "新年"},
	{id = "119719716898695", name = "心做dj版"},
	{id = "88304207692432", name = "武家坡"},
	{id = "84177223761751", name = "原神丘丘谣"},
	{id = "82696338249251", name = "横冲直撞"},
	{id = "89795630567186", name = "陈浩南砍遍铜锣湾小曲"},
	{id = "94624102598882", name = "和平精英死亡音效"},
	{id = "110788401793874", name = "oioi"},
	{id = "132524361907107", name = "把回忆拼好给你"},
	{id = "7801102946", name = "大河之剑天上来"},
	{id = "7334239757", name = "你咋这么自私"},
	{id = "7309537814", name = "你是故意找茬是不是"},
	{id = "129921580107843", name = "童话镇"},
	{id = "125615482496831", name = "倩衣"},
	{id = "116016960263535", name = "器张"},
	{id = "97285892199649", name = "我们之间的回忆"},
	{id = "109386756896813", name = "不得不"},
	{id = "120145064597801", name = "安和桥"},
	{id = "82485901858938", name = "小半"},
	{id = "93310151880263", name = "出山DJ"},
	{id = "93995930463751", name = "瞬di"},
	{id = "110807176141277", name = "欢乐颂"},
}

for _, music in ipairs(MusicList) do
	MusicSection:Button({
		Title = music.name,
		Color = Blue,
		Callback = function()
			playMusic(music.id)
		end,
	})
end
