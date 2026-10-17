-- A DÍVIDA DE HOLLOW — lobby, salas de fila (2/3/6), partidas em 3 fases
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Remotes = RS:WaitForChild("Remotes")
local Award = SS:WaitForChild("Award")
local TryRevive = SS:WaitForChild("TryRevive")
local Entities = require(script.Parent:WaitForChild("Entities"))
local Levels = workspace:WaitForChild("Levels")
local Lobby = workspace:WaitForChild("Lobby")

Players.CharacterAutoLoads = false

---------------------------------------------------------------------
-- História: textos das páginas e velas
---------------------------------------------------------------------
local PAGES = {
	"Cláusula I — \"Eu, Augustus Hollow, cedo ao Credor os anos de minha filha Clara, em troca de sua vida.\"",
	"Cláusula II — \"Cada geração Hollow pagará uma alma. Se faltar sangue, o Credor aceita hóspedes.\"  Na margem, a letra de Eleanora: \"Ele trouxe os pacientes para o porão. Os gritos pararam.\"",
	"Diário da enfermeira Voss — \"Costurei meus olhos para não ver o que fiz. Depois a boca, para não contar. Agora só escuto. O Credor disse que o silêncio é a quitação.\"",
	"Cláusula III — \"Quem ler estas páginas assume a dívida de quem não puder pagá-la.\"  Embaixo, em tinta fresca, estão os seus nomes.",
}
local CANDLES = {
	"Vela de Augustus — \"Fui eu quem assinou. Perdoe-me, Clara.\"",
	"Vela de Eleanora — \"Queime o papel. Mesmo que eu seja a última a ver.\"",
	"Vela de Clara — \"Eu ainda estou aqui. Quando você olha para mim, eu fico quietinha.\"",
}

local LOBBY_LIGHT = {fogStart = 30, fogEnd = 260, fog = {14, 10, 12}, ambient = {36, 28, 30}, tint = {235, 220, 215}, atmo = 0.3}

local PHASES = {
	{id = 1, level = "Fase1", title = "O SAGUÃO", sub = "A energia da mansão morreu há cem anos. Religue-a.",
		item = "fuse", itemLabel = "Fusíveis", count = 5, centerObj = "Gerador", centerAction = "Inserir fusíveis", holdSec = 1.5,
		deliverText = "Leve os fusíveis ao gerador (centro)", exitText = "Fuja pela porta a leste!",
		doneMsg = "O GERADOR LIGOU! A porta do porão está abrindo... ELA SABE ONDE VOCÊ ESTÁ. CORRA!",
		entities = {"clara"}, grace = 30,
		hint = "Fusíveis brilham no escuro. Clara só se move quando ninguém olha. Armários (E) escondem você.",
		light = {fogStart = 10, fogEnd = 90, fog = {8, 8, 10}, ambient = {10, 10, 14}, tint = {215, 225, 235}, atmo = 0.55}},
	{id = 2, level = "Fase2", title = " O SANATÓRIO", sub = "Os pacientes nunca saíram. Eleanora ainda os procura.",
		item = "page", itemLabel = "Páginas", count = 4, centerObj = "Incinerador", centerAction = "Queimar páginas", holdSec = 2,
		deliverText = "Queime as páginas no incinerador (centro)", exitText = "Fuja pela porta a leste!",
		doneMsg = "A FORNALHA RUGE! Ela ouviu... não há mais silêncio que te proteja. CORRA!",
		entities = {"eleanora"}, grace = 30,
		hint = "Eleanora chora e só ouve: Ande devagar, agache (C) e não corra perto dela.",
		light = {fogStart = 10, fogEnd = 85, fog = {10, 16, 14}, ambient = {10, 16, 14}, tint = {205, 235, 220}, atmo = 0.6}},
	{id = 3, level = "Fase3", title = "A CRIPTA", sub = "Aqui começou. Aqui termina.",
		item = "candle", itemLabel = "Velas", count = 3, centerObj = "Altar", centerAction = "Romper o contrato", holdSec = 4,
		deliverText = "Leve as velas ao altar (centro)", exitText = "Clara voltou. Fuja pelo portão leste!",
		doneMsg = "O CONTRATO ARDE! O Credor não aceita perder... Clara está vindo. CORRA PELO PORTÃO!",
		entities = {"augustus", "coro"}, grace = 30, finale = "clara",
		hint = "Augustus vê e ouve você. Quando as luzes piscarem e as vozes chegarem: esconda-se.",
		light = {fogStart = 8, fogEnd = 75, fog = {16, 6, 6}, ambient = {16, 8, 8}, tint = {240, 205, 200}, atmo = 0.65}},
}

