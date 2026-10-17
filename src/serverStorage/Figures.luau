-- Figures: as três personagens dos retratos (Augustus, Eleanora, Clara) como modelos 3D.
-- Origem nos pés (y = 0), frente = -Z. Uso: Figures.build("Clara") -> Model (PrimaryPart = Root)
local M = {}
local V = Vector3.new
local function C(r, g, b) return Color3.fromRGB(r, g, b) end

local function newFigure(name)
	local model = Instance.new("Model"); model.Name = name
	local root = Instance.new("Part")
	root.Name = "Root"; root.Size = V(1, 1, 1); root.Transparency = 1; root.Anchored = true; root.CanCollide = false
	root.CanQuery = false; root.CanTouch = false; root.Parent = model
	model.PrimaryPart = root
	local F = {model = model}
	-- kind: "b" bloco, "e" elipsoide, "v" cilindro vertical (size = diâmetro, altura, diâmetro)
	function F.P(pname, kind, size, off, color, o)
		o = o or {}
		local p = Instance.new("Part")
		p.Name = pname; p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
		p.Color = color; p.Material = o.mat or Enum.Material.SmoothPlastic; p.Transparency = o.t or 0
		p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
		local rot = CFrame.Angles(o.rx or 0, o.ry or 0, o.rz or 0)
		if kind == "v" then
			p.Shape = Enum.PartType.Cylinder
			p.Size = V(size.Y, size.X, size.Z)
			p.CFrame = CFrame.new(off) * rot * CFrame.Angles(0, 0, math.pi / 2)
		else
			p.Size = size
			p.CFrame = CFrame.new(off) * rot
			if kind == "e" then
				local m = Instance.new("SpecialMesh"); m.MeshType = Enum.MeshType.Sphere; m.Parent = p
			end
		end
		if o.glow then
			local l = Instance.new("PointLight"); l.Color = color; l.Range = o.glow[1]; l.Brightness = o.glow[2]; l.Parent = p
		end
		p.Parent = model
		return p
	end
	return F
end

local BUILD = {}

