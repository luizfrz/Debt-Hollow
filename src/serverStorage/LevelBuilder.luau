-- LevelBuilder v2: mansao / sanatorio / cripta com arquitetura, mobilia e iluminacao.
-- Uso: require(game.ServerStorage.LevelBuilder).build({name = 'Fase1', origin = Vector3.new(0, 0, 0), N = 5, seed = 1, style = 'mansion'})
local B = {}
local V3, CF, M = Vector3.new, CFrame.new, Enum.Material
local rad = math.rad
local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local GOLD = C(190, 150, 70)
local CYL = Enum.PartType.Cylinder

local STYLE = {
	mansion = {H = 16, wall = C(98, 54, 58), wallMat = M.Fabric, wain = C(50, 32, 24), wainMat = M.Wood, rail = C(112, 80, 44),
		floor = C(62, 42, 30), floorMat = M.WoodPlanks, ceiling = C(78, 66, 56), beam = C(38, 24, 16), trim = C(118, 92, 56),
		hallFloor = C(170, 160, 150), hallMat = M.Marble, hallDark = C(26, 22, 24), col = C(150, 142, 132),
		lamp = C(255, 200, 130), light = C(255, 170, 90), br = 0.8, locker = C(56, 38, 28), lockerMat = M.Wood,
		gate = C(30, 30, 34), frame = C(52, 34, 24), center = 'Generator'},
	sanatorium = {H = 13, wall = C(170, 186, 178), wallMat = M.Concrete, wain = C(112, 150, 140), wainMat = M.Marble, rail = C(80, 100, 94),
		floor = C(78, 94, 88), floorMat = M.Marble, ceiling = C(186, 192, 188), beam = C(120, 124, 122), trim = C(150, 160, 156),
		hallFloor = C(150, 170, 160), hallMat = M.Marble, hallDark = C(60, 80, 72), col = C(170, 184, 176),
		lamp = C(200, 255, 230), light = C(170, 255, 220), br = 0.9, locker = C(120, 132, 126), lockerMat = M.Metal,
		gate = C(110, 122, 116), frame = C(96, 106, 102), center = 'Incinerator'},
	crypt = {H = 18, wall = C(60, 56, 66), wallMat = M.Slate, wain = C(44, 40, 50), wainMat = M.Cobblestone, rail = C(36, 32, 40),
		floor = C(34, 32, 38), floorMat = M.Cobblestone, ceiling = C(22, 20, 26), beam = C(30, 26, 32), trim = C(50, 46, 56),
		hallFloor = C(52, 48, 58), hallMat = M.Granite, hallDark = C(52, 48, 58), col = C(70, 66, 78),
		lamp = C(255, 130, 60), light = C(255, 100, 40), br = 1, locker = C(28, 22, 26), lockerMat = M.Wood,
		gate = C(20, 18, 22), frame = C(40, 36, 46), center = 'Altar'},
}

local function part(parent, name, size, cf, color, mat, o)
	o = o or {}
	local p = Instance.new('Part')
	p.Name = name; p.Size = size; p.CFrame = cf; p.Anchored = true
	p.Color = color; p.Material = mat or M.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	if o.t then p.Transparency = o.t end
	if o.shape then p.Shape = o.shape end
	if o.collide == false then p.CanCollide = false; p.CanQuery = false; p.CanTouch = false end
	if o.sphere then local m = Instance.new('SpecialMesh'); m.MeshType = Enum.MeshType.Sphere; m.Parent = p end
	p.Parent = parent
	return p
end

-- centro da fase: gerador / incinerador / altar
local function buildCenter(kind, c, root)
	local ind
	if kind == 'Generator' then
		part(root, 'Center', V3(6, 5, 4), CF(c + V3(0, 2.5, 0)), C(70, 74, 60), M.Metal)
		ind = part(root, 'Indicator', V3(1, 1, 0.3), CF(c + V3(0, 4, 2.1)), C(255, 40, 40), M.Neon)
		ind:SetAttribute('OnColor', C(60, 255, 90))
	elseif kind == 'Incinerator' then
		part(root, 'Center', V3(7, 6, 5), CF(c + V3(0, 3, 0)), C(40, 38, 38), M.Metal)
		part(root, 'Chimney', V3(1.8, 8, 1.8), CF(c + V3(0, 10, 0)), C(34, 32, 32), M.Metal)
		ind = part(root, 'Indicator', V3(3, 2.2, 0.3), CF(c + V3(0, 2.6, 2.6)), C(70, 30, 15), M.Neon)
		ind:SetAttribute('OnColor', C(255, 110, 30))
	else
		part(root, 'AltarBase', V3(11, 1.2, 6), CF(c + V3(0, 0.6, 0)), C(60, 56, 62), M.Slate)
		part(root, 'Center', V3(8, 3, 3.6), CF(c + V3(0, 2.7, 0)), C(74, 68, 78), M.Slate)
		ind = part(root, 'Indicator', V3(2.4, 0.1, 3), CF(c + V3(0, 4.3, 0)), C(120, 20, 20), M.Neon)
		ind:SetAttribute('OnColor', C(255, 235, 200))
		for k = -1, 1 do
			part(root, 'Holder', V3(0.6, 1.4, 0.6), CF(c + V3(k * 3, 4.9, -1.2)), C(20, 18, 20), M.Metal)
			local fl = part(root, 'Flame', V3(0.5, 0.9, 0.5), CF(c + V3(k * 3, 6.1, -1.2)), C(255, 150, 50), M.Neon, {t = 1, collide = false, shape = Enum.PartType.Ball})
			local pl = Instance.new('PointLight'); pl.Color = C(255, 150, 60); pl.Range = 22; pl.Brightness = 2.5; pl.Enabled = false; pl.Parent = fl
		end
	end
	ind:SetAttribute('OffColor', ind.Color)
end

---------------------------------------------------------------------
-- Pecas de mobilia: {profundidade, funcao(p, rng)}; p(nome, tamanho, deslocamento, cor, material, opcoes)
-- frente da peca = -Z; fundo (parede) = +Z
---------------------------------------------------------------------
local function books(p, W, D, y)
	p('Books', V3(W / 2 - 0.6, 1.9, D - 0.5), V3(-W / 4, y, 0.1), C(124, 44, 44), M.Fabric)
	p('Books', V3(W / 2 - 0.6, 1.9, D - 0.5), V3(W / 4, y, 0.1), C(44, 64, 96), M.Fabric)