---------------------------------------------------------------------
-- Estado
---------------------------------------------------------------------
local match = nil -- {players = {[Player]=true}, mode = string, state = ..., ctrl = ...}
local caught, hidden, sprinting, crouching = {}, {}, {}, {}
local hiddenAt = {}

local function hum(pl)
	local ch = pl.Character
	return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function hrpOf(pl)
	local ch = pl.Character
	return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function eachMatchPlayer(fn)
	if not match then return end
	for pl in pairs(match.players) do if pl.Parent then fn(pl) end end
end
local function notifyAll(text, dur)
	eachMatchPlayer(function(pl) Remotes.Notify:FireClient(pl, text, dur or 4) end)
end
local function aliveList()
	local l = {}
	eachMatchPlayer(function(pl)
		local h = hum(pl)
		if h and h.Health > 0 and not caught[pl] then table.insert(l, pl) end
	end)
	return l
end

local function applySpeed(pl)
	local h = hum(pl)
	if not h or caught[pl] or hidden[pl] then return end
	h.WalkSpeed = sprinting[pl] and 21 or (crouching[pl] and 7 or 13)
end

local function setCharVisible(ch, vis)
	for _, d in ipairs(ch:GetDescendants()) do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then d.Transparency = vis and 0 or 1
		elseif d:IsA("Decal") then d.Transparency = vis and 0 or 1 end
	end
end

---------------------------------------------------------------------
-- Armários (esconderijos)
---------------------------------------------------------------------
local function unhide(pl)
	local locker = hidden[pl]
	if not locker then return end
	hidden[pl] = nil
	locker:SetAttribute("Occupant", nil)
	pl:SetAttribute("Hidden", false)
	local prompt = locker:FindFirstChildOfClass("ProximityPrompt")
	if prompt then prompt.ActionText = "Esconder-se" end
	local ch, hrp = pl.Character, hrpOf(pl)
	if ch and hrp then
		hrp.Anchored = false
		local face = locker:GetAttribute("Facing") or Vector3.new(1, 0, 0)
		local out = Vector3.new(locker.Position.X, 3, locker.Position.Z) + face * 4.5
		ch:PivotTo(CFrame.lookAt(out, out + face))
		setCharVisible(ch, true)
	end
	applySpeed(pl)
end

local function hide(pl, locker)
	local h, hrp = hum(pl), hrpOf(pl)
	if not h or not hrp or h.Health <= 0 or caught[pl] or hidden[pl] then return end
	if locker:GetAttribute("Occupant") then Remotes.Notify:FireClient(pl, "O armário está ocupado.", 2) return end
	hidden[pl] = locker
	hiddenAt[pl] = os.clock()
	locker:SetAttribute("Occupant", pl.UserId)
	pl:SetAttribute("Hidden", true)
	local prompt = locker:FindFirstChildOfClass("ProximityPrompt")
	if prompt then prompt.ActionText = "Sair" end
	local face = locker:GetAttribute("Facing") or Vector3.new(1, 0, 0)
	local inside = Vector3.new(locker.Position.X, 3, locker.Position.Z)
	hrp.AssemblyLinearVelocity = Vector3.zero
	pl.Character:PivotTo(CFrame.lookAt(inside, inside + face))
	hrp.Anchored = true
	setCharVisible(pl.Character, false)
