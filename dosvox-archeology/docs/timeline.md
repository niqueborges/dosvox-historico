# Linha do Tempo Evolutiva do DOSVOX (D.2)

O DOSVOX não é um software criado num único momento, mas um ecossistema construído por sedimentação geológica. Este documento traça a evolução da sua arquitetura, mapeando como cada "camada" de dependência que descobrimos surgiu na história.

- **1987 — Sistema Tradutor Fonético NRL**
  O embrião absoluto. Onde nasceu o componente que hoje reside em `dvtradut.pas`. Originalmente concebido antes do DOSVOX existir como sistema operacional, focado puramente em regras de difones para o português.

- **1994 — Primeiros Programas DOS**
  O nascimento do sistema operacional para cegos. Nesta era, os "verbos" se conectavam diretamente às interrupções de hardware do MS-DOS (speaker do PC e placas SoundBlaster rudimentares). Aqui nasceram arquiteturas de programas como o EdiVox (`DOSED.PAS` atuava nativamente).

- **1998 — Migração via `dvcrt`**
  A transição para o Windows. A criação do `dvcrt` e `dvwin` marcou o momento em que o DOSVOX deixou de ser um SO independente e virou um "Desktop Environment" emulado em Win32. As antigas chamadas de DOS foram re-escritas dentro de `dvwin` para garantir a retrocompatibilidade visual e sonora, criando o "Kernel 77".

- **2002 — Integrações VCL / PowerPoint**
  O DOSVOX passa a englobar utilitários ricos do ecossistema Windows (OLE, COM, ActiveX). É aqui que aplicações como o `PPTVOX` ganham vida, sedimentando a **Classe D** de dependências (ex: `OleServer`, `OleCtrls`).

- **2010 — Implementação SAPI5**
  O motor original de voz sintetizada ganha alternativas modernas. As bibliotecas `dvsapi5.pas` e `speechLib_TLB.pas` são anexadas ao núcleo. Essa foi uma fase de delegação, onde o Windows passou a ser responsável pelo processamento de fala, em vez da engine interna nativa.

- **2016 — Módulos Multimídia Avançados**
  Modernização dos drivers de som. As implementações de `dvwav` são reforçadas com `bass.pas`, e o sistema lida com MP3, rádios na internet (`radio50`) e protocolos de segurança mais robustos como SSL (`ssl_openssl_lib.pas`).

- **2026 — Arqueologia e Reconstrução**
  A presente fase. O momento histórico em que o monólito de código construído por quase quatro décadas é dissecado. A transição de "arquitetura intocável" para "laboratório de consolidação", visando sua modernização definitiva para o futuro.
