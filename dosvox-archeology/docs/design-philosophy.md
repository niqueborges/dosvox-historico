# A Filosofia de Design do DOSVOX

*(Documento em construção)*

A longevidade do DOSVOX não se deve apenas a escolhas tecnológicas (como a linguagem usada), mas principalmente a uma **filosofia rigorosa e consistente de interação humano-computador**. O projeto adotou princípios que priorizam a autonomia do usuário cego, em vez de tentar adaptar a experiência visual padrão para ele.

## Princípios Observados na Arquitetura

1. **Teclado acima do mouse:** A interface inteira é pensada para eficiência tátil e sonora. O teclado não é um atalho; é o meio primário.
2. **Texto acima de gráficos:** Em vez de tentar "ler uma tela visual" (como os leitores de tela tradicionais), as aplicações do DOSVOX nascem estruturadas em texto.
3. **Voz integrada desde o início:** O programa já assume que a saída principal será a voz do sintetizador. O som não é um adendo, é o núcleo do design da interface.
4. **Programas pequenos:** Uma abordagem inspirada na filosofia UNIX — construir programas modulares, pequenos e especialistas, que fazem apenas uma coisa, mas a fazem muito bem.
5. **Forte modularização e Baixo acoplamento:** A separação estrita entre quem manda falar (as aplicações) e quem fala (os sintetizadores como LianeTTS ou SAPI).
6. **Preservação de compatibilidade:** O sistema manteve a estabilidade da interface e da voz por décadas, reconhecendo que a curva de aprendizado e o conforto sonoro do usuário cego têm mais valor do que modernizações estéticas desnecessárias.

Essa filosofia de design é talvez o maior ativo a ser preservado em futuras reescritas do projeto.

---

## 7. A Inclusão Colaborativa (O Cego e o Vidente)

O estudo combinado do código da `dvcrt`, das mensagens de UX e dos materiais oficiais de ensino revela um paradigma sutil e brilhante de convivência. Não se trata de uma arquitetura feita *apenas* para o cego isolado do mundo.

**Evidência:**
- Os manuais principais do sistema (`Dosvox.txt`, `Edivox.txt`, `Minied.txt`) são distribuídos em texto puro (.txt). 
- Eles descrevem a interação exclusivamente por teclado e resposta sonora (sem mouse).
- Os minicursos didáticos são distribuídos em PowerPoint (`.ppt`).
- O manual do `Minied` afirma textualmente que a exibição na tela serve *"para que um eventual observador que não seja deficiente visual possa também acompanhar o trabalho"*.

**Inferência:**
O sistema foi concebido arquiteturalmente para privilegiar de forma absoluta a interação sonora (o `.txt` puro para o usuário cego), mas preservou deliberadamente vias de acesso gráficas (a tela emulada do `dvcrt` e os slides em `.ppt`) adequadas para aulas presenciais e para os professores/familiares videntes.

**Hipótese Histórica:**
A equipe do DOSVOX buscou resolver um problema sociotécnico: garantir a autonomia total e independente do usuário cego na máquina, sem impedir a participação ativa, a aprendizagem e a colaboração da sua família ou educadores. São dois modos de acesso perfeitamente orquestrados para coexistirem.