end

---------------------------------------------------------------------
-- Captura (usada pelas criaturas)
---------------------------------------------------------------------
local function catchPlayer(pl, kind)
	if caught[pl] then return "dead" end
	if TryRevive:Invoke(pl) then -- Amuleto Protetor
		unhide(pl)
		Remotes.Notify:FireClient(pl, "O Amuleto Protetor se desfez... e ela recuou.", 4)
		return "saved"
	end
	caught[pl] = true
	unhide(pl)
	local h = hum(pl)
	if h then h.WalkSpeed = 0; h.JumpHeight = 0 end
	Remotes.Jumpscare:FireClient(pl, kind)
	task.delay(1.7, function()
		local h2 = hum(pl)
		if h2 then h2.Health = 0 end
	end)
	return "dead"
end

-- contexto entregue às criaturas
local ctx = {}
function ctx.getTargets()
	local list = {}
	for pl in pairs(match and match.players or {}) do
		local h, hrp = hum(pl), hrpOf(pl)
		if h and hrp and h.Health > 0 and not caught[pl] and not hidden[pl] then
			local v = hrp.AssemblyLinearVelocity
			local moving = Vector3.new(v.X, 0, v.Z).Magnitude > 3
			local noise
			if moving and sprinting[pl] then noise = 34
			elseif moving then noise = crouching[pl] and 5 or 14
			else noise = 3 end
			noise *= 1 - 0.12 * (pl:GetAttribute("Stealth") or 0)
			table.insert(list, {pl = pl, hum = h, root = hrp, ch = pl.Character, noise = noise})
		end
	end
	return list
end
function ctx.getHidden()
	local list = {}
	for pl, locker in pairs(hidden) do table.insert(list, {pl = pl, locker = locker}) end
	return list
end
function ctx.catch(pl, kind) return catchPlayer(pl, kind) end
function ctx.notify(text, dur) notifyAll(text, dur) end
function ctx.chase(v) eachMatchPlayer(function(pl) Remotes.Chase:FireClient(pl, v) end) end
local rushActive = false -- o Coro está vindo ou passando: ninguém sai do armário
function ctx.rush(stage)
	if stage == "warn" then rushActive = true elseif stage == "end" then rushActive = false end
	eachMatchPlayer(function(pl) Remotes.Rush:FireClient(pl, stage) end)
end

---------------------------------------------------------------------
-- Itens e objetivo da fase
---------------------------------------------------------------------
local function updateObjective(P, st)
	local text
	if st.opened then text = P.exitText
	elseif st.collected >= P.count then text = P.deliverText
	else text = ("%s: %d/%d"):format(P.itemLabel, st.collected, P.count) end
	eachMatchPlayer(function(pl) Remotes.Objective:FireClient(pl, text) end)
end

local function makeItem(kind, pos)
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false
	if kind == "fuse" then
		p.Name = "Fuse"; p.Size = Vector3.new(0.9, 1.8, 0.9); p.Shape = Enum.PartType.Cylinder
		p.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
		p.Material = Enum.Material.Neon; p.Color = Color3.fromRGB(255, 205, 80)
		local l = Instance.new("PointLight"); l.Color = p.Color; l.Range = 9; l.Brightness = 1.2; l.Parent = p
	elseif kind == "page" then
		p.Name = "Page"; p.Size = Vector3.new(1.4, 0.06, 1.9)
		p.CFrame = CFrame.new(pos.X, 0.15, pos.Z) * CFrame.Angles(0, math.rad(math.random(0, 359)), 0)
		p.Material = Enum.Material.Neon; p.Color = Color3.fromRGB(225, 222, 205)
		local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(190, 215, 255); l.Range = 8; l.Brightness = 0.9; l.Parent = p
	else
		p.Name = "Candle"; p.Size = Vector3.new(1.6, 0.5, 0.5); p.Shape = Enum.PartType.Cylinder
		p.CFrame = CFrame.new(pos.X, 0.8, pos.Z) * CFrame.Angles(0, 0, math.rad(90))
		p.Material = Enum.Material.SmoothPlastic; p.Color = Color3.fromRGB(14, 12, 14)
		local flame = Instance.new("Part")
		flame.Name = "Flame"; flame.Shape = Enum.PartType.Ball; flame.Size = Vector3.new(0.4, 0.6, 0.4)
		flame.Material = Enum.Material.Neon; flame.Color = Color3.fromRGB(255, 150, 50)
		flame.Anchored = true; flame.CanCollide = false; flame.CFrame = CFrame.new(pos.X, 1.8, pos.Z)
		flame.Parent = p
		local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 150, 60); l.Range = 12; l.Brightness = 1.4; l.Parent = flame
	end
	return p
