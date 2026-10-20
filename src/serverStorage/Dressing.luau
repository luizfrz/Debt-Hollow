-- Dressing: camada extra de cenario (vigas, arandelas/tochas, teias, correntes, papeis, caixas, ossos, vitrais, poeira;
-- na mansao: passadeiras nas portas, luar nas janelas, cadeiras e quadros caidos, velas no chao).
-- Uso: require(game.ServerStorage.Dressing).dress(workspace.Levels.Fase1, 'mansion', seed)  -- idempotente (recria a pasta 'Extra')
local B = require(script.Parent:WaitForChild('LevelBuilder'))
local part = B.part
local V3, CF, M = Vector3.new, CFrame.new, Enum.Material
local rad = math.rad
local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local GOLD = C(190, 150, 70)
local D = {}

local HEIGHT = {mansion = 16, sanatorium = 13, crypt = 18}
-- lados: direcao para fora da celula (normal da parede) e eixo ao longo da parede
local SIDES = {{V3(1, 0, 0), V3(0, 0, 1)}, {V3(-1, 0, 0), V3(0, 0, 1)}, {V3(0, 0, 1), V3(1, 0, 0)}, {V3(0, 0, -1), V3(1, 0, 0)}}

local function look(pos, dir) -- orienta uma peca com a face frontal (-Z) apontando para dir
	return CF(pos, pos + dir)
end

