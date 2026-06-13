# Árvore Genealógica das Units (Grafo de Dependências)

*(Documento em construção)*

A investigação no código-fonte revela que o "Kernel 77" (o framework do DOSVOX) não é uma *Big Ball of Mud*, mas sim um sistema incrivelmente bem estratificado e sem ciclos de dependência em seu núcleo principal. O crescimento se deu em camadas limpas (sedimentação).

## O Grafo Vertical Fundamental

A cadeia de dependência flui perfeitamente de baixo para cima, sem retornos (sem dependências circulares):

```text
dvtradut (O tradutor fonético de 1987. A unit mais antiga. Não depende de ninguém.)
   │
   ▼
dvcrt (Lida com a janela do terminal de texto e som bruto)
   │
   ▼
dvwin (O orquestrador criado em 1998. Depende de `dvcrt` e `dvtradut`. Lida com SAPI e integrações de alto nível)
   │
   ▼
dvform (Criada em 2001. Depende de `dvwin`. Cria formulários acessíveis e menus)
   │
   ▼
Aplicações (Consomem `dvwin` e `dvform`)
```

## O que isso prova?

1. **Ausência de Ciclos:** `dvwin` NÃO usa `dvform`. `dvform` usa `dvwin`. Isso é uma prova de maturidade arquitetural (ou pelo menos de uma excelente higiene de código ao longo do tempo).
2. **Crescimento por Sedimentação:** O DOSVOX não foi "reescrito" a cada década. Ele foi empilhado. Quando surgiu a necessidade de formulários visuais acessíveis (2001), não se alterou a `dvwin` para fazer isso; criou-se a `dvform` no topo dela.
3. **O Fóssil de Nomenclatura:** Por isso a pasta se chama `tradutor`. Em 1994, o sistema inteiro girava em torno do `dvtradut.pas`. A pasta apenas manteve seu nome enquanto o mundo moderno (`dvwin`, internet, etc.) crescia ao redor dela.