end

local ITEM_LABELS = {fuse = {"Fusível", "Pegar"}, page = {"Página rasgada", "Ler"}, candle = {"Vela negra", "Pegar"}}

---------------------------------------------------------------------
-- Uma fase
---------------------------------------------------------------------
local function placePlayers(level)
	local base = level.Spawn.Position
	local remaining, i = 0, 0
	eachMatchPlayer(function(pl)
		i += 1; remaining += 1
		local idx = i
		task.spawn(function()
			caught[pl] = nil; sprinting[pl] = nil; crouching[pl] = nil; hidden[pl] = nil
			pl:SetAttribute("Hidden", false)
			pl:LoadCharacter()
			local ch = pl.Character or pl.CharacterAdded:Wait()
			ch:WaitForChild("HumanoidRootPart")
			ch:PivotTo(CFrame.new(base + Vector3.new(((idx - 1) % 3 - 1) * 3, 3, math.floor((idx - 1) / 3) * 3)))
			remaining -= 1
		end)
	end)
	local t0 = os.clock()
	while remaining > 0 and os.clock() - t0 < 8 do task.wait(0.1) end
end

local function inZone(zone, pos)
	local rel = zone.CFrame:PointToObjectSpace(pos)
	return math.abs(rel.X) <= zone.Size.X / 2 and math.abs(rel.Z) <= zone.Size.Z / 2
end

