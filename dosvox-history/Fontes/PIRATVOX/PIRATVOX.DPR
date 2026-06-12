{********************************************
*  PIRATE ISLAND                            *
*  ORIGINALLY IN BASIC BY DAVID MENY - 1995 *
*  TRANSLATED INTO PASCAL BY ANTONIO BORGES *
*  THE DOSVOX PROJECT - UFRJ - 2001         *
*  CONTRIBUTIONS FROM PAULO S. RAMOS - 2006 *
********************************************}

program pirate;
uses dvcrt, dvwin, winprocs;

var
    A: array [1..45, 1..6] of integer = (
        (0,0,0,0,0,6),            { ROOM 1 }
        (2,2,3,2,0,0),            { ROOM 2 }
        (2,3,4,0,6,0),            { ROOM 3 }
        (0,0,0,3,8,0),            { ROOM 4 }
        (0,5,10,9,0,0),           { ROOM 5 }
        (0,0,12,11,1,3),          { ROOM 6 }
        (0,17,0,0,0,0),           { ROOM 7 }
        (0,0,0,0,0,4),            { ROOM 8 }
        (5,10,13,9,0,0),          { ROOM 9 }
        (5,19,10,9,0,0),          { ROOM 10 }
        (6,15,12,0,0,0),          { ROOM 11 }
        (6,16,0,11,0,0),          { ROOM 12 }
        (9,0,0,18,0,0),           { ROOM 13 }
        (0,19,14,20,0,0),         { ROOM 14 }
        (0,0,0,0,0,0),            { ROOM 15 }
        (12,0,17,15,0,0),         { ROOM 16 }
        (7,22,18,16,0,0),         { ROOM 17 }
        (13,0,0,17,0,0),          { ROOM 18 }
        (14,18,19,10,0,0),        { ROOM 19 }
        (0,0,21,14,0,0),          { ROOM 20 }
        (0,0,0,20,0,0),           { ROOM 21 }
        (17,39,43,43,43,43),      { ROOM 22 }
        (0,0,0,0,21,0),           { ROOM 23 }
        (0,0,29,28,0,0),          { ROOM 24 }
        (0,29,0,0,0,0),           { ROOM 25 }
        (0,0,0,0,0,0),            { ROOM 26 }
        (0,31,0,0,0,0),           { ROOM 27 }
        (24,32,29,0,0,0),         { ROOM 28 }
        (0,33,24,28,0,0),         { ROOM 29 }
        (0,0,31,0,0,0),           { ROOM 30 }
        (27,37,0,30,33,0),        { ROOM 31 }
        (28,38,33,0,0,0),         { ROOM 32 }
        (29,39,0,32,0,31),        { ROOM 33 }
        (0,0,0,0,0,32),           { ROOM 34 }
        (0,0,0,0,0,33),           { ROOM 35 }
        (0,40,37,0,0,0),          { ROOM 36 }
        (31,41,0,36,39,0),        { ROOM 37 }
        (32,42,39,0,0,0),         { ROOM 38 }
        (33,0,0,38,0,37),         { ROOM 39 }
        (36,0,0,0,0,0),           { ROOM 40 }
        (37,0,0,0,0,0),           { ROOM 41 }
        (38,0,0,0,0,0),           { ROOM 42 }
        (0,0,0,0,0,0),            { ROOM 43 }
        (0,0,11,0,0,45),          { ROOM 44 }
        (0,0,0,0,44,0)            { ROOM 45 }
    );

const
    O1_: array [1..14] of string = (
        'PICARETA', 'CAPITÃO', 'CHAVE', 'ALHO',
        'LIVRO',    'ESPADA',  'BAÚ',   'COZINHEIRO',
        'MOEDA',    'BANDEJA', 'CAIXA', 'BAIONETA',
        'GRADE',    'SACO'
    );

    O2_: array [1..14] of string = (
        'Existe uma picareta velha aqui.',
        'O capitão do navio está aqui.',
        'Há uma chave brilhante próxima a você.',
        'Há um dente de alho próximo de você.',

        'Há um livro encadernado aqui.',
        'Existe uma espada afiada aqui.',
        'Existe um baú velho de pirata aqui.',
        'O cozinheiro do navio está aqui, cozinhando um guisado.',

        'Existe uma moeda espanhola aqui.',
        'Existe uma bandeja aqui completa de comida descartada.',
        'Próximo de você, há caixa pequena.',
        'Há uma baioneta aqui.',

        'Há uma grade de metal aqui.',
        'Existe uma bolsa de moedas de prata aqui.'
    );


    IN_: array [1..14] of string = (
        'uma picareta',
        '',
        'uma chave',
        'um dente de alho',

        'um livro',
        'uma espada afiada',
        '',
        '',

        'uma moeda de ouro',
        'uma bandeja',
        'uma caixa',
        'uma baioneta',

        '',
        'uma bolsa de moedas de prata'
    );

    RO_: array [1..45] of string =  (
        'Precipício alto', 'Floresta tropical', 'Floresta tropical', 'Caminho pequeno', 'Floresta espessa ', 'Precipício próximo ',
        'Rocha', 'Em cima de uma árvore', 'Floresta espessa', 'Floresta espessa', 'Enseada interior', 'Prado ',
        'Floresta espessa ', 'Pântano ', 'Areia movediça ', 'Caminho da praia ', 'Praia com areia', 'Pântano ', 'Pântano ',
        'Caverna escura', 'Caverna de morcegos', 'Enseada rasa', 'Caverna secreta', 'Timão',
        'Camarote do capitão', 'Sua cabine', 'Corredor', 'Tombadilho de Abordagem', 'Tombadilho de abordagem',
        'Cabine da tripulação', 'Corredor', 'Tombadilho do meio', 'Tombadilho do meio', 'Vigia da gávea', 'Vigia da gávea',
        'Refeitório', 'Corredor', 'Tombadilho de estibordo', 'Tombadilho de estibordo', 'Galera', 'Corredor',
        'Biblioteca do navio', 'Debaixo d''água', 'Parte superior da baía', 'Parte inferior da baía'
    );

var
    TR: array [1..14] of integer;

    RO: integer;
    SCORE: integer;
    F1, F2, F3, F4: integer;
    START: integer;
    MV: integer;
    dead: boolean;
    needsDescribing: boolean;

    A_, B_, C_: string;

    FLAG1,     FLAG2,    FLAG3,    FLAG4,    FLAG5,
    FLAG6,     FLAG7,    FLAG8,    FLAG9,    FLAG10,
    FLAG11,    FLAG12,   FLAG13,   FLAG14,   FLAG15,
    FLAG40,    FLAG55,   FLAG50,   FLAG60,   FLAG70,
    FLAG95,    FLAG96,   FLAG97,   FLAG98,   FLAG99,   FLAG100,FLAG101: integer;

