# Protocolo Claude × Roblox Studio — economia de tokens

Regras práticas para trabalhar neste projeto ("A Dívida de Hollow") gastando o mínimo de tokens, tiradas dos desperdícios reais das sessões anteriores. Siga na ordem: **planejar → editar pouco → testar pouco → responder curto**.

---

## 0. Os 8 maiores desperdícios (e a regra que os evita)

| # | O que desperdiçou | Regra |
|---|---|---|
| 1 | Chamada de **Edit** com o Studio em **Play**: erro, e o código grande foi reenviado 4 vezes | Antes de qualquer escrita, chame `start_stop_play(false)` (barato) ou `get_studio_state`. Nunca reenvie código grande sem antes ver o estado |
| 2 | `get_console_output` devolve dezenas de linhas repetidas do UIBlox/CorePackages a cada chamada | Não chame por rotina. Se precisar, use o filtro da seção 4 |
| 3 | Reenviar scripts inteiros para mudar 3 linhas | Use `multi_edit` com `old_string` curto. Ver seção 2 |
| 4 | Gerar centenas de partes à mão | Use o gerador (`LevelBuilder`, `Figures`) e passe só os parâmetros |
| 5 | Screenshots tirados antes da renderização (`SurfaceGui` aparece preto por alguns segundos) e que dão timeout | Máximo 1 captura por alvo. Se vier preta, espere e repita 1 vez, sem mudar nada |
| 6 | `search_game_tree` sem filtro (200 nós de serviços inúteis) | Sempre com `path`, `max_depth` ou `keywords` |
| 7 | Testes longos em vários passos (jogar 3 fases inteiras) | Use os ganchos de teste da seção 5 |
| 8 | Respostas longas repetindo o que o código já mostra | Seção 7 |

---

## 1. Antes de agir
1. **Leia o mapa do projeto (seção 8)** em vez de explorar o Studio. Não faça `search_game_tree` do jogo inteiro.
2. Decida o menor conjunto de scripts a alterar. Uma mudança de design raramente exige mais de 2 scripts.
3. Se o pedido for ambíguo e a diferença for pequena, **escolha o padrão razoável, faça e diga o que assumiu** em uma linha. Pergunte só se a escolha errada custar refazer algo grande.
4. Junte chamadas **independentes na mesma resposta** (vários `multi_edit`, leituras, capturas).

## 2. Editar
- **Edite, não reescreva.** `multi_edit` com trechos únicos e curtos. As edições de um mesmo script vão em uma só chamada (é atômica: se uma falha, nenhuma é aplicada, então confira o `old_string`).
- Só reescreva o script inteiro se mais da metade mudar. Nesse caso, apague e recrie o script em duas chamadas simples, em vez de várias edições frágeis.
- **Não releia** o que você acabou de editar: o `multi_edit` já falha se algo estiver errado.
- Mantenha scripts **pequenos e modulares** (`ModuleScript`s). Código novo vai em um módulo novo, para a próxima edição não precisar de contexto grande.
- **Dados em tabela, lógica em função.** Textos de história, fases e preços ficam em tabelas (`PHASES`, `PAGES`, `ShopConfig`). Mudar conteúdo vira edição de uma linha.
- Para um valor ajustado várias vezes (brilho, velocidade, preço), deixe-o em **uma constante** no topo ou em `ShopConfig`.
- Ao criar conteúdo grande no mundo (mapa, modelo), escreva um **gerador parametrizado** e execute-o uma vez. Evite listar parte por parte.
- Para alterar muitas instâncias existentes, faça um **patch em `execute_luau`** (varrer e ajustar propriedades) em vez de recriar tudo.

## 3. Executar e consultar
- `execute_luau` deve **devolver um resumo pequeno** (`return {coins = 380, fase = 2}`), nunca uma árvore ou lista longa.
- Para ler o estado do jogo, retorne só o que precisa (posição, contagens, flags).
- `script_grep`/`script_search` para achar trechos; `script_read` só no intervalo necessário.
- Assets: `search_asset` com `maxResults` baixo (3–5) e **guarde o ID escolhido** no código/config. Não busque de novo.

## 4. Console e erros
`get_console_output` traz muito ruído. Prefira, durante o Play, capturar só erros do **projeto** via `execute_luau`:

