{-------------------------------------------------------------}
{
{    Webvox - Módulo de substituição de javaScript
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit webjava;

interface
uses windows, sysutils, classes, shellApi,
     dvcrt, dvWin, winsock,
     webVars, webMsg, dvScript;

function simulaJavaScript (nomePag: string): string;

implementation

function simulaJavaScript (nomePag: string): string;
var
    nomeCmd, proc, param: string;
    p: integer;
//    linhaProc: string;
begin
    simulaJavaScript := nomePag;

    mensagem ('WBJAVA', 1);  {'Simulando Java Script'}

    nomeCmd := sintAmbiente ('WEBVOX', 'JAVASCRIPT');
    if nomeCmd = '' then
        nomeCmd := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\webjava.cmd'; //Neno

    p :=  pos ('JAVASCRIPT:', maiuscAnsi(nomePag));
    if p = 0 then exit;

    proc := copy (nomePag, p+11,999);
    p := pos ('(', proc);

    param := trim (copy (proc, p+1, 999));
    delete (param, length (param), 1);
    if (param <> '') and (param[1] = '''') then
        delete (param, 1, 1);
    if (param <> '') and (param[length(param)] = '''') then
        delete (param, length (param), 1);

    delete (proc, p, 999);
    param := trim (param);
    proc := trim (proc);

(*
    executaLinha ('P = ' + nomePag);
    executaLinha ('J = ' + proc);
    executaLinha ('X = ' + param);
    executaLinha ('N = ' + param);

    ultLinhaProc := 0;

    if executaScript (nomeCmd, proc, ultLinhaProc, linhaProc) <> SCR_OK then
        begin
            mensagem ('WBNAODSP', 1);   {'Operação não disponível'}
            sintWriteln ('Javascript:' + proc + '(' + param + ')');
        end;
//    simulaJavaScript := varScript ['N'];

    simulaJavaScript := calculaExpressao('N');

*)

    mensagem ('WBNAODSP', 1);   {'Operação não disponível'}
    sintWriteln ('Javascript:' + proc + '(' + param + ')');
end;

end.
