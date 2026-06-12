funcao maquina joga (jogador,rodada,jogada, var carta_jogada)

----------------------------------------------------
variavel global
   situacao = record
           corte:array [0..3] of naipe
           ttrunfo:boolean
        end;

var
   participante: array [0..3] of situacao

-----------------------------------------------------

se rodada >= 0 e <= 4

   se jogada = 0
      carta_a_jogar <- rodada_04_vez_0 (jogador,rodada,jogada)

   se não se jogada = 1 ou = 2
      carta_a_jogar <- rodada_04_vez_1_2 (jogador,rodada,jogada)

   se não
      carta_a_jogar <- rodada_0_4_vez_3 (jogador,rodada,jogada)

se não

   se jogada = 0
      carta_a_jogar <- rodada_59_vez_0 (jogador,rodada,jogada)

   se não se jogada = 1 ou = 2
      carta_a_jogar <- rodada_04_vez_1_2 (jogador,rodada,jogada)

   se não
      carta_a_jogar <- rodada_0_4_vez_3 (jogador,rodada,jogada)

carta_jogada <- jogador [quenjoga].carta[carta_a_jogar]
jogador [quenjoga].carta[carta_a_jogar].usada <- true



funcao rodada_04_vez_0 (jogador,rodada,jogada)
----------------------------------------------

achou <- procura_As (quemjoga)

se achou <> -1
   rodada_04_vez_0 <- achou

se não
   quem_parceiro_corta <- parceirocortaoutrosnao (quemjoga)

   se participante [proximo(proximo(quemjoga))].ttrunfo = true

      se quem_parceiro_corta <> NULL
         rodada_04_vez_0 <- maior_do_naipe (quemjoga,quem_parceiro_corta)

      se não
         rodada_04_vez_0 <- menor_carta (quemjoga)

   se não
      rodada_04_vez_0 <- menor_carta (quemjoga)


funcao rodada_04_vez_1_2 (jogador,rodada,jogada)
------------------------------------------------

pnaipe <- naipe_jogada (rodada)
tercarta <- tem_naipe (quemjoga, naipe)

quemfaz <- quem_faz (rodada, naipe)
proximocarta <- proximo_corta (quenjoga, pnaipe)

se quemfaz <> proximo (proximo(quemjoga))

   se tercarta = true
      faco <- se_carta_faz (quemjoga, carta, rodada)

      se (faco = true) e (((proximocorta = true) e
      (participante[proximo(quemjoga)].ttrunfo = false)) ou
      (proximocorta = false))
         rodada_04_vez_1_2 <- maior_do_naipe (quemjoga, naipe)

      se não
         rodada_04_vez_1_2 <- menor_do_naipe (quemjoga, naipe)

    se não
       corta (quemjoga, naipe)
       tercarta <- tem_naipe (quemjoga, trunfo.naipe)

       se tercarta = true
          rodada_04_vez_1_2 <- maior_do_naipe (quemjoga,trunfo.naipe)

       se não
          rodada_04_vez_1_2 <- menor_carta (quemjoga)
          participante[quemjoga].ttrunfo <- false



funcao rodada_04_vez3 (jogador,rodada,jogada)
---------------------------------------------

quemfaz <- quem_faz (rodada, naipe)
naipe <- naipe_jogada (rodada)

se quemfaz <> proximo(proximo(quemjoga))
   tercarta <- tem_naipe (quemjoga, naipe)
   carta := naior_do_naipe (quemjoga, pnaipe)

   se tercarta = true
      faco <- se_carta_faz (quemjoga, carta, rodada)

      se faco
         rodada _04_vez3 <- maior_do_naipe (quemjoga, naipe)

      se não
         rodada _04_vez3 <- menor_do_naipe (quemjoga, naipe)

   se não
      corta (quemjoga, naipe)
      tercarta <- tem_naipe (quemjoga, trunfo.naipe)

      se tercarta = true
         rodada _04_vez3 <- maior_do_naipe (quemjoga, trunfo.naipe)

      se não
         rodada _04_vez3 <- menor_do_naipe (quemjoga, trunfo.naipe)
         participante[quemjoga].ttrunfo <- false

se não
   tercarta <- tem_naipe (quemjoga, naipe)

   se tercarta =  true
      rodada _04_vez3 <- maior_do_naipe (quemjoga, naipe)

   se não
      rodada _04_vez3 <- maior_carta (quemjoga)
      corta (quemjoga, naipe)


funcao rodada_59_vez0 (jogador,rodada,jogada)
---------------------------------------------

quemparceirocorta <- parceirocortaoutrosnao (quemjoga)

se participante [proximo(proximo(quemjoga))].ttrunfo = true

   se quemparceirocorta <> NULL
      rodada _59_vez0 <- maior_do_naipe (quemjoga, naipe)

   se não
      rodada _59_vez0 <- maior_carta (quemjoga)

se não
   rodada _59_vez0 <- menor_carta (quemjoga)



funcao procura_As (quemjoga)
----------------------------

posicao <- -1

para i <- 0 ate 9

   se jogador [quemjoga].carta [i].letra =  as e
   jogador [quemjoga].carta [i].naipe <> trunfo.naipe e
   jogador [quemjoga].carta [i].usada = false
      posicao <- i
      i <- 10

procura_As <- posicao


funcao parceirocortaoutrosnao (quemJoga)
---------------------------------------

cnaipe <- NULL
parceiro <- proximo(proximo(quemjoga))
tem <- 0

