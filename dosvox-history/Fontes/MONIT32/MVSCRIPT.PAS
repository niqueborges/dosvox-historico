unit mvscript;

interface
uses dvcrt, dvwin, dvmacro, dvExec, classes, windows, activex, oleacc,
     mvMonit, mvmsaa, mvVars, mvMsg;

procedure iniciaScriptVox;

implementation

{--------------------------------------------------------}
{                 inicia um script
{--------------------------------------------------------}

procedure iniciaScriptVox;
var nomeScript: string;
    c: char;
begin
    mensagem ('MOSCRIPT', 0);   {'Nome do script: '}
    sintReadln (nomeScript);
    mensagem ('MOMOEXEC', 0);   {'Monitora enquando executa? '}
    c := sintReadkey;
    writeln (c);

    showWindow (crtWindow, SW_HIDE);
    executaProg (sintAmbiente ('DOSVOX', 'PROG.CMD'), '', nomeScript);

    if upcase(c) = 'N' then
        begin
            monitorando := true;
            while monitorando do delay (500);
        end
    else
        monitora;
end;

end.
