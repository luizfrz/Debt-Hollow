-- Entities: modelos e IA das criaturas da Mansão Hollow
--   visitante  (Fase 1)  o Credor: vê e ouve
--   enfermeira (Fase 2)  Sra. Voss: cega, só ouve
--   clara      (Fase 3)  só se move quando ninguém olha
--   coro       (Fase 3)  as vozes: investida em linha reta, só os armários salvam
local PFS = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("Remotes")

local M = {}
local BUILD, BRAIN = {}, {}

---------------------------------------------------------------------
-- Helpers de modelagem
---------------------------------------------------------------------
local function part(m, name, size, cf, color, mat, props)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Anchored = true
	p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
	p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
	if props then for k, v in pairs(props) do p[k] = v end end
	p.Parent = m
	return p
end
local function round(p, scale)
	local s = Instance.new("SpecialMesh"); s.MeshType = Enum.MeshType.Sphere; s.Scale = scale or Vector3.one; s.Parent = p
end
local function glow(p, color, range, brightness)
	local l = Instance.new("PointLight"); l.Color = color; l.Range = range; l.Brightness = brightness; l.Parent = p
end
local function newModel(name)
	local m = Instance.new("Model"); m.Name = name
	return m
end
local function finish(m, root)
	m.PrimaryPart = root
	return m
end

---------------------------------------------------------------------
-- O VISITANTE — o Credor. Altíssimo, cartola, sorriso largo demais,
-- dedos que arrastam no chão. Olhos vermelhos.
---------------------------------------------------------------------
function BUILD.visitante()
	local m = newModel("Visitante")
	local black, coat = Color3.fromRGB(10, 10, 12), Color3.fromRGB(18, 16, 20)
	local pale = Color3.fromRGB(222, 216, 204)
	local root = part(m, "Root", Vector3.new(2, 2, 1), CFrame.new(), black, nil, {Transparency = 1})
	part(m, "Torso", Vector3.new(2.2, 4, 1.2), CFrame.new(0, 0.75, 0), coat, Enum.Material.Fabric)
	part(m, "CoatTailL", Vector3.new(0.9, 3.4, 0.35), CFrame.new(-0.55, -2.4, 0.55) * CFrame.Angles(-0.12, 0, 0), coat, Enum.Material.Fabric)
	part(m, "CoatTailR", Vector3.new(0.9, 3.4, 0.35), CFrame.new(0.55, -2.4, 0.55) * CFrame.Angles(-0.12, 0, 0), coat, Enum.Material.Fabric)
	part(m, "LegL", Vector3.new(0.7, 3.5, 0.7), CFrame.new(-0.5, -3, 0), black)
	part(m, "LegR", Vector3.new(0.7, 3.5, 0.7), CFrame.new(0.5, -3, 0), black)
	for _, s in ipairs({-1, 1}) do
		part(m, "Arm", Vector3.new(0.5, 6, 0.5), CFrame.new(1.5 * s, 0, 0) * CFrame.Angles(0, 0, -0.08 * s), black)
		for k = -1, 1 do -- três dedos longos arrastando
			part(m, "Finger", Vector3.new(0.12, 1.8, 0.12), CFrame.new(1.5 * s + k * 0.2, -3.8, 0) * CFrame.Angles(0, 0, k * 0.15), black)
		end
	end
	local head = part(m, "Head", Vector3.new(1.7, 2.3, 1.7), CFrame.new(0, 3.9, 0), pale)
	round(head)
	part(m, "MouthLine", Vector3.new(1.5, 0.1, 0.05), CFrame.new(0, 3.45, -0.8), black)
	for k = -4, 4 do -- sorriso largo demais
		local x = k * 0.17
		part(m, "Tooth", Vector3.new(0.09, 0.3, 0.05), CFrame.new(x, 3.35 + (x * x) * 0.4, -0.8 + (x * x) * 0.5), Color3.fromRGB(245, 245, 235))
	end
	for _, s in ipairs({-1, 1}) do
		local eye = part(m, "Eye", Vector3.new(0.35, 0.18, 0.1), CFrame.new(0.4 * s, 4.1, -0.82), Color3.fromRGB(255, 20, 20), Enum.Material.Neon)
		glow(eye, Color3.fromRGB(255, 20, 20), 6, 0.8)
	end
	part(m, "Brim", Vector3.new(0.15, 3.4, 3.4), CFrame.new(0, 4.95, 0) * CFrame.Angles(0, 0, math.pi / 2), black, nil, {Shape = Enum.PartType.Cylinder})
	part(m, "Crown", Vector3.new(2.0, 1.8, 1.8), CFrame.new(0, 6.0, 0) * CFrame.Angles(0, 0, math.pi / 2), black, nil, {Shape = Enum.PartType.Cylinder})
	return finish(m, root), 4.75
