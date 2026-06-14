# DOSVOX Curation Log

Este diário registra as decisões de curadoria durante a arqueologia e engenharia reversa do DOSVOX. O objetivo é preservar o raciocínio por trás de cada classificação, visto que os diretórios experimentais (`dosvox-apps`, `dosvox-core`) são ambientes temporários de testes.

## Entradas

### 13/06/2026

**Artefato:** `edivox` (Edivox)
- **Motivo da Inclusão:** Representante primário da interface de edição de texto do usuário final.
- **Valor Principal:** Operacional.
- **Evidências:** Presente nas três distribuições (Completo, Reduzido, Mini). Uso ubíquo em manuais e referências.
- **Status:** Experimental.

**Artefato:** `webvox` (Webvox)
- **Motivo da Inclusão:** Representante primário da navegação web nativa.
- **Valor Principal:** Operacional / Arquitetural.
- **Evidências:** Presente no Mini. Possui forte dependência das bibliotecas do núcleo (possivelmente synapse ou sockets).
- **Status:** Experimental.

**Artefato:** `cartavox` (Cartavox)
- **Motivo da Inclusão:** Representante de comunicação externa (e-mail).
- **Valor Principal:** Operacional.
- **Evidências:** Presente no Mini. Comunicação via internet acoplada ao paradigma de interface VOS.
- **Status:** Experimental.

**Artefato:** `forcavox` (Forcavox)
- **Motivo da Inclusão:** Escolhido pelos mantenedores originais para compor a distribuição mínima (Mini).
- **Valor Principal:** Operacional (Engajamento mínimo/Treinamento).
- **Evidências:** Um jogo que sobreviveu à restrição extrema de peso no instalador Mini, servindo possivelmente para introduzir o uso do teclado.
- **Status:** Experimental.

**Artefato:** `sudovox` (Sudovox)
- **Motivo da Inclusão:** Presente no Mini, reforçando o padrão de preservação de lógica lúdica no núcleo mínimo.
- **Valor Principal:** Operacional.
- **Evidências:** Instalado pelo `dv63-mini-setup.exe`.
- **Status:** Experimental.

**Artefato:** `mistuvox` (Mistuvox)
- **Motivo da Inclusão:** Remanescente valioso da primeira geração de arquitetura.
- **Valor Principal:** Histórico.
- **Evidências:** Possui arquivos de texto que o datam em 1994, antes mesmo do Windows se tornar dominante. Ausente no Mini.
- **Status:** Experimental.

**Artefato:** `pptvox` (PPTVOX)
- **Motivo da Inclusão:** Contraexemplo arquitetural.
- **Valor Principal:** Arquitetural (Excepcional).
- **Evidências:** Integra-se com MS PowerPoint, utilizando OLE/COM e VCL visual (Delphi), contrastando com a norma procedural/textual predominante.
- **Status:** Experimental.

**Artefato:** `DOSDOS.PAS` e `DOSED.PAS`
- **Motivo da Inclusão:** Fósseis tecnológicos.
- **Valor Principal:** Histórico.
- **Evidências:** Artefatos que evidenciam a transição geracional entre a arquitetura legada (MS-DOS) e a arquitetura Win32.
- **Status:** Experimental.