procedure INITIALIZE;
begin
    RO := 26;
    SCORE := 0;
    F3 := 45;
    F4 := 29;
    MV := 0;
    dead := false;
    needsDescribing := true;

    TR[1]  := 35;    TR[2]  := 25;   TR[3]  := 8;   TR[4] := 40;
    TR[5]  := 255;   TR[6]  := 255;  TR[7]  := 23;  TR[8] := 40;
    TR[9]  := 255;   TR[10] := 36;   TR[11] := 45;  TR[12] := 255;
    TR[13] := 255;   TR[14] := 255;

    FLAG1  := 0;    FLAG2  := 0;   FLAG3  := 0;   FLAG4  := 0;   FLAG5   := 0;
    FLAG6  := 0;    FLAG7  := 0;   FLAG8  := 0;   FLAG9  := 0;   FLAG10 := 0;
    FLAG11 := 0;    FLAG12 := 0;   FLAG13 := 0;   FLAG14 := 0;   FLAG15 := 0;
    FLAG40 := 0;    FLAG55 := 0;   FLAG50 := 0;   FLAG60 := 0;   FLAG70  := 0;
    FLAG95 := 0;    FLAG96 := 0;   FLAG97 := 0;   FLAG99 := 0;   FLAG100 := 0;
end;

procedure COLOR (a, b: byte);
begin
    textAttr := (b shl 4) or a;
end;

procedure eliminaConectores (var C_: string);
begin
    if pos ('PARA ', C_) = 1 then delete (C_, 1, 5);
    if pos ('COM ',  C_) = 1 then delete (C_, 1, 4);
    if pos ('ATÉ ' , C_) = 1 then delete (C_, 1, 4);
    if pos ('UMA ' , C_) = 1 then delete (C_, 1, 4);
    if pos ('UM '  , C_) = 1 then delete (C_, 1, 3);
    if pos ('NO '  , C_) = 1 then delete (C_, 1, 3);
    if pos ('NA '  , C_) = 1 then delete (C_, 1, 3);
    if pos ('DO '  , C_) = 1 then delete (C_, 1, 3);
    if pos ('DA '  , C_) = 1 then delete (C_, 1, 3);
    if pos ('O '   , C_) = 1 then delete (C_, 1, 2);
    if pos ('A '   , C_) = 1 then delete (C_, 1, 2);
end;

procedure showScore;
begin
    COLOR (0, 7);
    gotoxy (1, 25);
    clreol;
    gotoxy (50, 25);
    sintWrite ('Pontuação: ');
    sintWriteint (SCORE);
    COLOR (7, 0);
    writeln;

    sintWrite ('Do máximo de 200 pontos, você conseguiu ');
    sintWriteInt (SCORE);
    sintWriteln (' pontos.');

    sintWrite ('Isso dá a você uma qualificação de ');

    IF SCORE=0     THEN SintWriteln ('Clandestino no navio.')
    else
    IF SCORE <  50 THEN sintWriteln ('Menino de Tombadilho.')
    else
    IF SCORE < 100 THEN sintWriteln ('Homem do Mar.')
    else
    IF SCORE < 150 THEN sintWriteln ('Bucaneiro.')
    ELSE
                        sintWriteln ('Capitão do Mar.');
end;

procedure captain_dialog;
begin
    writeln;
    sintWriteln ('O capitão olha para você então diz');
    sintWriteln ('"Bem, qual é a longitude de Ilha do Pirata? "');
    sintReadint (F1);
    sintWriteln ('OK, agora qual é a latitude?');
    sintReadint (F2);

    sintWriteln ('"É melhor estar certo ou lamentará ter acordado esta manhã! Agora vá embora."');

    START := 1;
    RO := 29;

    IF (F1 = F4) AND (F2 = F3) THEN
        begin
            FLAG98 := 1;
            writeln;
        end
    else
       FLAG98 := 0;
end;