local function runPhase(P)
	local level = Levels[P.level]
	local st = {collected = 0, opened = false}
	match.state = st
	local conns, items = {}, {}
	local gate, center = level.Gate, level.Center
	local indicator = level:FindFirstChild("Indicator")

	-- cartão de título (a tela escurece, o servidor teleporta, o cartão aparece)
	eachMatchPlayer(function(pl)
		Remotes.Phase:FireClient(pl, {id = P.id, title = P.title, sub = P.sub, hold = 5, light = P.light})
		Remotes.Objective:FireClient(pl, ("%s: 0/%d"):format(P.itemLabel, P.count))
	end)
	task.wait(1.6)
	placePlayers(level)

	-- reset do cenário
	gate.CFrame = gate:GetAttribute("ClosedCF")
	if indicator then indicator.Color = indicator:GetAttribute("OffColor") end
	for _, f in ipairs(level:GetChildren()) do
		if f.Name == "Flame" then f.Transparency = 1; local l = f:FindFirstChildOfClass("PointLight"); if l then l.Enabled = false end end
	end

	-- armários
	for _, lk in ipairs(level.Lockers:GetChildren()) do
		if lk.Name == "Locker" then
			lk:SetAttribute("Occupant", nil)
			local prompt = lk:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				prompt.ActionText = "Esconder-se"
				table.insert(conns, prompt.Triggered:Connect(function(pl)
					if not match or not match.players[pl] then return end
					if hidden[pl] == lk then unhide(pl)
					elseif not hidden[pl] then hide(pl, lk) end
				end))
			end
		end
	end

	-- itens espalhados
	local spots = level.Spots:GetChildren()
	for i = #spots, 2, -1 do local j = math.random(1, i); spots[i], spots[j] = spots[j], spots[i] end
	for i = 1, P.count do
		local item = makeItem(P.item, spots[i].Position)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = ITEM_LABELS[P.item][1]; prompt.ActionText = ITEM_LABELS[P.item][2]
		prompt.HoldDuration = 0.6; prompt.MaxActivationDistance = 7; prompt.RequiresLineOfSight = false
		prompt.Parent = item
		table.insert(conns, prompt.Triggered:Connect(function(pl)
			if not item.Parent or not match or not match.players[pl] or caught[pl] or hidden[pl] then return end
			item:Destroy()
			st.collected += 1
			Award:Fire(pl, "fuse")
			local n = st.collected
			if P.item == "page" then notifyAll(PAGES[n], 11)
			elseif P.item == "candle" then notifyAll(CANDLES[n], 9)
			else notifyAll(("Fusível encontrado (%d/%d)"):format(n, P.count), 3) end
			updateObjective(P, st)
		end))
		item.Parent = level
		table.insert(items, item)
	end

	-- criaturas
	local ctrl = Entities.start(level, P.entities, ctx, {grace = P.grace, rushFirst = 50})
	match.ctrl = ctrl

	-- ponto de entrega (gerador / incinerador / altar)
	local cp = Instance.new("ProximityPrompt")
	cp.ObjectText = P.centerObj; cp.ActionText = P.centerAction
	cp.HoldDuration = P.holdSec; cp.MaxActivationDistance = 8; cp.RequiresLineOfSight = false
	cp.Parent = center
	table.insert(conns, cp.Triggered:Connect(function(pl)
		if st.opened or not match or not match.players[pl] or caught[pl] or hidden[pl] then return end
		if st.collected < P.count then
			notifyAll(("Faltam %d ítens: %s."):format(P.count - st.collected, string.lower(P.itemLabel)), 3)
			return
		end
		st.opened = true
		Award:Fire(pl, "generator")
		cp:Destroy()
		if indicator then indicator.Color = indicator:GetAttribute("OnColor") end
		for _, f in ipairs(level:GetChildren()) do
			if f.Name == "Flame" then f.Transparency = 0; local l = f:FindFirstChildOfClass("PointLight"); if l then l.Enabled = true end end
		end
		TweenService:Create(gate, TweenInfo.new(5, Enum.EasingStyle.Quad), {CFrame = gate:GetAttribute("ClosedCF") + Vector3.new(0, 10.5, 0)}):Play()
		notifyAll(P.doneMsg, 7)
		ctrl:SetRage(true)
		if P.finale then ctrl:Spawn(P.finale, {grace = 3}) end
		updateObjective(P, st)
	end))

	task.wait(4) -- cartão de título na tela
	eachMatchPlayer(function(pl) Remotes.Notify:FireClient(pl, P.hint, 8) end)

	-- espera: objetivo → saída
	local result, zoneDeadline
	while true do
		task.wait(0.3)
		local alive = aliveList()
		if #alive == 0 then result = false; break end
		if st.opened then
			local inside = 0
			for _, pl in ipairs(alive) do
				local hrp = hrpOf(pl)
				if hrp and inZone(level.ExitZone, hrp.Position) then inside += 1 end
			end
			if inside > 0 and not zoneDeadline then
				zoneDeadline = os.clock() + 12
				if inside < #alive then notifyAll("Alguém chegou à saída. Os outros têm 12 segundos!", 4) end
			end
			if inside == #alive or (zoneDeadline and os.clock() > zoneDeadline) then result = true; break end
		end
	end

	-- limpeza
	ctrl:Stop(); match.ctrl = nil
	for _, c in ipairs(conns) do c:Disconnect() end
	for _, it in ipairs(items) do if it.Parent then it:Destroy() end end
	if cp.Parent then cp:Destroy() end
	eachMatchPlayer(function(pl) unhide(pl) end)
	gate.CFrame = gate:GetAttribute("ClosedCF")
	return result
