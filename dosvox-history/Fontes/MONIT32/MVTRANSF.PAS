unit mvtransf;

interface
uses dvcrt, dvwin, dvmacro, dvExec, classes, windows, activex, oleacc, mvmsaa, mvVars;

procedure leAreaTransfEditor;

implementation

{--------------------------------------------------------}
{          joga a área de transferência no edivox
{--------------------------------------------------------}

procedure leAreaTransfEditor;
var arq: file;
    jan: HWND;
begin
    assign (arq, 'monitor.$$$');
    {$I-}  erase (arq);  {$I+}
    if ioresult <> 0 then;

    executaProg (sintAmbiente ('DOSVOX', 'EDITOR'), '', 'monitor.$$$');
    delay (5000);
    
    keyboardVirtKey (VK_INSERT, false, true, false, 10);
    keyboardVirtKey (VK_PRIOR, true, false, false, 10);
    keyboardVirtKey (VK_F9, false, false, false, 10);
    keyboardChar ('f', 10);
    keyboardChar ('t', 10);

    monitorando := true;
    jan := getForegroundWindow;
    while monitorando do
        begin
            delay (500);
            if jan <> getForegroundWindow then monitorando := false;
        end;
end;

end.
