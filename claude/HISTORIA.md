# A DÍVIDA DE HOLLOW
*"Toda herança tem um preço."*

> **Atualização:** as criaturas do jogo são as mesmas personagens dos retratos do lobby, com a mesma aparência: **Clara** abre a partida (Fase 1) e volta no final da Fase 3, **Eleanora** chora e só ouve (Fase 2) e **Augustus** vê e ouve (Fase 3, com o Coro). Todas andam com animação procedural (passos, balanço, tremor) e, no jumpscare, aparece o próprio retrato 2D. Os três cenários foram refeitos com arquitetura própria (seção 2b). As seções 3.1 (Visitante) e 3.2 (Enfermeira) descrevem versões anteriores. Quem se esconde em armário precisa **esperar a tensão passar** para sair. A loja vende só **pacotes de moedas** em Robux.

Terror cooperativo em primeira pessoa para 2, 3 ou 6 jogadores. Inspiração de ritmo: Doors (armários, avisos antes do perigo, criaturas com regras próprias). Classificação-alvo: 16+. O medo vem de tensão, som e sugestão, sem gore explícito.

---

## 1. A história

### 1.1 O que aconteceu (1927)
Em Ravenmoor, o doutor **Augustus Hollow** era dono da maior mansão da cidade e do **Sanatório Hollow**, no porão. Sua filha **Clara**, de 8 anos, sofria de uma doença que nenhum médico conseguia nomear, a "Febre Cinzenta".

Desesperado, Augustus encontrou num livro proibido a oferta de uma entidade que "empresta anos": **o Credor**. Augustus assinou o **Contrato de Hollow**:

- **Cláusula I:** Clara viverá.
- **Cláusula II:** cada geração Hollow pagará uma alma. Se faltar sangue da família, o Credor aceita "hóspedes".
- **Cláusula III:** quem ler o contrato assume a dívida de quem não puder pagá-la.

Clara se curou, mas não envelheceu nem dormiu mais, e só se move quando ninguém a vê. O Credor a deixou viva como garantia, e ela é a promessa que o contrato precisa que ninguém veja quebrada.

Para pagar a Cláusula II sem sacrificar a própria família, Augustus passou a trazer pacientes sem família para o sanatório. **Margarethe Voss**, a enfermeira-chefe, executava os "tratamentos" que alimentavam o contrato.

**Eleanora**, a esposa, descobriu tudo e tentou queimar o contrato. Foi trancada no porão e levada pelo Credor. As vozes dos pacientes e a dela correm a mansão todas as noites, cobrando: **o Coro**.

Augustus se enforcou na cripta sob a capela, e a casa fechou.

### 1.2 Por que você está aqui
Cem anos depois, cada jogador recebe uma carta sem remetente: *"Sua herança o espera."*

Todos descendem de alguém que Augustus enganou, alimentou ou esqueceu. Pela Cláusula III, a dívida passou para vocês. O Credor virá cobrar. A única saída é descer pela mansão, pelo sanatório e pela cripta, reunir o contrato rasgado e queimá-lo antes que ele chegue.

### 1.3 A reviravolta
A última página do contrato (Fase 2) termina com os **nomes dos jogadores da partida**, escritos em tinta fresca. Quem lê assume a dívida. Isso prepara a segunda temporada: **os que escaparam são os próximos "hóspedes"**.

---

## 2. Objetivo (dificuldade média)
**Quitar a dívida em 3 fases (cerca de 12 a 20 minutos).**

| Fase | Local | Objetivo | Criatura |
|---|---|---|---|
| 1 | O Saguão (mansão, 5×5 salas) | Achar **5 fusíveis**, ligar o gerador e fugir pela porta a leste | Clara Hollow |
| 2 | O Sanatório (porão, 6×6 salas) | Achar **4 páginas** do contrato, queimá-las no incinerador e fugir | Eleanora Hollow |
| 3 | A Cripta (5×5 salas) | Acender **3 velas negras** no altar, romper o contrato e fugir do Credor | Augustus Hollow + O Coro, e no final Clara |