end

local PIECES = {}
PIECES.mansion = {
	{1.6, function(p) -- estante de livros
		local wd, W, Ht, D = C(54, 36, 26), 7, 11, 1.6
		p('Back', V3(W, Ht, 0.3), V3(0, Ht / 2, D / 2 - 0.15), wd, M.Wood)
		p('Side', V3(0.4, Ht, D), V3(-W / 2 + 0.2, Ht / 2, 0), wd, M.Wood)
		p('Side', V3(0.4, Ht, D), V3(W / 2 - 0.2, Ht / 2, 0), wd, M.Wood)
		for i = 0, 3 do
			p('Shelf', V3(W, 0.3, D), V3(0, 0.3 + i * 2.9, 0), wd, M.Wood)
			books(p, W, D, 1.4 + i * 2.9)
		end
		p('Top', V3(W + 0.4, 0.4, D + 0.2), V3(0, Ht + 0.2, 0), wd, M.Wood)
	end},
	{2.8, function(p) -- sofa
		local c = C(112, 30, 38)
		p('Base', V3(6, 1.3, 2.8), V3(0, 0.65, 0), c, M.Fabric)
		p('Back', V3(6, 2.6, 0.8), V3(0, 2.2, 1), c, M.Fabric)
		p('Arm', V3(0.8, 2, 2.8), V3(-2.8, 1.4, 0), c, M.Fabric)
		p('Arm', V3(0.8, 2, 2.8), V3(2.8, 1.4, 0), c, M.Fabric)
		p('Cushion', V3(2.3, 0.5, 2), V3(-1.2, 1.55, -0.2), C(134, 42, 50), M.Fabric)
		p('Cushion', V3(2.3, 0.5, 2), V3(1.2, 1.55, -0.2), C(134, 42, 50), M.Fabric)
	end},
	{2.8, function(p) -- poltrona
		local c = C(40, 70, 56)
		p('Base', V3(3.2, 1.3, 2.8), V3(0, 0.65, 0), c, M.Fabric)
		p('Back', V3(3.2, 3, 0.8), V3(0, 2.4, 1), c, M.Fabric)
		p('Arm', V3(0.6, 1.9, 2.8), V3(-1.7, 1.4, 0), c, M.Fabric)
		p('Arm', V3(0.6, 1.9, 2.8), V3(1.7, 1.4, 0), c, M.Fabric)
	end},
	{2.2, function(p) -- lareira
		p('Surround', V3(7, 8.5, 2), V3(0, 4.25, 0), C(70, 62, 60), M.Brick)
		p('Opening', V3(3.8, 3.8, 0.6), V3(0, 2.3, -0.8), C(8, 6, 6), M.Slate)
		p('Mantel', V3(8, 0.6, 2.6), V3(0, 5.4, -0.3), C(52, 34, 24), M.Wood)
		p('Log', V3(2.8, 0.6, 0.6), V3(0, 0.7, -0.8), C(40, 26, 18), M.Wood)
		local ember = p('Ember', V3(2, 0.5, 0.5), V3(0, 1.1, -0.8), C(255, 110, 30), M.Neon, {collide = false})
		local l = Instance.new('PointLight'); l.Color = C(255, 120, 40); l.Range = 9; l.Brightness = 0.7; l.Parent = ember
	end},
	{1.8, function(p) -- relogio de pe
		p('Body', V3(2.2, 9, 1.6), V3(0, 4.5, 0), C(56, 36, 26), M.Wood)
		p('Face', V3(1.4, 1.4, 0.12), V3(0, 7.3, -0.8), C(226, 216, 190), M.SmoothPlastic)
		p('Glass', V3(1.4, 3.2, 0.1), V3(0, 3.7, -0.82), C(14, 12, 12), M.Glass)
		p('Pendulum', V3(0.25, 2.4, 0.1), V3(0, 3.4, -0.88), GOLD, M.Metal)
	end},
	{5.2, function(p) -- piano com banco
		p('Body', V3(6.4, 2.4, 2.8), V3(0, 2.8, 1.1), C(14, 12, 14), M.SmoothPlastic)
		p('Lid', V3(6.4, 0.2, 2.8), V3(0, 4.1, 1.1), C(20, 18, 20), M.SmoothPlastic)
		p('Keys', V3(5.6, 0.25, 0.9), V3(0, 3.0, -0.6), C(230, 226, 214), M.SmoothPlastic)
		p('Leg', V3(0.5, 1.6, 0.5), V3(-2.9, 0.8, -0.1), C(14, 12, 14), M.SmoothPlastic)
		p('Leg', V3(0.5, 1.6, 0.5), V3(2.9, 0.8, -0.1), C(14, 12, 14), M.SmoothPlastic)
		p('Bench', V3(3, 1.4, 1.2), V3(0, 0.7, -2.1), C(100, 30, 36), M.Fabric)
	end},
	{2.6, function(p) -- guarda-roupa
		p('Body', V3(5.2, 9.5, 2.6), V3(0, 4.75, 0), C(60, 40, 28), M.Wood)
		p('Crown', V3(5.6, 0.6, 2.9), V3(0, 9.8, 0), C(50, 32, 22), M.Wood)
		p('Seam', V3(0.1, 8.5, 0.1), V3(0, 4.75, -1.35), C(20, 14, 10), M.SmoothPlastic)
		p('Knob', V3(0.25, 0.25, 0.25), V3(-0.4, 4.7, -1.4), GOLD, M.Metal, {collide = false})
		p('Knob', V3(0.25, 0.25, 0.25), V3(0.4, 4.7, -1.4), GOLD, M.Metal, {collide = false})
	end},
	{8, function(p) -- cama de dossel
		local wd = C(60, 40, 28)
		p('Frame', V3(4.6, 1.2, 8), V3(0, 0.6, 0), wd, M.Wood)
		p('Mattress', V3(4.2, 0.7, 7.4), V3(0, 1.55, 0), C(214, 206, 188), M.Fabric)
		p('Pillow', V3(1.7, 0.5, 1.2), V3(-1, 2.1, 3), C(230, 224, 210), M.Fabric)
		p('Pillow', V3(1.7, 0.5, 1.2), V3(1, 2.1, 3), C(230, 224, 210), M.Fabric)
		p('Blanket', V3(4.2, 0.3, 4.2), V3(0, 2, -1.2), C(100, 28, 36), M.Fabric)
		p('Headboard', V3(4.8, 3.5, 0.4), V3(0, 2.6, 3.8), wd, M.Wood)
		p('Post', V3(0.4, 6, 0.4), V3(-2.2, 3, -3.7), wd, M.Wood)
		p('Post', V3(0.4, 6, 0.4), V3(2.2, 3, -3.7), wd, M.Wood)
	end},
	{4.6, function(p) -- mesa de jantar com cadeiras
		local wd = C(62, 40, 28)
		p('Top', V3(7, 0.5, 3.4), V3(0, 3.2, 0.2), wd, M.Wood)
		for _, x in ipairs({-3.1, 3.1}) do for _, z in ipairs({-1.2, 1.6}) do p('Leg', V3(0.5, 3, 0.5), V3(x, 1.5, z), wd, M.Wood) end end
		p('Candle', V3(0.35, 0.9, 0.35), V3(0, 3.95, 0.2), C(230, 220, 190), M.SmoothPlastic)
		p('Flame', V3(0.2, 0.35, 0.2), V3(0, 4.55, 0.2), C(255, 170, 60), M.Neon, {collide = false})
		for _, x in ipairs({-1.8, 1.8}) do
			p('Seat', V3(1.8, 0.4, 1.8), V3(x, 1.9, -2.2), C(90, 30, 36), M.Fabric)
			p('ChairLeg', V3(0.4, 1.7, 0.4), V3(x, 0.85, -2.2), wd, M.Wood)
			p('ChairBack', V3(1.8, 2.6, 0.3), V3(x, 3.2, -3), wd, M.Wood)
		end
	end},
	{1.6, function(p) -- armadura
		local st = C(150, 150, 158)
		p('Pedestal', V3(1.8, 0.8, 1.8), V3(0, 0.4, 0), C(60, 56, 54), M.Slate)
		p('Legs', V3(1.1, 2.2, 0.6), V3(0, 1.9, 0), st, M.Metal)
		p('Chest', V3(1.6, 2.2, 0.9), V3(0, 4.1, 0), st, M.Metal)
		p('Helm', V3(0.95, 1.1, 0.95), V3(0, 5.75, 0), st, M.Metal, {sphere = true})
		p('Visor', V3(0.7, 0.1, 0.1), V3(0, 5.8, -0.5), C(8, 8, 10), M.SmoothPlastic)
		p('Spear', V3(0.18, 8, 0.18), V3(1.3, 4.8, 0), C(70, 50, 34), M.Wood)
		p('Tip', V3(0.35, 0.9, 0.12), V3(1.3, 9, 0), st, M.Metal)
	end},
}