procedure PRINT_ROOM_DESCRIPTION;
label newPlace;
begin
newPlace:
     COLOR (0, 7);
     gotoxy (1, 25);
     clreol;
     gotoxy (50, 25);
     sintWriteln (RO_[RO]);

     gotoxy (50, 25);
     sintWrite ('Score: ');
     sintWriteInt (SCORE);
     COLOR (7, 0);
     writeln;

    IF (RO = 21) AND (FLAG101>=1) THEN
                begin
                     IF TR[4] <> 200 THEN
                         begin
                             sintWriteln ('Os morcegos vêem você e atacam.');
                             sintWriteln ('Você recebe muitas mordidas de morcego e lentamente... lentamente... lentamente morre. ');
                             sintWriteln ('Você morreu. Muito ruim.');
                             dead := true;
                         end
                     else
                         sintWriteln ('Os morcegos, sentindo o odor do seu alho, ficam longe lá atrás.')
                end;

    IF (RO =25) AND (FLAG101>=1) THEN
    BEGIN
                     captain_dialog;
                     goto newPlace;
                 end;


    IF (RO = 43) AND (FLAG101>=1) THEN
                  begin
                      sintWriteln ('Você está debaixo da água. Você está afundando na areia macia.......');
                      sintWriteln ('Você morreu. Muito ruim.');
                      dead := true;
                  end;

    IF (RO = 15) AND (FLAG101>=1) THEN
                 begin
                     sintWriteln ('Você está em pé, ou quase em pé, em uma grande lagoa de areia movediça.');
                     sintWriteln ('Você é lentamente...lentamente...lentamente...afundando.');
                     sintWriteln ('Você morreu. Muito ruim.');
                     dead := true;
                 end;

     IF (RO <=46 ) AND (FLAG101=0) THEN
          begin
              case RO of
              1: { ROOM 1  }
                  begin
                      sintWriteln ('Você está no topo de um precipício alto mirando as águas azuis do oceano.');
                      sintWriteln ('Um caminho conduz para baixo. A terra está úmida aqui.');
                  end;

              2, 3: { ROOM 2 AND 3 }
                      sintWriteln ('Você está em uma grande floresta tropical.');

              4: { ROOM 4 }
                  begin
                      sintWriteln ('Você está em um caminho pequeno que conduz para fora de uma grande');
                      sintWriteln ('floresta tropical em direção a oeste.');
                      sintWriteln ('No centro do caminho há uma árvore grande.');
                  end;

              5, 9, 10, 13: { ROOM 5,9,10 AND 13 }
                  begin
                      sintWriteln ('Esta é uma floresta espessa coberta por muitas árvores, das quais nenhuma é escalável.');
                  end;

              6: { ROOM 6 }
                  begin
                      sintWriteln ('Você está de pé abaixo de um grande precipício.');
                      sintWriteln ('Um caminho prepara o caminho para o precipício');
                      sintWriteln ('enquanto um caminho leste/oeste se dirige para uma enseada e um prado.');
                  end;

              7: { ROOM 7 }
                  begin
                      sintWriteln ('Você é próximo a uma pedra grande que provavelmente esteve aqui ');
                      sintWriteln ('para muitas centenas de anos. Um pequeno caminho conduz ao sul.');
                  end;

              8:{ ROOM 8 }
                  begin
                      sintWriteln ('Você está em uma árvore grande acima de um pequeno caminho.');
                      sintWriteln ('As muitas folhas e galhos impedem você de ir mais para cima,');
                      sintWriteln ('enquanto um tronco grande se dirige para baixo.');
                  end;

             11: { ROOM 11 }
                 begin
                     sintWriteln ('Você está em pé na orla de uma enseada interior.');
                     sintWriteln ('As águas claras, azul do oceano vem do leste,');
                     sintWriteln ('enquanto um cheiro estranho vem do Sul.');
                     sintWriteln ('A terra é úmida aqui.');
                 end;

             12: { ROOM 12 }
                 begin
                     sintWriteln ('Você está de pé em um grande prado onde os pássaros cantam e cervos brincam.');
                     sintWriteln ('Parte da grama alta e luxuriante em baixo de você está ceivada,');
                     sintWriteln ('formando um caminho para o norte, sul e oeste.');
                 end;

             14, 18, 19: { ROOMs 14,18 and 19 }
                 begin
                     sintWriteln ('Este é um pântano muito escuro, onde as criaturas horrorosas se escondem ');
                     sintWriteln ('quando não estão à caça.');
                     sintWriteln ('Um caminho conduz para o oeste.');
                 end;

             15: { ROOM 15 }
                 begin
                     sintWriteln ('Você está em pé, ou quase em pé, em uma grande lagoa de areia movediça.');
                     sintWriteln ('Você é lentamente...lentamente...lentamente...afundando.');
                     sintWriteln ('Você morreu. Muito ruim.');
                     dead := true;
                 end;

             16: { ROOM 16 }
                 begin
                     sintWriteln ('Você está andando ao longo de um caminho na praia que cerca');
                     sintWriteln ('a parte sudoeste da ilha.');
                     sintWriteln ('Para o leste você pode ver uma praia, enquanto do oeste vem um cheiro estranho.');
                 end;

             17: { ROOM 17 }
                 begin
                     sintWriteln ('Esta é uma praia com areia saindo da água.');
                     sintWriteln ('As árvores de palma se enfileiram na orla e um caminho conduz para o oeste e para o leste.');
                     sintWriteln ('Outro caminho vai para o norte.');
                 end;

             20: { ROOM 20 }
                 begin
                     sintWriteln ('Você está de pé em uma caverna escura na beirada de um pântano.');
                     sintWriteln ('Do leste se escutam barulhos rechinantes (Talvez você não seja o único nesta ilha).');
                 end;

             21: { ROOM 21 }
                 begin
                     sintWriteln ('Você está em uma caverna com muitos morcegos. O chão é úmido aqui.');
                     IF TR[4] <> 200 THEN
                         begin
                             sintWriteln ('Os morcegos vêem você e atacam.');
                             sintWriteln ('Você tem muitas mordidas de morcego e lentamente... lentamente... lentamente morre.');
                             sintWriteln ('Você morreu. Muito ruim.');
                             dead := true;
                         end
                     else
                         sintWriteln ('Os morcegos, sentindo o odor do seu alho, ficam longe lá atrás.')
                 end;

             22: { ROOM 22 }
                 begin
                     sintWriteln ('Você está em uma enseada rasa, tão rasa que você pode ficar em pé.');
                     sintWriteln ('Para o norte existe uma praia com areia,');
                     sintWriteln ('enquanto para todas outras direções a água é profunda.');
                     FLAG40 := 1;
                 end;

             23: { ROOM 23 }
                 begin
                     sintWriteln ('Você está em uma caverna secreta embaixo de uma grade.');
                     sintWriteln ('Lá de cima você pode ouvir barulhos rechinantes.');
                 end;

             24: { ROOM 24  }
                 begin
                     sintWriteln ('Esta é o timão do navio onde o navio é dirigido.');
                     sintWriteln ('Um marinheiro está aqui conduzindo o navio pela água azul do oceano.');
                 end;

             25: { ROOM 25 }
                 begin
                     sintWriteln ('Você está nos aposentos do capitão, um quarto grande com muitos equipamentos,');
                     sintWriteln ('inclusive uma bússola e relíquias velhas feitas de ouro.');
                     sintWriteln ('Existe aqui uma escrivaninha grande de madeira contendo informações ultra-secretas.');

                     captain_dialog;
                     goto newPlace;
                 end;

             26: { ROOM 26 }
                 begin
                     sintWriteln ('Você está em sua cabine, um quarto pequeno com pouco mobiliário.');
                     sintWriteln ('As únicas mobílias são uma cama e um pequeno armário com só uma gaveta.');
                     sintWriteln ('Uma porta de madeira grande está na parede a leste.');
                 end;

             27: { ROOM 27 }
                 sintWriteln ('Você está na extremidade norte de um corredor conduzindo de norte para sul.');

             28: { ROOM 28 }
                 begin
                     sintWriteln ('Você está na seção de abordagem do tombadilho do navio.');
                     sintWriteln ('Para o norte está o timão do navio.');
                     sintWriteln ('Também o tombadilho central está no Sul.');
                 end;

             29: { ROOM 29 }
                 begin
                     sintWriteln ('Você está no tombadilho de abordagem do navio.');
                     sintWriteln ('Para o oeste existe outro tombadilho de abordagem e para o Sul existe o tombadilho central.');
                     sintWriteln ('Para o leste existe um passadiço principal que conduz ao timão.');
                     sintWriteln ('e para o norte existe uma porta grande principal que leva aos aposentos do capitão.');
                 end;

             30: { ROOM 30 }
                 begin
                     sintWriteln ('Você está na parte de cabine da tripulação do navio.');
                     sintWriteln ('Existem muitos beliches e ferramentas aqui que pertencem a outras pessoas,');
                     sintWriteln ('logo não toque nelas.');
                 end;

             31: { ROOM 31 }
                 begin
                     sintWriteln ('Este é um corredor levando de norte para sul.');
                     sintWriteln ('Para o oeste está a cabine da tripulação enquanto para cima está o tombadilho central.');
                 end;

             32: { ROOM 32 }
                 begin
                     sintWriteln ('Você está no tombadilho central do navio.');
                     sintWriteln ('Um outro tombadilho central está no outro lado para o leste ');
                     sintWriteln ('enquanto os tombadilho de abordagem e estibordo do navio estão do outro lado para o norte e sul.');
                     sintWriteln ('Existe um mastro grande aqui com uma vigia de gávea em cima dele.');
                 end;

             33: { ROOM 33 }
                 begin
                     sintWriteln ('Você está em um dos dois tombadilhos centrais.');
                     sintWriteln ('Este tombadilho central tem uma escada principal até os tombadilhos abaixo.');
                     sintWriteln ('O de abordagem e o de estibordo estão do outro lado para o norte e sul');
                     sintWriteln ('enquanto um mastro grande está acima de você.');
                     sintWriteln ('No topo desse mastro, existe uma vigia de gávea.');
                 end;

             34, 35: { ROOM 34 and 35 }
                 begin
                     sintWriteln ('Você está na vigia da gávea, um lugar para observar a terra, tempestades e outros navios.');
                 end;

             36: { ROOM 36 }
                 begin
                     sintWriteln ('Você está no refeitório do navio');
                     sintWriteln ('onde todo dia tripulantes famintos são alimentados.');
                     sintWriteln ('Para o Sul está a galera e para o leste está um corredor.');
                 end;

             37: { ROOM 37 }
                 begin
                     sintWriteln ('Você está em um corredor que conduz do norte para sul.');
                     sintWriteln ('Para o oeste está o refeitório do navio.');
                 end;

             38: { ROOM 38 }
                 begin
                     sintWriteln ('Você está no tombadilho de estibordo do navio.');
                     sintWriteln ('Para o leste está outro tombadilho de estibordo,');
                     sintWriteln ('enquanto para o norte está um tombadilho central.');
                     sintWriteln ('Para o Sul está a biblioteca do navio.');
                 end;

             39: { ROOM 39 }
                 begin
                     sintWriteln ('Este é o tombadilho de estibordo do navio.');
                     sintWriteln ('Existe uma escada aqui, conduzindo até um corredor ');
                     sintWriteln ('e um tombadilho para o norte e para o oeste.');
                     writeln;

                     IF FLAG40 = 1 then
                         begin
                             sintWriteln ('Quando você volta para bordo do navio, o capitão saúda você.');
                             sintWriteln ('"Bem-vindo a bordo, matey!"');

                             if TR[9] = 200 THEN
                                 begin
                                     sintWriteln ('"Parabéns, você achou a moeda.');
                                     sintWriteln ('"Agora todos nós seremos ricos!"');
                                     SCORE := SCORE + 55;
                                 end
                             else
                                 begin
                                     sintWriteln ('"O que? Você não achou a moeda! Eu matarei você por isto!');
                                     sintWriteln ('O capitão então tira sua espada e mata você!');
                                 end;

                             dead := true;
                         end;
                 end;

              40: { ROOM 40 }
                  begin
                      sintWriteln ('Esta é a galera do navio onde a comida é preparada.');
                      sintWriteln ('Um fogão grande se apoia contra a parede sul e muitos ingredientes ');
                      sintWriteln ('aguardando ser colocados no guisado que o cozinheiro está fazendo.');
                  end;

              41: { ROOM 41 }
                  begin
                      sintWriteln ('Você está na extremidade sul de um corredor que se dirige de norte para sul.');
                  end;

              42: { ROOM 42 }
                  begin
                      sintWriteln ('Você está na biblioteca do navio com muitos livros enfileirados na parede.');
                      sintWriteln ('Um catálogo de cartões está aqui ');
                      sintWriteln ('e uma nota de referência do catálogo de cartões está alfinetada em cima do catálogo de cartão.');
                  end;

              43: { ROOM 43 }
                  begin
                      sintWriteln ('Você está debaixo da água. Você está afundando na areia macia.......');
                      sintWriteln ('Você morreu. Muito ruim.');
                      dead := true;
                  end;

              44: { ROOM 44 }
                  begin
                      sintWriteln ('Você está nadando sobre a água em uma enseada interior.');
                      sintWriteln ('Fora para o leste está a orla da enseada.');
                  end;

              45: { ROOM 45   }
                  begin
                      sintWriteln ('Você está na parte inferior de uma enseada.');
                      sintWriteln ('A areia aqui é firme, deste modo você não afunda.');
                  end;
              end;
          end;
