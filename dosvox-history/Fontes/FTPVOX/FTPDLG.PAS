{-------------------------------------------------------------}
{
{    Programa de Transferência Remota de Arquivos
{
{    Rotinas de acesso à rede
{
{    Autor: Jose' Antonio Borges
{
{    Em 21/04/98
{
{-------------------------------------------------------------}

unit ftpDlg;
interface

uses
    dvCrt, dvWin, sysUtils, winsock, winprocs,
    ftpVars, ftpMsg, ftpRede;

function enviaComando (msg: string): boolean;
procedure pegaResposta (var s: string; var codigo: integer; var continua: boolean);
procedure mostraRespostas (var cod: integer);
procedure falaRespostas (var cod: integer; comCodigo, tamanhoArq: boolean);

implementation

{-------------------------------------------------------------}
{         envia uma mensagem, interpretando resposta
{-------------------------------------------------------------}

function enviaComando (msg: string): boolean;
var p: array [0..255] of char;
label erro;
begin
    if debug then
        begin
            textColor (yellow);
            writeln (msg);
            textColor (white);
        end;

    msg := msg + #$0d + #$0a;
    enviaComando := true;

    strPCopy (p, msg);
    if send (sock, p, length (msg), 0) <= 0 then
        goto erro;

    processaRede;
    exit;

erro:
    mensagem ('FTCOMINT', 1);  {'Comunicação foi interrompida'}
    enviaComando := false;
end;

{-------------------------------------------------------------}
{         pega uma linha recebida, interpretando codigo
{-------------------------------------------------------------}

procedure pegaResposta (var s: string; var codigo: integer; var continua: boolean);
var cod: string;
    i, erro: integer;
begin
    codigo := 0;
    s := '';
    if pins = pret then
        exit;

    s := bufLinhas [pret]^;
    dispose (bufLinhas [pret]);

    textColor (yellow);
    if verboso then
        sintWriteln (s)
    else
        writeln (s);
    textColor (white);

    pret := (pret + 1) mod MAXLINHAS;

    cod := '';
    i := 1;
    while s[i] = ' ' do i := i + 1;
    while s[i] in ['0'..'9'] do
        begin
            cod := cod + s[i];
            i := i + 1;
        end;

    codigo := 0;
    val (cod, codigo, erro);
    continua := (s[i] = '-') or (codigo = 0);
end;

{-------------------------------------------------------------}
{                  mostra as respostas do servidor
{-------------------------------------------------------------}

procedure mostraRespostas (var cod: integer);
var s: string;
    continua: boolean;
begin
    repeat
        begin
            if wherex <> 1 then writeln;
            pegaResposta (s, cod, continua);
            if (not verboso) and debug then
                begin
                    textColor (blue);
                    writeln (s);
                    textColor (white);
                end;
        end;

        if continua and (pins = pret) then
             processaRede;
    until not continua;
end;

{--------------------------------------------------------}
{                  Formata o tamanho do arquivo
{--------------------------------------------------------}

function formataTamanhoArq ( tam: int64): string;
var
    medida: string[2];
    decimal: integer;
begin
    medida := '';
    if tam >= 65536 then
        begin
            medida := 'K';
            decimal := tam mod 1024;
            tam := tam div 1024;
            if decimal > 512 then tam := tam + 1;
        end;
    if tam >= 65536 then
        begin
            medida := 'MB';
            decimal := tam mod 1024;
            tam := tam div 1024;
            if decimal > 512 then tam := tam + 1;
        end;

    result := intToStr (tam) + medida;
end;

{-------------------------------------------------------------}
{                  fala as respostas do servidor
{-------------------------------------------------------------}

procedure falaRespostas (var cod: integer; comCodigo, tamanhoArq: boolean);
var
    s: string;
    i: int64;
    erro: integer;
    continua: boolean;
begin
    repeat
        while pins <> pret do
            begin
                pegaResposta (s, cod, continua);
                if not comCodigo then
                    if (s <> '') and (s[1] in ['0'..'9']) then
                        delete (s, 1, 4);

                if tamanhoArq then
                    begin
                        val (trim(s), i, erro);
                        if erro = 0 then s := formataTamanhoArq (i);
                    end;

                sintetiza (utf8ToAnsi(s));
            end;

        if continua then processaRede;
    until not continua;
end;

{-------------------------------------------------------------}

begin
end.
