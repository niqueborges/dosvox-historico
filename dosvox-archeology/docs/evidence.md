# Metodologia Arqueológica e Consolidação de Evidências

A pesquisa no código-fonte do DOSVOX adota uma separação científica rigorosa para evitar interpretações precipitadas. Qualquer afirmação técnica sobre a arquitetura e história do sistema deve ser classificada em um dos três níveis:

1. **Evidência:** O fato cru e observável diretamente no código (arquivos, diretivas, imports, logs, datas de cabeçalho).
2. **Inferência:** A conclusão técnica imediata tirada da evidência. O que o código faz, sem necessariamente explicar a motivação histórica.
3. **Hipótese Histórica:** A suposição sobre a intenção dos autores ou a evolução de engenharia do sistema, que explica o "porquê" as coisas são como são.

---

## 1. O Fóssil Fundador (`dvtradut.pas`)

**Evidência:** 
O arquivo `C:\winvox\Fontes\tradutor\dvtradut.pas` possui um cabeçalho datado de "Julho de 1987 / Aprovado: Dez/1987" e indica ser um Trabalho de Fim de Curso sobre "Sistema Tradutor Fonetico N.R.L.". Não possui dependências com nenhuma outra unit do projeto (apenas processa strings baseadas em `MAX_EXCESSOES` e listas encadeadas de regras).

**Inferência:** 
O motor fonético é isolado, autosuficiente e construído antes de qualquer integração visual ou de sistema operacional moderno.

**Hipótese Histórica:** 
O DOSVOX não nasceu como um leitor de telas, mas sim de uma pesquisa acadêmica focada exclusivamente em Processamento de Linguagem Natural (NLP) e regras de síntese de voz para o português do Brasil. O sistema foi construído "ao redor" desse motor anos depois.

---

## 2. A Camada de Compatibilidade (`dvcrt.pas`)

**Evidência:** 
O cabeçalho de `dvcrt.pas` diz explicitamente *"Dosvox CRT emulation procedures. Based on the Turbo Pascal Runtime Library Windows CRT Interface Unit. January/1998"*. Em seu interior existem emulações idênticas da API antiga (`GotoXY`, `ClrScr`, matriz virtual `80x25`). Jogos antigos (como `mistuvox.dpr` de 1994) chamam essas funções (`clrscr`, `textBackground`) e importam a `dvcrt`, sem fazer chamadas diretas ao `Windows.pas` para gerenciar a GUI.

**Inferência:** 
A biblioteca intercepta os comandos destinados ao hardware (vídeo e teclado do MS-DOS) e os traduz para chamadas Win32, desenhando uma janela virtual no Windows enquanto preserva a interface procedural antiga para o chamador.

**Hipótese Histórica:** 
A transição dramática do MS-DOS para o Windows em 1998 não foi resolvida reescrevendo-se as aplicações, mas sim implementando o que hoje chamaríamos de *Adapter Pattern* na camada do interpretador (a Crt). Essa decisão genial salvou o ecossistema e cristalizou a API.

---

## 3. Os Dois Ecossistemas Coexistentes (A Quebra da Linearidade)

**Hipótese em teste:** 
A migração DOS → Windows foi absorvida unicamente pela camada de abstração procedural (`dvcrt` + `dvwin`).

**Evidência:** 
A maioria esmagadora de programas antigos (`mistuvox`, `colossal`, `minied`, `intervox`) sobrevive perfeitamente sem chamadas explícitas a `CreateWindow` ou `DispatchMessage`. 
**CONTRAEXEMPLOS:** Foram encontrados módulos que utilizam recursos visuais nativos do Delphi (`.dfm`):
- `PPTVOX` (~2002)
- `DICIO` (~2002)
- `sapi4cnf` (~2010)
- `gravadosvox` (~2016)

**Inferência:** 
A arquitetura textual do DOSVOX não foi universal em todas as épocas. Ela permaneceu dominante no ecossistema principal, mas determinados módulos especializados recorreram à VCL padrão do Delphi quando precisaram interagir fortemente com COM/Office, multimídia ou configurações de drivers. O projeto engloba **dois paradigmas coexistentes**:
- **Ecossistema A (Paradigma DOSVOX):** Linear, sem laço de eventos, abstraído por `dvcrt -> dvwin`. Foco total na experiência tátil/sonora cega.
- **Ecossistema B (Paradigma Delphi/VCL):** Orientado a eventos, formulários nativos do Windows. Usado pontualmente para integrações pesadas.

**Hipótese Revisada:** 
A interface textual emulada pela `dvcrt` foi o paradigma fundador e predominante do DOSVOX, mantendo 90% dos aplicativos vivos, mas não foi dogmática; a partir dos anos 2000, os autores não hesitaram em usar ferramentas RAD (VCL) quando o limite procedural se tornou um obstáculo para integrações modernas de SO.

---

## 4. O Grafo de Dependências Estrito (Sedimentação)

**Evidência:** 
A análise das cláusulas `uses` dos módulos centrais revela:
`dvtradut` não importa nada.
`dvcrt` usa bibliotecas do Windows.
`dvwin` usa `dvcrt` e `dvtradut`.
`dvform` usa `dvwin` e `dvcrt`.
Nenhuma unit das camadas superiores é importada pelas camadas inferiores.

**Inferência:** 
O núcleo do sistema ("Kernel 77") possui uma arquitetura de dependências puramente vertical. Não há ciclos (importação mútua).

**Hipótese Histórica:** 
O sistema evoluiu predominantemente por **sedimentação**, empilhando novas camadas de abstração (`dvwin` em 1998, `dvform` em 2001) para resolver problemas novos (interfaces no Windows, menus complexos) sem reescrever ou destruir as fundações prévias (o algoritmo de 1987). Isso explica como código de 30 anos atrás ainda compila no mesmo projeto em 2026.