end

---------------------------------------------------------------------
-- Partida
---------------------------------------------------------------------
local function toLobby(pl)
	pl:SetAttribute("InMatch", false); pl:SetAttribute("Hidden", false)
	caught[pl] = nil; hidden[pl] = nil; sprinting[pl] = nil; crouching[pl] = nil
	task.spawn(function() pl:LoadCharacter() end)
end

local function endMatch(win)
	local m = match
	local title = win and "A DÍVIDA FOI QUITADA" or "A DÍVIDA PERMANECE"
	local body = win
		and "O contrato queimou. Em algum lugar, uma menina finalmente parou de sorrir.\n\n...Mas a carta nunca disse quem a escreveu."
		or "O Credor guarda os seus nomes. Ele é paciente.\nToda herança tem um preço."
	for pl in pairs(m.players) do
		if pl.Parent then
			Remotes.Result:FireClient(pl, win, title, body)
			if win then Award:Fire(pl, "win") end
		end
	end
	task.wait(10)
	for pl in pairs(m.players) do
		if pl.Parent then Remotes.Phase:FireClient(pl, {id = 0, light = LOBBY_LIGHT, title = "O ÁTRIO", sub = "Você sobreviveu... por enquanto.", hold = 3}) end
	end
	task.wait(1.6)
	for pl in pairs(m.players) do if pl.Parent then toLobby(pl) end end
	match = nil
end

local function runMatch(startPhase)
	local won = true
	for idx, P in ipairs(PHASES) do
		if idx < (startPhase or 1) then continue end
		local ok = runPhase(P)
		if not ok then won = false; break end
		eachMatchPlayer(function(pl) Award:Fire(pl, "phase") end)
	end
	endMatch(won)
end

local function startMatch(list, modeName, startPhase)
	if match then return end
	match = {players = {}, mode = modeName}
	for _, pl in ipairs(list) do
		match.players[pl] = true
		pl:SetAttribute("InMatch", true)
	end
	task.spawn(runMatch, startPhase)
end

-- gancho para testes e para outros sistemas
local startEvent = Instance.new("BindableEvent")
startEvent.Name = "StartMatch"; startEvent.Parent = SS
startEvent.Event:Connect(function(list, name, startPhase) startMatch(list, name or "TESTE", startPhase) end)