end

---------------------------------------------------------------------
-- A ENFERMEIRA — Margarethe Voss. Curvada, olhos e boca costurados,
-- avental manchado de ferrugem, seringa longa na mão.
---------------------------------------------------------------------
function BUILD.enfermeira()
	local m = newModel("Enfermeira")
	local dress, rust = Color3.fromRGB(196, 198, 190), Color3.fromRGB(110, 42, 30)
	local skin, thread = Color3.fromRGB(228, 222, 214), Color3.fromRGB(14, 12, 12)
	local root = part(m, "Root", Vector3.new(2, 2, 1), CFrame.new(), dress, nil, {Transparency = 1})
	part(m, "Skirt", Vector3.new(3, 2.6, 2.2), CFrame.new(0, -2.6, 0), dress, Enum.Material.Fabric)
	part(m, "LegL", Vector3.new(0.4, 1, 0.4), CFrame.new(-0.5, -3.9, 0), Color3.fromRGB(24, 24, 26))
	part(m, "LegR", Vector3.new(0.4, 1, 0.4), CFrame.new(0.5, -3.9, 0), Color3.fromRGB(24, 24, 26))
	local stoop = CFrame.new(0, 0, -0.2) * CFrame.Angles(0.22, 0, 0) -- postura curvada
	part(m, "Torso", Vector3.new(2.2, 3, 1.3), stoop * CFrame.new(0, 0.2, 0), dress, Enum.Material.Fabric)
	part(m, "Apron", Vector3.new(1.7, 3.4, 0.12), stoop * CFrame.new(0, -0.4, -0.7), rust, Enum.Material.Fabric)
	part(m, "Stain1", Vector3.new(0.5, 0.7, 0.05), stoop * CFrame.new(0.3, 0.3, -0.78), Color3.fromRGB(70, 22, 16), Enum.Material.Fabric)
	part(m, "Stain2", Vector3.new(0.9, 0.4, 0.05), stoop * CFrame.new(-0.2, -1.2, -0.78), Color3.fromRGB(70, 22, 16), Enum.Material.Fabric)

	local hc = CFrame.new(0, 3.1, -0.9) * CFrame.Angles(0.2, 0, 0.35) -- cabeça inclinada
	local head = part(m, "Head", Vector3.new(1.7, 2, 1.7), hc, skin)
	round(head)
	part(m, "Cap", Vector3.new(1.8, 0.5, 1.5), hc * CFrame.new(0, 0.95, 0.05), Color3.fromRGB(235, 235, 228))
	part(m, "CrossV", Vector3.new(0.15, 0.4, 0.05), hc * CFrame.new(0, 0.95, -0.72), Color3.fromRGB(150, 20, 20))
	part(m, "CrossH", Vector3.new(0.4, 0.15, 0.05), hc * CFrame.new(0, 0.95, -0.72), Color3.fromRGB(150, 20, 20))
	part(m, "MouthThread", Vector3.new(0.9, 0.07, 0.05), hc * CFrame.new(0, -0.45, -0.85), thread)
	for k = -3, 3 do -- pontos da boca costurada
		part(m, "MouthStitch", Vector3.new(0.04, 0.34, 0.05), hc * CFrame.new(k * 0.14, -0.45, -0.85), thread)
	end
	for _, s in ipairs({-1, 1}) do -- olhos costurados
		part(m, "EyeThread", Vector3.new(0.4, 0.06, 0.05), hc * CFrame.new(0.38 * s, 0.1, -0.85), thread)
		for k = -1, 1 do
			part(m, "EyeStitch", Vector3.new(0.04, 0.22, 0.05), hc * CFrame.new(0.38 * s + k * 0.13, 0.1, -0.85), thread)
		end
		part(m, "Hair", Vector3.new(0.12, 2.1, 0.12), hc * CFrame.new(0.82 * s, -0.5, 0.1), thread)
		part(m, "Hair2", Vector3.new(0.1, 1.6, 0.1), hc * CFrame.new(0.66 * s, -0.3, 0.45), thread)
	end

	part(m, "ArmL", Vector3.new(0.4, 5, 0.4), CFrame.new(-1.5, -1, -0.5) * CFrame.Angles(0.12, 0, 0.06), skin)
	part(m, "ArmR", Vector3.new(0.4, 3, 0.4), CFrame.new(1.5, 0.9, -1.4) * CFrame.Angles(-1.2, 0, 0), skin)
	part(m, "Syringe", Vector3.new(0.3, 0.3, 2.0), CFrame.new(1.5, 0.45, -3.2), Color3.fromRGB(200, 230, 220), Enum.Material.Glass, {Transparency = 0.45})
	part(m, "Fluid", Vector3.new(0.2, 0.2, 1.3), CFrame.new(1.5, 0.45, -3.1), Color3.fromRGB(150, 30, 30))
	part(m, "Plunger", Vector3.new(0.6, 0.6, 0.1), CFrame.new(1.5, 0.45, -2.15), Color3.fromRGB(60, 60, 64), Enum.Material.Metal)
	part(m, "Needle", Vector3.new(0.05, 0.05, 1.8), CFrame.new(1.5, 0.45, -4.9), Color3.fromRGB(190, 190, 195), Enum.Material.Metal)
	return finish(m, root), 4.4
