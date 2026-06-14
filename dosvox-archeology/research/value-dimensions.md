# As Três Dimensões de Valor (DOSVOX)

A arqueologia de sistemas legados de longa vida, como o DOSVOX, exige que evitemos classificar módulos ou artefatos de forma binária ("importante" vs "descartável").

Um executável ou trecho de código pode ter altíssima relevância em uma dimensão e nenhuma em outra. Para nortear nossa taxonomia e os "Cortes de Extração", estabelecemos três eixos independentes de valor:

## 1. Valor Histórico
**Pergunta que responde:** "O que isso nos diz sobre a evolução do sistema?"

- Representa um artefato que preserva paradigmas do passado, decisões antigas de design ou comprova genealogia.
- **Exemplo Clássico:** `Mistuvox`. Pode não ser utilizado diariamente hoje, mas possui fortes evidências datadas (ex: 1994) e revela como a arquitetura inicial integrava jogos e lógica procedimental.
- **Ausência no Mini:** Frequente. A distribuição moderna costuma podar o valor histórico por peso, o que torna a arqueologia nos fontes ainda mais essencial.

## 2. Valor Arquitetural
**Pergunta que responde:** "O quão central este componente é para a estrutura do software?"

- Representa o acoplamento, a dependência técnica, e o quão próximo o componente está do coração (Core) tecnológico. Se o componente desaparecer, o build falha ou o ecossistema colapsa.
- **Exemplo Clássico:** `PPTVOX`. É um ponto fora da curva que usa tecnologias de borda (OLE/VCL) interagindo com o núcleo. Possui alto valor para entender os limites arquiteturais.
- **Ausência no Mini:** Possível (como o PPTVOX), pois a arquitetura pode suportar plugins opcionais que, embora vitais para o entendimento do "todo", não são exigidos no mínimo operacional.

## 3. Valor Operacional
**Pergunta que responde:** "O que um usuário moderno absolutamente necessita para operar o sistema?"

- Representa a utilidade prática final. Responde ao escopo de uso cotidiano (edição de texto, navegação básica).
- **Exemplo Clássico:** `Forcavox` ou `Sudovox`. Preservados na instalação mínima (`Mini`), não necessariamente porque possuem código sofisticado ou dependências críticas, mas porque provêem valor tangível e engajamento mínimo necessário para o usuário alvo segundo a visão dos mantenedores.
- **Ausência no Mini:** Muito improvável. Se tem alto valor operacional, os mantenedores quase certamente o incluíram.

---

> [!NOTE]
> **A Regra de Curadoria:**
> Nenhuma aplicação entra definitivamente em `dosvox-apps/` porque ela é "famosa", antiga, ou porque "está no instalador Mini".
> Ela só será admitida se, após análise em Sandbox e compilação experimental, demonstrar ser uma unidade **coesa e representativa** em uma (ou mais) destas três dimensões, auxiliando na compreensão holística do DOSVOX.


## Regras e Filosofia de Curadoria

1. **Transferência não implica canonização:** Copiar algo para dosvox-apps/ ou dosvox-core/ não significa que aquele módulo recebeu um selo definitivo. É apenas um ambiente experimental.
2. **Ausência no Mini não implica irrelevância:** mistuvox, jogavox ou pptvox podem ter enorme valor histórico ou arquitetural mesmo estando ausentes do núcleo operacional mínimo.
3. **Frequência de uso não mede importância:** DOSDOS.PAS pode ser inútil operacionalmente hoje e ainda assim ser um dos artefatos mais importantes para entender a transição DOS → Windows.
4. **Um contraexemplo vale mais que cem confirmações:** Se aparecer um programa antigo que contorne a dvcrt, ou uma unit que quebre a estratificação vertical, este artefato tem alto valor científico e exige investigação prioritária.
5. **A estrutura final deve emergir das evidências:** Não devemos decidir previamente o que é dosvox-core. O próprio sistema deve revelar isso através de suas dependências, distribuições, gerações e builds.
6. **Curadoria experimental e não destrutiva:** Trabalhar exclusivamente com cópias, nunca mover nada do diretório original e assumir que qualquer classificação atual é provisória.

