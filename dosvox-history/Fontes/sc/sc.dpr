{------------------------------------------------------------------------------}
{
{                                  SC.DPR
{
{    ScriptVox - Interpretador de Scripts do Sistema DosVox
{                Versão 6
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Adendos:    Antonio Borges e Patrick Barbosa
{    Data:       28/09/2015
{    Alterações: 30/03/2016, 01/07/2016, 14/05/2024
{
{------------------------------------------------------------------------------}

program scriptvox;

uses
    screen, dvscript,
    dvwin, dvcrt, dvarq, dvform, dvmsaa, dvdigitexto,
    windows, classes, sysUtils, activeX;

const
    SCRIPTVOX_VERSION    = dvscript.SCRIPTVOX_VERSION;
    SCRIPTVOX_SUBVERSION = dvscript.SCRIPTVOX_SUBVERSION;

type
    Msg = (SCINIC, SCNOMPRO, SCFIM, SCARQNAO, SCERREXE, SCERRROT,
           SCRERROSINT, SCERRO, SCEDITE, SCINTER);

var
    scriptPath, beginAtLabel : string;
    interactiveMode          : boolean;

{--------------------------------------------------------}
{                 fala uma mensagem
{--------------------------------------------------------}

procedure recordedMessage (m : Msg; skip : integer);
type
    MsgRec = record
        fileName : string;
        msg      : string
    end;
const
    table : array[Msg] of MsgRec =
    (
        ( fileName: 'SCINIC';      msg: 'ScriptVox - v'                       ),
        ( fileName: 'SCNOMPRO';    msg: 'Nome do arquivo .PRO a executar: '   ),
        ( fileName: 'SCFIM';       msg: 'Fim do script'                       ),
        ( fileName: 'SCARQNAO';    msg: 'Arquivo .PRO inexistente'            ),
        ( fileName: 'SCERREXE';    msg: 'Erro de execução na linha '          ),
        ( fileName: 'SCERRROT';    msg: 'Este rótulo não existe'              ),
        ( fileName: 'SCRERROSINT'; msg: 'Script com erro sintático na linha ' ),
        ( fileName: 'SCERRO';      msg: 'Erro'                                ),
        ( fileName: 'SCEDITE';     msg: 'Editore e aperte enter'              ),
        ( fileName: 'SCINTER';     msg: 'Modo interativo'                     )
    );
var
    i : integer;
begin
    with table[m] do
    begin
        write (msg); scLog (msg);

        for i := 1 to skip do scWriteln;

        if existeArqSom (fileName) then
            sintsom (fileName)
        else
            sintetiza (msg)
    end
end;

{--------------------------------------------------------}
{                    inicialização
{--------------------------------------------------------}

function initialized : boolean;
label
    again;
var
    s, currDir : string;
    p          : integer;
begin
    initialized := true;

    sintInic (0, sintAmbiente ('SCRIPVOX', 'DIRSCRIPVOX'));
    clrscr;
    setWindowText (crtWindow, 'SCRIPVOX');

    if paramCount <> 0 then
    begin
        scriptPath := paramStr (1)
    end
    else begin
        textBackground (BLUE);
        recordedMessage (SCINIC, 0);

        scWrite (SCRIPTVOX_VERSION);

        if SCRIPTVOX_SUBVERSION <> '' then
            scWrite (' (' + SCRIPTVOX_SUBVERSION + ')');

        scWriteln;

        textBackground (BLACK);
        scWriteln;

        getDir (0, currDir);
{$I-}
        ChDir (currDir);
{$I+}
        if ioresult <> 0 then ;

        recordedMessage (SCNOMPRO, 0);

        scriptPath := trim (obtemNomeArqMasc (20, '*.pro'));
        scWriteln (scriptPath);

        if teclaObtemNomeArq = ESC then
        begin
            sintFim;
            doneWinCrt
        end;
    end;

    interactiveMode := false;
    if scriptPath = '' then
    begin
        s := 'SCRIPTVOX (interativo)';
        setWindowText (crtWindow, @s[1]);
        interactiveMode := true;
        exit
    end;

    beginAtLabel := '';
    p := pos ('@', scriptPath);

    if p <> 0 then
    begin
        beginAtLabel := trim (copy (scriptPath, p + 1, 999));
        delete (scriptPath, p, 999);
        scriptPath := trim (scriptPath)
    end;

    s := 'SCRIPTVOX ' + scriptPath;
    setWindowText (crtWindow, @s[1]);

again:
    if fileExists (scriptPath) then exit;

    if pos ('.', scriptPath) = 0 then
    begin
        if fileExists (scriptPath + '.PRO') then
        begin
            scriptPath := scriptPath + '.PRO';
            exit
        end
    end;

    if pos ('\', scriptPath) = 0 then
    begin
        s := sintAmbiente ('SCRIPVOX', 'DIRDEFAULT');

        if s <> '' then
        begin
            if s [length(s)] <> '\' then
                s := s + '\';

            scriptPath := s + scriptPath;
            goto again
        end
    end;

    recordedMessage (SCARQNAO, 1);
    initialized := false
end;

{--------------------------------------------------------}
{               processamento interativo
{--------------------------------------------------------}

procedure interact;
label
    coda, again;
var
    c           : char;
    i           : integer;
    quiet       : boolean;
    cmdList,
    script      : TStringList;
    line        : string;
    numlastLine : integer;
    lastLine    : string;
    ret         : RESULTADO_SCRIPT;

    {----------------------------------------------------}
    {             verifica se deve encerrar              }
    {----------------------------------------------------}

    function terminate : boolean;
    var
        c : char;
    begin
	    if script.Count > 0 then
	        scWriteln ('Você editou um script de ' + IntToStr (script.Count) + ' linhas.');

        scWrite ('Deseja realmente encerrar o ScriptVox? ');
    	c := readKey; scWriteln (c);
	    terminate := MaiuscAnsi (c) = 'S'
    end;

begin
    recordedMessage (SCINTER, 2);

    scWriteln ('Digite AJUDA para conhecer os comandos e funções');
    scWriteln;

    script   := TStringList.Create;
    cmdList  := TStringList.create;
    quiet    := true;

    repeat
again:
        line := '';

        repeat
            c := sintEdita (line, wherex, wherey, 255, true); writeln; { Atenção: é só writeln mesmo, não é scWriteln! }

            case c of
                ESC:         if terminate then goto coda;
                F5:          toggleScreenSave;
                F9:          begin
                                 garanteEspacoTela (20);
                                 popupDigiTexto (script, false, true, 1, wherey, 80, 16, true);
                                 goto again
                             end;
                CTLF9:       begin
                                 ret := dvscript.executaScriptList (script, '', numlastLine, lastLine);

                                 if ret = SCR_OK then
                                     scWriteln ('Ok')
                                 else begin
                                     if numlastLine > 0 then
                                         scWriteln ('Erro na linha ' + intToStr (numlastLine));
                                     scWriteln (lastLine);
                                 end;
                                 goto again
                             end;
                CIMA, BAIX:  if cmdList.Count > 0 then
                             begin
                                 garanteEspacoTela (5);
                                 popupMenuCria (wherex, wherey, 80, cmdList.Count, RED);

                                 for i := cmdList.Count - 1 downto 0 do
                                     popupMenuAdiciona ('', cmdList[i]);

                                 if popupMenuSeleciona >= 1 then
                                 begin
                                     line := opcoesItemSelecionado;
                                     recordedMessage (SCEDITE, 1)
                                 end
                              end
            end
        until c = ENTER;

        if line <> '' then
        begin
            i := cmdList.indexOf (line);

            if i >= 0 then
                cmdList.Delete (i);

            cmdList.Add (line)
        end;

        scLogLn (line);

        if not dvscript.executaLinha (line) then
            recordedMessage (SCERRO, 1);

        if dvscript.terminouScript (quiet) then
            break;

        line := ''
    until false;

coda:
    if not quiet then
        recordedMessage (SCFIM, 1)
end;

{--------------------------------------------------------}
{          processa um script dado em arquivo
{--------------------------------------------------------}

procedure script;
var
    numLastLine : integer;
    lastLine    : string;
begin
    case dvscript.executaScript (scriptPath, beginAtLabel, numLastLine, lastLine) of
        SCR_OK:                 ;
        SCR_ERROEXEC:           begin
                                    showWindow (crtWindow, SW_RESTORE);
                                    gotoxy (1, 23);
                                    clreol; scWriteln; clreol; scWriteln; clreol;

                                    gotoxy (1, 23);
                                    textColor (YELLOW);
                                    sintbip; sintbip; sintbip;
                                    recordedMessage (SCERREXE, 0);   {'Erro de execução na linha '}
                                    sintWrite (intToStr (numLastLine));
                                    scWriteln;
                                    clreol;
                                    sintEdita (lastLine, wherex, wherey, 80, false);
                                    scWrite (intToStr (numLastLine));
                                    clreol;
                                    textColor (WHITE);
                                    readln;
                                end;
        SCR_SEMARQUIVO:         recordedMessage (SCARQNAO, 1);   {'Arquivo inexistente'}
        SCR_ROTULOINVALIDO:     recordedMessage (SCERRROT, 1);   {'Este rótulo não existe !'}
        SCR_ERROSINTAXE:        begin
                                    recordedMessage (SCRERROSINT, 0);
                                    scWrite (intToStr (numLastLine));
                                    scWriteln;
                                    readln
                                end
    end
end;

{--------------------------------------------------------}
{                      finalização
{--------------------------------------------------------}

procedure finish;
begin
    sintFim;
    doneWinCrt
end;

{--------------------------------------------------------}
{     Programa Principal do Interpretador ScriptVox
{--------------------------------------------------------}

begin
    if initialized then
    begin
        if interactiveMode then
            interact
        else
            script
    end
    else begin
        delay (1000)
    end;

    finish
end.