end;

procedure PRINT_ROOM_CONTENTS;
var FLAG99: integer;
    I: integer;
begin
    FLAG99 := 0;
    FOR I := 1 TO 14 do
        begin
            IF TR[I] = RO THEN
                begin
                    sintWrite (O2_[I]);
                    IF FLAG99 = 1 THEN writeln;
                    FLAG99 := 1;
                end
        end;
end;

procedure LOOK_UNDER_JULIUS;
begin
    writeln;
    sintWriteln ('    Você examina o catálogo de cartão, ache um livro sobre Julius ');
    sintWriteln ('    o Pirata, vi pegá-lo nas prateleiras, e acha este trecho:');
    writeln;
    sintWriteln ('    Julius o Pirata era um grande pirata, conhecido para suas aventuras ousadas');
    sintWriteln ('    e que conquistou tesouros raros e valiosos. ');
    sintWriteln ('    Seu tesouro escondido mais famoso foi uma moeda de ouro espanhola,');
    sintWriteln ('    uma moeda original já que só havia sido cunhada uma em 1635. ');
    sintWriteln ('    Julius morreu antes de poder recuperar a moeda mas registrou os graus');
    sintWriteln ('    da ilha que a moeda famosa deveria estar, em seu livro de pirata,');
    sintWriteln ('    herdado por várias gerações de descendentes.');
    sintWriteln ('    O último herdeiro conhecido registrado do livro foi Humphry Goodfellow,');
    sintWriteln ('    que morreu em um incência em sua casa.');
    sintWriteln ('    O paradeiro do livro é desconhecido.');
    writeln;

    sintWriteln ('    Você lê em até você acha o último parágrafo, que você fica');
    sintWriteln ('    chocado pela seguinte observação:');
    writeln;
    sintWriteln ('    Julius o Pirata era um grande pirata, mas tinha um problema ');
    sintWriteln ('    com seu olho esquerdo, que o fez pôr as marcas 5 graus para oeste');
    sintWriteln ('    nos originais dos mapas de longitude e latitude.');
end;

procedure LOOK_UNDER_PIRATE_ISLAND;
begin
    writeln;
    sintWriteln ('    A Ilha do Pirata é uma das ilhas mais mais assustadoras de todo oceano.');
    sintWriteln ('    O nome da ilha dava frio na espinha de muitos jovens marinheiros.');
    sintWriteln ('    Os capitães mais valentes ficaram longe da ilha ');
    sintWriteln ('    só para ficar fora dos horrores que a superstição propala.');
    sintWriteln ('    As lendas também dizem que uma moeda de ouro espanhol valiosíssima');
    sintWriteln ('    está na Ilha do Pirata, mas até hoje ninguém sequer tentou achar a moeda.');
    sintWriteln ('    Entretanto, não existem registros todas as viagens!');
end;

procedure LOOK_UNDER_DAVID_MENY;
begin
    writeln;
    sintWriteln ('    David Meny é um dos maiores piratas dos sete mares!');
    sintWriteln ('    Ele fugiu de uma cela de prisão e achou a Moeda de Prata Espanhola,');
    sintWriteln ('    a segunda em valor perdendo para só a moeda de ouro famosa');
    sintWriteln ('    feita pelos Espanhóis. Ele continua a vagar o mundo afora');
    sintWriteln ('    à procura de aventura e intrigas.');
end;

procedure LOOK_UNDER_ANTONIO_BORGES;
begin
    writeln;
    sintWriteln ('    Antonio Borges era o Imediato de Julius o Pirata.');
    sintWriteln ('    Ele era a única pessoa a bordo que sabia escrever.');
    sintWriteln ('    Todos os registros tinham sido feitos por ele,');
    sintWriteln ('    inclusive a localização de todos os tesouros.');
    sintWriteln ('    Ele foi morto por Julius devido a uma intriga da tripulação.');
end;


function RESTART: boolean;
var c: char;
begin
    sintWriteln ('Você gostaria de começar de novo?');
    c := readkey;
    sintWriteln (c);
    if upcase (c) = 'N' then
        begin
            writeln;
            sintWriteln ('OK. Veja você da próxima vez na Ilha do Pirata.');
            delay (1000);
            restart := false;
        end
    else
        begin
            A[26, 3] := 0;
            A[27, 4] := 0;
            A[21, 6] := 0;
            A[23, 5] := 0;

            restart := true;
        end;

    clrscr;
end;