para i <- 0 ate 3

   se participante [paeceiro].corte[i]<>NULL
      naipetemp <- participante [parceiro].corte [i]
      tem <- 1

      para j <- 0 ate 3

         se (participante [proximo(parceiro)].corte [j] = naipetemp) ou
         (participante [proximo(quemjoga)].corte [j] = naipetemp)
            tem <- 0
            j <- 4

      se tem = 1
         tem <- 0

         para j <- 0  ate 9

            se (jogador [quemjoga].carta [j].naipe = naipetemp) e
            (jogador [quemjoga].carta [j].usada = false)
               i <- 4
               tem <-  1

se tem = 1
   cartanaipe <- naipetemp

parceirocoteoutrosnao <- cartanaipe


funcao maior_do_naipe (quemjoga, naipe)
---------------------------------------

para i <- 0 ate 9

   se (jogador [quemjoga].carta [i].naipe = naipe) e
   (jogador [quemjoga].carta[i].usada = false)
      pos <- i

maior_do_naipe <- pos


funcao menor_do_naipe (quemjoga, naipe)
---------------------------------------

para i <- 0 ate 9

   se (jogador [quemjoga].carta [i].naipe = naipe) e
   (jogador [quemjoga].carta[i].usada = false)
      pos <- i
      i <- 10

menor_do_naipe <- pos


funcao tem_naipe (quemjoga, naipe)
----------------------------------

result <- false

para i <- 0 ate 9

   se (jogador [quemjoga].carta [i].naipe = naipe) e
   (jogador [quemjoga].carta[i].usada = false)
      result <- true
      i <- 10

tem_naipe <- result


funcao maior_carta (quemjoga)
-----------------------------


para i <- 0 ate 9

   se jogador [quemjoga].carta[i].usada = false
      pos <- i
      i <- 10

para i <- 0 ate 9

   se (jogador [quemjoga].carta[i].usada = false) e
   (jogador [quemjoga].carta [i].letra > jogador [quemjoga].carta[pos].letra)
   e (jogador [quemjoga].carta[i].naipe <> trunfo.naipe)
      pos <- i


maior_carta <- pos


funcao menor_carta (quemjoga)
-----------------------------


para i <- 0 ate 9

   se jogador [quemjoga].carta[i].usada = false
      pos <- i
      i <- 10

para i <- 0 ate 9

   se (jogador [quemjoga].carta[i].usada = false) e
   (jogador [quemjoga].carta [i].letra < jogador [quemjoga].carta[pos].letra)
   e (jogador [quemjoga].carta[i].naipe <> trunfo.naipe)
      pos <- i


menor_carta <- pos


procedimento corta (quemjoga, naipe)
------------------------------------

para i <- 0 ate  3

   se participante [quemjoga].corta [i] <> NULL

      se participante [quemjoga].corta [i] = naipe
         i <- 4

   se não
      participante [quemjoga].corta [i] <- naipe



funcao naipe_jogada (rodada)
----------------------------

para i <- 0 ate 3
   se (mesa_de_carta [rodada].carta [i].naipe = NULL) e
   (mesa_de_carta [rodada].carta [proximo(i)].naipe <> NULL)
      naipetemp <- mesa_de_carta [rodada].carta [proximo(i)].naipe
      i <- 4

naipe_jogsda <- naipetemp



funcao quem_faz (rodada, naipe)
-------------------------------

para i <- 0 ate 3

   se (mesa_de_carta [rodada].carta [i].naipe = naipe
       cartatemp <- mesa_de_carta [rodada].carta [i]
       fazendo <- i

para i <- 0 ate 3

   se (mesa_de_carta [rodada].carta [i].naipe = trunfo.naipe

      se (cartatemp.naipe <> trunfo.naipe) ou ((cartatemp.naipe = trunfo.naipe) e
      (mesa_de_carta [rodada].carta [i].letra > cartatemp.letra)))
          cartatemp <- mesa_de_carta [rodada].carta [i]
          fazendo <- i

   se não se (mesa_de_carta [rodada].carta [i].naipe = naipe

      se (cartatemp.naipe <> trunfo.naipe) e
      (mesa_de_carta [rodada].carta [i].letra > cartatemp.letra)
          cartatemp <- mesa_de_carta [rodada].carta [i]
          fazendo <- i


quem_faz <- fazendo

funcao se_carta_faz (quemjoga, carta, rodada)
---------------------------------------------

faz <- false
cont <- 0

se jogador [quemjoga].carta [carta].letra = as
   tmaior <- 0

se não se jogador [quemjoga].carta [carta].letra = sete
   tmaior <- 1

se não se jogador [quemjoga].carta [carta].letra = rei
   tmaior <- 2

se não se jogador [quemjoga].carta [carta].letra = valete
   tmaior <- 3

se não se jogador [quemjoga].carta [carta].letra = dama
   tmaior <- 4

se não se jogador [quemjoga].carta [carta].letra = seis
   tmaior <- 5

se não se jogador [quemjoga].carta [carta].letra = cinco
   tmaior <- 6

se não se jogador [quemjoga].carta [carta].letra = quatro
   tmaior <- 7

se não se jogador [quemjoga].carta [carta].letra = tres
   tmaior <- 8

se não se jogador [quemjoga].carta [carta].letra = dois
   tmaior <- 9


para i <- 0 ate rodada

   para j <- 0 ate 3

      se (jogador [quemjoga].carta [carta].naipe = mesa_de_carta [i].carta [j].naipe) e
      (jogador [quemjoga].carta [carta].letra < mesa_de_carta [i].carta [j].letra)
         cont <- cont + 1

se cont = tmaior
   faz <- true


se_carta_faz <- faz


funcao proximo_corta (quemjoga, naipe)
---------------------------------------

corta <- false

for i <- 0  ate 3

   se participante [proximo (quemjoga)].corte [i] = naipe
      corta <- true
      i <- 4

proximo_corta <- corta