end

---------------------------------------------------------------------
-- CLARA — a filha. Camisola rasgada, rosto de porcelana rachado,
-- órbitas vazias, sorriso largo, boneca nas mãos.
---------------------------------------------------------------------
function BUILD.clara()
	local m = newModel("Clara")
	local gown, porcelain, black = Color3.fromRGB(214, 204, 184), Color3.fromRGB(236, 232, 224), Color3.fromRGB(8, 8, 9)
	local root = part(m, "Root", Vector3.new(2, 2, 1), CFrame.new(), gown, nil, {Transparency = 1})
	part(m, "LegL", Vector3.new(0.4, 1, 0.4), CFrame.new(-0.35, -1.8, 0), porcelain)
	part(m, "LegR", Vector3.new(0.4, 1, 0.4), CFrame.new(0.35, -1.8, 0), porcelain)
	part(m, "Skirt", Vector3.new(2.6, 1.6, 2.2), CFrame.new(0, -0.9, 0), gown, Enum.Material.Fabric)
	part(m, "Torso", Vector3.new(1.7, 1.9, 1.1), CFrame.new(0, 0.65, 0), gown, Enum.Material.Fabric)
	part(m, "Tear", Vector3.new(0.7, 0.8, 0.05), CFrame.new(0.4, -1.2, -1.12), Color3.fromRGB(120, 112, 98), Enum.Material.Fabric)
	part(m, "ArmL", Vector3.new(0.35, 2, 0.35), CFrame.new(-1.1, 0.5, 0) * CFrame.Angles(0, 0, 0.1), porcelain)
	part(m, "ArmR", Vector3.new(0.35, 2, 0.35), CFrame.new(1.1, 0.8, -0.6) * CFrame.Angles(-0.9, 0, 0), porcelain)
	-- a boneca
	part(m, "DollBody", Vector3.new(0.5, 0.9, 0.25), CFrame.new(1.1, 0.7, -1.5), Color3.fromRGB(200, 180, 150), Enum.Material.Fabric)
	round(part(m, "DollHead", Vector3.new(0.5, 0.5, 0.5), CFrame.new(1.1, 1.35, -1.5), porcelain))
	part(m, "DollEyeL", Vector3.new(0.1, 0.12, 0.05), CFrame.new(1.0, 1.4, -1.76), black)
	part(m, "DollEyeR", Vector3.new(0.1, 0.12, 0.05), CFrame.new(1.2, 1.4, -1.76), black)
	-- cabeça
	local head = part(m, "Head", Vector3.new(1.5, 1.7, 1.5), CFrame.new(0, 2.3, 0), porcelain)
	round(head)
	for _, s in ipairs({-1, 1}) do
		part(m, "Socket", Vector3.new(0.42, 0.55, 0.05), CFrame.new(0.38 * s, 2.4, -0.72), black)
		part(m, "Glint", Vector3.new(0.08, 0.08, 0.03), CFrame.new(0.38 * s, 2.32, -0.75), Color3.fromRGB(255, 30, 30), Enum.Material.Neon)
		part(m, "SmileEdge", Vector3.new(0.07, 0.3, 0.05), CFrame.new(0.58 * s, 1.98, -0.69) * CFrame.Angles(0, 0, 0.35 * s), black)
		part(m, "HairSide", Vector3.new(0.2, 2.6, 0.25), CFrame.new(0.85 * s, 1.7, -0.1), black)
	end
	part(m, "Smile", Vector3.new(1.1, 0.07, 0.05), CFrame.new(0, 1.85, -0.72), black)
	part(m, "Crack1", Vector3.new(0.03, 0.9, 0.02), CFrame.new(0.2, 2.75, -0.74) * CFrame.Angles(0, 0, 0.4), black)
	part(m, "Crack2", Vector3.new(0.03, 0.8, 0.02), CFrame.new(-0.5, 2.2, -0.72) * CFrame.Angles(0, 0, -0.6), black)
	part(m, "Crack3", Vector3.new(0.03, 0.7, 0.02), CFrame.new(0.55, 2.0, -0.7) * CFrame.Angles(0, 0, 0.9), black)
	part(m, "HairBack", Vector3.new(1.7, 2.4, 0.3), CFrame.new(0, 2.0, 0.75), black)
	part(m, "Bangs", Vector3.new(1.5, 0.45, 0.2), CFrame.new(0, 3.0, -0.62), black)
	return finish(m, root), 2.3
