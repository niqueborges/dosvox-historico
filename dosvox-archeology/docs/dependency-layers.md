# Camadas de Dependência (Dependency Layers)

O Laboratório de Compilação (Fase C.3) nos permitiu reconstruir empiricamente a estratificação do DOSVOX. Partimos do "Núcleo Experimental" e descobrimos as raízes em cascata que definem a topologia de engenharia real do sistema.

## Camada 0: A Base Física / Drivers / SO
Bibliotecas pré-compiladas, dependências do compilador (Delphi / FreePascal) e interações OLE/COM cruas.
- `windows`, `sysutils`, `classes`, `forms` (Delphi RTL/VCL)
- `OleServer`, `OleCtrls`, `StdVCL` (Bibliotecas COM/ActiveX)
- `BaseUnix`, `Sockets`, `dynlibs` (Componentes transversais FreePascal/Synapse)
- `speechLib_TLB`, `ssl_openssl_lib`, `pipe` (Wrappers de baixo nível)

## Camada 1: O Núcleo Win32 / Motores Base
Os motores que dialogam diretamente com a Camada 0 e abstraem recursos complexos de sistema.
- `dvtradut` (Tradutor interno)
- `dvsapi4`, `dvsapi5`, `dvsapglb`, `speech` (Abstrações de TTS e SAPI)
- `dvssl`, `minireg` (Comunicações e Registro)
- `dvAmplia`, `dvMouse` (Acessibilidade física)
- `dvmidi`, `videovox` (Mídia pura)

## Camada 2: O Kernel 77 (A API do Ecossistema)
Estas são as units de alta centralidade que abstraem todo o peso da Camada 1 para oferecer o "Paradigma DOSVOX" limpo aos programadores de aplicativos.
- **`dvcrt`**: A espinha dorsal procedural (texto e tela).
- **`dvwin`**: O inicializador do ambiente, gerenciador de fala e teclado.
- `dvform`: A ponte de formulários visuais do Delphi.
- `dvwav`: O motor simplificado de reprodução de áudio.
- `dvexec`: O motor transparente de execução de subprocessos.
- `dvhora`: Manipulação cronológica.
- `dvarq`: Leitura e escrita padronizadas de arquivos.
- `dvBrlCliente`, `dvinter`, `dvlenum`, `dvserpro`

## Camada 3: Aplicações Fundamentais (Primeira Ordem)
Programas que utilizam diretamente a Camada 2 para resolver lógicas estritas sem grandes acoplamentos verticais.
- `Edivox` (Opera pesado em `dvcrt`, `dvwav`, `dvarq`)
- `Forcavox`, `Sudovox`, `Desafio do Barão` (Jogos/Utilitários que dependem 100% de `dvcrt` e `dvwin`)
- `Mistuvox` (Aplicações históricas que consolidaram o padrão)
- *Fósseis* (`DOSDOS.PAS`, `DOSED.PAS` que usam `dvExec` para retrocompatibilidade)

## Camada 4: Aplicações de Borda (Segunda Ordem)
Programas complexos que, além da Camada 2, tocam frequentemente em recursos da Camada 0 e 1, quebrando a barreira da pureza textual.
- `Webvox` (Requer Synapse, sockets TCP/IP)
- `Cartavox` (Requer SMTP, IMAP, SSL)
- `PPTVOX` (Requer integração direta com ActiveX/OLE do MS PowerPoint na Camada 0)
