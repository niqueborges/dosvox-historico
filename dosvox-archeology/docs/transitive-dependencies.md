# Fecho Transitivo e o "Kernel 77"

O mapeamento de frequência das dependências (C.2.2) apontou que as aplicações do DOSVOX compartilham uma base de código altíssimamente coesa. O fecho transitivo das dependências revela um núcleo emergente, que chamamos provisoriamente de "Kernel 77".

## O Núcleo Arquitetural Empírico

Com base no Sandbox de Curadoria, o verdadeiro core (o núcleo do qual quase todas as aplicações dependem para existir no paradigma DOSVOX) é formado pelas seguintes units:

1. **`dvcrt`**: A espinha dorsal procedural. Substitui a biblioteca `crt` do Turbo Pascal por uma abstração Win32. Presente em **100%** das aplicações mapeadas (exceção honrosa ao PPTVOX que a inclui por compatibilidade, não como tela principal).
2. **`dvwin`**: O ecossistema em si (inicialização, ambiente, acessibilidade). Presente em **100%** das aplicações. É aqui que moram as funções de interligação (`sintAmbiente`, caminhos, teclado).
3. **`dvform`**: A ponte gráfica. Usada em **66%** da Amostra (6 em 9), serve para conectar o mundo puramente textual com painéis de configuração visual do Windows.
4. **`dvwav` / `dvexec` / `dvhora` / `dvarq`**: As bibliotecas satélites essenciais. Quase todas as aplicações tocam som (`dvwav`), manipulam diretórios e arquivos texto (`dvarq`) e executam subprocessos (`dvexec`).

### Expansão do Fecho Transitivo

O próximo passo empírico (C.3) será isolar as units acima em `dosvox-core/` e verificar quais units do Delphi (e outras de baixo nível, como `dvtradut` ou `dvsapi4`) elas mesmas incluem, formando a Árvore de Dependências Completa.

**Mistuvox** → Depende de `dvwin`.
↳ `dvwin` → Depende de `dvtradut`, `dvcrt`, `windows`...
