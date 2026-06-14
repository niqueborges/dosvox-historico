# Caçada aos Binários Órfãos

A arqueologia do ecossistema DOSVOX revelou executáveis presentes nas distribuições cujo código-fonte pode não estar diretamente mapeado ou cuja procedência exige verificação cruzada. Esta tabela consolida o rastreamento dos binários órfãos e suas funções.

| Nome do Binário | Função Inferida / Conhecida | Origem Conhecida | Código-Fonte Existente no Repo? | Motivo da Preservação | Nível de Confiança |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `DOSDOS.EXE` | Interação legada de manipulação de disco | Era DOS Puro (16-bits) | Fóssil Parcial (`DOSDOS.PAS`) | Retrocompatibilidade histórica | **Alta** |
| `DOSED.EXE` | Editor de texto primitivo | Era DOS Puro | Fóssil Parcial (`DOSED.PAS`) | Retrocompatibilidade histórica | **Alta** |
| Motores SAPI (`SAPI4`, `SAPI5`) | Integração com Vozes do Windows | Microsoft / Terceiros | Não (Módulos externos/Wrappers apenas) | Suporte a sintetizadores modernos | **Alta** |
| `LianeTTS` (Binários Base) | Motor de síntese fonética | Serpro / NCE | Não (Proprietário/Terceiros) | Voz clássica do ecossistema | **Alta** |

*(Nota: Este é um caderno de laboratório vivo. À medida que novos diretórios `orphan-binaries` são inspecionados nas escavações, esta tabela deverá ser atualizada para documentar ferramentas de terceiros vs. ferramentas nativas de eras esquecidas).*