PIECES.sanatorium = {
	{8, function(p) -- cama de enfermaria com soro
		local mt, wh = C(150, 156, 152), C(214, 218, 210)
		p('Frame', V3(3.6, 0.5, 7.6), V3(0, 2.2, 0), mt, M.Metal)
		p('Mattress', V3(3.4, 0.5, 7.2), V3(0, 2.7, 0), wh, M.Fabric)
		p('Pillow', V3(2, 0.4, 1.2), V3(0, 3.1, 2.6), wh, M.Fabric)
		p('Blanket', V3(3.4, 0.2, 3.8), V3(0, 3.05, -1.2), C(130, 150, 142), M.Fabric)
		p('Stain', V3(1.1, 0.05, 1.1), V3(0.4, 3.18, -0.8), C(110, 50, 38), M.Fabric, {collide = false})
		p('Headboard', V3(3.6, 2.2, 0.3), V3(0, 3.1, 3.85), mt, M.Metal)
		for _, x in ipairs({-1.7, 1.7}) do
			p('Leg', V3(0.3, 2, 0.3), V3(x, 1, 3.6), mt, M.Metal); p('Leg', V3(0.3, 2, 0.3), V3(x, 1, -3.6), mt, M.Metal)
			p('Rail', V3(0.15, 0.9, 5), V3(x * 1.03, 3.5, -0.4), mt, M.Metal, {collide = false})
		end
		p('IVPole', V3(0.15, 6.5, 0.15), V3(2.7, 3.25, -2), mt, M.Metal)
		p('IVBag', V3(0.6, 1, 0.3), V3(2.7, 6.2, -2), C(200, 220, 230), M.Glass, {t = 0.35, collide = false})
	end},
	{7, function(p) -- maca com lencol
		local mt = C(150, 156, 152)
		p('Table', V3(3, 0.4, 6.4), V3(0, 3, 0), mt, M.Metal)
		p('Mattress', V3(2.8, 0.4, 6), V3(0, 3.4, 0), C(190, 196, 190), M.Fabric)
		p('Body', V3(1.6, 0.9, 4.4), V3(0, 4.05, 0.2), C(222, 220, 212), M.Fabric, {sphere = true, collide = false})
		p('Post', V3(0.4, 2.2, 0.4), V3(0, 1.8, 2.6), mt, M.Metal)
		p('Post', V3(0.4, 2.2, 0.4), V3(0, 1.8, -2.6), mt, M.Metal)
		for _, x in ipairs({-1.3, 1.3}) do for _, z in ipairs({-2.6, 2.6}) do p('Wheel', V3(0.4, 1, 1), V3(x, 0.5, z), C(30, 30, 32), M.Metal, {shape = CYL, collide = false}) end end
	end},
	{3, function(p) -- cadeira de rodas
		local mt = C(60, 62, 64)
		p('Seat', V3(2.2, 0.3, 2.2), V3(0, 2.6, 0), C(90, 100, 96), M.Fabric)
		p('Back', V3(2.2, 2.4, 0.2), V3(0, 3.8, 1.1), C(90, 100, 96), M.Fabric)
		p('Wheel', V3(0.2, 3, 3), V3(-1.3, 1.5, 0.4), mt, M.Metal, {shape = CYL})
		p('Wheel', V3(0.2, 3, 3), V3(1.3, 1.5, 0.4), mt, M.Metal, {shape = CYL})
		p('Handle', V3(0.15, 0.15, 1), V3(-1.1, 5, 1.5), mt, M.Metal, {collide = false})
		p('Handle', V3(0.15, 0.15, 1), V3(1.1, 5, 1.5), mt, M.Metal, {collide = false})
		p('Foot', V3(1.8, 0.2, 0.8), V3(0, 1.4, -1.5), mt, M.Metal, {collide = false})
	end},
	{1.8, function(p) -- armario de remedios
		p('Body', V3(5, 8, 1.8), V3(0, 4, 0), C(190, 200, 196), M.Metal)
		p('Glass', V3(4.4, 3.2, 0.1), V3(0, 6, -0.92), C(170, 200, 210), M.Glass, {t = 0.5, collide = false})
		p('Bottle', V3(0.5, 0.9, 0.5), V3(-1.3, 5.2, -0.5), C(60, 120, 80), M.Glass, {collide = false})
		p('Bottle', V3(0.5, 1.2, 0.5), V3(0, 5.35, -0.5), C(140, 90, 40), M.Glass, {collide = false})
		p('Bottle', V3(0.5, 0.8, 0.5), V3(1.3, 5.15, -0.5), C(150, 150, 170), M.Glass, {collide = false})
	end},
	{2.2, function(p) -- pia com espelho
		p('Counter', V3(4, 3, 2.2), V3(0, 1.5, 0), C(200, 206, 202), M.Marble)
		p('Basin', V3(2.4, 0.5, 1.4), V3(0, 3.1, -0.1), C(40, 46, 44), M.Metal, {collide = false})
		p('Tap', V3(0.2, 0.9, 0.2), V3(0, 3.6, 0.7), C(170, 170, 176), M.Metal, {collide = false})
		p('Mirror', V3(3, 2.8, 0.15), V3(0, 6.5, 1), C(150, 170, 176), M.Glass, {collide = false})
	end},
	{3.2, function(p) -- escrivaninha
		local wd = C(120, 100, 80)
		p('Top', V3(5, 0.4, 2.4), V3(0, 3.2, 0.2), wd, M.Wood)
		p('Block', V3(1.6, 3, 2.2), V3(-1.7, 1.5, 0.2), wd, M.Wood)
		p('Block', V3(1.6, 3, 2.2), V3(1.7, 1.5, 0.2), wd, M.Wood)
		p('Papers', V3(1.2, 0.05, 1.6), V3(0.4, 3.45, 0.2), C(226, 222, 206), M.Fabric, {collide = false})
		p('Seat', V3(1.6, 0.3, 1.6), V3(0, 1.9, -2.2), C(60, 70, 66), M.Fabric)
		p('ChairLeg', V3(0.4, 1.7, 0.4), V3(0, 0.85, -2.2), C(60, 62, 64), M.Metal)
		p('ChairBack', V3(1.6, 2.4, 0.25), V3(0, 3.2, -3), C(60, 70, 66), M.Fabric)
	end},
	{1, function(p) -- cortina divisoria
		p('Rail', V3(6, 0.15, 0.15), V3(0, 9, 0), C(150, 156, 152), M.Metal, {collide = false})
		for _, x in ipairs({-2, 0, 2}) do p('Cloth', V3(2, 7, 0.12), V3(x, 5.5, 0), C(170, 196, 184), M.Fabric, {t = 0.2, collide = false}) end
	end},
}