```lua
local LogService = game:GetService("LogService")
local erros = {}
for _, m in ipairs(LogService:GetLogHistory()) do
	if m.messageType == Enum.MessageType.MessageError
		or (m.message:find("ServerScriptService") or m.message:find("StarterPlayerScripts")) then
		erros[#erros + 1] = m.message
	end
end
return erros
```

- Ignore sempre: `UIBlox - Warning`, `FoundationProvider`, `ContentId: rbxassetid://203785492` (ruído do Studio, não do jogo).
- O aviso `[Economy] DataStore indisponível` é esperado em jogo não publicado.
- Só chame o console **depois** de um teste e **uma vez**.

## 5. Testar (barato e rápido)
Não jogue o jogo inteiro. Use os ganchos do projeto, **apenas no Studio**:

| Gancho | Para quê |
|---|---|
| `ServerStorage.StartMatch:Fire({player}, "TESTE", 3)` | Começa a partida direto na fase 3 (1 a 3) |
| `ServerStorage.DebugCmd:Invoke("state")` | Itens coletados, objetivo aberto, jogadores vivos |
| Sala **SOLO** do lobby | Jogar sozinho sem comandos |
| `workspace.Levels.FaseN.ExitZone` | Teleporte do cliente para a saída |
| `workspace:SetAttribute("ForceTouch", true)` (modo Edit) | Força a interface de celular no Studio. **Desligue depois** (`nil`) |

Receita do cliente para interagir com prompts (precisa **olhar** para o objeto, senão o prompt não aparece):

```lua
cam.CameraType = Enum.CameraType.Scriptable
cam.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0,1.5,0), alvo.Position)
task.wait(1.1); prompt:InputHoldBegin(); task.wait(prompt.HoldDuration + 0.3); prompt:InputHoldEnd()
cam.CameraType = Enum.CameraType.Custom
```

- Teste **uma coisa por vez** e valide com um `return` curto.
- Parar o Play antes de editar. O Studio em Play bloqueia ferramentas de edição.
- Cuidado com criaturas durante testes longos: elas matam o jogador parado depois da carência (30 s).

## 6. Capturas de tela (imagens são caras)
- Só quando a pergunta for **visual** (aparência de modelo, UI, retrato). Nunca para checar lógica.
- Uma captura por alvo, com câmera já posicionada (`camera_position` e `look_at_position`).
- `SurfaceGui` renderiza com atraso: se vier preto, espere e repita **uma** vez.
- Cenas muito escuras (Cripta, sanatório) saem quase pretas no editor. Não tente corrigir isso com mais capturas.

## 7. Respostas
- Resumo final em **poucas linhas**: o que mudou, o que foi testado, o que não foi. Sem repetir código.
- Diga com honestidade o que **não** foi testado, em uma frase.
- Não narre cada chamada de ferramenta. Fale só nas decisões e nos resultados.
- Para documentos longos (história, protocolos), **escreva o arquivo uma vez** e referencie-o. Não cole o conteúdo no chat.

## 8. Mapa do projeto (não explore de novo)

**Mundo:** `Workspace.Lobby` (átrio a x≈-400), `Workspace.Levels.Fase1/2/3` (x = 0, 500, 1000), `Workspace.Entities` (criaturas em jogo).

**Scripts:**
| Onde | O que faz |
|---|---|
| `ServerScriptService.Match` | Lobby, filas (1/2/3/6), partida, fases, armários, itens |
| `ServerScriptService.Entities` | IA e modelos. **Ativas** (rostos do lobby): `clara` (F1), `eleanora` (F2, só ouve), `augustus` (F3, vê e ouve), `coro`. `visitante` e `enfermeira` ficaram sem uso |
| `ServerScriptService.Economy` | Moedas, loja, diária, gamepasses, DataStore |
| `ServerStorage.LevelBuilder` | Gera as 3 fases (labirinto + estilo `mansion` / `sanatorium` / `crypt`): lambri, molduras, portas, mobília, lustres, janelas, salão central |
| `ServerStorage.Figures` | Modelos 3D de Augustus, Eleanora e Clara |
| `ServerStorage.FigureAnimator` | Animação procedural das figuras (passo, balanço, tremor quando congelada) |
| `ReplicatedStorage.PortraitArt` | Retratos 2D desenhados com Frames; usados no lobby e no jumpscare |
| `ReplicatedStorage.ShopConfig` | Preços, recompensas, IDs de gamepass/produto |
| `StarterPlayerScripts.HorrorClient` | HUD, lanterna, medo, jumpscare, fases |
| `StarterPlayerScripts.ShopClient` | Loja (tecla B) |

