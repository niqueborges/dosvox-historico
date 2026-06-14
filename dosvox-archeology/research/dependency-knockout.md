# Relatório de Teste de Destruição (Knockout)

Em vez de verificar o que compila com a presença, testamos o que falha com a ausência. Este experimento mede a resiliência do ecossistema e revela se os módulos estão acoplados por necessidade ou por acidente estrutural.

*Ambiente:* `dosvox-core-knockout/`

## KO-001: Remoção de `dvcrt` (Classe A)
**Hipótese:** Tudo deve parar de funcionar.
**Resultado:**
- **Todas as Aplicações (Edivox a PPTVOX):** Não compila.
**Conclusão:** `dvcrt` é o oxigênio do sistema. O acoplamento é forte, justificado e absoluto.

## KO-002: Remoção de `dvwav` (Classe B)
**Hipótese:** Aplicações de mídia falham, utilitários lógicos sobrevivem.
**Resultado:**
- Edivox, Webvox, Cartavox, Mistuvox, PPTVOX: Não compila (dependem de som guiado estruturalmente).
- Forcavox, Sudovox, Baronvox, Fósseis: **Sem efeito (Compilam perfeitamente).**
**Conclusão:** Unidades B não bloqueiam todo o Kernel 77. Elas são módulos opcionais que atendem à maioria, mas não a totalidade. Os jogos remanescentes e os fósseis provaram independência de som em seu *core lógico*.

## KO-003: Remoção de `dvhora` (Classe B)
**Hipótese:** Aplicações que precisam de tempo explodem.
**Resultado:**
- Edivox, Webvox, Cartavox, Sudovox, PPTVOX: Não compila.
- Forcavox, Mistuvox, Baronvox, Fósseis: **Sem efeito (Compilam perfeitamente).**
**Conclusão:** `dvhora` é amplamente usado, mas Forcavox e Baronvox provam que a temporalidade não é obrigatória para a arquitetura DOSVOX funcionar.

## KO-004: Remoção de `dvmouse` (Classe C)
**Hipótese:** Ninguém deve perceber, exceto programas específicos que exijam o clique de mouse acessível.
**Resultado Esperado:** Sem efeito na grande maioria.
**Resultado Real:** **FALHA TOTAL (Todas as Aplicações Não Compilam).**
**Análise da Surpresa (Por que Falhou?):**
Investigamos a árvore e descobrimos que `dvcrt.pas` possui a cláusula explícita `uses ..., dvMouse;` em seu Implementation. O `dvcrt` intercepta a mensagem `wm_MouseWheel`.
**Conclusão:** O DOSVOX tem um problema arquitetural de acoplamento! Uma biblioteca hiper-especializada de Classe C (`dvmouse`) foi injetada no núcleo duro de Classe A (`dvcrt`), tornando-se existencial para todo o ecossistema. Isso mostra que o Kernel não é perfeitamente modular; utilitários periféricos contaminaram a raiz.
