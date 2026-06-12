{--------------------------------------------------------}
{
{   Jogo de Paciencia Falado
{
{   Autor: Jose' Antonio Borges
{
{   Em 19/9/97
{
{--------------------------------------------------------}

program paciencia;
{$R pacienci.res}
uses DVcrt, pacVars, pacmens, DVlenum, DVWin, pacdesen;

{-----------------------------------------------------------}
{                       calcula o tempo                     }
{-----------------------------------------------------------}

procedure mostraTempo;
var h, m, s, c: word;
    difh, difm, difs: integer;
begin
    gettime (h, m, s, c);

    difh := integer(h) - h0;
    if difh < 0 then difh := difh + 24;
    difm := integer(m) - m0;
    if difm < 0 then
        begin
            difm := difm + 60;
            difh := difh + 1;
        end;
    difs := integer(s) - s0;
    if difs < 0 then
        begin
            difs := difs + 60;
            difm := difm + 1;
        end;

    mensagem ('PATEMPOJ');  {Tempo de jogo:}
    if difh < 10 then write ('0'); write (difh, ':');
    if difm < 10 then write ('0'); write (difm, ':');
    if difs < 10 then write ('0'); write (difs);

     if difh > 0 then
         begin
             falaNumeroConv (numeroParaString (difh), FEMININO);
             if difh = 1 then sintSom ('_HORA')
                         else sintSom ('_HORAS');
         end;

     falaNumeroConv (numeroParaString (difm), MASCULINO);
     if difm > 1 then
         sintSom ('_MINUTOS')
     else
         sintSom ('_MINUTO');
     falaNumeroConv (numeroParaString (difs), MASCULINO);
     sintSom ('_SEGUNDS');
end;

{--------------------------------------------------------}
{                faz a festa quando termina
{--------------------------------------------------------}

procedure fazAFesta;
begin
    textBackGround (red);
    gotoxy (30,  9);    write ('                                                 ');
    gotoxy (30, 10);    write ('   @@@    @@@   @   @  @   @   @@@   @   @    @  ');
    gotoxy (30, 11);    write ('  @   @  @   @  @@  @  @   @  @   @  @   @    @  ');
    gotoxy (30, 12);    write ('  @      @   @  @ @ @  @   @  @   @  @   @    @  ');
    gotoxy (30, 13);    write ('  @  @@  @@@@@  @  @@  @@@@@  @   @  @   @    @  ');
    gotoxy (30, 14);    write ('  @   @  @   @  @   @  @   @  @   @  @   @    @  ');
    gotoxy (30, 15);    write ('  @   @  @   @  @   @  @   @  @   @  @   @       ');
    gotoxy (30, 16);    write ('   @@@   @   @  @   @  @   @   @@@    @@@     @  ');
    gotoxy (30, 17);    write ('                                                 ');
    sintSom ('PAAPLAUS');
    sintSom ('PAGANHOU');
end;

{--------------------------------------------------------}
{                   desenha uma carta
{--------------------------------------------------------}

procedure carta (x, y: integer; valor, naipe, fundo: integer);
const
    tabchr: array [COPAS..ESPADAS] of char = ('c', 'o', 'p', 'e');
begin
    textbackground (fundo);
    textColor (black);
    gotoxy (x, y);    write ('+');
    if (naipe = COPAS) or (naipe = OUROS) then
        textColor (Red);
(*
    case valor of
        1:  write (' A', ' ', tabchr[naipe]);
        11: write (' J', ' ', tabchr[naipe]);
        12: write (' Q', ' ', tabchr[naipe]);
        13: write (' K', ' ', tabchr[naipe]);
    else
        write (valor:2, ' ', tabchr[naipe]);
    end;

    textColor (black);
    write ('--+');

    gotoxy (x, y+1);  write ('|      |');
    gotoxy (x, y+2);  write ('|      |');
    gotoxy (x, y+3);  write ('|      |');
    gotoxy (x, y+4);  write ('+------+');
*)

    gotoxy (x, y  );  write ('        ');
    gotoxy (x, y+1);  write ('        ');
    gotoxy (x, y+2);  write ('        ');
    gotoxy (x, y+3);  write ('        ');
    gotoxy (x, y+4);  write ('        ');

    textbackground (black);
    textColor (white);

    mostraCartaGrafica (x, y, naipe, valor-1);
end;

{--------------------------------------------------------}
{               desenha uma carta virada
{--------------------------------------------------------}

procedure cartaVirada (x, y: integer);
begin
    textbackground (white);
    textbackground (yellow);
    gotoxy (x, y);    write ('+------+');
    gotoxy (x, y+1);  write ('|께께께|');
    gotoxy (x, y+2);  write ('|께께께|');
    gotoxy (x, y+3);  write ('|께께께|');
    gotoxy (x, y+4);  write ('+------+');
    textbackground (black);
    textColor (white);

    mostraCartaGrafica (x, y, 6, 14);
end;

{--------------------------------------------------------}
{                    desenha do espaco
{--------------------------------------------------------}

procedure espacoCarta (x, y: integer; fundo : integer);
begin
    textbackground (fundo);
    gotoxy (x, y);    write ('+------+');
    gotoxy (x, y+1);  write ('!      !');
    gotoxy (x, y+2);  write ('!      !');
    gotoxy (x, y+3);  write ('!      !');
    gotoxy (x, y+4);  write ('+------+');
    textbackground (black);
    textColor (white);
end;

{--------------------------------------------------------}
{                  inicializa o baralho
{--------------------------------------------------------}

procedure inicBaralho;
var
    naipe, valor, i: integer;
begin
    i := 1;
    for naipe := COPAS to ESPADAS do
        for valor := 1 to 13 do
            begin
                baralho [i] := (valor shl 3) or naipe;
                i := i + 1;
            end;
end;

{--------------------------------------------------------}
{                     embaralha
{--------------------------------------------------------}

procedure embaralha;
var vez, i, j: integer;
    temp: byte;
begin
    randomize;
    for vez := 1 to 1000 do
        begin
            i := random (52) + 1;
            j := random (52) + 1;
            temp := baralho [i];
            baralho [i] := baralho [j];
            baralho [j] := temp;
        end;
end;

{--------------------------------------------------------}
{                     distribui cartas
{--------------------------------------------------------}

procedure distribui;
var x, y: integer;
    valor, naipe: byte;

begin
    for x := 1 to 7 do
       for y := 1 to 20 do
           coluna [x, y] := 0;

    ncbaralho:= 52;
    for y := 1 to 7 do
       begin
           for x := y to 7 do
               begin
                   coluna [x, y] := baralho [ncbaralho];
                   ncbaralho := ncbaralho - 1;
               end;
       end;

    for x := 1 to 7 do
        begin
            cartasCol [x] := x;
            fechadasCol[x] := x-1;
        end;

    mensagem ('');

    for y := 1 to 7 do
        begin
            for x := y to 7 do
                begin
                    if y <= fechadasCol [x] then
                        cartaVirada (9*(x+1), y)
                    else
                        begin
                            valor := coluna [x, y] shr 3;
                            naipe := coluna [x, y] and 7;
                            carta(9*(x+1), y, valor, naipe, white);
                        end;
                end;

            gotoxy (y*4-3, 25);
            textBackground (RED);
            mensCarta (coluna [y, y]);
        end;

    for x := COPAS to ESPADAS do
        pilha [x] := $0;

    ncTiradas := 0;
end;

{--------------------------------------------------------}
{                     mostra o baralho
{--------------------------------------------------------}

procedure mostraBaralho;
var x: integer;
    valor, naipe: byte;
begin
    x := 1;
    if ncBaralho = 0 then
        espacoCarta (9*(x+1), 20, blue)
    else
        cartaVirada (9*(x+1), 20);
    x := 2;
    if ncTiradas = 0 then
        espacoCarta (9*(x+1), 20, blue)
    else
        begin
            valor := tiradas [ncTiradas] shr 3;
            naipe := tiradas [ncTiradas] and 7;
            carta (9*(x+1), 20, valor, naipe, white);
        end;
end;

{--------------------------------------------------------}
{                     mostra tela
{--------------------------------------------------------}

procedure mostraTela;
var x, y, xm: integer;
    valor, naipe: byte;
begin
    for x := 1 to 7 do
        begin
            y := 1;
            if cartasCol [x] = 0 then
                espacoCarta (9*(x+1), y, blue)
            else
              for y := 1 to cartasCol [x] do
                begin
                    if y <= fechadasCol [x] then
                        cartaVirada (9*(x+1), y)
                    else
                        begin
                            valor := coluna [x, y] shr 3;
                            naipe := coluna [x, y] and 7;
                            carta(9*(x+1), y, valor, naipe, white);
                        end;
                end;

            xm := 2;
            if cartasCol[x] > 0 then xm := cartasCol[x]+1;
                for y := xm to 20 do
                    begin
                        gotoxy (9*(x+1), 4+y);
                        textBackground (blue);
                        write ('        ');
                    end;
        end;

    for y := COPAS to ESPADAS do
        if pilha [y] = 0 then
            espacoCarta (6, 5*(y-2), blue)
        else
           begin
               valor := pilha [y] shr 3;
               naipe := pilha [y] and 7;
               carta (6, 5*(y-2), valor, naipe, white);
           end;

    mostraBaralho;
end;

{--------------------------------------------------------}
{               fala trecho selecionado
{--------------------------------------------------------}

procedure falaSelec;
begin
    if (linAtual = 20) then exit;

    if cartasCol [colAtual] = 0 then
        begin
            mensagem ('PAVAZIO');  {Vazia}
            exit;
        end;

    mensagem ('');
    mensCarta (coluna [colAtual, cartasCol [colAtual]]);

    if linAtual < cartasCol[colAtual] then
        begin
            mensCont ('PAATE');
            mensCarta (coluna [colAtual, linAtual]);
        end;
end;

{--------------------------------------------------------}
{                mostra coluna selecionada
{--------------------------------------------------------}

procedure mostraSelecTela;
var x, y: integer;
    valor, naipe: byte;
label fim;
begin
    if (colAtual < 1) or (colAtual > 7) then
        exit;

    x := colAtual;
    if cartasCol[x] = 0 then
        begin
           if linAtual = 20 then
               espacoCarta (9*(x+1), 1, blue)
           else
               espacoCarta (9*(x+1), 1, green);
           goto fim;
        end;

    for y := 1 to cartasCol [x] do
       begin
           if y <= fechadasCol [x] then
               cartaVirada (9*(x+1), y)
           else
               begin
                   valor := coluna [x, y] shr 3;
                   naipe := coluna [x, y] and 7;
                   if y < linAtual then
                       carta (9*(x+1), y, valor, naipe, white)
                   else
                       carta (9*(x+1), y, valor, naipe, green);
               end;
       end;
fim:
    falaSelec;
end;

{--------------------------------------------------------}
{            desenha tela, embaralha e distribui
{--------------------------------------------------------}

procedure cabecalho;
begin
    textBackground (blue);
    clrscr;

    textBackground (RED);
    textColor(white);
    gotoxy (1, 1);
    write ('   NCE/UFRJ   ');
    gotoxy (1, 2);
    write ('PROJETO DOSVOX');
    gotoxy (1, 3);
    write ('Paciencia Vox ');

    textBackground (black);
end;

{--------------------------------------------------------}
{            desenha tela, embaralha e distribui
{--------------------------------------------------------}

procedure inicializa;
begin
    cabecalho;

    textColor(white);
    mensagem ('PAINTRO');
    sintSom ('PAINTRO1');

    inicBaralho;
    embaralha;
    distribui;

    mostraTela;

    colAtual := 1;
    linAtual := 1;

    sintSom ('PAINTRO2');
    mensagem ('PAAGORA');
    mostraSelecTela;

    gettime (h0, m0, s0, c0);
end;

{--------------------------------------------------------}
{               seleciona proxima coluna
{--------------------------------------------------------}

procedure proximaColuna;
begin
    linAtual := 20;                         { desseleciona }
    mostraSelecTela;

    if colatual < 7 then
        colAtual := colAtual + 1;

    linAtual := fechadasCol [colatual]+1;   { seleciona tudo }
    mostraSelecTela;
end;

{--------------------------------------------------------}
{                seleciona coluna anterior
{--------------------------------------------------------}

procedure colunaAnterior;
begin
    linAtual := 20;                         { desseleciona }
    mostraSelecTela;

    if colatual > 1 then
        colAtual := colAtual - 1;

    linAtual := fechadasCol [colatual]+1;   { seleciona tudo }
    mostraSelecTela;
end;
{--------------------------------------------------------}
{
{--------------------------------------------------------}

procedure sobeNaColuna;
begin
    if (cartasCol [colAtual] = 0) then
        begin
            sintClek;
            exit;
        end;

    linAtual := linAtual - 1;

    if (linAtual < 1) or (linAtual <= fechadasCol[colAtual]) then
        begin
            linAtual := linAtual + 1;
            sintClek;
        end;

    mostraSelecTela;
end;

{--------------------------------------------------------}
{
{--------------------------------------------------------}

procedure desceNaColuna;
begin
    if (cartasCol [colAtual] = 0) then
        begin
            sintClek;
            exit;
        end;

    linAtual := linAtual + 1;

    if linAtual > cartasCol [colAtual] then
        begin
            linAtual := linAtual - 1;
            sintClek;
        end;

    mostraSelecTela;
end;

{--------------------------------------------------------}
{              le toda coluna selecionada
{--------------------------------------------------------}

procedure leTodaColuna;
var y: integer;
begin
    mensagem ('PACOLUNA');
    mensNumero (colAtual);
    write (':');

    for y := fechadasCol[colAtual] + 1 to cartasCol [colAtual] do
        begin
            write (' ');
            mensCarta (coluna [colAtual, y]);
        end;

    write ('  ');
    mensCont ('PAFECHAD');
    if fechadasCol [colAtual] = 0 then
        mensCont ('PANADA')
    else
        mensNumero (fechadasCol [colAtual]);
end;

{--------------------------------------------------------}
{                le trecho selecionado
{--------------------------------------------------------}

procedure leSelec;
var y: integer;
begin
    mensagem ('PACOLUNA');
    mensNumero (colAtual);
    write (': ');

    if cartasCol [colAtual] = 0 then
         mensCont ('PAVAZIA')
    else
        for y := linAtual to cartasCol [colAtual] do
        begin
            mensCarta (coluna [colAtual, y]);
            write (' ');
        end;
end;

{--------------------------------------------------------}
{                le pilhas de naipes
{--------------------------------------------------------}

procedure lePilhasNaipes;
var naipe: integer;
begin
    mensagem ('PANASPIL');
    for naipe := COPAS to ESPADAS do
        begin
            write (' ');
            mensCarta (pilha [naipe] or naipe);
            if (pilha [naipe] shr 3) = 0 then
                begin
                    write (' ', chr(naipe));
                    sintSom (tabSomNaipes [naipe]);
                end;
        end;
end;

{--------------------------------------------------------}
{         toma ultima carta da coluna selecionada
{--------------------------------------------------------}

function ultimaCarta: byte;
begin
    if cartasCol [colAtual] = 0 then
        ultimaCarta := 0
    else
        ultimaCarta := coluna [colAtual, cartasCol [colAtual]];
end;

{--------------------------------------------------------}
{         ve se duas cartas podem ser justapostas
{--------------------------------------------------------}

function naipesCompativeis (naipe1, naipe2: integer): boolean;
var temp: integer;
begin
    if naipe1 > naipe2 then
        begin
            temp := naipe1;
            naipe1 := naipe2;
            naipe2 := temp;
        end;

    naipesCompativeis := (naipe1 <= OUROS) and (naipe2 >= PAUS);
end;

{--------------------------------------------------------}
{            traz de volta uma carta das pilhas
{--------------------------------------------------------}

procedure jogaDaPilhaNaColuna;
var c: char;
    naipep, naipe, valor: integer;

label moveCarta, deNovo;

begin

deNovo:
    mensagem ('PAQUEPIL');  { 'De que pilha (Copas, Ouros, Paus ou Espadas) ? }

    c := readkey;
    gotoxy (47, 25);
    write (c);
    sintCarac (c);
    c := upcase (c);

    if c = 'C' then naipep := COPAS   else
    if c = 'O' then naipep := OUROS   else
    if c = 'P' then naipep := PAUS    else
    if c = 'E' then naipep := ESPADAS else
         begin
             if c = #$1b then
                begin
                    mensagem ('PADESIST');  { Desistiu }
                    mostraTela;
                    exit;
                end;

             if c = #$0 then readkey;
             goto deNovo;
         end;

                           { caso especial, rei colocado em coluna vazia }

    if ((pilha [naipep] shr 3) = 13) and
       (cartasCol [colAtual] = 0) then goto moveCarta;

    valor := ultimaCarta shr 3;
    naipe := ultimaCarta and 7;

    if not naipesCompativeis (naipe, naipep) then
        begin
            sintSom ('PAEFEIT2');
            mensagem ('PAINCOMP');  { Naipes incompativeis }
            exit;
        end;

    if valor - (pilha [naipep] shr 3) <> 1 then
        begin
            textBackGround (RED);
            gotoxy (1, 25); clreol;
            if (pilha[naipep] shr 3) = 0 then
                begin
                    mensagem ('PAPILNAD');   { Esta pilha nao tem nada }
                    exit;
                end
            else
                begin
                    sintSom ('PAEFEIT2');
                    mensagem ('PAVALINC');  { Valores incompativeis ! }
                    mensCont ('PANAPILH');  { Na pilha tem }
                    mensCarta(pilha[naipep]);
                    exit;
                end;
        end;

moveCarta:
    inc (cartasCol [colAtual]);
    coluna [colAtual, cartasCol [colAtual]] := pilha [naipep];

    valor := pilha [naipep] shr 3 - 1;
    if valor = 0 then
        pilha [naipep] := 0
    else
        pilha [naipep] := (valor shl 3) or naipep;

    linAtual := fechadasCol [colatual]+1;   { seleciona tudo }

    mostraTela;
    mostraSelecTela;
end;

{--------------------------------------------------------}
{                 joga da Coluna na Pilha
{--------------------------------------------------------}

procedure jogaDaColunaNaPilha;
var
    valor, naipe: byte;
begin
    if cartasCol [colAtual] = 0 then
        begin
            leSelec;    { so' para dizer que esta vazia }
            exit;
        end;

    valor := ultimaCarta shr 3;
    naipe := ultimaCarta and 7;

    if valor - (pilha [naipe] shr 3) <> 1 then
        begin
            sintSom ('PAEFEIT2');
            mensagem ('PAVALINC');  { Valores incompativeis ! }
            mensCont ('PANAPILH');  { Na pilha tem }
            mensCarta (pilha[naipe]);
            exit;
        end
    else
        begin
            pilha [naipe] := coluna [colAtual, cartasCol [colAtual]];
            coluna [colAtual, cartasCol [colAtual]] := 0;
            dec (cartasCol [colAtual]);

            if (fechadasCol [colAtual] = cartasCol [colAtual]) and
               (fechadasCol [colAtual] > 0) then
                   dec (fechadasCol [colAtual]);

            linAtual := fechadasCol [colatual]+1;   { seleciona tudo }
        end;

    sintSom ('PAEFEIT4');
    if cartasCol [colAtual] = 0 then
        mensagem ('PAMOVVAZ')   { movi, coluna ficou vazia }
    else
        begin
            mensagem ('PAMOVFIC');   { movi, ficou }
            {mensCarta (ultimaCarta);}
        end;

    mostraTela;
    mostraSelecTela;
end;

{--------------------------------------------------------}
{       move trecho selecionado para outra coluna
{--------------------------------------------------------}

procedure moveParaOutraColuna;

    procedure erro;
    begin
        mensagem ('PADSTERR');  { Comando errado, escolha destino }
    end;

    {------------------------------------}

var col, y, i: integer;
    c, c2: char;
    ind1, ind2, aMover: byte;
    naipeOrig, naipeDest, valorOrig, valorDest: byte;

begin
    if cartasCol [colAtual] = 0 then
        begin
            leSelec;   { diz que esta' Vazio }
            exit;
        end;

    mensagem ('PADESTIN');

    col := colAtual;

    repeat
        y := 5 + cartasCol[col];
        if cartasCol [col] = 0 then
            y := y + 1;

        textBackground (blue);
        gotoxy (9*(col+1)+3 , y);
        write ('/\');

        mensagem ('');
        if cartasCol [col] = 0 then
            mensCont ('PAVAZIO')  { vazio }
        else
            mensCarta (coluna [col, cartasCol [col]]);

        c := readkey;
        c2 := #$0;
        if c = #$0 then
            c2 := readkey;

        gotoxy (9*(col+1)+3 , y);
        textBackground (BLUE);
        write ('  ');

        gotoxy (30, 25);
        textBackGround (RED);
        clreol;

        if c = #$0 then
            begin
                case c2 of
                    DIR:  begin
                              if col < 7 then
                                  col := col + 1
                              else
                                  sintBip;
                          end;

                    ESQ:  begin
                              if col > 1 then
                                  col := col - 1
                              else
                                  sintBip;
                          end;
                else
                    erro;
                end;

                clreol;
            end
        else
        if c = #$1b then
             begin
                 mensagem ('PADESIST');
                 mostraTela;
                 exit;
             end
        else
        if c <> #$0d then
            erro;

    until c = #$0d;

    valorOrig := coluna [colAtual, linAtual] shr 3;
    naipeOrig := coluna [colAtual, linAtual] and 7;

    if cartasCol [col] <> 0 then
        begin
            valorDest := coluna [col, cartasCol [col]] shr 3;
            naipeDest := coluna [col, cartasCol [col]] and 7;

            if (not naipesCompativeis (naipeOrig, naipeDest)) or
               (valorDest - 1 <> valorOrig) then
                begin
                    sintSom ('PAEFEIT2');
                    mensagem ('PADESINV');  { Destino invalido, comando cancelado }
                    sintSom ('PAEFEIT3');
                    falaSelec;
                    exit;
                end;
        end
    else
        begin
            if valorOrig <> 13 then     { rei para coluna vazia }
                begin
                    sintSom ('PAEFEIT2');
                    mensagem ('PADESINV');  { Destino invalido, comando cancelado }
                    sintSom ('PAEFEIT3');
                    falaSelec;
                    exit;
                end;
        end;

    aMover := cartasCol [colAtual] - linAtual + 1;
    ind1 := linAtual;
    ind2 := cartasCol [col] + 1;
    for i := 0 to aMover-1 do
        begin
            coluna [col, ind2+i] := coluna [colAtual, ind1+i];
            coluna [colAtual, ind1+i] := 0;
        end;
    
    inc (cartasCol [col], aMover);
    dec (cartasCol [colAtual], aMover);
    if (fechadasCol [colAtual] = cartasCol [colAtual]) and
       (fechadasCol [colAtual] > 0) then
           dec (fechadasCol [colAtual]);

    mostraTela;

    sintSom ('PAEFEIT4');
    if cartasCol [colAtual] = 0 then  { se toda coluna movida }
        mensagem ('PAMOVVAZ')  { 'Movi e coluna ficou vazia }
    else
        begin
            y := cartasCol [colAtual];
            mensagem ('PAMOVABR');   { Movi e abri }
            mensCarta (coluna [colAtual, y]);
        end;

    colAtual := col;
    linAtual := fechadasCol [colAtual]+1;

    sintSom ('PAEFEIT3');
    mensagem ('PAAGORA');
    mostraSelecTela;
end;

{-------------------------------------------------------}
{           le as tres ultimas cartas dadas
{--------------------------------------------------------}

procedure le3CartasTiradas;
var i: integer;
begin
    if ncTiradas = 0 then
        mensagem ('PANAOTIR')   { Nao existem cartas tiradas }
    else
        begin
            mensagem ('PAULTTIR');
            for i := 3 downto 1 do
                if nctiradas >= i then
                    begin
                        mensCarta (tiradas [ncTiradas-i+1]);
                        write (' ');
                    end;
        end;
end;

{--------------------------------------------------------}
{                    da tres cartas
{--------------------------------------------------------}

procedure da3Cartas;
var i: integer;
begin
    if ncBaralho = 0 then
        begin
            if ncTiradas = 0 then
                begin
                    sintSom ('PAEFEIT2');
                    mensagem ('PAACABAC');  { Acabaram-se todas as cartas }
                    exit;
                end
            else
                begin
                    mensagem ('PARETBAR');  { Retornando o maco do baralho }
                    sintSom ('PAEFEIT1');
                    ncBaralho := ncTiradas;
                    ncTiradas := 0;
                    for i := 1 to ncBaralho do
                        baralho [i] := tiradas [ncBaralho-i + 1];

                    mostraBaralho;
                end;
        end;

    mensagem ('PATIRADO');    { Tirado }
    for i := 3 downto 1 do
        if ncBaralho >= 1 then
            begin
                ncTiradas := ncTiradas + 1;
                tiradas [ncTiradas] := baralho [ncBaralho];
                ncBaralho := ncBaralho - 1;

                mostraBaralho;

                textBackGround (RED);
                gotoxy (20-i*4, 25);
                mensCarta (tiradas [ncTiradas]);
                write (' ');
            end;


    if ncBaralho = 0 then
        begin
            sintSom ('PAEFEIT1');
            mensagem ('PAFIMBAR');   { Fim do baralho }
        end;

    mostraBaralho;
end;

{--------------------------------------------------------}
{               move do baralho para coluna
{--------------------------------------------------------}

procedure moveBaralhoParaColuna;
var naipep, valorp, naipe, valor: byte;

label moveCarta, deNovo;

begin

deNovo:
    textBackGround (RED);
    gotoxy (1, 25); clreol;

    if ncTiradas = 0 then
        begin
            mensagem ('PANAOTIR');   { Nao ha cartas tiradas }
            exit;
        end;

    valorp := tiradas [nctiradas] shr 3;
    naipep := tiradas [nctiradas] and 7;

                           { caso especial, rei colocado em coluna vazia }

    if (valorp = 13) and
       (cartasCol [colAtual] = 0) then goto moveCarta;

    valor := ultimaCarta shr 3;
    naipe := ultimaCarta and 7;

    if not naipesCompativeis (naipe, naipep) then
        begin
            sintSom ('PAEFEIT3');
            mensagem ('PANAIINC'); { Naipes incompativeis }
            exit;
        end;

    if valor - valorp <> 1 then
        begin
            sintSOm ('PAEFEIT3');
            mensagem ('PACARINC'); { Carta incompativel, nao posso mover }
            exit;
        end;

moveCarta:
    inc (cartasCol [colAtual]);
    coluna [colAtual, cartasCol [colAtual]] := tiradas [ncTiradas];
    ncTiradas := ncTiradas - 1;

    linAtual := fechadasCol [colatual]+1;   { seleciona tudo }

    mostraTela;

    mensagem ('PANOBAR');     { No baralho agora }
    if ncTiradas <> 0 then
        mensCarta (tiradas[ncTiradas])
    else
        mensCont ('PANADA');  { nada }

    sintSom ('PAEFEIT3');
    mensagem ('PAAGORA');
    mostraSelecTela;
end;

{--------------------------------------------------------}
{               move do baralho para pilha
{--------------------------------------------------------}

procedure moveBaralhoParaPilha;
var
    valor, naipe: byte;
begin
    if ncTiradas = 0 then
        begin
            mensagem ('PANAOTIR');
            exit;
        end;

    valor := tiradas [nctiradas] shr 3;
    naipe := tiradas [nctiradas] and 7;

    if valor - (pilha [naipe] shr 3) <> 1 then
        begin
            mensagem ('PANAOPOS');  { Nao posso, na pilha tem }
            mensCarta (pilha [naipe] or naipe);
            exit;
        end
    else
        begin
            mensagem ('PAMOVBAR');
            mensCarta (tiradas [ncTiradas]);
            pilha [naipe] := tiradas [ncTiradas];
            dec (ncTiradas);
        end;

    mostraBaralho;
    mostraTela;

    mensagem ('PANOBAR');     { No baralho agora }
    if ncTiradas <> 0 then
        mensCarta (tiradas[ncTiradas])
    else
        mensCont ('PANADA');  { nada }

    sintSom ('PAEFEIT3');
    mensagem ('PAAGORA');
    mostraSelecTela;
end;

{--------------------------------------------------------}
{                      cancela o jogo
{--------------------------------------------------------}

procedure cancelaJogo;
var c: char;
begin
    mensagem ('PACNFFIM');  { Confirma fim desta partida (sim ou nao) ? }
    c := readkey;
    write (c);
    sintCarac (c);

    if upcase(c) = 'S' then
        jogando := false;
end;

{--------------------------------------------------------}
{                        indica Erro
{--------------------------------------------------------}

procedure erro;
begin
    mensagem ('PAOPCERR');  { Opcao errada, aperte F1 para ajuda }
end;

{--------------------------------------------------------}
{                       ajuda
{--------------------------------------------------------}

procedure ajuda;
begin
    mensAjuda;

    cabecalho;
    mostraTela;
    mostraSelecTela;
end;

{--------------------------------------------------------}
{                 ve se partida terminou
{--------------------------------------------------------}

function jogoTerminou: boolean;
var terminou: boolean;
begin
    terminou := ((pilha [COPAS]   shr 3) = 13) and
                ((pilha [OUROS]   shr 3) = 13) and
                ((pilha [ESPADAS] shr 3) = 13) and
                ((pilha [PAUS]    shr 3) = 13);

    jogoTerminou := terminou;
    if terminou then
        begin
            fazAFesta;
            repeat readkey;
            until not keypressed;
        end;
end;

{--------------------------------------------------------}
{                 ve se terminou tudo
{--------------------------------------------------------}

function veSeSai: boolean;
var c: char;
begin
    mensagem ('PADENOVO');  { Quer jogar de novo (sim ou nao) ? }
    repeat
        c := readkey;
    until not keypressed;
    write (c);
    sintCarac (c);

    veSeSai := upcase(c) <> 'S';
end;

{--------------------------------------------------------}
{               processa os controles
{--------------------------------------------------------}

procedure processaControles;
var c: char;
begin
    c := readkey;
    case c of
        F1:   ajuda;
        F8:   mostraTempo;

        DIR:  proximaColuna;
        ESQ:  colunaAnterior;
        CIMA: sobeNaColuna;
        BAIX: desceNaColuna;

        PGUP: leTodaColuna;
        PGDN: lePilhasNaipes;

        HOME: leSelec;
        TEND: le3CartasTiradas;

        INS:  jogaDaPilhaNaColuna;
        DEL:  jogaDaColunaNaPilha;
    else
        erro;
    end;
end;

{--------------------------------------------------------}
{                    programa principal
{--------------------------------------------------------}

var c: char;
    dir: string;
begin
    dir := sintAmbiente('PACIENCIA', 'DIRPACIENCIA');
    if dir = '' then
        dir := 'c:\winvox\som\pacienci';
    sintinic (0, dir);
    textColor (white);

    saiDoProg := false;
    checkFocus := true;

    repeat
        inicializa;

        jogando := true;
        while jogando do
            begin
                c := readkey;
                case upcase(c) of
                    GOTFOCUS: mostraTela;
                    #$0:    processaControles;
                    ENTER:  moveParaOutraColuna;
                    TAB:    da3Cartas;
                    ' ':    moveBaralhoParaColuna;
                    BS:     moveBaralhoParaPilha;
                    ESC:    cancelaJogo;
                else
                    erro;
                end;

                if jogando then
                     jogando := not JogoTerminou;

            end;

        saiDoProg := veSeSai;

    until saiDoProg;

    mensagem ('PAFIM');
    textMode (co80);
    sintFim;
    doneWinCRT;
end.
