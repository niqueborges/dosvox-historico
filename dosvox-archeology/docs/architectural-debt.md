# Oportunidades de Refatoração e Dívida Arquitetural

Este documento acompanha a **Topologia Desejável** do DOSVOX, contraposta à *Topologia Observada* na Fase C.3 e C.4.
Os itens descritos aqui não são classificados como "erros da época" ou "más decisões", mas sim como **Acoplamentos Históricos**. Eles representam a sedimentação natural de componentes que chegaram depois e acabaram se cristalizando no núcleo duro do sistema.

A prioridade de todas as dívidas aqui registradas é **Baixa**, pois o sistema é mantido estável e funcional há décadas. A correção destas dívidas beneficiaria a arquitetura, mas não é crítica para a operação.

---

## AD-001: Acoplamento de `dvcrt` com `dvmouse`

**Evidência:** 
A biblioteca `dvcrt` importa a `dvmouse`. O teste empírico (Knockout) da remoção de `dvmouse` causou a falha de compilação em 100% da Amostra de Ouro (de Edivox a PPTVOX), englobando até programas não interativos ou matemáticos.

**Impacto:** 
Uma biblioteca especializada de interface de apontador (Classe C) tornou-se, por acoplamento, uma dependência existencial obrigatória (Classe A). 

**Arquitetura Desejável:**
Isolar a captura do mouse num hook externo, invertendo a dependência.
```text
dvcrt
 ├── teclado
 ├── tela
 └── hook opcional
        ↓
     dvmouse
```

**Justificativa Histórica (Sedimentação):**
A interceptação de rolagem de tela (`wm_MouseWheel`) provavelmente foi adicionada anos após o `dvcrt` nascer, numa época em que o Windows exigia tratar essa mensagem globalmente na janela procedural, sedimentando a `dvmouse` na base.

---

## AD-002: Interfaces SAPI e Multimídia no Núcleo 

**Evidência:**
Dependências como `videovox` e bibliotecas `dvsapi5`, `speechLib_TLB` estão presentes na cascata recursiva do motor base (via `dvwin` e `dvsapglb`).

**Impacto:**
Componentes que poderiam ser *plugins* sob demanda são carregados na matriz de resolução primária de dependências.

**Arquitetura Desejável:**
Uma arquitetura onde serviços de mídia e TTS rodem como injeção de dependência na inicialização, mantendo o `dvwin` ignorante da implementação subjacente SAPI.
