Unit cdScript;

interface

uses dvCrt, dvWin,
    dvScript,
    dvArq, dvForm,
    cdUtil, cdVars, cdMsg,
    winProcs, winTypes, sysUtils, mmSystem;

procedure executaCMD;

implementation

var
    retornoMci: array [0..255] of char;
    erroMci: longint;
    resulta: RESULTADO_SCRIPT;
    ultimaLinha: integer;

{---------------------------------------------------------------------}

procedure erroScript (n: RESULTADO_SCRIPT; rotulo: string);
begin
    case n of
        SCR_ERROEXEC:       sintWriteln ('Erro de execução do script');
        SCR_SEMARQUIVO:     sintWriteln ('Script não foi achado');
        SCR_ROTULOINVALIDO: begin
                                sintWriteln ('Rótulo não foi achado dentro do script');
                                sintWriteln (rotulo);
                            end;
    end;
    if n <> SCR_OK then
        exit;
end;

{--------------------------------------------------------}

procedure sendString (s: string);
var p: array [0..255] of char;
begin
    strPcopy (p, s);
    erroMci := mciSendString (p, retornoMci, 255, 0);
    writeln (p, '->',retornoMci);
end;

{--------------------------------------------------------}

procedure executaCMD;
var nomeScript: string;
    linhaFonte: string;
label retorna, termina;
begin

    if not trocaDir(dirScript) then
        goto retorna;

    mensagem ('CDSELSCR', 1); {'Selecione o script com as setas')}
    garanteEspacoTela (11);
    nomeScript:= obtemNomeArqMasc (10, '*.CMD');
    writeln (nomeScript);
    if nomeScript = '' then
    begin
        mensagem ('CDNAOSCR', 1); {'Não foi possível selecionar nenhum script')}
        goto retorna;
    end;

//    nomeScript:= '"' + nomeScript + '"';

    resulta := executaScript (nomeScript, 'inicia', ultimaLinha, linhaFonte);
    if resulta <> SCR_OK then
        erroScript (resulta, 'inicia');

    retorna:
    if not trocaDir(dirTexto) then
        goto termina
    else
        exit;

termina:
    mensagem ('CDPRODIS', 1); {'Problema no disco, o programa será fechado')}
    sintFim;
    doneWinCrt;

end;

end.
