# Metodologia Arqueológica do DOSVOX

A análise, documentação e extração arquitetural do ecossistema DOSVOX em 2026 foram conduzidas sob um rigoroso conjunto de princípios metodológicos. Inspirada pela história do projeto e pautada no respeito pelo legado de três décadas, esta metodologia serviu para evitar que reconstruíssemos a arquitetura com base em "achismos" modernos ou falhas de memória. 

Estes são os oito mandamentos que guiaram nossa arqueologia de software, e que devem nortear qualquer esforço futuro de preservação sistêmica.

## 1. Evidência Acima da Memória
Como o próprio Antonio Borges escreveu: *“O tempo se comporta como um apagador”* e há uma *“leve tendência a enfeitar o pavão”*. Relatos humanos (mesmo dos fundadores) são cruciais para a sociologia do projeto, mas a estrutura técnica deve ser comprovada. A evidência imutável deixada no código tem precedência sobre a lembrança arquitetural.

## 2. Quando Houver Dúvida, Pergunte ao Compilador
O compilador não mente e não tem nostalgia. Em vez de ler o código e tentar adivinhar a dependência, conduzimos testes empíricos rigorosos. Testes de "Knockout" (apagar uma unit e ver onde o sistema sangra) ou o Fecho Transitivo são a nossa fonte máxima da verdade estrutural. 

## 3. Preservar Antes de Refatorar
Em um sistema legado de altíssima longevidade, reescritas puramente cosméticas destroem a estratigrafia técnica. A primeira etapa de qualquer contato com o código foi o mapeamento, catalogação e isolamento. Somente após compreender o porquê de um código estar daquele jeito, pensou-se em modernizá-lo.

## 4. Não Confundir Importância Operacional com Histórica
Um módulo foi julgado a partir de matrizes multidimensionais de valor. Um executável esquecido ou um arquivo em Turbo Pascal puro (como o fóssil `DOSDOS.PAS`) pode não ter nenhuma relevância para o usuário final de hoje, mas possui um altíssimo valor arquitetural e genético para entender como a plataforma deu o salto evolutivo do DOS para o Windows.

## 5. Registrar Hipóteses e Níveis de Confiança
A arqueologia de software é uma ciência probabilística em suas fases iniciais. Aceitamos a ambiguidade. Em vez de declarar fatos absolutos prematuramente, registramos "matrizes de confiança taxonômica", aceitando que nossa visão do sistema evoluiria conforme mais "escavações" (compilações) fossem feitas.

## 6. Manter os Cadernos de Laboratório
A separação estrita entre conhecimento consolidado (`docs/`) e as anotações empíricas brutas (`research/`) foi basilar. Os logs de compilação, grafos crús e matrizes de instaladores não foram apagados após servirem de rascunho. Eles preservam *como* a equipe de 2026 chegou às conclusões, permitindo que a ciência seja reproduzida ou contestada no futuro.

## 7. Preferir a Organização por Camadas (Sedimentação)
Em vez de impor um viés retrospectivo (tentando enxergar "Clean Architecture" ou um MVC perfeito em um código de 1994), o estudo buscou entender o sistema pelas suas camadas geológicas de desenvolvimento. Aceitamos que o DOSVOX cresceu por sedimentação contínua de "Mutirões" e focamos em entender as fronteiras entre essas eras tecnológicas que coexistem perfeitamente.