PIECES.crypt = {
	{7, function(p) -- tumulo com dois caixoes
		p('Slab', V3(6.2, 0.6, 7), V3(0, 0.3, 0), C(70, 66, 76), M.Slate)
		for _, x in ipairs({-1.5, 1.5}) do
			p('Coffin', V3(2.4, 1.6, 6.2), V3(x, 1.4, 0), C(52, 32, 26), M.Wood)
			p('Lid', V3(2.6, 0.4, 6.4), V3(x, 2.4, 0), C(64, 40, 32), M.Wood)
		end
		p('Candle', V3(0.3, 0.8, 0.3), V3(0, 3.2, -3), C(220, 210, 180), M.SmoothPlastic, {collide = false})
		p('Flame', V3(0.2, 0.35, 0.2), V3(0, 3.8, -3), C(255, 150, 50), M.Neon, {collide = false})
	end},
	{4.6, function(p) -- sarcofago
		p('Base', V3(3.4, 2, 4.4), V3(0, 1, 0), C(84, 80, 90), M.Slate)
		p('Lid', V3(3.7, 0.8, 4.7), V3(0, 2.4, 0), C(96, 92, 102), M.Slate)
		p('Ridge', V3(0.6, 0.5, 4), V3(0, 3, 0), C(110, 106, 116), M.Slate)
		p('CrossV', V3(0.3, 1.2, 0.1), V3(0, 1.1, -2.25), C(140, 136, 148), M.Slate, {collide = false})
		p('CrossH', V3(0.9, 0.3, 0.1), V3(0, 1.4, -2.25), C(140, 136, 148), M.Slate, {collide = false})
	end},
	{2.6, function(p) -- anjo de pedra chorando
		local st = C(120, 118, 126)
		p('Plinth', V3(2.6, 1.4, 2.6), V3(0, 0.7, 0), C(84, 80, 90), M.Slate)
		p('Robe', V3(1.8, 4.6, 1.4), V3(0, 3.7, 0), st, M.Slate)
		p('Head', V3(0.9, 1, 0.9), V3(0, 6.3, -0.1), st, M.Slate, {sphere = true})
		p('Hands', V3(1.2, 0.5, 0.4), V3(0, 6.2, -0.6), st, M.Slate, {collide = false})
		p('Wing', V3(0.3, 4, 2), V3(-1.1, 4.5, 0.5), st, M.Slate, {rz = 0.35, collide = false})
		p('Wing', V3(0.3, 4, 2), V3(1.1, 4.5, 0.5), st, M.Slate, {rz = -0.35, collide = false})
	end},
	{1.6, function(p) -- candelabro de ferro
		local fe = C(26, 24, 26)
		p('Base', V3(1.2, 0.4, 1.2), V3(0, 0.2, 0), fe, M.Metal)
		p('Pole', V3(0.3, 5, 0.3), V3(0, 2.7, 0), fe, M.Metal)
		p('Arms', V3(2.6, 0.2, 0.2), V3(0, 4.6, 0), fe, M.Metal, {collide = false})
		local mid
		for _, x in ipairs({-1.2, 0, 1.2}) do
			p('Candle', V3(0.3, 1, 0.3), V3(x, 5.3, 0), C(220, 210, 180), M.SmoothPlastic, {collide = false})
			local f = p('Flame', V3(0.22, 0.4, 0.22), V3(x, 6, 0), C(255, 150, 50), M.Neon, {collide = false})
			if x == 0 then mid = f end
		end
		local l = Instance.new('PointLight'); l.Color = C(255, 140, 60); l.Range = 11; l.Brightness = 1; l.Parent = mid
	end},
	{3, function(p, rng) -- ossos e cranios
		p('Mound', V3(4, 1.2, 3), V3(0, 0.6, 0), C(190, 184, 170), M.Slate, {sphere = true, collide = false})
		for k = 1, 5 do
			p('Skull', V3(0.8, 0.8, 0.8), V3(rng:NextNumber(-1.6, 1.6), 1.1 + rng:NextNumber(0, 0.3), rng:NextNumber(-1, 1)), C(210, 204, 188), M.Slate, {sphere = true, collide = false})
		end
	end},
	{0.8, function(p) -- grades de ferro
		local fe = C(30, 28, 32)
		for k = 0, 8 do p('Bar', V3(0.2, 9, 0.2), V3(-3.2 + k * 0.8, 4.5, 0), fe, M.Metal) end
		p('Rail', V3(7, 0.3, 0.3), V3(0, 1, 0), fe, M.Metal, {collide = false})
		p('Rail', V3(7, 0.3, 0.3), V3(0, 8.5, 0), fe, M.Metal, {collide = false})
	end},
}

