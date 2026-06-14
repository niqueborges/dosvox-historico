# Matriz de Compilação (Sandbox)

Esta matriz acompanha o status da compilação laboratorial da Amostra de Ouro contra o núcleo experimental `dosvox-core/`. O sucesso valida a estratificação; a falha (erro) mapeia dependências invisíveis.

| Programa | Grupo | Valor Principal | Status de Compilação | Dependências Descobertas / Faltantes |
| --- | --- | --- | --- | --- |
| Mistuvox | B | Histórico | 🟢 OK | `dvAmplia`, `dvBrlCliente`, `dvinter`... (14 units do Core Expandido) |
| Forcavox | D | Operacional | 🟢 OK | Mapeadas no Core Expandido |
| Desafio do Barão (Baronvox) | D | Operacional | 🟢 OK | Mapeadas no Core Expandido |
| Sudovox | D | Operacional | 🟢 OK | Mapeadas no Core Expandido |
| Edivox | A | Operacional | 🟢 OK | Mapeadas no Core Expandido |
| Webvox | A | Operacional | 🟢 OK | Mapeadas no Core Expandido + `synafpc` (FreePascal) |
| Cartavox | A | Operacional | 🟢 OK | Mapeadas no Core Expandido |
| PPTVOX | C | Arquitetural | 🟢 OK | `speechLib_TLB`, COM/OLE Externo |
| Fósseis (DOSDOS/DOSED) | D | Histórico | 🟢 OK | Plena resolução via Win32 Bridges |

*(Legenda: ⚪ Pendente, 🟢 OK, 🔴 Falhou)*
