# Proveniência e Licenciamento (D.1)

A varredura pelos códigos-fonte do Sítio Original (`C:\winvox\Fontes`) em busca de proveniência legal revelou um mosaico de titularidades e licenças. O DOSVOX cresceu absorvendo tecnologias de código aberto, bibliotecas comerciais antigas e código proprietário acadêmico.

## 1. Titularidade Principal (Core)
A esmagadora maioria do código estrutural (`dvwin`, `dvcrt`, `dvtradut`) pertence institucionalmente ao projeto DOSVOX.
- **Cabeçalho Padrão:** `{ Copyright (C) 2008 - NCE/UFRJ - The Dosvox Project }`
- **Autores Frequentes:** José Antonio Borges, Neno Henrique da Cunha Albernaz, Patrick Barboza, Bernard Condorcet, Geraldo Xexeo.
- **Licenciamento Explícito:** Ausente no código-fonte em si. O site do InterVox fala em distribuição livre, mas **não há uma licença de software livre (ex: GPL) anexada nativamente ao core do projeto**. Trata-se de código de domínio universitário freeware.

## 2. Bibliotecas de Terceiros e Licenças Adotadas
O ecossistema utiliza pontes que arrastam licenças conhecidas:
- **SQLite3 / ScripVox:** `Copyright 2010-2013 Yury Plashenkov` (Sob a **Licença MIT**).
- **Bass.pas (Motor de Som):** `Copyright (c) 1999-2022 Un4seen Developments Ltd.` (Software proprietário com isenção para projetos freeware/educacionais).
- **Integração NVDA / Python:** `Copyright (C) 2006-2007 NVDA Contributors` (Sob a **Licença GNU GPL**).
- **FormulaCalc (CALCUVOX):** `Copyright 2000-2002 AidAim Software. Small adjusts by Antonio Borges`.
- **Chessvox:** `Copyright 1997 Tom Kerrigan` (Código antigo de IA de xadrez adaptado).

## Resumo Jurídico e Histórico
Se o DOSVOX for migrado para um repositório Open Source público (como o GitHub) no futuro, **uma auditoria de licenciamento precisará ser feita**. O código base é do NCE/UFRJ, mas a inclusão da engine de som `BASS` (Comercial/Freeware) e eventuais conflitos com `GPL` (NVDA) na mesma distribuição impõem restrições à mudança da licença do DOSVOX para algo puramente permissivo como MIT.