-- AUGUSTUS HOLLOW — o patriarca: grisalho, barbudo, óculos dourados com olhos vermelhos.
function BUILD.Augustus()
	local F = newFigure("Augustus")
	local P = F.P
	local skin, skinD, grey = C(196, 172, 150), C(168, 142, 124), C(132, 130, 134)
	local coat, coat2, white, gold, black = C(20, 18, 24), C(40, 36, 46), C(232, 228, 218), C(190, 150, 70), C(10, 10, 12)
	for _, s in ipairs({-1, 1}) do
		P("Shoe", "b", V(0.7, 0.4, 1.3), V(0.45 * s, 0.2, -0.2), black)
		P("Leg", "b", V(0.7, 2.4, 0.8), V(0.45 * s, 1.6, 0), black)
		P("CoatTail", "b", V(0.95, 1.5, 0.45), V(0.5 * s, 2.5, 0.55), coat, {rx = -0.12, mat = Enum.Material.Fabric})
		P("Arm", "b", V(0.55, 2.2, 0.55), V(1.35 * s, 3.9, 0), coat, {rz = 0.04 * s, mat = Enum.Material.Fabric})
		P("Hand", "b", V(0.45, 0.55, 0.45), V(1.35 * s, 2.55, 0), skin)
		P("Lapel", "b", V(0.45, 1.8, 0.1), V(0.5 * s, 4.05, -0.58), coat2, {rz = 0.28 * s, mat = Enum.Material.Fabric})
		P("Collar", "b", V(0.3, 0.38, 0.1), V(0.27 * s, 5.05, -0.5), white, {rz = 0.5 * s})
		P("Ear", "e", V(0.18, 0.4, 0.25), V(0.66 * s, 6.05, 0), skinD)
		P("Tuft", "e", V(0.35, 0.8, 0.35), V(0.62 * s, 6.25, -0.05), grey)
		P("Brow", "b", V(0.42, 0.09, 0.1), V(0.28 * s, 6.42, -0.62), grey, {rz = 0.2 * s})
		P("Cheek", "e", V(0.3, 0.4, 0.1), V(0.42 * s, 5.95, -0.55), C(96, 70, 60), {t = 0.7})
		P("GlassRim", "e", V(0.5, 0.45, 0.08), V(0.28 * s, 6.25, -0.64), gold, {mat = Enum.Material.Metal})
		P("Eye", "e", V(0.36, 0.3, 0.08), V(0.28 * s, 6.25, -0.67), C(255, 30, 30), {mat = Enum.Material.Neon, glow = {7, 0.8}})
		P("Mustache", "e", V(0.42, 0.16, 0.2), V(0.22 * s, 5.88, -0.68), grey, {rz = -0.15 * s})
	end
	P("Torso", "b", V(2.1, 2.3, 1.1), V(0, 3.95, 0), coat, {mat = Enum.Material.Fabric})
	P("Shirt", "b", V(0.7, 1.7, 0.08), V(0, 4.1, -0.56), white)
	P("Cravat", "b", V(0.45, 0.5, 0.12), V(0, 4.85, -0.6), black)
	P("Pin", "e", V(0.1, 0.1, 0.1), V(0, 4.8, -0.68), gold, {mat = Enum.Material.Metal})
	P("Chain", "b", V(0.9, 0.05, 0.04), V(0.6, 3.9, -0.6), gold, {rz = -0.45, mat = Enum.Material.Metal})
	P("Watch", "e", V(0.4, 0.4, 0.1), V(1.0, 3.55, -0.62), gold, {mat = Enum.Material.Metal})
	P("WatchFace", "e", V(0.3, 0.3, 0.06), V(1.0, 3.55, -0.68), C(236, 230, 214))
	P("Neck", "b", V(0.5, 0.4, 0.5), V(0, 5.25, 0), skinD)
	P("Head", "e", V(1.3, 1.6, 1.3), V(0, 6.15, 0), skin)
	P("HairBack", "e", V(1.45, 1.2, 1.35), V(0, 6.5, 0.15), grey)
	P("Forehead", "e", V(0.6, 0.25, 0.1), V(0, 6.75, -0.55), C(230, 210, 190), {t = 0.6})
	P("Bridge", "b", V(0.2, 0.05, 0.05), V(0, 6.27, -0.67), gold, {mat = Enum.Material.Metal})
	P("Nose", "e", V(0.22, 0.5, 0.3), V(0, 6.0, -0.66), C(172, 146, 128))
	P("Beard", "e", V(0.9, 0.75, 0.6), V(0, 5.55, -0.4), grey)
	P("Mouth", "b", V(0.34, 0.04, 0.05), V(0, 5.74, -0.72), C(52, 30, 28))
	return F.model
end