procedure INVENTORY;
var I: integer;
begin
    sintWriteln ('É isto que você está levando:');
    FOR I := 1 TO 14 do
        IF TR[I] = 200 THEN
            begin
                sintWriteln ('    ' + IN_[I]);
                FLAG1 := 1;
            end;

    IF FLAG1 <> 1 THEN
        sintWriteln ('    nada');
    FLAG1 := 0;
end;

procedure DIG;
var F_: string;
label dodig;
begin
    IF C_ <> '' THEN
        F_ := C_
    ELSE
        begin
            sintWriteln ('Com o que vai cavar? ');
            sintReadln (F_);
            F_ := maiuscAnsi (F_);
            eliminaConectores (F_);
        end;

    IF F_ <> 'PICARETA' THEN
        begin
            sintWriteln ('Você não pode usar isso para cavar.');
            exit;
        end;

    IF (TR[1]<>200) THEN
  BEGIN
  sintWriteln ('Você não possue uma picareta. ');
  exit;
  end;



    IF (RO=1) OR (RO=11) OR (RO=21) THEN
        goto dodig;

    IF RO > 23 THEN
          begin
              sintWriteln ('Se você cavar no navio, pode causar um vazamento.');
              exit;
          end;

    sintWriteln ('O chão é muito duro aqui.');
    exit;

dodig:
    IF RO=1 THEN
        begin
            sintWriteln ('Você cava no chão... Você bate em algo! É um caixão!');
            sintWriteln ('Quando você abre o caixão, um esqueleto salta para fora,');
            sintWriteln ('com uma faca estendida, apunhalando você!!');
            sintWriteln ('O caixão era uma armadilha!!');
            dead := true;
            exit;
        end;

    IF RO = 11 THEN
        begin
            sintWriteln ('Você cava mas você não acha nada.');
            exit;
        end;

    sintWriteln ('Ao cavar na terra úmida você acidentalmente encontra uma grade no chão!');
    TR[13] := 21;
end;

procedure KNOCK;
var F_: string;
begin
    IF C_ <> '' THEN
        F_ := C_
    ELSE
        begin
            sintWriteln ('Onde você quer bater? ');
            sintReadln (F_);
            F_ := maiuscAnsi (F_);
            eliminaConectores (F_);
        end;

    IF F_ <> 'PORTA' THEN
         begin
             sintWriteln ('Que atitude estranha!!!');
             exit;
         end;

    IF (RO <> 29) AND (RO <> 26) AND (RO <> 27) THEN
         begin
             sintWriteln ('Eu não vejo nenhuma porta aqui.');
             exit;
         end;


    IF (RO = 29) AND (FLAG12 = 0) THEN
         begin
             sintWriteln ('Você bate na porta e espera. Logo o capitão abre e permite que você entre.');
             FLAG12 := 1;
             writeln;
             RO := 25;
             needsDescribing := true;
         end;

    IF (RO = 29) AND (FLAG12 = 1) THEN
        begin
            sintWriteln ('Não há resposta.');
            exit;
        end;

    sintWriteln ('Nada acontece.');
end;

procedure SWIM;
begin
    IF (RO <> 11) AND (RO <> 44) AND (RO <> 45) AND (RO <> 22) THEN
        begin
            sintWriteln ('Você não pode nadar aqui!');
            exit;
        end;

    IF (RO = 44) OR (RO = 45) THEN
        begin
            sintWriteln ('Você nada ao redor por algum tempo e acaba voltando para onde você está agora.');
            exit;
        end;

    IF RO = 22 THEN
        begin
            sintWriteln ('A água é muito rasa para nadar aqui.');
            exit;
        end;

    sintWriteln ('Você nada para fora na baía...');
    RO := 44;
    needsDescribing := true;
end;

procedure GO;
begin
    C_ := copy (C_, 1, 1);
    IF (C_ = 'S') AND (RO = 39) AND (FLAG97 = 0) THEN
        begin
            sintWriteln ('Não acredito que você queira pular na água.');
            exit;
        end;

    IF ((C_='E') AND (RO=26) and (flag11=0)) or
       ((C_='N') AND (RO=29)) THEN
        begin
            sintWriteln ('A porta está fechada. ');
            EXIT;
        end;

    IF ((C_ = 'N') AND (A[RO,1] = 0)) OR
       ((C_ = 'S') AND (A[RO,2] = 0)) OR
       ((C_ = 'E') AND (A[RO,3] = 0)) OR
       ((C_ = 'W') AND (A[RO,4] = 0)) OR
       ((C_ = 'U') AND (A[RO,5] = 0)) OR
       ((C_ = 'D') AND (A[RO,6] = 0)) THEN
        begin
            sintWriteln ('Impossível ir nesta direção. ');
            exit;
        end;

    IF C_ = 'N' THEN RO := A[RO,1];
    IF C_ = 'S' THEN RO := A[RO,2];
    IF C_ = 'E' THEN RO := A[RO,3];
    IF C_ = 'W' THEN RO := A[RO,4];
    IF C_ = 'U' THEN RO := A[RO,5];
    IF C_ = 'D' THEN RO := A[RO,6];

    IF (RO = 22) AND (FLAG2 = 0) THEN
        begin
            SCORE := SCORE+20;
            FLAG2 := 1;
        end;
    IF (RO = 23) AND (FLAG3 = 0) THEN
          begin
              SCORE := SCORE+15;
              FLAG3 := 1;
          end;

     needsDescribing := true;
end;

procedure GET;
var OBJ, I: integer;
begin
    IF (C_='') THEN
        begin
            sintWriteln ('Pegar o que? ');
            exit;
        end;
    IF (C_='BAÚ') AND (RO=23) THEN
         begin
             sintWriteln ('O baú é muito grande e pesado para você levar.');
             exit;
         end;

    IF (C_='CAPITÃO') AND (RO=25) THEN
        begin
            sintWriteln ('O capitão se esquiva quando você o tenta erguer.');
            sintWriteln ('"Eh, você é algum tipo de tarado?"');
            exit;
        end;

    IF (C_='COZINHEIRO') AND (RO=40) THEN
        begin
            sintWriteln ('Os cozinheiro segura sua mão. "Não agora, alguém poderia nos ver."');
            exit;
        end;

    IF (C_='GUISADO') AND (RO=40) THEN
        begin
            sintWriteln ('Os cozinheiro segura sua mão. "Espere o guisado ficar pronto."');
            exit;
        end;

    IF (C_='ALHO') AND (FLAG98=0) THEN
        begin
            sintWriteln ('"Ninguém vai estragar o meu guisado."');
            sintWriteln ('O cozinheiro retira-se uma faca e corta sua garganta.');
            sintWriteln ('Ao morrer, você ouve o murmúrio de cozinheiro, "Isso vai ensiná-lo para sempre."');
            dead := true;
            exit;
        end;

    IF (C_='GRADE') AND (RO = 21) AND (TR[13] = 21) THEN
        begin
            sintWriteln ('A grade está bem presa.');
            exit;
        end;

    FLAG7 := 0;
    FLAG8 := 0;
    OBJ := 0;
    FOR I := 1 TO 14 DO
        IF TR[I] = 200 THEN FLAG7 := FLAG7+1;
    IF FLAG7 > 6 THEN
        begin
            sintWriteln  ('Você não pode levar nada mais.');
            exit;
        end;

    FOR I := 1 TO 12 DO
        IF TR[I] = RO THEN FLAG8 := 1;

    IF FLAG8 = 0 THEN
         begin
             sintWriteln ('Não a nada assim por aqui. ');
             exit;
         end;

    FOR I := 1 TO 14 DO
        IF (C_ = O1_[I]) AND (TR[I]=RO) THEN OBJ := I;

    IF OBJ=0 THEN
        begin
            sintWriteln ('Eu não vejo nada aqui.');
            exit;
        end;

    TR[OBJ] := 200;
    sintWriteln ('Ok.');
    IF (TR[1]=200) AND (FLAG9=0) THEN
         begin
             SCORE := SCORE+15;
             FLAG9 := 1;
         end;
    IF (TR[12]=200) AND (FLAG10=0) THEN
         begin
             SCORE := SCORE+35;
             FLAG10:=1;
         end;
    IF (TR[9]=200) AND (FLAG55=0) THEN
         begin
             SCORE := SCORE+60;
             FLAG55 := 1
         end;
