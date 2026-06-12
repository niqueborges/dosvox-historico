{--------------------------------------------------------}
{    Programa SuecaVox
{    Mostra resultado
{--------------------------------------------------------}

unit svResult;

interface

uses dvcrt, svvars, dvwin, svMensa, svCartas;

procedure mostra_pontuacao;
function conta_pontos (rodada_de_cartas:mesa;inicio:integer):integer;
procedure mostra_escore;
function verifica_maior_carta_jogada (cartas_jogadas:mesa;primeiro:integer):integer;

implementation


function verifica_maior_carta_jogada (cartas_jogadas:mesa;primeiro:integer):integer;
var maiorCarta:carta;
    i,venceu:integer;
begin
   (* guarda o valor da primeira carta jogada para comparacao *)
   maiorCarta := cartas_jogadas.cartasJogada[primeiro];
   venceu := primeiro;
   for i:= 0 to 3 do
   begin
      (* se achar uma carta maior a maior carta passa a ser essa*)
      if (maiorCarta.vnaipe = cartas_jogadas.cartasJogada[i].vnaipe) then
      begin
         if (maiorCarta.vletra < cartas_jogadas.cartasJogada[i].vletra) then
         begin
            venceu := i;
            maiorCarta := cartas_jogadas.cartasJogada[i];
         end;
      end
      (* se a carta for do mesmo naipe do tunfo a maior carta passa a ser essa*)
      else if (cartas_jogadas.cartasJogada[i].vnaipe = trunfo.vnaipe) then
      begin
            venceu := i;
            maiorCarta := cartas_jogadas.cartasJogada[i];
      end;
   end;
   (* retorna quem jogou a maior carta *)
   verifica_maior_carta_jogada := venceu;
end;


procedure pontos (venceu:integer;cartas_jogadas:mesa);
var pontos,i:integer;
begin
    pontos := 0;
    (* calcula o total de pontos jogados *)
    for i := 0 to 3 do
    begin
       pontos := pontos + cartas_jogadas.cartasJogada[i].vvalor;
    end;

    (* acumula os pontos no vencedor *)
    if ((venceu = 0) or (venceu = 2)) then
         pontos1 := pontos1 + pontos
    else
         pontos2 := pontos2 + pontos;

end;

function conta_pontos (rodada_de_cartas:mesa;inicio:integer):integer;
var vencedor:integer;
begin
   (* verifica quem jogou a maior carta *)
   vencedor := verifica_maior_carta_jogada (rodada_de_cartas,inicio);
   (* conta os pontos e acumula na dupla vencedora *)
   pontos (vencedor,rodada_de_cartas);
   (* retorna o vencedor *)
   conta_pontos := vencedor;
end;

procedure mostra_pontuacao;
var cpontos1,cpontos2:string;
begin
   if not(renuncia) then
      begin
      limpaJanela (1, 1, 50, 6);
      gotoxy (1, 1);

      (* se a dupla1 nao fizer pontos *)
      if (pontos1 = 0) then
      begin
         escore2 := 4;
         fala ('svadupla',0);    { A dupla }
         write (jogador[0].nome.nomeJogadores);
         sintSom (jogador[0].nome.som);
         fala ('sve', 0);
         write (jogador[2].nome.nomeJogadores);
         sintSom (jogador[2].nome.som);

         fala ('svband',1);      { perdeu de bandeira }
         fala ('svPprama',1);     { precisam praticar mais }
         if comEfeitos then delay (500);
      end
      (* se a dupla 2 nao fizer pontos *)
      else if (pontos2 = 0) then
      begin
         escore1 := 4;
         fala ('svadupla',0);   { a dupla }
         write (jogador[1].nome.nomeJogadores);
         sintSom (jogador[1].nome.som);
         fala ('sve', 0);
         write (jogador[2].nome.nomeJogadores);
         sintSom (jogador[3].nome.som);
         fala ('svband',0);    { perdeu de bandeira }
         if comEfeitos then delay (500);
      end

      else if (pontos1 > pontos2) then
      begin
          (* se a dupla 2 fizer menos de 30 pontos *)
          if (pontos2 < 30) then
             escore1 := escore1 + 2
          (* se ela perder, mas fizer mais de 30 pontos *)
          else
             escore1 := escore1 + 1;
      end

      else if (pontos1 < pontos2) then
      begin
          (* se a dupla 1 fizer menos de 30 pontos *)
          if (pontos1 < 30) then
             escore2 := escore2 + 2
          (* se ela perder, mas fizer mais de 30 pontos *)
          else
             escore2 := escore2 + 1;
      end
      (* se empatarem em pontos *)
      else
      begin
         escore1 := escore1 + 1;
         escore2 := escore2 + 1;
      end;

      (* imprime os pontos das duplas *)

      str ((pontos1)*2/2:3:0,cpontos1);
      fala ('svdupla',0);    { dupla }
      write (jogador[0].nome.nomeJogadores );
      sintSom (jogador[0].nome.som);
      fala ('sve', 0);
      write (jogador[2].nome.nomeJogadores + ' ' );
      sintsom (jogador[2].nome.som);
      sintwriteln (cpontos1);

      if comEfeitos then delay (200);

      str ((pontos2)*2/2:3:0,cpontos2);
      fala ('svdupla',0);
      write (jogador[1].nome.nomeJogadores);
      sintSom (jogador[1].nome.som);
      fala ('sve', 0);
      write (jogador[3].nome.nomeJogadores + ' ');
      sintSom (jogador[3].nome.som);
      sintwriteln (cpontos2);
      if comEfeitos then delay (2000);

      (* zera os pontos *)
      pontos1 := 0; pontos2 := 0;
   end;
end;

procedure mostra_escore;
var cescore1,cescore2:string;
begin
   gotoxy (58,2);
/////   textcolor (BLACK);
textcolor (WHITE);
   fala ('svescore',0);    { escore  }

   (* mostra os escores da dupla 1 *)

///// textcolor (RED);
textcolor (YELLOW);
   (* transforma 0 valor do escore em caracter *)
   gotoxy (60,3);
   str ((escore1)*2/2:1:0,cescore1);
   write (jogador[0].nome.nomeJogadores);
   sintSom (jogador[0].nome.som);
   gotoxy (60,4);
   fala ('sve', 0);
   write (jogador[2].nome.nomeJogadores + ' ');
   sintsom (jogador[2].nome.som);
   sintWrite (cescore1);


   (* mostra os escores da dupla 2 *)

   (* transforma o valor do escore em caracter *)
   gotoxy (60,5);
   str (escore2*2/2:1:0,cescore2);
   write (jogador[1].nome.nomeJogadores);
   sintSom (jogador[1].nome.som);
   gotoxy (60,6);
   fala ('sve', 0);
   write (jogador[3].nome.nomeJogadores + ' ');
   sintSom (jogador[3].nome.som);
   sintWrite (cescore2);
/////   textcolor (BLACK);
textColor (WHITE);
    if comEfeitos then delay (1000);
end;

end.
