# Métricas de Dependência do Núcleo (Snapshot)

**Data do Snapshot:** 2026-06
**Local original analisado:** `C:\winvox\Fontes\tradutor`

Esta métrica resume as dependências vitais das units que compõem o "Kernel" do DOSVOX (o orquestrador de síntese e emulação).

### A Cadeia de Sedimentação (Grafo Vertical)

1. **`dvtradut.pas` (Geração 0 - 1987)**
   - **Importa:** `NADA`
   - **É importada por:** `dvwin.pas`, `dvinter.pas`, utilitários de sintaxe.
   - **Acoplamento:** Zero. Totalmente autocontida.

2. **`dvcrt.pas` (Geração 2 - 1998)**
   - **Importa:** `Windows`, `Messages`, `SysUtils`, `mmSystem`, `minireg` (Apenas APIs base do Windows).
   - **É importada por:** **Virtualmente todos os 167 programas do ecossistema.**
   - **Acoplamento:** Alto *fan-in* (muitos dependem dela), baixo *fan-out* (ela depende apenas do SO).

3. **`dvwin.pas` (Geração 2 - 1998)**
   - **Importa:** `Windows`, `SysUtils`, `dvcrt`, `dvwav`, `dvtradut`, `dvsapi`, `mmsystem`, etc.
   - **É importada por:** **Virtualmente todos os 167 programas do ecossistema.**
   - **Acoplamento:** Alto *fan-in*, médio *fan-out* (conecta a aplicação à infraestrutura do DOSVOX).

4. **`dvform.pas` (Geração 3 - 2001)**
   - **Importa:** `dvwin`, `dvcrt`, `Windows`, bibliotecas visuais base.
   - **É importada por:** Programas que necessitam de captura de formulários mais complexos sem quebrar o paradigma textual (ex: Webvox, Cartavox).

### Sumário da Saúde Arquitetural
- **Ausência de Ciclos:** Nenhuma dependência circular detectada entre as units principais.
- **Isolamento de API:** A maior parte dos programas depende exclusivamente de `dvcrt` e `dvwin`. Se estas duas units forem preservadas, 90% do ecossistema continua funcionando.
