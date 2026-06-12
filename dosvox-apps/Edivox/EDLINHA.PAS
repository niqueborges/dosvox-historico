{--------------------------------------------------------}
{
{    Rotinas de tratamento de linhas do EDIVOX
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edLinha;

interface
uses
    DVcrt, DVWin, sysutils, dvForm,
    classes,
    edUtil,
    edDocUti, edvars,  edMensag, edTela;

procedure memorizaLinha;
procedure posicionaNaLinhaMemorizada;
procedure cmdLinha;
Procedure insereLinha (conteudo : String; falando: boolean) ;
Procedure insereProxLinha (conteudo : String; falando: boolean) ;
Procedure Removelinha;
procedure RemoveApenasUmaLinha;
procedure voltaRemovida;
procedure quebraLinha;
procedure insereNaLinha (conteudo: string);
procedure juntaLinhas;

implementation

uses EdDesFaz;

{--------------------------------------------------------}

const maxMemoria = 30;
type tLinhaMemo = array [1..maxMemoria] of integer;
var memoriaLinha: tLinhaMemo;

{--------------------------------------------------------}

procedure memorizaLinha;
var
    i: integer;
    gravou: boolean;
begin
    gravou := false;
    for i := 1 to maxMemoria do
        if memoriaLinha [i] = posy then
            begin
                gravou := true;
                break;
            end;

    if not gravou then
        for i := 1 to maxMemoria do
            if memoriaLinha [i] = 0 then
                begin
                    gravou := true;
                    memoriaLinha [i] := posy;
                    break;
                end;

    if not gravou then
        begin
            for i := 1 to (maxMemoria - 1) do
                memoriaLinha [i] := memoriaLinha [i + 1];
            memoriaLinha [maxMemoria] := posy;
        end;
    fala ('EDLINHA');
    escreveNumero (posy);
    fala ('EDMEMORI'); {'memorizada'}
end;

{--------------------------------------------------------}

procedure posicionaNaLinhaMemorizada;
var
    i, n, qtdMemo, qtdMostra: integer;
begin
    qtdMemo := 0;
    i := 1;
    while i <= maxMemoria do
        if (memoriaLinha [i] > 0) and (memoriaLinha [i] <= maxlinhas)  then
            begin
                qtdMemo := qtdMemo + 1;
                i := i + 1;
            end
        else
        if memoriaLinha [i] > maxlinhas  then
            for n := i to (maxMemoria - 1) do memoriaLinha [n] := memoriaLinha [n + 1]
        else
            i := i + 1;

    if qtdMemo = 0 then
        begin
            sintBip;
            exit;
        end;
    if qtdMemo = 1 then
        posy := memoriaLinha [1]
    else
        begin
            fala ('EDCFVEL'); {'Use as setas para selecionar.'}

    if qtdMemo < 26 then qtdMostra := qtdMemo
    else qtdMostra := 26 - wherey;

            popupMenuCria (35, 10, 44, qtdMostra, RED);
            for i := 1 to qtdMemo do
                popupMenuAdiciona('', intToStr(memoriaLinha [i]) + ' ' + texto[memoriaLinha [i]]);

            n := popupMenuSeleciona;
            if (n > 0) and (n <= qtdMemo) then
                posy := memoriaLinha [n]
            else
                begin
                    sintclek;
                    exit;
                end;
        end;

    escreveNumero (posy);
end;

{--------------------------------------------------------}

Procedure insereLinha (conteudo : String; falando: boolean) ;
Begin
    texto.Insert(posy, conteudo);
    inc (maxlinhas);
    while posy >= texto.count do texto.append('');

    posx := length (conteudo)+1;

    if falando then
        fala ('EDLINSER');

    if posy < inibloco then
        inibloco := inibloco + 1;
    if posy <= fimbloco then
        fimbloco := fimbloco + 1;
    if posy < salvaCury then
        salvaCury := salvaCury + 1;
end;

{--------------------------------------------------------}

Procedure insereProxLinha (conteudo : String; falando: boolean) ;
Begin
    gravarDesfazer;
    posy := posy + 1;
    insereLinha (conteudo, false);

    if falando and (posy < maxlinhas) then
        fala ('EDLINSER');
end;

{-----------------------------}

Procedure Removelinha;
Begin

    If posy< maxlinhas then
        begin
            dec (maxlinhas);
            texto.delete(posy);
        end
    else
        If posy = maxlinhas Then
            texto [posy] := '';

    posx := 1;

    if posy < iniBloco then
        iniBloco := iniBloco - 1;
    if posy <= fimBloco then
        fimBloco := fimBloco - 1;

    if posy = salvaCury then
        begin
            salvaCurx := 1;
            salvaCury := 1;
        end
    else
    if posy < salvaCury then
        salvaCury := salvaCury - 1;
end;

{--------------------------------------------------------}

Procedure RemoveApenasUmaLinha;
begin
    linhaRemovida := texto[posy];
    gravarDesfazer;

    If (posy = maxlinhas) and (posy = 1) Then
        texto [posy] := ''
    else
        begin
            dec (maxlinhas);
            texto.delete(posy);
            if posy > maxlinhas then posy := maxLinhas;
        end;

    posx := 1;

    if posy < iniBloco then
        iniBloco := iniBloco - 1;
    if posy <= fimBloco then
        fimBloco := fimBloco - 1;

    if posy = salvaCury then
        begin
            salvaCurx := 1;
            salvaCury := 1;
        end
    else
    if posy < salvaCury then
        salvaCury := salvaCury - 1;

    fala ( 'EDLINREM' );
end;

{--------------------------------------------------------}

procedure voltaRemovida;
begin
    if linhaRemovida = '' then
        sintBip
    else
        begin
            gravarDesfazer;
            insereLinha (linhaRemovida , true);
        end;
end;

{--------------------------------------------------------}

procedure juntaLinhas;
var linha: string;
    salvax, salvay: integer;
begin
    gravarDesfazer;
    if posy < maxlinhas then
        begin
            if texto[posy] = '' then
                linha :=  texto [posy+1]
            else
                linha := texto [posy] + ' ' + texto [posy+1];
            salvax := posx;  salvay := posy;
            removeLinha;
            texto[posy] := linha;
            posx := salvax;  posy := salvay;
            fala ('EDLINJUN');
        end;
end;

{-----------------------------}

Procedure quebraLinha;
Var
    linha1, linha2: String;
Begin
    If posx = 1 Then
        Begin
            gravarDesfazer;
            insereLinha ('', false);
            posy := posy + 1;
            fala ('EDLINQUE');
        end
    Else
    If posx > length ( texto[posy]) then
        juntaLinhas
    Else
        begin
            gravarDesfazer;
            linha1 := copy (texto [posy], 1, posx-1);
            linha2 := copy (texto [posy], posx, length (texto[posy])-posx+1);
            texto[posy] := linha2;
            insereLinha (linha1, false);
            posy := posy + 1;
            posx := 1;
            fala ('EDLINQUE');
        end;
end;

{--------------------------------------------------------}

procedure editaOuApagaLinha (noInicio, apagaLinha,apagarParteLinha , tiraHifenizacao: boolean);
var
    y, yIni, yFim, salvaY, p, salvaIniBloco, salvaFimBloco: integer;
    contador: integer;
    textoBusc, s: string;
    c: CHAR;

    procedure tiraHifenizacaoLinha (l: integer);
    var
        k: integer;
        s, s2: string;
    begin
        if (l + 1) > maxLinhas then exit;
        s := texto[l];
        if (copy(s,length(s), 1) <> '-') or (length(s) < 2) or (not(s[length(s) - 1] in LETRAS_DE_PALAVRA)) then exit;
        s2 := texto[l + 1];
        if (trim(s2) = '') or (not(s2[1] in LETRAS_DE_PALAVRA)) then exit;
         inc(contador);
        delete (s, length(s), 1);
        k := pos (' ', s2);
        if k > 0 then
            begin
                s := s + copy (s2, 1, (k - 1));
                delete (s2, 1, k);
            end
        else
            begin
                s := s + s2;
                s2 := '';
            end;
        texto[l] := s;
        if trim(s2) <> '' then
            texto[l + 1] := s2
        else
            begin
                posy := l + 1;
                Removelinha;
                posy := l;
                apagaLinha := true;
                if (l +1) <= salvaY then
                    salvaY := salvaY - 1;
            end;
    end;

begin
    if tiraHifenizacao then
        fala ('EDRETHIF') {'Retirando hifenização'}
     else
        repeat
            textoBusc := '';
            if apagaLinha then
                fala ('EDQUATRE') {'Qual o texto das linhas a excluir? '}
            else
            if apagarParteLinha then
                fala ('EDQPEXCLU') {'Qual o texto da posição a excluir? '}
            else
                fala ('EDTXTPRC'); {'Qual o texto? '}
            c := sintEditaCampo (textoBusc, 1, wherey, 255, 80, true);
            writeln;
            if (c = ESC) or (trim(textoBusc) = '') then
                begin
                            fala ('EDDESIST');
                    exit;
                end;
        until upcase(c) in [ENTER, ESC];

    if blocoInvalido or blocoTodoTexto then
        c := 'T'
    else
        repeat
            fala ('EDTODBLK'); {'Todo texto (T) ou bloco (B): '}
            c := popupMenuPorLetra ('TB');
        until c in ['T', 'B', ESC];

    if c = ESC then
        begin
                    fala ('EDDESIST');
            exit;
        end;

    if c = 'T' then
        begin
            yIni := 1;
            yFim := maxLinhas;
        end
    else
    if (c = 'B') and (fimbloco < iniBloco) then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end
    else //Bloco válido
        begin
            yIni := iniBloco;
            yFim := fimBloco;
        end;

    if apagaLinha then
        if textoBusc[length(textoBusc)] = '*' then
            begin
                delete (textobusc, length(textoBusc), 1);
                noInicio := true;
            end
        else noInicio := false;

    gravarDesfazer;

    salvaIniBloco := iniBloco;
    salvaFimBloco := fimBloco;
    salvaY := posY;
    contador := 0;

    for y := yFim downto yIni do
        begin
            s := texto[y];
            if trim (s) = '' then continue;

            if tiraHifenizacao then
                begin
                    tiraHifenizacaoLinha (y);
                    continue;
                end;

            if apagarParteLinha then //Apaga parte da linha com texto
                begin
                    p := pos (textoBusc, s);
                    if p = 0 then continue;
                    if noInicio then
                        delete (s, 1, p)
                    else
                        delete (s, p, length(s) - p + 1);
                    inc(contador);
                    texto[y] := s;
                    continue;
                end;

            if not apagaLinha then
                begin
                    if noInicio then
                        s := textoBusc + s
                    else
                        s := s + textoBusc;
                    texto[y] := s;
                    continue;
                end;

            if noInicio then
                p := pos (textoBusc, copy (s, 1, length (textoBusc)))
            else
                p := pos (textoBusc, s);
            if p > 0 then
                begin
                    posY := y;
                    inc(contador);
                    Removelinha;
                    if y <= salvaY then
                        salvaY := salvaY - 1;
                end;

        end;

    if not apagaLinha then
        begin
            iniBloco := salvaIniBloco;
            fimBloco := salvaFimBloco;
        end;

    posY := salvaY;
    if posY > maxLinhas then posY := maxLinhas
    else
    if posY < 1 then posY := 1;

    If contador > 0 then sintetiza(intToStr(contador));
    fala ('EDOK');
end;

{--------------------------------------------------------}

procedure excluiLinhasComTexto;
begin
    editaOuApagaLinha (false, true, false, false);
end;

{--------------------------------------------------------}

procedure removerLinhasIguais;
var
    y, k, yIni, yFim, salvaY, salvaIniBloco, salvaFimBloco: integer;
    contador: integer;
    s: string;
    c: CHAR;

begin
    fala ('EDREMLRE'); {'Removendo linhas repetidas'}
    if blocoInvalido or blocoTodoTexto then
        c := 'T'
    else
        repeat
            fala ('EDTODBLK'); {'Todo texto (T) ou bloco (B): '}
            c := popupMenuPorLetra ('TB');
        until c in ['T', 'B', ESC];

    if c = ESC then
        begin
                    fala ('EDDESIST');
            exit;
        end;

    if c = 'T' then
        begin
            yIni := 1;
            yFim := maxLinhas;
        end
    else
    if (c = 'B') and (fimbloco < iniBloco) then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end
    else //Bloco válido
        begin
            yIni := iniBloco;
            yFim := fimBloco;
        end;

    gravarDesfazer;

    salvaIniBloco := iniBloco;
    salvaFimBloco := fimBloco;
    salvaY := posY;
    contador := 0;

    y := yIni;
    while y < yFim do
        begin
            s := texto[y];
            if trim (s) = '' then
                begin
                    inc (y);
                    continue;
                end;

            for k := yFim downto (y + 1) do
                begin
                    if s <> texto[k] then continue;
                    inc(contador);
                    posY := k;
                    Removelinha;
                    if k <= salvaY then dec (salvaY);
                    dec (yFim);
                end;

            inc (y);
        end;

    posY := salvaY;
    if posY > maxLinhas then posY := maxLinhas
    else
    if posY < 1 then posY := 1;

    If contador > 0 then sintetiza(intToStr(contador))
    else
        begin
            iniBloco := salvaIniBloco;
            fimBloco := salvaFimBloco;
        end;

    fala ('EDOK');
end;

{--------------------------------------------------------}

procedure MostrarLinhasRepetidas;
const
TOTALMAXLINHASPROCESS = 50000;
var
    c: char;
    y: longInt;
    qtdMostra: integer;
    yIni, yFim: longInt;
    linha: string;
    listaLinRep: TStringList;

    procedure addListaLinRep (linha: string);
    var
        i: longInt;
        k: integer;
        s: string;
        adicionou: boolean;
    begin
        adicionou := false;
        for i := 0 to (listaLinRep.count - 1) do
            if copy(listaLinRep[i], pos('=', listaLinRep[i])+1, length(listaLinRep[i])) = linha then
                begin
                    s := listaLinRep[i];
                    delete (s, pos('=', s), length(s));
                    k := strToInt (s) + 1;
                    listaLinRep[i] := intToStr(k) + '=' + linha;
                    adicionou := true;
                    break;
                end;
        if not adicionou  then
            listaLinRep.add ('1=' + linha);
    end;

begin
    if blocoInvalido or blocoTodoTexto then
        c := 'T'
    else
        repeat
            fala ('EDTODBLK'); {'Todo texto (T) ou bloco (B): '}
            c := popupMenuPorLetra ('TB');
        until c in ['T', 'B', ESC];

    if c = ESC then
        begin
                    fala ('EDDESIST');
            exit;
        end;

    if c = 'T' then
        begin
            yIni := 1;
            yFim := maxLinhas;
        end
    else
    if (c = 'B') and (fimbloco < iniBloco) then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end
    else //Bloco válido
        begin
            yIni := iniBloco;
            yFim := fimBloco;
        end;

    if (yFim - yIni) > TOTALMAXLINHASPROCESS then
        begin
            fala ('EDGRANDE'); {'Bloco muito grande'}
//            fala ('EDNEXEC');  {'Não pude executar'}
            fala ('EDNPTRMA'); {'não pode ter mais de '}
            sintwrite (intToStr(TOTALMAXLINHASPROCESS));
            fala ('EDLINHAS'); {'Linhas'}
            exit;
        end;

    listaLinRep := TStringList.create;
    if (yFim - yIni) > 2000 then
        fala ('EDAGUARD');   {'Aguarde ...'}

    for y := yIni to yFim do
        begin
            linha := texto[y];
            if trim(linha) = '' then continue;
            addListaLinRep (linha);
        end;

    // Coloca 0 na frente para ordenar direito
    for y := (listaLinRep.count -1) downto 0 do
        while pos('=',listaLinRep[y]) < 15 do listaLinRep[y] := '0' + listaLinRep[y];
    listaLinRep.Sort;

    // Retira as ocorrencias com apenas 1.
    for y := (listaLinRep.count -1) downto 0 do
        begin
            linha := listaLinRep[y];
            while linha[1] = '0' do delete(linha, 1 , 1); // Retira os 0 colocados na frente para ordenar
            if copy (linha, 1, 2) = '1=' then listaLinRep.Delete (y)
            else
                begin
                    linha[pos('=', linha)] := ' ';
                    listaLinRep[y] := linha;
                end;
        end;

    if listaLinRep.count = 0 then
        begin
            fala ('EDNAOTRP');      {'Não tem repetições'}
            listaLinRep.Free;
            exit;
        end;

    fala ('EDUSESET');    {'Use as setas.'}
    sintclek;

    if listaLinRep.count < 27 then qtdMostra := listaLinRep.count
    else qtdMostra := 26 - wherey;

    popupMenuCria(40, 9, 30, qtdMostra, RED);
    for y := (listaLinRep.count -1) downto 0 do
        popupMenuAdiciona ('', listaLinRep[y]);

    popupMenuSeleciona;
    listaLinRep.free;
    fala ('EDOK');
end;

{--------------------------------------------------------}

procedure removerNumerosPaginas (todosNumeros: boolean);
var
    y, i, contador, numPag, erro: integer;
    s: string;

begin
    fala ('EDRENUPA'); {'Removendo números das páginas'}

    contador := 0;
    numPag := 0;

    gravarDesfazer;

    for y := 1 to (texto.Count -1)do
        begin
            s := trim(texto[y]);
            if s = '' then continue;
            if not tudoNumeral (s) then continue;
            val (s, i, erro);
            if (not todosNumeros) and ((erro > 0) or (i <= numPag)) then continue;
            inc (numPag);
            inc(contador);
            texto[y] := '';
        end;

    If contador > 0 then sintetiza(intToStr(contador));
    fala ('EDOK');
end;

{--------------------------------------------------------}

procedure cmdLinha;
var
    c1, c2: char;
label deNovo;

begin

    fala ('EDOPCAO');   { qual opcao ? }
    c1 := leTeclaMaiusc(c2);

deNovo:
    escreveTela;

    case c1 of
        'I': begin
                gravarDesfazer;
                insereLinha ('', true);
            end;

        'A', 'N': insereProxLinha ('', true);
        'R': RemoveApenasUmaLinha;
        'V': voltaRemovida;
        'Q': quebraLinha;
        'J': juntaLinhas;
        'E': excluiLinhasComTexto;
        'S': editaOuApagaLinha (true , false, false, false);
        'D': editaOuApagaLinha (false , false, false, false);
        ^S: editaOuApagaLinha (true , false, true, false);
        ^D: editaOuApagaLinha (false , false, true, false);
        'H': editaOuApagaLinha (false , false, false, true);
        'U': removerLinhasIguais;
        ^U: MostrarLinhasRepetidas;

        'P', ^P: removerNumerosPaginas (c1 = ^P);

        #$0: begin
                c1 := ajuda (c2, 'EDAJLI', 16);
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
{       Insere uma string na linha
{--------------------------------------------------------}

procedure insereNaLinha (conteudo: string);
var
    linha, saida: string;
    salvax: integer;
begin
    linha := texto[posy];
    saida := copy (linha, 1, posx-1) + conteudo + copy (linha, posx, length(linha)-posx+1);
    salvax := posx;
    texto[posy] := saida;
    posx := salvax + length (conteudo);
    sintTextoFormatado (conteudo);
end;

{--------------------------------------------------------}

begin
end.
