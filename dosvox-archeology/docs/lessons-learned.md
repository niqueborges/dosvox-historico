# Lições Aprendidas na Arqueologia de Software

A pesquisa no código do DOSVOX em 2026 nos ensinou tanto sobre os sistemas antigos quanto sobre as armadilhas de se realizar arqueologia de software de forma negligente. Se no futuro um novo pesquisador tentar reconstruir o legado de qualquer plataforma viva por várias décadas, estes princípios provaram-se verdadeiros:

## Lição 1: Contagem de arquivos brutos é enganosa
**O Erro:** Achar que medir a arquitetura baseando-se apenas na contagem total de arquivos extraídos revelaria os gargalos do projeto.
**A Descoberta:** Descobrimos que milhares de pequenos arquivos `.wav` ou arquivos de log pesavam estatisticamente a distribuição do mesmo jeito que units fundamentais da linguagem. 
**A Correção:** Classificar estritamente por extensão e natureza semântica (código procedural vs dados estáticos vs binários) foi a única maneira de ver o esqueleto real.

## Lição 2: Importância operacional não é importância histórica
**O Erro:** Descartar programas antigos por achar que "ninguém mais usa isso no dia-a-dia".
**O Exemplo:** Aplicativos de jogos aparentemente irrelevantes como `Forcavox` ou fóssil de disco como `DOSDOS` não eram meras brincadeiras — eles retêm o DNA arquitetural da migração, ensinando aspectos essenciais da retrocompatibilidade que a equipe desenvolveu.

## Lição 3: O compilador é a maior ferramenta sociológica da pesquisa
**A Descoberta:** Entender que ler o código e inferir a arquitetura não funciona. Apenas quebrando o código (Knockout) se descobre a verdade sobre quem dependia de quem. A engenharia reversa empírica não deve temer a falha do Build.

## Lição 4: A arquitetura idealizada quase sempre difere da arquitetura real
**A Expectativa:** O projeto assumiria que as camadas do Kernel e módulos periféricos não se tocavam por causa do princípio modular defendido.
**A Evidência Real:** A contaminação do módulo `dvcrt` pelo `dvmouse`. O código conta a história verdadeira: as dívidas arquiteturais inevitavelmente acontecem sob a pressão do tempo e da adaptação a novas infraestruturas operacionais.

## Lição 5: A memória humana e o código se complementam
**O Conflito:** Nós baseamos toda a nossa pesquisa (Fase A até C) apenas na leitura isolada de matrizes compiláveis.
**A Epifania:** O trabalho de engenharia empírico, que gerou todas as nossas hipóteses taxonômicas (descoberta do Mutirão, centralidade por sedimentação de verbos), foi surpreendente e explicitamente confirmado pela história contada pelo criador do DOSVOX, Antonio Borges. A arqueologia confirmou a memória, e a história validou as equações dos grafos de dependência construídos pelo computador. A documentação arqueológica funde a precisão cristalina e insensível do compilador às intenções emocionais e contextuais de quem escreveu o código 30 anos atrás.

---

*O DOSVOX não foi reconstruído para ser simplificado, mas para ser compreendido. Muitas coisas aconteceram. Em 2026, quando já não era possível lembrar de tudo, nós perguntamos ao compilador. E fomos documentando à medida que descobríamos.*
