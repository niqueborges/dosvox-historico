{--------------------------------------------------------}
{
{           cartaVox - rotinas para tratamento IMAP
{
{       Por: Neno Albernaz --> neno@intervox.nce.ufrj.br
{       Em: 15/05/2013
{
{--------------------------------------------------------}

unit carIMAP;

interface

uses
    dvcrt,
    dvexec,
    dvWin,
    sysutils,
    windows,
    careMudo,
    carUtil,
    carVars,
    carMsg;

procedure chamaIMAPUtil;

implementation

{-------------------------------------------------------------}
{       Chama o programa externo IMAPUtgil.exe em Winvox
{-------------------------------------------------------------}

procedure chamaIMAPUtil;
var
    s, senha: string;
    c1: char;
    salvaAttr: word;
begin
    s := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\IMAPUtil.exe';
    if not fileExists (s) then
        begin
            msgBaixo('CTNEIMAP'); {'Não encontrei o utilitário IMAPUtil.'}
            exit;
        end;

    c1 := ' ';
    if trim (senhaSalva) = '' then
        begin
            senha := '';
            salvaAttr := textattr;
            textBackground (RED);
            mensagem ('CTINFSEN', 1);  {'Informe sua senha'}
            textBackground (BLACK);
            textColor (BLACK);
            c1 := sintEditaCampoMudo (senha, 1, wherey, 255, 80, true);
            writeln;
            textAttr := salvaAttr;
            if trim (senha) <> '' then senhaSalva := senha;
        end;

    if (c1 <> ESC) and (trim(senhaSalva) <> '') then
        if executaProg ( s, dirRecebe, hostIMAP+' '+ intToStr(portaImap)+' '+ contaUsuario+' '+ senhaSalva+' '+ prefixoNomeArq) >= 32 then
            esperaProgVoltar;
    while sintFalando do waitMessage;
end;

{--------------------------------------------------------}
begin
end.
