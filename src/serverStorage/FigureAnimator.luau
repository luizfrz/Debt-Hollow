-- FigureAnimator: animacao procedural (caminhada, respiracao, tremor) dos modelos de Figures.
-- Uso: local a = Animator.new(model, 'Clara'); a:update(rootCF, dt, speed, 'walk'|'idle'|'frozen')
local V3, CF = Vector3.new, CFrame.new
local A = {}
A.__index = A

local function set(list) local s = {} for _, n in ipairs(list) do s[n] = true end return s end
local HEAD = set({'Head', 'Socket', 'Glint', 'Tear', 'Blush', 'SmileEdge', 'Smile', 'Tooth', 'Crack1', 'Crack2', 'Crack3', 'Nose', 'HairTop', 'HairBack', 'Bang',
	'Forehead', 'Bridge', 'Beard', 'Mouth', 'Ear', 'Tuft', 'Brow', 'Cheek', 'GlassRim', 'Eye', 'Mustache', 'Bun', 'Ribbon', 'Lips', 'HairFront', 'Streak', 'EyeWhite', 'Iris', 'Lid'})
local ARMS = set({'Arm', 'Hand', 'Sleeve', 'Contract', 'Burn1', 'Burn2', 'Ember', 'Ember2', 'DollBody', 'DollHead', 'DollEyeL', 'DollEyeR'})
local LEGS = set({'Leg', 'Shoe'})
local SKIRT = set({'Skirt', 'Skirt1', 'Skirt2', 'Skirt3', 'LaceHem'})
local TAIL = set({'Pigtail', 'Bow', 'CoatTail'}) -- balancam como pendulo

-- leg/arm = amplitude do passo; bob = quique; lean = inclinacao; sway = balanco; rate = frequencia do passo
local CFG = {
	Clara = {hip = V3(0, 1.0, 0), shoulder = V3(0, 3.4, -0.4), neck = V3(0, 3.7, 0), leg = 0.62, arm = 0.5, bob = 0.1, lean = 0.1, sway = 0.07, rate = 0.42, twist = 0.14, lift = 0.35},
	Augustus = {hip = V3(0, 2.8, 0), shoulder = V3(0, 4.9, 0), neck = V3(0, 5.4, 0), leg = 0.45, arm = 0.5, bob = 0.08, lean = 0.05, sway = 0.03, rate = 0.42, twist = 0.1, lift = 0.25},
	Eleanora = {hip = V3(0, 3.0, 0), shoulder = V3(0, 4.8, -0.3), neck = V3(0, 5.5, 0), leg = 0, arm = 0.15, bob = 0.12, lean = 0.05, sway = 0.07, rate = 0.3, twist = 0.05, lift = 0},
}

function A.new(model, figName)
	local self = setmetatable({}, A)
	self.cfg, self.root, self.items = CFG[figName], model.PrimaryPart, {}
	self.phase, self.amp, self.t, self.twitchAt, self.twitch = 0, 0, 0, 2, 0
	for _, p in ipairs(model:GetChildren()) do -- o modelo ainda esta na origem: CFrame atual = pose de repouso
		if p:IsA('BasePart') and p ~= self.root then
			local g = TAIL[p.Name] and 'Tail' or LEGS[p.Name] and 'Leg' or ARMS[p.Name] and 'Arm' or SKIRT[p.Name] and 'Skirt' or HEAD[p.Name] and 'Head' or 'Body'
			local x = p.CFrame.X
			table.insert(self.items, {p = p, rest = p.CFrame, g = g, side = math.abs(x) < 0.05 and 0 or (x < 0 and 1 or -1),
				pivot = g == 'Tail' and (p.CFrame.Position + V3(0, p.Size.Y / 2, 0)) or nil})
		end
	end
	return self
end

function A:update(rootCF, dt, speed, state)
	local c = self.cfg
	self.t += dt
	if state == 'walk' then
		self.phase += dt * speed * c.rate
		self.amp += (1 - self.amp) * math.min(1, dt * 4)
	elseif state == 'idle' then
		self.amp += (0 - self.amp) * math.min(1, dt * 3)
	end -- 'frozen' mantem a pose do passo
	local ph, amp, t = self.phase, self.amp, self.t
	local s = math.sin(ph)
	local idle = state == 'idle'
	local bob = math.abs(s) * c.bob * amp + (idle and math.sin(t * 1.6) * 0.03 or 0)
	local twist = (c.twist or 0.1) * amp
	local B = rootCF * CF(s * 0.06 * amp, bob, 0) * CFrame.Angles(-c.lean * amp, -s * twist, s * c.sway * amp)
	local G = rootCF * CF(0, bob * 0.3, 0)

	-- cabeca: olha em volta parada; quando congelada, tremor rapido (esta viva)
	local hy, hr, hp = 0, 0, math.sin(ph * 2) * 0.03 * amp
	if state == 'frozen' then
		if t > self.twitchAt then
			self.twitch = (math.random() < 0.5 and 1 or -1) * 0.2
			self.twitchAt = t + 1.2 + math.random() * 2; self.twitchEnd = t + 0.12
		end
		if self.twitchEnd and t > self.twitchEnd then self.twitch = 0 end
		hy = self.twitch
	else
		hr = idle and math.sin(t * 0.7) * 0.05 or math.sin(ph) * 0.04 * amp
		hy = idle and math.sin(t * 0.5) * 0.12 or 0
	end
	local HR = CFrame.Angles(hp, hy + s * twist * 0.7, hr) -- a cabeca compensa a torcao do tronco
	local neck = c.neck

	for _, it in ipairs(self.items) do
		local g, rest = it.g, it.rest
		local cf
		if g == 'Body' then cf = B * rest
		elseif g == 'Head' then cf = B * CF(neck) * HR * CF(-neck) * rest
		elseif g == 'Leg' then
				local pv = V3(rest.X, c.hip.Y, 0)
				local lift = math.max(0, math.cos(ph) * it.side) * (c.lift or 0.2) * amp -- o pe sobe ao avancar
				cf = G * CF(0, lift, 0) * CF(pv) * CFrame.Angles(s * c.leg * amp * it.side, 0, 0) * CF(-pv) * rest
			elseif g == 'Arm' then
				local pv = V3(rest.X, c.shoulder.Y, c.shoulder.Z)
				local sw = -math.sin(ph - 0.4) * c.arm * amp * it.side + math.sin(t * 1.4 + it.side) * 0.03 -- defasado do passo + respiracao
				cf = B * CF(pv) * CFrame.Angles(sw, 0, it.side * 0.04 * amp) * CF(-pv) * rest
			elseif g == 'Skirt' then
			local pv = V3(0, c.hip.Y + 0.4, 0)
			cf = B * CF(pv) * CFrame.Angles(0, 0, -s * c.sway * 1.6 * amp) * CF(-pv) * rest
		else -- Tail
			local ang = math.sin(ph - 0.9) * 0.22 * amp + math.sin(t * 1.3) * 0.04
			local rot = it.p.Name == 'CoatTail' and CFrame.Angles(ang, 0, 0) or CFrame.Angles(0, 0, ang)
			cf = B * CF(it.pivot) * rot * CF(-it.pivot) * rest
		end
		it.p.CFrame = cf
	end
	self.root.CFrame = rootCF
end

return A
