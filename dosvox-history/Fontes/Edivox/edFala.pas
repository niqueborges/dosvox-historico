{--------------------------------------------------------}
{
{    Controle da Fala
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edFala;

interface
uses
    Dvcrt, DvWin, dvWav, windows, sysutils,
    edVars, edTela, edMensag, edDocUti, edDicion;

Procedure cmdFala;
Procedure falaPalavra;
Procedure falaPalavraAntes;
Procedure falaRestoLinha (soletrando: boolean);
Procedure falaRestoTexto (soletrando: boolean);
procedure falaAtePonto (soletrando: boolean);

implementation

{--------------------------------------------------------}

function isolaPalavra: string;
Var
    j  : integer;
    f, palavra : String;

const
    alfa: set of char = ['a'..'z','A'..'Z', #128..#255];
    numeros: set of char = ['0'..'9'];
Begin
    f := texto[posy];

    palavra :='';
    isolaPalavra := '';
    If (posx > length(f)) or (length(f)=0)
        Then exit;

    j := posx;
    while (j < length(f)) and (f[j] = ' ')  Do
        inc (j);

    if f[j] = '<' then
        palavra := obtemFormatacaoPos (copy(f, j, length(f)-j+1));

    if palavra <> '' then
        j := j + length (palavra)
    else
    if not (f[j] in alfa) then
        begin
           If f[j] in numeros then
               Begin
                   while (j<=length(f)) and (f[j] in numeros) do
                       begin
                           palavra := palavra + f[j];
                           inc(j);
                       end;
               End
           Else
               begin
                   palavra := f[j];
                   inc(j);
               end;
        end
    else
        begin
            while  (j<=length(f)) and (f[j] in alfa) do
                begin
                    palavra:=palavra+ f[j];
                    inc (j);
                end;
        end;

    isolaPalavra := palavra;
    posx := j;
end;

{--------------------------------------------------------}

procedure soletraPalavra;
var palavra: string;
begin
    if mudo then exit;

    palavra := isolaPalavra;
    sintsoletra (palavra);
end;

{--------------------------------------------------------}

procedure falaPalavra;
var palavra: string;
begin
    if mudo then exit;

    if posx <= 80 then
        gotoxy (posx, 15)
    else
        gotoxy (80, 15);

    palavra := isolaPalavra;
    if palavra = ' ' then
        sintclek
    else
    if length (palavra) > 0 then
        sintTextoFormatado (palavra)
    else
        sintBip;
end;

{--------------------------------------------------------}

Procedure falaPalavraAntes;
var
    s, palavra: string;
    i: integer;
begin
    if (posy < 1) or (posx <= 1) then exit;
    s := texto[posy];
    s := trim(copy (s, 1, posx - 1));
    palavra := '';
    for i := length (s) downto 1 do
        if (s[i] in LETRAS_DE_PALAVRA) or (s[i] in ['0' .. '9']) then
            palavra := s[i] + palavra
        else
            break;

    sintetiza (palavra);
end;

{--------------------------------------------------------}

Procedure falaRestoLinha (soletrando: boolean);
begin
    if mudo then exit;

    queueingWaves := true;
    if length (texto[posy]) = 0 then
        sintBip
    else
//        if sapiPresente then
//            begin
//                sintTextoFormatado (copy (texto[posy], posx, length (texto[posy])));
//                posx := length (texto[posy]^) + 1;
//            end
//       else
//Neno    while (posx <= length (texto[posy])) and (not keypressed) do
//        if soletrando then
//            begin
//                sintSoletra (texto[posy][posx]);
//                posx := posx + 1;
//            end
//        else
//            falaPalavra;
        if soletrando then
            sintSoletra (copy(texto[posy], posx, length(texto[posy])))
        else
            sintTextoFormatado (copy (texto[posy], posx, length (texto[posy])));

    if posx > (length (texto[posy]) +1) then posx := length (texto[posy]) +1;

    queueingWaves := false;
    while sintFalando do waitMessage;
    if keypressed and comSapi then sintPara; //Neno, inclusão do comSapi para acertar o travamento ao teclar F5.
end;

{--------------------------------------------------------}

procedure falaInicioLinha;
var salva: integer;
begin
    if mudo then exit;

    queueingWaves := true;
    if length (texto[posy]) = 0 then
        sintBip
    else
        begin
            salva := posx;
            posx := 1;
            while (posx+1 < salva) and (not keypressed) do
                    falaPalavra;
            posx := salva;
        end;
    queueingWaves := false;
    while sintFalando do waitMessage;
end;

{--------------------------------------------------------}

procedure falaAtePontuacao (soletrando: boolean; var chegouAoFim: boolean);
var
    s, s2: string;
    p: integer;
label fimTexto;

label fimFala;

begin
    chegouAoFim := false;

    if mudo then
        begin
            chegouAoFim := true;
            exit;
        end;

    if posy > maxLinhas then goto fimTexto;

    if posx > length(texto[posy]) then   { ignora fim de linha e linhas em branco }
        begin
            posx := 1;
            posy := posy + 1;
        end;

    while (posy <= maxLinhas) and (texto[posy] = '') do
        begin
            posy := posy + 1;
        end;

    if posy > maxLinhas then goto fimTexto;

    s := '';
    repeat
        s2 := texto[posy] + ' ';    // faz com que tenha sempre um espaço no final

        for p := posx to length (s2) do
            begin
                s := s + s2[p];

                if s2[p] in ['.', '!', '?', ':', ';', '<'] then
                    begin
                        if s2[p+1] = ' ' then   // tem que ter espaço depois para encerrar
                            begin
                                posx := p+1;
                                goto fimFala;
                            end;
                    end;
            end;

        posy := posy + 1;
        posx := 1;

    until (posy > maxLinhas) or (texto[posy] = '') or (texto[posy][1] = ' ');

fimFala:
    queueingWaves := true;
    if soletrando then
        sintSoletra (s)
    else
        sintTextoFormatado (s);

    while sintFalando do waitMessage;
    queueingWaves := false;

fimTexto:
    if (posy > maxLinhas) or (posx > length (texto[posy])) then
        begin
            posx := 1;
            posy := posy + 1;
        end;

    if posy > maxLinhas then
        begin
            posy := maxLinhas;
            posx := length (texto[posy])+1;
            while sintFalando do waitMessage;
            fala ('EDFIMTEX');
            chegouAoFim := true;
        end;
end;

{--------------------------------------------------------}

procedure falaAtePonto (soletrando: boolean);
var dummy: boolean;
begin
    falaAtePontuacao (soletrando, dummy);
end;

{--------------------------------------------------------}

Procedure falaRestoTexto (soletrando: boolean);
var chegouAoFim: boolean;
label fim;
begin
    if mudo then exit;

    queueingWaves := true;
    sintFalaPont := falaPontuacao;

    repeat
        if posx <= 80 then
            gotoxy (posx, 15)
        else
            gotoxy (80, 15);

        falaAtePontuacao (soletrando, chegouAoFim);
        escreveTela;
        if posy > maxLinhas then
            break
        else
            delay (200);

    until chegouAoFim or keypressed;

fim:
    sintFalaPont := true;

    if posy > maxLinhas then
        begin
            posy := maxLinhas;
            posx := length (texto[posy])+1;
        end;

    queueingWaves := false;
    while sintFalando do waitMessage;

    if not somenteLeitura then
        while keypressed do readkey;
end;

{--------------------------------------------------------}

Procedure cmdFala;
var
    c1, c2: char;
label deNovo;
begin

    fala ('EDOPCAO');   { qual opcao ? }
    c1 := leTeclaMaiusc(c2);

deNovo:
    escreveTela;

    case c1 of

       #$0d, 'F',
             'L': falaRestoLinha (false);
             'T': falaRestoTexto (false);
             'I': falaInicioLinha;
             'P': falaAtePonto (false);

       #$0: begin
                c1 := ajuda (c2, 'EDAJFA', 4);
                goto deNovo;
            end;
      #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    end;

    escreveTela;
end;

{--------------------------------------------------------}
begin
end.
