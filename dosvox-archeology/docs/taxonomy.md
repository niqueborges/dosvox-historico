# Taxonomia do Ecossistema DOSVOX

Para catalogar os milhares de arquivos e dezenas de módulos do DOSVOX, a arqueologia utilizou um método analítico baseado em três dimensões de valor e testes práticos de distribuição.

## As Três Dimensões de Valor

Um módulo ou arquivo fonte do DOSVOX não é julgado de forma binária ("útil" ou "inútil"). O projeto o classifica em três eixos independentes:
1. **Valor Histórico:** Preserva paradigmas do passado e demonstra a evolução do sistema (Ex: Fósseis como o `DOSDOS.PAS` ou jogos ancestrais como `Mistuvox`).
2. **Valor Arquitetural:** Mede o quão central o componente é para a estrutura do software. Se removido, o ecossistema quebra (Ex: O Kernel 77, `dvcrt`, `PPTVOX` por limites de integração).
3. **Valor Operacional:** Representa a utilidade prática final para um usuário cego moderno no seu dia-a-dia.

## A Taxonomia Guiada por Distro (Métricas de Instalação)

Uma das metodologias usadas foi o cruzamento (teoria dos conjuntos) das distribuições oficiais (`Completo`, `Reduzido`, `Mini`) para extrair os módulos de ouro:
- **Núcleo Operacional Mínimo:** A intersecção estrita (`Completo ∩ Mini`). Arquivos que são absolutamente vitais para boot e acesso à interface.
- **Conteúdo Opcional:** O diferencial (`Completo - Mini`). Jogos adicionais, módulos periféricos.
- **Zona Cinzenta:** Módulos que sobrevivem à poda moderada, mas são cortados na versão Mini (`Reduzido - Mini`).

## Cadernos de Pesquisa (Research Notes)

Os cadernos detalhados que originaram essa taxonomia e documentam os resultados das experiências empíricas podem ser consultados no diretório `research/`:

- [Classificação Individual dos Artefatos](../research/classification.md)
- [Matriz de Confiança Taxonômica](../research/taxonomic-confidence.md)
- [Análise Conjuntista de Instaladores (Metrics)](../research/taxonomy-metrics.md)
- [Aprofundamento nas Dimensões de Valor](../research/value-dimensions.md)
- Listas cruas de dados: [Completo-Mini](../research/complete-minus-mini.md), [Reduzido-Mini](../research/reduzido-minus-mini.md), [Intersecção Mínima](../research/complete-intersection-mini.md).
