{-------------------------------------------------------------}
{
{    Traduvox - tradutor de textos usando o Google Translator
{
{    Módulo de envio/recepção da tradução
{
{    Autores: Antonio Borges & Julio Silveira
{
{    Atualizado por Patrick Barboza
{
{    Em dezembro/2023
{
{    Com a colaboração de Fabiano Ferreira
{
{-------------------------------------------------------------}

unit trgoogle;

interface
uses
  dvwin,
  dvcrt,
  dvinet,
  winsock,
  sysUtils,
  classes,
  trMsg,
  trnet;

function traduzArquivoGoogle (nomeArq: string; aTraduzir, linguaOrig: string;
                              var traduzido: string; linguaDest: string): string;

implementation
var
    sock: integer;
    pbuf: PbufRede;

{-------------------------------------------------------------}

function traduzArquivoGoogle (nomeArq: string; aTraduzir, linguaOrig: string;
                              var traduzido: string; linguaDest: string): string;
var
    s, status: string;
    p: integer;

    nomePag,
    scheme: string;
begin
    result := '';
    nomePag := 'translate.google.com';
    scheme := 'HTTPS';

    if nomeArq = '' then
        exit;

    aTraduzir := stringtourl(ansitoutf(aTraduzir));
    s :=   'GET /m?sl='+linguaOrig+'&tl='+linguaDest+'&q='+aTraduzir+'&op=translate HTTP/1.1'             + CRLF +
        'Host: '+nomePag + CRLF +
        'Connection: Close'                      + CRLF +
        'Accept: */*'                 + CRLF +
        'Accept-Encoding: identity'                 + CRLF +
        'UA-CPU: x86'                            + CRLF +
        'User-Agent: Webvox'                 + CRLF;
    if scheme = 'HTTPS' then
        sock := abreConexaoSSL (nomePag, 443)
    else
        sock := abreConexao (nomePag, 80);
    if sock <= 0 then
        begin
            mensagem ('TRNOGOOG',2);  {'Google translator está inacessível.'}
            exit;
        end;

    pbuf := inicBufRede(sock);
    writelnRede (sock, s);

    {*
     *  Traz cabeçalho da mensagem
     *}
    nlinCabecHTTP := 0;

    if not readlnBufRede (pbuf, s, 10) then
        s := '';
    status := s;

    {*  Primeira linha: código da resposta *}

    delete (status, 1, pos (' ', status));
    result := status;

    {* Armazena todas as linhas do cabecalho *}

    while s <> '' do
    begin
        inc(nlinCabecHTTP);
        cabecHTTP[nlinCabecHTTP] := s;
        if not readlnBufRede (pbuf, s, 10) then
            s := '';
    end;

    // Traz dados após o cabeçalho
    while readlnBufRede (pbuf, s, 10) and (s <> '') do
    begin
        traduzido := traduzido + s;
    end;

    fimBufRede(pbuf);
    closeSocket (sock);
    if (copy (status, 1, 3) <> '200') then
        exit;

    {*  Procura e extrai texto traduzido *}
    p := pos ('"result-container">', traduzido);
    if (p <> 0) then
    begin
        p := p + 19;
        traduzido := copy(traduzido,p,length(traduzido)-p+1);
        traduzido := copy (traduzido,1,pos('<',traduzido)-1);
        traduzido := utfToAnsi(traduzido);
        traduzido := subsCaracs(traduzido);
    end
    else
        traduzido := '';
    end;
end.
