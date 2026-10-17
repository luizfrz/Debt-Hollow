-- A DÍVIDA DE HOLLOW — cliente: HUD, lanterna, medo, jumpscares e fases
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Remotes = RS:WaitForChild("Remotes")

local PortraitArt = require(RS:WaitForChild("PortraitArt"))
local PORTRAITS = {clara = "Clara", augustus = "Augustus", eleanora = "Eleanora"} -- o susto usa o retrato 2D do lobby

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local SOUNDS = {
	ambience = "rbxassetid://138890398994853",
	heartbeat = "rbxassetid://139481207162657",
	scream = "rbxassetid://130285917830946",
}
local function newSound(id, vol, looped)
	local s = Instance.new("Sound")
	s.SoundId = id; s.Volume = vol; s.Looped = looped or false
	s.Parent = camera
	return s
end
local ambience = newSound(SOUNDS.ambience, 0.35, true)
local heartbeat = newSound(SOUNDS.heartbeat, 0, true)
local scream = newSound(SOUNDS.scream, 1.5, false)
local roar = newSound(SOUNDS.scream, 1.2, false)
roar.PlaybackSpeed = 0.5 -- o grito do Coro, grave e monstruoso
ambience:Play(); heartbeat:Play()

---------------------------------------------------------------------
-- HUD
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "HorrorHUD"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")

-- celular: controles de toque e interface que se adapta ao tamanho da tela
local touch = UIS.TouchEnabled or (RunService:IsStudio() and workspace:GetAttribute("ForceTouch") == true)
local hud = Instance.new("Frame") -- tudo que usa tamanhos fixos fica aqui e escala com a tela
hud.Name = "Scaled"; hud.BackgroundTransparency = 1; hud.BorderSizePixel = 0; hud.ZIndex = 55; hud.Parent = gui
local uiScale = Instance.new("UIScale"); uiScale.Parent = hud
local function rescale()
	local v = camera.ViewportSize
	local s = math.clamp(math.min(v.X / 900, v.Y / 520), 0.55, 1.15)
	uiScale.Scale = s; hud.Size = UDim2.fromScale(1 / s, 1 / s)
end
rescale(); camera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)

local function label(name, size, pos, textSize, anchor)
	local l = Instance.new("TextLabel")
	l.Name = name; l.Size = size; l.Position = pos; l.AnchorPoint = anchor or Vector2.zero
	l.BackgroundTransparency = 1; l.TextColor3 = Color3.fromRGB(220, 215, 205)
	l.Font = Enum.Font.SpecialElite; l.TextSize = textSize; l.TextStrokeTransparency = 0.5
	l.Parent = hud
	return l
end

local objective = label("Objective", UDim2.fromOffset(460, 60), UDim2.fromOffset(20, 20), 22)
objective.TextXAlignment = Enum.TextXAlignment.Left; objective.TextYAlignment = Enum.TextYAlignment.Top
objective.TextWrapped = true; objective.Text = "Pise em uma sala para entrar na fila"

local message = label("Message", UDim2.new(0.8, 0, 0, 120), UDim2.fromScale(0.5, 0.82), 22, Vector2.new(0.5, 0.5))
message.TextTransparency = 1; message.TextStrokeTransparency = 1; message.TextWrapped = true

local hint = label("Hint", UDim2.fromOffset(620, 24), UDim2.new(0, 20, 1, -36), 16)
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Text = "F lanterna  ·  Shift correr  ·  C agachar  ·  E interagir/esconder  ·  G pilha  ·  B loja"
hint.TextTransparency = 0.4
hint.Visible = not touch

local spectateLabel = label("Spectate", UDim2.fromOffset(500, 28), UDim2.new(0.5, 0, 0, 24), 20, Vector2.new(0.5, 0))
spectateLabel.Text = ""; spectateLabel.TextColor3 = Color3.fromRGB(190, 170, 150)

local function bar(name, y, color)
	local bg = Instance.new("Frame")
	bg.Name = name; bg.Size = UDim2.fromOffset(200, 8); bg.Position = UDim2.new(0, 20, 0, y)
	bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20); bg.BackgroundTransparency = 0.3; bg.BorderSizePixel = 0; bg.Parent = hud
	local fill = Instance.new("Frame")
	fill.Name = "Fill"; fill.Size = UDim2.fromScale(1, 1); fill.BackgroundColor3 = color; fill.BorderSizePixel = 0; fill.Parent = bg
	return fill
