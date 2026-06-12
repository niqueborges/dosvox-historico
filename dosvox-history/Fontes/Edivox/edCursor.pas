{--------------------------------------------------------}
{
{    Funcoes de manipulacao do cursor
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edCursor;

interface

uses
    DVcrt, DVWin, Windows,
    edDesFaz,
    edBraille,
    edvars, edUtil, edMensag, edTela, edEmbel, sysUtils, edDocUti;

Procedure compactaLinha (posy: integer);
procedure cmdCursor;
procedure insereLetra (letra: char);
Procedure removeLetra (falaDel, falaLetra: boolean);
Procedure removeProxLetra (falaDel, falaLetra: boolean);
procedure removeAreaMarcada;

Procedure SetaEsq;
Procedure SetaDir;
function SetaBaixo (selecionando: boolean): boolean;
function  SetaCima (selecionando: boolean): boolean;
Procedure SetaVertBaixo (falarRestoLinha: boolean);
Procedure SetaVertCima (falarRestoLinha: boolean);

Procedure inicioTexto;
Procedure fimTexto;
procedure coluna1;
procedure ultimaColuna;
Procedure pulaPag (selecionando: boolean);
Procedure voltaPag (selecionando: boolean);
Procedure avancaParag (paragrafo,falarTotalLinhas: boolean);
Procedure recuaParag (paragrafo, falarTotalLinhas: boolean);
Procedure posicEmLinha;

Procedure palavraDir (falando: boolean);
Procedure palavraEsq (falando: boolean);

Procedure apagaPalavra;
Procedure apagaFimlinha;
Procedure apagaIniciolinha;

Procedure informaLinha (posAtual, totalLinhas: integer; falarLido: boolean);
Procedure informaColuna;

implementation

{--------------------------------------------------------}

Procedure compactaLinha (posy: integer);
var
    t, tamOrig: integer;
    s: string;
begin
    tamOrig := length (texto[posy]);
    if (tamOrig = 0) or (texto[posy][tamOrig] <> ' ') then
        exit;

    s := texto [posy];
    t := tamOrig;
    if t > 0 then
        begin
            while (t > 0) and (s[t] = ' ') do  t := t - 1;
            s := copy (s, 1, t);
        end;

    texto [posy] := s;
end;

{--------------------------------------------------------}

procedure insereLetra (letra: char);
var s: string;
begin
    s := texto[posy];
    if posx <= length (s) then
        insert (letra, s,  posx)
    else
        s := s + letra;

    texto [posy] := s;

    posx := posx + 1;

    escreveLinha;

    if (length(texto[posy]) > margDir) then
        if (quebraAuto and (letra <> ' ') and (posx > margDir)) then
            ajusteAutomatico
        else
        if quebraAuto then
            sintBip;

    if soletrando then
        sintCarac (letra);
end;

{--------------------------------------------------------}

Procedure removeLetra (falaDel, falaLetra: boolean);
var c: char;
    s, s2: string;
begin
    If posx > 1 Then
        begin
            s := texto[posy];
            s2 := obtemFormatacao (copy (s, 1, posx-1));
            if sintFalarTudo and falaDel then fala ('EDDEL');
            if s2 <> '' then
                begin
                    posx := posx - length (s2);
                    delete (s, posx  , length(s2));
                    sintTextoFormatado (s2);
                end
            else
                begin
                    c := s[posx-1];
                    delete (s, posx-1, 1);
                    dec(posx);
                    if falaLetra then sintCarac (c);
                end;

            texto[posy] := s;

            escreveLinha;
        end
    else
        sintBip;
end;

{--------------------------------------------------------}

Procedure removeProxLetra (falaDel, falaLetra: boolean);
begin
    If posx <= length(texto[posy]) Then
        begin
            posx := posx + 1;
            removeLetra (falaDel, falaLetra);
        end
    else
        sintBip;
end;

{--------------------------------------------------------}

procedure removeAreaMarcada;
var i, n: integer;
begin
    gravarDesfazer;
    posx := iniMarca;
    n := fimMarca-iniMarca;
    iniMarca := 0;
    fimMarca := 0;
    for i := 1 to n do
       begin
           if (i = 4) and (n >= 5) then
               begin
                   sintClek; sintclek;
               end;

           removeProxLetra (i=1, I<5);
       end;
end;

{--------------------------------------------------------}

Procedure SetaEsq;
var c: char;
Begin
    if posx > 1 then
        begin
            posx := posx - 1;
            gotoxy (posx-deslocEsqTela, 15);
            c := texto[posy][posx];
            if c = #$09 then
                SintSom('EDTECTAB') {'Tab'}
            else
                sintCarac(c);
        end
    else
        sintBip;
end;

{--------------------------------------------------------}

Procedure SetaDir;
var c: char;
Begin
    if posx <= length(texto [posy]) then
        begin
            posx := posx + 1;
            gotoxy (posx-deslocEsqTela, 15);
            c := texto[posy][posx-1];
            if c = #$09 then
                SintSom('EDTECTAB') {'Tab'}
            else
            if (modoSoletrar = SOLETRABRAILLE) or (modoSoletrar = SOLETRAAMERICANBRAILLE) then {Soletrando pontos braille }
                soletraPontosBraille(c, modoSoletrar)
            else
            if (not (c in ['A'..'Z', 'a'..'z'])) or
               (getKeyState (vk_Menu) >= 0) then
                sintCarac(c)
            else
                sintSom('_FON' + intToStr(ord(c)));
        end
    else
        sintBip;
end;

{--------------------------------------------------------}

procedure falaEspacosNaFrente;
var
    i: integer;
begin
    if (not falaEspacos) or (texto[posy] = '') then exit;
    for i := 1 to length(texto[posy]) do
        if texto[posy][i] <> ' ' then break;
    dec(i);
    if i > 0 then
        begin
            sintetiza (intToStr(i));
            sintClek;
        end;
end;

{--------------------------------------------------------}

procedure shiftSetaBaixo;
var posyAux: integer;
begin
    if (inibloco <= fimbloco) and(posy = (iniBloco -1)) then
        begin
            inc(iniBloco);
            posyAux := posy + 1;
            if posyAux  > maxLinhas then posyAux := maxLinhas;
            if length(trim(texto[posyAux])) = 0 then sintBip
            else sintTextoFormatado (texto[posyAux]);
            fala ('EDDESSEL'); {'deselecionado'}
        end
    else
        begin
            if (inibloco > fimbloco) or ((fimBloco + 1) <> posy) then inibloco := posy;
            fimbloco := posy;
            if length(trim(texto[posy])) = 0 then sintBip
            else sintTextoFormatado (texto[posy]);
            fala ('EDSELECI'); {'Selecionado'}
        end;
end;

{--------------------------------------------------------}

function SetaBaixo (selecionando: boolean): boolean;
begin
    if selecionando then shiftSetaBaixo;

    if posy < maxlinhas then
        begin
            compactaLinha (posy);
            posy := posy + 1;
        end
    else
        begin
            limpaBufTec;
            fala ('EDFIMTEX');
        end;

    if not selecionando then falaEspacosNaFrente;
    posx := 1;

    result := selecionando;
end;

{--------------------------------------------------------}

procedure shiftSetaCima;
var posyAux: integer;
begin
    if (inibloco <= fimbloco) and(posy = (fimBloco +1)) then
        begin
            dec(fimbloco);
            posyAux := posy - 1;
            if posyAux  < 1 then posyAux := 1;
            if length(trim(texto[posyAux])) = 0 then sintBip
            else sintTextoFormatado (texto[posyAux]);
            fala ('EDDESSEL'); {'deselecionado'}
        end
    else
        begin
            if (inibloco > fimbloco) or ((iniBloco- 1) <> posy) then fimBloco := posy;
            iniBloco := posy;
            if length(trim(texto[posy])) = 0 then sintBip
            else sintTextoFormatado (texto[posy]);
            fala ('EDSELECI'); {'Selecionado'}
        end;
end;

{--------------------------------------------------------}

function  SetaCima (selecionando: boolean): boolean;
begin
    if selecionando then shiftSetaCima;

    If posy > 1 then
        begin
            compactaLinha (posy);
            posy := posy - 1;
            posx := 1;
        end
    else
        begin
            limpaBufTec;
            fala ('EDINITEX');
        end;

    if not selecionando then falaEspacosNaFrente;
    posx := 1;

    result := selecionando;
end;

{--------------------------------------------------------}

Procedure SetaVertBaixo (falarRestoLinha: boolean);
var
    s: string;

begin
    if posy < maxlinhas then
        begin
            compactaLinha (posy);
            posy := posy + 1;
            sintetiza (intToStr(posx));
            sintclek;

            s := texto[posy];
            while (posx-1) > length(s) do
                s := s + ' ';
            texto[posy] := s;
            if posx > length (texto[posy]) then
                sintCarac (' ')
            else
            if falarRestoLinha then
                sintTextoFormatado (copy(s, posx, length(s)))
            else
                sintCarac (texto[posy][posx]);
        end
    else
        begin
            limpaBufTec;
            fala ('EDFIMTEX');
        end;
end;

{--------------------------------------------------------}

Procedure SetaVertCima (falarRestoLinha: boolean);
var
    s: string;

begin
    sintetiza (intToStr(posx));
    sintclek;

    If posy > 1 then
        begin
            compactaLinha (posy);
            posy := posy - 1;

            s := texto[posy];
            while (posx-1) > length(s) do
                s := s + ' ';
            texto[posy] := s;
            if posx > length (texto[posy]) then
                sintCarac (' ')
            else
            if falarRestoLinha then
                sintTextoFormatado (copy(s, posx, length(s)))
            else
                sintCarac (texto[posy][posx]);
        end
    else
        begin
            limpaBufTec;
            fala ('EDINITEX');
        end;
end;

{--------------------------------------------------------}

procedure coluna1;
begin
    posx := 1;
    sintClek;
end;

{--------------------------------------------------------}

procedure ultimaColuna;
begin
    posx := length( texto [posy])+1;
    sintClek;
end;

{--------------------------------------------------------}

Procedure inicioTexto;
begin
    posy := 1;
    posx := 1;
    fala ('EDINITEX');
    delay (100);
end;

{--------------------------------------------------------}

Procedure fimTexto;
begin
    posy :=maxlinhas;
    posx := 1;
    fala ('EDFIMTEX');
    delay (100);
end;

{--------------------------------------------------------}

Procedure pulaPag (selecionando: boolean);
begin
    posx := 1;
    if selecionando and (fimBloco <> posy) then iniBloco := posy;
    posy:=posy + 15;
    if selecionando then
        begin
            fimBloco := posy;
            fala ('EDSELECI'); {'Selecionado'}
        end;

    If posy > maxlinhas Then
        begin
            posy:=maxlinhas;
            if selecionando then fimBloco := posy;
            limpaBufTec;
            fala ('EDFIMTEX');
        end
    else
        begin
            sintClek;  sintClek;
        end;
end;

{--------------------------------------------------------}

Procedure voltaPag (selecionando: boolean);
var  aux : integer;
begin
    posx := 1;
    if selecionando and (iniBloco <> posy) then fimBloco := posy;
    aux  := posy - 15;
    if selecionando then fala ('EDSELECI'); {'Selecionado'}
    If aux < 1 Then
        begin
            posy := 1;
            limpaBufTec;
            fala ('EDINITEX');
        end
     Else
        begin
            posy :=  aux ;
            sintClek;  sintClek;
        end;
    if selecionando then iniBloco := posy;
end;

{--------------------------------------------------------}

Procedure avancaParag (paragrafo, falarTotalLinhas: boolean);
var
    salvaPosY: integer;
begin
    salvaPosY := posy;
    if paragrafo and (posy < maxlinhas) then inc(posy);
    sintClek;

    if texto [posy] = '' then
        inc(posy)
    else
        while (posy <= maxlinhas) and (trim(texto[posy]) <> '') and
            ((texto[posy][1] <> ' ') or (not paragrafo))  do inc(posy);

    while (posy <= maxlinhas) and (trim(texto[posy]) = '') do inc(posy);

    posx := 1;
    If posy > maxlinhas Then
        begin
            posy := maxlinhas;
            limpaBufTec;
            fala ('EDFIMTEX');
        end
    else
    if posy - salvaPosY > 2 then
        sintClek;

    if falarTotalLinhas and ((posy - salvaPosY - 1) > 0) then sintetiza (intToStr(posy - salvaPosY - 1));
end;

{--------------------------------------------------------}

Procedure recuaParag (paragrafo, falarTotalLinhas: boolean);
var salvaPosY: integer;
begin
    salvaPosY := posy;
    dec(posy);
    sintClek;

    while (posy > 0) and (trim(texto[posy]) = '') do dec(posy);

    while (posy > 0) and (trim(texto[posy]) <> '') and
            ((texto[posy][1] <> ' ') or (not paragrafo))  do dec(posy);

    if posy < 1 then
        begin
            posy := 1;
            limpaBufTec;
            fala ('EDINITEX');
        end
    else
        begin
            if not paragrafo  then
                inc(posy);
            if salvaPosY - posy > 2 then
                sintClek;
        end;

    if falarTotalLinhas and ((salvaPosY - posy - 1) > 0) then sintetiza (intToStr(salvaPosY - posy - 1));
end;

{--------------------------------------------------------}

Procedure palavraDir (falando: boolean);
var
    linha: string;
    tam: integer;
    c: char;
begin
    tam := length (texto [posy]);
    linha := texto [posy] + ' x';

    c := linha[posx];
    if c <> ' ' then
        repeat
            posx := posx + 1;
            c := linha[posx];
        until not (c in ['a'..'z', 'A'..'Z', '0'..'9', #128..#255]);

    if c = ' ' then
        repeat
            posx := posx + 1;
            c := linha[posx];
        until c <> ' ';

    if posx > tam+1 then
        begin
            posx := tam+1;
            if falando then sintBip;
        end
    else
        if falando then {sintClek};
end;

{--------------------------------------------------------}

Procedure palavraEsq (falando: boolean);
var
    linha: string;
    c: char;
begin
    linha := ' x' + texto [posy];
    posx := posx + 2;

    repeat
        posx := posx - 1;
        if posx <= length (linha) then
            c := linha[posx]
        else
            c := ' ';
    until c <> ' ';

    repeat
        posx := posx - 1;
        c := linha[posx];
    until not (c in ['a'..'z', 'A'..'Z', '0'..'9', #128..#255]);

    posx := posx - 1;

    if posx <= 0 then
        begin
            posx := 1;
            if falando then sintBip;
        end
    else
        if falando then {sintClek};
end;

{--------------------------------------------------------}

Procedure posicEmLinha;
var num : Integer;
Begin
    num := 0;
    fala ('EDDGNLIN'); { Digite o numero da linha }
    sintReadInt (num);

    if (num > maxLinhas) or (num < 1) then
        fala ('EDLINAO')    { Linha nao existe! }
    else
        begin
            posy := Num;
            posx := 1;
            sintClek;
        end;
end;

{--------------------------------------------------------}

Procedure apagaPalavra;
var
    x, x1, x2: integer;
    s, s2: string;
begin
    posx := posx + 1;
    palavraEsq (false);
    x1 := posx;
    palavraDir (false);
    x2 := posx;

    if x1 <> x2 then
        begin
            gravarDesfazer;
            s := texto[posy];
            s2 := s;   {para falar depois}

            delete (s, x1, x2-x1);
            texto[posy] := s;
            posx := x1;

            escreveTela;

            if sintFalarTudo then sintSom ('EDDEL');
            for x := x1 to x2-1 do
                sintCarac (s2[x]);
        end
    else
        sintBip;
end;

{--------------------------------------------------------}

Procedure apagaFimlinha;
var
    s: string;
begin
    gravarDesfazer;
    s := texto [posy];
    if posx = 1 then
        s := ''
    else
        s := copy (s, 1, posx-1);

    texto[posy] := s;

    fala ('EDAPAFIM');
end;

{--------------------------------------------------------}

Procedure apagaIniciolinha;
var
    s: string;
begin
    gravarDesfazer;
    s := texto [posy];

    delete (s, 1, posx-1);
    texto[posy] := s;

    posx := 1;
    fala ('EDAPAINI');
end;

{--------------------------------------------------------}

Procedure informaLinha (posAtual, totalLinhas: integer; falarLido: boolean);
begin
    fala ('EDLINHA');
    escreveNumero (posAtual);
    if not keypressed then delay (50);
    falaSeguinte ('EDDE'); {'de'}
    if not keypressed then delay (50);
    escreveNumero (totalLinhas);
    if not keypressed then delay (100);
////    if falarLido then falaSeguinte ('EDLIDO'); {'lido'}
    escreveNumero ((posAtual*100)div totalLinhas);
    sintWrite ('%');
    delay (100);
end;

{--------------------------------------------------------}

Procedure informaColuna;
var totalColunas: integer;
begin
    totalColunas := length(texto [posy]);
    fala ('EDCOLUNA');
    escreveNumero (posx);
    if totalColunas > posx then
        begin
            if not keypressed then delay (50);
            falaSeguinte ('EDDE'); {'de'}
            if not keypressed then delay (50);
            escreveNumero (totalColunas);
        end;
    if not keypressed then     delay (100);
end;

{--------------------------------------------------------}

procedure memorizaPoscur;
begin
    salvaCurx := posx;
    salvaCury := posy;
end;

{--------------------------------------------------------}

procedure voltaPoscur;
begin
    posx := salvaCurx;
    posy := salvaCury;
    if posy > maxLinhas then posy := maxlinhas;
    if posx > length (texto[posy])+1 then
        posx := 1;

    escreveTela;
end;

{--------------------------------------------------------}

Procedure cmdCursor;
var
    c1, c2: char;
    apertouShift: boolean;
label deNovo;
begin
    fala ('EDOPCAO');   { qual opcao ? }
    c1 := leTeclaMaiusc(c2);
    apertouShift := GetKeyState(VK_SHIFT) < 0;

deNovo:
    escreveTela;

    case c1 of
        '-': inicioTexto;
        '+': fimTexto;
        'A': avancaParag (true, apertouShift);
        'R': recuaParag (true, apertouShift);
        'P': posicEmLinha;
        'I': apagaIniciolinha;
        'F': apagaFimlinha;
        'L': informaLinha (posy, maxLinhas, true);
        'C': informaColuna;
        'M': memorizaPoscur;
        'V': voltaPoscur;
        'N': avancaParag (false, apertouShift);
        'E': recuaParag (false, apertouShift);

       #$0: begin
                c1 := ajuda (c2, 'EDAJCU', 14);
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
