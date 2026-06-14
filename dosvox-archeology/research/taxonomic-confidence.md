# Matriz de Confiança Taxonômica

Este artefato mede a confiança probabilística (rigidez científica) das deduções arquiteturais feitas durante a pesquisa, em vez de assumir conclusões binárias. Ele separa a evidência observável da teoria.

| Artefato / Estrutura | Confiança | Evidência / Motivo |
| --- | --- | --- |
| **`dvtradut` como fundação (Camada 1)** | **Alta** | Requerido transitivamente por quase todos os módulos centrais; compilação em árvore exige sua presença imediata. |
| **`dvcrt` como ponte (Camada 2)** | **Alta** | Única unit presente em 100% da Amostra de Ouro original. Teste de Knockout prova interrupção existencial de toda aplicação se removida. |
| **Estratificação em 4 Camadas (C0 a C4)** | **Alta** | O grafo gerado pela matriz de compilação exige dependências ordenadas (ex: FPC -> dvwin -> dvcrt -> edivox). |
| **Fósseis como Pontes Win32** | **Alta** | Código-fonte analisado e compilação confirmada contra o `dosvox-core`. Usa `dvExec` explicitamente. |
| **Kernel 77 como entidade coesa** | **Média** | O Fecho Transitivo experimental validou as units principais, mas forçou a descoberta de 14 novas units (Kernel Expandido). Suas fronteiras ainda têm margem fluida. |
| **Fronteira entre `dosvox-core` e `dosvox-thirdparty`** | **Média** | O compilador separou perfeitamente `synafpc` / `speechLib_TLB` das units internas, mas alguns sub-wrappers (`minireg`) habitam zonas cinzentas da arquitetura. |
| **Núcleo Operacional Mínimo** | **Média** | Dedução suportada pelas distribuições Oficiais Mini e Reduzido, pendente teste humano prático para provar usabilidade. |
| **Papel pedagógico de Jogos (Forcavox, Sudovox)** | **Baixa** | Baseado puramente na presença persistente nas instalações mínimas (pesam no instalador, mas resistiram ao corte). Intenção exata dos autores originais ainda é hipótese sociológica. |
| **Classe C (Módulos Especializados)** | **Baixa** | Units como `dvmouse` e `videovox` foram registradas apenas no fechamento transitivo; ainda carecem de Knockout dedicado a programas que as requeiram ativamente. |
