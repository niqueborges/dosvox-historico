# Código Morto e Fósseis

Em sistemas que evoluem por 30 anos como o DOSVOX, o acúmulo de arquivos sem uso real ("fósseis") é o comportamento padrão e esperado.

Exemplos encontrados na raiz da pasta `Dosvox`:
- `DOSDOS.PAS`
- `DOSED.PAS`
- `DOSJANEL.PAS`
- `T.PAS`

## A Postura Conservadora da Arqueologia de Software

Apesar de não haver nenhuma referência (`uses`) a esses arquivos em todo o ecossistema na versão analisada, **nós não apagamos esses arquivos de forma destrutiva**.

Em software legado antigo, a dependência pode estar invisível aos métodos modernos de busca por causa de:
- Includes estáticos (`{$I arquivo.pas}`)
- Diretivas de compilação condicional
- Scripts de build antigos ou hardcoded (como arquivos `.bat` antigos)

## O que faremos?

Em vez de deletar, no futuro eles serão isolados:
```text
legacy/
    unused/
        DOSDOS.PAS
        DOSED.PAS
        DOSJANEL.PAS
        T.PAS
```

E documentados da seguinte forma:
*"Nenhuma referência explícita encontrada em todos os `.pas` e `.dpr` da versão estudada. Arquivo mantido para fins históricos e segurança de build."*
