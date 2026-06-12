{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de controle da tela
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit pltela;
interface
uses
    dvcrt, dvwin, plvars;

procedure cabecalho;
procedure mostraCabColunas;
procedure mostraLinha (y: integer);
procedure mostraTela;
function criaStringSaida (x, y: integer): string;

implementation
uses plBloco;

{--------------------------------------------------------}
{      ve posicao de uma celula da planilha na tela
{--------------------------------------------------------}

procedure calcPosTela (coluna, linha: integer; var x, y: integer);
var i: integer;
begin
    x := 5;
    if coluna > MAXCELLINHA then
        x := 9999
    else
        for i := xcelTela to coluna-1 do
            x := x + col[i].largcoluna;
    y := 5 + linha-ycelTela;
end;

{--------------------------------------------------------}
{               mostra o cabecalho das colunas
{--------------------------------------------------------}

procedure mostraCabColunas;
var xc, yc, xt, yt, i: integer;
    nome: string;
begin
    xc := xcelTela;
    yc := ycelTela-1;
    calcPosTela (xc, yc, xt, yt);
    repeat
         gotoxy (xt, yt);

         nome := '';
         for i := 1 to col[xc].largColuna do
             nome := nome + ' ';
         nome [col[xc].largColuna div 2+1] := chr (ord('A')-1+xc);

         textBackGround (BLUE);
         write (nome);

         xc := xc + 1;
         calcPosTela (xc, yc, xt, yt);
    until (xc > MAXCELLINHA) or (xt+col[xc].largcoluna > 80);
    ultxTela := xc - 1;
    alterouTodaTela := true;

    textBackGround (BLACK);
    clreol;
end;

{--------------------------------------------------------}
{               mostra o cabecalho da planilha
{--------------------------------------------------------}

procedure cabecalho;
begin
    textBackground (BLACK);
    textColor (WHITE);
    clrscr;

    textBackground (BLUE);
    write ('Planilha eletronica VOX - versao ', versao);

    textBackGround (BLACK);
    clreol;
    gotoxy (45, 1);

    textBackGround (BLACK);
    textColor (YELLOW);
    if length(nomePlan) > 21 then
        write ('...', copy (nomePlan, length(nomePlan)-18+1, 18))
    else
        write (nomePlan);

    gotoxy (68, 1);
    textColor (WHITE);
    textBackGround (MAGENTA);
    write (chr (xatual+ord('A')-1), yatual);

    gotoxy (15, 25);
    textBackground (Black);
    write ('Digite Enter para editar campo, F9 para escolher opcao');

    mostraCabColunas;
end;

{--------------------------------------------------------}
{         cria a representacao grafica da saida
{--------------------------------------------------------}

var cd: integer;
    va: real;
    ce: PCELULA;

function criaStringSaida (x, y: integer): string;
var br: string;
    i, nbr: integer;
    fl: word;
    s: string;
begin
    ce := plan[y]^.cel[x];
    va := ce^.valor;
    cd := ce^.casasDec;

    { assume que celula existe }
    with plan[y]^.cel[x]^ do
        begin
            case tipo of
                nada:    s := '';

                letras:  s := conteudo;

                numero:
                        if formato = numerico then
                            str (valor:10:casasDec, s)
                        else
                        if formato = geral then
                             begin
                                 if (valor <= 9999999) and
                                    (valor - trunc(valor) = 0) then
                                     str (valor:10:0, s)
                                 else
                                     str (valor:10:casasDec, s);
                             end
                         else
                             s := conteudo;

                         {****************** completar }

                form:    if tipoResultComput = letras then
                             s := resultComput
                         else
                             if (valor <= 9999999) and
                                    (valor - trunc(valor) = 0) then
                                 str (valor:10:0, s)
                             else
                                 str (valor:10:casasDec, s);      { completar }
            end;

            fl := alinhamento and (alinEsq+alinDir+centrada);
            if (alinhamento = 0) and (tipo=numero) then
                fl := alinEsq;

            if (fl and centrada) <> 0 then
                begin
                    nbr := (col[x].largcoluna - length(s)) div 2;
                    br := '';
                    for i := 1 to nbr do br := br + ' ';
                    s := br + s;
                end
            else
            if ((fl and alinDir) <> 0) then
                begin
                    nbr := col[x].largcoluna - length(s);
                    br := '';
                    for i := 1 to nbr do br := br + ' ';
                    s := br + s;
                end;
        end;

    criaStringSaida := s;
end;

{--------------------------------------------------------}
{                desenha uma linha
{--------------------------------------------------------}

procedure mostraLinha (y: integer);
var xc, xt, yt: integer;
    saida, s: string;
    tam, xiDestaque, tamDestaque: integer;

begin
    if xatual > ultxtela then
        begin
            xceltela := xceltela + 1;
            mostraCabColunas;
        end;

    if xatual < xceltela then
        begin
            xceltela := xceltela - 1;
            mostraCabColunas;
        end;

    textBackGround (BLUE);
    calcPosTela (1, y, xt, yt);
    gotoxy (1, yt);
    write (y:4);

    textBackground (BLACK);

    xc := xcelTela;
    calcPosTela (xc, y, xt, yt);
    gotoxy (xt, yt);

    setLength (saida, 80);
    fillchar (saida[1], 80, ' ');

    xidestaque := 80;
    tamDestaque := 0;
    repeat
        if (plan[y] <> NIL) and (plan[y]^.cel[xc] <> NIL) then
           begin
               with plan[y]^.cel[xc]^ do
                   begin
                       s := criaStringSaida (xc, y);
                       fillchar (saida[xt-4], 80-xt+1, ' ');
                       tam := length (s);
                       if xt+tam > 80 then tam := 80-xt+1;
                       if tam > 0 then
                           move (s[1], saida[xt-4], tam);
                   end;
           end;

        if (xc = xatual) and (y = yatual) then
            begin
                xiDestaque := xt;
                tamDestaque := col[xc].largColuna;
            end;

        xc := xc + 1;
        calcPosTela (xc, y, xt, yt);
    until (xc > MAXCELLINHA) or (xt+col[xc].largcoluna > 80);

    textBackground (BLACK);
    textColor (WHITE);

    xidestaque := xidestaque - 4;
    if xidestaque <> 1 then
        write (copy (saida, 1, xiDestaque-1));

    textBackground (RED);
    textColor (WHITE);
    write (copy (saida, xidestaque, tamDestaque));

    xiDestaque := xiDestaque + tamDestaque;
    textBackground (BLACK);
    textColor (WHITE);
    write (copy (saida, xidestaque, 77-xiDestaque));

    if y = yatual then
        begin
            gotoxy (68, 1);
            clreol;
            textBackGround (MAGENTA);
            write (chr (xatual+ord('A')-1), yatual);
            if plan[yatual] <> NIL then
                if plan[yatual]^.cel[xatual] <> NIL then
                    case plan[yatual]^.cel[xatual]^.tipo of
                       nada:   ;
                       letras: write ('(Alfa)');
                       numero: write ('(Num)');
                       form:   write ('(Form)');
                    end;
        end;

    textColor (WHITE);
    textBackground (BLACK);

    calcPosTela (xatual, yatual, xt, yt);
    gotoxy (xt, yt);
end;

{--------------------------------------------------------}
{                exibe a planilha na tela
{--------------------------------------------------------}

procedure mostraTela;
var i: integer;

    procedure calcUltXtela;
    var xc, yc, xt, yt: integer;
    begin
        xc := xcelTela;
        yc := ycelTela;
        calcPosTela (xc, yc, xt, yt);
        repeat
             xc := xc + 1;
             calcPosTela (xc, yc, xt, yt);
        until (xc > MAXCELLINHA) or (xt+col[xc].largcoluna > 80);
        ultxTela := xc - 1;
    end;

begin
    calcUltXtela;
    while xatual > ultxtela do
        begin
            xceltela := xceltela + 1;
            calcUltXtela;
        end;

    while xatual < xceltela do
        begin
            xceltela := xceltela - 1;
            calcUltXtela;
        end;

    textBackground (BLACK);
    textColor (WHITE);

    mostraCabColunas;
    for i := 0 to 19 do
        mostraLinha (i+ycelTela);

    alterouTodaTela := false;
end;

end.
