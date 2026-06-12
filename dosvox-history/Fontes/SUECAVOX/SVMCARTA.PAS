{--------------------------------------------------------}
{    Programa SuecaVox
{    Controle da Série de Jogos
{--------------------------------------------------------}

unit svMcarta;
interface

uses
    dvcrt,svvars ,winprocs, wintypes;

procedure RedesenhaCartas (possi,quemD:integer);
procedure mostra_jogador (mjogador:integer);
procedure mostra_carta  (posx, posy, bmpcarta:integer);
procedure levanta_carta (vcarta:carta);

implementation

uses svcartas;

(***************************************************)
procedure mostra_carta (posx, posy, bmpCarta:integer);
(***************************************************)

var
   bm: hbitmap;
   dcTrab, dcTela: hDC;
   cartaReal:integer;

const
    tabCartas: array [0..41] of integer = (
        15,16,17,18,19,25,24,26,20,14,28,29,30,31,32,38,37,39,33,27,
        2,3,4,5,6,12,11,13,7,1,41,42,43,44,45,51,50,52,46,40,61,111
    );

begin

   dcTela := getDC (crtWindow);
   dcTrab := createCompatibleDC (dcTela);

   cartaReal:= tabCartas [bmpCarta];
   bm := LoadBitmap (hinstance, makeIntResource (cartaReal));

   selectObject (dcTrab, bm);
   if tabCartas [bmpCarta] <> 111 then
      bitBlt (dcTela,trunc (posx * Tela.X),trunc (posy * Tela.Y), 71, 96, dcTrab, 0, 0, srcCopy)
   else
      bitBlt (dcTela,trunc (posx * Tela.X),trunc (posy * Tela.Y), 138, 113, dcTrab, 0, 0, srcCopy);

   deleteDC (dcTrab);

   deleteObject (bm);

   releaseDc (crtWindow, dcTela);

end;

(******************************************)
procedure mostra_jogador (mjogador:integer);
(******************************************)
var i:integer;

begin
   for i := 0 to 9 do
      if not jogador[mjogador].cartas [i].usada then
         begin
            if mjogador = 0 then
               mostra_carta (120 + i * 15, 305-28, jogador [mjogador].cartas [i].bmp)
            else
            if mjogador = 1 then
               mostra_carta (10 ,80 + i * 15, 40)
            else
            if mjogador = 2 then
               mostra_carta (120 + i * 15, 23, 40)
            else
            if mjogador = 3 then
               mostra_carta (350, 80 + 15 * i, 40);
         end;

   if mjogador = 0 then
      gotoxy (25,24)
   else
   if mjogador = 1 then
      gotoxy (3,5)
   else
   if mjogador = 2 then
      gotoxy (25,1)
   else
   if mjogador = 3 then
      gotoxy (45,5);

   if mjogador <> 0 then
      write (jogador [mjogador].nome.nomeJogadores);
end;

(**************************************)
procedure levanta_carta (vcarta:carta);
(**************************************)
var i:integer;
begin
   for i := 0 to 9 do
      if not jogador[0].cartas [i].usada then
         begin
            if (jogador[0].cartas [i].vnaipe = vcarta.vnaipe) and
               (jogador[0].cartas [i].vletra = vcarta.vletra) then
                  mostra_carta (120 + i * 15, 290-28, jogador [0].cartas [i].bmp)
            else
                  mostra_carta (120 + i * 15, 305-28, jogador [0].cartas [i].bmp);
          end;

end;

(******************************************)
procedure RedesenhaCartas (possi, quemD:integer);
(******************************************)
var m: integer;
begin
   (* mostra o trunfo *)
   mostra_trunfo (quemD);

   (* mostra o logotipo *)
   mostra_carta (480,280,41);  {41 é a carta do logotipo}

   (* mostra as cartas dos jogadores *)
   for m := 0 to 3 do
      mostra_jogador (m);

   (* mostra as cartas jogadas *)
   for m := 0 to 3 do
       begin
          gotoxy (28,25);
          if (mesa_de_cartas[possi].cartasJogada[m].vnaipe <> NULL) then
              begin
                 if m = 0 then
                     mostra_carta (200, 170, mesa_de_cartas[possi].cartasJogada[m].bmp)
                 else if m = 1 then
                     mostra_carta (150, 160, mesa_de_cartas[possi].cartasJogada[m].bmp)
                 else if m = 2 then
                     mostra_carta (200, 130, mesa_de_cartas[possi].cartasJogada[m].bmp)
                 else
                     mostra_carta (250, 160, mesa_de_cartas[possi].cartasJogada[m].bmp);
              end;
       end;
end;

end.

