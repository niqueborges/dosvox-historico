{--------------------------------------------------------}
{    Programa SuecaVox
{    Jogada da maquina
{--------------------------------------------------------}


unit svMaqjo;


interface

uses  dvcrt, svVars,svEmbara, dvwin, svMensa;

procedure maquina_joga (jogadorm:integer; jogada:integer; rodada:integer; var cartajogada:carta);
function rodada_04_vez_0 (rjogador:integer):integer;
function rodada_04_vez_1_2 (rjogador:integer; rrodada:integer; rjogada:integer):integer;
function rodada_04_vez_3 (rjogador:integer; rrodada:integer; rjogada:integer):integer;
function rodada_59_vez_0 (rjogador:integer; rrodada:integer; rjogada:integer):integer;
function procura_As (qjoga:integer):integer;
function parceiro_corta_outros_nao (qjoga:integer):naipe;
function menor_do_naipe (qjoga:integer; qnaipe:naipe):integer;
function maior_do_naipe (qjoga:integer; qnaipe:naipe):integer;
function menor_carta (qjoga:integer):integer;
function se_carta_faz (qjoga:integer; qcarta:integer; qrodada:integer):boolean;

function se_faz_agora (qjoga:integer; qnaipe:naipe; qcarta:integer; qrodada:integer):boolean;
function maior_carta (qjoga:integer):integer;
function naipe_jogada (qrodada:integer):naipe;
function tem_naipe (qjoga:integer; qnaipe:naipe):boolean;
procedure corta (qjoga:integer; qnaipe:naipe);
function quem_faz (qrodada:integer; qnaipe:naipe):integer;
function proximo_corta (qjoga:integer; qnaipe:naipe):boolean;

implementation

procedure maquina_joga (jogadorm:integer; jogada:integer; rodada:integer; var cartajogada:carta);
var cartaajogar:integer;

begin
   cartaajogar := -1;
   case jogada of
       0:  (* heurística:   se primeiras jogadas tenta jogar um ás,
                            nas outras já tem outros macetes...*)

            if (rodada >= 0) and (rodada <= 4) then
                cartaajogar := rodada_04_vez_0 (jogadorm)
            else
                cartaajogar := rodada_59_vez_0 (jogadorm,rodada,jogada);

    1, 2: (* heurística do segundo e terceiro: apóiam ou prejudicam o primeiro *)
           cartaajogar := rodada_04_vez_1_2 (jogadorm,rodada,jogada);

       3: (* o último já toma decisão mais acertada *)
           cartaajogar := rodada_04_vez_3 (jogadorm,rodada,jogada);
   end;

   cartajogada := jogador [jogadorm].cartas [cartaajogar];
   jogador [jogadorm].cartas [cartaajogar].usada := TRUE;

end;

(**************************************************)
function rodada_04_vez_0 (rjogador:integer):integer;
(**************************************************)
var achou:integer;
    quemparceirocorta:naipe;

begin

   (* posicao da primeira carta AS se encontrar *)
   achou := procura_AS (rjogador);

   (* se encontrou um As *)
   if achou <> -1 then
      rodada_04_vez_0 := achou

   (* se nao encontrou *)
   else
   begin
      (* se o parceiro está cortando algum naipe e os outros não *)

      quemparceirocorta := parceiro_corta_outros_nao (rjogador);

      if participante [proximo (proximo (rjogador))].ttrunfo  then
      begin

         if (quemparceirocorta <> NULL) and (quemparceirocorta <> trunfo.vnaipe) then
            rodada_04_vez_0 := maior_do_naipe (rjogador, quemparceirocorta)
         else
            rodada_04_vez_0 := menor_carta (rjogador);

      end
      else  (* o parceiro não tem trunfo *)
          rodada_04_vez_0 := menor_carta (rjogador);

   end;

end;

(***************************************************************************************)
function rodada_04_vez_1_2 (rjogador:integer; rrodada:integer; rjogada:integer):integer;
(***************************************************************************************)
var   pnaipe:naipe;
      faz,faco,proximocorta,tercarta:boolean;
      w,carta,quemfaz:integer;

begin
   carta := -1;

   (*  verifica o naipe da jogada *)
   pnaipe := naipe_jogada (rrodada);

   (*  verifica se tem o naipe da jogada *)
   tercarta := tem_naipe (rjogador, pnaipe);

   (* verifica quem esta fazendo *)
   quemfaz := quem_faz (rrodada, pnaipe);

   (* verifica se o proximo esta cortando *)
   proximocorta := proximo_corta (rjogador, pnaipe);

   if quemfaz <> proximo (proximo (rjogador)) then
   begin

      if tercarta then   (* se tem a carta do naipe *)
      begin

         carta := maior_do_naipe (rjogador, pnaipe);
         faco := se_carta_faz (rjogador, carta, rrodada);

         if faco then
         begin

            if not proximocorta then
               rodada_04_vez_1_2 := maior_do_naipe (rjogador, pnaipe)

            else if proximocorta and (not participante [proximo (rjogador)].ttrunfo)  then
               rodada_04_vez_1_2 := maior_do_naipe (rjogador, pnaipe)

            else
              rodada_04_vez_1_2 := menor_do_naipe (rjogador, pnaipe);

         end
         else
            rodada_04_vez_1_2 := menor_do_naipe (rjogador, pnaipe);

      end
      else  (* não tem a carta do naipe *)
      begin
         corta (rjogador, pnaipe);
         tercarta := tem_naipe (rjogador, trunfo.vnaipe);

         if tercarta  then
         begin
            carta := maior_do_naipe (rjogador, trunfo.vnaipe);
            faco := se_faz_agora (rjogador,trunfo.vnaipe,carta,rrodada);

            if faco then   (* ou seja, tem trunfo e faz *)
               rodada_04_vez_1_2 := maior_do_naipe (rjogador, trunfo.vnaipe)
            else    (* tem trunfo mas não faz *)
               rodada_04_vez_1_2 := menor_carta (rjogador);

         end
         else    (* não tem trunfo *)
         begin
            rodada_04_vez_1_2 := menor_carta (rjogador);
            participante [rjogador].ttrunfo := FALSE;
         end;
      end;

   end
   else   (* quem faz é o parceiro *)
   begin

      for w := 0 to 9 do
         if (jogador [proximo (proximo (rjogador))].cartas [w].vnaipe =
          mesa_de_cartas [rrodada].cartasjogada [proximo (proximo (rjogador))].vnaipe)
                                   and
          (jogador [proximo (proximo (rjogador))].cartas [w].vletra =
           mesa_de_cartas [rrodada].cartasjogada [proximo (proximo (rjogador))].vletra)   then
           carta := w;


      faz := se_faz_agora (proximo (proximo (rjogador)),pnaipe,carta,rrodada);

      if faz then
      begin
         if pnaipe <> trunfo.vnaipe then
         begin

            if not proximocorta then
            begin

               if tercarta then
                  rodada_04_vez_1_2 := maior_do_naipe (rjogador, pnaipe)
               else
               begin
                  rodada_04_vez_1_2 := maior_carta (rjogador);
                  corta (rjogador,pnaipe);
               end;
            end

            else if proximocorta and (not participante [proximo (rjogador)].ttrunfo)  then
            begin

               if tercarta then
                  rodada_04_vez_1_2 := maior_do_naipe (rjogador, pnaipe)
               else
               begin
                  rodada_04_vez_1_2 := maior_carta (rjogador);
                  corta (rjogador,pnaipe);
               end;
             end

            else
            begin
               if tercarta then
                  rodada_04_vez_1_2 := menor_do_naipe (rjogador, pnaipe)

               else
               begin
                  rodada_04_vez_1_2 := menor_carta (rjogador);
                  corta (rjogador,pnaipe);
               end;
            end;
         end
         else  (* o naipe é trunfo *)
         begin

           for w := 0 to 9 do
              if (jogador [proximo (proximo (rjogador))].cartas [w].vnaipe =
              mesa_de_cartas [rrodada].cartasjogada [proximo (proximo (rjogador))].vnaipe)
                                         and
                 (jogador [proximo (proximo (rjogador))].cartas [w].vletra =
              mesa_de_cartas [rrodada].cartasjogada [proximo (proximo (rjogador))].vletra)   then
                 carta := w;


           faco := se_faz_agora (proximo (proximo (rjogador)),trunfo.vnaipe,carta,rrodada);
           if faco then   (* se a carta do parceiro é a maior do jogo no momento *)
           begin

               if tercarta then
                  rodada_04_vez_1_2 := maior_do_naipe (rjogador, pnaipe)
               else
               begin
                  rodada_04_vez_1_2 := maior_carta (rjogador);
                  corta (rjogador,pnaipe);
               end;

           end
           else     (* se não for a maior do momento *)
           begin

               if tercarta then (* se tem a carta do naipe *)
               begin
                 carta := maior_do_naipe (rjogador, pnaipe);
                 faco := se_carta_faz (rjogador, carta, rrodada);

                 if faco then  (*  se tem a maior carta do jogo no momento *)
                    rodada_04_vez_1_2 := maior_do_naipe (rjogador, pnaipe)
                 else
                    rodada_04_vez_1_2 := menor_do_naipe (rjogador, pnaipe);
               end
               else (* se não tem carta do naipe *)
               begin
                  rodada_04_vez_1_2 := menor_carta (rjogador);
                  corta (rjogador,pnaipe);
               end;

           end;

         end;
      end
      else
      begin
         if tercarta then   (* se tem a carta do naipe *)
         begin

            carta := maior_do_naipe (rjogador, pnaipe);
            faco := se_carta_faz (rjogador, carta, rrodada);

            if faco then
            begin

               if not proximocorta then
                  rodada_04_vez_1_2 := maior_do_naipe (rjogador, pnaipe)

               else if proximocorta and (not participante [proximo (rjogador)].ttrunfo)  then
                  rodada_04_vez_1_2 := maior_do_naipe (rjogador, pnaipe)

               else
                  rodada_04_vez_1_2 := menor_do_naipe (rjogador, pnaipe);

            end
            else
               rodada_04_vez_1_2 := menor_do_naipe (rjogador, pnaipe);

         end
         else  (* não tem a carta do naipe *)
         begin
            corta (rjogador, pnaipe);
            tercarta := tem_naipe (rjogador, trunfo.vnaipe);

            if tercarta  then
            begin
               carta := maior_do_naipe (rjogador, trunfo.vnaipe);
               faco := se_faz_agora (rjogador,trunfo.vnaipe,carta,rrodada);

               if faco then   (* ou seja, tem trunfo e faz *)
                  rodada_04_vez_1_2 := maior_do_naipe (rjogador, trunfo.vnaipe)
               else    (* tem trunfo mas não faz *)
                  rodada_04_vez_1_2 := menor_carta (rjogador);

            end
            else    (* não tem trunfo *)
            begin
               rodada_04_vez_1_2 := menor_carta (rjogador);
               participante [rjogador].ttrunfo := FALSE;
            end;
         end;

      end;
   end;

end;


(***********************************************************************************)
function rodada_04_vez_3 (rjogador:integer; rrodada:integer; rjogada:integer):integer;
(***********************************************************************************)
var carta,quemfaz :integer;
    pnaipe :naipe;
    tercarta,faco:boolean;

begin

   (*  verifica o naipe da jogada *)
   pnaipe := naipe_jogada (rrodada);

   (* verifica quem esta fazendo *)
   quemfaz := quem_faz (rrodada, pnaipe);

   (*  verifica se tem o naipe da jogada *)
   tercarta := tem_naipe (rjogador, pnaipe);

   if quemfaz <> proximo (proximo (rjogador)) then
   begin

      if tercarta then
      begin
         carta := maior_do_naipe (rjogador, pnaipe);
         faco := se_faz_agora (rjogador,pnaipe,carta,rrodada);

         if faco then
            rodada_04_vez_3 := carta
         else
            rodada_04_vez_3 := menor_do_naipe (rjogador, pnaipe);
      end

      else  (* não tem carta *)
      begin
         corta (rjogador,pnaipe);
         tercarta := tem_naipe (rjogador, trunfo.vnaipe);

         if tercarta then
            rodada_04_vez_3 := maior_do_naipe (rjogador, trunfo.vnaipe)
         else
         begin
            rodada_04_vez_3 := menor_carta (rjogador);
            participante [rjogador].ttrunfo := FALSE;

         end;

      end;

   end
   else   (* o é o parceiro quem está fazendo *)
   begin

      if tercarta then
         rodada_04_vez_3 := maior_do_naipe (rjogador, pnaipe)
      else
      begin
         rodada_04_vez_3 := maior_carta (rjogador);
         corta (rjogador, pnaipe);
      end;

   end;

end;


(***********************************************************************************)
function rodada_59_vez_0 (rjogador:integer; rrodada:integer; rjogada:integer):integer;
(***********************************************************************************)
var quemparceirocorta :naipe;

begin
    (* verifica qual o naipe que o parceiro esta cortando *)
    quemparceirocorta := parceiro_corta_outros_nao (rjogador);

    if not participante [proximo (proximo (rjogador))].ttrunfo then
    begin
       if (quemparceirocorta <> NULL) and  (quemparceirocorta <> trunfo.vnaipe) then
          rodada_59_vez_0 := maior_do_naipe (rjogador, quemparceirocorta)
       else
          rodada_59_vez_0 := maior_carta (rjogador);
    end
    else
       rodada_59_vez_0 := menor_carta (rjogador);

end;


(*******************************************)
function procura_As (qjoga:integer):integer;
(*******************************************)
var i,posicao:integer;
label achouAs;

begin
   posicao := -1;

   for i := 0 to 9 do
   begin

      if (jogador [qjoga].cartas [i].vletra = ace) and
         (jogador [qjoga].cartas [i].vnaipe <> trunfo.vnaipe) and
         (not jogador [qjoga].cartas [i].usada)  then
      begin
         posicao := i;
         goto achouAs;  (*  break *)
      end;

   end;

achouAS:

   procura_As := posicao;

end;


(********************************************************)
function parceiro_corta_outros_nao (qjoga:integer):naipe;
(********************************************************)
var  naipetemp,cnaipe :naipe;
     tem,i,j, parceiro :integer;

label achouCorte,
      achouDoParceiro;

begin
   cnaipe := NULL;
   parceiro := proximo (proximo(qjoga));
   tem := 0;
   naipeTemp := NULL;

   for i := 0 to 3 do
   begin

      if participante [parceiro].corte [i] <> NULL then
      begin
         naipetemp := participante [parceiro].corte [i];
         tem := 1;

         for j := 0 to 3 do    { busca carta de corte }
         begin
            if (participante [proximo (parceiro)].corte [j] = naipetemp) or
               (participante [proximo (qjoga)   ].corte [j] = naipetemp) then
            begin
               tem := 0;
               goto achouCorte;
            end;
         end;

achouCorte:

         if tem = 1 then
         begin
            tem := 0;

            for j := 0 to 9 do     { busca se parceiro tem deste naipa }
               if (jogador [qjoga].cartas [j].vnaipe = naipetemp) and
                  (not jogador [qjoga].cartas [j].usada) then
               begin
                  tem := 1;
                  goto achouDoParceiro;
               end;

achouDoParceiro:

         end;
         { a variavel "tem" indica se ele tinha ou nao tinha }

      end;
   end;

   if tem = 1 then
      cnaipe := naipetemp;

   parceiro_corta_outros_nao := cnaipe;

end;


(*************************************************************)
function maior_do_naipe (qjoga:integer; qnaipe:naipe):integer;
(*************************************************************)
var pos,i:integer;

begin
   pos := -1;
   for i := 0 to 9 do
   begin

      if (jogador [qjoga].cartas [i].vnaipe = qnaipe ) and
      (not jogador [qjoga].cartas [i].usada ) then
         pos := i;
   end;

   maior_do_naipe := pos;
end;


(*************************************************************)
function menor_do_naipe (qjoga:integer; qnaipe:naipe):integer;
(*************************************************************)
var pos,i:integer;

label achouMenor;

begin
   pos := -1;
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

   menor_do_naipe := pos;

end;



(*************************************************************)
function tem_naipe (qjoga:integer; qnaipe:naipe):boolean;
(*************************************************************)
var i:integer;
    resulta: boolean;

label achouNaipe;

begin

   resulta := FALSE;

   for i := 0 to 9 do
   begin

      if (jogador [qjoga].cartas [i].vnaipe = qnaipe ) and
      (not jogador [qjoga].cartas [i].usada ) then
       begin
         resulta := TRUE;
         goto achouNaipe;
       end;

   end;

achouNaipe:

   tem_naipe := resulta;

end;


(*******************************************)
function maior_carta (qjoga:integer):integer;
(*******************************************)
var pos,i:integer;

label achouCarta;

begin
   pos := -1;
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

   maior_carta := pos;

end;

(*******************************************)
function menor_carta (qjoga:integer):integer;
(*******************************************)
var pos,i:integer;

label achouMenor;

begin
   pos := -1;

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

   menor_carta := pos;

end;


(********************************************)
procedure corta (qjoga:integer; qnaipe:naipe);
(********************************************)
var i:integer;

label JaCortei;

begin
   for i:= 0 to 3 do
   begin
      if participante [qjoga].corte [i] <> NULL then
      begin

         if participante [qjoga].corte [i] = qnaipe then
            goto JaCortei;
      end
      else
         participante [qjoga].corte [i] := qnaipe;
   end;

JaCortei:

end;

(*********************************************)
function naipe_jogada (qrodada:integer):naipe;
(*********************************************)
var  i:integer;
     naipetemp :naipe;

label acheiNaipe;

begin
   naipeTemp := NULL;

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

   naipe_jogada := naipetemp;

end;


(*********************************************************)
function quem_faz (qrodada:integer; qnaipe:naipe):integer;
(*********************************************************)
var i,fazendo:integer;
    cartatemp:carta;
begin
  fazendo := -1;

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
  quem_faz := fazendo;

end;

(******************************************************************************)
function se_carta_faz (qjoga:integer; qcarta:integer; qrodada:integer):boolean;
(******************************************************************************)
var faz :boolean;
    cont,i,j,tmaior :integer;

begin
   faz := FALSE;
   cont := 0;
   tmaior := -1;

   if jogador [qjoga].cartas [qcarta].vletra = ace then
      tmaior := 0

   else
   if jogador [qjoga].cartas [qcarta].vletra = sete then
      tmaior := 1

   else
   if jogador [qjoga].cartas [qcarta].vletra = rei then
      tmaior := 2

   else
   if jogador [qjoga].cartas [qcarta].vletra = valete then
      tmaior := 3

   else
   if jogador [qjoga].cartas [qcarta].vletra = dama then
      tmaior := 4

   else
   if jogador [qjoga].cartas [qcarta].vletra = seis then
      tmaior := 5

   else
   if jogador [qjoga].cartas [qcarta].vletra = cinco then
      tmaior := 6

   else
   if jogador [qjoga].cartas [qcarta].vletra = quatro then
      tmaior := 7

   else
   if jogador [qjoga].cartas [qcarta].vletra = tres then
      tmaior := 8

   else
   if jogador [qjoga].cartas [qcarta].vletra = dois then
      tmaior := 9;


   for i := 0 to (qrodada - 1) do
   begin

      for j := 0 to 3 do
      begin

         if (jogador [qjoga].cartas [qcarta].vnaipe = mesa_de_cartas [i].cartasJogada [j].vnaipe) and
         (jogador [qjoga].cartas [qcarta].vletra < mesa_de_cartas [i].cartasJogada [j].vletra) then
             cont := cont + 1;

      end;

   end;

   if cont = tmaior then
      faz := TRUE;

   se_carta_faz := faz;

end;


(************************************************************)
function proximo_corta (qjoga:integer; qnaipe:naipe):boolean;
(************************************************************)
var corta :boolean;
    i :integer;

label achouCorte;

begin
   corta := FALSE;

   for i := 0 to 3 do
   begin

      if participante [proximo (qjoga)].corte [i] = qnaipe then
      begin
         corta := TRUE;
         goto achouCorte;

      end;

   end;

achouCorte:

   proximo_corta := corta;

end;


(*******************************************************************************************)
function se_faz_agora (qjoga:integer; qnaipe:naipe; qcarta:integer; qrodada:integer):boolean;
(*******************************************************************************************)
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

   se_faz_agora := farei;

end;


end.