end

---------------------------------------------------------------------
-- O CORO — uma massa de rostos gritando, núcleo vermelho, fumaça.
---------------------------------------------------------------------
function BUILD.coro()
	local m = newModel("Coro")
	local pale, black = Color3.fromRGB(205, 200, 190), Color3.fromRGB(5, 4, 6)
	local root = part(m, "Root", Vector3.new(10, 10, 10), CFrame.new(), Color3.fromRGB(6, 4, 8), nil, {Shape = Enum.PartType.Ball, Transparency = 0.15})
	local core = part(m, "Core", Vector3.new(4, 4, 4), CFrame.new(), Color3.fromRGB(255, 30, 30), Enum.Material.Neon, {Shape = Enum.PartType.Ball})
	glow(core, Color3.fromRGB(255, 40, 40), 45, 3)
	local rng = Random.new(77)
	for _ = 1, 16 do
		local dir = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1))
		if dir.Magnitude < 0.2 then dir = Vector3.new(0, 1, 0) end
		dir = dir.Unit
		local pos = dir * 4.6
		local cf = CFrame.lookAt(pos, pos + dir)
		round(part(m, "Face", Vector3.new(2.4, 3, 1.2), cf, pale))
		part(m, "EyeL", Vector3.new(0.5, 0.7, 0.2), cf * CFrame.new(-0.55, 0.5, -0.55), black)
		part(m, "EyeR", Vector3.new(0.5, 0.7, 0.2), cf * CFrame.new(0.55, 0.5, -0.55), black)
		round(part(m, "Mouth", Vector3.new(0.8, 1.1, 0.2), cf * CFrame.new(0, -0.6, -0.55), black))
	end
	local pe = Instance.new("ParticleEmitter")
	pe.Color = ColorSequence.new(Color3.fromRGB(10, 8, 12))
	pe.Size = NumberSequence.new(8); pe.Lifetime = NumberRange.new(1, 2); pe.Rate = 60
	pe.Speed = NumberRange.new(4, 10); pe.SpreadAngle = Vector2.new(180, 180)
	pe.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
	pe.Parent = root
	return finish(m, root), 6
end

-- Clara usa o mesmo modelo dos retratos (ServerStorage.Figures); substitui o modelo simples acima.
local Figures = require(game:GetService("ServerStorage"):WaitForChild("Figures"))
function BUILD.clara()
	return Figures.build("Clara"), 0 -- origem nos pés
end

function BUILD.augustus() return Figures.build("Augustus"), 0 end
function BUILD.eleanora() return Figures.build("Eleanora"), 0 end

