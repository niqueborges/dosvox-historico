{--------------------------------------------------------}

{
{    Tratamento de Blocos de Linhas
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{--------------------------------------------------------}

Unit edBloco;

interface

uses
    DVcrt, DVWin, DVarq, DVdde, windows, sysUtils,
    classes,
//    dvArqLog,
    dvForm, dvExec,
    edVars, edUtil, edMensag, edLinha, edArq, edAcento, edEmbel, edTela, eddicion,
    edDesfaz,
    edTraduvox,
    edDocUti, edCursor, edReform, edTransf;

procedure inicBloco;
procedure selecionarBloco  (iBloco, fBloco: integer; posAtual: boolean);
procedure falaBlocoSelecionado;
procedure informaBloco;
procedure MostrarPalavrasRepetidas;
procedure blocoParagrafo;
Procedure RemoveBloco;
procedure trataBloco (cmdBloco: boolean);

implementation

{--------------------------------------------------------}

Procedure InicBloco;
begin
    inibloco := 1;
    fimbloco := 0;
end;

{--------------------------------------------------------}

procedure selecionarBloco  (iBloco, fBloco: integer; posAtual: boolean);
begin
    inibloco := iBloco;
    fimbloco := fBloco;

    if posAtual and (iBloco = 1) then fala ('EDFIMBLK')    { fim do bloco }
    else
if posAtual and (fBloco = maxlinhas) then fala ('EDINIBLK');    { inicio do bloco }

    fala ('EDBLKMAR'); {'Bloco marcado'}
end;

{--------------------------------------------------------}

procedure falaBlocoSelecionado;
var y: integer;
begin
    if blocoInvalido then
        begin
            fala ('EDBLKINV');   { bloco invalido }
            exit;
        end;

    sintclek;
    for y := iniBloco to fimBloco do
        if not keypressed then
            sintTextoFormatado (texto[y])
        else
            break;
    sintclek;
end;

{--------------------------------------------------------}

procedure informaBloco;
var falarTotalLinhasBlocoPrimeiro: boolean;
begin
    if blocoInvalido then
        begin
            fala ('EDBLKINV');   { bloco invalido }
            exit;
        end;

    falarTotalLinhasBlocoPrimeiro := 'S' = upcase(sintAmbiente ('EDIVOX', 'FALARTOTALLINHASBLOCOPRIMEIRO', 'NAO')[1]);

    if falarTotalLinhasBlocoPrimeiro then
        begin
            if sintFalarTudo then fala ('EDLINHAS'); {'Linhas'} write(': ');
            sintwrite (intToStr(fimbloco - inibloco + 1));
        end;

    fala('EDINIBLK'); {'Inicio do bloco'}
    sintwrite (intToStr(inibloco));
    fala ('EDFIMBLK'); {'Fim do bloco'}
    sintwrite (intToStr(fimbloco));

    if not falarTotalLinhasBlocoPrimeiro then
        begin
            fala ('EDLINHAS'); {'Linhas'} write(': ');
            sintwrite (intToStr(fimbloco - inibloco + 1));
        end;

    if not keypressed then falaBlocoSelecionado;
end;

{--------------------------------------------------------}

Procedure copiaBloco;
Var
    tam, k : Integer;

Begin
    if blocoInvalido or
        ( (posy >= inibloco) and (posy <= fimbloco) ) then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    gravarDesfazer;

    tam := fimbloco - inibloco + 1;
    For k := tam-1 downto 0 do
        begin
            if keypressed and (tam > 1000) then
                begin
                    limpabuftec;
                    informaLinha ( tam - k, tam, false);
                end;
                insereLinha (texto [inibloco+k], false);
        end;

    fimbloco := inibloco + tam - 1;
    fala ('EDBLKCPY');
End;

{--------------------------------------------------------}

procedure falaQuantas (JogaAreaTransfer: boolean);
var
    s: string;
    totalLinhasEmBranco, totalPalavras, totalCaracteres, totalEspacos, totalNumeros, totalPontuacao: int64;
    totalLetras, totalLetrasSemAcento, totalLetrasComAcento, totalLetrasMaiusculas, totalLetrasMinusculas: integer;
    y: integer;

    procedure contaPalavras (s: string);
    var
        p: integer;
    begin
        s := trim(s);
        while s <> '' do
            begin
                totalPalavras := totalPalavras + 1;
                p := pos (' ', s);
                if p > 0 then
                    delete (s, 1, p)
                else
                     s := '';
                s := trim(s);
            end;
    end;

    function strToChar (s: string): char;
    begin
        strToChar := s[1];
    end;

    procedure contaCaracteres (s: string);
    var
        i: integer;
    begin
        totalCaracteres := totalCaracteres +  length(s);
        for i := 1 to length(s)do
            if s[i] = ' ' then
                totalEspacos := totalEspacos + 1
            else
            if s[i] in ['0' .. '9'] then
                totalNumeros := totalNumeros + 1
            else
            if s[i] in ['.', ',', '?', '!', ';', ':'] then
                totalPontuacao := totalPontuacao+ 1
            else
            if strToChar(semAcentos(s[i])) in ['A' .. 'Z', 'Ç'] then
                begin
                    totalLetras := totalLetras + 1;
                    if strToChar(maiuscansi(s[i])) in ['A' .. 'Z', 'Ç'] then
                        totalLetrasSemAcento := totalLetrasSemAcento + 1
                    else
                        totalLetrasComAcento := totalLetrasComAcento + 1;
                    if (s[i] = uppercase(s[i])) and (not(s[i] in ['á', 'à', 'â', 'ã', 'ä', 'é', 'è', 'ê', 'ë', 'í', 'ì', 'î', 'ï', 'ó', 'ò', 'ô', 'õ', 'ö', 'ú',
'ù', 'û', 'ü', 'ç'])) then
                        totalLetrasMaiusculas := totalLetrasMaiusculas + 1
                    else
                        totalLetrasMinusculas := totalLetrasMinusculas + 1;
                end;
    end;

begin
    if blocoInvalido then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    totalPalavras := 0;
    totalCaracteres := 0;
    TotalEspacos := 0;
    totalNumeros := 0;
    totalPontuacao := 0;
    totalLetras := 0;
    totalLetrasSemAcento := 0;
    totalLetrasComAcento := 0;
    totalLetrasMaiusculas := 0;
    totalLetrasMinusculas := 0;
        totalLinhasEmBranco := 0;
    for y := iniBloco to fimBloco do
        begin
            s := texto[y];
            if trim(s) = '' then
                totalLinhasEmBranco := totalLinhasEmBranco + 1
            else
                begin
                    contaPalavras (s);
                    contaCaracteres (s);
                end;
        end;

    if JogaAreaTransfer then
        begin
            s := intToStr(totalPalavras) + ' palavras'
                 + '; ' + intToStr (totalCaracteres) + ' caracteres'
                 + '; ' + intToStr (totalEspacos) + ' espaços em branco'
                 + '; ' + intToStr (totalLetras) + ' letras'
                 + '; ' + intToStr (totalLetrasSemAcento) + ' letras sem acento'
                 + '; ' + intToStr (totalLetrasComAcento) + ' letras com acento'
                 + '; ' + intToStr (totalLetrasMaiusculas) + ' letras maiúsculas'
                 + '; ' + intToStr (totalLetrasMinusculas) + ' letras minúsculas'
                 + '; ' + intToStr (totalNumeros) + ' números'
                 + '; ' + intToStr (totalPontuacao) + ' sinais de pontuação'
                 + '; ' + intToStr (totalLinhasEmBranco) + ' linhas em branco';
            jogaStringAreaTransf (s);
        end;

    escreveNumero (totalPalavras);
    fala ('EDPALAVR'); {'palavras'}
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalCaracteres) + 'Caracteres');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalEspacos) + 'Espaços em branco');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLetras) + 'Letras');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLetrasSemAcento) + 'Letras sem acento');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLetrasComAcento) + 'Letras com acento');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLetrasMaiusculas) + 'Letras maiúsculas');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLetrasMinusculas) + 'Letras minúsculas');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalNumeros) + 'Números');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalPontuacao) + 'Sinais de pontuação');
    sintClek;
    if not keypressed then     delay (300);
    sintetiza (intToStr (totalLinhasEmBranco) + 'Linhas em branco');
    sintClek;