-- decoracao de parede (alto, sem colisao)
local DECOR = {
	mansion = function(p, rng) -- retrato de familia; as vezes os olhos brilham
		p('Frame', V3(4, 5.4, 0.4), V3(0, 8, 0.05), GOLD, M.Metal)
		p('Canvas', V3(3.4, 4.8, 0.3), V3(0, 8, -0.05), C(30, 26, 24), M.Fabric)
		p('Shoulders', V3(2.6, 1.6, 0.2), V3(0, 7, -0.2), C(14, 12, 14), M.Fabric, {sphere = true})
		p('Face', V3(1.3, 1.8, 0.2), V3(0, 8.4, -0.22), C(168, 150, 124), M.SmoothPlastic, {sphere = true})
		if rng:NextNumber() < 0.25 then
			p('Eye', V3(0.25, 0.15, 0.1), V3(-0.3, 8.55, -0.34), C(255, 30, 30), M.Neon)
			p('Eye', V3(0.25, 0.15, 0.1), V3(0.3, 8.55, -0.34), C(255, 30, 30), M.Neon)
		end
	end,
	sanatorium = function(p) -- quadro de avisos / prontuario
		p('Board', V3(3.6, 2.6, 0.2), V3(0, 6.5, 0.1), C(206, 210, 200), M.Fabric)
		for k = 0, 2 do p('Line', V3(3, 0.1, 0.05), V3(0, 7.2 - k * 0.6, -0.05), C(70, 74, 70), M.SmoothPlastic) end
	end,
	crypt = function(p) -- relevo de pedra com cruz
		p('Plaque', V3(3, 4, 0.4), V3(0, 8, 0.1), C(48, 44, 54), M.Slate)
		p('CrossV', V3(0.4, 2.6, 0.2), V3(0, 8, -0.15), C(120, 116, 128), M.Slate)
		p('CrossH', V3(1.6, 0.4, 0.2), V3(0, 8.6, -0.15), C(120, 116, 128), M.Slate)
	end,
}

local WINDOW = {
	mansion = function(p, rng, th)
		p('Frame', V3(3.8, 7, 0.5), V3(0, 8, 0.1), th.frame, M.Wood)
		p('Pane', V3(3, 6.2, 0.2), V3(0, 8, -0.05), C(110, 130, 190), M.Neon, {t = 0.4, collide = false})
		p('Mullion', V3(0.15, 6.2, 0.1), V3(0, 8, -0.2), th.frame, M.Wood, {collide = false})
		p('Mullion', V3(3, 0.15, 0.1), V3(0, 8, -0.2), th.frame, M.Wood, {collide = false})
		p('Curtain', V3(1, 7.4, 0.6), V3(-2.2, 7.6, -0.3), C(100, 28, 36), M.Fabric, {collide = false})
		p('Curtain', V3(1, 7.4, 0.6), V3(2.2, 7.6, -0.3), C(100, 28, 36), M.Fabric, {collide = false})
		p('Valance', V3(5.4, 0.9, 0.7), V3(0, 11.7, -0.3), C(120, 34, 42), M.Fabric, {collide = false})
	end,
	sanatorium = function(p, rng, th)
		p('Frame', V3(2.4, 3, 0.4), V3(0, 9.5, 0.1), th.frame, M.Metal)
		p('Pane', V3(2, 2.6, 0.2), V3(0, 9.5, -0.05), C(190, 230, 220), M.Neon, {t = 0.5, collide = false})
		p('Bar', V3(0.12, 2.6, 0.1), V3(-0.4, 9.5, -0.2), th.frame, M.Metal, {collide = false})
		p('Bar', V3(0.12, 2.6, 0.1), V3(0.4, 9.5, -0.2), th.frame, M.Metal, {collide = false})
	end,
}

