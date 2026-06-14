# DOSVOX Compilation Log

Este diário registra os experimentos do Laboratório de Compilação (Fase C.3). Em vez de descobrir dependências "olhando", nós as descobrimos de forma empírica (via falhas de compilação reais `File not found`). Este processo preserva a história de *como* descobrimos o Kernel definitivo.

## Entradas

*(As sessões de compilação da C.3 serão registradas aqui em formato)*:

```markdown
### [Data] - [Programa Testado]
- **Units Presentes no Core:** `dvcrt, dvwin, dvform, dvwav, dvexec, dvarq, dvhora`
- **Erro Encontrado:** `[Mensagem de erro do compilador]`
- **Correção Aplicada:** `[Ação tomada, ex: copiar nova unit para o core]`
- **Resultado Final:** `[OK / Falha]`
```

### 13/06/2026 - Sandbox de Compilação: Resolução do Core Transitivo
- **Units Iniciais no Core:** dvcrt, dvwin, dvform, dvwav, dvexec, dvarq, dvhora
- **Erro Encontrado:** Ao emular o dcc32, as units iniciais lançaram erro de \File not found\ para 14 dependências internas.
- **Correção Aplicada (Iteração 1):** Foram copiados para o core os módulos faltantes: dvAmplia, minireg, dvBrlCliente, dvMouse, dvmidi, ideovox, dvlenum, dvssl, dvsapglb, dvserpro, dvsapi5, dvsapi54, speech, dvinter.
- **Erro Encontrado:** A Iteração 1 lançou falha de \File not found\ para 4 sub-dependências.
- **Correção Aplicada (Iteração 2):** Foram copiados: pipe, speechLib_TLB, speechLib54_TLB, ssl_openssl_lib.
- **Erro Encontrado:** A Iteração 2 pediu units do sistema Delphi/FPC (OleServer, StdVCL, BaseUnix, Sockets, dynlibs).
- **Correção Aplicada (Iteração 3/4):** Como estas são bibliotecas embutidas nos compiladores Delphi/FreePascal (Synapse), elas foram registradas como resolvidas externamente.
- **Resultado Final:** OK. O \dosvox-core\ experimental está estabilizado.