end;

{--------------------------------------------------------}

procedure colocaEmMaiusculoMinusculo (maiusculo, primeiraMaiusculo, paraUTF8: boolean);
var
    y: integer;
    tecla: char;
    s: string;

    function colocaPrimMaiuscula (s: string): string;
    var
        i: integer;
        proximaMaiusc: boolean;
    begin
        s := ansiLowerCase (s);
        proximaMaiusc := true;
        for i := 1 to length (s) do
            begin
                if (s [i] <> ' ') and proximaMaiusc then
                    begin
                        s [i] := (ansiUpperCase (s) [i]);
                        proximaMaiusc := false;
                    end
                else
                if s [i] = ' ' then
                    proximaMaiusc := true;
            end;
        colocaPrimMaiuscula := s;
    end;

begin
    if blocoInvalido then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    if maiusculo then
        fala ('EDMAIUSC')   { 'Deseja converter o bloco para maiúscula?'}
    else
    if primeiraMaiusculo then
        fala ('EDPRIMAI')   { 'Deseja converter primeira letra de todo bloco para maiúscula?'}
    else
    if paraUTF8 then
        fala ('EDPUTF8')   { 'Deseja codificar o bloco para UTF-8'}
    else
        fala ('EDMINUSC');   { 'Deseja converter o bloco para minúscula?'}

    tecla := popupMenuPorLetra ('SN');
    if not (tecla in ['S', ENTER]) then
        begin
            fala ('EDDESIST');  { Desistiu }
            exit;
        end;

    gravarDesfazer;

    for y := iniBloco to fimBloco do
        begin
            s := texto[y];
            if trim(s) = '' then
                continue
            else
            if maiusculo then
                s := ansiUpperCase (s)
            else
            if primeiraMaiusculo then
                s := colocaPrimMaiuscula (s)
            else
            if paraUTF8 then
                s := AnsiToUtf8(s)
            else
                s := ansiLowerCase (s);

            texto[y] := s;
        end;

    fala ('EDOK');
