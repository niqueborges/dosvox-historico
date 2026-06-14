# Validação Histórica (History Crosswalk)

A história oral e os relatos do criador do DOSVOX (Antonio Borges) confirmam diversas hipóteses levantadas puramente pela análise estática e arqueológica do código-fonte. A tabela abaixo relaciona trechos da documentação histórica, evidências encontradas no código, as hipóteses originais e o grau de confirmação.

| Evidência textual | Evidência do código | Hipótese anterior | Grau de confirmação |
| :--- | :--- | :--- | :--- |
| **Mutirão Vox** ("Antonio convocou então os seus alunos... a participarem de um mutirão vox") | 167 projetos `.dpr`, 854 arquivos `.pas`, múltiplos estilos de programação, diferentes gerações convivendo | Crescimento por sedimentação / Plataforma federada sem reescrita única | **Alta** |
| **Preferência pela voz original** ("muitos usuários antigos ainda preferem a síntese original pela sua velocidade") | `dvtradut` e a manutenção do sistema de síntese clássica preservado ao lado da SAPI | Compatibilidade cultural e estabilidade de interface vocal | **Alta** |
| **Editor surgiu primeiro** ("Esse programa foi a base do que veio depois a se transformar num poderoso editor de textos, o EDIVOX") | `EDIVOX` possui grande centralidade e independência do resto do sistema | Centralidade do editor precedendo o shell | **Média** |
| **Usuários sugeriam funções** ("os usuários sugeriam mais e mais ideias que eram imediatamente acrescentadas") | Expansão constante de módulos, diretório `dosvox-apps` muito vasto e com aplicações de nicho | Evolução incremental orientada a necessidades | **Alta** |
| **Arquitetura baseada em verbos** ("SoleArq", "Televox", "Edivox", "Vox", "Gerenciador") | Variáveis e processos como `sintetiza`, `sintEditaCampo`, `executaProg` | Modelo mental orientado à ação e ao verbo em vez de controle visual / widget | **Alta** |
| **Adaptação contínua** ("Mais do que as ferramentas em si, estava a possibilidade de adaptá-las...") | Fósseis convivendo com VCL, pontes Win32, NVDA, Synapse, isolamento tecnológico nas bordas | Princípio da compatibilidade acima de reescritas / Crescimento sem quebrar o existente | **Alta** |

Este documento atua como uma "Pedra de Roseta" ligando a história contada e vivida (a documentação humana) às evidências descobertas de forma empírica nas estruturas do código atual.