Regras gerais:
- Os itens são compartilhados pelo grupo.
- Quem morre observa um sobrevivente e **volta na próxima fase**.
- Se todos morrem na mesma fase, a partida acaba.
- Depois que o primeiro jogador chega à saída, os outros têm **12 segundos**.
- Ligar o gerador, o incinerador ou o altar **enfurece** as criaturas, que passam a saber onde você está. O final de cada fase é sempre uma corrida.

---

## 2b. Os cenários
Cada fase é um labirinto de salas de 28 studs com arquitetura própria, gerado pelo `LevelBuilder`:

- **Fase 1, o Saguão (mansão):** pé-direito de 16 studs, papel de parede vinho com lambri de madeira, rodapé, friso e sanca dourados, vigas no teto, molduras de porta com folhas entreabertas, janelas com cortinas nas paredes externas, tapetes, lustres de velas e retratos de família (alguns com olhos que brilham). As salas têm estantes, sofás, lareiras, piano, relógio de pé, camas de dossel, mesas de jantar e armaduras. No centro, o **salão** com piso de mármore xadrez, quatro colunas e o gerador.
- **Fase 2, o Sanatório:** reboco claro com azulejo até a altura do peito, canos no teto, lâmpadas fluorescentes frias, portas de metal, janelas gradeadas e quadros de avisos. Camas de enfermaria com soro e manchas, macas com um corpo coberto por lençol, cadeiras de rodas, armários de remédios, pias com espelho e cortinas divisórias. No centro, o incinerador.
- **Fase 3, a Cripta:** teto de 18 studs com nervuras de pedra, paredes de pedra escura, candelabros de ferro, túmulos com dois caixões, sarcófagos, anjos de pedra que choram, ossos e crânios, grades, poças d'água e teias de aranha. No centro, o altar dentro de um círculo ritual vermelho, com **Augustus e Eleanora** ao lado.
- Todas têm **armários** para se esconder (E), pontos de item e uma saída a leste. O lobby continua como era.

---

## 3. Os personagens

### 3.1 O Visitante, o Credor (versão anterior; hoje o Credor age pelos Hollow)
**Quem é:** a entidade que assinou o contrato. Não tem nome. Os mortos o chamam de "o Credor"; a mansão o chama de "o Visitante".

**Aparência:** quase 12 studs de altura, de cartola e casaco comprido. Seu rosto é de um branco de osso, e o sorriso é largo demais, com dentes pequenos e regulares como teclas de piano. Os olhos são dois pontos vermelhos que brilham no escuro. Tem braços compridos demais, e os dedos finos arrastam pelo chão enquanto ele anda. Não faz barulho nenhum, e o silêncio que o acompanha é o aviso.

**Comportamento:**
- Enxerga por linha de visão (60 studs) e ouve passos (14 andando, 34 correndo, 5 agachado).
- Patrulha, persegue, procura onde viu você pela última vez e volta a patrulhar.
- Se ficar mais de 3 segundos perto do seu armário, tem 50% de chance de abri-lo.

**Como sobreviver:** agache, apague a lanterna e esconda-se. Ele é rápido, então não dá para correr dele por muito tempo.

**Jumpscare:** o rosto pálido enche a tela e o grito é seco. Mensagem: *"O VISITANTE COBROU SUA DÍVIDA"*.

### 3.2 A Enfermeira, Margarethe Voss (versão anterior; hoje Eleanora faz a ronda do sanatório)
**Quem é:** a enfermeira-chefe do sanatório. Para não ver nem contar o que fez, costurou os próprios olhos e a boca. Ficou cega, mas aprendeu a escutar o mundo inteiro.

