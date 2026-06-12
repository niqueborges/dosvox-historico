{--------------------------------------------------------}
{
{    Programa para emissao de cheques
{
{    Módulo de rotinas utilitárias
{
{    Autor: Antonio Borges
{
{    Em Agosto de 2001
{
{--------------------------------------------------------}

{$N+}

unit chFolhe;

interface
uses dvcrt, dvwin, dvlenum, windows, chvars, chmsg, chutil, chlanc;

procedure folhear;
procedure geraExtrato;

implementation

{--------------------------------------------------------}

procedure carregaDocs;
var
    arqLanc: text;
    lixo: string;
begin
    assign (arqLanc, nomeArqLanc);
    {$I-} reset (arqLanc);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('CHARQERR', 1);  {'Arquivo de lançamentos está vazio ou não foi achado.'}
            exit;
        end;

    ndocs := 0;
    while not eof (arqLanc) do
        begin
            ndocs := ndocs + 1;
            new (listaDoc [ndocs]);
            with listaDoc [ndocs]^ do
                begin
                    readln (arqLanc, dataDoc);
                    readln (arqLanc, tipoDoc);
                    readln (arqLanc, valordoc);
                    readln (arqLanc, debcred);
                    readln (arqLanc, serieDoc);
                    readln (arqLanc, numeroDoc);
                    readln (arqLanc, favorecidoDoc);
                    readln (arqLanc, finalidadeDoc);
                    readln (arqLanc, lixo);
                end;
            if eof (arqLanc) then break;
        end;

    close (arqLanc);
end;

{--------------------------------------------------------}

procedure guardaDocs;
var
    arqLanc: text;
    i: integer;
    dc: string[2];
begin
    assign (arqLanc, nomeArqLanc);
    {$I-} rewrite (arqLanc);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('CHLANNAT', 1);  {'Erro no arquivo de lançamentos.'}
            exit;
        end;

    for i := 1 to ndocs do
        with listaDoc[i]^ do
            begin
                writeln (arqLanc, dataDoc);
                writeln (arqLanc, tipoDoc);
                writeln (arqLanc, valordoc);
                dc := copy (debCred+' ', 1, 1);
                writeln (arqLanc, upcase (dc[1]));
                writeln (arqLanc, serieDoc);
                writeln (arqLanc, numeroDoc);
                writeln (arqLanc, favorecidoDoc);
                writeln (arqLanc, finalidadeDoc);
                writeln (arqLanc, '----------------------------------------');
            end;
    close (arqLanc);
end;

{--------------------------------------------------------}

procedure ordenaDocs;
var i, j: integer;
    temp: PDadosDoc;
    chave1, chave2: string;
begin
    for i := 1 to ndocs-1 do
        for j := i+1 to ndocs do
            begin
                with listaDoc[i]^ do
                    chave1 := copy (dataDoc, 7, 4) + copy (dataDoc, 4, 2) + copy (dataDoc, 1, 2) + copy (debcred, 1, 1);
                with listaDoc[j]^ do
                    chave2 := copy (dataDoc, 7, 4) + copy (dataDoc, 4, 2) + copy (dataDoc, 1, 2) + copy (debcred, 1, 1);
                if chave1 > chave2 then
                    begin
                        temp := listaDoc [i];
                        listaDoc[i] := listaDoc[j];
                        listaDoc[j] := temp;
                    end;
            end;

end;

{--------------------------------------------------------}

function calculaSaldo (n: integer): double;
var saldo, v: double;
    i: integer;
begin
    saldo := 0;
    for i := 1 to n do
        with listaDoc[i]^ do
            if debCred <> '' then
                begin
                    consisteConvValor (valorDoc, v);
                    case upcase (debCred[1]) of
                        'C': saldo := saldo + v;
                        'D': saldo := saldo - v;
                    end;
                end;

    calculaSaldo := saldo;
end;

{--------------------------------------------------------}

procedure falaLinhaLista (qual: integer);
var s: string;
    saldo: double;
begin
    if (qual <= 0) or (qual > ndocs) then
        exit;
    with listaDoc[qual]^ do
        begin
            sintetiza (copy (dataDoc, 1, 5));
            sintetiza (tipoDoc);
            s := valorDoc;
            if copy (s, length(s)-2, 3) = ',00' then
                delete (s, length(s)-2, 3);
            sintetiza (s);
            sintetiza ('saldo');
            saldo := calculaSaldo (qual);
            str (saldo:4:2, s);
            s [length (s)-2] := ',';
            if copy (s, length(s)-2, 3) = ',00' then
                delete (s, length(s)-2, 3);
            if s[1] = '-' then
                begin
                    delete (s, 1, 1);
                    s := s + ' negativo';
                end;
            sintetiza (s);
        end;
end;

{--------------------------------------------------------}

procedure mostraLista;
var l: integer;
    saldo: double;
    s: string;
begin
    for l := linhaVideo to linhaVideo + 9 do
        begin
            gotoxy (1, l-linhaVideo+4);
            if l = linhaArq then
                textColor (WHITE)
            else
                textColor (LIGHTGRAY);
            clreol;
            if l<= ndocs then
                with listaDoc[l]^ do
                    begin
                        write (dataDoc);
                        gotoxy (13, l-linhaVideo+4);
                        write (tipoDoc);
                        gotoxy (51-length (valorDoc), l-linhaVideo+4);
                        write (valorDoc);
                        saldo := calculaSaldo (l);
                        str (saldo:4:2, s);
                        s [length (s)-2] := ',';
                        gotoxy (68-length (s), l-linhaVideo+4);
                        write (s);
                    end;
        end;
    textColor (LIGHTGRAY);
end;

{--------------------------------------------------------}

procedure mostraDocAtual (qual: integer);
begin
    gotoxy (1, 15);
    writeln ('---------------------------------------------------------------------');
    if (qual > 0) and (qual <= ndocs) then
        with listaDoc[qual]^ do
            begin
                clreol;
                writeln (tipoDoc);
                clreol;
                write (valordoc);
                clreol;
                if debCred = 'D' then write (' Débito')
                else
                if debCred = 'C' then write (' Crédito');
                writeln;
                clreol;
                if favorecidoDoc <> '' then
                    writeln ('Favorecido: ', favorecidoDoc);
                clreol;
                if finalidadeDoc <> '' then
                    writeln ('Finalidade: ', finalidadeDoc);
                clreol;
                writeln ('Data: ', dataDoc);
                clreol;
                if serieDoc <> '' then
                    writeln ('Série: ', serieDoc);
                clreol;
                if numeroDoc <> '' then
                    writeln ('Número: ', numeroDoc);
            end;

    while wherey < 24 do
        begin
           clreol;
           writeln;
        end;
end;

{--------------------------------------------------------}

procedure leDocAtual (qual: integer);
begin
    if (qual > 0) and (qual <= ndocs) then
        with listaDoc[qual]^ do
            begin
                sintetiza (tipoDoc);
                sintetiza (valordoc);
                if debCred = 'D' then sintetiza (' Débito')
                else
                if debCred = 'C' then sintetiza (' Crédito');

                if favorecidoDoc <> '' then
                    sintetiza ('Favorecido: ' + favorecidoDoc);
                if finalidadeDoc <> '' then
                    sintetiza ('Finalidade: ' + finalidadeDoc);
                sintetiza ('Data: ' + dataDoc);
                if serieDoc <> '' then
                    sintetiza ('Série: ' + serieDoc);
                if numeroDoc <> '' then
                    sintetiza ('Número: ' + numeroDoc);
            end;
end;

{--------------------------------------------------------}

procedure ajudaFolheia;
var i: integer;
begin
    for i := 1 to 25 do
        begin
            gotoxy (1, i);
            clreol;
        end;

    gotoxy (1, 15);
    writeln ('-----------------------------------------------------------');
    mensagem ('CHAJFL00', 1);  {'Opções de folheamento'}
    mensagem ('CHAJFL01', 1);  {'A - alterar'}
    mensagem ('CHAJFL02', 1);  {'R - remover lançamento'}
    mensagem ('CHAJFL03', 1);  {'N - novo lançamento'}
    mensagem ('CHAJFL04', 1);  {'S - saldo final'}
    mensagem ('CHAJFL05', 1);  {'F5 - procura lançamento'}
    mensagem ('CHAJFL06', 1);  {'CTL F5 - procura próximo'}
    mensagem ('CHAJFL09', 1);  {'ESC termina'}

    while wherey < 24 do
        begin
            clreol;
            writeln;
        end;
end;

{--------------------------------------------------------}

procedure folheiaDocs;
var c, c2: char;
    terminou: boolean;
    a, m, d, w: word;
    pdoc: PDadosDoc;
    inibeFala: boolean;
    saldo: double;
    textoBusc, s: string;


    procedure cabec;
    begin
        gotoxy (1, 1);
        write ('Cheque Vox - ', bancoAtual);
        clreol;  writeln;
        write ('Data         Documento                        Valor           Saldo');
        clreol;  writeln;
        write ('-------------------------------------------------------------------');
        clreol; writeln;
    end;

    {--------------------------------------------------------}

    procedure editaDoc;
    begin
        if (linhaArq > 0) and (linhaArq <= ndocs) then
            begin
                new (pdoc);
                pdoc^ := listaDoc[linhaArq]^;
                if editaDadosDoc (pdoc^) then
                    begin
                        dispose (listaDoc[linhaArq]);
                        listaDoc[linhaArq] := pdoc;
                    end
                else
                    dispose (pdoc);
                ordenaDocs;
            end;

    end;

    {--------------------------------------------------------}

    procedure removeDoc;
    var i: integer;
    begin
        if (linhaArq > 0) and (linhaArq <= ndocs) then
            begin
                gotoxy (1, 22);
                clreol;
                mensagem ('CHCNFREM', 0);   {'Confirma remoção? '}
                sintLeTecla (c, c2);
                writeln;
                if upcase(c) <> 'S' then
                    begin
                        clreol;
                        mensagem ('CHDESIST', 0);  {'Desistiu'}
                        exit;
                    end;

                dispose (listaDoc [linhaArq]);
                for i := linhaArq to ndocs - 1 do
                    listaDoc [i] := listaDoc [i+1];
                ndocs := ndocs - 1;
            end;
    end;

{--------------------------------------------------------}

    procedure procuraDocDeNovo (primLinha: integer; textoBusc: string);
    var i: integer;

       function achou (s: string): boolean;
       begin
           s := maiuscAnsi (s);
           achou := pos (textoBusc, s) <> 0;
       end;

    begin
        textoBusc := maiuscAnsi (textoBusc);

        if primLinha < 1 then primLinha := 1;

        i := primLinha;
        while i <= ndocs do
            begin
                with listaDoc [i]^ do
                  begin
                      if achou (dataDoc) then break;
                      if achou (tipoDoc) then break;
                      if achou (valorDoc) then break;
                      if achou (debCred) then break;
                      if achou (serieDoc) then break;
                      if achou (numeroDoc) then break;
                      if achou (favorecidoDoc) then break;
                      if achou (finalidadeDoc) then break;
                  end;
                i := i + 1;
            end;

        gotoxy (1, 22);   clreol;
        if i > ndocs then
            begin
                mensagem ('CHNAOACH', 0);   {'Não achou'}
                while not keypressed do delay (100);
            end
        else
            begin
                mensagem ('CHACHOU', 0);   {'Achou'}
                linhaArq := i;
            end;
    end;

{--------------------------------------------------------}

    procedure procuraDoc;
    begin
        gotoxy (1, 22);   clreol;
        mensagem ('CHTXTBUS', 0);     {'Qual o texto buscado? '}
        sintReadln (textoBusc);
        if textoBusc = '' then exit;
        procuraDocDeNovo (linhaArq, textoBusc);
    end;

{--------------------------------------------------------}

begin
    clrscr;
    cabec;

    linhaArq := 0;
    linhaVideo := 1;

    terminou := false;
    inibeFala := false;
    mostraDocAtual (linhaArq);
    textoBusc := '';

    repeat
        mostraLista;
        gotoxy (1, linhaArq-linhaVideo + 4);

        c := readkey;

        if c = #$0 then
            case readkey of
                F1: ajudaFolheia;
                CIMA:   begin
                            linhaArq := linhaArq - 1;
                            if linhaArq < 0 then linhaArq := 0;
                        end;

                BAIX:   begin
                            linhaArq := linhaArq + 1;
                            if linhaArq > ndocs then linhaArq := ndocs + 1;
                        end;

                PGUP:  begin
                            linhaArq := linhaArq - 10;
                            if linhaArq < 0 then linhaArq := 0;
                        end;
                PGDN:  begin
                            linhaArq := linhaArq + 10;
                            if linhaArq > ndocs then linhaArq := ndocs + 1;
                        end;

                F5:     procuraDoc;
                CTLF5:  procuraDocDeNovo (linhaArq+1, textoBusc);
                F7:     removeDoc;

                CTLPGUP: linhaArq := 1;
                CTLPGDN: linhaArq := ndocs;
            end
        else
            case upcase(c) of
                ENTER, ' ':
                    begin
                        leDocAtual (linhaArq);
                        inibeFala := true;
                    end;

                'N':  begin
                           new (pdoc);
                           limpaDoc (pdoc^);
                           getDate (a, m, d, w);
                           pdoc^.dataDoc := int2 (d) + '/' + int2 (m) + '/' + int2str (a);

                           if editaDadosDoc (pdoc^) then
                               begin
                                   ndocs := ndocs + 1;
                                   listaDoc[ndocs] := pDoc;
                                   ordenaDocs;
                               end
                           else
                               dispose (pdoc);
                      end;

                'E':  editaDoc;
                'R':  removeDoc;
                'P':  procuraDoc;
                'S':  begin
                          saldo := calculaSaldo (ndocs);
                          str (saldo:4:2, s);
                          s [length (s)-2] := ',';
                          if copy (s, length(s)-2, 3) = ',00' then
                              delete (s, length(s)-2, 3);
                          if s[1] = '-' then
                              begin
                                  delete (s, 1, 1);
                                  s := s + ' negativo';
                              end;

                          gotoxy (1, 22);
                          mensagem ('CHSALFIN', 0);   {'Saldo final: '}
                          sintWriteln (s);
                          while not keypressed do delay (100);
                      end;

                ESC:
                    begin
                        terminou := true;
                        inibeFala := true;
                    end;
            end;

        while linhaVideo > linhaArq do
            if linhaVideo > 1 then
                linhaVideo := linhaVideo - 1
            else
                break;

        while linhaVideo + 9 < linhaArq do
            if linhaVideo < ndocs then
                linhaVideo := linhaVideo + 1
            else
                break;

    mostraDocAtual (linhaArq);
    if (linhaArq <= 0) or (linhaArq > ndocs) then
        sintbip
    else
        if not inibeFala then
            begin
                mostraLista;
                falaLinhaLista (linhaArq);
            end;
    inibeFala := false;

    cabec;
    until terminou;

    clrscr;
end;

{--------------------------------------------------------}

procedure folhear;
var i: integer;
begin
    if nomeArqLanc = '' then
        begin
            mensagem ('CHARQNDF', 1);  {'Nome do arquivo de lançamentos não foi definido.'}
            exit;
        end;

    carregaDocs;
    ordenaDocs;
    folheiaDocs;
    guardaDocs;

    for i := 1 to ndocs do
        dispose (listaDoc[i]);
end;

{--------------------------------------------------------}

procedure geraExtrato;
var arqTxt: text;
    nomeArqTxt: string;
    l, i: integer;
    s, lin: string;
    saldo: double;
begin
    if nomeArqLanc = '' then
        begin
            mensagem ('CHARQNDF', 1);  {'Nome do arquivo de lançamentos não foi definido.'}
            exit;
        end;

    mensagem ('CHQTXT', 1);   {'Informe o nome do arquivo TXT a gerar'}
    sintReadln (nomeArqTxt);
    while (nomeArqTxt <> '') and (nomeArqTxt[1] = ' ') do
        delete (nomeArqTxt, 1, 1);

    if nomeArqTxt = '' then
        begin
            mensagem ('CHARQINC', 1);    {'Nome de arquivo incorreto.'}
            exit;
        end;

    carregaDocs;
    ordenaDocs;

    assign (arqTxt, nomeArqTxt);
    {$I-}  rewrite (arqTxt);  {$I+}
    if ioresult <> 0 then
         begin
            mensagem ('CHARQNCR', 1);    {'Arquivo não pôde ser criado.'}
            exit;
         end;

    writeln (arqTxt, 'Cheque Vox - ', bancoAtual);
    writeln (arqTxt, 'Data        Número      Documento                        Valor            Saldo');
    writeln (arqTxt, '-------------------------------------------------------------------------------');

    for l := 1 to ndocs do
        with listaDoc[l]^ do
            begin
                lin := dataDoc;

                while length (lin) < 12 do lin := lin + ' ';
                lin := lin + numeroDoc;

                while length (lin) < 24 do lin := lin + ' ';
                lin := lin + tipoDoc;

                while length (lin) < 62-length(valorDoc) do lin := lin + ' ';
                lin := lin + valorDoc;

                saldo := calculaSaldo (l);
                str (saldo:4:2, s);
                s [length (s)-2] := ',';
                while length (lin) < 79-length (s) do lin := lin + ' ';
                lin := lin + s;

                writeln (arqTxt, lin);
            end;

    close (arqTxt);

    for i := 1 to ndocs do
        dispose (listaDoc[i]);

    mensagem ('CHOK', 1);     {'OK.'}
end;

end.