-- ELEANORA HOLLOW — vestido azul-esverdeado, pérolas, lágrima, contrato queimado nas mãos.
function BUILD.Eleanora()
	local F = newFigure("Eleanora")
	local P = F.P
	local teal, tealD, lace = C(40, 82, 92), C(30, 62, 70), C(236, 232, 222)
	local skin, hair, gold = C(224, 208, 194), C(64, 46, 40), C(190, 150, 70)
	P("Skirt1", "v", V(3.4, 1.2, 3.4), V(0, 0.6, 0), tealD, {mat = Enum.Material.Fabric})
	P("Skirt2", "v", V(2.9, 1.2, 2.9), V(0, 1.8, 0), teal, {mat = Enum.Material.Fabric})
	P("Skirt3", "v", V(2.4, 1.1, 2.4), V(0, 2.95, 0), tealD, {mat = Enum.Material.Fabric})
	for k = 0, 15 do
		local a = k / 16 * math.pi * 2
		P("LaceHem", "e", V(0.34, 0.34, 0.34), V(math.cos(a) * 1.7, 0.18, math.sin(a) * 1.7), lace)
	end
	P("Bodice", "b", V(1.5, 1.7, 0.95), V(0, 4.3, 0), teal, {mat = Enum.Material.Fabric})
	P("LaceChest", "e", V(1.1, 0.8, 0.5), V(0, 4.8, -0.4), lace)
	P("HighCollar", "v", V(0.65, 0.5, 0.65), V(0, 5.4, 0), lace)
	for k = -4, 4 do P("Pearl", "e", V(0.14, 0.14, 0.14), V(k * 0.13, 4.95 - (16 - k * k) * 0.012, -0.62), C(246, 242, 236)) end
	P("Cameo", "e", V(0.3, 0.36, 0.08), V(0, 4.62, -0.66), gold, {mat = Enum.Material.Metal})
	P("CameoIn", "e", V(0.2, 0.26, 0.06), V(0, 4.62, -0.7), C(218, 196, 196))
	P("Head", "e", V(1.1, 1.4, 1.1), V(0, 6.15, 0), skin)
	P("HairBack", "e", V(1.25, 1.3, 1.15), V(0, 6.3, 0.15), hair)
	P("Bun", "e", V(0.62, 0.62, 0.62), V(0, 7.05, 0.2), hair)
	P("Ribbon", "b", V(0.85, 0.07, 0.5), V(0, 6.85, -0.05), C(120, 60, 66))
	P("Nose", "e", V(0.12, 0.35, 0.2), V(0, 6.0, -0.55), C(206, 184, 170))
	P("Lips", "e", V(0.3, 0.1, 0.12), V(0, 5.78, -0.55), C(150, 78, 86))
	P("Tear", "e", V(0.06, 0.2, 0.05), V(0.28, 5.95, -0.58), C(150, 205, 255), {t = 0.25})
	for _, s in ipairs({-1, 1}) do
		P("HairFront", "e", V(0.7, 0.55, 0.4), V(0.3 * s, 6.65, -0.38), hair, {rz = 0.45 * s})
		P("Streak", "b", V(0.04, 0.6, 0.04), V(0.5 * s, 6.5, -0.56), C(192, 192, 198), {rz = 0.4 * s})
		P("EyeWhite", "e", V(0.32, 0.17, 0.08), V(0.26 * s, 6.2, -0.56), C(238, 238, 244))
		P("Iris", "e", V(0.17, 0.17, 0.08), V(0.26 * s, 6.2, -0.6), C(120, 175, 255), {mat = Enum.Material.Neon, glow = {6, 0.6}})
		P("Lid", "b", V(0.36, 0.04, 0.06), V(0.26 * s, 6.31, -0.58), C(52, 38, 34))
		P("Brow", "b", V(0.34, 0.05, 0.06), V(0.26 * s, 6.45, -0.57), hair, {rz = -0.15 * s})
		P("Blush", "e", V(0.3, 0.18, 0.05), V(0.4 * s, 5.9, -0.5), C(214, 150, 150), {t = 0.75})
		P("Sleeve", "b", V(0.45, 1.7, 0.45), V(0.95 * s, 4.0, -0.55), teal, {rx = -0.7, rz = -0.06 * s, mat = Enum.Material.Fabric})
		P("Hand", "e", V(0.4, 0.3, 0.4), V(0.38 * s, 3.4, -1.15), skin)
	end
	P("Contract", "b", V(0.9, 0.04, 1.2), V(0, 3.5, -1.25), C(232, 220, 190), {rx = 0.3})
	P("Burn1", "e", V(0.4, 0.05, 0.4), V(-0.35, 3.55, -1.65), C(40, 22, 16), {rx = 0.3})
	P("Burn2", "e", V(0.3, 0.05, 0.25), V(0.4, 3.45, -0.8), C(40, 22, 16), {rx = 0.3})
	P("Ember", "e", V(0.09, 0.09, 0.09), V(-0.35, 3.6, -1.7), C(255, 140, 40), {mat = Enum.Material.Neon, glow = {6, 1}})
	P("Ember2", "e", V(0.07, 0.07, 0.07), V(-0.15, 3.58, -1.5), C(255, 190, 70), {mat = Enum.Material.Neon})
	return F.model
end

