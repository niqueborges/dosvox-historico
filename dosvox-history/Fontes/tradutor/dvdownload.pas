unit dvdownload;

interface
uses
    dvcrt, dvwin, dvinet, sysUtils, classes, synacode, windows;

function download (url, nomeArqBaixar: string; progresso: integer): integer;

const
    DNWL_OK = 0;
    DNWL_ERRO_CONEXAO  = 1;
    DNWL_ERRO_HTTP     = 2;
    DNWL_ERRO_DOWNLOAD = 3;
    DNWL_ERRO_ESCRITA  = 4;
    DNWL_CANC  = 5;
implementation

const
    CRLF = #$0d + #$0a;
var
    retornoDownload: integer;
    statusUltIO: integer;
tamarq : int64;
{--------------------------------------------------------}

function traduzURL (url: string; out protocolo, nomeComput: string;
                                 out porta: integer;
                                 out recurso: string): boolean;
var
    i: integer;
    erro: integer;
    s: string;
begin
    traduzURL := false;

    url := trim(url);
    i := pos('://' , url);
    if i = 0 then
        protocolo := 'http'
    else
        begin
            protocolo := copy(url, 1, (i-1));
            url := copy(url, (i+3), 999999);
        end;
    protocolo := upperCase(protocolo);

    i := pos('/', url);
    if i = 0 then
        i := pos('?', url);

    if i = 0 then
        begin
            recurso := '';
            nomeComput := url;
        end
    else
        begin
            nomeComput := copy(url, 1, (i-1));
            recurso := copy(url, i, 999999);
            if copy(recurso, 1,1) = '?' then
                recurso := '/' + recurso;
        end;

    i := pos(':', nomeComput);
    if i <> 0 then
        begin
            s := copy(nomeComput, (i+1), 999999);
            nomeComput := copy(nomeComput, 1, i-1);
            val (s, porta, erro);
            if erro <> 0 then
                exit;
        end
    else
        if protocolo = 'HTTPS' then
            porta := 443
        else
            porta := 80;

    if recurso = '' then
        recurso := '/';

    i := pos('?', recurso);
    if i <> 0 then
        recurso := copy(recurso, 1,i) + copy(recurso, i+1,999999);

    traduzURL := true;
end;

{--------------------------------------------------------}

function pegaHeader (protocolo, nomeComput: string; porta: integer; recurso: string;
                     out codRetorno: integer;
                     out novaUrl: string;
                     out pbuf: PbufRede;
                     out soquete: integer): boolean;

var s: string;
    i: integer;
    header: TStringList;
    aEnviar: string;

begin
    pegaHeader := false;
    codRetorno := 500;
    novaUrl := '';

    if ansiUpperCase(protocolo) = 'HTTPS' then
        soquete := abreConexaoSSL (nomeComput, porta)
    else
        soquete := abreConexao (nomeComput, porta);
    if soquete < 0 then
        begin
            retornoDownload := DNWL_ERRO_CONEXAO;
            exit;
        end;

    aEnviar :=
        'GET ' + recurso + ' HTTP/1.0' + CRLF +
        'UA-CPU: x86' + CRLF +
        'Connection: Close' + CRLF +
        'Accept-Language: pt-br' + CRLF +
        'User-Agent: DVDownload ' + '1.0' + CRLF +
        'Host: ' + nomeComput + CRLF +
        CRLF;

    statusUltIO := ord (writeRede(soquete, aEnviar));

    pBuf := inicBufRede (soquete);

    header := TStringList.Create;
    repeat
        statusUltIO := ord (not readlnBufRede (pbuf, s, 30));
        header.add(s);
    until (statusUltIO <> 0) or (s = '');

    if copy(header[0], 1,4) <> 'HTTP' then   // erro no servidor
        begin
            retornoDownload := DNWL_ERRO_HTTP;
            header.Free;
            fechaConexao(soquete);
            fimBufRede(pbuf);
            pbuf := NIL;
            exit;
        end;

    s := header[0];
    i := pos(' ', s);
    codRetorno := StrToInt(copy(s, i+1, 3));

    if (codRetorno div 100) = 3  then  // relocators
        begin
            // pega o location
            for i := 0 to (header.Count-1) do
                begin
                    if pos('LOCATION:', upperCase(header[i])) = 1 then
                        novaUrl := trim(copy(header[i], 10 , 999999));
                end;
            fimBufRede (pbuf);
            fechaConexao(soquete);
        end;

        tamArq :=0;

        if codRetorno = 200 then
            begin
                for i := 1 to header.Count-1 do
                    if copy (trim(ansiUpperCase(header[i])), 1, 14) = 'CONTENT-LENGTH' then
                        begin
                            s := header[i];
                            delete(s,1,pos(':',s));
                            s := trim(s);
                            tamArq := strToInt64(s);
                            break;
                        end;
            end;

    header.Free;
    pegaHeader := true;
end;

{--------------------------------------------------------}

function abreUrl(url: string; out pBuf: pbufrede; out soquete: integer): boolean;
var
    protocolo, nomeComput, recurso: string;
    porta: integer;
    novaUrl: string;
    codRetorno: integer;

