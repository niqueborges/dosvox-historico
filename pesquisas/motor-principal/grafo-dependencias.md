# Grafo de Dependências e Arquitetura do Sistema

Para entender a organização do código, extraí e cruzei as cláusulas `uses` (importações) de todos os **950 arquivos** de código-fonte (`.pas` e `.dpr`) presentes no Dosvox. O resultado revela uma arquitetura altamente hierárquica e bem definida.

---

## 1. As Units Mais Utilizadas (In-Degree)

Excluindo as bibliotecas padrão do Windows e do compilador Delphi (`SysUtils`, `Windows`, `Classes`), estas são as units exclusivas do ecossistema Dosvox que são invocadas por praticamente todos os programas:

1. **`dvcrt`** (736 dependências): O coração da interface de texto.
2. **`dvwin`** (694 dependências): Rotinas de fala e síntese de voz (O "motor" de leitura).
3. **`dvform`** (287 dependências): Controles de interface de usuário (menus, diálogos).
4. **`dvexec`** (111 dependências): Execução de processos encadeados (como o menu chamando um jogo).
5. **`dvarq`** (110 dependências): Abstrações para leitura e gravação segura de arquivos.
6. **`dvinet`** (99 dependências): Camada de protocolos de internet (TCP/IP).
7. **`dvhora`** (82 dependências): Manipulação de data, hora e relógios.
8. **`dvwav`** (53 dependências): Manipulação direta e tocador de arquivos de áudio wave.

---

## 2. A Infraestrutura Central e os Componentes Fundamentais

Se você apagasse as units **`dvcrt.pas`** e **`dvwin.pas`**, **cerca de 77% dos programas parariam de compilar e funcionar imediatamente**. 

Elas formam a "Trindade" do framework Dosvox (junto com a `dvform`). 
A arquitetura é montada sobre uma premissa básica: todo programa precisa desenhar texto em uma janela (`dvcrt`) e imediatamente enviar a string de caracteres desenhada para ser falada pelo sintetizador de voz (`dvwin`). Essas duas bibliotecas andam de mãos dadas em quase todo o código fonte para garantir a acessibilidade total em tempo real.

---

## 3. Módulos Independentes

Descobri cerca de **95 arquivos** que **não importam nenhuma outra unit** do sistema (nem mesmo bibliotecas do Delphi ou o próprio `dvcrt`). Eles são os módulos mais isolados da arquitetura. 

**Características deles:**
Quase todos têm o sufixo "VARS", "DADOS" ou similares (Exemplos: `AGVARS.PAS`, `BRVARS.PAS`, `CATAVARS.PAS`). 
Esses arquivos são estritamente **repositórios de estado e estruturas de dados**. Eles contêm definições de `records`, constantes, arrays globais e tipos de variáveis. O fato de serem isolados demonstra uma boa prática de arquitetura procedural: os dados estão puramente isolados da lógica de apresentação (voz e tela) e da lógica de negócio.

---

## 4. O Grafo em Camadas (A Arquitetura Encontrada)

A arquitetura geral do DOSVOX se revela um elegante **Monolito Modular em Camadas**, estruturado da seguinte forma (da base ao topo):

### Camada 0: Sistema Operacional e Base Delphi
* **Componentes:** `Windows`, `SysUtils`, `Classes`, Bibliotecas C (`bass.dll`).
* **Responsabilidade:** Chamadas nativas de SO (abrir janelas, alocar memória, sockets TCP).

### Camada 1: O Framework de Acessibilidade (O Core)
* **Componentes:** `dvcrt.pas` (Interface Gráfica que finge ser Texto), `dvwin.pas` (Integração de Voz e Multimídia), `dvtradut.pas` (Tradução Braille subjacente).
* **Responsabilidade:** Abstrair o Windows. Aqui o sistema cria a "ilusão" para a Camada 3 de que os programas estão rodando no velho ambiente DOS falado. Toda a carga pesada de interceptar teclas e disparar voz para os drivers instalados ocorre aqui.

### Camada 2: Serviços Compartilhados
* **Componentes:** `dvform.pas` (Caixas de diálogo padronizadas), `dvexec.pas` (Processos), `dvarq.pas` (Arquivos), `dvinet.pas` (Rede), `dvwav.pas` (Áudio direto).
* **Responsabilidade:** Entregar utilidades de alto nível que programas frequentemente precisam (fazer download de um arquivo, formatar uma lista de menu, ler um diretório em ordem alfabética e já preparar a string falada).

### Camada 3: Aplicações do Usuário Final (Os Módulos)
* **Componentes:** O topo da pirâmide. Onde moram as centenas de `.dpr` como `webvox.dpr`, `jogavox.dpr`, `cartavox.dpr`.
* **Responsabilidade:** Eles não sabem como falar ou desenhar gráficos; eles simplesmente dizem: *"dvWin, leia este e-mail"*, *"dvCrt, pinte a tela de azul e espere a tecla Enter"* ou *"dvForm, monte um menu com 5 opções de música"*.
* **Isolamento de Dados:** Como visto, eles delegam seu próprio estado para arquivos independentes (`*VARS.pas`).
