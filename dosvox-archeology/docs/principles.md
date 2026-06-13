# Princípios Arquiteturais e de Sobrevivência do DOSVOX

Este documento não descreve "como o código funciona", mas sim **"quais princípios permitiram que o código sobrevivesse"**. A história das ideias embutidas no DOSVOX tende a durar muito mais do que qualquer linguagem ou framework específico. O sistema não sobreviveu 30 anos por acaso, mas por escolhas de engenharia deliberadas ou intuitivas que formaram uma filosofia robusta.

## 1. Crescimento por Sedimentação
O sistema não cresceu refatorando ou destruindo código antigo para abraçar novos padrões. Ele cresceu **empilhando** novas abstrações (como `dvwin` e `dvform`) sobre as antigas (como `dvtradut`), sem quebrar a camada inferior. Códigos legados não eram reescritos; a terra sobre a qual eles rodavam era trocada sem que eles percebessem.

## 2. Compatibilidade Acima de Reescritas
Diante de mudanças tectônicas (como a transição do MS-DOS para o Windows em 1998), a equipe optou por preservar as aplicações e reescrever o interpretador (criando a `dvcrt.pas`). Eles protegeram o patrimônio de código da comunidade às custas de manter uma arquitetura "exótica" de emulação no núcleo.

## 3. Baixo Acoplamento Entre Aplicações e Infraestrutura
As aplicações (jogos, editores) dizem *o que* fazer (`sintetiza('texto')`), mas não sabem *quem* faz. A troca de sintetizadores (LianeTTS, SAPI4, SAPI5) ou a evolução do motor de fala não reverbera em quebra nos programas finais, graças à abstração estrita fornecida pelo "Kernel" (`dvwin`).

## 4. API Estável Baseada em Verbos de Ação
O contrato entre a aplicação e o sistema (o "SDK") manteve a mesma linguagem procedural simples por décadas (`sintetiza`, `sintWrite`, `readkey`). Essa linearidade evitou que os programadores (muitos com deficiência visual) precisassem reaprender arquiteturas orientadas a eventos (callbacks, threads) para continuarem produtivos.

## 5. Encapsulamento das Mudanças Tecnológicas nas Bordas
Quando tecnologias modernas (Python, VCL do Delphi nativo, Tesseract OCR, requisições HTTP) foram necessárias, elas **não invadiram o núcleo**. Elas foram isoladas na periferia do sistema (via módulos `.dfm`, executáveis externos ou scripts em arquivos `.inc`), mantendo o cerne histórico procedural imaculado.

## 6. Interface Sonora Como Experiência Primária
Diferente dos leitores de tela convencionais (que "traduzem" telas visuais do Windows para voz), o DOSVOX **nasce sonoro**. As respostas textuais na tela não guiam a interação; elas são apenas um espelho do que a voz já confirmou.

## 7. Preservação da Colaboração (Inclusão Colaborativa)
Apesar do sistema focar na autonomia absoluta do usuário cego (uso focado no teclado e feedback por áudio), ele nunca se fechou para o mundo visual. A tela da emulação procedural e os "minicursos" visuais (em `.ppt`) provam a preocupação de permitir que videntes (pais, professores) acompanhassem ativamente o processo educativo, criando dois modos de acesso perfeitamente compatíveis.

## 8. Ecossistema sobre Monólito
A métrica de "167 projetos independentes `.dpr`" prova que o DOSVOX **nunca foi um programa grande**. O crescimento ocorreu por adição contínua de programas relativamente independentes, pequenos e focados, todos apoiados por uma infraestrutura comum ("Kernel 77"). Essa descentralização em um *ecossistema de aplicações* em vez da expansão infinita de um único executável é uma das razões mais profundas da sobrevivência do sistema: a quebra de um aplicativo novo jamais derruba a máquina base.