**Aparência:** curvada, com a cabeça inclinada para o lado, como quem escuta. Veste um vestido cinza-claro e um avental cor de ferrugem, com manchas escuras. Usa uma touca com uma cruz vermelha desbotada. Os olhos e a boca são linhas de pontos de linha preta. Carrega uma seringa de vidro, comprida demais, com um líquido escuro. Cabelo preto e fino escorre da touca. Sussurra uma cantiga de ninar.

**Comportamento:**
- É **cega**: lanterna e esconderijos à vista não importam.
- Ouve 30% mais longe que o Visitante: 18 andando, 44 correndo e 6 agachado.
- Quando não ouve nada, para e escuta por 2 a 4 segundos a cada ponto de patrulha.
- Quando ouve algo, vai direto ao som.

**Como sobreviver:** agache (C) e ande devagar quando ela estiver perto, e nunca corra no mesmo corredor. A lanterna pode ficar acesa.

**Jumpscare:** o rosto sem olhos, com a boca costurada, se aproxima. Mensagem: *"A ENFERMEIRA OUVIU VOCÊ"*.

### 3.3 Clara Hollow (Fase 1 e final da Fase 3)
**Quem é:** a filha de Augustus. Presa pelo contrato, ficou como uma boneca viva. Já não é a menina do retrato. Quer brincar de "estátua".

**Aparência:** pequena, de camisola creme rasgada, com o rosto de porcelana rachado por linhas pretas finas. As órbitas dos olhos são vazias, com um brilho vermelho minúsculo ao fundo. O sorriso é largo demais, quase de orelha a orelha. O cabelo preto e liso cai sobre o rosto. Segura uma boneca de pano com os mesmos olhos vazios. Ri baixinho.

**Comportamento:**
- **Só se move quando nenhum jogador a está olhando.** Se qualquer jogador a vê (na frente dele, em linha reta, a até 120 studs), ela congela.
- Sempre sabe onde você está e vem direto.
- **Anda de forma fluida:** acelera e faz curvas suaves, levanta os pés, balança a saia, as tranças e os braços com a boneca.
- **Congelada** (quando olhada), mantém a pose do passo e dá um tremor rápido de cabeça de tempos em tempos, para mostrar que está viva.
- Quem a encara e recua devagar fica seguro. Quem a olha com outra criatura por perto está em apuros.

**Como sobreviver:** nunca desvie o olhar quando ela estiver perto. Em grupo, uma pessoa a observa enquanto as outras trabalham. Mas lembre-se das vozes (3.4).

**Jumpscare:** o **retrato 2D do lobby** (porcelana rachada, órbitas vazias com brilho vermelho, sorriso largo, tranças com laços e a boneca) enche a tela com zoom e tremor. Mensagem: *"CLARA ESTAVA ATRÁS DE VOCÊ"*.

### 3.4 O Coro (Fase 3)
**Quem é:** os pacientes do sanatório e Eleanora. Estão presos na mansão e cobram a dívida a quem aparece.

**Aparência:** uma massa de sombra com rostos pálidos gritando, olhos e bocas escuros. No centro, um brilho vermelho ilumina tudo em volta. Uma fumaça escura o segue.

**Comportamento:**
- **Aviso de 6 segundos:** as luzes de todo o andar piscam, a mensagem *"AS VOZES ESTÃO CHEGANDO. ESCONDA-SE!"* aparece e o ambiente treme.
- **Investida em linha reta**, atravessando paredes, ao longo de uma fileira ou coluna aleatória. Mata quem estiver na faixa e não estiver escondido.
- Acontece a cada 50 a 85 segundos, a primeira depois de 50 s.

**Como sobreviver:** esconda-se em um armário assim que as luzes piscarem. O armário é a única defesa.

**Jumpscare:** vários rostos se fundem. Mensagem: *"O CORO LEVOU VOCÊ"*.

