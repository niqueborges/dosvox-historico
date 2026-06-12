{--------------------------------------------------------}
{    Programa SuecaVox
{    Utilitários para manipulação dos nomes das cartas
{--------------------------------------------------------}

unit svCartas;
interface

uses  dvcrt, svVars, dvwin, svMensa,svMcarta;

procedure fala_carta (carta_a_ler:carta);
procedure le_carta (carta_a_ler:carta);
procedure mostra_trunfo (quem_distribui:integer);
procedure limpaJanela (x1:integer; y1:integer; x2:integer; y2:integer);

implementation

procedure fala_carta (carta_a_ler:carta);
begin
   (* fala a letra *)
   if (carta_a_ler.vletra = ace) then
      sintSom ('a')

   else if (carta_a_ler.vletra = dois) then
      sintSom ('2')

   else if (carta_a_ler.vletra = tres) then
      sintSom ('3')

   else if (carta_a_ler.vletra = quatro) then
      sintSom ('4')

   else if (carta_a_ler.vletra = cinco) then
      sintSom ('5')

   else if (carta_a_ler.vletra = seis) then
      sintSom ('6')

   else if (carta_a_ler.vletra = sete) then
      sintSom ('7')

   else if (carta_a_ler.vletra = dama) then
      sintSom ('q')

   else if (carta_a_ler.vletra = valete) then
      sintSom ('j')

   else if (carta_a_ler.vletra = rei ) then
      sintSom ('k');

   (* fala o naipe *)
   if (carta_a_ler.vnaipe = ouros) then
      sintSom ('ouros')

   else if (carta_a_ler.vnaipe = copas) then
      sintSom ('copas')

   else if (carta_a_ler.vnaipe = espadas) then
      sintSom ('espadas')

   else if (carta_a_ler.vnaipe = paus) then
      sintSom ('paus');
end;

procedure le_carta (carta_a_ler:carta);
var carta_a_lerLetra,carta_a_lerNaipe:string;

begin
   carta_a_lerLetra := ' ';
   carta_a_lerNaipe := ' ';

   (* verifica qual e a letra do carta_a_ler *)
   if (carta_a_ler.vletra = ace) then
      carta_a_lerLetra := 'As'

   else if (carta_a_ler.vletra = dois) then
      carta_a_lerLetra := 'Dois'

   else if (carta_a_ler.vletra = tres) then
      carta_a_lerLetra := 'Três'

   else if (carta_a_ler.vletra = quatro) then
      carta_a_lerLetra := 'Quatro'

   else if (carta_a_ler.vletra = cinco) then
      carta_a_lerLetra := 'Cinco'

   else if (carta_a_ler.vletra = seis) then
      carta_a_lerLetra := 'Seis'

   else if (carta_a_ler.vletra = sete) then
      carta_a_lerLetra := 'Sete'

   else if (carta_a_ler.vletra = dama) then
      carta_a_lerLetra := 'Dama'

   else if (carta_a_ler.vletra = valete) then
      carta_a_lerLetra := 'Valete'

   else if (carta_a_ler.vletra = rei ) then
      carta_a_lerLetra := 'Rei';

   (* verifica qual e o naipe do carta_a_ler *)
   if (carta_a_ler.vnaipe = ouros) then
      carta_a_lerNaipe := 'Ouros'

   else if (carta_a_ler.vnaipe = copas) then
      carta_a_lerNaipe := 'Copas'

   else if (carta_a_ler.vnaipe = espadas) then
      carta_a_lerNaipe := 'Espadas'

   else if (carta_a_ler.vnaipe = paus) then
      carta_a_lerNaipe := 'Paus';

   (* mostra o carta_a_ler *)
   if  (carta_a_lerLetra <> ' ') or (carta_a_lerNaipe <> ' ') then
      write ( carta_a_lerLetra + ' de ' + carta_a_lerNaipe);
end;

procedure mostra_trunfo (quem_distribui:integer);
begin

   gotoxy (58,8);
   fala ('svtrunf',0);  { trunfo }

   (* mostra a carta  *)
   mostra_carta (500,160,trunfo.bmp);
   fala_carta (trunfo);

   gotoxy (58,9);
   fala ('svtruest',0);    { está com }
   write (jogador[quem_distribui].nome.nomeJogadores);
   sintSom (jogador[quem_distribui].nome.som);
end;

procedure limpaJanela (x1:integer; y1:integer; x2:integer; y2:integer);
var i,j:integer;
    s: string;
begin
   s := '';
   for j := x1 to x2 do
       s := s + ' ';
   for i := y1 to y2 do
      begin
          gotoxy (x1,i);
          write (s);
      end;
end;

end.