-- CLARA HOLLOW — porcelana rachada, órbitas vazias, sorriso largo, boneca nos braços.
function BUILD.Clara()
	local F = newFigure("Clara")
	local P = F.P
	local gown, por, black, red = C(214, 204, 184), C(240, 236, 228), C(14, 12, 14), C(150, 28, 28)
	local lace = C(244, 240, 230)
	for _, s in ipairs({-1, 1}) do
		P("Shoe", "b", V(0.45, 0.2, 0.7), V(0.35 * s, 0.1, -0.1), black)
		P("Leg", "b", V(0.3, 0.7, 0.3), V(0.35 * s, 0.55, 0), por)
		P("Arm", "b", V(0.25, 1.2, 0.25), V(0.75 * s, 2.9, -0.4), por, {rx = -1.0, rz = -0.05 * s})
		P("Hand", "e", V(0.24, 0.24, 0.24), V(0.3 * s, 2.4, -1.0), por)
		P("Socket", "e", V(0.42, 0.55, 0.12), V(0.38 * s, 4.25, -0.66), black)
		P("Glint", "e", V(0.1, 0.1, 0.08), V(0.38 * s, 4.15, -0.72), C(255, 30, 30), {mat = Enum.Material.Neon, glow = {6, 0.7}})
		P("Tear", "b", V(0.05, 0.5, 0.03), V(0.4 * s, 3.7, -0.68), black, {t = 0.35})
		P("Blush", "e", V(0.3, 0.2, 0.05), V(0.55 * s, 3.95, -0.62), C(214, 150, 150), {t = 0.6})
		P("SmileEdge", "b", V(0.05, 0.25, 0.05), V(0.46 * s, 3.88, -0.68), black, {rz = 0.4 * s})
		P("Pigtail", "e", V(0.4, 1.5, 0.4), V(0.95 * s, 3.8, 0.2), black, {rz = -0.1 * s})
		P("Bow", "e", V(0.38, 0.22, 0.16), V(0.9 * s, 4.55, 0.1), red, {rz = 0.3 * s})
		P("Bang", "e", V(0.55, 0.35, 0.3), V(0.35 * s, 4.7, -0.6), black, {rz = 0.3 * s})
		P("Bow2", "e", V(0.26, 0.14, 0.08), V(0.17 * s, 3.35, -0.46), red, {rz = 0.4 * s})
	end
	P("Skirt", "v", V(2.4, 1.5, 2.4), V(0, 1.3, 0), gown, {mat = Enum.Material.Fabric})
	for k = 0, 11 do
		local a = k / 12 * math.pi * 2
		P("LaceHem", "e", V(0.2, 0.2, 0.2), V(math.cos(a) * 1.2, 0.58, math.sin(a) * 1.2), lace)
	end
	P("Torso", "b", V(1.3, 1.4, 0.8), V(0, 2.75, 0), gown, {mat = Enum.Material.Fabric})
	for k = 0, 9 do
		local a = k / 10 * math.pi * 2
		P("LaceNeck", "e", V(0.16, 0.16, 0.16), V(math.cos(a) * 0.45, 3.5, math.sin(a) * 0.45), lace)
	end
	P("Knot", "e", V(0.14, 0.14, 0.1), V(0, 3.35, -0.46), C(120, 18, 18))
	P("Neck", "v", V(0.3, 0.3, 0.3), V(0, 3.6, 0), por)
	P("Head", "e", V(1.4, 1.55, 1.4), V(0, 4.3, 0), por)
	P("HairTop", "e", V(1.5, 0.95, 1.5), V(0, 4.85, 0.1), black)
	P("HairBack", "e", V(1.45, 1.5, 0.7), V(0, 4.2, 0.6), black)
	P("Nose", "e", V(0.1, 0.1, 0.1), V(0, 4.0, -0.68), C(206, 196, 190))
	P("Smile", "b", V(0.9, 0.05, 0.05), V(0, 3.78, -0.7), black)
	for k = -5, 5 do P("Tooth", "b", V(0.02, 0.13, 0.03), V(k * 0.085, 3.72, -0.7), black, {t = 0.15}) end
	P("Crack1", "b", V(0.03, 0.6, 0.02), V(0.2, 4.7, -0.7), black, {rz = 0.35})
	P("Crack2", "b", V(0.03, 0.45, 0.02), V(-0.45, 4.1, -0.68), black, {rz = -0.55})
	P("Crack3", "b", V(0.03, 0.5, 0.02), V(0.55, 4.05, -0.66), black, {rz = 0.7})
	P("DollBody", "b", V(0.4, 0.7, 0.2), V(0, 2.3, -1.05), C(184, 160, 128), {mat = Enum.Material.Fabric})
	P("DollHead", "e", V(0.42, 0.42, 0.42), V(0, 2.85, -1.05), por)
	P("DollEyeL", "e", V(0.08, 0.1, 0.05), V(-0.1, 2.88, -1.25), black)
	P("DollEyeR", "e", V(0.08, 0.1, 0.05), V(0.1, 2.88, -1.25), black)
	return F.model
end

function M.build(name)
	return BUILD[name]()
end

return M
