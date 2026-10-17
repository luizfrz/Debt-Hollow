-- Economia: moedas, melhorias, itens, recompensa diária e pacotes de moedas (Robux)
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")

local Config = require(RS:WaitForChild("ShopConfig"))
local Remotes = RS:WaitForChild("Remotes")
local Award = SS:WaitForChild("Award")
local TryRevive = SS:WaitForChild("TryRevive")

-- em jogo não publicado GetDataStore lança erro; sem store o progresso vale só na sessão
local okStore, store = pcall(function() return DataStoreService:GetDataStore("HollowManor_v1") end)
if not okStore then store = nil end
local DEFAULT = {coins = 0, bat = 0, sta = 0, ste = 0, pilhas = 1, amuletos = 0, escapes = 0, streak = 0, lastDay = 0}

local data, storeOK = {}, {}

local function copy(t) local c = {} for k, v in pairs(t) do c[k] = v end return c end

local function push(pl)
	local d = data[pl]
	if not d then return end
	pl:SetAttribute("BatteryLevel", d.bat)
	pl:SetAttribute("StaminaLevel", d.sta)
	pl:SetAttribute("Stealth", d.ste)
	pl:SetAttribute("Amulets", d.amuletos)
	pl:SetAttribute("Batteries", d.pilhas)
	local ls = pl:FindFirstChild("leaderstats")
	if ls then ls.Moedas.Value = d.coins; ls.Fugas.Value = d.escapes end
	Remotes.Wallet:FireClient(pl, {coins = d.coins, bat = d.bat, sta = d.sta, ste = d.ste, pilhas = d.pilhas, amuletos = d.amuletos})
end

local function save(pl)
	if not storeOK[pl] or not data[pl] then return true end
	local ok, err = pcall(function() store:SetAsync("P_" .. pl.UserId, data[pl]) end)
	if not ok then warn("[Economy] falha ao salvar " .. pl.Name .. ": " .. tostring(err)) end
	return ok
end

local function notify(pl, text, dur) Remotes.Notify:FireClient(pl, text, dur or 4) end

local function addCoins(pl, amount)
	local d = data[pl]; if not d then return 0 end
	d.coins += amount
	push(pl)
	return amount
end

