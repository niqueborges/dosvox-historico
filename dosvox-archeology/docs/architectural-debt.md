# Autópsia de Dívida Arquitetural Histórica

Uma das descobertas mais raras na pesquisa arqueológica do DOSVOX é a transparência com que o ecossistema acumulou acoplamentos. Este documento não expõe "erros", mas descreve como tecnologias que chegaram depois acabaram se cristalizando na base por necessidades prementes, resultando em "Dívidas Arquiteturais" sedimentares que foram mantidas porque funcionavam.

## 1. Dependências Inesperadas e Acoplamentos Universais
O caso mais emblemático do ecossistema: a contaminação do Kernel.
- **O Fato:** A biblioteca nuclear `dvcrt` possui um `uses` explícito para `dvmouse`. 
- **O Teste Empírico:** O método "Knockout" mostrou que, ao apagar a `dvmouse` (uma biblioteca hiper-especializada de Classe C focada na rodinha do mouse), 100% da Amostra de Ouro falhou a compilação, incluindo editores, cálculos matemáticos estritos e jogos sem interface de clique.
- **A Sedimentação:** A interceptação do `wm_MouseWheel` foi adicionada na janela virtual de texto (`dvcrt`) muito tempo depois do seu nascimento, transformando um periférico opcional numa âncora existencial para toda a plataforma.

## 2. Wrappers Acumulados
No esforço brutal para manter a interface com os programadores simples e imutável (o "SDK Implícito"), o DOSVOX precisou criar "Wrappers" em torno do Windows para isolar a complexidade do Ecossistema B (Delphi).
- **A Dívida:** Ao longo do tempo, as bibliotecas de voz (`dvsapi4`, `dvsapi5`, `speechLib_TLB`) e de rede (`Synapse`) foram introduzidas empilhando invólucro sobre invólucro para se comunicarem com a `dvwin`, fazendo com que a malha de resolução de compilação da camada 1 carregue componentes pesados (COM, OLE) na partida inicial do software, quando na verdade poderiam ser plugins carregados dinamicamente apenas quando requisitados pelas Camadas 3 e 4.

## 3. Retrocompatibilidades Preservadas (O Paradoxo Funcional)
Alguns componentes continuam existindo e sendo compilados meramente porque as fundações confiam que eles ainda estão lá.
- Muitas funções antigas de formatação CRT persistem emuladas na `dvcrt` e são importadas pelos programas clássicos não porque o Windows precisa, mas porque ferramentas do "Mutirão Vox" de 1996 utilizam a mesma sintaxe de Turbo Pascal. A dependência transitiva é tolerada e arrastada de geração em geração.

## 4. Camadas que Sobreviveram por Conveniência
O isolamento em binários paralelos (`DOSDOS`, `DOSED`) ou `executaProg` foi usado para manter velhas rotinas de disco ou acesso ao SO funcionando, mesmo quando as APIs do Delphi ou Windows já ofereciam abstrações modernas de `SysUtils`. Essa conveniência gerou um ecossistema com alta proliferação de EXEs que operam praticamente as mesmas tarefas nucleares, multiplicando o esforço de manutenção.
