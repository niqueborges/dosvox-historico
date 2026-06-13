# Genealogia dos Verbos (D.3)

O DOSVOX é programado através de um dialeto muito peculiar de Pascal. Os desenvolvedores não utilizavam a biblioteca padrão do Delphi diretamente (como `WriteLn` ou controles visuais tradicionais). Eles moldaram a plataforma através de uma série de "verbos" globais. 

Este documento mapeia o nascimento e o propósito das seis ações primordiais da linguagem do DOSVOX.

## `ReadKey`
- **Onde nasceu:** `dvcrt.pas` (Camada 2 - Classe A)
- **O que faz:** Função clássica do Pascal/DOS recriada para o Windows. Ela intercepta eventos de tecla e bloqueia a execução até o usuário interagir.
- **Quem a consome:** Literalmente todos os utilitários de modo texto (Edivox, Jogos, Mistuvox). É o principal input do paradigma de diálogo interativo (computador pergunta, cego responde).
- **Status:** Ativo e existencial. Sem `ReadKey`, o DOSVOX é surdo ao teclado.

## `sintetiza`
- **Onde nasceu:** `dvWin.pas` (Camada 1 - Classe A)
- **O que faz:** Envia uma string de texto para o buffer de pronúncia do motor de fala (seja SAPI ou nativo), sem necessariamente exibi-la na tela.
- **Quem a consome:** Componentes de notificação invisível e menus (ex: Webvox lendo links, Cartavox lendo remetentes).
- **Status:** Ativo e vital. É o output puro de acessibilidade.

## `sintWrite`
- **Onde nasceu:** `dvWin.pas` (Camada 1 - Classe A)
- **O que faz:** O equivalente ao `Write` do Pascal, mas projetado para acessibilidade. Ele imprime a string na janela gráfica procedural (via `dvcrt` hooks) e **também a fala** em voz alta via sintetizador.
- **Quem a consome:** Menus interativos, programas de texto, cartilhas de instalação.
- **Status:** Ativo. A base da interface bi-modal do DOSVOX (ver na tela = ouvir).

## `sintEditaCampo`
- **Onde nasceu:** `dvWin.pas` (Camada 1 - Classe A)
- **O que faz:** Função complexa que desenha uma caixa de input na tela, lê os caracteres digitados com eco sonoro (fala a letra ao bater), permite apagar (fala "apagou X"), e retorna a string quando o usuário aperta Enter.
- **Quem a consome:** Cartavox (para ditar remetente/assunto), Edivox (buscas), utilitários de configuração.
- **Status:** Ativo. A principal abstração para formulários em modo texto.

## `sintSom`
- **Onde nasceu:** `dvWin.pas` (Camada 1 - Classe A) *(encaminha para `dvwav` Classe B)*
- **O que faz:** Reproduz um arquivo `.wav` predeterminado (geralmente da pasta `C:\winvox\som`).
- **Quem a consome:** Jogavox, mensagens de erro do sistema (bips, alertas de colisão).
- **Status:** Ativo. Forma a identidade sonora estrutural (eixo Z de usabilidade).

## `executaProg` (Antigo `executa`)
- **Onde nasceu:** `dvexec.pas` (Camada B)
- **O que faz:** A ponte do mundo. Lança subprocessos nativos do Windows (`WinExec` / `ShellExecute`) com tratamento especial para ocultar as janelas ou capturar a saída padrão (Stdout), e espera eles voltarem.
- **Quem a consome:** Fósseis Win32, Cartavox (chamando o `blat` de e-mail), menus encadeados (`dosvox.exe` chamando `edivox.exe`).
- **Status:** Ativo e crucial. É o "loader" do ecossistema. Permite que o DOSVOX seja um aglomerado de executáveis isolados, no lugar de um monólito gigantesco em RAM.
