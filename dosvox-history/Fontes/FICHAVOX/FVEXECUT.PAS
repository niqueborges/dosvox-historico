unit fvExecut;
interface
uses windows, dvcrt, dvwin, sysUtils, dvlenum,
    fvMsg, fvProc, fvVars, fvEdita;

    procedure executaArquivo;

implementation

{--------------------------------------------------------}

    procedure executaArquivo;
    var extensao: string[3];
        nomeProg, nomearq, nomeDir: string;
        p: integer;
    begin
        nomearq := fichario[posAtual]^.nomeArq;

        getdir (0, nomeDir);

        p := pos ('.', nomeArq);
        if p <> 0 then
            extensao := copy (nomeArq, p+1, 3)
        else
            extensao := '';

        if ((extensao = '') or (extensao = 'txt') or (extensao = 'TXT'))then
            editarArquivo (nomeArq)
        else
            begin
                if (extensao = 'EXE') or (extensao = 'COM') then
                    begin
                        if nomeDir [length (nomeDir)] = '\' then
                            nomeProg := nomedir + nomeArq
                        else
                            nomeProg := nomedir + '\' + nomeArq;
                        nomeArq := '';
                    end
                else
                    begin
                        nomeProg := sintAmbiente ('DOSVOX', 'PROG.' + extensao);
                        if nomeProg = '' then
                            begin
                                nomeProg := nomeArq;
                                nomeArq := '';
                            end;
                end;

                while sintFalando do;
                if executaProg (nomeProg, nomeDir, nomeArq, SW_SHOWNORMAL) then
                    esperaProgVoltar;
                while sintFalando do;
                while keypressed do readkey;
                sintBip;
            end;
    end;

{--------------------------------------------------------}

end.
