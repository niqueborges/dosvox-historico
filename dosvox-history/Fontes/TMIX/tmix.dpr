{---------------------------------------------------------------------}
{    Projeto DOSVOX - NCE/UFRJ
{    Interface simplificada para controle de volume
{    Autor: José Antonio Borges
{    Em 11/05/2008
{    Versão Windows Vista/7 em 07/06/2011
{---------------------------------------------------------------------}

program tmix;

uses dvcrt, dvwin, windows, sysutils, mixer, mmsystem;

var
    a_mixer: TMixer;
    volume: integer;
    dir: string;

{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'MXINIC' then
        s := 'Programa de Ajuste de Volume'
    else
    if nomeArq = 'MXVOLATU' then
        s := 'Volume atual: '
    else
    if nomeArq = 'MXNOVO' then
        s := 'Novo valor entre 10 e 100: '
    else
    if nomeArq = 'MXVOLBAI' then
        s := 'Volume muito baixo, não deixo.'
    else
    if nomeArq = 'MXOK' then
        s := 'OK'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}

begin
    screensize.y := 6;
    screensize.x := 40;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('MXINIC'));
    writeln;
    textBackground (BLACK);
    setWindowTitle ('TMIX - volume');

    dir := sintAmbiente ('TMIX', 'DIRTMIX');
    if dir = '' then
        dir := 'c:\winvox\som\tmix';
    sintInic (0, dir);

    a_mixer := g_mixer;

    mensagem ('MXVOLATU', 0);   {'Volume atual: '}
    sintWriteln (intToStr(a_mixer.volume * 100 div 65535));

    mensagem ('MXNOVO', 0);     {'Novo valor entre 10 e 100: '}
    sintReadint (volume);

    if volume < 10 then
        mensagem ('MXVOLBAI', 1);  {'Volume muito baixo, não deixo.'}
    if (volume < 10) or (volume > 100) then
        volume := 80;

    a_mixer.volume := volume * 65535 div 100 + 1;

    mensagem ('MXOK', 0);     {'OK'}
    sintFim;
    doneWinCrt;
end.

