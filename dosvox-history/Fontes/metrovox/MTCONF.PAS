unit mtConf;

interface

uses dvwin, dvcrt,
    windows, shellApi, sysUtils, winSock,
    mtVars, mtMsg;

procedure pegaConf;
procedure gravaConf;

implementation

{--------------------------------------------------------}
{Pega configuração no DOSVOX.INI
{--------------------------------------------------------}

procedure pegaConf;
begin

    bpmStr:= sintAmbiente ('METROVOX', 'BPM');
    compassoStr:= sintAmbiente ('METROVOX', 'COMPASSO');
    somTempo:= sintAmbiente ('METROVOX', 'SOMTEMPO');
    somCompasso:= sintAmbiente ('METROVOX', 'SOMCOMPASSO');

end;

{--------------------------------------------------------}
{Grava configuração no DOSVOX.INI
{--------------------------------------------------------}

procedure gravaConf;
var opcao: char;
    gravaTempo, gravaCompasso: string;
begin

    writeln;
    mensagem ('MTASSPAD', 0); {'Deseja assumir esse modelo como padrão ? '}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) <> 'S' then
    begin
        mensagem ('MTDESIST', 1); {'Desistiu'}
        exit;
    end;

    str (bpm, bpmStr);
    str (compasso, compassoStr);

    if compassoStr = '2' then
        compassoStr:= 'Binário'
    else
    if compassoStr = '3' then
        compassoStr:= 'Ternário'
    else
    if compassoStr = '4' then
        compassoStr:= 'Quaternário'
    else
        compassoStr:= 'Quaternário';

    gravaTempo:= somTempo;
    gravaCompasso:= somCompasso;

    while (pos ('\', gravaTempo) <> 0) do
        delete (gravaTempo, 1, pos ('\', gravaTempo));
    delete (gravaTempo, length (gravatempo) -3, 4);

    while (pos ('\', gravaCompasso) <> 0) do
        delete (gravaCompasso, 1, pos ('\', gravaCompasso));
    delete (gravaCompasso, length (gravaCompasso) -3, 4);

    sintGravaAmbiente ('METROVOX', 'BPM', bpmStr);
    sintGravaAmbiente ('METROVOX', 'COMPASSO', compassoStr);
    sintGravaAmbiente ('METROVOX', 'SOMTEMPO',  gravaTempo);
    sintGravaAmbiente ('METROVOX', 'SOMCOMPASSO',  gravaCompasso);

    mensagem ('MODPAD', 1); {'OK, assumido'}

end;

end.