end
local staminaFill = bar("Stamina", 86, Color3.fromRGB(190, 190, 190))
local batteryFill = bar("Battery", 102, Color3.fromRGB(255, 220, 120))

-- vinheta
local vignette = Instance.new("Folder"); vignette.Name = "Vignette"; vignette.Parent = gui
local vigFrames = {}
local function edge(pos, size, rot)
	local f = Instance.new("Frame")
	f.Position = pos; f.Size = size; f.BackgroundColor3 = Color3.new(0, 0, 0); f.BorderSizePixel = 0; f.BackgroundTransparency = 1
	local g = Instance.new("UIGradient")
	g.Rotation = rot
	g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
	g.Parent = f; f.Parent = vignette
	table.insert(vigFrames, f)
end
edge(UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.3), 90)
edge(UDim2.fromScale(0, 0.7), UDim2.fromScale(1, 0.3), 270)
edge(UDim2.fromScale(0, 0), UDim2.fromScale(0.25, 1), 0)
edge(UDim2.fromScale(0.75, 0), UDim2.fromScale(0.25, 1), 180)

-- visão de dentro do armário (fresta)
local slit = Instance.new("Folder"); slit.Name = "LockerView"; slit.Parent = gui
local slitTop = Instance.new("Frame")
slitTop.Size = UDim2.fromScale(1, 0.42); slitTop.BackgroundColor3 = Color3.new(0, 0, 0); slitTop.BorderSizePixel = 0; slitTop.ZIndex = 30; slitTop.Visible = false; slitTop.Parent = slit
local slitBottom = slitTop:Clone(); slitBottom.Position = UDim2.fromScale(0, 0.58); slitBottom.Parent = slit
local slitHint = Instance.new("TextLabel")
slitHint.Size = UDim2.fromScale(1, 0.06); slitHint.Position = UDim2.fromScale(0, 0.87); slitHint.BackgroundTransparency = 1
slitHint.Font = Enum.Font.SpecialElite; slitHint.TextSize = 20; slitHint.TextColor3 = Color3.fromRGB(170, 160, 145)
slitHint.Text = "Prenda a respiração...  pressione E ou Espaço para sair"; slitHint.ZIndex = 31; slitHint.Visible = false; slitHint.Parent = slit

-- medidor de tensão (dentro do armário) e botão de sair, que também serve no celular
local tension, tensionShown = 0, 0
Remotes.Tension.OnClientEvent:Connect(function(t) tension = t end)
local tensionText = Instance.new("TextLabel")
tensionText.Size = UDim2.fromScale(1, 0.05); tensionText.Position = UDim2.fromScale(0, 0.61); tensionText.BackgroundTransparency = 1
tensionText.Font = Enum.Font.SpecialElite; tensionText.TextScaled = true; tensionText.ZIndex = 32; tensionText.Visible = false; tensionText.Parent = slit
local tensionBg = Instance.new("Frame")
tensionBg.Size = UDim2.fromScale(0.36, 0.022); tensionBg.Position = UDim2.fromScale(0.32, 0.68); tensionBg.BackgroundColor3 = Color3.fromRGB(28, 10, 10)
tensionBg.BorderSizePixel = 0; tensionBg.ZIndex = 32; tensionBg.Visible = false; tensionBg.Parent = slit
local tensionFill = Instance.new("Frame")
tensionFill.Size = UDim2.fromScale(0, 1); tensionFill.BorderSizePixel = 0; tensionFill.ZIndex = 33; tensionFill.Parent = tensionBg
local exitBtn = Instance.new("TextButton")
exitBtn.Size = UDim2.fromScale(0.28, 0.1); exitBtn.Position = UDim2.fromScale(0.36, 0.75); exitBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
exitBtn.TextColor3 = Color3.fromRGB(225, 215, 195); exitBtn.Font = Enum.Font.SpecialElite; exitBtn.TextScaled = true
exitBtn.Text = "SAIR DO ARMÁRIO"; exitBtn.ZIndex = 34; exitBtn.Visible = false; exitBtn.Parent = slit
exitBtn.Activated:Connect(function() Remotes.Unhide:FireServer() end)

