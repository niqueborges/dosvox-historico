# Princípios Arquiteturais e de Sobrevivência do DOSVOX

Este documento não descreve "como o código funciona", mas sim **"quais princípios permitiram que o código sobrevivesse"**. A longevidade do DOSVOX não se deve apenas a escolhas tecnológicas, mas principalmente a uma **filosofia rigorosa e consistente de interação humano-computador** e engenharia de software. O projeto adotou princípios que priorizam a autonomia do usuário cego, em vez de tentar adaptar a experiência visual padrão para ele.

## 1. Crescimento por Sedimentação
O sistema não cresceu refatorando ou destruindo código antigo para abraçar novos padrões. Ele cresceu **empilhando** novas abstrações (como `dvwin` e `dvform`) sobre as antigas (como `dvtradut`), sem quebrar a camada inferior. Códigos legados não eram reescritos; a terra sobre a qual eles rodavam era trocada sem que eles percebessem.

## 2. Compatibilidade Acima de Reescritas
Diante de mudanças tectônicas (como a transição do MS-DOS para o Windows em 1998), a equipe optou por preservar as aplicações e reescrever o interpretador (criando a `dvcrt.pas`). Eles protegeram o patrimônio de código da comunidade às custas de manter uma arquitetura "exótica" de emulação no núcleo. A curva de aprendizado e o conforto sonoro do usuário cego sempre tiveram mais valor do que modernizações estéticas desnecessárias.

## 3. Baixo Acoplamento Entre Aplicações e Infraestrutura
As aplicações (jogos, editores) dizem *o que* fazer (`sintetiza('texto')`), mas não sabem *quem* faz. A troca de sintetizadores (LianeTTS, SAPI4, SAPI5) ou a evolução do motor de fala não reverbera em quebra nos programas finais, graças à abstração estrita fornecida pelo "Kernel" (`dvwin`).

## 4. API Estável Baseada em Verbos de Ação
O contrato entre a aplicação e o sistema (o "SDK") manteve a mesma linguagem procedural simples por décadas (`sintetiza`, `sintWrite`, `readkey`). Essa linearidade evitou que os programadores (muitos com deficiência visual) precisassem reaprender arquiteturas orientadas a eventos (callbacks, threads) para continuarem produtivos.

## 5. Encapsulamento das Mudanças Tecnológicas nas Bordas
Quando tecnologias modernas (Python, VCL do Delphi nativo, Tesseract OCR, requisições HTTP) foram necessárias, elas **não invadiram o núcleo**. Elas foram isoladas na periferia do sistema (via módulos `.dfm`, executáveis externos ou scripts em arquivos `.inc`), mantendo o cerne histórico procedural imaculado.

## 6. Interface Sonora Como Experiência Primária
Diferente dos leitores de tela convencionais (que "traduzem" telas visuais do Windows para voz), o DOSVOX **nasce sonoro**. O som não é um adendo, é o núcleo do design da interface. As respostas textuais na tela não guiam a interação; elas são apenas um espelho do que a voz já confirmou.

## 7. Teclado Acima do Mouse
A interface inteira é pensada para eficiência tátil e sonora. O teclado não é um atalho; é o meio primário. O "texto" puro está acima de gráficos complexos na estruturação lógica de quase todas as aplicações.

## 8. Preservação da Colaboração (A Inclusão Colaborativa)
Apesar do sistema focar na autonomia absoluta do usuário cego, ele nunca se fechou para o mundo visual. A tela da emulação procedural e os "minicursos" visuais (em `.ppt`) provam a preocupação de permitir que videntes (pais, professores) acompanhassem ativamente o processo educativo. É comum ler em manuais que a exibição na tela serve *"para que um eventual observador que não seja deficiente visual possa também acompanhar o trabalho"*. São dois modos de acesso perfeitamente orquestrados para coexistirem.

## 9. Ecossistema sobre Monólito (Programas Pequenos)
Inspirado na filosofia UNIX, o DOSVOX constrói programas modulares, pequenos e especialistas. A métrica de "167 projetos independentes `.dpr`" prova que o DOSVOX **nunca foi um programa grande**. O crescimento ocorreu por adição contínua de programas focados, apoiados por uma infraestrutura comum ("Kernel 77"). A quebra de um aplicativo novo jamais derruba a máquina base.
