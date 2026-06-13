# Matriz de Criticidade Taxonômica

A Fase C.3 revelou dependências ocultas, e a Fase C.4 as classificou por gravidade de impacto. Esta matriz formaliza as quatro classes de infraestrutura descobertas pelo compilador.

## Classe A — Infraestrutura Existencial
Sem elas, nada no ecossistema DOSVOX vive. O próprio "Paradigma DOSVOX" depende ontologicamente destas units.
- **`dvcrt`**: A base procedural de interface com o usuário e desenho de tela.
- **`dvwin`**: O motor central de integração de teclado, voz e processos de ambiente.
- **`dvtradut`**: O motor de tradução e abstração.
- **`dvmouse`**: *(Surpresa Empírica)* Originalmente especializada, tornou-se existencial devido a acoplamento sedimentado no `dvcrt`.

## Classe B — Serviços Fundamentais
Muitas aplicações de alto nível (Grupo A e B) dependem massivamente, mas aplicações matemáticas estritas ou de rede pura poderiam sobreviver sem elas.
- **`dvwav`**: Áudio gravado e sonoplastia estrutural.
- **`dvexec`**: Interação com subprocessos e binários legados.
- **`dvarq`**: Gerenciador padronizado de arquivos.
- **`dvhora`**: Contexto de relógio e cronômetro.
- **`dvform`**: A ponte gráfica com formulários visuais Delphi.

## Classe C — Serviços Especializados
Bibliotecas nativas do DOSVOX construídas para resolver domínios específicos de algumas poucas aplicações.
- **`videovox`**: Módulo de apresentação de vídeos.
- **`dvsapi5`, `dvsapi4`, `dvsapglb`, `speech`**: Motores de Síntese de Voz e interface SAPI.
- **`dvAmplia`**: Ampliação de tela nativa.

## Classe D — Bibliotecas Externas (Third-Party)
Infraestrutura exigida pelo compilador ou pelo SO, não mantida pelos desenvolvedores do DOSVOX, mas imperativas para a arquitetura.
- **`speechLib_TLB`, `speechLib54_TLB`**: Bibliotecas de Tipos COM SAPI da Microsoft.
- **`OleServer`, `OleCtrls`, `StdVCL`**: Base do Windows OLE e VCL.
- **`BaseUnix`, `Sockets`, `dynlibs`, `synafpc`**: Base da suíte Synapse e do runtime FreePascal.
- **`pipe`, `ssl_openssl_lib`**: Camadas de protocolo padrão.
