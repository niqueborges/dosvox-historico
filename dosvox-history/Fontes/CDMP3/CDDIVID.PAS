unit cdDivid;

interface

uses dvcrt, dvWin, dvArq, dvForm,
    cdUtil, cdVars, cdMsg,
    sysUtils;

procedure divideArq;
procedure removePartesDivididas;

implementation

{--------------------------------------------------------}

procedure removePartesDivididas;
var
    buscado: TSearchRec;
    dosError: integer;
    i: integer;
    arqTxt: text;
begin

        dosError := FindFirst ('*.PAR', FAARCHIVE, buscado);

    i:= 0;
    nomeArqTxt[i]:= buscado.name;

    if nomeArqTxt[i] = '' then
        exit;

    while dosError = 0 do
        begin
            i:= i + 1;
            nomeArqTxt[i]:= buscado.name;
            assign (arqTxt, nomeArqTxt[i]);
            {$I-} erase (arqTxt); {$I+}
            if ioResult <> 0 then;
            dosError := FindNext(buscado);
        end;

    semArqPar:= true;

end;

{--------------------------------------------------------}

procedure divideArq;
var arqTxt, arqTmp: text;
    nomeArq: string;
    marcLinha: char;
    marca: string;
    numParte: integer;
    nomeParte, cabecArq: string;
    p, s: string;
    i: integer;
label automatizado, cancela;
begin

    removePartesDivididas;

    if (nomeEfeitoWav = '') or (not fileExists (nomeEfeitoWav)) then introduz_efeito:= false;

    if geraAuto then
        begin
            nomeArq:= nomeArqTxt[numarqs];
            marcLinha:= 'L';
            goto automatizado;
        end;

    if semArqTxt then
        begin
            mensagem ('CDNAODIV', 1); {'O diretório padrão não contém nenhum arquivo a dividir')}
            exit;
        end;

    mensagem ('CDSELSET', 1); {'Escolha o arquivo com as setas')}
    garanteEspacoTela (11);
    nomeArq:= obtemNomeArqMasc (10, '*.TXT');
    writeln (nomeArq);
    if nomeArq = '' then
    begin
        mensagem ('CDDESIST', 1);
        exit;
    end;

    mensagem ('CDMARLIN', 0); {'Digite M se for usar uma marca especial ou L para número de linhas : ')}
    marcLinha:= popupMenuPorLetra ('MLPD');
    if marcLinha in ['D',ESC] then
        goto cancela;

    if not (marcLinha in ['M', 'L', 'P', ENTER]) then
        begin
            mensagem ('CDINDERR', 1); {'Você indicou uma letra inválida')}
            goto cancela;
        end;

    if marcLinha = 'M' then
        begin
            mensagem ('CDINDMAR', 0); {'Indique qual será a marca : ')}
            sintReadln (marca);
            if marca = '' then
                goto cancela;
        end
        else
    if marcLinha in ['P', ENTER] then
        begin
            marcLinha:= 'L';
            numLinhas := strToInt(sintAmbiente ('CDMP3', 'QUEBRARLINHA', '100'));
        end
    else
        begin
            mensagem ('CDINDLIN', 0); {'Indique qual será o número de linhas para cada parte : ')}
            sintReadInt (numLinhas);
            writeln;
            if numLinhas < 1 then
                goto cancela;
        end;

    automatizado:

    mensagem ('CDINIDIV', 1); {'Iniciando o processo de divisão')}

    assign (arqTxt, nomeArq);
    {$I-} reset(arqTxt); {$I+}
    if ioResult <> 0 then
        goto cancela;

    dirSom:= copy(nomeArq, 1, length(nomeArq) -4 );
    cabecArq:= dirSom;
    nomeParte:= trim(copy(nomeArq, 1, 5)) + '_';

    numParte:= 0;

    while not eof(arqTxt) do
    begin

        numParte:= numParte + 1;

        if numParte > 999 then
        begin
            removePartesDivididas;
            sintBip; sintBip;
            sintWriteln ('O número de divisões excedeu o limite suportado de 999');
            sintWriteln ('O programa será fechado');
            sintFim;
            doneWinCrt;
        end;

        str (numParte, p);
        while length(p) < 3 do p := '0' + p;

        assign (arqTmp, nomeParte + p + '.PAR');
        {$I-} rewrite(arqTmp); {$I+}
        if ioResult <> 0 then
            goto cancela;

        if (numparte >= 1) and (numParte <=9) then
            delete (p, 1, 2);
        if (numparte >= 10) and (numParte <=99) then
            delete (p, 1, 1);

        if introduz_cabec then
        begin
            write (arqTmp, cabecArq + ' ');
            writeln (arqTmp, p);
            writeln (arqTmp);
        end;

        if introduz_efeito then
        begin
            writeln (arqTmp, '#SOM#');
            writeln (arqTmp);
        end;

        if formatEsp then
        begin
            writeln (arqTmp, '#SAPI#' + intToStr(tipEsp) + ',' + intToStr(numEsp) + ',' + intToStr(velEsp) + ',' + intToStr(tonEsp));
            writeln (arqTmp);
        end;

        if marcLinha = 'M' then
            begin
                repeat
                    readln (arqTxt, s);
                    if trim(s) <> trim(marca) then
                        writeln (arqTmp, s);
                until (trim(s) = trim(marca)) or (eof(arqTxt));
            if formatEsp then
            begin
                writeln (arqTmp);
                writeln (arqTmp, '#SOM#');
            end;
            writeln (arqTmp);
//            write (arqTmp, 'Final da parte ');
//            writeln (arqTmp, p);
            end; //Relativo ao if

        if marcLinha = 'L' then
            begin
            i:= 0;
                repeat
                    readln (arqTxt, s);
                    i:= i + 1;
//                    if copy (s, 1, 1) = '-' then
//                        writeln (arqTmp);
                    writeln (arqTmp, s);
                until (i = numLinhas) or (eof(arqTxt));
            if formatEsp then
            begin
                writeln (arqTmp);
                writeln (arqTmp, '#SOM#');
            end;
            writeln (arqTmp);
//            write (arqTmp, 'Final da parte ');
//            writeln (arqTmp, p);
            end; //Relativo ao if

        close (arqTmp);
        sintClek;
    end; //Relativo ao while
    close (arqTxt);

    semArqPar:= false;

    mensagem ('CDDIVSUC', 1); {'A divisão foi feita com sucesso')}
    writeln;

    if selNomArqs(dirTexto, 'P') then
    begin
        mensagem ('CDTOTCON', 0); {'Total de arquivo(s) à converter --- ')}
        sintWriteInt (numArqs);
        writeln;
    exit;
    end
    else
    begin
        mensagem ('CDPRODIS', 1); {'Problema no disco, o programa será fechado')}
        sintFim;
        doneWinCrt;
    end;

    cancela:

    {$I-} close(arqTxt); {$I+}
    if ioResult <> 0 then;

    {$I-} close(arqTmp); {$I+}
    if ioResult <> 0 then;

    sintbip; sintBip;
    mensagem ('CDDIVCAN', 1); {'A operação de dividir foi cancelada')}

end;

end.