### 3.5 Augustus Hollow (Fase 3)
Médico e industrial, 56 anos. Nos retratos tem o olhar fixo e olhos que, no lobby, ficam vermelhos. Na Fase 3 anda de verdade, com o corpo do retrato (óculos dourados com lentes vermelhas, barba grisalha, casaco preto, corrente de relógio). **Vê e ouve**: linha de visão de 60 studs e passos (14 andando, 34 correndo, 5 agachado); patrulha, persegue e procura. Se ficar mais de 3 segundos perto do armário, tem 50% de chance de abri-lo. Antes disso, aparece parado ao lado do altar. Jumpscare: o retrato dele em zoom. Mensagem: *"AUGUSTUS COBROU SUA DÍVIDA"*. Sua vela: *"Fui eu quem assinou. Perdoe-me, Clara."*

### 3.6 Eleanora Hollow (Fase 2)
A mãe. Escreve nas margens do contrato e deixa recados nas páginas. Na Fase 2 faz a ronda do sanatório com o corpo do retrato (vestido azul-esverdeado, pérolas, lágrima, o contrato queimado nas mãos). **Só ouve**: tem 30% mais alcance que Augustus (18 andando, 44 correndo, 6 agachado) e para a cada ponto de patrulha para escutar. Jumpscare: o retrato dela em zoom. Mensagem: *"ELEANORA OUVIU VOCÊ"*. Sua vela: *"Queime o papel. Mesmo que eu seja a última a ver."* Sua voz está no Coro.

### 3.7 Os Herdeiros (jogadores)
Descendentes das pessoas que Augustus enganou. Cada um recebeu uma carta e entrou na mansão por vontade própria. O Credor já sabe seus nomes, que estão na Cláusula III.

---

## 4. As páginas e velas (textos do jogo)

**Páginas (Fase 2):**
1. *Cláusula I — "Eu, Augustus Hollow, cedo ao Credor os anos de minha filha Clara, em troca de sua vida."*
2. *Cláusula II — "Cada geração Hollow pagará uma alma. Se faltar sangue, o Credor aceita hóspedes."* Na margem, a letra de Eleanora: *"Ele trouxe os pacientes para o porão. Os gritos pararam."*
3. *Diário da enfermeira Voss — "Costurei meus olhos para não ver o que fiz. Depois a boca, para não contar. Agora só escuto. O Credor disse que o silêncio é a quitação."*
4. *Cláusula III — "Quem ler estas páginas assume a dívida de quem não puder pagá-la."* Embaixo, em tinta fresca, estão os seus nomes.

**Velas (Fase 3):**
1. *Vela de Augustus — "Fui eu quem assinou. Perdoe-me, Clara."*
2. *Vela de Eleanora — "Queime o papel. Mesmo que eu seja a última a ver."*
3. *Vela de Clara — "Eu ainda estou aqui. Quando você olha para mim, eu fico quietinha."*

---

## 5. Finais
- **Dívida quitada** (vitória): *"O contrato queimou. Em algum lugar, uma menina finalmente parou de sorrir. ...Mas a carta nunca disse quem a escreveu."*
- **Dívida permanece** (derrota): *"O Credor guarda os seus nomes. Ele é paciente. Toda herança tem um preço."*

## 6. Ganchos para o futuro
- Quem completa as 3 fases pode ganhar a conquista **Último Herdeiro**.
- Segunda temporada: o **Hotel Ravenmoor**, onde os herdeiros são os hóspedes e o Credor é o recepcionista.

## 7. Sistemas e acessibilidade
- **Esconder-se:** nos armários, um medidor de **tensão** sobe com a criatura por perto. Só se pode sair quando o medidor baixa (mais de 16 studs de distância e sem o Coro passando).
- **Lanterna:** feixe estreito e forte com borda suave, que ilumina só onde você aponta.
- **Celular:** botões de toque (Lanterna, Correr, Agachar, Pilha e Sair do armário), interface que escala com a tela, loja que encolhe para caber e sombras da lanterna desligadas para ganhar desempenho.
- **Loja:** melhorias e itens com moedas ganhas jogando; o único item pago são **pacotes de moedas** em Robux.
