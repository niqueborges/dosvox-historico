# O Paradoxo dos Fósseis: DOSDOS.PAS e DOSED.PAS

A inclusão de `DOSDOS.PAS` e `DOSED.PAS` na Amostra de Ouro (Grupo D - Fósseis) gerou uma descoberta arquitetural fascinante: **Eles não são fósseis puros pré-Windows.**

Ao verificarmos suas cláusulas `uses`, notamos:
```pascal
unit dosdos;
interface
uses windows, sysutils,
     dvcrt, dvwin, dvForm, dvExec,
     dosproc, dosgeral, dosmsg, dosed;
```

Eles dependem de `dvcrt`, `dvwin` e das APIs Win32 (windows, sysutils).

## Conclusão: Uma Camada de Retrocompatibilidade Ativa

Isso indica que o sistema não abandonou o MS-DOS ao migrar para Delphi/Windows. Em vez disso, construiu uma camada de abstração (Bridge) onde o `dosvox.exe` (a shell) ainda compreende comandos DOS.

- `DOSDOS.PAS` possui funções como `executa` e `macroComando` que rodam sob a supervisão do Windows (usando `dvExec`), mas oferecem uma interface transparente ao usuário para rodar legados.
- `DOSED.PAS` mapeia a intenção de "editar som" (antigamente algo via DOS) para o `MINIGRAV.EXE`, usando a API de ambiente do `dvwin` (`sintAmbiente`).

| Conceito Antigo (DOS) | Transmutação Win32 (`DOSDOS` / `DOSED`) | Base Tecnológica |
| --- | --- | --- |
| Executar programa DOS | `executaPrograma (..., SW_SHOWNORMAL)` | `dvExec` |
| Edição de som manual | Encaminhamento para `MINIGRAV.EXE` | `dvwin` (`sintAmbiente`) |
| Diretórios temporários | `GetTempFile` via API Windows | Win32 API (`GetTempPath`) |

Esta evidência sugere que o DOSVOX **emulou a experiência do DOS** em cima de uma arquitetura estritamente Windows, usando `dvcrt` para desenhar o texto procedural e `dvExec` para invocar binários antigos de forma transparente.
