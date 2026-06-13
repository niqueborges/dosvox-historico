# Arquitetura do DOSVOX

O DOSVOX é um ecossistema estruturado em camadas claras, o que explica sua incrível longevidade.

## Mapa Arquitetural

1. **Núcleo (Framework / Runtime)**
   - `dvcrt`, `dvwin`, `dvform`, `dvarq`, `dvexec`, `dvinet`, `dvhora`, `dvwav`, `dvtradut`, `dvsapi`
   - Concentram a complexidade de lidar com o sistema operacional (Windows), acessibilidade nativa, rede e renderização de janelas/teclado.
2. **Shell**
   - `dosvox.dpr`, `dosconf`, `dosdir`, `doscopia`
   - O orquestrador central por onde o usuário entra no ecossistema e navega entre os módulos.
3. **TTS (Text-to-Speech)**
   - `lianetts`, `SAPI4`, `SAPI5`
   - Motores de síntese de voz (plugins).
4. **Aplicações (Módulos)**
   - `Cartavox`, `Webvox`, `Edivox`, `Jogavox`, `Chessvox`
   - Programas de usuário final.

## O Princípio de Inversão de Dependência (Dependency Inversion)

A maior descoberta arquitetural do DOSVOX é a sua implementação natural da Inversão de Dependência, construída décadas antes desse termo se popularizar.

**O Problema comum:** Em sistemas mal projetados, uma aplicação como o "Chessvox" chamaria diretamente a API do sintetizador de voz (ex: LianeTTS). Se o sintetizador quebrar ou for trocado, todas as dezenas de jogos e aplicativos precisariam ser reescritos.

**A Solução no DOSVOX:**
Aplicações (`Chessvox`, `Cartavox`) -> dependem de -> `dvwin` (Framework) -> que delega para -> `dvserpro` -> `LianeTTS`.

As aplicações **não sabem quem sintetiza a voz**. Elas apenas emitem o comando "fale isso" para a `dvwin`. A `dvwin` decide, baseada na infraestrutura, qual motor usar (Liane, SAPI, etc). Isso garante que o código das aplicações continue imaculado, independentemente da evolução tecnológica dos sintetizadores de voz.

## A Grande Migração (1998)

**Evidência:**
A declaração de cabeçalho da unit `dvcrt.pas` diz textualmente: *"Dosvox CRT emulation procedures. Based on the Turbo Pascal Runtime Library Windows CRT Interface Unit. January/1998"*. Em seu código-fonte estão implementadas as mesmas funções exatas e matrizes (`80x25`) da biblioteca original do MS-DOS (`GotoXY`, `WhereX`, `ClrScr`, `TextColor`, `KeyPressed`, `ReadKey`).

**Inferência:**
Os desenvolvedores preservaram rigorosamente a *API pública* do ambiente DOS, mas substituíram a sua *implementação* interna. A `dvcrt` é, na prática, um *Adapter Pattern* de altíssimo nível. Ela interceptava os comandos antigos (que antes manipulavam diretamente o hardware de vídeo e teclado no DOS) e os traduzia para chamadas Win32, criando uma "janela de texto virtual" (CRT) para as aplicações no Windows.

**Hipótese Histórica:**
Essa camada de compatibilidade arquitetural foi o principal fator tecnológico que permitiu ao ecossistema DOSVOX atravessar a dramática transição estrutural "MS-DOS → Windows" sem exigir uma reescrita generalizada de centenas de aplicativos pré-existentes. O modelo mental do desenvolvedor e o código-fonte permaneceram intactos, apenas o interpretador (`dvcrt`) mudou por baixo.