---------------------------------------------------------------------
-- Carregar / recompensa diária
---------------------------------------------------------------------
local function dailyReward(pl)
	local d = data[pl]
	local today = math.floor(os.time() / 86400)
	if d.lastDay == today then return end
	if d.lastDay == today - 1 then d.streak = d.streak % #Config.Daily + 1 else d.streak = 1 end
	d.lastDay = today
	local amount = Config.Daily[d.streak]
	d.coins += amount
	local msg = ("Recompensa diária (dia %d): +%d moedas"):format(d.streak, amount)
	if d.streak == #Config.Daily then
		d.pilhas = math.min(Config.Items.battery.max, d.pilhas + Config.DailyBonusBatteries)
		msg ..= (" e +%d pilhas!"):format(Config.DailyBonusBatteries)
	else
		msg ..= (" — volte amanhã por mais (%d/%d)"):format(d.streak, #Config.Daily)
	end
	task.delay(9, function() if pl.Parent then notify(pl, msg, 6) end end)
end

Players.PlayerAdded:Connect(function(pl)
	local ls = Instance.new("Folder"); ls.Name = "leaderstats"
	local c = Instance.new("IntValue"); c.Name = "Moedas"; c.Parent = ls
	local e = Instance.new("IntValue"); e.Name = "Fugas"; e.Parent = ls
	ls.Parent = pl

	local ok, saved = pcall(function() return store:GetAsync("P_" .. pl.UserId) end)
	local d = copy(DEFAULT)
	if ok then
		storeOK[pl] = true
		if type(saved) == "table" then for k, v in pairs(saved) do d[k] = v end end
	else
		warn("[Economy] DataStore indisponível (ative 'Enable Studio Access to API Services'): progresso desta sessão não será salvo.")
	end
	data[pl] = d
	dailyReward(pl)
	push(pl)
end)

Players.PlayerRemoving:Connect(function(pl)
	save(pl)
	data[pl] = nil; storeOK[pl] = nil
end)

game:BindToClose(function()
	for _, pl in ipairs(Players:GetPlayers()) do save(pl) end
end)

task.spawn(function()
	while true do
		task.wait(60)
		for _, pl in ipairs(Players:GetPlayers()) do save(pl) end
	end
end)

Remotes.ClientReady.OnServerEvent:Connect(push)

---------------------------------------------------------------------
-- Recompensas por eventos do jogo (vindas do Match)
---------------------------------------------------------------------
Award.Event:Connect(function(pl, kind)
	if not data[pl] then return end
	local R = Config.Reward
	-- item e objetivo não enviam aviso: o contador de moedas do HUD já mostra o ganho,
	-- e o aviso não pode cobrir o texto da história (páginas, velas, gerador).
	if kind == "fuse" then
		addCoins(pl, R.fuse)
	elseif kind == "generator" then
		addCoins(pl, R.generator)
	elseif kind == "phase" then
		local got = addCoins(pl, R.phase)
		task.delay(7, function() if pl.Parent then notify(pl, ("Fase concluída! +%d moedas"):format(got), 3) end end)
	elseif kind == "win" then
		local got = addCoins(pl, R.win)
		data[pl].escapes += 1
		push(pl)
		save(pl)
		task.delay(2, function() if pl.Parent then notify(pl, ("Dívida quitada! +%d moedas"):format(got), 5) end end)
	end
end)

TryRevive.OnInvoke = function(pl)
	local d = data[pl]
	if d and d.amuletos > 0 then
		d.amuletos -= 1
		push(pl)
		return true
	end
	return false
end

---------------------------------------------------------------------
-- Loja (compras com moedas)
---------------------------------------------------------------------
local levelKey = {battery = "bat", stamina = "sta", stealth = "ste"}

Remotes.ShopAction.OnServerInvoke = function(pl, action, id)
	local d = data[pl]
	if not d then return false, "Dados ainda carregando." end

	if action == "upgrade" then
		local up, key = Config.Upgrades[id], levelKey[id]
		if not up then return false, "Item inválido." end
		local lvl = d[key]
		if lvl >= Config.MaxLevel then return false, "Nível máximo." end
		local cost = up.costs[lvl + 1]
		if d.coins < cost then return false, "Moedas insuficientes." end
		d.coins -= cost; d[key] = lvl + 1
		push(pl); save(pl)
		return true, up.name .. " nível " .. (lvl + 1)

	elseif action == "item" then
		local it = Config.Items[id]
		if not it then return false, "Item inválido." end
		local key = id == "battery" and "pilhas" or "amuletos"
		if d[key] >= it.max then return false, "Você já carrega o máximo." end
		if d.coins < it.cost then return false, "Moedas insuficientes." end
		d.coins -= it.cost; d[key] += 1
		push(pl); save(pl)
		return true, it.name .. " comprado."
	end
	return false, "Ação inválida."
end

Remotes.UseBattery.OnServerEvent:Connect(function(pl)
	local d = data[pl]
	if d and d.pilhas > 0 then
		d.pilhas -= 1
		push(pl)
		Remotes.Recharge:FireClient(pl)
	end
end)

---------------------------------------------------------------------
-- Robux: pacotes de moedas (Developer Products)
---------------------------------------------------------------------
MarketplaceService.ProcessReceipt = function(info)
	local pl = Players:GetPlayerByUserId(info.PlayerId)
	if not pl or not data[pl] then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local pack
	for _, p in ipairs(Config.CoinPacks) do
		if p.id ~= 0 and p.id == info.ProductId then pack = p end
	end
	if not pack then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local d = data[pl]
	d.rcpt = d.rcpt or {}
	if not d.rcpt[info.PurchaseId] then
		d.coins += pack.coins
		d.rcpt[info.PurchaseId] = true -- evita entregar duas vezes se o salvamento falhar
	end
	push(pl)
	if storeOK[pl] and not save(pl) then return Enum.ProductPurchaseDecision.NotProcessedYet end
	notify(pl, ("+%d moedas. Obrigado!"):format(pack.coins), 4)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
