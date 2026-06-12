{--------------------------------------------------------}
{    Programa SuecaVox
{    Escolha dos jogadores
{--------------------------------------------------------}

unit svEscolh;

interface

uses dvcrt, svvars, svcartas, svMensa, dvwin;

procedure escolhe_jogadores(var tnome:jogadores);
procedure cria_jogadores;

implementation

const
   ESC      = #27;
   ENTER    = #13;
   ESQUERDA = #75;
   DIREITA  = #77;
   CIMA     = #72;
   BAIXO    = #80;

   (* complementa o tamanho da string *)

(**********************************************)
function complemento (c:string):string;
(**********************************************)
var k: string[14];
    l, i: integer;

begin
   k := '';
   l := length (c);
   l := 13 - l;

   for i := 0 to l do
      k := k + ' ';

  complemento := k;
end;

(************************)
procedure cria_jogadores;
(************************)
var i: integer;
    s: string[2];
begin
   (* nome dos participantes *)

   for i := 0 to MAXJOGADORES - 1 do
       begin
          nomeparticipante[i].nomeJogadores := nomeJog[i+1];
          str (i+1, s);
          nomeparticipante[i].som := 'svjog' + s;
          nomeparticipante[i].escolhido := FALSE;
       end;
end;

(**************************************************************)
procedure escolhe_jogadores(var tnome:jogadores);
(**************************************************************)
var i:integer;
    opc:char;

begin

   for i := 0 to MAXJOGADORES-1 do
   begin

       if nomeparticipante[i].escolhido = FALSE then
          begin
             textcolor (WHITE);
             textbackground (RED);
          end
       else
          begin
             textcolor (BLACK);
             textbackground (RED);
          end;

       gotoxy (2,i + 8);
       write (nomeparticipante[i].nomeJogadores,complemento (nomeparticipante[i].nomeJogadores));

   end;

   i := 0;

   while (nomeparticipante [i].escolhido <> FALSE) do
      i := i + 1;

   repeat

      textcolor (RED);
      textbackground (WHITE);

      gotoxy (2,i + 8);
      write (nomeparticipante[i].nomeJogadores,complemento (nomeparticipante[i].nomeJogadores));
      sintSom (nomeparticipante[i].som);

      opc := readkey;
      if opc = ESC then
          begin
              textBackground (BLACK);
              textColor (YELLOW);
              gotoxy (1, 25);
              fala ('svfim', 0);
              sintFim;
              doneWincrt;
          end;

      textcolor (WHITE);
      textbackground (RED);

      gotoxy (2,i + 8);
      write (nomeparticipante[i].nomeJogadores,complemento (nomeparticipante[i].nomeJogadores));


      if opc = #$0 then
         begin
            opc := readkey;

            if opc = F1 then
                sintSom ('sv1ajuda')   { use setas, etc...}
            else

            if (opc = BAIXO) or (opc = DIREITA) then
               begin
                  i := i + 1;

                  if i >= MAXJOGADORES then
                     i := 0;

                  while (nomeparticipante [i].escolhido <> FALSE) do
                     begin
                        i := i + 1;

                        if i >= MAXJOGADORES then
                           i := 0;
                  end;

               end

            else if (opc = CIMA) or (opc = ESQUERDA) then
               begin
                  i := i - 1;

                  if i <= -1 then
                     i := MAXJOGADORES-1;


                  while (nomeparticipante [i].escolhido <> FALSE) do
                     begin
                       i := i - 1;

                       if i <= -1 then
                         i := MAXJOGADORES-1;
                     end;

               end;

         end


   until opc = ENTER;

   textcolor (WHITE);
   textbackground (BLACK);

   nomeparticipante [i].escolhido := TRUE;
   tnome := nomeparticipante [i];

end;

end.