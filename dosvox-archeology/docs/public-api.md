# A API Pública do DOSVOX (O SDK de Acessibilidade)

A genialidade arquitetural do DOSVOX não reside na complexidade do código, mas na sua simplicidade intencional. O sistema ofereceu a programadores (frequentemente com deficiência visual) uma "máquina virtual" ou SDK conceitual estável por décadas. 

Os desenvolvedores pensavam de forma procedural e linear: *"faça uma coisa; espere uma tecla; faça outra coisa; toque um som"*.
Conceitos modernos (janela, evento, thread, callback) foram deliberadamente escondidos no "Kernel" (`dvcrt`, `dvwin`).

## O Dicionário de Verbos (Contrato de Interface)

Ao longo das décadas, o DOSVOX consolidou este pequeno conjunto de verbos que serviam como contrato entre a aplicação e o sistema operacional subjacente:

### Inicialização e Encerramento
- `sintInic`: Inicializa o mecanismo de síntese de voz e a emulação da janela de texto.
- `sintFim`: Finaliza a síntese de voz.
- `doneWinCrt`: Destrói a janela gráfica de emulação de texto.

### Saída (Voz e Tela)
- `sintetiza('texto')`: Envia a string exclusivamente para o motor de voz (SAPI/Liane), sem imprimir na tela.
- `sintWrite('texto')` / `sintWriteln('texto')`: Imprime o texto na tela (virtual CRT) e, simultaneamente, o envia para a voz.
- `sintSom('nomeArquivo')`: Dispara a execução de um áudio (wav/mp3) encapsulando chamadas ao `mmSystem` ou `dvWav`.
- `sintBip`: Emite o beep de alerta padrão.

### Entrada e Interação (Teclado)
- `readkey`: Pausa a execução bloqueando a thread até o usuário pressionar uma tecla (herança direta do Turbo Pascal).
- `keypressed`: Verifica se há algo no buffer de teclado sem bloquear a execução.
- `sintEditaCampo(...)`: O ápice da acessibilidade. Encapsula todo o comportamento de edição de texto (navegação com setas, backspace, soletrar letras em voz alta enquanto digita) retornando apenas a string final para o programador.
- `waitMessage`: Mantém a janela ativa e a voz falando (processa a fila de mensagens do Windows) sem avançar a lógica da aplicação.
- `sintFalando`: Função booleana que avisa se o motor de voz (SAPI/Liane) ainda está processando áudio. Essencial para sincronizar a fala com a execução.

### Um Paradigma Estável
A maior conquista deste contrato é que, respondendo à pergunta histórica: *Um desenvolvedor cego em 1994 conseguiria reconhecer e programar uma aplicação DOSVOX em 2026?*
**Sim, praticamente sem reaprender a API.** A estabilidade desse contrato de interface é a verdadeira razão pela qual a migração do DOS para Windows não destruiu o ecossistema.
