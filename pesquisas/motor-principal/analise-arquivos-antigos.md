# Os 100 Arquivos Mais Antigos do DOSVOX

Para identificar os arquivos que mais provavelmente remontam ao núcleo original do MS-DOS e à migração inicial para o Windows, criei um sistema de pontuação baseado nas seguintes heurísticas:
- **Estilo de programação:** Ausência total de `class` (paradigma procedural puro).
- **Chamadas de I/O Clássicas:** Uso intenso de `Assign`, `Reset`, `Rewrite`, `Close` (I/O padrão do Turbo Pascal antigo, antes das classes de Stream do Delphi).
- **APIs:** Ausência de `uses Windows` e `uses SysUtils`, indicando isolamento da WinAPI.
- **Datas e Autoria:** Comentários com datas dos anos 90 ou assinatura original de J. A. Borges.
- **Dependências:** Ausência de cláusula `uses` (arquivos standalone).
- **Palavras reservadas antigas:** Uso de `absolute`, `interrupt`, etc.

## Lista dos Top 100 Arquivos Legados

### `\FICHAVOX\FVARQUI.PAS` (Pontuação: 143)
> **Por que parece antigo:** 41 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Sem SysUtils do Delphi

### `\CARTAVOX\carSMTP.pas` (Pontuação: 129)
> **Por que parece antigo:** 38 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\sc\sc_interp\IO.PAS` (Pontuação: 98)
> **Por que parece antigo:** 26 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data do inicio dos anos 2000

### `\agenda\AGFORM.PAS` (Pontuação: 97)
> **Por que parece antigo:** 24 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\CARTAVOX\CARCOPIA.PAS` (Pontuação: 96)
> **Por que parece antigo:** 27 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\CARTAVOX\PRELISTA.DPR` (Pontuação: 93)
> **Por que parece antigo:** 16 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990

### `\UTIL\PRELISTA.DPR` (Pontuação: 93)
> **Por que parece antigo:** 16 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990

### `\LETRIX\LETRIX.DPR` (Pontuação: 89)
> **Por que parece antigo:** 23 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data do inicio dos anos 2000

### `\ICHINVOX\ICHINTER.PAS` (Pontuação: 88)
> **Por que parece antigo:** 21 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\PAPOVOX\ppcontro.pas` (Pontuação: 85)
> **Por que parece antigo:** 20 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Data do inicio dos anos 2000

### `\MINIGRAV\JUNTAWAV.DPR` (Pontuação: 82)
> **Por que parece antigo:** 14 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Data da decada de 1990

### `\WEBVOX\WEBCATAL.PAS` (Pontuação: 79)
> **Por que parece antigo:** 18 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Sem SysUtils do Delphi, Data do inicio dos anos 2000

### `\CARTAVOX\CARUTIL.PAS` (Pontuação: 78)
> **Por que parece antigo:** 21 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\tradutor\DVTRADUT.PAS` (Pontuação: 73)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Standalone (sem clausula uses), Data da decada de 1990

### `\MISTUVOX\mistuvox.dpr` (Pontuação: 71)
> **Por que parece antigo:** 7 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990, Data do inicio dos anos 2000

### `\PLANIVOX\plarq.pas` (Pontuação: 71)
> **Por que parece antigo:** 17 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI

### `\PPTVOX\pparq.pas` (Pontuação: 69)
> **Por que parece antigo:** 18 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\UTIL\reduztam.dpr` (Pontuação: 68)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990, Data do inicio dos anos 2000

### `\COLOSSAL\COLMSG.PAS` (Pontuação: 67)
> **Por que parece antigo:** 14 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Data do inicio dos anos 2000

### `\agenda\agGastos.pas` (Pontuação: 63)
> **Por que parece antigo:** 16 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\CARTAVOX\CARENVIA.PAS` (Pontuação: 63)
> **Por que parece antigo:** 16 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\TELEVOX\TelItem.pas` (Pontuação: 63)
> **Por que parece antigo:** 16 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\INTERVOX\INTERVOX.DPR` (Pontuação: 62)
> **Por que parece antigo:** 14 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data do inicio dos anos 2000

### `\ICHINVOX\ICHDISCO.PAS` (Pontuação: 61)
> **Por que parece antigo:** 12 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\MINIED\minied.dpr` (Pontuação: 61)
> **Por que parece antigo:** 7 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data da decada de 1990, Data do inicio dos anos 2000