---------------------------------------------------------------------
-- Jumpscare (um rosto por criatura)
---------------------------------------------------------------------
local jump = Instance.new("Frame")
jump.Name = "Jumpscare"; jump.Size = UDim2.fromScale(1, 1); jump.BackgroundColor3 = Color3.new(0, 0, 0)
jump.BackgroundTransparency = 1; jump.Visible = false; jump.ZIndex = 50; jump.Parent = gui

local face = Instance.new("Frame")
face.Size = UDim2.fromScale(0.34, 0.8); face.Position = UDim2.fromScale(0.5, 0.5); face.AnchorPoint = Vector2.new(0.5, 0.5)
face.BackgroundColor3 = Color3.fromRGB(225, 218, 205); face.BorderSizePixel = 0; face.ZIndex = 51; face.Parent = jump
local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0.5, 0); fc.Parent = face
local sockets, pupils = {}, {}
for _, x in ipairs({0.28, 0.72}) do
	local socket = Instance.new("Frame")
	socket.Size = UDim2.fromScale(0.26, 0.14); socket.Position = UDim2.fromScale(x, 0.32); socket.AnchorPoint = Vector2.new(0.5, 0.5)
	socket.BackgroundColor3 = Color3.new(0, 0, 0); socket.BorderSizePixel = 0; socket.ZIndex = 52; socket.Parent = face
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = socket
	local pupil = Instance.new("Frame")
	pupil.Size = UDim2.fromScale(0.28, 0.28); pupil.Position = UDim2.fromScale(0.5, 0.5); pupil.AnchorPoint = Vector2.new(0.5, 0.5)
	pupil.BackgroundColor3 = Color3.fromRGB(255, 20, 20); pupil.BorderSizePixel = 0; pupil.ZIndex = 53; pupil.Parent = socket
	local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0.5, 0); pc.Parent = pupil
	table.insert(sockets, socket); table.insert(pupils, pupil)
end
local mouth = Instance.new("Frame")
mouth.Size = UDim2.fromScale(0.5, 0.32); mouth.Position = UDim2.fromScale(0.5, 0.72); mouth.AnchorPoint = Vector2.new(0.5, 0.5)
mouth.BackgroundColor3 = Color3.new(0, 0, 0); mouth.BorderSizePixel = 0; mouth.ZIndex = 52; mouth.Parent = face
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0.5, 0); mc.Parent = mouth

local gameOver = label("GameOver", UDim2.fromScale(1, 0.2), UDim2.fromScale(0.5, 0.5), 48, Vector2.new(0.5, 0.5))
gameOver.TextColor3 = Color3.fromRGB(170, 20, 20)
gameOver.TextTransparency = 1; gameOver.TextStrokeTransparency = 1; gameOver.ZIndex = 60

local resultBody = label("ResultBody", UDim2.fromScale(0.7, 0.3), UDim2.fromScale(0.5, 0.64), 24, Vector2.new(0.5, 0))
resultBody.TextWrapped = true; resultBody.TextTransparency = 1; resultBody.TextStrokeTransparency = 1; resultBody.ZIndex = 60

local VARIANTS = {
	visitante = {face = Color3.fromRGB(225, 218, 205), pupil = Color3.fromRGB(255, 20, 20), eye = UDim2.fromScale(0.26, 0.14), mouth = UDim2.fromScale(0.5, 0.32), teeth = true,
		text = "O VISITANTE COBROU SUA DÍVIDA", bg = Color3.new(0, 0, 0)},
	enfermeira = {face = Color3.fromRGB(232, 226, 218), eye = UDim2.fromScale(0.26, 0.016), mouth = UDim2.fromScale(0.42, 0.016), stitches = true,
		text = "A ENFERMEIRA OUVIU VOCÊ", bg = Color3.fromRGB(6, 14, 10)},
	clara = {face = Color3.fromRGB(238, 234, 226), pupil = Color3.fromRGB(255, 30, 30), pupilSize = 0.14, eye = UDim2.fromScale(0.28, 0.2), mouth = UDim2.fromScale(0.7, 0.035), cracks = true,
		text = "CLARA ESTAVA ATRÁS DE VOCÊ", bg = Color3.fromRGB(10, 5, 5)},
	coro = {face = Color3.fromRGB(175, 170, 165), eye = UDim2.fromScale(0.26, 0.2), mouth = UDim2.fromScale(0.46, 0.42),
		text = "O CORO LEVOU VOCÊ", bg = Color3.fromRGB(40, 0, 0)},
}
-- as três personagens do lobby: o rosto do susto é o do retrato
VARIANTS.augustus = {face = Color3.fromRGB(196, 172, 150), pupil = Color3.fromRGB(255, 30, 30), pupilSize = 0.3, eye = UDim2.fromScale(0.22, 0.12),
	mouth = UDim2.fromScale(0.26, 0.03), hair = Color3.fromRGB(132, 130, 134), beard = true, glasses = true,
	text = "AUGUSTUS COBROU SUA DÍVIDA", bg = Color3.fromRGB(20, 6, 6)}
