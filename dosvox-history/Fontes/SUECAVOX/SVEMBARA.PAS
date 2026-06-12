{--------------------------------------------------------}
{    Programa SuecaVox
{    Embaralha e distribui as cartas
{--------------------------------------------------------}

unit svEmbara;
interface
uses dvcrt, svvars, svcartas, dvwin, svMensa;

function proximo (x:integer):integer;
procedure embaralha_cartas;
procedure organiza_cartas;
function distribui_cartas (quem_embaralha:integer):integer;

implementation

function proximo (x:integer):integer;
begin

   (* o proximo jogador para qualquer jogador *)
   x := x + 1;
   if (x >= 4) then
      x := 0;
   proximo := x;

end;

procedure cria_baralho;
var i:integer;
    naipeTemp:naipe;
begin
  (* cria o baralho *)
   for i:=0 to 3 do
   begin
      (* coloca as letras *)
      vbaralho[i*10].vletra := dois;
      vbaralho[i*10+1].vletra := tres;
      vbaralho[i*10+2].vletra := quatro;
      vbaralho[i*10+3].vletra := cinco;
      vbaralho[i*10+4].vletra := seis;
      vbaralho[i*10+5].vletra := dama;
      vbaralho[i*10+6].vletra := valete;
      vbaralho[i*10+7].vletra := rei;
      vbaralho[i*10+8].vletra := sete;
      vbaralho[i*10+9].vletra := ace;


      (* valor das cartas *)
      vbaralho[i*10].vvalor := 0;
      vbaralho[i*10+1].vvalor := 0;
      vbaralho[i*10+2].vvalor := 0;
      vbaralho[i*10+3].vvalor := 0;
      vbaralho[i*10+4].vvalor := 0;
      vbaralho[i*10+5].vvalor := 2;
      vbaralho[i*10+6].vvalor := 3;
      vbaralho[i*10+7].vvalor := 4;
      vbaralho[i*10+8].vvalor := 10;
      vbaralho[i*10+9].vvalor := 11;
   end;

   (* posiciona os naipes *)
   for i:=0 to 39 do
   begin
      if i<= 9 then
         naipeTemp := ouros

      else if (i>=10) and (i<=19) then
         naipeTemp := copas

      else if (i>=20) and (i<=29) then
         naipeTemp := paus

      else
         naipetemp := espadas;

      vbaralho[i].vnaipe := naipeTemp;
      vbaralho[i].usada := FALSE;
      vbaralho[i].bmp := i;

   end;
end;

procedure embaralha_cartas;
var i,indice1,indice2:integer;
    cartaTemp:carta;

begin
   cria_baralho;

   if comEfeitos then
        begin
            fala ('svembca',1);    { embaralhando carta }
            delay (500);
            sintSom ('svsembca');
            while sintFalando do;
        end;

   (* embaralha as cartas *)
   randomize;

   for i:=0 to 300 do
   begin
      indice1 := round(random(40));
      indice2 := round(random(40));
      cartaTemp := vbaralho[indice2];
      vbaralho[indice2] := vbaralho [indice1];
      vbaralho[indice1] := cartaTemp;

   end;

   if comEfeitos then
        begin
            sintSom ('svsembca');
            delay (300);
            fala ('svcorta',1);
            sintSom ('svscorta');
            delay (500);
        end;
end;

procedure organiza_cartas;
var i,ind,ind2:integer;
    troquei:boolean;
    cartaTemp:carta;

begin
  ind2 := 8;

  (* repete para os 4 jogadores *)
  for i:=0 to 3 do
  begin

     (* faz a organização pelo algorítimo da bolha *)
     repeat
        troquei:=FALSE;
        for ind := 0 to ind2 do
        begin
           if ((jogador[i].cartas[ind].vnaipe > jogador[i].cartas[ind+1].vnaipe) or
              ((jogador[i].cartas[ind].vnaipe = jogador[i].cartas[ind+1].vnaipe) and
              (jogador[i].cartas[ind].vletra > jogador[i].cartas[ind+1].vletra))) then
           begin

              (* faz a troca de cartas *)
              cartaTemp := jogador[i].cartas[ind];
              jogador[i].cartas[ind] := jogador[i].cartas[ind+1];
              jogador[i].cartas[ind+1] := cartaTemp;
              troquei := TRUE;

           end;

        end;

     (* sai se não houver troca *)
     until (troquei = FALSE);

  end;
end;

function distribui_cartas (quem_embaralha:integer):integer;
var quem_recebe,quem_distribui,j,i:integer;

begin
    if comEfeitos then
        begin
            fala ('svdistca',1);    {   distribuindo carta }
            delay (500);
        end;

   (* o trunfo e a primeira carta da matriz embaralhada *)
   trunfo := vbaralho[0];

   (* define quem distribui as cartas que e o primeiro a receber *)
   quem_recebe := proximo (quem_embaralha); (* quem recebe e o proximo *)

   quem_distribui := quem_recebe;

   (* distribui as cartas *)
   for j:=0 to 3 do
   begin
      (* distribui 10 cartas para cada jogador *)
      for i:=0 to 9 do
         jogador[quem_recebe].cartas[i] := vbaralho[j*10+i];

      (* quem recebe e o proximo *)
      quem_recebe := proximo (quem_recebe);
   end;
   for i := 0 to 3 do
      for j:=0 to 9 do
         jogador[i].cartas[j].usada := FALSE;

   if comEfeitos then
      for i := 0 to 3 do
         sintSom ('svsdistc');  {distribuindo cartas}

   distribui_cartas := quem_distribui;
end;
end.