### `\sc\sc_interp\dvscript55.pas` (Pontuação: 61)
> **Por que parece antigo:** 22 chamadas classicas (Assign/Reset/Rewrite), Data do inicio dos anos 2000

### `\SCRIPVOX\dvscript57.pas` (Pontuação: 61)
> **Por que parece antigo:** 22 chamadas classicas (Assign/Reset/Rewrite), Data do inicio dos anos 2000

### `\tradutor\dvscript55.pas` (Pontuação: 61)
> **Por que parece antigo:** 22 chamadas classicas (Assign/Reset/Rewrite), Data do inicio dos anos 2000

### `\tradutor\UUENC.PAS` (Pontuação: 61)
> **Por que parece antigo:** 12 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\AGENVOX\AGARQ.PAS` (Pontuação: 60)
> **Por que parece antigo:** 10 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data do inicio dos anos 2000

### `\Edivox\edArq.pas` (Pontuação: 60)
> **Por que parece antigo:** 15 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\MINIWEB\TCORREIO.PAS` (Pontuação: 60)
> **Por que parece antigo:** 10 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data do inicio dos anos 2000

### `\tradutor\synapse\synsock.pas` (Pontuação: 60)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Standalone (sem clausula uses), Data da decada de 1990, Data do inicio dos anos 2000

### `\MINIWEB\MINIWEB.DPR` (Pontuação: 59)
> **Por que parece antigo:** 13 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data do inicio dos anos 2000

### `\recado\recmime64.pas` (Pontuação: 59)
> **Por que parece antigo:** 8 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Standalone (sem clausula uses)

### `\TNETVOX\TNTERM.PAS` (Pontuação: 59)
> **Por que parece antigo:** 13 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data do inicio dos anos 2000

### `\agenda\AGMAIL.PAS` (Pontuação: 58)
> **Por que parece antigo:** 11 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\BRAIVOX\BRAIVOX.DPR` (Pontuação: 58)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data da decada de 1990, Data do inicio dos anos 2000

### `\WEBVOX\WEBBUSCA.PAS` (Pontuação: 58)
> **Por que parece antigo:** 11 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Sem SysUtils do Delphi, Data do inicio dos anos 2000

### `\WEBVOX\WEBCARTA.PAS` (Pontuação: 58)
> **Por que parece antigo:** 11 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Sem SysUtils do Delphi, Data do inicio dos anos 2000

### `\chessvox\svload.pas` (Pontuação: 56)
> **Por que parece antigo:** 12 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI

### `\UTIL\COMPARE.PAS` (Pontuação: 56)
> **Por que parece antigo:** 7 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Standalone (sem clausula uses)

### `\chessvox\defs.pas` (Pontuação: 55)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Standalone (sem clausula uses), Data da decada de 1990

### `\QUESTVOX\QUESTVOX.DPR` (Pontuação: 55)
> **Por que parece antigo:** 10 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Data do inicio dos anos 2000

### `\tradutor\pngimage.pas` (Pontuação: 55)
> **Por que parece antigo:** 20 chamadas classicas (Assign/Reset/Rewrite), Data do inicio dos anos 2000

### `\tradutor\synapse\mimeinln.pas` (Pontuação: 55)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Data da decada de 1990, Data do inicio dos anos 2000, Palavras reservadas raiz (absolute/interrupt/port)

### `\CARTAVOX\carResp.pas` (Pontuação: 54)
> **Por que parece antigo:** 13 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\CDMP3\CDjunta.pas` (Pontuação: 53)
> **Por que parece antigo:** 11 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI

### `\Edivox\LIMPAEXC.DPR` (Pontuação: 53)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Standalone (sem clausula uses)

### `\WEBVOX\webGrava.pas` (Pontuação: 53)
> **Por que parece antigo:** 11 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data do inicio dos anos 2000

### `\chessvox\book.pas` (Pontuação: 50)
> **Por que parece antigo:** 5 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data da decada de 1990

### `\PIRATVOX\PIRATVOX.DPR` (Pontuação: 50)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990, Data do inicio dos anos 2000

### `\VIDAVOX\VIDAVOX.DPR` (Pontuação: 50)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990, Data do inicio dos anos 2000

