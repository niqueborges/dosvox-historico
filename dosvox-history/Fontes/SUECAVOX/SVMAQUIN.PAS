{--------------------------------------------------------}
{    Programa SuecaVox
{    Jogada da maquina
{--------------------------------------------------------}

unit svMaquin;


interface

uses  dvcrt, svVars,svEmbara, dvwin, svMensa;

procedure maquina_joga2 (jogadorm:integer; jogada:integer; rodada:integer; var cartajogada:carta);

implementation


(**************************************)
function qmaior (lletra:letra):integer;
(**************************************)
var tmaior :integer;

begin

   if lletra = as then
      tmaior := 0

   else
   if lletra = sete then
      tmaior := 1

   else
   if lletra = rei then
      tmaior := 2

   else
   if lletra = valete then
      tmaior := 3

   else
   if lletra = dama then
      tmaior := 4

   else
   if lletra = seis then
      tmaior := 5

   else
   if lletra = cinco then
      tmaior := 6

   else
   if lletra = quatro then
      tmaior := 7

   else
   if lletra = tres then
      tmaior := 8

   else
   if lletra = dois then
      tmaior := 9;

   qmaior := tmaior;
end;

(***********************************************)
function joga_trunfo (jjogador:integer):integer;
(***********************************************)
var i,cartaTemp,carta:integer;
label acheiTrunfo;

begin

   cartaTemp := 0;

   for i := 0 to 9 do
      begin
         if jogador [jjogador].cartas[9 - i].vnaipe = trunfo.vnaipe then
            begin
               carta := qmaior(jogador [jjogador].cartas[9 - i].vletra);
               if carta = cartaTemp then
                  cartaTemp := cartaTemp + 1
               else
                  goto acheiTrunfo;
            end;

      end;
acheiTrunfo:

   joga_trunfo := i;

end;

(********************************************************************************************)
function se_faz_agora2 (qjoga:integer; qnaipe:naipe; qcarta:integer; qrodada:integer):boolean;
(********************************************************************************************)
var farei:boolean;
        i:integer;

begin
   farei := TRUE;


   for i := 0 to 3 do
   begin
       if (jogador [qjoga].cartas [qcarta].vnaipe = qnaipe) then
       begin

          if ((mesa_de_cartas [qrodada].cartasJogada [i].vnaipe = qnaipe) and
             (mesa_de_cartas [qrodada].cartasJogada [i].vletra >
                 jogador [qjoga].cartas [qcarta].vletra))
                                or
             (mesa_de_cartas [qrodada].cartasJogada [i].vnaipe = trunfo.vnaipe) then
             farei := FALSE;

       end
       else
       if (jogador [qjoga].cartas [qcarta].vnaipe = trunfo.vnaipe) then
       begin
          if (mesa_de_cartas [qrodada].cartasJogada [i].vnaipe = trunfo.vnaipe) and
             (mesa_de_cartas [qrodada].cartasJogada [i].vletra >
                 jogador [qjoga].cartas [qcarta].vletra)  then
             farei := FALSE;

       end;
   end;

   se_faz_agora2 := farei;

end;

(*********************************************************)
function quem_faz2 (qrodada:integer; qnaipe:naipe):integer;
(*********************************************************)
var i,fazendo:integer;
    cartatemp:carta;
begin

  for i := 0 to 3 do
  begin

     if (mesa_de_cartas [qrodada].cartasJogada [i].vnaipe = qnaipe ) then
     begin
        cartatemp := mesa_de_cartas [qrodada].cartasJogada [i];
        fazendo := i;

     end;

  end;

  for i := 0 to 3 do
  begin

    if  (mesa_de_cartas [qrodada].cartasJogada [i].vnaipe = trunfo.vnaipe) then
    begin

       if (cartatemp.vnaipe <> trunfo.vnaipe) or ((cartatemp.vnaipe = trunfo.vnaipe) and
       (mesa_de_cartas [qrodada].cartasJogada [i].vletra > cartatemp.vletra)) then
       begin
           cartatemp := mesa_de_cartas [qrodada].cartasJogada [i];
           fazendo := i;

       end;
    end
    else
    if mesa_de_cartas [qrodada].cartasJogada [i].vnaipe = qnaipe then
    begin

       if (cartatemp.vnaipe <> trunfo.vnaipe) and
       (mesa_de_cartas [qrodada].cartasJogada [i].vletra > cartatemp.vletra) then
       begin
          cartatemp := mesa_de_cartas [qrodada].cartasJogada [i];
          fazendo := i;

       end;

    end;

  end;
  quem_faz2 := fazendo;

end;

(*************************************************************)
function menor_do_naipe2 (qjoga:integer; qnaipe:naipe):integer;
(*************************************************************)
var pos,i:integer;

label achouMenor;

begin

   for i := 0 to 9 do
   begin

      if (jogador [qjoga].cartas [i].vnaipe = qnaipe ) and
      (not jogador [qjoga].cartas [i].usada ) then
      begin
         pos := i;
         goto achouMenor;
      end;
   end;

achouMenor:

   menor_do_naipe2 := pos;

end;



(*******************************************)
function maior_carta2 (qjoga:integer):integer;
(*******************************************)
var pos,i:integer;

label achouCarta;

begin

   for i := 0 to 9 do
   begin

      if (not jogador [qjoga].cartas [i].usada ) then
      begin
         pos := i;
         goto achouCarta;
      end;

   end;

achouCarta:

   for i := 0 to 9 do
   begin

      if (not jogador [qjoga].cartas [i].usada ) and
      (jogador [qjoga].cartas [i].vletra > jogador [qjoga].cartas [pos].vletra)
      and (jogador [qjoga].cartas [i].vnaipe <> trunfo.vnaipe) then
         pos := i;

   end;

   maior_carta2 := pos;

end;

(*********************************************)
function naipe_jogada2 (qrodada:integer):naipe;
(*********************************************)
var  i:integer;
     naipetemp :naipe;

label acheiNaipe;

begin

   for i := 0 to 3 do
   begin

      if (mesa_de_cartas [qrodada].cartasJogada [i].vnaipe = NULL) and
      (mesa_de_cartas [qrodada].cartasJogada [proximo (i)].vnaipe <> NULL) then
      begin
         naipetemp := mesa_de_cartas [qrodada].cartasJogada [proximo (i)].vnaipe;
         goto acheiNaipe;
      end;

   end;

acheiNaipe:

   naipe_jogada2 := naipetemp;

end;


(*************************************************)
function carta_que_faz (ljogador:integer):integer;
(*************************************************)
var x,z,lcarta:integer;
label achouMaior;
label achouQueFaz;

begin
   lcarta := -1;

   for x := 0 to 9 do
      begin
         (* se a carta não foi usada *)
         if not jogador [ljogador].cartas [x].usada then
            begin
               for z := 0 to 9 do
                  begin

                     if jogador [ljogador].cartas [x].vnaipe <> trunfo.vnaipe then
                        begin
                           if ((jogador [proximo (ljogador)].cartas [z].vnaipe = jogador [ljogador].cartas [x].vnaipe) and
                           (jogador [proximo (ljogador)].cartas [z].vletra > jogador [ljogador].cartas [x].vletra))
                                                      or
                            (jogador [proximo (ljogador)].cartas [x].vnaipe = trunfo.vnaipe) then
                                if lcarta = -1 then
                                   goto achouMaior
                                else
                                   goto achouQueFaz;
                        end
                     else
                        if (jogador [proximo (ljogador)].cartas [z].vnaipe = trunfo.vnaipe ) and
                        (jogador [proximo (ljogador)].cartas [z].vletra > jogador [ljogador].cartas [x].vletra) then
                           if lcarta = -1 then
                              goto achouMaior
                           else
                              goto achouQueFaz;
                  end;

               for z := 0 to 9 do
                  begin

                     if jogador [ljogador].cartas [x].vnaipe <> trunfo.vnaipe then
                        begin
                           if ((jogador [proximo (proximo (proximo (ljogador)))].cartas [z].vnaipe
                                                         =
                                       jogador [ljogador].cartas [x].vnaipe)
                                                         and
                           (jogador [proximo (proximo (proximo (ljogador)))].cartas [z].vletra
                                                           >
                                            jogador [ljogador].cartas [x].vletra))
                                                      or
                           (jogador [proximo (proximo (proximo (ljogador)))].cartas [z].vnaipe = trunfo.vnaipe) then
                              if lcarta = -1 then
                                 goto achouMaior
                              else
                                 goto achouQueFaz;
                        end
                     else
                        begin
                           if  (jogador [proximo (proximo (proximo (ljogador)))].cartas [z].vnaipe = trunfo.vnaipe ) and
                           (jogador [proximo (proximo (proximo (ljogador)))].cartas [z].vletra
                                                  >
                                 jogador [ljogador].cartas [x].vletra) then
                              if lcarta = -1 then
                                 goto achouMaior
                              else
                                 goto achouQueFaz;
                        end;

                  end;
                  lcarta := x;
            end;
achouMaior:
      end;

achouQueFaz:

   carta_que_faz := lcarta;
end;


(*******************************************)
function menor_carta2 (qjoga:integer):integer;
(*******************************************)
var pos,i:integer;

label achouMenor;

begin

   for i := 0 to 9 do
   begin

      if (not jogador [qjoga].cartas [i].usada ) then
      begin
         pos := i;
         goto achouMenor;
      end;
   end;

achouMenor:

   for i := 0 to 9 do
   begin

      if (not jogador [qjoga].cartas [i].usada ) and
      (jogador [qjoga].cartas [i].vletra < jogador [qjoga].cartas [pos].vletra)
      and (jogador [qjoga].cartas [i].vnaipe <> trunfo.vnaipe) then
         pos := i;

   end;

   menor_carta2 := pos;

end;

(*************************************************************)
function maior_do_naipe2 (qjoga:integer; qnaipe:naipe):integer;
(*************************************************************)
var pos,i:integer;

begin

   for i := 0 to 9 do
   begin

      if (jogador [qjoga].cartas [i].vnaipe = qnaipe ) and
      (not jogador [qjoga].cartas [i].usada ) then
         pos := i;
   end;

   maior_do_naipe2 := pos;

end;

(********************************************************)
function tem_naipe2 (qjoga:integer; qnaipe:naipe):boolean;
(********************************************************)
var i:integer;
    result:boolean;

label achouNaipe;

begin

   result := FALSE;

   for i := 0 to 9 do
   begin

      if (jogador [qjoga].cartas [i].vnaipe = qnaipe ) and
      (not jogador [qjoga].cartas [i].usada ) then
       begin
         result := TRUE;
         goto achouNaipe;
       end;

   end;

achouNaipe:

   tem_naipe2 := result;

end;

(***************************************************************)
function adversarios_cortam (lnaipe:naipe; ljoga:integer):boolean;
(***************************************************************)
var l:integer;
    lcorte,lcorte1,lcorte2:boolean;

label achou_cortam;

begin

   lcorte := FALSE;
   lcorte1 := FALSE;
   lcorte2 := FALSE;

   (* verifica se tem alguem cortando o naipe *)
   for l := 0 to 9 do
      begin
         if (jogador [proximo (ljoga)].cartas [l].vnaipe = lnaipe) and
         (not jogador [proximo (ljoga)].cartas [l].usada)  then
             lcorte1 := TRUE;

          if (jogador [proximo (proximo (proximo (ljoga)))].cartas [l].vnaipe = lnaipe) and
         (not jogador [proximo (proximo (proximo (ljoga)))].cartas [l].usada)  then
             lcorte2 := TRUE;

      end;

   (* algun dos oponentes estiver cortando, verifica se tem trunfo *)
   if not lcorte1 then
      begin

         for l := 0 to 9 do
         begin
            if (jogador [proximo (ljoga)].cartas [l].vnaipe = trunfo.vnaipe) and
            (not jogador [proximo (ljoga)].cartas [l].usada)  then
               begin
                  lcorte := TRUE;
                  goto achou_cortam;
               end;
         end;
      end;

   if not lcorte2 then
      begin

         for l := 0 to 9 do
            begin
               if (jogador [proximo (proximo (proximo (ljoga)))].cartas [l].vnaipe = trunfo.vnaipe) and
              (not jogador [proximo (proximo (proximo (ljoga)))].cartas [l].usada)  then
                  begin
                     lcorte := TRUE;
                     goto achou_cortam;
                  end;

            end;
      end;

achou_cortam:

   adversarios_cortam := lcorte;

end;

(*******************************************)
function procura_As2 (qjoga:integer):integer;
(*******************************************)
var i,posicao:integer;
label achouAs;

begin
   posicao := -1;

   for i := 0 to 9 do
      begin

         if (jogador [qjoga].cartas [i].vletra = as) and
            (jogador [qjoga].cartas [i].vnaipe <> trunfo.vnaipe) and
            (not jogador [qjoga].cartas [i].usada)  then
            begin
               if not adversarios_cortam (jogador [qjoga].cartas [i].vnaipe,qjoga) then
                  begin
                     posicao := i;
                     goto achouAs;  (*  break *)
                  end;
            end;

      end;

achouAS:

   procura_As2 := posicao;

end;

(*************************************************************************************************)
function quem_vai_fazer (sjogador:integer; sjogada:integer; srodada:integer; snaipe:naipe):integer;
(*************************************************************************************************)

var z,jogadorTestado,squemfaz:integer;
    stercarta,sair:boolean;
    cartaTemp :carta;

begin

  (* verifica quem esta fazendo *)
   squemfaz := quem_faz2 (srodada, snaipe);

   (* compara a carta de quem esta fazendo com a de todos *)
   cartaTemp := mesa_de_cartas [srodada].cartasjogada [squemFaz];

   JogadorTestado := sjogador;
   sair := FALSE;
   repeat
      (*  verifica se tem o naipe da jogada *)
      stercarta := tem_naipe2(jogadorTestado, snaipe);

      if not stercarta then (* se não tem a carta *)
         begin
            (*  verifica se tem trunfo *)
            stercarta := tem_naipe2(jogadorTestado, trunfo.vnaipe);

            (* se tiver trunfo ele passa a fazer *)
            if stercarta then
               begin
                  squemfaz := jogadortestado;
                  snaipe := trunfo.vnaipe;
                  z := maior_do_naipe2 (jogadorTestado,trunfo.vnaipe);
                  cartaTemp := jogador [jogadorTestado].cartas [z];
               end;
         end
      else   (* se ele tem a carta do naipe *)
         begin
            for z := 0 to 9 do
               begin

                  if ( jogador [jogadorTestado].cartas [z].vnaipe = snaipe ) and
                     ( jogador [jogadorTestado].cartas [z].vletra > cartaTemp.vletra ) and
                     (not ( jogador [jogadorTestado].cartas [z].usada )) then
                     begin
                        squemfaz := jogadorTestado;
                        cartaTemp := jogador [jogadorTestado].cartas [z];
                     end;
               end;
         end;

      if sjogada = 1 then
         if jogadorTestado = proximo (proximo (sjogador)) then
            sair := TRUE;

      if sjogada = 2 then
          if jogadorTestado = proximo (sjogador) then
             sair := TRUE;

      jogadorTestado := proximo (jogadorTestado);

   until sair;

   quem_vai_fazer := squemfaz;

end;


(**************************************************)
function rodada_04_vez_02 (rjogador:integer):integer;
(**************************************************)
var tas,achou:integer;
    tcorte:boolean;
    pnaipe:naipe;

begin

   (* posicao da primeira carta AS se encontrar *)
   achou := procura_AS2 (rjogador);

   (* se encontrou um As *)
   if achou <> -1 then
      rodada_04_vez_02 := achou

   (* se nao encontrou *)
   else
      begin
         (* verifica se o parceiro tem AS e ninguem corta *)
         tas := procura_AS2 (proximo (proximo (rjogador)));
         if tas <> -1 then
            pnaipe := jogador [proximo (proximo (rjogador))].cartas [tas].vnaipe ;

         (* se tiver joga a maior daquele naipe *)
         if (tas <> -1) and (tem_naipe2 (rjogador, pnaipe)) then
            rodada_04_vez_02 := maior_do_naipe2 (rjogador,jogador[proximo (proximo (rjogador))].cartas [tas].vnaipe)

         else (* se não tiver *)
            begin
               (* procura uma carta que vai fazer a jogada *)
               achou := carta_que_faz (rjogador);

               (* se achou  joga a carta *)
               if achou <> -1 then
                  rodada_04_vez_02 := achou

               else   (* senão joga a menor que tiver *)
                  rodada_04_vez_02 := menor_carta2 (rjogador);
            end;
      end;

end;

(***************************************************************************************)
function rodada_04_vez_1_22 (rjogador:integer; rrodada:integer; rjogada:integer):integer;
(***************************************************************************************)
var   pnaipe:naipe;
      faz,faco,proximocorta,tercarta:boolean;
      quemTemMaior,w,carta,quemfaz:integer;

begin
   (*  verifica o naipe da jogada *)
   pnaipe := naipe_jogada2 (rrodada);

   (*  verifica se tem o naipe da jogada *)
   tercarta := tem_naipe2 (rjogador, pnaipe);

   (* verifica quem vai fazer a jogada *)
   quemfaz := quem_vai_fazer (rjogador,rjogada,rrodada,pnaipe);

   if tercarta then  (* se o jogador tiver carta do naipe *)
      begin

         (* quem vai fazer e o jogador ou o parceiro*)
         if (quemfaz = rjogador) or (quemfaz = proximo (proximo (rjogador))) then
            rodada_04_vez_1_22 := maior_do_naipe2 (rjogador,pnaipe)

         else
            rodada_04_vez_1_22 := menor_do_naipe2 (rjogador,pnaipe);

      end
   else  (* não tem carta do naipe *)
      begin
          (* quem vai fazer e o jogador ou o parceiro*)
         if quemfaz = proximo (proximo (rjogador)) then
            rodada_04_vez_1_22 := maior_carta2 (rjogador)

         else if quemfaz = rjogador then
            rodada_04_vez_1_22 := joga_trunfo (rjogador)
         else
            rodada_04_vez_1_22 := menor_carta2 (rjogador);
      end;

end;


(***********************************************************************************)
function rodada_04_vez_32 (rjogador:integer; rrodada:integer; rjogada:integer):integer;
(***********************************************************************************)
var carta,quemfaz :integer;
    pnaipe :naipe;
    tercarta,faco:boolean;

begin

   (*  verifica o naipe da jogada *)
   pnaipe := naipe_jogada2 (rrodada);

   (* verifica quem esta fazendo *)
   quemfaz := quem_faz2 (rrodada, pnaipe);

   (*  verifica se tem o naipe da jogada *)
   tercarta := tem_naipe2(rjogador, pnaipe);

   (* nao é o parceiro quem está fazendo *)
   if quemfaz <> proximo (proximo (rjogador)) then
      begin

         if tercarta then   (* tem carta *)
            begin
               carta := maior_do_naipe2 (rjogador, pnaipe);
               faco := se_faz_agora2 (rjogador,pnaipe,carta,rrodada);

               if faco then
                  rodada_04_vez_32 := carta
               else
                  rodada_04_vez_32 := menor_do_naipe2 (rjogador, pnaipe);
            end
         else  (* não tem carta *)
            begin
               tercarta := tem_naipe2(rjogador, trunfo.vnaipe);

               if tercarta then
                  begin
                     carta := maior_do_naipe2 (rjogador,trunfo.vnaipe);
                     faco := se_faz_agora2 (rjogador,trunfo.vnaipe,carta,rrodada);

                     if faco then
                        rodada_04_vez_32 := joga_trunfo (rjogador)
                     else
                        rodada_04_vez_32 := menor_carta2 (rjogador);
                  end
               else
                  rodada_04_vez_32 := menor_carta2 (rjogador);
            end;
      end
   else   (* o é o parceiro quem está fazendo *)
      begin

         if tercarta then
            rodada_04_vez_32 := maior_do_naipe2 (rjogador, pnaipe)
         else
            rodada_04_vez_32 := maior_carta2 (rjogador);

      end;

end;


(************************************************************************************************)
procedure maquina_joga2 (jogadorm:integer; jogada:integer; rodada:integer; var cartajogada:carta);
(************************************************************************************************)
var cartaajogar:integer;

begin

   case jogada of
       0:  (* heurística:   se primeiras jogadas tenta jogar um ás,
                            nas outras já tem outros macetes...*)

           cartaajogar := rodada_04_vez_02 (jogadorm);

    1, 2: (* heurística do segundo e terceiro: apóiam ou prejudicam o primeiro *)
           cartaajogar := rodada_04_vez_1_22 (jogadorm,rodada,jogada);

       3: (* o último já toma decisão mais acertada *)
           cartaajogar := rodada_04_vez_32 (jogadorm,rodada,jogada);
   end;

   cartajogada := jogador [jogadorm].cartas [cartaajogar];
   jogador [jogadorm].cartas [cartaajogar].usada := TRUE;

end;


end.