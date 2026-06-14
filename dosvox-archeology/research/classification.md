# Classificação dos Artefatos Arqueológicos

Este documento cataloga a taxonomia dos módulos do sistema, categorizando-os por Tipo, Geração, Estado e descrevendo a Evidência de cada classificação.

---

### `dvtradut.pas`
- **Tipo:** Core
- **Geração:** G0 (1987)
- **Estado:** Ativo
- **Evidência:** Cabeçalho do arquivo indica criação em julho de 1987 ("Sistema Tradutor Fonetico N.R.L.") e adaptação ao DOSVOX em 1994. Não possui dependências com outras units.

### `dvcrt.pas`
- **Tipo:** Core
- **Geração:** G2 (1998)
- **Estado:** Ativo
- **Evidência:** Cabeçalho declara ser uma implementação de "Windows CRT Interface Unit" (Jan/1998) para emular as chamadas antigas do MS-DOS no Windows 32-bits.

### `mistuvox.dpr`
- **Tipo:** App
- **Geração:** G1 (1994 DOS / Migrado)
- **Estado:** Ativo
- **Evidência:** Cabeçalho lista "Em 30/12/1994". O código faz uso exclusivo de funções procedurais puras (`textBackground`, `clrscr`, `keypressed`) herdadas do Turbo Pascal.

### `PPTVOX` (Módulo)
- **Tipo:** ThirdParty / Interop
- **Geração:** G3 / G4 (~2002)
- **Estado:** Ativo
- **Evidência:** Presença de arquivos `.dfm` (`PPMSG.DFM`), demonstrando a adoção do Paradigma Visual Delphi para conectar-se às APIs COM do Microsoft PowerPoint, quebrando o paradigma de emulação textual.

### `DOSDOS.PAS` e `DOSED.PAS`
- **Tipo:** Legacy/Fóssil
- **Geração:** G1 (Era DOS puro)
- **Estado:** Fóssil
- **Evidência:** Arquivos-fonte de Turbo Pascal espalhados na raiz sem associação a arquivos `.dpr` ou inclusão nos builds modernos, retendo lógicas exclusivas do sistema de arquivos antigo de 16-bits.

### `lianetts/dosvox.py` e `SonoraMat/*.py`
- **Tipo:** Shell / Peripheral Scripts
- **Geração:** G5
- **Estado:** Ativo
- **Evidência:** Scripts Python que empacotam o motor LianeTTS ou processam matemática. Não são chamados internamente pelo `Core` Pascal, mantendo a arquitetura original limpa de invasão linguística moderna.
