# DOSVOX Histórico

Pesquisa independente sobre a arquitetura, história e evolução do DOSVOX, sistema brasileiro de acessibilidade desenvolvido na UFRJ.

## Objetivos

- Preservar informações técnicas sobre o DOSVOX
- Documentar sua arquitetura
- Mapear os módulos existentes
- Registrar a evolução histórica do projeto
- Produzir documentação acessível para desenvolvedores

## Fontes principais

- Portal DOSVOX (https://intervox.nce.ufrj.br/dosvox/)
- Código-fonte
- Publicações acadêmicas
- Entrevistas e vídeos
- Documentação recuperada

## Primeiros achados

Data da análise: junho de 2026

### Código-fonte

- Linguagem principal: Delphi / Object Pascal
- Arquivos-fonte identificados: 1021
- Linhas de código identificadas: 377013

### Evidências de manutenção recente

Arquivos encontrados com modificações em 2024 e 2025.

### Estrutura observada

O DOSVOX é composto por dezenas de aplicações integradas, incluindo editor de textos, navegador, leitor de EPUB, rádio, ferramentas de comunicação e recursos de acessibilidade.

## Estrutura do Projeto

A escavação consolidou-se em uma arquitetura limpa de diretórios e em um **Knowledge Graph de 6 Dimensões**.

### As Camadas do Repositório:
- `dosvox-history/` (Espelho bruto e inalterado)
- `dosvox-core/` (Infraestrutura principal, o framework)
- `dosvox-shell/` (Orquestração e menu do sistema)
- `dosvox-apps/` (Aplicações independentes)
- `dosvox-thirdparty/` (Ferramentas externas encapsuladas)
- `sources/` (Materiais brutos, manuais, entrevistas, instaladores)
- `dosvox-archeology/` (A camada documental: narrativas, lições, matrizes e evidências)

### Pastas Antigas (Congeladas)
> O material das pastas legadas abaixo migrou para `dosvox-archeology/` e `sources/`. Elas foram mantidas temporariamente por fidelidade aos commits antigos:
- `docs/` (Congelada)
- `fontes/` (Congelada)
- `pesquisas/` (Congelada)

## O DOSVOX Memory OS

O repositório é indexado por um compilador rigoroso de contexto (`tools/knowledge_compiler.py`) que constrói o `context/` — um verdadeiro Sistema Operacional de Memória mapeando as 6 dimensões da arqueologia:

1. **Espaço** (`catalogs`, `topics`, `concepts`): O que é, onde está e o que significa.
2. **Relações** (`graph-links`, `graph-semantic`): As pontes textuais e abstratas.
3. **Procedimentos** (`personas`, `recipes`, `playbooks`): Como investigar falhas, ler código ou navegar no repositório assumindo posturas intelectuais (Debugger, Architect).
4. **Tempo** (`events/`): O eixo cronológico (logs de fases da expedição e descobertas).
5. **Incerteza** (`questions/`): A manutenção explícita do não-saber. Questões não respondidas, preservadas com grau de confiança, evitando que hipóteses provisórias virem dogmas no futuro.
6. **Proveniência**: A dimensão oculta que sustenta todo o sistema (evidências, matrizes de dependência e testes destrutivos como o *knockout* que garantem a autenticidade das respostas acima).

## Status

A reconstrução do meta-conhecimento foi estabilizada. O legado técnico e intelectual das décadas passadas agora respira na arquitetura do futuro.
Para informações históricas dos módulos, confira o [STATUS_DO_PROJETO.md](file:///e:/Dev/projetos/dosvox-historico/STATUS_DO_PROJETO.md).

## Proveniência da Arquitetura

As estruturas de preservação descritas neste repositório não foram concebidas por uma única entidade.

Entre 2026 e as fases finais da escavação, as hipóteses, modelos e refinamentos que culminaram no DOSVOX Memory OS emergiram de um processo iterativo de diálogo entre três participantes:

- o pesquisador humano responsável pelo projeto;
- o ChatGPT, utilizado como parceiro de raciocínio, crítica e revisão;
- o Antigravity, utilizado como ambiente complementar de experimentação arquitetural.

As ideias foram continuamente submetidas a questionamento, reformulação e validação empírica. Nenhuma decisão importante foi atribuída a uma única fonte.

Este registro é preservado deliberadamente como parte da história intelectual do projeto, da mesma forma que se preservam autores, versões e evidências do próprio ecossistema DOSVOX.

Assim como a arqueologia do DOSVOX busca preservar a memória técnica das gerações anteriores, este documento preserva também as circunstâncias e os interlocutores que participaram da reconstrução desse conhecimento.