---------------------------------------------------------------------
function B.build(cfg)
	local rng = Random.new(cfg.seed or 1)
	local N, S = cfg.N, cfg.S or 28
	local style = cfg.style
	local th = STYLE[style]
	local H, T, GAP, DH, half = th.H, 1, 8, 10, S / 2
	local O = cfg.origin

	local root = Instance.new('Folder'); root.Name = cfg.name
	root:SetAttribute('Origin', O); root:SetAttribute('N', N); root:SetAttribute('S', S)
	local function folder(n) local f = Instance.new('Folder'); f.Name = n; f.Parent = root; return f end
	local shell, walls, props, decor = folder('Shell'), folder('Walls'), folder('Props'), folder('Decor')
	local spots, lockers, lamps = folder('Spots'), folder('Lockers'), folder('Lamps')
	local function Cc(i, j) return O + V3(i * S, 0, j * S) end
	local function key(i, j) return i * 100 + j end

	-- labirinto (DFS) + aberturas extras
	local openE, openN, visited = {}, {}, {}
	local function dfs(i, j)
		visited[key(i, j)] = true
		local dirs = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}}
		for k = #dirs, 2, -1 do local r = rng:NextInteger(1, k); dirs[k], dirs[r] = dirs[r], dirs[k] end
		for _, d in ipairs(dirs) do
			local ni, nj = i + d[1], j + d[2]
			if ni >= 0 and ni < N and nj >= 0 and nj < N and not visited[key(ni, nj)] then
				if d[1] == 1 then openE[key(i, j)] = true
				elseif d[1] == -1 then openE[key(ni, nj)] = true
				elseif d[2] == 1 then openN[key(i, j)] = true
				else openN[key(ni, nj)] = true end
				dfs(ni, nj)
			end
		end
	end
	dfs(0, 0)
	for i = 0, N - 1 do for j = 0, N - 1 do
		if i < N - 1 and not openE[key(i, j)] and rng:NextNumber() < 0.28 then openE[key(i, j)] = true end
		if j < N - 1 and not openN[key(i, j)] and rng:NextNumber() < 0.28 then openN[key(i, j)] = true end
	end end

	local function sideOpen(i, j) -- portas de cada lado da celula
		return {
			E = (i < N - 1) and openE[key(i, j)] or (i == N - 1 and j == N - 1),
			W = (i > 0) and openE[key(i - 1, j)] or false,
			N = (j < N - 1) and openN[key(i, j)] or false,
			S = (j > 0) and openN[key(i, j - 1)] or false,
		}
	end

	-- parede com vao de porta, moldura e folha entreaberta
	local function wall(cx, cz, alongZ, hasDoor)
		local function seg(len, off, h, y)
			local size = alongZ and V3(T, h, len) or V3(len, h, T)
			local pos = alongZ and V3(cx, y, cz + off) or V3(cx + off, y, cz)
			part(walls, 'Wall', size, CF(pos), th.wall, th.wallMat)
		end
		if not hasDoor then seg(S + T, 0, H, H / 2) return end
		local side = (S - GAP) / 2
		seg(side + T / 2, -(GAP / 2 + side / 2), H, H / 2)
		seg(side + T / 2, (GAP / 2 + side / 2), H, H / 2)
		seg(GAP, 0, H - DH, DH + (H - DH) / 2)
		local fmat = th.wainMat == M.Marble and M.Metal or M.Wood
		local function fr(len, off, h, y)
			local size = alongZ and V3(T + 1.2, h, len) or V3(len, h, T + 1.2)
			local pos = alongZ and V3(cx, y, cz + off) or V3(cx + off, y, cz)
			part(decor, 'DoorFrame', size, CF(pos), th.frame, fmat, {collide = false})
		end
		fr(0.9, -(GAP / 2 + 0.05), DH, DH / 2); fr(0.9, GAP / 2 + 0.05, DH, DH / 2); fr(GAP + 1.9, 0, 1, DH + 0.5)
		if style ~= 'crypt' and rng:NextNumber() < 0.5 then
			local phi = rad(rng:NextInteger(55, 80)) * (rng:NextInteger(0, 1) == 0 and 1 or -1)
			local w, h = GAP / 2 - 0.2, DH - 0.4
			if alongZ then
				local d = V3(math.sin(phi), 0, math.cos(phi))
				part(decor, 'DoorLeaf', V3(0.3, h, w), CF(V3(cx, h / 2 + 0.2, cz - GAP / 2) + d * (w / 2)) * CFrame.Angles(0, phi, 0), th.frame, fmat, {collide = false})
			else
				local d = V3(math.cos(phi), 0, -math.sin(phi))
				part(decor, 'DoorLeaf', V3(w, h, 0.3), CF(V3(cx - GAP / 2, h / 2 + 0.2, cz) + d * (w / 2)) * CFrame.Angles(0, phi, 0), th.frame, fmat, {collide = false})
			end
		end
	end

	-- lambri, rodape, friso e sanca de cada lado da celula (sem tapar as portas)
	local function trim(c, doors)
		for side, open in pairs(doors) do
			local horiz = (side == 'E' or side == 'W')
			local sgn = (side == 'E' or side == 'N') and 1 or -1
			local segs = open and {{-half + 0.5, -GAP / 2 - 0.5}, {GAP / 2 + 0.5, half - 0.5}} or {{-half + 0.5, half - 0.5}}
			for _, sg in ipairs(segs) do
				local len, mid = sg[2] - sg[1], (sg[1] + sg[2]) / 2
				local function put(name, thick, h, y, inset, color, mat)
					local off = sgn * (half - 0.5 - inset)
					local size = horiz and V3(thick, h, len) or V3(len, h, thick)
					local pos = horiz and V3(off, y, mid) or V3(mid, y, off)
					part(decor, name, size, CF(c + pos), color, mat, {collide = false})
				end
				put('Wainscot', 0.3, 5, 2.5, 0.15, th.wain, th.wainMat)
				put('Rail', 0.55, 0.4, 5.2, 0.27, th.rail, M.Wood)
				put('Baseboard', 0.5, 0.8, 0.4, 0.25, th.rail, M.Wood)
			end
			local off = sgn * (half - 0.9)
			local size = horiz and V3(0.8, 0.8, S - 1) or V3(S - 1, 0.8, 0.8)
			local pos = horiz and V3(off, H - 0.4, 0) or V3(0, H - 0.4, off)
			part(decor, 'Crown', size, CF(c + pos), th.trim, M.Wood, {collide = false})
		end
	end

	-- peca encostada na parede; side E/W/N/S, a = posicao ao longo da parede
	local function piece(c, side, a, depth, fn, parent, collide)
		local d = half - 0.5 - depth / 2
		local x, z, ry
		if side == 'E' then x, z, ry = d, a, 90 elseif side == 'W' then x, z, ry = -d, a, -90
		elseif side == 'N' then x, z, ry = a, d, 0 else x, z, ry = a, -d, 180 end
		local base = CF(c + V3(x, 0, z)) * CFrame.Angles(0, rad(ry), 0)
		local function p(name, size, off, color, mat, o)
			o = o or {}
			if o.collide == nil then o.collide = collide end
			return part(parent, name, size, base * CF(off) * CFrame.Angles(o.rx or 0, o.ry or 0, o.rz or 0), color, mat, o)
		end
		fn(p, rng, th)
	end
	local function slot(c, q, fn, depth, parent, collide) -- escolhe a parede do quadrante
		if rng:NextNumber() < 0.5 then piece(c, q[1] > 0 and 'E' or 'W', q[2] * 9.5, depth, fn, parent, collide)
		else piece(c, q[2] > 0 and 'N' or 'S', q[1] * 9.5, depth, fn, parent, collide) end
	end

	local function addLight(c, big)
		local y, lamp = H - 3, nil
		if style == 'mansion' then
			part(decor, 'Chain', V3(0.2, 3, 0.2), CF(c + V3(0, H - 1.5, 0)), C(30, 26, 22), M.Metal, {collide = false})
			for k = 0, 5 do
				local a = rad(k * 60)
				part(decor, 'Arm', V3(2.6, 0.2, 0.2), CF(c + V3(math.cos(a) * 1.3, y, math.sin(a) * 1.3)) * CFrame.Angles(0, -a, 0), GOLD, M.Metal, {collide = false})
				part(decor, 'Candle', V3(0.3, 0.8, 0.3), CF(c + V3(math.cos(a) * 2.6, y + 0.5, math.sin(a) * 2.6)), C(230, 220, 190), M.SmoothPlastic, {collide = false})
				part(decor, 'Flame', V3(0.2, 0.35, 0.2), CF(c + V3(math.cos(a) * 2.6, y + 1.1, math.sin(a) * 2.6)), C(255, 170, 60), M.Neon, {collide = false})
			end
			lamp = part(lamps, 'Lamp', V3(0.8, 0.8, 0.8), CF(c + V3(0, y, 0)), th.lamp, M.Neon, {collide = false})
		elseif style == 'sanatorium' then
			part(decor, 'Housing', V3(7.4, 0.4, 1.6), CF(c + V3(0, H - 0.2, 0)), C(120, 124, 122), M.Metal, {collide = false})
			lamp = part(lamps, 'Lamp', V3(7, 0.3, 1.2), CF(c + V3(0, H - 0.5, 0)), th.lamp, M.Neon, {collide = false})
		else
			part(decor, 'Chain', V3(0.2, 4, 0.2), CF(c + V3(0, H - 2, 0)), C(24, 22, 24), M.Metal, {collide = false})
			part(decor, 'Bowl', V3(0.8, 2.4, 2.4), CF(c + V3(0, H - 4.2, 0)) * CFrame.Angles(0, 0, rad(90)), C(30, 26, 24), M.Metal, {shape = CYL, collide = false})
			lamp = part(lamps, 'Lamp', V3(1, 1.4, 1), CF(c + V3(0, H - 3.7, 0)), th.lamp, M.Neon, {collide = false, sphere = true})
		end
		local pl = Instance.new('PointLight')
		pl.Brightness = th.br * (big and 1.3 or 1); pl.Range = big and 24 or 16; pl.Color = th.light; pl.Shadows = true; pl.Parent = lamp
		lamp:SetAttribute('Base', pl.Brightness)
	end

	local function hall(c) -- salao central: piso xadrez / circulo ritual, colunas, luz forte
		if style ~= 'crypt' then
			for gx = -2, 2 do for gz = -2, 2 do
				if (gx + gz) % 2 == 0 then part(shell, 'Tile', V3(5.6, 0.12, 5.6), CF(c + V3(gx * 5.6, 0.06, gz * 5.6)), th.hallDark, th.hallMat, {collide = false}) end
			end end
		else
			part(shell, 'RuneRing', V3(0.12, 21, 21), CF(c + V3(0, 0.07, 0)) * CFrame.Angles(0, 0, rad(90)), C(150, 24, 24), M.Neon, {shape = CYL, collide = false})
			part(shell, 'RuneInner', V3(0.14, 19.4, 19.4), CF(c + V3(0, 0.08, 0)) * CFrame.Angles(0, 0, rad(90)), th.hallFloor, th.hallMat, {shape = CYL, collide = false})
		end
		for _, sx in ipairs({-1, 1}) do for _, sz in ipairs({-1, 1}) do
			local p0 = c + V3(sx * 9, 0, sz * 9)
			part(decor, 'ColBase', V3(3.2, 0.8, 3.2), CF(p0 + V3(0, 0.4, 0)), th.col, M.Marble)
			part(decor, 'ColShaft', V3(H - 2.4, 2.2, 2.2), CF(p0 + V3(0, H / 2, 0)) * CFrame.Angles(0, 0, rad(90)), th.col, M.Marble, {shape = CYL})
			part(decor, 'ColCap', V3(3.2, 0.8, 3.2), CF(p0 + V3(0, H - 0.4, 0)), th.col, M.Marble)
		end end
		addLight(c, true)
	end

	local ci = math.floor(N / 2)
	local QUADS = {{1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
	for i = 0, N - 1 do for j = 0, N - 1 do
		local c = Cc(i, j)
		local doors = sideOpen(i, j)
		local isStart, isCenter = (i == 0 and j == 0), (i == ci and j == ci)

		if isCenter then part(shell, 'Floor', V3(S, 1, S), CF(c + V3(0, -0.5, 0)), th.hallFloor, th.hallMat)
		else part(shell, 'Floor', V3(S, 1, S), CF(c + V3(0, -0.5, 0)), th.floor:Lerp(Color3.new(1, 1, 1), rng:NextNumber() * 0.1), th.floorMat) end
		part(shell, 'Ceiling', V3(S, 1, S), CF(c + V3(0, H + 0.5, 0)), th.ceiling, M.Concrete)

		if i < N - 1 then wall(c.X + half, c.Z, true, openE[key(i, j)]) else wall(c.X + half, c.Z, true, j == N - 1) end
		if j < N - 1 then wall(c.X, c.Z + half, false, openN[key(i, j)]) else wall(c.X, c.Z + half, false, false) end
		if i == 0 then wall(c.X - half, c.Z, true, false) end
		if j == 0 then wall(c.X, c.Z - half, false, false) end
		trim(c, doors)

		-- teto: vigas / canos / nervuras; teias de aranha
		if style == 'sanatorium' then
			if rng:NextNumber() < 0.6 then part(decor, 'Pipe', V3(S - 1, 0.5, 0.5), CF(c + V3(0, H - 1.2, rng:NextInteger(0, 1) == 0 and -10 or 10)), th.beam, M.Metal, {shape = CYL, collide = false}) end
		elseif style == 'mansion' then
			for _, z in ipairs({-7, 7}) do part(decor, 'Beam', V3(S - 1, 0.9, 0.9), CF(c + V3(0, H - 1, z)), th.beam, M.Wood, {collide = false}) end
		else
			part(decor, 'Rib', V3(S - 1, 1, 1), CF(c + V3(0, H - 0.6, 0)), th.beam, M.Slate, {collide = false})
			part(decor, 'Rib', V3(1, 1, S - 1), CF(c + V3(0, H - 0.6, 0)), th.beam, M.Slate, {collide = false})
		end
		if rng:NextNumber() < 0.5 then
			local sx, sz = (rng:NextInteger(0, 1) == 0) and -1 or 1, (rng:NextInteger(0, 1) == 0) and -1 or 1
			part(decor, 'Cobweb', V3(3.4, 0.05, 3.4), CF(c + V3(sx * (half - 1.8), H - 1.2, sz * (half - 1.8))) * CFrame.Angles(0, rad(45), 0), C(235, 235, 235), M.Fabric, {t = 0.75, collide = false})
		end

		if isCenter then hall(c)
		else
			local used = {}
			local function qk(q) return q[1] .. ',' .. q[2] end
			if not isStart then
				local fs = part(spots, 'Spot', V3(1, 1, 1), CF(c + V3(rng:NextInteger(-4, 4), 1, rng:NextInteger(-4, 4))), Color3.new(1, 1, 1), M.Plastic, {t = 1, collide = false})
				if rng:NextNumber() < 0.45 then
					local sx = rng:NextInteger(0, 1) == 0 and -1 or 1
					local sz = rng:NextInteger(0, 1) == 0 and -1 or 1
					local pos = c + V3(sx * (half - 1.9), 3.5, sz * 9.5)
					local lk = part(lockers, 'Locker', V3(3.2, 7, 3.2), CF(pos), th.locker, th.lockerMat)
					lk:SetAttribute('Facing', V3(-sx, 0, 0))
					part(lockers, 'Slit', V3(0.12, 4.6, 2), CF(pos + V3(-sx * 1.62, 0.4, 0)), C(6, 6, 6), M.SmoothPlastic, {collide = false})
					local pp = Instance.new('ProximityPrompt')
					pp.ObjectText = 'Armario'; pp.ActionText = 'Esconder-se'; pp.HoldDuration = 0.4
					pp.MaxActivationDistance = 6; pp.RequiresLineOfSight = false; pp.Parent = lk
					used[qk({sx, sz})] = true
				end
			end
			local quads = {table.unpack(QUADS)}
			for k = #quads, 2, -1 do local r = rng:NextInteger(1, k); quads[k], quads[r] = quads[r], quads[k] end
			local want = isStart and 1 or rng:NextInteger(2, 3)
			local list = PIECES[style]
			for _, q in ipairs(quads) do
				if want <= 0 then break end
				if not used[qk(q)] then
					local e = list[rng:NextInteger(1, #list)]
					slot(c, q, e[2], e[1], props, true)
					used[qk(q)] = true; want -= 1
				end
			end
			for _, q in ipairs(quads) do -- quadros nas paredes que sobraram
				if not used[qk(q)] and rng:NextNumber() < 0.8 then slot(c, q, DECOR[style], 0.5, decor, false) end
			end
			local win = WINDOW[style]
			if win then -- janelas nas paredes externas
				local outer = {}
				if i == 0 then outer[#outer + 1] = 'W' end
				if i == N - 1 and j ~= N - 1 then outer[#outer + 1] = 'E' end
				if j == 0 then outer[#outer + 1] = 'S' end
				if j == N - 1 then outer[#outer + 1] = 'N' end
				for _, side in ipairs(outer) do if rng:NextNumber() < 0.75 then piece(c, side, 0, 0.5, win, decor, false) end end
			end
			if style == 'mansion' and rng:NextNumber() < 0.5 then -- tapete
				local rot = CFrame.Angles(0, rad(rng:NextInteger(0, 1) * 90), 0)
				part(decor, 'RugBorder', V3(11.6, 0.1, 7.6), CF(c + V3(0, 0.05, 0)) * rot, C(40, 24, 14), M.Fabric, {collide = false})
				part(decor, 'Rug', V3(10.6, 0.12, 6.6), CF(c + V3(0, 0.06, 0)) * rot, C(104, 30, 40), M.Fabric, {collide = false})
			elseif style == 'crypt' and rng:NextNumber() < 0.25 then -- poca d'agua
				part(decor, 'Puddle', V3(4, 0.06, 3), CF(c + V3(rng:NextInteger(-8, 8), 0.04, rng:NextInteger(-8, 8))), C(30, 50, 70), M.Glass, {t = 0.3, sphere = true, collide = false})
			end
			if (i + j) % 3 == 0 then addLight(c, false) end
		end
	end end

	-- pontos fixos: spawn, monstro, centro, saida
	local sp = part(root, 'Spawn', V3(6, 1, 6), CF(Cc(0, 0) + V3(0, 0.5, 0)), Color3.new(1, 1, 1), M.Plastic, {t = 1, collide = false})
	part(root, 'MonsterSpawn', V3(2, 1, 2), CF(Cc(N - 1, 0) + V3(0, 1, 0)), Color3.new(1, 1, 1), M.Plastic, {t = 1, collide = false})
	buildCenter(th.center, Cc(ci, ci), root)

	local ec = Cc(N - 1, N - 1)
	local gateX = ec.X + half
	local gate = part(root, 'Gate', V3(1, 10, 8), CF(gateX, 5, ec.Z), th.gate, M.Metal)
	gate:SetAttribute('ClosedCF', gate.CFrame)
	part(root, 'ExitZone', V3(14, 10, 14), CF(gateX + 9, 5, ec.Z), Color3.new(1, 1, 1), M.Plastic, {t = 1, collide = false})
	part(shell, 'OutsideGround', V3(40, 1, 40), CF(gateX + 20, -0.5, ec.Z), th.floor, th.floorMat)

	return root
end

return B
