{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Download de arquivo pela WEB                        }
{                                                        }
{    baseado na unit DOSUPDAT do Dosvox                  }
{                                                        }
{    Autores:  José Antonio Borges                       }
{              Júlio Tadeu Carvalho da Silveira          }
{              Marcolino Matheus de Souza Nascimento     }
{                                                        }
{    Em fevereiro de 2018                                }
{                                                        }
{--------------------------------------------------------}

unit rdDownld;

interface
uses
    windows,
    sysUtils,
    classes,
    dvcrt,
    dvwin,
    dvinet,
    dvarq,
    rdmsg,
    synacode;

function GetTempDir: string;
function GetTempFile: string;
function baixaArquivo (site, arquivoABaixar: string; aceitaErro: boolean): boolean;
function BaixaStringList (site: string; var sl: TStringList): boolean;

implementation

const
    CRLF = #$0d + #$0a;

var
    statusUltIO: integer;
    pbuf: PbufRede;
    soquete: integer;

{--------------------------------------------------------}
{            Descobre diretório de trabalho
{--------------------------------------------------------}

function GetTempDir: string;
var
    TempPath: array[0..511] of Char;

begin
    GetTempPath(512, TempPath);
    Result := StrPas(TempPath);
end;

{--------------------------------------------------------}
{            Descobre arquivo temporario
{--------------------------------------------------------}

function GetTempFile: string;
var
    TempPath, TempFile: array[0..511] of Char;

begin
    GetTempPath(512, TempPath);
    GetTempFileName(TempPath, PChar('rad'), 0, TempFile);
    Result := StrPas(tempFile);
end;

{--------------------------------------------------------}
{                  Traduz a url
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
        url := copy(url, (i+3), 999);
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
                recurso := copy(url, i, 999);
                if copy(recurso, 1,1) = '?' then
                    recurso := '/' + recurso;
            end;

        i := pos(':', nomeComput);
        if i <> 0 then
            begin
                s := copy(nomeComput, (i+1), 999);
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
            recurso := copy(recurso, 1,i) + EncodeURL(copy(recurso, i+1,999));

        traduzURL := true;
end;

{--------------------------------------------------------}
{                  Pega o cabeçalho
{--------------------------------------------------------}

function pegaHeader (protocolo, nomeComput: string; porta: integer; recurso: string;
                         out codRetorno: integer;
                         out novaUrl: string;
                         out pbuf: PbufRede;
                         out soquete, tamArq: integer): boolean;

var s,aux: string;
    i, l: integer;
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
           exit;
       end;

    aEnviar :=
        'GET ' + EncodeURL(recurso) + ' HTTP/1.0' + CRLF +
        'UA-CPU: x86' + CRLF +
        'Connection: Close' + CRLF +
        'Accept-Language: pt-br' + CRLF +
        'User-Agent: Webvox 2.4' + CRLF +
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
                mensagem('RDERRSRV',1); {'Erro na comunicação com o servidor de rádios'}
                header.Free;
                fechaConexao(soquete);
                fimBufRede(pbuf);
                pbuf := NIL;
                exit;
            end;

        s := header[0];
        i := pos(' ', s);
        codRetorno := StrToInt(copy(s, i+1, 3));

        tamArq :=0;
        if codRetorno = 200 then
            begin
                for l := 1 to header.Count-1 do
                    if copy (trim(ansiUpperCase(header[l])), 1, 14) = 'CONTENT-LENGTH' then
                        begin
                            aux := header[l];
                            delete(aux,1,pos(':',aux));
                            aux := trim(aux);
                            tamArq := strToInt(aux);
                            break;
                        end;
            end;

        if (codRetorno div 100) = 3  then  // relocators
            begin
                // pega o location
                for i := 0 to (header.Count-1) do
                    begin
                        if pos('LOCATION:', upperCase(header[i])) = 1 then
                            novaUrl := trim(copy(header[i], 10 , 999));
                    end;
                fimBufRede (pbuf);
                fechaConexao(soquete);
            end;

        header.Free;
        pegaHeader := true;
    end;

{--------------------------------------------------------}
{                  abre a url
{--------------------------------------------------------}

function abreUrl(url: string; out pBuf: pbufrede; out soquete, tamArq: integer): boolean;
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
                                   codRetorno, novaUrl, pbuf, soquete, tamArq) then
                    exit;
       end;

    abreUrl := codRetorno = 200;
end;

{--------------------------------------------------------}
{          Copia conteúdo da url para um arquivo
{--------------------------------------------------------}

function copiaURLparaArquivo (pbuf: PbufRede; soquete: integer;
                              nomeArqBaixar: string; tamArq: Integer): boolean;
const
    TAMBUF = 8192;
var
    arq: file;
    lidoOk: boolean;
    buf: packed array [0..TAMBUF-1] of char;
    ncbuf: integer;
    c: char;
    escritos: integer;
label cancela;
begin
     copiaURLparaArquivo := false;
     statusUltIO := 0;
     ncbuf := 0;

     assign (arq, nomeArqBaixar);
     {$I-}  rewrite (arq, 1);  {$I+}
     if ioresult <> 0 then
         begin
             statusUltIO := 1;
             mensagem('RDERRWAR',1); {'Erro de escrita do arquivo'}
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
                        mensagem('RDERRWAR',1); {'Erro de escrita do arquivo'}
                        statusUltIO := 1;
                        lidoOk := false;
                    end;
                ncbuf := 0;
            end;
    until not lidoOk;

    limpaBufTec;
    if ncbuf <> 0 then
        begin
            blockWrite (arq, buf, ncbuf, escritos);
            if escritos <> ncbuf then
                begin
                    mensagem('RDERRWAR',1); {'Erro de escrita do arquivo'}
                    statusUltIO := 1;
                end;
        end;

    closeFile (arq);
    copiaURLparaArquivo := true;
    exit;

cancela:
    mensagem ('RDDESIST', 2);   {Desistiu}
    closeFile (arq);
    {$I-} DeleteFile(nomeArqBaixar); {$I+}
    ioresult;
end;

{--------------------------------------------------------}
{               Faz o download de um arquivo
{--------------------------------------------------------}

function baixaArquivo (site, arquivoABaixar: string; aceitaErro: boolean): boolean;
var
    tamArq: integer;

label erro;
begin
    result := false;

    if abreUrl(site, pbuf, soquete, tamArq) then
        begin
          if copiaURLparaArquivo (pbuf, soquete, arquivoABaixar, tamArq) or aceitaErro then
            begin
                result := true;
            end;
          fimBufRede(pbuf);
          fechaConexao(soquete);
        end;
end;

function BaixaStringList (site: string; var sl: TStringList): boolean;
var tempFile: string;
begin
    if fileExists(site) then
        begin
            sl.LoadFromFile(site);
            result := true;
        end
    else
        begin
            tempFile := getTempFile;
            result := baixaArquivo (site, tempFile, true);
            sl.loadFromFile (tempFile);
            deleteFile (tempFile);
        end;
end;

end.

