# DOSVOX 6.3 - Análise Conjuntista de Instaladores

Esta análise foi conduzida extraindo os instaladores oficiais da versão 6.3 de forma isolada e calculando as interseções e diferenças entre as distribuições. O objetivo é deduzir a taxonomia arquitetural baseada nas escolhas de empacotamento dos mantenedores.

## Métricas de Distribuição

- **Completo**: Instalação padrão.
- **Reduzido**: Versão com mídias e opcionais removidos.
- **Mini**: Versão estritamente essencial.

### Resultados da Extração

1. **Núcleo Operacional Mínimo** (`Completo ∩ Mini`)
   - **Total de arquivos:** 5.442
   - **Interpretação:** Este é o conjunto de arquivos que os mantenedores julgaram absolutamente necessários para uma instalação viável. Define o escopo do que pode ser considerado o "Core" do sistema e o ecossistema base inseparável.
   - **Inventário:** [complete-intersection-mini.md](file:///e:/Dev/projetos/dosvox-historico/dosvox-archeology/docs/complete-intersection-mini.md)

2. **Conteúdo Opcional** (`Completo - Mini`)
   - **Total de arquivos:** 7.652
   - **Interpretação:** Mídias, jogos adicionais, manuais extensos e vozes complementares. Pode ser removido sem inviabilizar o uso cotidiano.
   - **Inventário:** [complete-minus-mini.md](file:///e:/Dev/projetos/dosvox-historico/dosvox-archeology/docs/complete-minus-mini.md)

3. **Zona Cinzenta** (`Reduzido - Mini`)
   - **Total de arquivos:** 7.351
   - **Interpretação:** Conjunto de aplicações que sobrevivem a um corte primário (reduzido) mas são ejetadas quando a restrição de tamanho é extrema (mini). Oferece forte indício sobre o que é utilitário vs o que é periférico.
   - **Inventário:** [reduzido-minus-mini.md](file:///e:/Dev/projetos/dosvox-historico/dosvox-archeology/docs/reduzido-minus-mini.md)

## Próximos Passos (Fase C)
Com as listas extraídas, podemos agora realizar a amostragem de ouro (`Amostra de Ouro`) para aplicações clássicas, movendo o código-fonte que corresponde apenas a essas áreas prioritárias e estabelecendo o `dosvox-core`.
