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