VARIANTS.eleanora = {face = Color3.fromRGB(224, 208, 194), pupil = Color3.fromRGB(120, 175, 255), pupilSize = 0.35, eye = UDim2.fromScale(0.22, 0.12),
	mouth = UDim2.fromScale(0.2, 0.028), hair = Color3.fromRGB(64, 46, 40), tear = true,
	text = "ELEANORA OUVIU VOCÊ", bg = Color3.fromRGB(4, 10, 16)}
VARIANTS.clara.hair = Color3.fromRGB(14, 12, 14)

local extras = {}
local function addExtra(parent, size, pos, color, rot)
	local f = Instance.new("Frame")
	f.Size = size; f.Position = pos; f.AnchorPoint = Vector2.new(0.5, 0.5); f.BackgroundColor3 = color
	f.BorderSizePixel = 0; f.Rotation = rot or 0; f.ZIndex = 54; f.Parent = parent
	table.insert(extras, f)
end

local function addRound(parent, size, pos, color)
	local f = Instance.new("Frame")
	f.Size = size; f.Position = pos; f.AnchorPoint = Vector2.new(0.5, 0.5); f.BackgroundColor3 = color
	f.BorderSizePixel = 0; f.ZIndex = 54; f.Parent = parent
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = f
	table.insert(extras, f)
	return f
end
local function addRing(parent, size, pos, color)
	local f = addRound(parent, size, pos, color)
	f.BackgroundTransparency = 1
	local s = Instance.new("UIStroke"); s.Color = color; s.Thickness = 4; s.Parent = f
end

