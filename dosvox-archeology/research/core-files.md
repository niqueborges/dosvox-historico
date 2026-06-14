# Inventário do Core (O "Kernel" do DOSVOX)

Este catálogo documenta as units vitais que compõem a infraestrutura base do sistema. Elas residem originariamente em `C:\winvox\Fontes\tradutor` e serão o alicerce da pasta `dosvox-core`.

---

## `dvtradut.pas`
- **Geração:** G0 (1987 / 1994)
- **Papel:** Motor fonético original (Tradução texto-fala baseada em regras e exceções para o português).
- **Dependências:** Nenhuma.
- **Status:** Ativo.
- **Evidência:** Cabeçalho do arquivo datado de julho de 1987 ("Sistema Tradutor Fonetico N.R.L.") e adaptado em 1994.

## `dvcrt.pas`
- **Geração:** G2 (1998)
- **Papel:** Camada de compatibilidade. Emulador da tela textual do MS-DOS e adaptador do teclado para o Windows (Virtual CRT).
- **Dependências:** `Windows`, `Messages`, `SysUtils`, `mmSystem`, `minireg`.
- **Status:** Ativo.
- **Evidência:** Cabeçalho afirma: *"Dosvox CRT emulation procedures. Based on the Turbo Pascal Runtime Library Windows CRT Interface Unit. January/1998"*.

## `dvwin.pas`
- **Geração:** G2 (1998)
- **Papel:** O orquestrador de acessibilidade. Detém o "SDK" procedural público do DOSVOX (`sintetiza`, `sintEditaCampo`, `sintSom`). Direciona a síntese textual para os drivers apropriados.
- **Dependências:** `Windows`, `SysUtils`, `dvcrt`, `dvtradut`, `dvsapi`, `dvwav`, `mmsystem`.
- **Status:** Ativo.
- **Evidência:** Funções como `sintetiza()` são usadas até em jogos de 1994 (como `mistuvox`), provando a preservação retroativa da API MS-DOS no Windows.

## `dvform.pas`
- **Geração:** G3 (2001)
- **Papel:** Abstração de menus e formulários de navegação complexa (combobox, listas) sem abandonar o paradigma textual auditivo.
- **Dependências:** `dvwin`, `dvcrt`.
- **Status:** Ativo.
- **Evidência:** Importado pesadamente por utilitários robustos dos anos 2000 como `Webvox` e aplicações de sistema.

## `dvsapi.pas`
- **Geração:** G4 (Anos 2000+)
- **Papel:** Camada de despacho e conexão com os motores de voz da Microsoft (SAPI4, SAPI5). Isola o COM+ do restante da `dvwin`.
- **Dependências:** `dvsapi4`, `dvsapi5`, `dvsapglb`.
- **Status:** Ativo.
- **Evidência:** Existência de sub-arquivos `sapi5.inc` para tratar instâncias de COM Objects (`TSpVoice.Create`).