M.BUILD = BUILD

---------------------------------------------------------------------
-- Caminhante (base para visitante, enfermeira e clara)
---------------------------------------------------------------------
local Walker = {}
Walker.__index = Walker

local SWAY = {visitante = 0.06, enfermeira = 0.12, clara = 0.02}
local CATCH = {visitante = 4.5, enfermeira = 4.5, clara = 3.8}
local INTERVAL = {visitante = 0.25, enfermeira = 0.25, clara = 0.1}

local function ground(v) return Vector3.new(v.X, 1, v.Z) end

function Walker:place(pos)
	self.model:PivotTo(CFrame.new(pos.X, self.G, pos.Z))
end

function Walker:goTo(target, force)
	target = ground(target)
	local now = os.clock()
	if not force and self.waypoints and self.lastGoal and (target - self.lastGoal).Magnitude < 3 and now - self.lastCompute < 0.7 then return end
	self.lastGoal, self.lastCompute = target, now
	local ok = pcall(function() self.path:ComputeAsync(ground(self.root.Position), target) end)
	if ok and self.path.Status == Enum.PathStatus.Success then
		self.waypoints = self.path:GetWaypoints(); self.wpIndex = 2
	else
		self.waypoints = {{Position = target}}; self.wpIndex = 1
	end
end

function Walker:retreat()
	self:place(self.level.MonsterSpawn.Position)
	self.state = "patrol"; self.waypoints = nil; self.lostAt = nil; self.hunting = false
	self.ctrl.graceUntil = os.clock() + 8
	self.ctrl.updateChase()
end

function Walker:afterKill()
	self.paused = true; self.waypoints = nil
	task.delay(3.5, function()
		if not self.alive then return end
		self:retreat(); self.paused = false
	end)
end

function Walker:tryCatch(pl)
	local r = self.ctx.catch(pl, self.kind)
	if r == "saved" then self:retreat() else self:afterKill() end
end

function Walker:step(dt)
	if self.paused or self.frozen or not self.waypoints or os.clock() < self.pauseUntil then
		self.curSpeed = 0
		if self.anim then self.anim:update(self.root.CFrame, dt, 0, self.frozen and 'frozen' or 'idle') end
		return
	end
	local wp = self.waypoints[self.wpIndex]
	if not wp then
		self.waypoints = nil
		if self.onArrive then self:onArrive() end
		return
	end
	local cur = self.root.Position
	local tgt = Vector3.new(wp.Position.X, cur.Y, wp.Position.Z)
	local d = tgt - cur
	if d.Magnitude < 1.2 then self.wpIndex += 1; return end
	local dir = d.Unit
	self.curSpeed = (self.curSpeed or 0) + (self.speed - (self.curSpeed or 0)) * math.min(1, dt * 3.5) -- acelera sem tranco
	local newPos = cur + dir * math.min(d.Magnitude, self.curSpeed * dt)
	local want = CFrame.lookAt(newPos, newPos + dir).Rotation
	self.face = self.face and self.face:Lerp(want, math.min(1, dt * 7)) or want -- curva suave
	local cf = CFrame.new(newPos) * self.face
	if self.anim then
		self.anim:update(cf, dt, self.curSpeed, 'walk')
	else
		local sway = math.sin((os.clock() - self.t0) * self.speed * 0.7) * (SWAY[self.kind] or 0.05)
		self.model:PivotTo(cf * CFrame.Angles(0, 0, sway))
	end

	for _, t in ipairs(self.ctx.getTargets()) do
		local rp = t.root.Position
		if (Vector3.new(rp.X, 0, rp.Z) - Vector3.new(newPos.X, 0, newPos.Z)).Magnitude < (CATCH[self.kind] or 4.5) then
			self:tryCatch(t.pl)
			break
		end
	end
end

function Walker:destroy()
	self.alive = false
	if self.model then self.model:Destroy() end
end

local function nearest(self, targets)
	local best, bd
	for _, t in ipairs(targets) do
		local d = (t.root.Position - self.root.Position).Magnitude
		if not bd or d < bd then best, bd = t, d end
	end
	return best, bd
end

