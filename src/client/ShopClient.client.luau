-- Loja e carteira (cliente) — compatível com celular (toque e telas pequenas)
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local Config = require(RS:WaitForChild("ShopConfig"))
local Remotes = RS:WaitForChild("Remotes")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local touch = UIS.TouchEnabled or (RunService:IsStudio() and workspace:GetAttribute("ForceTouch") == true)

local GOLD = Color3.fromRGB(235, 190, 80)
local TEXT = Color3.fromRGB(225, 220, 210)
local PANEL = Color3.fromRGB(16, 14, 14)
local ROBUX = Color3.fromRGB(60, 140, 90)

local wallet = {coins = 0, bat = 0, sta = 0, ste = 0, pilhas = 0, amuletos = 0}

local gui = Instance.new("ScreenGui")
gui.Name = "ShopGui"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local function make(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end
local function corner(o, r) make("UICorner", {CornerRadius = UDim.new(0, r or 6)}, o) end

-- moedas no HUD (canto superior direito; maior no celular)
local coinsBtn = make("TextButton", {
	Name = "Coins", Size = touch and UDim2.fromOffset(230, 48) or UDim2.fromOffset(190, 36),
	Position = UDim2.new(1, -16, 0, 16), AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = PANEL, BackgroundTransparency = 0.25, TextColor3 = GOLD, Font = Enum.Font.SpecialElite,
	TextSize = touch and 22 or 20, Text = touch and "0 moedas  [LOJA]" or "0 moedas  [B]", AutoButtonColor = true,
}, gui)
corner(coinsBtn, 8)

-- painel (encolhe para caber em telas pequenas)
local panel = make("Frame", {
	Name = "Panel", Size = UDim2.fromOffset(580, 440), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = PANEL, BackgroundTransparency = 0.05, Visible = false,
}, gui)
corner(panel, 10)
make("UIStroke", {Color = Color3.fromRGB(80, 60, 40), Thickness = 2}, panel)
local fit = make("UIScale", {}, panel)
local function refit()
	local v = camera.ViewportSize
	fit.Scale = math.clamp(math.min(v.X * 0.95 / 580, v.Y * 0.94 / 440), 0.5, 1)
end
refit(); camera:GetPropertyChangedSignal("ViewportSize"):Connect(refit)

-- botão modal libera o mouse da câmera em primeira pessoa
make("TextButton", {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, Text = "", Modal = true}, panel)

make("TextLabel", {
	Size = UDim2.new(1, -80, 0, 44), Position = UDim2.fromOffset(20, 6), BackgroundTransparency = 1, TextColor3 = TEXT,
	Font = Enum.Font.SpecialElite, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Left, Text = "Armazém do Zelador",
}, panel)
local closeBtn = make("TextButton", {
	Size = UDim2.fromOffset(48, 48), Position = UDim2.new(1, -56, 0, 6), BackgroundColor3 = Color3.fromRGB(60, 25, 25),
	TextColor3 = TEXT, Font = Enum.Font.SpecialElite, TextSize = 22, Text = "X",
}, panel)
corner(closeBtn, 6)

local balance = make("TextLabel", {
	Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(20, 50), BackgroundTransparency = 1, TextColor3 = GOLD,
	Font = Enum.Font.SpecialElite, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Text = "",
}, panel)

local list = make("ScrollingFrame", {
	Size = UDim2.new(1, -30, 1, -100), Position = UDim2.fromOffset(15, 78), BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 8, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, panel)
make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)

local order = 0
local function header(text)
	order += 1
	make("TextLabel", {
		Size = UDim2.new(1, -10, 0, 26), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 140, 125),
		Font = Enum.Font.SpecialElite, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Text = text, LayoutOrder = order,
	}, list)
end

local status = make("TextLabel", {
	Size = UDim2.new(1, -40, 0, 20), Position = UDim2.new(0, 20, 1, -22), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(190, 120, 120),
	Font = Enum.Font.SpecialElite, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Text = "",
}, panel)

local function say(text, good)
	status.TextColor3 = good and Color3.fromRGB(130, 200, 140) or Color3.fromRGB(200, 120, 120)
	status.Text = text
end

