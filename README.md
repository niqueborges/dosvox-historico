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

Abaixo estão os principais documentos gerados pela pesquisa, organizados por categoria:

- **Documentação Geral (`docs/`):**
  - [Linha do Tempo](file:///e:/Dev/projetos/dosvox-historico/docs/timeline.md) - Cronologia detalhada do projeto, reunindo marcos históricos do site oficial e evidências técnicas.
  - [Arquitetura Comprovada](file:///e:/Dev/projetos/dosvox-historico/docs/arquitetura.md) - Estudo consolidado sobre o ecossistema, modularidade e bibliotecas compartilhadas do DOSVOX.
  - [Mapeamento de Módulos](file:///e:/Dev/projetos/dosvox-historico/docs/projetos.md) - Inventário e categorização de todas as aplicações e executáveis do ecossistema.
  - [Autores e Colaboradores](file:///e:/Dev/projetos/dosvox-historico/docs/autores.md) - Mapeamento da equipe de desenvolvimento do núcleo e evoluções.

- **Fontes de Informação (`fontes/`):**
  - [Mapa do Portal DOSVOX](file:///e:/Dev/projetos/dosvox-historico/fontes/mapa-portal-dosvox.md) - Inventário completo e estruturado das páginas internas do site oficial.

- **Pesquisas e Análises (`pesquisas/`):**
  - [Análise da Instalação do Winvox](file:///e:/Dev/projetos/dosvox-historico/pesquisas/analise-instalacao-winvox.md) - Raio-X técnico de uma instalação real do sistema e suas dependências.
  - [Análise de Preservação Digital](file:///e:/Dev/projetos/dosvox-historico/pesquisas/analise-preservacao-digital.md) - Priorização e triagem das páginas do portal oficial para fins de conservação digital.
  - **Motor Principal (`pesquisas/motor-principal/`)**: Pasta dedicada ao estudo profundo da espinha dorsal do DOSVOX. Destaque para a [Análise Técnica do DvCrt](file:///e:/Dev/projetos/dosvox-historico/pesquisas/motor-principal/analise-dvcrt.md) e o [Guia de Preservação do DOSVOX](file:///e:/Dev/projetos/dosvox-historico/pesquisas/motor-principal/guia-preservacao.md).
  - **Registros (`pesquisas/registros/`)**: Registros de investigações brutas sobre a pasta local de instalação.

## Utilitários

- **[Builder de Contexto](file:///e:/Dev/projetos/dosvox-historico/context_builder.py)**: Script em Python que compila todo o conhecimento destas pastas num único arquivo Markdown (`context.md`) para alimentar rapidamente o contexto de qualquer Inteligência Artificial.

## Status

Pesquisa ativa e em franca documentação. Para acompanhar o progresso mais detalhado e os próximos passos, consulte o arquivo [STATUS_DO_PROJETO.md](file:///e:/Dev/projetos/dosvox-historico/STATUS_DO_PROJETO.md).