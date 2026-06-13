# O "Kernel 77" (Framework Base / Runtime)

**Evidência:** 
Partindo de `dosvox.dpr`, `dvcrt`, `dvwin` e `dvform`, o grafo de dependências encontrado envolve aproximadamente 71 a 77 units localizadas majoritariamente na pasta `tradutor`.

**Inferência:** 
Existe um subconjunto relativamente pequeno e coeso responsável pela infraestrutura principal do sistema. Este núcleo não é um kernel de SO, mas sim um **framework base** ou **runtime**. O número exato varia dependendo de quais extensões (OCR, internet, síntese específica) o ponto de partida puxa.

**Hipótese Histórica:** 
Este subconjunto de aproximadamente 77 units representa o núcleo histórico de fundação do DOSVOX.

## A pasta "tradutor" como um Fóssil de Nomenclatura
Em projetos longos, é comum que um diretório nasça para uma finalidade e vá acumulando responsabilidades ao longo das décadas até que seu nome original perca o sentido. 

A pasta `tradutor` é o exemplo perfeito disso no DOSVOX. Hoje, ela contém:
- `dvcrt` (terminal texto)
- `dvwin` (orquestração de janelas acessíveis e teclado)
- `dvinet` (rede)
- `dvarq` (arquivos)
- `dvform` (formulários)
- Wrappers de SAPI e multimídia

Na prática, a pasta `tradutor` virou o `framework/`, `core/` ou `runtime/` do ecossistema, mas o nome histórico foi mantido. O framework é altamente coeso e as applications (Jogavox, Webvox, etc.) apenas o consomem.