function D.dress(level, style, seed)
	local old = level:FindFirstChild('Extra'); if old then old:Destroy() end
	local rng = Random.new(seed or 7)
	local O, N, S = level:GetAttribute('Origin'), level:GetAttribute('N'), level:GetAttribute('S')
	local H = HEIGHT[style]
	local half = S / 2
	local out = Instance.new('Folder'); out.Name = 'Extra'; out.Parent = level
	local n = 0
	local function P(name, size, cf, color, mat, o)
		n += 1
		local p = part(out, name, size, cf, color, mat, {collide = false, t = o and o.t, sphere = o and o.sphere, shape = o and o.shape})
		return p
	end
	local function flame(pos, color, range, br)
		local f = P('Flame', V3(0.3, 0.5, 0.3), CF(pos), color, M.Neon, {sphere = true})
		local l = Instance.new('PointLight'); l.Color = color; l.Range = range; l.Brightness = br; l.Shadows = false; l.Parent = f
	end

	for i = 0, N - 1 do for j = 0, N - 1 do
		local c = O + V3(i * S, 0, j * S)
		-- vigas no teto
		if style ~= 'sanatorium' then
			local alongX = (i + j) % 2 == 0
			for k = -1, 1 do
				local off = k * S / 3
				local size = alongX and V3(S, 1, 1.1) or V3(1.1, 1, S)
				local pos = c + (alongX and V3(0, H - 0.6, off) or V3(off, H - 0.6, 0))
				P('Beam', size, CF(pos), style == 'crypt' and C(38, 34, 42) or C(34, 22, 16), style == 'crypt' and M.Slate or M.Wood)
			end
		else -- calhas de cano no teto do sanatorio
			P('Pipe', V3(S, 0.6, 0.6), CF(c + V3(0, H - 1, rng:NextInteger(-8, 8))), C(110, 120, 116), M.Metal, {})
		end

		-- 1 a 2 fontes de luz de parede por celula, fora do vao das portas
		for k = 1, rng:NextInteger(1, 2) do
			local sd = SIDES[rng:NextInteger(1, 4)]
			local along = sd[2] * (rng:NextInteger(0, 1) == 0 and -1 or 1) * (half - 4.2)
			local base = c + sd[1] * (half - 1.1) + along
			if style == 'mansion' then
				P('SconceArm', V3(0.3, 0.3, 0.7), look(base + V3(0, 8.2, 0), sd[1]), GOLD, M.Metal)
				P('SconceCup', V3(0.55, 0.3, 0.55), CF(base + V3(0, 8.5, 0) - sd[1] * 0.2), GOLD, M.Metal)
				P('Candle', V3(0.3, 0.8, 0.3), CF(base + V3(0, 9, 0) - sd[1] * 0.2), C(235, 225, 195))
				flame(base + V3(0, 9.6, 0) - sd[1] * 0.2, C(255, 170, 80), 17, 0.9)
			elseif style == 'sanatorium' then
				P('Caged', V3(0.9, 0.9, 0.5), look(base + V3(0, 9.5, 0), sd[1]), C(80, 86, 84), M.Metal)
				local f = P('Bulb', V3(0.5, 0.5, 0.5), CF(base + V3(0, 9.5, 0) - sd[1] * 0.3), C(215, 255, 240), M.Neon, {sphere = true})
				local l = Instance.new('PointLight'); l.Color = C(190, 255, 230); l.Range = 16; l.Brightness = 0.8; l.Shadows = false; l.Parent = f
			else
				P('TorchHolder', V3(0.35, 1.8, 0.35), CF(base + V3(0, 7.5, 0)) * CFrame.Angles(0, 0, 0), C(26, 22, 22), M.Metal)
				P('TorchHead', V3(0.7, 0.5, 0.7), CF(base + V3(0, 8.6, 0)), C(40, 28, 20), M.Wood)
				flame(base + V3(0, 9.2, 0), C(255, 120, 45), 19, 1.1)
			end
		end

		-- teias nos cantos do teto
		if style ~= 'sanatorium' then
			for _, sx in ipairs({-1, 1}) do for _, sz in ipairs({-1, 1}) do
				if rng:NextNumber() < 0.55 then
					local corner = c + V3(sx * (half - 1), H - 0.5, sz * (half - 1))
					for k = 0, 3 do
						local dir = V3(-sx * math.cos(rad(k * 28)), -0.55, -sz * math.sin(rad(k * 28))).Unit
						P('Web', V3(0.05, 0.05, 3.2 - k * 0.3), CF(corner + dir * 1.6, corner + dir * 3.2), C(210, 210, 215), M.SmoothPlastic, {t = 0.45})
					end
				end
			end end
		end

		-- correntes pendentes (cripta) / papeis soltos (mansao, sanatorio) / ossos e rachaduras no chao
		if style == 'crypt' and rng:NextNumber() < 0.5 then
			local x, z = rng:NextNumber(-9, 9), rng:NextNumber(-9, 9)
			for k = 0, 6 do P('Chain', V3(0.2, 0.7, 0.2), CF(c + V3(x, H - 1 - k * 0.8, z)) * CFrame.Angles(0, k * 0.8, 0), C(30, 28, 30), M.Metal) end
			P('Shackle', V3(0.9, 0.2, 0.9), CF(c + V3(x, H - 7, z)), C(30, 28, 30), M.Metal, {shape = Enum.PartType.Cylinder})
		else
			for k = 1, rng:NextInteger(2, 5) do
				local col = style == 'sanatorium' and C(226, 226, 214) or C(214, 204, 176)
				P('Paper', V3(1.1, 0.04, 1.5), CF(c + V3(rng:NextNumber(-10, 10), 0.08, rng:NextNumber(-10, 10))) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0), col, M.Fabric)
			end
		end
		if style == 'sanatorium' and rng:NextNumber() < 0.4 then -- mancha escura de sangue seco
			P('Stain', V3(rng:NextNumber(2, 4), 0.03, rng:NextNumber(2, 4)), CF(c + V3(rng:NextNumber(-8, 8), 0.07, rng:NextNumber(-8, 8))), C(70, 18, 16), M.SmoothPlastic, {sphere = true})
		end
		if style == 'mansion' and rng:NextNumber() < 0.35 then -- vaso quebrado
			local p0 = c + V3(rng:NextNumber(-8, 8), 0, rng:NextNumber(-8, 8))
			P('Vase', V3(1.4, 1, 1.4), CF(p0 + V3(0, 0.5, 0)), C(70, 100, 130), M.Slate, {sphere = true})
			for k = 1, 4 do P('Shard', V3(0.5, 0.15, 0.7), CF(p0 + V3(rng:NextNumber(-1.8, 1.8), 0.08, rng:NextNumber(-1.8, 1.8))) * CFrame.Angles(0, rng:NextNumber(0, 6), rng:NextNumber(-0.2, 0.2)), C(80, 112, 142), M.Slate) end
		end
		if style == 'crypt' and rng:NextNumber() < 0.45 then -- fendas e raizes
			local p0 = c + V3(rng:NextNumber(-8, 8), 0.06, rng:NextNumber(-8, 8))
			for k = 0, 3 do P('Crack', V3(0.12, 0.04, 2.2), CF(p0 + V3(k * 0.9, 0, k * 0.7)) * CFrame.Angles(0, rad(25 + k * 22), 0), C(8, 8, 10), M.SmoothPlastic) end
		end
		-- poeira suspensa: brilha onde há luz (lanterna, lustres)
		local dust = P('Dust', V3(S - 2, H - 2, S - 2), CF(c + V3(0, H / 2, 0)), C(0, 0, 0), M.SmoothPlastic, {t = 1})
		local pe = Instance.new('ParticleEmitter')
		pe.Shape = Enum.ParticleEmitterShape.Box; pe.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		pe.Rate = 3; pe.Lifetime = NumberRange.new(8, 12); pe.Speed = NumberRange.new(0.1, 0.4)
		pe.SpreadAngle = Vector2.new(180, 180); pe.Size = NumberSequence.new(0.07); pe.LightInfluence = 1
		pe.Color = ColorSequence.new(C(220, 210, 190)); pe.RotSpeed = NumberRange.new(-20, 20)
		pe.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.4), NumberSequenceKeypoint.new(0.7, 0.4), NumberSequenceKeypoint.new(1, 1)})
		pe.Parent = dust

		if style == 'mansion' then
			if rng:NextNumber() < 0.3 then -- cadeira tombada de costas
				local base = CF(c + V3(rng:NextNumber(-7, 7), 0, rng:NextNumber(-7, 7))) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0)
				local wd = C(62, 40, 28)
				P('FallenBack', V3(1.8, 0.3, 2.6), base * CF(0, 0.15, 0), wd, M.Wood)
				P('FallenSeat', V3(1.8, 1.8, 0.4), base * CF(0, 0.9, 1.5), C(90, 30, 36), M.Fabric)
				for _, x in ipairs({-0.75, 0.75}) do P('FallenLeg', V3(0.3, 0.3, 1.7), base * CF(x, 1.6, 2.3), wd, M.Wood) end
			end
			if rng:NextNumber() < 0.25 then -- quadro caido, virado para o chao
				local base = CF(c + V3(rng:NextNumber(-8, 8), 0.12, rng:NextNumber(-8, 8))) * CFrame.Angles(0, rng:NextNumber(0, 6.28), rad(4))
				P('FallenFrame', V3(3, 0.24, 4), base, GOLD, M.Metal)
				P('FallenCanvas', V3(2.5, 0.06, 3.5), base * CF(0, 0.13, 0), C(40, 30, 26), M.Fabric)
			end
			if rng:NextNumber() < 0.25 then -- velas derretidas no chao (alguem esteve aqui)
				local p0 = c + V3(rng:NextNumber(-8, 8), 0, rng:NextNumber(-8, 8))
				P('Wax', V3(1.6, 0.08, 1.6), CF(p0 + V3(0, 0.04, 0)), C(230, 220, 195), M.SmoothPlastic, {sphere = true})
				for k = 0, 2 do
					local h = 0.4 + k * 0.25
					local q = p0 + V3(math.cos(k * 2.1) * 0.4, 0, math.sin(k * 2.1) * 0.4)
					P('Candle', V3(0.25, h, 0.25), CF(q + V3(0, h / 2, 0)), C(235, 225, 195))
					if k == 2 then flame(q + V3(0, h + 0.2, 0), C(255, 160, 70), 8, 0.6) end
				end
			end
		end
	end end

	local decor = level:FindFirstChild('Decor')
	if style == 'mansion' and decor then
		for _, d in ipairs(decor:GetChildren()) do
			-- passadeira de tapete atravessando cada porta (o lintel tem 1 de altura e 9.9 de comprimento)
			if d.Name == 'DoorFrame' and math.abs(d.Size.Y - 1) < 0.01 then
				local alongZ = d.Size.Z > d.Size.X
				local pos = V3(d.Position.X, 0.07, d.Position.Z)
				P('Runner', alongZ and V3(12, 0.1, 3.8) or V3(3.8, 0.1, 12), CF(pos), C(36, 20, 14), M.Fabric)
				P('Runner', alongZ and V3(12, 0.12, 3) or V3(3, 0.12, 12), CF(pos), C(96, 26, 34), M.Fabric)
			-- luar azulado entrando pelas janelas
			elseif d.Name == 'Pane' then
				local moon = P('Moonlight', d.Size, d.CFrame * CF(0, 0, -0.4), C(0, 0, 0), M.SmoothPlastic, {t = 1})
				local sl = Instance.new('SurfaceLight')
				sl.Face = Enum.NormalId.Front; sl.Color = C(140, 165, 255); sl.Brightness = 1.6
				sl.Range = 20; sl.Angle = 70; sl.Shadows = true; sl.Parent = moon
			end
		end
	end

	return n
end

return D