end;

{--------------------------------------------------------}

procedure MostrarPalavrasRepetidas;
var
    y, qtdMostra: integer;
    linha, palExt: string;
    listaPalRep: TStringList;

    procedure addListaPalRep (palavra: string);
    var
        i, k: integer;
        s: string;
        adicionou: boolean;
    begin
        adicionou := false;
        for i := 0 to (listaPalRep.count - 1) do
            if copy(listaPalRep[i], pos('=', listaPalRep[i])+1, length(listaPalRep[i])) = palavra then
                begin
                    s := listaPalRep[i];
                    delete (s, pos('=', s), length(s));
                    k := strToInt (s) + 1;
                    listaPalRep[i] := intToStr(k) + '=' + palavra;
                    adicionou := true;
                    break;
                end;
        if not adicionou  then
            listaPalRep.add ('1=' + palavra);
    end;

    function extraiPalavraLinha: string;
    var
        k, erro: integer;
        palavra: string;
    begin
        k := pos(' ', linha);
        if k>0 then
            begin
                palavra := copy (linha, 1, k-1);
                delete (linha, 1, k);
                linha := trim(linha);
            end
        else
            begin
                palavra := linha;
                linha := '';
            end;
        while (palavra <> '') and (palavra[length(palavra)] in ['.', ',', '?', '!', ';', ':', '¡', '¿', ')', '"', '}', ']', '>', '-', '_']) do
            delete (palavra, length(palavra), 1);
        while (palavra <> '') and (palavra[1] in ['.', ',', '?', '!', ';', ':', '¡', '¿', '(', '"', '{', '[', '<', '-', '_']) do
            delete (palavra, 1, 1);
        if palavra <> '' then
            begin
                val (palavra, k, erro);
                if erro = 0 then palavra := '';
                if k = 0 then; // Temporáriamente uma forma de usar o k.
            end;

        result := palavra;
    end;

