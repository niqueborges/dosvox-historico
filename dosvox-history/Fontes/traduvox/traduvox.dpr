{-------------------------------------------------------------}
{
{    Traduvox - tradutor de textos usando o Google Translator
{
{    Autor: José Antonio Borges
{
{    Em 14/05/2010
{
{    Atualizado por Neno Albernaz para versão 3.2 - Em 28/08/2021
{    Otimização das mensagens quando chamado com parãmetros.
{
{    Atualizado por Patrick Barboza
{
{    Em dezembro/2023 - Versão 3.3
{
{    Com a colaboração de Fabiano Ferreira
{
{-------------------------------------------------------------}

program traduvox;
uses
  dvwin,
  dvcrt,
  dvinet,
  sysUtils,
  trmsg,
  trvars,
  trintera,
  trtraduz,
  trsintet;

{$R *.res}

procedure termina;
begin
    writeln;
    if interativo then
        mensagem ('TRFIM', 0)   {'Fim do Traduvox'}
    else
        mensagem ('TROK', 0);   {'Ok'}
    fechaWinSock;
    sintFim;
    doneWinCrt;
end;

function pegaParam (var param: string): string;
var p: integer;
begin
    result := '';
    param := trim (param);
    if param = '' then exit;

    if param[1] = '"' then
        begin
            delete (param, 1, 1);
            p := pos ('"', param);
            if p = 0 then
                begin
                    result := param;
                    param := '';
                end
            else
                begin
                    result := copy (param, 1, p-1);
                    delete (param, 1, p);
                    param := trim (param);
                end;
        end
    else
        begin
             p := pos (' ', param);
             if p = 0 then
                 begin
                     result := param;
                     param := '';
                 end
             else
                 begin
                     result := copy (param, 1, p-1);
                     delete (param, 1, p);
                     param := trim (param);
                 end;
        end;
end;

procedure inicializa;
label erro;
var params: string;
    dir: string;
begin
    dir := sintAmbiente ('TRADUVOX', 'DIRTRADUVOX');
    if dir = '' then
        dir := 'c:\winvox\som\traduvox';
    sintInic (0, dir);

    textBackground (BLUE);
    if paramCount = 0 then
        begin
            mensagem ('TRINIC', 0);    {'TRADUVOX - NCE/UFRJ - v.'}
            sintSoletra (versao);
            write(versao);
            if tipoVersao <> '' then
            begin
                writeln(' '+tipoversao);
                sintetiza(tipoVersao);
            end;
        end
    else
        begin
            mensagem ('TRINIC', -1);    {'TRADUVOX - NCE/UFRJ - v.'}
            writeln (versao);
        end;
    textBackground (BLACK);
    writeln; writeln;

    textColor (GREEN);
    mensagem ('TRGOOGLE', -2);  {'Este programa utiliza a tecnologia Google Translator'}
    mensagem ('TRCOLAB', -2);  {'Com a colaboração de Fabiano Ferreira'}
    textColor (WHITE);

    while sintFalando do delay (100);   // não reseta sapi enquanto não terminar de falar

    if sapiPresente then
        presetSapi;

    interativo := paramCount = 0;
    if not interativo then
        begin
            if paramcount < 3 then goto erro;
            params := CmdLine;

            pegaParam (params);   // nome do programa;
            linguaOrig  := pegaParam (params);
            linguaDest  := pegaParam (params);
            nomeArqOrig := pegaParam (params);
            nomeArqDest := pegaParam (params);

            if not fileExists (nomeArqOrig) then
                begin
                    mensagem ('TRARQNAO', 2);  {'Arquivo origem não existe'}
                    goto erro;
                    termina;
                end;
        end;

    abreWinSock;

    exit;
erro:
    mensagem ('TRUSO1', 1);  {'Uso: traduvox linguaorig linguadest arqorigem [arqdestino]'}
    mensagem ('TRUSO2', 1);  {'Os códigos usados para as línguas são os mesmos do Google'}
    mensagem ('TRUSO3', 2);  {'PT = Português  EN = Inglês  SP = espanhol etc...'}
    mensagem ('TRENTER', 1); {'Tecle enter'}
    readln;
    sintFim;
    doneWinCrt;
end;

begin
    inicializa;
    setWindowTitle ('Traduvox');
    if interativo then
        processaInterativo
    else
    begin
        if nomeArqDest <> '' then
            traduzArquivo (nomeArqOrig, 'A', nomeArqDest)
        else
            traduzArquivo (nomeArqOrig, 'L', nomeArqDest);
    end;
    termina;
end.