local jumping, deaths = false, 0
Remotes.Jumpscare.OnClientEvent:Connect(function(kind)
	local V = VARIANTS[kind] or VARIANTS.visitante
	for _, e in ipairs(extras) do e:Destroy() end
	table.clear(extras)
	face.BackgroundColor3 = V.face; jump.BackgroundColor3 = V.bg
	for _, s in ipairs(sockets) do s.Size = V.eye end
	for _, p in ipairs(pupils) do
		p.Visible = V.pupil ~= nil
		if V.pupil then p.BackgroundColor3 = V.pupil; p.Size = UDim2.fromScale(V.pupilSize or 0.28, V.pupilSize or 0.28) end
	end
	mouth.Size = V.mouth
	if V.teeth then
		for k = -5, 5 do addExtra(mouth, UDim2.fromScale(0.07, 0.22), UDim2.fromScale(0.5 + k * 0.085, 0.14), Color3.fromRGB(245, 245, 235)) end
	end
	if V.stitches then
		for k = -4, 4 do addExtra(face, UDim2.fromScale(0.008, 0.07), UDim2.fromScale(0.5 + k * 0.05, 0.72), Color3.new(0, 0, 0)) end
		for _, ex in ipairs({0.28, 0.72}) do
			for k = -1, 1 do addExtra(face, UDim2.fromScale(0.008, 0.05), UDim2.fromScale(ex + k * 0.05, 0.32), Color3.new(0, 0, 0)) end
		end
	end
	if V.cracks then
		addExtra(face, UDim2.fromScale(0.006, 0.28), UDim2.fromScale(0.55, 0.12), Color3.new(0, 0, 0), 20)
		addExtra(face, UDim2.fromScale(0.006, 0.24), UDim2.fromScale(0.3, 0.55), Color3.new(0, 0, 0), -35)
		addExtra(face, UDim2.fromScale(0.006, 0.2), UDim2.fromScale(0.78, 0.5), Color3.new(0, 0, 0), 40)
	end
	if V.hair then addRound(face, UDim2.fromScale(1.02, 0.34), UDim2.fromScale(0.5, 0.05), V.hair) end
	if V.beard then addRound(face, UDim2.fromScale(0.7, 0.3), UDim2.fromScale(0.5, 0.9), Color3.fromRGB(124, 122, 126)) end
	if V.glasses then
		for _, ex in ipairs({0.28, 0.72}) do addRing(face, UDim2.fromScale(0.3, 0.19), UDim2.fromScale(ex, 0.32), Color3.fromRGB(190, 150, 70)) end
	end
	if V.tear then addRound(face, UDim2.fromScale(0.03, 0.12), UDim2.fromScale(0.72, 0.5), Color3.fromRGB(150, 205, 255)) end
	gameOver.Text = V.text

	jumping = true
	jump.Visible = true; jump.BackgroundTransparency = 0
	face.Visible = true
	local art, artRatio
	if PORTRAITS[kind] then
		face.Visible = false
		art = Instance.new("Frame")
		art.AnchorPoint = Vector2.new(0.5, 0.42); art.BorderSizePixel = 0; art.ZIndex = 51
		art.Position = UDim2.fromScale(0.5, 0.5); art.Size = UDim2.fromOffset(100, 100); art.Parent = jump
		artRatio = PortraitArt.paint(PORTRAITS[kind], art)
	end
	scream:Play()
	local t0 = os.clock()
	while os.clock() - t0 < 1.0 do
		local k = os.clock() - t0
		face.Size = UDim2.fromScale(0.34 + k * 0.25, 0.8 + k * 0.4)
		face.Position = UDim2.fromScale(0.5 + (math.random() - 0.5) * 0.04, 0.5 + (math.random() - 0.5) * 0.04)
		if art then
			local h = camera.ViewportSize.Y * (0.9 + k * 0.7)
			art.Size = UDim2.fromOffset(h * artRatio, h)
			art.Position = UDim2.fromScale(0.5 + (math.random() - 0.5) * 0.03, 0.5 + (math.random() - 0.5) * 0.03)
		end
		RunService.RenderStepped:Wait()
	end
	if art then art:Destroy() end
	face.Visible = false
	gameOver.TextColor3 = Color3.fromRGB(170, 20, 20)
	gameOver.TextTransparency = 0; gameOver.TextStrokeTransparency = 0.5
	task.wait(2.2)
	TweenService:Create(gameOver, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	TweenService:Create(jump, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
	task.wait(1)
	jump.Visible = false
	face.Size = UDim2.fromScale(0.34, 0.8); face.Position = UDim2.fromScale(0.5, 0.5)
	jumping = false

	deaths += 1
	if deaths % 3 == 0 and (player:GetAttribute("Amulets") or 0) == 0 then
		message.Text = "Dica: o Amuleto Protetor te salva uma vez. Abra a loja com B."
		TweenService:Create(message, TweenInfo.new(0.5), {TextTransparency = 0.15, TextStrokeTransparency = 0.5}):Play()
		task.delay(5, function() TweenService:Create(message, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play() end)
	end
end)

---------------------------------------------------------------------
-- Fases: cartão de título + iluminação
---------------------------------------------------------------------
local cc = Lighting:FindFirstChild("HorrorCC")
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local baseSat = cc and cc.Saturation or -0.35

local function c3(t) return Color3.fromRGB(t[1], t[2], t[3]) end
local function applyLight(l, dur)
	if not l then return end
	local info = TweenInfo.new(dur)
	TweenService:Create(Lighting, info, {FogStart = l.fogStart, FogEnd = l.fogEnd, FogColor = c3(l.fog), Ambient = c3(l.ambient), OutdoorAmbient = c3(l.ambient)}):Play()
	if cc then TweenService:Create(cc, info, {TintColor = c3(l.tint)}):Play() end
	if atmosphere then TweenService:Create(atmosphere, info, {Density = l.atmo}):Play() end
end

local cover = Instance.new("Frame")
cover.Name = "PhaseCover"; cover.Size = UDim2.fromScale(1, 1); cover.BackgroundColor3 = Color3.new(0, 0, 0)
cover.BackgroundTransparency = 1; cover.Visible = false; cover.ZIndex = 70; cover.BorderSizePixel = 0; cover.Parent = gui
local cardTitle = label("CardTitle", UDim2.fromScale(1, 0.15), UDim2.fromScale(0.5, 0.42), 54, Vector2.new(0.5, 0.5))
cardTitle.ZIndex = 71; cardTitle.TextTransparency = 1; cardTitle.TextStrokeTransparency = 1; cardTitle.TextColor3 = Color3.fromRGB(190, 40, 40)
local cardSub = label("CardSub", UDim2.fromScale(0.8, 0.1), UDim2.fromScale(0.5, 0.54), 26, Vector2.new(0.5, 0.5))
cardSub.ZIndex = 71; cardSub.TextTransparency = 1; cardSub.TextStrokeTransparency = 1; cardSub.TextWrapped = true

local phaseToken = 0
Remotes.Phase.OnClientEvent:Connect(function(p)
	phaseToken += 1
	local my = phaseToken
	if p.cover == false then applyLight(p.light, 1.5) return end
	task.spawn(function()
		cover.Visible = true
		TweenService:Create(cover, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
		task.wait(1.5)
		applyLight(p.light, 0.4)
		if p.title then
			cardTitle.Text = p.title; cardSub.Text = p.sub or ""
			TweenService:Create(cardTitle, TweenInfo.new(1), {TextTransparency = 0, TextStrokeTransparency = 0.5}):Play()
			TweenService:Create(cardSub, TweenInfo.new(1.4), {TextTransparency = 0, TextStrokeTransparency = 0.5}):Play()
			task.wait(p.hold or 4)
			TweenService:Create(cardTitle, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			TweenService:Create(cardSub, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			task.wait(0.8)
		end
		if my ~= phaseToken then return end
		TweenService:Create(cover, TweenInfo.new(1.5), {BackgroundTransparency = 1}):Play()
		task.wait(1.5)
		if my == phaseToken then cover.Visible = false end
	end)
end)

Remotes.Result.OnClientEvent:Connect(function(win, title, body)
	while jumping do task.wait(0.2) end
	for _, e in ipairs(extras) do e:Destroy() end
	table.clear(extras)
	face.Visible = false
	jump.BackgroundColor3 = Color3.new(0, 0, 0); jump.Visible = true
	TweenService:Create(jump, TweenInfo.new(1.5), {BackgroundTransparency = 0}):Play()
	task.wait(1.5)
	gameOver.Text = title
	gameOver.TextColor3 = win and Color3.fromRGB(235, 190, 80) or Color3.fromRGB(170, 20, 20)
	resultBody.Text = body
	TweenService:Create(gameOver, TweenInfo.new(1.2), {TextTransparency = 0, TextStrokeTransparency = 0.5}):Play()
	task.wait(1.5)
	TweenService:Create(resultBody, TweenInfo.new(1.5), {TextTransparency = 0, TextStrokeTransparency = 0.5}):Play()
	task.wait(5.5)
	TweenService:Create(gameOver, TweenInfo.new(0.8), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	TweenService:Create(resultBody, TweenInfo.new(0.8), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	task.wait(0.8)
	jump.Visible = false; jump.BackgroundTransparency = 1
end)

---------------------------------------------------------------------
-- Mensagens, objetivo, perseguição, Coro
---------------------------------------------------------------------
local msgToken = 0
Remotes.Notify.OnClientEvent:Connect(function(text, dur)
	msgToken += 1
	local my = msgToken
	message.Text = text
	TweenService:Create(message, TweenInfo.new(0.4), {TextTransparency = 0, TextStrokeTransparency = 0.5}):Play()
	task.delay(dur or 4, function()
		if my == msgToken then
			TweenService:Create(message, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		end
	end)
end)

Remotes.Objective.OnClientEvent:Connect(function(text) objective.Text = text end)

local chasing = false
Remotes.Chase.OnClientEvent:Connect(function(v) chasing = v end)

local shakeBoost = 0
Remotes.Rush.OnClientEvent:Connect(function(stage)
	if stage == "warn" then
		shakeBoost = 0.25
		TweenService:Create(ambience, TweenInfo.new(1), {Volume = 0.7}):Play()
	elseif stage == "go" then
		roar:Play()
		shakeBoost = 1
		task.delay(3, function() shakeBoost = 0 end)
	end
end)

---------------------------------------------------------------------
-- Lanterna (bateria), corrida (stamina) e agachar
---------------------------------------------------------------------
local flashPart = Instance.new("Part")
flashPart.Name = "Flashlight"; flashPart.Size = Vector3.one * 0.2; flashPart.Transparency = 1
flashPart.Anchored = true; flashPart.CanCollide = false; flashPart.CanQuery = false; flashPart.CanTouch = false
flashPart.Parent = camera
-- feixe direcionado: núcleo estreito e forte + borda suave e fraca (não ilumina a sala toda)
local spot = Instance.new("SpotLight")
spot.Face = Enum.NormalId.Front; spot.Range = 45; spot.Angle = 22; spot.Brightness = 7
spot.Color = Color3.fromRGB(255, 244, 220); spot.Shadows = not touch; spot.Parent = flashPart
local halo = Instance.new("SpotLight")
halo.Face = Enum.NormalId.Front; halo.Range = 24; halo.Angle = 46; halo.Brightness = 0.9
halo.Color = Color3.fromRGB(255, 236, 200); halo.Shadows = false; halo.Parent = flashPart

local flashOn, battery, stamina = true, 100, 100
local sprintWanted, sprintSent = false, false
local crouchOn, crouchY = false, 0
Remotes.Recharge.OnClientEvent:Connect(function() battery = 100; flashOn = true end)

UIS.InputBegan:Connect(function(input, gp)
	if player:GetAttribute("Hidden") and (input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.Space) then
		Remotes.Unhide:FireServer()
		return
	end
	if gp then return end
	if input.KeyCode == Enum.KeyCode.F then flashOn = not flashOn
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		sprintWanted = true
		if crouchOn then crouchOn = false; Remotes.Crouch:FireServer(false) end
	elseif input.KeyCode == Enum.KeyCode.C then
		crouchOn = not crouchOn
		Remotes.Crouch:FireServer(crouchOn)
	elseif input.KeyCode == Enum.KeyCode.G and battery < 85 and (player:GetAttribute("Batteries") or 0) > 0 then
		Remotes.UseBattery:FireServer()
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then sprintWanted = false end
end)

-- controles de toque (celular): botões grandes à direita, abaixo do botão de moedas
if touch then
	local function btn(text, row)
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(84, 84); b.AnchorPoint = Vector2.new(1, 0)
		b.Position = UDim2.new(1, -24, 0, 110 + row * 96)
		b.BackgroundColor3 = Color3.fromRGB(20, 18, 18); b.BackgroundTransparency = 0.35
		b.TextColor3 = Color3.fromRGB(235, 225, 205); b.Font = Enum.Font.SpecialElite; b.TextSize = 17; b.Text = text
		b.AutoButtonColor = true; b.Parent = hud
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = b
		local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(190, 150, 70); s.Thickness = 2; s.Parent = b
		return b
	end
	btn("LANTERNA", 0).Activated:Connect(function() flashOn = not flashOn end)
	local run = btn("CORRER", 1) -- segure para correr
	run.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			sprintWanted = true
			if crouchOn then crouchOn = false; Remotes.Crouch:FireServer(false) end
		end
	end)
	run.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then sprintWanted = false end
	end)
	btn("AGACHAR", 2).Activated:Connect(function()
		crouchOn = not crouchOn; Remotes.Crouch:FireServer(crouchOn)
	end)
	btn("PILHA", 3).Activated:Connect(function()
		if battery < 85 and (player:GetAttribute("Batteries") or 0) > 0 then Remotes.UseBattery:FireServer() end
	end)
end

---------------------------------------------------------------------
-- Espectador: ao morrer, acompanha um sobrevivente
---------------------------------------------------------------------
local spectating = false
task.spawn(function()
	while true do
		task.wait(0.5)
		local ch = player.Character
		local h = ch and ch:FindFirstChildOfClass("Humanoid")
		local dead = (not h) or h.Health <= 0
		if player:GetAttribute("InMatch") and dead then
			local target, name
			for _, other in ipairs(Players:GetPlayers()) do
				if other ~= player and other:GetAttribute("InMatch") and other.Character then
					local oh = other.Character:FindFirstChildOfClass("Humanoid")
					if oh and oh.Health > 0 then target, name = oh, other.DisplayName; break end
				end
			end
			if target then
				camera.CameraSubject = target; spectating = true
				spectateLabel.Text = "Observando " .. name .. "  (você volta na próxima fase)"
			end
		elseif spectating and h and h.Health > 0 then
			camera.CameraSubject = h; spectating = false; spectateLabel.Text = ""
		end
	end
end)

---------------------------------------------------------------------
-- Loop principal: medo, tremor, efeitos
---------------------------------------------------------------------
local fear = 0
local shakeSeed = math.random() * 100

RunService.RenderStepped:Connect(function(dt)
	local ch = player.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
	local hiddenNow = player:GetAttribute("Hidden") == true
	slitTop.Visible = hiddenNow; slitBottom.Visible = hiddenNow; slitHint.Visible = hiddenNow
	if not hiddenNow then tension = 0 end
	tensionShown += (tension - tensionShown) * math.min(1, dt * 6)
	tensionFill.Size = UDim2.fromScale(tensionShown, 1)
	tensionFill.BackgroundColor3 = Color3.fromRGB(80 + 175 * tensionShown, 200 - 160 * tensionShown, 60)
	local safe = tension < 0.6
	tensionText.Text = safe and "Silêncio... você pode sair." or "Aguarde... a tensão ainda não passou."
	tensionText.TextColor3 = safe and Color3.fromRGB(150, 210, 150) or Color3.fromRGB(220, 110, 100)
	tensionBg.Visible = hiddenNow; tensionText.Visible = hiddenNow; exitBtn.Visible = hiddenNow

	-- lanterna segue a câmera
	flashPart.CFrame = camera.CFrame
	local on = flashOn and battery > 0 and not jumping and not hiddenNow
	spot.Enabled = on; halo.Enabled = on
	if on then
		local premium = player:GetAttribute("PremiumLight")
		local drain = 1.1 * (1 - 0.15 * (player:GetAttribute("BatteryLevel") or 0)) * (premium and 0.7 or 1)
		battery = math.max(0, battery - dt * drain)
		spot.Range = premium and 60 or 45
		spot.Angle = premium and 28 or 22
		halo.Range = premium and 32 or 24
		halo.Angle = premium and 54 or 46
		local dim = battery < 15 and math.random() < 0.35
		spot.Brightness = dim and 1 or (premium and 9 or 7)
		halo.Brightness = dim and 0.1 or 0.9
	else
		battery = math.min(100, battery + dt * (flashOn and 0 or 4))
		if battery <= 0 then flashOn = false end
	end
	batteryFill.Size = UDim2.fromScale(battery / 100, 1)

	-- stamina / corrida
	local moving = hum and hum.MoveDirection.Magnitude > 0.1
	local sprinting = sprintWanted and moving and stamina > 0 and not crouchOn
	if sprinting then stamina = math.max(0, stamina - dt * 22 * (1 - 0.12 * (player:GetAttribute("StaminaLevel") or 0)))
	else stamina = math.min(100, stamina + dt * (moving and 10 or 18)) end
	if stamina <= 0 then sprintWanted = false end
	if sprinting ~= sprintSent then sprintSent = sprinting; Remotes.Sprint:FireServer(sprinting) end
	staminaFill.Size = UDim2.fromScale(stamina / 100, 1)

	-- medo pela proximidade das criaturas
	local target = 0
	local folder = workspace:FindFirstChild("Entities")
	if folder and hrp then
		local d = math.huge
		for _, e in ipairs(folder:GetChildren()) do
			if e.PrimaryPart then d = math.min(d, (e.PrimaryPart.Position - hrp.Position).Magnitude) end
		end
		if d < math.huge then target = math.clamp(1 - d / 55, 0, 1) end
	end
	if chasing then target = math.max(target, 0.35) end
	if hiddenNow then target = math.max(target, 0.4) end
	fear += (target - fear) * math.min(1, dt * 3)

	heartbeat.Volume = fear * 2.2
	heartbeat.PlaybackSpeed = 0.9 + fear * 0.6
	if shakeBoost == 0 then ambience.Volume = 0.35 + fear * 0.25 end
	for _, f in ipairs(vigFrames) do f.BackgroundTransparency = 1 - fear * 0.9 end
	if cc then cc.Saturation = baseSat - fear * 0.4 end
	camera.FieldOfView = 70 - fear * 8

	-- agachar + tremor da câmera
	crouchY += ((crouchOn and -1.5 or 0) - crouchY) * math.min(1, dt * 8)
	if hum then
		local s = fear * fear * 0.35 + shakeBoost * 0.3
		local t = os.clock() * 25 + shakeSeed
		hum.CameraOffset = Vector3.new(math.noise(t, 0) * s, crouchY + math.noise(0, t) * s, 0)
	end
end)

Remotes.ClientReady:FireServer()