begin
    abreUrl := false;
    novaUrl := url;

    codRetorno := 300;
    while (codRetorno div 100) = 3  do
        begin
            if not traduzURL (novaUrl, protocolo, nomeComput, porta, recurso) then
                exit;

             if not pegaHeader (protocolo, nomeComput, porta, recurso,
                               codRetorno, novaUrl, pbuf, soquete) then
                exit;
       end;

    abreUrl := true;
 end;

{--------------------------------------------------------}

function copiaURLparaArquivo (pbuf: PbufRede; soquete: integer;
                          nomeArqBaixar: string;  progresso: integer): boolean;
const
    TAMBUF = 8192;
var
    arq: file;
    lidoOk: boolean;
    buf: packed array [0..TAMBUF-1] of char;
    ncbuf: integer;
    c, k: char;
    escritos: integer;
quantobaixou, quantobaixouantes, quantosporcento, quantosporcentoantes: int64;
begin
     copiaURLparaArquivo := false;
     statusUltIO := 0;
     ncbuf := 0;
quantobaixou := 0;
quantosporcento := 0;
quantosporcentoantes := 0;
if progresso > 0 then
 begin
if tamarq >= 1099511627776 then
sintwriteln ('Baixando '+inttostr(tamarq div 1024 div 1024 div 1024 div 1024)+' TB')
else
if tamarq >= 1073741824 then
sintwriteln ('Baixando '+inttostr(tamarq div 1024 div 1024 div 1024)+' GB')
else
if tamarq >= 1048576 then
sintwriteln ('Baixando '+inttostr(tamarq div 1024 div 1024)+' MB')
else
if tamarq >= 1024 then
sintwriteln ('Baixando '+inttostr(tamarq div 1024)+' KB');
end;

     assign (arq, nomeArqBaixar);
     {$I-}  rewrite (arq, 1);  {$I+}
     if ioresult <> 0 then
         begin
             statusUltIO := 1;
             retornoDownload := DNWL_ERRO_ESCRITA;
             exit;
         end;

    repeat
        lidoOk := leCaracBufRede(pbuf, c);
        if lidoOk then
            begin
                buf[ncbuf] := c;
                ncbuf := ncbuf + 1;
            end;

        if ncbuf >= TAMBUF then
            begin
                escritos := 0;
                blockWrite (arq, buf, ncbuf, escritos);
                if escritos <> ncbuf then
                    begin
                        retornoDownload := DNWL_ERRO_ESCRITA;
                        statusUltIO := 1;
                        lidoOk := false;
                    end;
                    quantobaixou := quantobaixou + escritos;
                    if tamarq > 0 then
begin
                        quantosporcento := quantobaixou * 100 div tamarq;

                    if (quantosporcento > 0) and (quantosporcento mod 10 = 0) and (quantosporcento <> quantosporcentoantes)then
                    begin
case progresso of
3..5:
sintwriteln(inttostr(quantosporcento)+'%');
6..8:
beep(quantosporcento *20,200);
end;
                        quantosporcentoantes := quantosporcento;
                    end;
end
else
if (quantobaixou div 1024 div 1024 > 0) and
 ((quantobaixou div 1024 div 1024) mod 8 = 0) and
(quantobaixou div 1024 div 1024 <> quantobaixouantes) then
begin
case progresso of
1,4,7:
    sintwriteln(inttostr(quantobaixou div 1024 div 1024)+' MB gravados');
2,5,8:
beep((quantobaixou div 1024 div 1024)*10,200);
end;
quantobaixouantes := quantobaixou div 1024 div 1024;
end;

                ncbuf := 0;
end;
if keypressed then begin
k := readkey;
case k of
^z: begin
Sintwriteln ('Cancelando...');
    closeFile (arq);
retornodownload := DNWL_CANC;
             statusUltIO := 1;
exit;
end;

enter: begin
if  tamarq > 0 then sintwriteln (inttostr(quantosporcento)+'% de '+inttostr(tamarq div 1024 div 1024)+' MB')
else
sintwriteln(inttostr(quantobaixou div 1024 div 1024)+' MB gravados');
end;
' ': begin
progresso := progresso + 1;
    if progresso > 8 then progresso := 0;
sintetiza('Modo progresso: '+inttostr(progresso));
end;
end;
end;
    until not lidoOk;

    if ncbuf <> 0 then
        begin
            escritos := 0;
            blockWrite (arq, buf, ncbuf, escritos);
            if escritos <> ncbuf then
                begin
                    retornoDownload := DNWL_ERRO_ESCRITA;
                    statusUltIO := 1;
                end;
            end;

    closeFile (arq);
    copiaURLparaArquivo := true;
end;

{--------------------------------------------------------}

function download (url, nomeArqBaixar: string; progresso: integer): integer;
var
    pbuf: PbufRede;
    soquete: integer;

label erro;
begin
    if not abreWinSock then  // abre mesmo se aberto
        retornoDownload := DNWL_ERRO_CONEXAO
    else
        begin
            if abreUrl(url, pbuf, soquete) then
                begin
                    if copiaURLparaArquivo (pbuf, soquete, nomeArqBaixar,progresso) then
                        retornoDownload := DNWL_OK;
                    fimBufRede(pbuf);
                    fechaConexao(soquete);
                end;
        end;

    result := retornoDownload;
end;

end.