begin
    if blocoInvalido then
        begin
            fala ('EDBLKINV');   { bloco invalido }
            exit;
        end;
    if (fimBloco - iniBloco) > 50000 then
        begin
            fala ('EDGRANDE'); {'Bloco muito grande'}
            fala ('EDNEXEC'); {'Não pude executar'}
            exit;
        end;

    listaPalRep := TStringList.create;
    if (fimBloco - iniBloco) > 500 then
        fala ('EDAGUARD');   {'Aguarde ...'}

    for y := iniBloco to fimBloco do
        begin
            linha := trim(texto[y]);
            if linha = '' then continue;
            linha := ansiUpperCase (linha);
            while linha <> '' do
                begin
                    palExt := extraiPalavraLinha;
                    if palExt <> '' then addListaPalRep (palExt);
                end;
        end;

    for y := (listaPalRep.count -1) downto 0 do
        while pos('=',listaPalRep[y]) < 15 do listaPalRep[y] := '0' + listaPalRep[y]; // Coloca 0 na frente para ordenar direito
    listaPalRep.Sort;

    // Retira as ocorrencias com apenas 1.
    for y := (listaPalRep.count -1) downto 0 do
        begin
            linha := listaPalRep[y];
            while linha[1] = '0' do delete(linha, 1 , 1); // Retira os 0 colocados na frente para ordenar
            if copy (linha, 1, 2) = '1=' then listaPalRep.Delete (y)
            else
                begin
                    linha[pos('=', linha)] := ' ';
                    listaPalRep[y] := linha;
                end;
        end;

    if listaPalRep.count = 0 then
        begin
            fala ('EDNAOTRP');      {'Não tem repetições'}
            listaPalRep.Free;
            exit;
        end;

    fala ('EDUSESET');    {'Use as setas.'}
    sintclek;

    if listaPalRep.count < 27 then qtdMostra := listaPalRep.count
    else qtdMostra := 26 - wherey;

    popupMenuCria(40, 9, 30, qtdMostra, RED);
    for y := (listaPalRep.count -1) downto 0 do
        begin
            popupMenuAdiciona ('', listaPalRep[y]);
//            gravarArqLog (listaPalRep[y], '.\Edivox.log'); // Usa dvArqLog
        end;

    popupMenuSeleciona;
    listaPalRep.free;
    fala ('EDOK');
end;

{--------------------------------------------------------}

procedure tratamentoMaiusculaMinuscula;
var
    c1, c2: char;
label deNovo;
begin
    fala ('EDOPCAO');   { qual opcao ? }
    c1 := leTeclaMaiusc(c2);
deNovo:
    escreveTela;

    case c1 of
        'A': colocaEmMaiusculoMinusculo (true, false, false);
        'I': colocaEmMaiusculoMinusculo (false, false, false);
        'P': colocaEmMaiusculoMinusculo (false, true, false);
        'U': colocaEmMaiusculoMinusculo (false, false, true);
        'C': falaQuantas (false);
        'T': falaQuantas (true);
        'R': MostrarPalavrasRepetidas;

        #$0: begin
                c1 := ajuda (c2, 'EDAJMM', 8);
                goto deNovo;
            end;
        #$1b:  begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
    end;
end;

{--------------------------------------------------------}

Procedure RemoveBloco;
Var
    i, totalLinhas: Integer;
Begin
    If blocoInvalido then
        begin
            fala ('EDBLKINV');
            exit;
        end;

    gravarDesfazer;

    if  (fimbloco - inibloco) > 50000 then
        fala ('EDAGUARD'); {'Aguarde ...'}

    totalLinhas := fimbloco - inibloco;
    posy  := inibloco;
    For i := inibloco to fimbloco Do
        begin
            if keypressed and ((fimBloco - iniBloco)  > 1000) then
                begin
                    limpaBuftec;
                    informaLinha (i,  totalLinhas, false);
                end;
            removeLinha;
        end;

    fala ('EDBLKREM');
     inicBloco;
End;

{--------------------------------------------------------}

Procedure moveBloco;
var
    tam, i : Integer;

begin
    if blocoInvalido or
        ( (posy >= inibloco) and (posy <= fimbloco) ) then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    gravarDesfazer;

    tam := fimbloco - inibloco + 1;
    salvaCury:= posy;

    For i := tam-1 downto 0 do
        begin
            if keypressed and (tam > 1000) then
                begin
                    limpabuftec;
                    informaLinha ( tam - i,  tam, false);
                end;
            insereLinha (texto [fimbloco], false);
            posy := fimBloco;
            removeLinha;
            posy := salvaCury;
        end;

    posy := salvaCury;
    iniBloco := posy;
    fimBloco := iniBloco + tam - 1;

    fala ('EDBLKMOV');
end;

{--------------------------------------------------------}

Procedure LeBloco (adicionaAEsquerdaDaLinha: boolean);
var
    salvaNome: string;
    salva: integer;

label fim;

begin
    salvaNome := nomeArq;
    salva := posy;