end;

procedure DROP;
var I, OBJ: integer;
begin
    IF (C_='') THEN
        begin
            sintWriteln ('Soltar o que?');
            exit;
        end;

     OBJ := 0;
     FOR I := 1 TO 14 DO
         IF (C_=O1_[I]) and (TR[I]=200) THEN OBJ := I;

     IF OBJ = 0 THEN
         begin
             sintWriteln ('Você não tem isto!');
             exit;
         end;

     sintWriteln ('Ok.');
     TR[OBJ] := RO;
end;

procedure OPEN_THINGS;
begin
    IF C_='' THEN
        begin
            sintWriteln ('Abrir o que?');
            exit;
        end;

    IF (C_<>'GAVETA') AND (C_<>'CAIXA') AND (C_<>'BAÚ') AND (C_<>'PORTA') THEN
        begin
            sintWriteln ('Não tem nada assim por aqui.');
            exit;
        end;

    IF (C_='GAVETA') AND (RO<>26) THEN
        begin
            sintWriteln ('Eu não vejo nenhuma gaveta aqui.');
            exit;
        end;

    IF (C_='GAVETA') AND (RO=26) AND (FLAG4=1) THEN
        begin
            sintWriteln ('A gaveta já está aberta.');
            exit;
        end;

    IF (C_='GAVETA') AND (FLAG4=0) AND (RO=26) THEN
        begin
            sintWriteln ('A gaveta está agora aberta. Dentro de você vê seu livro de pirata e sua espada.');
            TR[5] := RO;
            TR[6] := RO;
            FLAG4 := 1;
            exit;
        end;

    IF C_='CAIXA' THEN
        begin
            IF TR[11]<>200 THEN
                begin
                    sintWriteln ('Você nem mesmo tem uma caixa.');
                    exit;
                end;

            IF FLAG5=0 THEN
                begin
                    sintWriteln ('OK, a caixa está agora aberta. Você acha uma baioneta dentro.');
                    TR[12] := RO;
                    FLAG5 := 1;
                    exit;
                end
            ELSE
                begin
                    sintWriteln ('A caixa já está aberta.');
                    exit;
                end;
        end;

    IF C_='BAÚ' then
        begin
            if RO<>23 THEN
                begin
                    sintWriteln ('Eu não vejo o baú aqui.');
                    exit;
                end;
            IF FLAG70=0 THEN
                begin
                    sintWriteln ('Você deve destrancar o baú.');
                    exit;
                end
            else
                begin
                    sintWriteln ('O baú já está aberto.');
                    exit;
                end;
        end;

    IF C_='PORTA' THEN
        begin
            if (RO<>26) AND (RO<>29) THEN
                begin
                    sintWriteln ('Não existe nenhuma porta aqui.');
                    exit;
                end;

            IF RO=26 then
                begin
                    IF FLAG11=0 THEN
                        begin
                            sintWriteln ('A porta se abre mostrando uma passagem para o leste.');
                            A[26,3] := 27;
                            A[27,4] := 26;
                            FLAG11 := 1;
                        end
                    else
                        sintWriteln ('A porta já está aberta.');
                    exit;
                end;

            IF RO=29 THEN
                begin
                    sintWriteln ('A porta está trancada. ');
                    exit;
                end;
        end;
end;

procedure CONFIG;
begin
    IF C_='' THEN
        begin
            sintWriteln ('Você não informou a opção de config a ativar ou desativar.');
            exit;
          end;

    IF (C_='-ENTROUR') then
        begin
            if FLAG101=0 then
                sintWriteln ('Este config já está desativado. ')
            else
                FLAG101:=1;
            exit;
        end;

    IF (C_='+ENTROUR') then
        begin
            if FLAG101=1 then
                sintWriteln ('Este config já está ativado. ')
            else
                FLAG101:=0;
            exit;
        end;
    END;

procedure UNLOCK;
var F_: string;
label unlockChest;
begin
    IF C_='' THEN
        begin
            sintWriteln ('Destrancar o que?');
            exit;
        end;

    IF (C_<>'PORTA') AND (C_<>'BAÚ') AND (C_<>'GRADE') AND (C_<>'CAIXA') THEN
        begin
            sintWriteln ('Eu não vou destrancar nada aqui. ');
            exit;
        end;

    IF (C_='PORTA') or (C_='CAIXA') THEN
        begin
            sintWriteln ('Você não precisa destrancar isto!');
            exit;
        end;

    sintWriteln ('Com o que?');
    sintReadln (F_);
    F_ := maiuscAnsi (F_);
    eliminaConectores (F_);

    IF C_='BAÚ' THEN  goto UnlockChest;

    IF F_='CHAVE' THEN
        begin
            sintWriteln ('A chave não se encaixa na grade.');
            exit;
        end;

    IF F_<>'PICARETA' THEN
        begin
            sintWriteln ('Você não conseguirá destrancar a grade com isso! Está muito enferrujada.');
            exit;
        end;

    IF FLAG60=1 THEN
        begin
            sintWriteln ('A grade já está destrancada!');
            exit;
        end;

     sintWriteln ('A grade está agora destrancada e aberta!');
     sintWriteln ('A grade revela uma passagem descendente.');
     A[21,6] := 23;
     A[23,5] := 21;
     FLAG60 := 1;
     exit;

unlockChest:
    IF F_='PICARETA' THEN
        begin
            sintWriteln ('A baioneta não se entra na fechadura do baú.');
            exit;
        end;

    IF F_<>'CHAVE' THEN
        begin
            sintWriteln ( 'Você não pode usar isso para destrancar o baú!');
            exit;
        end;

    IF FLAG70=1 THEN
        begin
            sintWriteln ( 'O baú já está destrancado!');
            exit;
        end;

    sintWriteln ('O baú está agora destrancado e aberto!');
    sintWriteln ('O baú revela um enorme moeda de ouro espanhola!');
    FLAG70 := 1;
    TR[9] := 23;
end;

