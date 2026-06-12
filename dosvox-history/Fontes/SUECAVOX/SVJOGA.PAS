{--------------------------------------------------------}
{    Programa SuecaVox
{    Controle da Série de Jogos
{--------------------------------------------------------}

unit svJoga;
interface

uses
    dvcrt, dvwin,
    svMcarta, svMensa, svvars, svembara, svhumano, svresult, svcartas, svMaqjo;

procedure joga_serie_de_partidas;

implementation

function executa_jogo (quemJoga:integer; quem_distribui:integer):boolean;
label saida;
var i,j,k,g,quem_iniciou,quem_ganhou:integer;
    desistiu:boolean;

begin
   desistiu := FALSE;
   quem_iniciou := quemJoga;
   while keyPressed do readKey;

   (* as dez jogadas de cada um *)
   pontos1 := 0;
   pontos2 := 0;

   (* limpa a matriz *)
   for i := 0 to 9 do
      for j := 0 to 3 do
      begin
         mesa_de_cartas[i].cartasJogada[J].vnaipe := NULL;
         mesa_de_cartas[i].cartasJogada[J].vletra := NULO;
      end;

   (* limpa os trunfos e as cartas jogadas *)
   for i := 0 to 3 do
   begin
      participante [i].ttrunfo := TRUE; (* sempre imagina-se que todos
                                             tem trunfo *)

      for j:= 0 to 3 do
         participante [i].corte [j] := NULL;   (* nimguem corta nada *)
   end;

   mostra_escore;
   for i := 0 to 9 do
   begin
      for j := 0 to 3 do
      begin

         (* limpa  o local das cartas dos jogadores *)
         for g := 0 to 3 do
            begin
               if g = 0 then
                  limpaJanela (15,18,43,25)
               else if g = 1 then
                  limpaJanela (2,6,14,23)
               else if g = 2 then
                  limpaJanela (15,2,43,8)
               else
                  limpaJanela (43,6,55,25);

               mostra_jogador (g);
            end;
          (* limpa o local das mensagens *)
         limpaJanela (1,25,57,25);
         (* diz quem joga *)
         gotoxy (25,25);

         if j = 0 then
             sintSom ('tliq');

         if quemJoga = 0 then
            begin
               Write (jogador[quemJoga].nome.nomeJogadores);
               sintSom (jogador[quemJoga].nome.som);
               fala ('svPJoga',0);      {pode jogar}
            end
         else
            begin
               Write (jogador[quemJoga].nome.nomeJogadores);
               sintSom (jogador[quemJoga].nome.som);
               fala ('svJogaa',0);      { Joga}

            end;
         (* se quem joga for humano *)
         if (quemJoga = 0) then
         begin
             humano_joga (j,i, mesa_de_cartas[i].cartasJogada[quemJoga],quem_distribui);
            (* se desistiu *)
            if (mesa_de_cartas[i].cartasJogada[quemJoga].vnaipe = NULL) then
            begin
               desistiu := TRUE;
               goto saida;
            end;

            (* verifica se houve abdicação *)
            if (j <> 0) and (mesa_de_cartas[i].cartasJogada[quemJoga].vnaipe<>
                mesa_de_cartas[i].cartasJogada[quem_iniciou].vnaipe) then
            begin
               (* procura uma carta do naipe da primeira carta jogada *)
                for k := 0 to 9 do
                begin
                   if (jogador[0].cartas[k].vnaipe =
                       mesa_de_cartas[i].cartasJogada[quem_iniciou].vnaipe)
                       and not(jogador[0].cartas[k].usada) then
                       begin
                          limpaJanela (15,25,55,25);
                          gotoxy (15,25);

                          sintSom ('erro');
                          fala ('svrenun',0);   {   Você renunciou, por isso perdeu o jogo. }
                          if comEfeitos then delay (1000);
                          escore2 := 4;
                          renuncia := TRUE;
                          goto saida;
                       end;
                end;
            end;

         end
         (* quem joga e o computador *)
         else
              maquina_joga (quemJoga,j,i, mesa_de_cartas[i].cartasJogada[quemJoga]);

         if quemJoga = 0 then
             begin
                 limpaJanela (15,18,43,25);
                 mostra_carta (200,170 ,mesa_de_cartas[i].cartasJogada[quemJoga].bmp);
                 mostra_jogador(0);
             end
         else if quemJoga = 1 then
            mostra_carta (150,160 ,mesa_de_cartas[i].cartasJogada[quemJoga].bmp)
         else if quemJoga = 2 then
            mostra_carta (200,130 ,mesa_de_cartas[i].cartasJogada[quemJoga].bmp)
         else
            mostra_carta (250,160 ,mesa_de_cartas[i].cartasJogada[quemJoga].bmp);

         fala_carta (mesa_de_cartas[i].cartasJogada[quemJoga]);
         quemJoga := proximo (quemJoga);

      end;
      quem_ganhou := conta_pontos (mesa_de_cartas[i],quem_iniciou);
      (* quem ganha e quem inicia a proxima jogada *)
      quemJoga := quem_ganhou;
      quem_iniciou := quem_ganhou;

      limpaJanela (20,25,50,25);
      gotoxy (20,25);
      fala ('svfqlevo',0);     { Quem levou foi }
      write (jogador[quem_ganhou].nome.nomeJogadores);
      sintSom (jogador[quem_ganhou].nome.som);
      limpaJanela (20,25,50,25);
      limpaJanela (15,9,42,20);
   end;

   for g := 0 to 3 do
       begin
          if g = 0 then
             limpaJanela (15,18,43,25)
          else if g = 1 then
             limpaJanela (2,5,15,25)
          else if g = 2 then
             limpaJanela (15,2,43,8)
          else
             limpaJanela (43,6,55,25);

          mostra_jogador (g);
       end;

   saida:
   executa_jogo := desistiu;
   limpaBufTec;
end;

function joga_um_jogo (embaralha:integer):boolean;
var distribui,quem_comeca,quem_joga:integer;
    desistiu:boolean;

begin
   if comEfeitos then sintSom ('tada');

   (* diz quem embaralha *)

//////   textBackGround (GREEN);
//////   textColor (YELLOW);
   textColor (GREEN);

   if comEfeitos then
        begin
            fala ('svqueem',0);    {Quem embaralha é }
            writeln (jogador [embaralha].nome.nomeJogadores);
            sintSom (jogador [embaralha].nome.som);
        end;

   embaralha_cartas;

   distribui := distribui_cartas (embaralha);
   organiza_cartas;

/////   textcolor (BLACK);
/////   textbackground (GREEN);
textcolor (GREEN);
textbackground (BLACK);
   clrscr;

/////   textBackGround (RED);
textBackground (BLUE);
   textColor (WHITE);
   gotoxy (59, 25);
   write ('SUECAVOX - NCE/UFRJ');
/////   textBackGround (GREEN);
/////   textColor (BLACK);
textBackGround (BLACK);
textColor (GREEN);

   mostra_trunfo (distribui);
   (* verifica quem comeca ( o proximo) *)
   quem_comeca := proximo (distribui);

   quem_joga := quem_comeca;
   mostra_carta (480,280,41);

   desistiu := executa_jogo (quem_joga,distribui);

   joga_um_jogo := desistiu;

end;

procedure joga_serie_de_partidas;
var quem_embaralha:integer;
    terminou,desistiu:boolean;

begin
   (* escolhe quem embaralha *)
   randomize;

   quem_embaralha:=round(random(4)); (* inteiro do numero randômico *)
   terminou := FALSE;
   escore1 := 0;
   escore2 := 0;

   writeln;
   repeat
       (* joga *)
/////       textBackGround (GREEN);
textbackground (BLACK);
       clrscr;
/////       textBackGround (RED);
textBackGround (BLUE);
       textColor (WHITE);
       gotoxy (1, 1);
       write ('SUECAVOX - NCE/UFRJ');
       gotoxy (1, 3);
textbackground (BLACK);

       desistiu := joga_um_jogo (quem_embaralha);

       if not (desistiu) then
       begin
          if comEfeitos then sintsom ('tada');
          mostra_pontuacao;
          if comEfeitos then sintSom ('chimes');
          if comEfeitos then mostra_escore;

          (* ate alguem conseguir 4 pontos *)
          if ((escore1>=4) or (escore2>=4)) then
          begin
             terminou := TRUE;

             limpaJanela (15,25,55,25);
             (* da parabéns a dupla vencedora *)
             if comEfeitos then sintSom ('aplauso');

             gotoxy (5,25);
             if (escore1>=4) then
             begin
                fala ('svparab',0);      { Parabéns a dupla vencedora }
                Write (jogador[0].nome.nomeJogadores);
                sintSom (jogador[0].nome.som);
                fala ('sve', 0);
                write (jogador[2].nome.nomeJogadores);
                sintSom (jogador[2].nome.som);
                if comEfeitos then sintSom ('aplauso');
             end
             else
             begin
                fala ('svparab',0);   { Parabéns a dupla vencedora }
                write (jogador[1].nome.nomeJogadores);
                sintSom (jogador[1].nome.som);
                fala ('sve', 0);
                write (jogador[3].nome.nomeJogadores);
                sintSom (jogador[3].nome.som);
                if comEfeitos then sintSom ('aplauso');
             end;
          end
          else
             quem_embaralha := proximo (quem_embaralha);
       end;
   until (terminou) or (desistiu);
   mostra_escore;
end;

end.