{ o "gravarDesfazer" foi colocado na "function abreArqSemCriar" em EdArq.pas}

    if adicionaAEsquerdaDaLinha then fala ('EDAESQUERDA'); {'a esquerda'}
    if abreArqSemCriar (adicionaAEsquerdaDaLinha) then
        begin
            fimBloco := posy-1;
            iniBloco := salva;
            posy := salva;
            posx := 1;
            fala ('EDBLKCRG');
        end;

    nomeArq := salvaNome;

    if posy <= 0 then
        posy := 1;
end;

{--------------------------------------------------------}

Procedure GravaBloco;
var
    salvaNome: string;
    tecla: char;
    aux: boolean;
begin
    If BlocoInvalido  Then
        begin
            fala ('EDBLKINV');   { bloco Invalido }
            exit;
        end;

    salvanome := nomeArq;
    nomearq := '';

    fala ('EDREFORM');   { Junta linhas para exportar? }
    tecla := popupMenuPorLetra('SN');
    aux := somenteLeitura;
    somenteLeitura := false;
    if tecla <> ESC then
        if upcase (tecla) <> 'S' then
            salvaArquivo (iniBloco, fimBloco, false, false)
        else
            salvaJuntaLinhas (iniBloco, fimBloco)
    else
        fala ('EDDESIST');   { Desistiu }
    somenteLeitura := aux;

    nomeArq := salvaNome;
end;

{--------------------------------------------------------}

Procedure AdicionaBloco;
Var
    salvaNome: string;
    adic : Text;
    i : Integer;

Label Inicio, fecha, fim;

Begin
    If blocoInvalido then
        begin
            fala ('EDBLKINV');
            exit;
         end;

Inicio :
    fala ('EDDIGNOM');
    salvaNome := Nomearq;
    nomeArq := obtemNomeArq (10);
    write (nomeArq);
    nomeArq := trim(nomeArq);
    if nomeArq = '' then
        begin
            fala ('EDDESIST');
            goto fim;
        end;

    if not testaExtensao (nomeArq) then
        begin
            assign (adic, nomeArq);
            {$i-} reset (adic); {$i+}
            if ioresult = 0 then
                {$i-} close (adic) {$i+}
            else
                nomeArq := nomeArq + '.txt';
        end;

    assign (adic, nomeArq);
    {$I-} append (adic); {$I+}
    If ioresult <> 0  Then
        begin
            fala('EDARQNAO');
            goto fim;
        end;

    For i := inibloco to fimbloco  Do
        begin
            {$I-} writeln (adic, texto[i]); {$I+}
            If ioResult <> 0  Then
                begin
                    fala ('EDERRESC');
                    goto fecha;
                end;
        end;

fecha:
    {$I-}  close (adic);  {$I+}
    if ioresult = 0 then
        fala ('EDBLKADC'); {  Bloco adicionado. }

fim:
    nomeArq := salvaNome;
End;

{--------------------------------------------------------}

Procedure OrdenaBloco;

    function acrescentaZeros (s: string): string;
    const zeros = '000000000000000';
    var nnum, i: integer;
    begin
        if (s <> '') and (s[1] in ['0'..'9']) then
            begin
                s := s + '.';
                for i := 1 to length(s) do
                     if not (s[i] in ['0'..'9']) then
                          begin
                              nnum := i-1;
                              break;
                          end;
                delete (s, length(s), 1);
                s := copy (zeros, 1, 15-nnum) + s;
            end;

        result := s;
    end;

    procedure ordenaComTStringlist (iniBloco, fimBloco: Integer);
    var
        linhasBloco: TStringList;
        i: longInt;
    begin
        linhasBloco := TStringList.create;
        for i := iniBloco to fimBloco do linhasBloco.Add (texto[i]);
        linhasBloco.Sort;
        for i := 0 to (linhasBloco.count - 1) do texto[iniBloco + i] := linhasBloco[i];
        linhasBloco.Free;
    end;

    procedure Sort(l, r: longInt);  // metodo quick sort
    var
        i, j: longInt;
        x: string;
        pt : Frase;
    begin
        i := l;
        j := r;

        x := semAcentos (acrescentaZeros(texto[(l+r) div 2]));
        repeat
            while semAcentos (acrescentaZeros(texto[i])) < x do
                inc (i);
            while x < semAcentos (acrescentaZeros(texto[j])) do
                dec(j);

            if i <= j then
                begin
                    pt       := texto[i];
                    texto[i] := texto[j];
                    texto[j] := pt;
                    inc (i);
                    dec (j);
                end;
        until i > j;

        if l < j then Sort(l, j);
        if i < r then Sort(i, r);
    end;