-- linha da loja (botão de 44 px de altura: alvo de toque confortável)
local function row(title, desc, btnText, btnColor, enabled, onClick)
	order += 1
	local r = make("Frame", {Size = UDim2.new(1, -10, 0, 64), BackgroundColor3 = Color3.fromRGB(28, 25, 24), LayoutOrder = order}, list)
	corner(r, 6)
	make("TextLabel", {
		Size = UDim2.new(1, -180, 0, 26), Position = UDim2.fromOffset(12, 6), BackgroundTransparency = 1, TextColor3 = TEXT,
		Font = Enum.Font.SpecialElite, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Text = title,
	}, r)
	make("TextLabel", {
		Size = UDim2.new(1, -180, 0, 22), Position = UDim2.fromOffset(12, 34), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 145, 135),
		Font = Enum.Font.SpecialElite, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Text = desc,
	}, r)
	local b = make("TextButton", {
		Size = UDim2.fromOffset(150, 44), Position = UDim2.new(1, -160, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = enabled and btnColor or Color3.fromRGB(50, 48, 46), TextColor3 = enabled and Color3.new(1, 1, 1) or Color3.fromRGB(130, 128, 125),
		Font = Enum.Font.SpecialElite, TextSize = 16, Text = btnText, AutoButtonColor = enabled,
	}, r)
	corner(b, 6)
	if enabled then b.Activated:Connect(onClick) end
end

local function buy(action, id)
	local ok, msg = Remotes.ShopAction:InvokeServer(action, id)
	say(msg or "", ok)
end

local function rebuild()
	for _, c in ipairs(list:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
	order = 0
	balance.Text = ("Moedas: %d     Pilhas: %d     Amuletos: %d"):format(wallet.coins, wallet.pilhas, wallet.amuletos)
	coinsBtn.Text = wallet.coins .. (touch and " moedas  [LOJA]" or " moedas  [B]")

	header("MELHORIAS  (compre com moedas ganhas jogando)")
	for _, k in ipairs({{"battery", "bat"}, {"stamina", "sta"}, {"stealth", "ste"}}) do
		local up, lvl = Config.Upgrades[k[1]], wallet[k[2]]
		local maxed = lvl >= Config.MaxLevel
		local cost = up.costs[lvl + 1]
		row(("%s  (nível %d/%d)"):format(up.name, lvl, Config.MaxLevel), up.desc,
			maxed and "MÁXIMO" or (cost .. " moedas"), GOLD:Lerp(Color3.new(0, 0, 0), 0.5),
			not maxed and wallet.coins >= cost, function() buy("upgrade", k[1]) end)
	end

	header("ITENS")
	for _, id in ipairs({"battery", "amulet"}) do
		local it = Config.Items[id]
		local have = id == "battery" and wallet.pilhas or wallet.amuletos
		local full = have >= it.max
		row(("%s  (%d/%d)"):format(it.name, have, it.max), it.desc,
			full and "CHEIO" or (it.cost .. " moedas"), GOLD:Lerp(Color3.new(0, 0, 0), 0.5),
			not full and wallet.coins >= it.cost, function() buy("item", id) end)
	end

	header("PACOTES DE MOEDAS  (opcional · Robux)")
	for _, pk in ipairs(Config.CoinPacks) do
		local title = ("%s  +%d"):format(pk.name, pk.coins)
		if pk.id == 0 then row(title, "Atalho para melhorias e itens.", "Em breve", ROBUX, false)
		else row(title, "Atalho para melhorias e itens.", "Comprar (Robux)", ROBUX, true, function() MarketplaceService:PromptProductPurchase(player, pk.id) end) end
	end
end

local function setOpen(open)
	panel.Visible = open
	if open then status.Text = ""; rebuild() end
end

Remotes.Wallet.OnClientEvent:Connect(function(w)
	wallet = w
	rebuild()
end)

coinsBtn.Activated:Connect(function() setOpen(not panel.Visible) end)
closeBtn.Activated:Connect(function() setOpen(false) end)
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.B then setOpen(not panel.Visible)
	elseif input.KeyCode == Enum.KeyCode.Escape and panel.Visible then setOpen(false) end
end)

rebuild()
Remotes.ClientReady:FireServer()
