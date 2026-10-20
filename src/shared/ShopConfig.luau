-- Configuração da loja e das recompensas.
-- IMPORTANTE: crie 3 Developer Products (pacotes de moedas) no Creator Hub (create.roblox.com)
-- e cole os IDs abaixo. Enquanto o ID for 0, o botão de Robux aparece como "Em breve".
return {
	-- Itens pagos = somente pacotes de moedas (Developer Products vendidos em Robux).
	-- Nada de benefício direto: quem não paga ganha as mesmas moedas jogando.
	CoinPacks = {
		{id = 2042372620, coins = 300, name = "Punhado de Moedas"},
		{id = 2037365404, coins = 800, name = "Bolsa de Moedas"},
		{id = 2036387345, coins = 2000, name = "Baú de Moedas"},
	},

	Reward = {
		fuse = 15,
		generator = 25,
		escape = 150,        -- quem encosta na saída
		escapeSurvivor = 100, -- demais jogadores vivos
		phase = 60,  -- por fase concluída
		win = 250,   -- por quitar a dívida (3 fases)
	},

	-- recompensa diária por dia da sequência (dia 7 dá bônus extra de pilhas)
	Daily = {50, 75, 100, 125, 150, 200, 300},
	DailyBonusBatteries = 2,

	Upgrades = {
		battery = {name = "Bateria Duradoura", desc = "A lanterna gasta menos bateria.", costs = {150, 300, 600}},
		stamina = {name = "Fôlego de Ferro", desc = "Corra por mais tempo.", costs = {150, 300, 600}},
		stealth = {name = "Passos Abafados", desc = "Ela te ouve de menos longe.", costs = {200, 400, 800}},
	},
	Items = {
		battery = {name = "Pilha", desc = "Recarrega a lanterna (tecla G).", cost = 40, max = 5},
		amulet = {name = "Amuleto Protetor", desc = "Te salva uma vez do ataque e faz ela recuar.", cost = 250, max = 3},
	},
	MaxLevel = 3,
}