**Remotes** (`ReplicatedStorage.Remotes`): Objective, Notify, Jumpscare, Sprint, Crouch, Chase, ClientReady, Phase, Result, Rush, Unhide, Tension, Wallet, ShopAction, UseBattery, Recharge.

**Atributos do jogador:** `InMatch`, `Hidden`, `BatteryLevel`, `StaminaLevel`, `Stealth`, `PremiumLight`, `Amulets`, `Batteries`.

**Pontos fixos de cada fase:** `Spawn`, `MonsterSpawn`, `Spots` (itens), `Lockers`, `Lamps`, `Center`, `Indicator`, `Gate`, `ExitZone`.

**Regras de design (já decididas, não rediscutir):** primeira pessoa; 3 fases (fusíveis → páginas → velas); quem morre volta na fase seguinte; amuleto salva uma vez; sem gore (alvo 16+).

## 8b. Código em arquivos (VS Code + Rojo)
Os scripts vivem em `src/` e são sincronizados com o Studio pelo Rojo (`rojo serve` + plugin). **O arquivo é a fonte da verdade**: edite no VS Code e deixe o Rojo sincronizar; não edite o mesmo script nos dois lados.

| Arquivo | Vai para |
|---|---|
| `src/server/*.server.luau`, `Entities.luau` | `ServerScriptService` |
| `src/serverStorage/*.luau` | `ServerStorage` |
| `src/shared/ShopConfig.luau` | `ReplicatedStorage` |
| `src/client/*.client.luau` | `StarterPlayerScripts` |

O mundo (lobby, fases, figuras, iluminação) **não** está nos arquivos: fica no lugar do Studio. Salve-o (`File → Save to File As…` ou publique) e regere as fases com `LevelBuilder` se precisar:
`B.build({name = 'Fase1', origin = Vector3.new(0,0,0), N = 5, seed = 1313, style = 'mansion'})` (Fase2: origem 500, N 6, seed 2027, `sanatorium`; Fase3: origem 1000, N 5, seed 666, `crypt`). Gere **uma fase por chamada** e recoloque `Fase3/Figures` (Augustus e Eleanora ao lado do altar).

## 8c. Exportar o Studio para os arquivos (sem gastar tokens)
O conteúdo dos scripts **não deve passar pelo chat**. Rode `tools/receiver.ps1` em segundo plano (`run_in_background`), ligue o `HttpService` no Studio, envie cada `Source` com `PostAsync("http://localhost:8765/", JSONEncode({path = 'src/...', content = script.Source}))` e **desligue o HttpService** no fim. Encerre o receptor depois (ele aceita até 12 arquivos e fecha sozinho em 4 min). Valide com `rojo build default.project.json -o <arquivo fora do projeto>.rbxlx`.

## 8d. Armadilhas já encontradas (não repetir)
- `Enum.Material.Tile` **não existe** (use `Marble`). Enum inexistente derruba o módulo inteiro no carregamento.
- Um `ModuleScript` que falhou ao carregar fica **em cache com erro**, mesmo depois de corrigir o `Source`. Clone o módulo, destrua o original e use o clone.
- `multi_edit` disparado **em paralelo** com `execute_luau` sobre o mesmo script pode não ser aplicado a tempo. Edite e só depois execute.
- Screenshot com a câmera dentro de uma parede só mostra a parede. Posicione a câmera dentro de uma sala, olhando para a porta.
- Para ler o erro de um módulo, compare `#LogService:GetLogHistory()` antes e depois do `require`, em vez de ler o console.

## 9. Checklist antes de cada resposta
- [ ] O Studio estava em Edit? (ou parei o Play)
- [ ] Usei `multi_edit` com trechos curtos em vez de reescrever?
- [ ] O teste devolveu um resumo pequeno e não uma árvore?
- [ ] Consultei o console no máximo uma vez, com filtro?
- [ ] Tirei no máximo uma captura por alvo?
- [ ] A resposta final cabe em poucas linhas e diz o que não foi testado?