procedure BUY;
var F_: string;
begin
    IF C_='' THEN
        begin
            sintWriteln ('Comprar o que? ');
            exit;
        end;

    IF C_<>'ALHO' THEN
        begin
            sintWriteln ('O que você quer realmente não pode ser comprado!');
            exit;
        end;

    IF FLAG50=1 THEN
        begin
            sintWriteln ('Mas você já comprou alho!');
            exit;
        end;

    IF (RO<>40) AND (TR[4]<>200) THEN
        begin
            sintWriteln ('Eu não vejo nenhum alho aqui.');
            exit;
        end;

    sintWriteln ('Com o quê vai pagar?');
    sintReadln (F_);
    F_ := maiuscAnsi (F_);
    eliminaConectores (F_);

    IF  (F_<>'SACO') AND (F_<>'PRATA') THEN
        begin
            sintWriteln ('"Você é um bobalhão!');
            sintWriteln ('Pensou que eu iria aceitar menos que prata por meu alho!"');
            sintWriteln ('Por isso você vai ser decapitado!');
            dead := true;
            exit;
        end;

    IF (TR[14] <> 200) THEN
    BEGIN
    sintWriteln ('"Você quis me enganar, você não tem bolsa de prata nem uma!" ');
    sintWriteln ('O cozinheiro pega uma faca e corta sua garganta. ');
    sintWriteln ('No fim de sua vida você escuta uma vós distante dizer: "Isso te ensinará para sempre a nunca enganar cozinheiros." ');
            dead := true;
            exit;
        end;

    sintWriteln ('O cozinheiro considera cuidadosamente e em tão diz: ');
    sintWriteln ('"Bem, acho que é um bom negócio" ');
    sintWriteln ('Emtão o cozinheiro te entrega o dente de alho e pega sua bolsa de prata. ');
    TR[4] :=200;
    TR[14] := 255;
    FLAG50 := 1;
end;

procedure CLIMB;
begin
    IF (C_<>'MASTRO') AND (C_<>'ESCADA') THEN
        begin
            sintWriteln ('Você não pode subir nisto!');
            exit;
        end;

    IF C_ = 'MASTRO' then
        begin
            if RO=33 THEN
                begin
                    sintWriteln ('Você sobe o mastro... Logo você está na vigia da gávea.');
                    RO := 35;
                    needsDescribing := true;
                    exit;
                end;

            IF RO=32 THEN
                begin
                    sintWriteln ('Você sobe o mastro... Logo você está na vigia da gávea.');
                    RO := 34;
                    needsDescribing := true;
                    exit;
                end;

            sintWriteln ('Eu não posso ver nenhum mastro aqui.');
            exit;
        end;

    IF C_='ESCADA' THEN
        begin
            IF RO=39 THEN
                sintWriteln ('Se você quer descer a escada então diga.')
            ELSE
                sintWriteln ('Eu não vejo nenhuma escada aqui.');
            exit;
        end;
end;

procedure READ_THING;
label readNote;
begin
    IF TR[5]<>200 THEN
        begin
            sintWriteln ('Você não está levando nenhum livro!');
            exit;
        end;

    IF (C_ <> '') AND (C_<>'LIVRO') AND (C_<>'NOTA') THEN
        begin
            sintWriteln ('Você não pode ler isto!');
            exit;
        end;

    IF C_='NOTA' THEN  goto readNote;

    writeln;
    sintWriteln ('     Isto é o livro sobre piratas de Julius o Pirata.');
    sintWriteln ('     Incluídos são muitas informações sobre outros piratas, navios e tesouros.');
    sintWriteln ('     Você folheia rapidamente o livro até que você ache uma entrada grande ');
    sintWriteln ('     em uma moeda espanhola antiga no valor de milhares de dólares');
    sintWriteln ('     e localizada em uma ilha perto daqui.');
    sintWriteln ('     A latitude é 45 graus e a longitude é 24 graus.');
    writeln;
    sintWriteln ('     Você nota que na parte inferior da última página ');
    sintWriteln ('     existe algo mais escrito:');
    writeln;
    sintWriteln ('     Para outras referências sobre Julius o Pirata, procure por Julius');
    sintWriteln ('     num catálogo de cartões que se encontra na biblioteca de navio.');
    exit;

readNote:
    IF RO<>42 THEN
        begin
            sintWriteln ('Você não acha nenhuma nota aqui.');
            exit;
        end;

    writeln;
    sintWriteln ('     Para achar um livro entre os muitos livros de nossa maravilhosa biblioteca,');
    sintWriteln ('     basta procurar pelo assunto e então vai achar o livro.');
    sintWriteln ('     Eu espero que os livros entreterão você e alargarão seus horizontes ');
    sintWriteln ('     e não deixe de pô-los de volta na estante, ou então!!!');
    writeln;
    sintWriteln ('                                        -Jonny, o Capitão');
end;

procedure look;
begin
    IF RO <> 42 THEN
        begin
            sintWriteln ('Você não pode achar mais informações sobre isto aqui.');
            sintWriteln ('Tente a biblioteca do navio, está aberta 24 horas por dia!');
            exit;
        end;

    IF A_ = 'PROCURAR JULIUS'         THEN  LOOK_UNDER_JULIUS
    else
    IF A_ = 'PROCURAR ILHA'           THEN  LOOK_UNDER_PIRATE_ISLAND
    else
    IF A_ = 'PROCURAR DAVID'          THEN  LOOK_UNDER_DAVID_MENY
    else
    IF A_ = 'PROCURAR ANTONIO'        THEN  LOOK_UNDER_ANTONIO_BORGES
    else
        begin
            sintWriteln ('Bem... Esta informações não está registrada aqui.');
            sintWriteln ('Talvez você deva procurar outras palavras-chave, por exemplo...');
            sintWriteln ('PROCURAR DAVID');
        end;
end;

procedure HELP;
begin
    clrscr;
    sintWriteln ('Muito bem, jovem pirata! Bons ventos o tragam!  Como o velho Moby Dick.');
    sintWriteln ('Seu grande avô - realmente grande - o nomeou. Bem, vamos aos negócios.');
    writeln;
    sintWriteln ('Você deve achar a localização (longitude e latitude) da amedrontadora');
    sintWriteln ('Ilha do pirata, explorá-la e trazer de volta a famosa moeda espanhola');
    sintWriteln ('que supostamente está lá.');
    writeln;
    sintWriteln ('Não tente enganar ninguém da minha tripulação ou então!...');
    sintWriteln ('Não tente especialmente me enganar!');
    sintWriteln ('É melhor você achar a moeda antes de você voltar ao meu navio,');
    sintWriteln ('ou então este alfanje será seu último desejo!');
    writeln;
    sintWriteln ('Agora você começará no meu navio "O Ninho da Águia"');
    sintWriteln ('e tem que primeiro localizar a longitude e latitude das ilhas');
    sintWriteln ('usando informações que devem buscará em algum lugar no meu navio.');
    writeln;
    sintWriteln ('Quando você alcançar a ilha - se você conseguir - você a explorará');
    sintWriteln ('até achar a moeda e então vai trazê-la para meu navio.');
    writeln;
    sintWriteln ('Tenha bom dia!');
    writeln;
    sintWriteln ('... aperte Enter ');
    readln;

    clrscr;
    sintWriteln ('** Comandos Importantes **');
    writeln;
    sintWriteln ('            Para andar, use os pontos cardeais - N, S, E, W');
    sintWriteln ('            Para cima e baixo, use C, B (ou U, D)');
    sintWriteln ('            Olhar            -  Para conhecer o lugar');
    sintWriteln ('            Pegar objeto     -  Para pegar um objeto');
    sintWriteln ('            Deixar objeto    -  Para largar um objeto');
    sintWriteln ('            Nadar            -  Para nadar');
    sintWriteln ('            Destrancar       -  Para destrancar um objeto');
    sintWriteln ('            Abrir            -  Para abrir algo');
    sintWriteln ('            Olhar            -  Mostra o lugar onde você está. ');
    sintWriteln ('            I ou Inventário  -  Para mostrar o que você está levando');
    writeln;
    sintWriteln ('Para receber as descrições de lugares resumidas digite: config +entrour');
    sintWriteln ('Para voltar a receber as descrições detalhadas digite:  config -entrour.');
    sintWriteln ('Isso é tudo, agora vamos ao que interessa.');
    writeln;
    sintWrite ('... aperte Enter ');
    readln;
    gotoxy (1, 25);