Begin
    If blocoInvalido then
        begin
             fala ('EDBLKINV');
             exit;
        end;

    gravarDesfazer;

    if upcase(sintAmbiente('EDIVOX', 'ORDENACAOPADRAO', 'SIM')[1]) = 'S' then
        Sort(iniBloco, fimBloco)
    else
        ordenaComTStringlist (iniBloco, fimBloco);

    fala ('EDBLKORD');
end;

{--------------------------------------------------------}

procedure blocoParagrafo;
begin
    inibloco := posy;
    fimBloco := posy;

    while (inibloco > 1) and (trim(texto[inibloco-1]) <> '') do
        inibloco := inibloco - 1;

    while (fimbloco < maxlinhas) and (trim(texto[fimbloco+1]) <> '') do
        fimbloco := fimbloco + 1;

    fala ('EDBLKPAR');
end;

{--------------------------------------------------------}

procedure blocoLinha;
begin
    inibloco := posy;
    fimBloco := posy;
    fala ('EDBLKLIN');
end;

{--------------------------------------------------------}

procedure enviaServidor;
var i: integer;
    servidor, topico, item: string [30];
    tamanho: longint;
    p: pchar;
    posic: integer;
begin
    if blocoInvalido then
        begin
            fala ('EDBLKINV');   { bloco invalido }
            exit;
        end;

    servidor := sintAmbiente ('EDIVOX', 'SERVIDOR');
    if servidor = '' then
        servidor := 'MONOLOG';
    topico := sintAmbiente ('EDIVOX', 'TOPICO');
    if topico = '' then
        topico := 'TALK';
    item := sintAmbiente ('EDIVOX', 'ITEM');

    while sintFalando do waitMessage;

    tamanho := 1;
    for i := iniBloco to fimBloco do
        tamanho := tamanho + length (texto[i]) + 2;

    if tamanho > longint (65000) then
        begin
            fala ('EDGRANDE');
            exit;
        end;

    getmem (p, tamanho);
    posic := 0;

    for i := iniBloco to fimBloco do
        if length (texto[i]) > 0 then
            begin
                move (texto[i][1], p[posic], length (texto[i]));
                posic := posic + length (texto[i]);
                p[posic] := #$0d;
                p[posic+1] := #$0a;
                posic := posic + 2;
            end;
    p[posic] := #$0;

    if not enviaServidorDDE (servidor, topico, item, p) then
        fala ('EDERRSRV');

    freemem (p, tamanho);
end;

{--------------------------------------------------------}

procedure justificaParagrafo;
begin
    inibloco := posy;
    fimBloco := posy;

    while (inibloco > 1) and (trim(texto[inibloco-1]) <> '') do
        inibloco := inibloco - 1;

    while (fimbloco < maxlinhas) and (trim(texto[fimbloco+1]) <> '') do
        fimbloco := fimbloco + 1;

    gravarDesfazer;

    acertaMargens (false);
    inicBloco;
    fala ('EDJUSTIF');
end;

{--------------------------------------------------------}

procedure verificaBloco;
begin
    if blocoInvalido then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    gravarDesfazer;

    if not verificaDicionario (iniBloco, fimBloco) then
        fala ('EDDICNAO');   {dicionário não foi encontrado}
end;

{--------------------------------------------------------}

procedure removeLinhasEmBranco(removerTodas: boolean);
var
    i: integer;
    passouUma: boolean;
begin
    if blocoInvalido then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    gravarDesfazer;

    passouUma := false;
    sintClek;
    for i := fimBloco downto iniBloco do
        if trim(texto [i]) = '' then
            begin
                posy := i;
                if (removerTodas or passouUma) then
                    Removelinha
                else
                    passouUma := true;
                if (i mod 100) = 0 then
                    sintClek;
            end
        else
    passouUma := false;

    posy := iniBloco;
    posx := 1;
end;

{--------------------------------------------------------}

procedure blocoParaMat (salvar: boolean);
var
    nomeArqTemp, nomeDir, nomeArqJS, linhaMat: string;
    textoMat, lista_js: TStringList;
    i: integer;