if RunService:IsStudio() then -- comandos de depuração (só no Studio)
	local dbg = Instance.new("BindableFunction")
	dbg.Name = "DebugCmd"; dbg.Parent = SS
	dbg.OnInvoke = function(cmd)
		if not match or not match.state then return "sem partida" end
		if cmd == "state" then
			return string.format("collected=%d opened=%s alive=%d", match.state.collected, tostring(match.state.opened), #aliveList())
		end
		return "?"
	end
end

---------------------------------------------------------------------
-- Lobby: salas de fila
---------------------------------------------------------------------
local modes = {}
for _, pad in ipairs(Lobby.Pads:GetChildren()) do
	table.insert(modes, {
		pad = pad, cap = pad:GetAttribute("Capacity"), name = pad:GetAttribute("ModeName"),
		radius = pad:GetAttribute("Radius"), counting = false, label = pad.Board.Label,
	})
end
table.sort(modes, function(a, b) return a.cap < b.cap end)

local function playersOnPad(mode)
	local list, c = {}, mode.pad.Position
	for _, pl in ipairs(Players:GetPlayers()) do
		if not pl:GetAttribute("InMatch") then
			local hrp = hrpOf(pl)
			local h = hum(pl)
			if hrp and h and h.Health > 0 then
				local d = Vector3.new(hrp.Position.X - c.X, 0, hrp.Position.Z - c.Z).Magnitude
				if d < mode.radius and math.abs(hrp.Position.Y - c.Y) < 8 then table.insert(list, pl) end
			end
		end
	end
	return list
end

local function startCountdown(m)
	m.counting = true
	task.spawn(function()
		local ok = true
		for t = 5, 1, -1 do
			if match then ok = false; break end
			local list = playersOnPad(m)
			if #list < m.cap then ok = false; break end
			m.label.Text = ("%s\nINICIANDO EM %d"):format(m.name, t)
			for _, pl in ipairs(list) do Remotes.Notify:FireClient(pl, ("A partida começa em %d..."):format(t), 1.2) end
			task.wait(1)
		end
		m.counting = false
		if ok and not match then
			local list = playersOnPad(m)
			if #list >= m.cap then
				local chosen = {}
				for i = 1, m.cap do chosen[i] = list[i] end
				startMatch(chosen, m.name)
			end
		end
	end)
end

task.spawn(function()
	while true do
		task.wait(0.3)
		for _, m in ipairs(modes) do
			if match then
				m.label.Text = m.name .. "\nPARTIDA EM ANDAMENTO"
			elseif not m.counting then
				local list = playersOnPad(m)
				m.label.Text = ("%s\n%d/%d"):format(m.name, #list, m.cap)
				if #list >= m.cap then startCountdown(m) end
			end
		end
	end
end)

---------------------------------------------------------------------
-- Jogadores
---------------------------------------------------------------------
local function initPlayer(pl)
	pl:SetAttribute("InMatch", false)
	task.spawn(function() pl:LoadCharacter() end)
end
Players.PlayerAdded:Connect(initPlayer)
for _, pl in ipairs(Players:GetPlayers()) do initPlayer(pl) end

Players.PlayerRemoving:Connect(function(pl)
	unhide(pl)
	caught[pl] = nil; sprinting[pl] = nil; crouching[pl] = nil
	if match then match.players[pl] = nil end
end)

Remotes.Sprint.OnServerEvent:Connect(function(pl, on)
	sprinting[pl] = on == true
	if on then crouching[pl] = false end
	applySpeed(pl)
end)
-- de dentro do armário o prompt coincide com a câmera: saída por tecla (E / Espaço)
local SAFE_DIST = 16 -- distância mínima da criatura para poder sair
local function threatDist(pl)
	local hrp, d = hrpOf(pl), math.huge
	local f = workspace:FindFirstChild("Entities")
	if hrp and f then
		for _, e in ipairs(f:GetChildren()) do
			if e.PrimaryPart then d = math.min(d, (e.PrimaryPart.Position - hrp.Position).Magnitude) end
		end
	end
	return d
end
Remotes.Unhide.OnServerEvent:Connect(function(pl)
	if not hidden[pl] or os.clock() - (hiddenAt[pl] or 0) <= 0.8 then return end
	if rushActive or threatDist(pl) < SAFE_DIST then
		Remotes.Notify:FireClient(pl, "Ainda é perigoso. Aguarde a tensão passar...", 2)
		return
	end
	unhide(pl)
end)
task.spawn(function() -- medidor de tensão para quem está escondido
	while true do
		task.wait(0.3)
		for pl in pairs(hidden) do
			Remotes.Tension:FireClient(pl, rushActive and 1 or math.clamp(1 - threatDist(pl) / 40, 0, 1))
		end
	end
end)
Remotes.Crouch.OnServerEvent:Connect(function(pl, on)
	crouching[pl] = on == true
	if on then sprinting[pl] = false end
	applySpeed(pl)
end)

Remotes.ClientReady.OnServerEvent:Connect(function(pl)
	if not pl:GetAttribute("InMatch") then
		Remotes.Phase:FireClient(pl, {id = 0, light = LOBBY_LIGHT, cover = false, hold = 0})
		Remotes.Objective:FireClient(pl, "Pise em uma sala para entrar na fila")
	end
end)
