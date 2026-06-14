# Arquitetura do DOSVOX

O DOSVOX é um ecossistema estruturado em camadas claras, o que explica sua incrível longevidade. A arqueologia revelou que a arquitetura não é monolítica, mas sustentada por um forte princípio de abstração e pela coexistência pacífica de diferentes gerações de código.

## 1. Mapa Arquitetural

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

## 2. As Duas Arquiteturas Coexistentes (Ecossistema A e B)

O ecossistema abriga dois paradigmas arquiteturais distintos que coabitam a mesma base de código há décadas.

### Ecossistema A (O Paradigma DOSVOX Clássico)
Este é o coração histórico do sistema, onde a vasta maioria dos jogos, editores e aplicativos de usuário operam.
- **Modelo de Programação:** Procedural linear. Sem componentes visuais, sem classes, sem laço de eventos explícito para o programador.
- **Fluxo Típico:** O programa faz algo, chama `sintetiza`, imprime na tela, bloqueia esperando o teclado (`readkey`), e reage. A emulação da interface é feita no terminal virtual e por áudio.
- **Abstração Vertical:** Aplicação -> `dvform` -> `dvwin` -> `dvcrt` -> API do Windows (escondida do programador final).

### Ecossistema B (O Paradigma Delphi / VCL)
Surgiu quando módulos especializados precisaram ultrapassar as barreiras da emulação de texto para integrar profundamente com o Windows.
- **Modelo de Programação:** Orientado a objetos e eventos. Focado na VCL (Visual Component Library).
- **Fluxo Típico:** Formulários desenhados na tela com janelas e callbacks atrelados a eventos do SO.
- **Exemplos:** `PPTVOX` (Integração pesada com COM/Office), `DICIO`, `sapi4cnf`.

Isolar a complexidade do Ecossistema B na periferia garantiu que qualquer desenvolvedor em 2026 consiga entender e modificar aplicações clássicas de 1994 sem exigir conhecimentos avançados de Win32.

## 3. O Princípio de Inversão de Dependência

Em vez das aplicações chamarem diretamente os motores de voz específicos (o que quebraria todo o sistema se o motor mudasse), o DOSVOX inverteu a dependência:
Aplicações -> `dvwin` (Kernel) -> `dvserpro` -> `LianeTTS` / `SAPI`.

As aplicações **não sabem quem sintetiza a voz**. Elas apenas emitem o comando genérico para a infraestrutura, garantindo que o código-fonte original continue imaculado independentemente da evolução tecnológica dos sintetizadores.

## 4. O Modelo de Programação (O SDK Implícito)

A infraestrutura expõe o que podemos chamar de um **SDK de Acessibilidade procedural**, focado em facilidade de uso para quem escreve o programa.

### O Ciclo de Vida Típico
1. `sintInic(...)` (Inicializa o motor de voz e a tela dvcrt)
2. `sintetiza('Titulo')` (Fala o que o programa é)
3. Laço principal (Menu, captura de teclas, lógica procedural)
4. `sintFim` / `doneWinCrt` (Encerra o acesso e a janela)

### O Dicionário de Ações Clássico
- **Falar um texto:** `sintetiza('texto');`
- **Imprimir e Falar:** `sintWriteln('texto');`
- **Esperar uma tecla:** `c := readkey;`
- **Saber se apertou tecla:** `if keypressed then ...`
- **Perguntar um texto ao usuário:** `sintEditaCampo(...)` (cuida de falar cada letra durante a digitação)
- **Bloquear enquanto fala:** `while sintFalando do waitMessage;`

## 5. A Grande Migração (1998)

Em 1998, a equipe precisou migrar do MS-DOS para o Windows. Em vez de reescrever centenas de aplicativos, eles preservaram rigorosamente a *API pública* do ambiente DOS (a biblioteca CRT original), substituindo apenas a sua *implementação* interna. 

A `dvcrt.pas` tornou-se um *Adapter Pattern* de altíssimo nível. Ela interceptava comandos antigos (`GotoXY`, `ClrScr`, `TextColor`) e os traduzia silenciosamente para chamadas Win32, criando uma "janela de texto virtual" para as aplicações. Essa camada de compatibilidade foi o principal fator tecnológico que permitiu a sobrevivência do ecossistema DOSVOX na era do Windows.
