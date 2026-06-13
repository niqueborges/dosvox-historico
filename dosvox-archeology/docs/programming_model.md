# Como se escrevia software para o DOSVOX (A API Pública)

O objetivo deste documento é responder à pergunta: **"Como um programador do DOSVOX escrevia um aplicativo?"**

Ao analisarmos o código-fonte de aplicações reais do DOSVOX (como o `timervox`), percebemos que o programador praticamente não lidava com as complexidades do Windows (WinAPI), SAPI ou DirectX. O ecossistema expunha o que podemos chamar de um **SDK de Acessibilidade** procedural, extremamente simples e focado.

## A "Receita de Bolo" (Ciclo de Vida)

Quase todo programa do DOSVOX segue este esqueleto implícito (template):

1. `sintInic(...)` (Inicializa o motor de voz e a tela dvcrt)
2. `sintetiza('Titulo')` (Fala o que o programa é)
3. Laço principal (Menu, captura de teclas)
4. `sintFim` / `doneWinCrt` (Encerra o acesso e a janela)

## O "Hello World" do DOSVOX

O menor programa acessível possível (se fôssemos escrevê-lo) seria algo assim:

```pascal
program HelloWorld;

uses 
  dvcrt, dvwin;

begin
  sintInic(0, '');
  sintetiza('Olá Mundo');
  sintWrite('Pressione qualquer tecla para sair');
  readkey;
  sintFim;
  doneWinCrt;
end.
```

## A API Pública (Dicionário de Ações)

Aqui estão as equivalências reais das funções mais utilizadas pelos programadores do ecossistema:

- **Falar um texto (sem imprimir na tela):** `sintetiza('texto');`
- **Imprimir na tela E Falar (híbrido):** `sintWriteln('texto');`
- **Esperar uma tecla:** `c := readkey;`
- **Checar se apertou tecla:** `if keypressed then ...`
- **Perguntar um texto ao usuário:** `sintEditaCampo(s, x, y, tamanho, max, true);` (Ele já cuida de falar cada letra enquanto o usuário digita!)
- **Saber se o sintetizador ainda está falando:** `while sintFalando do waitMessage;`
- **Executar outro programa do ecossistema:** `executaProg(nomeProg, parametros, ...) ;`
- **Emitir um bipe:** `sintBip;`
- **Limpar lixo de teclado:** `limpaBufTec;`

## O Valor Histórico Dessa Arquitetura

Para um desenvolvedor em 1998 ou 2005, criar um jogo acessível exigiria milhares de linhas para lidar com threads de áudio e interceptação de teclado. 

No modelo do DOSVOX, o programador só pensava em fluxos procedurais (`Escreve -> Fala -> Espera Tecla`). A abstração do "Kernel 77" (`dvwin`, `dvcrt`) encapsulava toda a complexidade, permitindo que estudantes e pesquisadores criassem dezenas de ferramentas acessíveis rapidamente. O DOSVOX funcionava, na prática, como uma Linguagem de Programação / Motor de Jogos focado exclusivamente no usuário cego.
