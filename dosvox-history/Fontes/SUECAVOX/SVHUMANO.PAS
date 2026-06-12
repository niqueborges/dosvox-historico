{--------------------------------------------------------}
{    Programa SuecaVox
{    Jogada humana
{--------------------------------------------------------}

unit svHumano;

interface

uses dvcrt, dvHora,svMcarta, svvars, svcartas, svresult, dvwin, svMensa;

procedure humano_joga (pos:integer;poscar:integer; var jogada:carta; distribui:integer);

implementation

const
   ESC      = #27;
   ENTER    = #13;
   ESQUERDA = #75;
   DIREITA  = #77;
   F1       = #59;
   F2       = #60;
   F3       = #61;
   F4       = #62;

function seleciona_carta (opcaosc:char; posicaosc:integer):integer;
var
   salva:integer;
begin
   salva := posicaosc;

   if (opcaosc = DIREITA) then
   begin
      posicaosc := posicaosc + 1;
      if posicaosc > 9 then
      begin
         posicaosc := salva;
         sintBip;
      end;
      (* procura a primeira carta a direita ate o fim *)
      while (jogador[0].cartas[posicaosc].usada) do
      begin
         posicaosc := posicaosc + 1;
         if posicaosc > 9 then
         begin
            posicaosc := salva;
            sintBip;
        end;
      end;
   end
   else
   begin
      posicaosc := posicaosc - 1;
      if posicaosc < 0  then
      begin
         posicaosc := salva;
         sintBip;
      end;
      (* procura a primeira carta a direita ate o fim *)
      while (jogador[0].cartas[posicaosc].usada) do
      begin
         posicaosc := posicaosc - 1;
         if posicaosc < 0  then
         begin
            posicaosc := salva;
            sintBip;
         end;
      end;
   end;
   seleciona_carta := posicaosc;
end;

procedure ver_cartas_da_mesa (posi:integer);
var i:integer;
begin
   for i := 0 to 3 do
   begin
      limpaJanela (1,25,58,25);
      gotoxy (28, 25);
      if (mesa_de_cartas[posi].cartasJogada[i].vnaipe <> NULL) then
      begin
         write (jogador [i].nome.nomeJogadores);
         sintSom (jogador [i].nome.som);
         fala ('svjogou',0);

         if i = 0 then
             mostra_carta (200, 170, mesa_de_cartas[posi].cartasJogada[i].bmp)
         else if i = 1 then
             mostra_carta (150, 160, mesa_de_cartas[posi].cartasJogada[i].bmp)
         else if i = 2 then
             mostra_carta (200, 130, mesa_de_cartas[posi].cartasJogada[i].bmp)
         else
             mostra_carta (250, 160, mesa_de_cartas[posi].cartasJogada[i].bmp);

         fala_carta (mesa_de_cartas[posi].cartasJogada[i]);
      end;
   end;
   limpaJanela (1,25,48,25);
   gotoxy (25,25);
   Write (jogador[0].nome.nomeJogadores);
   sintSom (jogador[0].nome.som);
   fala ('svPJoga',0);      { Joga}
   readKey;
end;


procedure ajuda;
var k:integer;

begin
   limpaJanela (1,1,57,25);
   gotoxy (1,1);
   escreveAjuda;

   sintSom ('svajuda');

   while not keypressed do delay (200);
   while keypressed do readkey;

   limpaJanela (1,1,57,25);

   for k := 0 to 3 do
      begin
         if k = 0 then
             limpaJanela (15,18,43,25)
          else if k = 1 then
             limpaJanela (2,5,15,25)
          else if k = 2 then
             limpaJanela (15,2,43,8)
          else
             limpaJanela (43,6,55,25);

         mostra_jogador (k);
      end;

end;

procedure humano_joga (pos:integer; poscar:integer; var jogada:carta; distribui:integer);
var carta_a_jogar:carta;
    posicao:integer;
    jogou:boolean;
    opcao,opc: char;
begin
   posicao := 0;
   jogou := FALSE;
   Jogada.vnaipe := NULL;

   carta_a_jogar := jogador[0].cartas[posicao];
   (* procura a primeira carta que nao foi jogada *)
   while (carta_a_jogar.usada) do
       begin
          posicao := posicao + 1;
          carta_a_jogar := jogador[0].cartas[posicao];
       end;

   readKey;
   repeat
      limpaJanela (15,17,43,24);
      carta_a_jogar := jogador[0].cartas[posicao];
      levanta_carta (carta_a_jogar);
      fala_carta (carta_a_jogar);

      gotoxy (42, 21);
      opcao := readkey;

      (* ABORTA *)
      if opcao = GOTFOCUS then
          redesenhaCartas (poscar,Distribui)
      else
      if (opcao = ESC) then
      begin
         repeat
            limpajanela (1,25,58,25);
            gotoxy (24,25);
            fala ('svConfDe',0);    { confirma desistência }
            opc := sintReadKey;
            write (opc);
            if upcase (opc) = 'S' then
               jogou := TRUE;
        until (upcase (opc) = 'S') or (upcase (opc) = 'N');
        limpajanela (1,25,58,25);
      end
      else if (opcao = #$0) then
      begin
         opcao := readkey;
         if ((opcao = ESQUERDA) or (opcao = DIREITA)) then
             posicao := seleciona_carta (opcao,posicao)
         else if (opcao = F1) then
             ajuda

         else if (opcao = F2) then
             ver_cartas_da_mesa (poscar)

         else if (opcao = F3) then
             begin
                mostra_escore;
                limpaJanela (1,25,58,25);
                gotoxy (25,25);
                Write (jogador[0].nome.nomeJogadores);
                sintSom (jogador[0].nome.som);
                fala ('svPJoga',0);      { Joga}
                readKey;
             end
         else if (opcao = F4) then
             begin
                mostra_trunfo(distribui);
                limpaJanela (1,25,58,25);
                gotoxy (25,25);
                Write (jogador[0].nome.nomeJogadores);
                sintSom (jogador[0].nome.som);
                fala ('svPJoga',0);      { Joga}
                readKey;
             end
         else if (opcao = F8) then falaHora
         else if (opcao =         CTLF8) then falaDia;
      end
      else if (opcao = ENTER) then
          begin
             jogador[0].cartas[posicao].usada := TRUE;
             jogada := carta_a_jogar;
             jogou := TRUE;
          end;

   until jogou;
end;

end.