### `\tradutor\synapse\mimepart.pas` (Pontuação: 49)
> **Por que parece antigo:** 8 chamadas classicas (Assign/Reset/Rewrite), Data da decada de 1990, Data do inicio dos anos 2000, Palavras reservadas raiz (absolute/interrupt/port)

### `\UTIL\UUENC.PAS` (Pontuação: 49)
> **Por que parece antigo:** 8 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\CONTAVOX\CONTAVOX.DPR` (Pontuação: 48)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data do inicio dos anos 2000

### `\CDMP3\CDDIVID.PAS` (Pontuação: 48)
> **Por que parece antigo:** 9 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI

### `\Dosvox\dosvox.dpr` (Pontuação: 46)
> **Por que parece antigo:** 2 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data da decada de 1990, Data do inicio dos anos 2000

### `\agenda\agFolhei.pas` (Pontuação: 45)
> **Por que parece antigo:** 5 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data do inicio dos anos 2000

### `\CARTAVOX\CARDECOD.PAS` (Pontuação: 45)
> **Por que parece antigo:** 10 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\CARTAVOX\CARLEIT.PAS` (Pontuação: 45)
> **Por que parece antigo:** 10 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes)

### `\chessvox\chessvox.dpr` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990

### `\chessvox\data.pas` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990

### `\chessvox\eval.pas` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990

### `\IMPRIVOX\IMPFORM.PAS` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Sem SysUtils do Delphi, Data da decada de 1990, Data do inicio dos anos 2000

### `\IMPRIVOX\IMPVARS.PAS` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Sem SysUtils do Delphi, Data da decada de 1990, Data do inicio dos anos 2000

### `\NIMVOX\NIMVOX.DPR` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990

### `\PAPOVOX\PAPOVOX.DPR` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Sem SysUtils do Delphi, Data da decada de 1990, Data do inicio dos anos 2000

### `\radio50\bass.pas` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Sem SysUtils do Delphi, Data da decada de 1990, Data do inicio dos anos 2000

### `\tradutor\OLEACC.PAS` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Sem SysUtils do Delphi, Data da decada de 1990, Data do inicio dos anos 2000

### `\UTIL\MODSENHA.PAS` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Data da decada de 1990

### `\UTIL\dvttslib\dvttslib.dpr` (Pontuação: 45)
> **Por que parece antigo:** Procedural puro (sem classes), Independencia da WinAPI, Data da decada de 1990, Assinatura do autor J. A. Borges

### `\lianetts\uttsInic.pas` (Pontuação: 44)
> **Por que parece antigo:** 3 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi, Standalone (sem clausula uses)

### `\MEMOJOGO\memojogo.dpr` (Pontuação: 44)
> **Por que parece antigo:** 8 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Assinatura do autor J. A. Borges

### `\PAPOVOX\PPARQ.PAS` (Pontuação: 44)
> **Por que parece antigo:** 8 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI

### `\TNETVOX\tncmdloc.pas` (Pontuação: 44)
> **Por que parece antigo:** 8 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI

### `\CALCUVOX\calmem.pas` (Pontuação: 43)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\COLOSSAL\COLSAVE.PAS` (Pontuação: 43)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\DICIO\ELIMREP.PAS` (Pontuação: 43)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\DICIO\PREPDIC.DPR` (Pontuação: 43)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\DICIO\PREPDIC.PAS` (Pontuação: 43)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\Dosvox\dosquem.pas` (Pontuação: 43)
> **Por que parece antigo:** 1 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Sem SysUtils do Delphi, Data da decada de 1990

### `\Edivox\ALTERDIC.DPR` (Pontuação: 43)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\FTPVOX\FTPARQ.PAS` (Pontuação: 43)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Data do inicio dos anos 2000

### `\PPTVOX\ppimport.pas` (Pontuação: 43)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\tradutor\dvinter.pas` (Pontuação: 43)
> **Por que parece antigo:** 1 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Data da decada de 1990, Data do inicio dos anos 2000

### `\tradutor\DVSENHA.PAS` (Pontuação: 43)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

### `\WEBVOX\WEBLIST.PAS` (Pontuação: 43)
> **Por que parece antigo:** 6 chamadas classicas (Assign/Reset/Rewrite), Procedural puro (sem classes), Independencia da WinAPI, Sem SysUtils do Delphi

*(A lista continua nos diretórios locais de varredura com os 100 arquivos listados no script de auditoria original).*
