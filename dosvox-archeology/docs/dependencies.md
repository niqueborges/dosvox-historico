# Arquitetura de Dependências

O estudo das dependências entre os módulos do DOSVOX provou que o sistema opera como um ecossistema rigorosamente estratificado, e não como um aglomerado desordenado ("spaghetti code"). 

## Estratificação (As Camadas do DOSVOX)

A compilação experimental validou a existência de **5 Camadas (C0 a C4)** de dependência estrita:
- **Camada 0 (Física):** SO, APIs do Windows, RTL/VCL do Delphi, COM/OLE.
- **Camada 1 (Motores Base):** Wrappers que encapsulam recursos como voz, registro, e rede (ex: `dvtradut`, `dvsapi4`, `dvsapi5`).
- **Camada 2 (O Kernel 77):** A API limpa que orquestra tudo. Units centrais de altíssima frequência (ex: `dvcrt`, `dvwin`, `dvform`).
- **Camada 3 (Aplicações Core):** Editores e jogos essenciais de acoplamento limpo.
- **Camada 4 (Aplicações de Borda):** Ferramentas que "furam" as camadas e se comunicam diretamente com a C0/C1 (ex: `PPTVOX`, `Webvox`).

## Testes de Resiliência (O Método Knockout)

Em vez de verificar apenas as dependências diretas (`uses`), a arqueologia conduziu o **Teste Knockout (KO)**: apagando unidades críticas e observando as falhas sistêmicas geradas.
- Constatou-se que a exclusão da `dvcrt` ou `dvwin` colapsa todo o ecossistema (prova absoluta de acoplamento arquitetural central).
- Provou-se que módulos sonoros (`dvwav`) ou temporais (`dvhora`), embora muito populares, não impedem a compilação do núcleo e de utilitários ancestrais (revelando resiliência interna).

## Cadernos de Pesquisa (Research Notes)

Os grafos pormenorizados, cálculos de frequência e as tabelas com os resultados das compilações estão preservados no diretório `research/`. Para aprofundamento, consulte:

- [Camadas de Dependência (Layers)](../research/dependency-layers.md)
- [Relatório do Teste de Destruição (Knockout)](../research/dependency-knockout.md)
- [Frequência e Centralidade de Units](../research/dependency-frequency.md)
- [Dependências Diretas (Por Aplicação)](../research/direct-dependencies.md)
- [Dependências Transitivas](../research/transitive-dependencies.md)
- [O Grafo Central](../research/dependency-graph.md)