begin
    if blocoInvalido then
        begin
            fala ('EDBLKINV');   { bloco invalido }
            exit;
        end;

    nomeArqJS := sintAmbiente ('DOSVOX', 'PGMDOSVOX', 'C:\Winvox') + '\ASCIIMathML.js';
    if not fileExists(nomeArqJS) then
        linhaMat := '<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/latest.js?config=AM_CHTML"></script>'
    else
    if not salvar then
        linhaMat := '<script type="text/javascript"src="' + nomeArqJS + '"></script>'
    else
        begin
            linhaMat := '';
            lista_js := TStringList.Create;
        lista_js.LoadFromFile (nomeArqJS);
        end;

    textoMat := TStringList.Create;
    {    Estrutura do HTML primeiro   }
    textoMat.append('<html>');
    textoMat.append('<body>');
    if linhaMat <> '' then
        textoMat.append(linhaMat)
    else
        begin
            textoMat.append('<script>');
            for i := 36 to (lista_js.Count - 1) do textoMat.append(lista_js[i]);
            textoMat.append('</script>');
            lista_js.Free;
        end;
    textoMat.append('<h3>');
    {   Adiciona linhas do texto antecedidas de <br>   }
    for i := iniBloco to fimBloco do
        begin
        textoMat.append('<br>'+texto[i]);
    end;
    {   Fechando estrutura do HTML   }
    textoMat.append('</h3>');
    textoMat.append('</body>');
    textoMat.append('</html>');

    if salvar then
        begin
            nomeArqTemp := copy (nomeArq, 1, length(nomeArq) - length(extractFileExt(nomeArq))) + '_Mat.htm';
            if fileExists (nomeArqTemp) then nomeArqTemp := resolverNovoNomeArq (nomeArqTemp);
            textoMat.saveToFile(nomeArqTemp);
            fala ('EDARQGRV'); {'Arquivo gravado'}
        end
    else
        begin
        fala ('EDAGUARD'); {'Aguarde ...'}
        nomeArqTemp := getTempFile_htm;
        textoMat.saveToFile(nomeArqTemp);
        getdir (0, nomeDir);
        if executaProg (nomeArqTemp, nomeDir, '') < 32 then
            fala ('EDNEXEC')    {'Não pude executar'}
        else
            esperaProgVoltar;
        sysUtils.deleteFile(nomeArqTemp);
        end;

    textoMat.Free;
end;

{--------------------------------------------------------}

Procedure TrataBloco (cmdBloco: boolean);
Var
    c1, c2 : char;
label deNovo;

Begin
    if cmdBloco then
        fala ('EDOPCAO')   { qual opcao ? }
    else
        fala ('EDCMDBLK');     { bloco: }
    c1 := leTeclaMaiusc(c2);

deNovo:
    case c1 of
        'M'     : movebloco;
        'C'     : copiabloco;
        'A'     : AdicionaBloco;
        'O'     : OrdenaBloco;
        'R'     : removeBloco;

        'I'     : begin
                        inibloco := posy;
                        fala ('EDINIBLK');    { inicio do bloco }
                   end;
        ^I      : selecionarBloco  (posy, maxLinhas, true);

        'F'     : begin
                        fimbloco := posy;
                        fala ('EDFIMBLK');    { fim do bloco }
                   end;
        ^F      : selecionarBloco  (1, posy, true);

        'D'     : begin
                        inicBloco;
                        fala ('EDBLKDSM');   { bloco desmarcado }
                   end;

        'L', ^L : leBloco (c1 = ^L);
        'G'     : gravaBloco;
        'E'     : embelezaBloco;
        'P'     : blocoParagrafo;
        'S'     : blocoLinha;
        'J'     : justificaParagrafo;
        'V'     : verificaBloco;
        'X'     : reformata;
        'U'     : tratamentoMaiusculaMinuscula;
        'B', ^B : removeLinhasEmBranco(c1 = 'B');
        'W'     : areaTransfWord;
        'T'     : selecionarBloco  (1, maxLinhas, false);
        'Q'     : quebrarLinhasBloco (1, maxlinhas, true);
        'Y', ^Y : trataTraduvox (c1 = 'Y');
        'N', ^N : blocoParaMat (c1 = ^N);

        #$0     : begin
                        c1 := ajuda (c2, 'EDAJBL', 30);
                        goto deNovo;
                   end;
        #$1b    : begin
                        fala ('EDDESIST');
                        exit;
                   end
    else
        sintBip;
    end;

    if cmdBloco then
        escreveTela;
end;

{--------------------------------------------------------}

begin
end.