local function hasLOS(self, t)
	local from = self.root.Position + Vector3.new(0, 2, 0)
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = {self.ctrl.folder, self.level.Props}
	local res = workspace:Raycast(from, t.root.Position - from, rp)
	return res ~= nil and res.Instance:IsDescendantOf(t.ch)
end

-- armafários: ficar muito tempo por perto pode revelar o jogador escondido
local function checkLockers(self, ctx)
	for _, h in ipairs(ctx.getHidden()) do
		if (h.locker.Position - self.root.Position).Magnitude < 8 and (self.state == "search" or self.state == "hunt") then
			self.knock[h.pl] = (self.knock[h.pl] or 0) + (INTERVAL[self.kind] or 0.25)
			if self.knock[h.pl] >= 3 then
				self.knock[h.pl] = 0
				if math.random() < 0.5 then self:tryCatch(h.pl) return true end
			end
		else
			self.knock[h.pl] = 0
		end
	end
	return false
end

---------------------------------------------------------------------
-- Cérebros
---------------------------------------------------------------------
function BRAIN.visitante(self, ctrl, ctx)
	local targets = ctx.getTargets()
	if checkLockers(self, ctx) then return end
	local best, bd = nearest(self, targets)
	local seen = false
	if best then
		if bd < best.noise then seen = true
		elseif bd < 60 then seen = hasLOS(self, best) end
		if ctrl.rage then seen = true end
	end
	if seen then
		self.state = "hunt"; self.lastSeen = best.root.Position; self.lostAt = nil
		self.speed = ctrl.rage and 19.5 or 16.5
		self.hunting = true; ctrl.updateChase()
		self:goTo(self.lastSeen)
	elseif self.state == "hunt" then
		self.lostAt = self.lostAt or os.clock()
		self:goTo(self.lastSeen)
		if os.clock() - self.lostAt > 4 then
			self.state = "search"; self.searchUntil = os.clock() + 8
			self.hunting = false; ctrl.updateChase()
		end
	elseif self.state == "search" then
		self.speed = 10
		if not self.waypoints then
			local near = self.lastSeen or self.root.Position
			self:goTo(near + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20)), true)
		end
		if os.clock() > self.searchUntil then self.state = "patrol" end
	else
		self.speed = 8
		if not self.waypoints then self:goTo(ctrl.randomCell(), true) end
	end
end

-- Enfermeira: cega. Ouve com muito mais acuidade que o Visitante.
function BRAIN.enfermeira(self, ctrl, ctx)
	local targets = ctx.getTargets()
	if checkLockers(self, ctx) then return end
	local heard, hd
	for _, t in ipairs(targets) do
		local d = (t.root.Position - self.root.Position).Magnitude
		local range = t.noise * 1.3 * (ctrl.rage and 1.6 or 1)
		if d < range and (not hd or d < hd) then heard, hd = t, d end
	end
	if heard then
		self.state = "hunt"; self.lastSeen = heard.root.Position; self.lostAt = nil
		self.speed = ctrl.rage and 22 or 19
		self.hunting = true; ctrl.updateChase()
		self:goTo(self.lastSeen)
	elseif self.state == "hunt" then
		self.lostAt = self.lostAt or os.clock()
		self:goTo(self.lastSeen)
		if os.clock() - self.lostAt > 3 then
			self.state = "search"; self.searchUntil = os.clock() + 10
			self.hunting = false; ctrl.updateChase()
		end
	elseif self.state == "search" then
		self.speed = 6
		if not self.waypoints and math.random() < 0.4 then
			local near = self.lastSeen or self.root.Position
			self:goTo(near + Vector3.new(math.random(-18, 18), 0, math.random(-18, 18)), true)
		end
		if os.clock() > self.searchUntil then self.state = "patrol" end
	else
		self.speed = 5.5
		if not self.waypoints then self:goTo(ctrl.randomCell(), true) end
	end
end

local function watching(self, t)
	local head = t.root.Position + Vector3.new(0, 1.5, 0)
	local to = (self.root.Position + Vector3.new(0, 1, 0)) - head
	if to.Magnitude > 120 then return false end
	if t.root.CFrame.LookVector:Dot(to.Unit) < 0.4 then return false end
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = {self.ctrl.folder, t.ch}
	return workspace:Raycast(head, to, rp) == nil
end