end;

var N, R: integer;

label playAgain, restarting, ask, again, error;

begin
    sintInic (0, '');
    sintFalaPont := false;

playAgain:
    clrscr;
    setWindowText (crtWindow, 'Ilha do pirata');

    INITIALIZE;

    gotoxy (1, 25);
    color (0, 7);
    writeln;
    sintWrite ('Ilha do pirata');
    writeln (' por David Meny.');
    writeln ('Copyright 1985, Menco, Inc.');
    writeln ('Tradução para Pascal por Antonio Borges - 2001.');
    writeln ('Projeto Dosvox, UFRJ.');
    write   ('Contribuições ao programa por Paulo Santos Ramos - 2006.');
    color (7, 0);
    writeln;
    writeln;

    sintBip;
    delay (2000);

    sintWriteln ('Em seu sono, você sonha com piratas corajosos que velejam através dos mares,');
    sintWriteln ('achando tesouros secretos escondidos em ilhas perigosas.');
    sintWriteln ('Você sonha com aventuras e lutas até a morte entre piratas');
    sintWriteln ('envolvendo estátuas de ouro e baús com moedas de ouro muito antigas.');
    sintWriteln ('Você sonha, sonha até o balanço do mar acordar você');
    sintWriteln ('a bordo do navio "O Ninho da Águia", um navio de pirata!');

    sintBip;
    writeln;
    writeln;
    writeln;
    writeln;
    writeln;
    writeln;

    repeat
        if needsDescribing then
            begin
                needsDescribing := false;
                PRINT_ROOM_DESCRIPTION;
                if dead then
                    goto restarting;
                PRINT_ROOM_CONTENTS;
            end;

        IF START <> 1 THEN goto ask;
        MV := MV + 1;
        IF MV <> 10   THEN goto ask;

        TR[2] := RO;
        sintWriteln ('O capitão caminha até você.');
        IF FLAG98 <> 1 THEN
            begin
                sintWriteln ('"Você é um idiota!! Nós temos velejado por dias e até agora não achamos a Ilha do Pirata."');
                sintWriteln ('"Eu não devia ter confiado em você, mesmo sendo meu neto."');
                sintWriteln ('O capitão então retira seu alfanje e decapita você."');
                goto restarting;
            end
        else
            begin
                sintWriteln ('Parabéns!! Nós viemos ter à praia da antiga Ilha do Pirata.');
                sintWriteln ('Agora desembarque pelo tombadilho de estibordo a leste.');
                sintWriteln ('O capitão então dá você uma bolsa de prata.');
                sintWriteln ('"Gaste isto com juízo. É seu pagamento SE você não voltar."');

                TR[2]   := 25;
                A[39,2] := 22;
                FLAG97  := 1;
                TR[14]  := 200;
            end;

ask:
        writeln;
        repeat
            write ('>');
            sintClek;
            sintReadln (A_);

            while (A_ <> '') and (A_[1] = ' ') do delete (A_, 1, 1);
            while (A_ <> '') and (A_[length(A_)] = ' ') do delete (A_, length (A_), 1);
            while pos ('  ', A_) <> 0 do
                delete (A_, pos ('  ', A_), 1);

            if A_ = '' then
                sintWriteln ('O quê?');
        until A_ <> '';

        A_ := maiuscAnsi (A_);

        N := pos (' ', A_);
        if N = 0 then
            begin
                B_ := A_;
                C_ := '';
            end
        else
            begin
                B_ := copy (A_, 1, N-1);
                C_ := copy (A_, N+1, 999);
            end;

        eliminaConectores (C_);

        IF (B_ = 'AJUDA') or (B_ = 'AJUDAR') or (B_ = 'HELP') THEN  HELP
        else
        if B_ = 'VOLTAR' then
            writeln ('Se você está perdido, eu também estou.')
        else
        if B_ = 'PROCURAR' then LOOK
        else
        IF (B_ = 'INVENTÁRIO') OR (B_ = 'I') THEN     INVENTORY
        else
        IF B_ = 'PONTOS' THEN   showScore
        else
        IF B_ = 'CAVAR' THEN   DIG
        else
        IF B_ = 'BATER' THEN   KNOCK
        else
        IF (B_ = 'ABANDONAR') OR (B_ = 'FIM') then     goto restarting
        else
        IF (B_ = 'OLHAR') THEN     needsDescribing := true
        else
        IF B_ = 'NADAR' THEN   SWIM
        else
        IF (B_ = 'DESCER') or (B_ = 'BAIXO') or (B_ = 'B') then
            begin
                C_ := 'D';  GO;
            end
        else
        IF (B_ = 'SUBIR') or (B_ = 'CIMA') or (B_ = 'C') then
            begin
                C_ := 'U';  GO;
            end
        else
        IF (B_ = 'N') or (B_ = 'S') or (B_ = 'E') or (B_ = 'W') OR
           (B_ = 'D') OR (B_ = 'U') then
            begin
                C_ := B_;   GO;
            end
        else   { aqui começam os transitivos }
        IF (B_ = 'IR') OR (B_ = 'VAI') OR (B_ =  'MOVER') OR
           (B_ =  'ANDAR') OR (B_ = 'CAMINHAR') THEN
            begin
                GO;
            end
        else
        IF (B_ = 'PEGAR') OR (B_ = 'TOMAR') THEN    GET
        else
        IF (B_ = 'DEIXAR') OR (B_ = 'LARGAR') OR (B_='SOLTAR') THEN    DROP
        else
        IF B_ = 'ABRIR' THEN OPEN_THINGS
    else
    IF (B_='CONFIG') OR (B_='CONFIGURAÇÃO') THEN CONFIG
        else
        IF (B_ = 'DESTRANCAR') or (B_ = 'REBENTAR') THEN UNLOCK
        else
        IF B_ = 'COMPRAR' THEN BUY
        else
        IF (B_ = 'SUBIR') OR (B_ = 'TREPAR') THEN CLIMB
        else
        IF B_ = 'LER' THEN READ_THING
        else
             begin
    error:
                sintWriteln ('Eu não conheço esta palavra.');
             end;

    until dead;

restarting:
    showScore;
    if RESTART then goto
        playAgain;

    sintFim;
    doneWinCrt;
end.
