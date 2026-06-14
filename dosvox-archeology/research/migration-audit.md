# Migration Audit

Esta é a auditoria que atesta a migração das pastas ancestrais (`docs/`, `fontes/`, `pesquisas/`) para a nova arquitetura do DOSVOX Memory OS (`dosvox-archeology/` e `sources/`).

- **docs/** (Antiga documentação geral) -> O conteúdo histórico e narrativo migrou na totalidade para `dosvox-archeology/docs/` e foi convertido nas dimensões do *Memory OS*.
- **fontes/** (Antiga pasta de cópias de conteúdo, como o mapa do portal) -> O conteúdo bruto foi unificado na pasta oficial `sources/`.
- **pesquisas/** (Antiga pasta de investigações brutas) -> As evidências, laboratórios e análises de dependências migraram para `dosvox-archeology/research/`.

## Status da Migração

- **Migrados**: 100% dos conceitos centrais.
- **Congelados**: As pastas antigas não foram apagadas para preservar links de commits passados, mas receberam a flag de `LEGACY DIRECTORY`.
- **Órfãos**: 0. Nenhuma informação técnica foi perdida.

*Toda nova documentação deve obrigatoriamente integrar a estrutura de `dosvox-archeology`.*