-- Clara: sabe onde você está; só congela enquanto alguém olha para ela.
function BRAIN.clara(self, ctrl, ctx)
	local targets = ctx.getTargets()
	if #targets == 0 then self.frozen = false; self.waypoints = nil; return end
	local watched = false
	for _, t in ipairs(targets) do
		if watching(self, t) then watched = true; break end
	end
	self.frozen = watched
	if watched then return end
	local best, bd = nearest(self, targets)
	self.hunting = bd < 40; ctrl.updateChase()
	self.speed = ctrl.rage and 20 or 16
	self:goTo(best.root.Position)
end

-- as três personagens do lobby são as criaturas: Augustus vê e ouve; Eleanora chora e só ouve
BRAIN.augustus = BRAIN.visitante
BRAIN.eleanora = BRAIN.enfermeira
SWAY.augustus, SWAY.eleanora = 0.04, 0.05
CATCH.augustus, CATCH.eleanora = 4.5, 4.5
INTERVAL.augustus, INTERVAL.eleanora = 0.25, 0.25

local Animator = require(game:GetService('ServerStorage'):WaitForChild('FigureAnimator'))
local FIG = {clara = 'Clara', augustus = 'Augustus', eleanora = 'Eleanora'} -- modelos com animacao procedural

local function newWalker(kind, ctrl, level, ctx)
	local model, G = BUILD[kind]()
	local self = setmetatable({}, Walker)
	self.kind, self.model, self.root, self.G = kind, model, model.PrimaryPart, G
	self.ctrl, self.ctx, self.level = ctrl, ctx, level
	self.speed, self.state, self.t0, self.alive = 0, "patrol", os.clock(), true
	self.knock, self.pauseUntil, self.hunting = {}, 0, false
	if FIG[kind] then self.anim = Animator.new(model, FIG[kind]) end -- antes de posicionar: o modelo ainda esta na origem
	self.path = PFS:CreatePath({AgentRadius = 2.2, AgentHeight = 8, AgentCanJump = false})
	self:place(level.MonsterSpawn.Position)
	model.Parent = ctrl.folder

	if kind == "enfermeira" or kind == "eleanora" then -- para e escuta ao chegar
		self.onArrive = function(w) if w.state ~= "hunt" then w.pauseUntil = os.clock() + math.random(2, 4) end end
	end

	task.spawn(function()
		while self.alive and ctrl.alive do
			task.wait(INTERVAL[kind] or 0.25)
			if self.paused then continue end
			if os.clock() < ctrl.graceUntil then self.waypoints = nil; continue end
			BRAIN[kind](self, ctrl, ctx)
		end
	end)
	return self
end

