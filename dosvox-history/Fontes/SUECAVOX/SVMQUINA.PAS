{--------------------------------------------------------}
{    Programa SuecaVox
{    Jogada da maquina
{--------------------------------------------------------}

unit svMquina;

interface

uses dvcrt, svvars, svcartas, svresult;

procedure mquina_joga (quemJogou:integer; pos:integer;poscar:integer; var jogada:carta);

implementation

procedure maquina_joga (quemJogou:integer; pos:integer; poscar:integer; var jogada:carta);
var carta_a_jogar:carta;
    posicao:integer;
    jogou:boolean;
    opcao: char;
begin
   posicao := 0;
   jogou := FALSE;
   Jogada.vnaipe := NULL;

   carta_a_jogar := jogador[quemJogou].cartas[posicao];
   (* procura a primeira carta que nao foi jogada *)
   while (carta_a_jogar.usada) do
   begin
      posicao := posicao + 1;
      carta_a_jogar := jogador[quemJogou].cartas[posicao];
   end;

   repeat
      carta_a_jogar := jogador[quemJogou].cartas[posicao];
      gotoxy (31,16);
      le_carta (carta_a_jogar);
      opcao := readkey;
      if (opcao = ENTER) then
      begin
         jogador[quemJogou].cartas[posicao].usada := TRUE;
         jogada := carta_a_jogar;
         jogou := TRUE;
      end

      else if (opcao = #$0) then
      begin
         opcao := readkey;
         if ((opcao = ESQUERDA) or (opcao = DIREITA)) then
            posicao := seleciona_carta (quemJogou,opcao,posicao);
      end;

   until jogou;
end;

end.