---------------------------------------------------------------------
-- Controlador de uma fase
---------------------------------------------------------------------
function M.start(level, kinds, ctx, opts)
	opts = opts or {}
	local O, N, S = level:GetAttribute("Origin"), level:GetAttribute("N"), level:GetAttribute("S")
	local ctrl = {alive = true, walkers = {}, rage = false, lastChase = false, flickerAllUntil = 0}

	local folder = workspace:FindFirstChild("Entities")
	if not folder then folder = Instance.new("Folder"); folder.Name = "Entities"; folder.Parent = workspace end
	ctrl.folder = folder
	ctrl.graceUntil = os.clock() + (opts.grace or 25)

	function ctrl.randomCell()
		for _ = 1, 10 do
			local c = O + Vector3.new(math.random(0, N - 1) * S, 1, math.random(0, N - 1) * S)
			if (c - level.Spawn.Position).Magnitude > 45 then return c end
		end
		return O + Vector3.new((N - 1) * S, 1, (N - 1) * S)
	end

	function ctrl.updateChase()
		local any = ctrl.rage
		for _, w in ipairs(ctrl.walkers) do if w.hunting then any = true end end
		if any ~= ctrl.lastChase then ctrl.lastChase = any; ctx.chase(any) end
	end

	function ctrl:Spawn(kind, o)
		o = o or {}
		local w = newWalker(kind, ctrl, level, ctx)
		table.insert(ctrl.walkers, w)
		if o.grace then ctrl.graceUntil = os.clock() + o.grace end
		return w
	end

	function ctrl:SetRage(v)
		ctrl.rage = v
		ctrl.updateChase()
	end

	function ctrl:FlickerAll(sec) ctrl.flickerAllUntil = os.clock() + sec end

	ctrl.conn = RunService.Heartbeat:Connect(function(dt)
		for _, w in ipairs(ctrl.walkers) do w:step(dt) end
	end)

	-- luzes tremem perto das criaturas
	task.spawn(function()
		while ctrl.alive do
			task.wait(0.15)
			local positions = {}
			for _, w in ipairs(ctrl.walkers) do table.insert(positions, w.root.Position) end
			if ctrl.rushPos then table.insert(positions, ctrl.rushPos) end
			local all = os.clock() < ctrl.flickerAllUntil
			for _, lamp in ipairs(level.Lamps:GetChildren()) do
				local l = lamp:FindFirstChildOfClass("PointLight")
				if l then
					local base = lamp:GetAttribute("Base") or 1
					local near = all
					if not near then
						for _, p in ipairs(positions) do if (lamp.Position - p).Magnitude < 38 then near = true; break end end
					end
					if near and math.random() < 0.6 then l.Brightness = base * math.random(0, 6) / 10
					elseif math.random() < 0.02 then l.Brightness = base * 0.2
					else l.Brightness = base end
				end
			end
		end
		for _, lamp in ipairs(level.Lamps:GetChildren()) do
			local l = lamp:FindFirstChildOfClass("PointLight")
			if l then l.Brightness = lamp:GetAttribute("Base") or 1 end
		end
	end)

	-- o Coro: investida em linha reta através do nível
	local function doRush()
		local alongX = math.random() < 0.5
		local line = alongX and (O.Z + math.random(0, N - 1) * S) or (O.X + math.random(0, N - 1) * S)
		local a, b = -45, (N - 1) * S + 45
		if math.random() < 0.5 then a, b = b, a end
		ctx.notify("AS VOZES ESTÃO CHEGANDO. ESCONDA-SE!", 5)
		ctx.rush("warn")
		ctrl:FlickerAll(6)
		for _ = 1, 12 do if not ctrl.alive then return end task.wait(0.5) end

		local model = BUILD.coro()
		model.Parent = folder
		ctx.rush("go")
		local dir = (b > a) and 1 or -1
		local pos = a
		local hit = {}
		local done = false
		ctrl.rushConn = RunService.Heartbeat:Connect(function(dt)
			pos += dir * 95 * dt
			local p3 = alongX and Vector3.new(O.X + pos, 6, line) or Vector3.new(line, 6, O.Z + pos)
			model:PivotTo(CFrame.new(p3) * CFrame.Angles(0, os.clock() * 3, 0))
			ctrl.rushPos = p3
			for _, t in ipairs(ctx.getTargets()) do
				local rp = t.root.Position
				local perp = alongX and math.abs(rp.Z - line) or math.abs(rp.X - line)
				local along = alongX and math.abs(rp.X - p3.X) or math.abs(rp.Z - p3.Z)
				if perp < 9 and along < 9 and not hit[t.pl] then
					hit[t.pl] = true
					ctx.catch(t.pl, "coro")
				end
			end
			if (dir > 0 and pos > b) or (dir < 0 and pos < b) then done = true end
		end)
		while not done and ctrl.alive do task.wait(0.1) end
		if ctrl.rushConn then ctrl.rushConn:Disconnect(); ctrl.rushConn = nil end
		ctrl.rushPos = nil
		model:Destroy()
		ctx.rush("end")
	end

	for _, kind in ipairs(kinds) do
		if kind == "coro" then
			task.spawn(function()
				for _ = 1, (opts.rushFirst or 45) do if not ctrl.alive then return end task.wait(1) end
				while ctrl.alive do
					doRush()
					for _ = 1, math.random(50, 85) do if not ctrl.alive then return end task.wait(1) end
				end
			end)
		else
			ctrl:Spawn(kind)
		end
	end

	function ctrl:Stop()
		ctrl.alive = false
		if ctrl.conn then ctrl.conn:Disconnect() end
		if ctrl.rushConn then ctrl.rushConn:Disconnect() end
		for _, w in ipairs(ctrl.walkers) do w:destroy() end
		table.clear(ctrl.walkers)
		for _, c in ipairs(folder:GetChildren()) do c:Destroy() end
		ctx.chase(false)
	end

	return ctrl
end

return M
