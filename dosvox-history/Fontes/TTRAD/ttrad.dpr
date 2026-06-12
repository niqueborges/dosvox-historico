program ttrad;
uses dvcrt, dvwin, dvtradut, dvinter, windows, dvsapi;

var
    s, s2, fonemas: string;
    aFalar: string;

begin
    if paramcount <> 0 then
        begin
            screenSize.y := 3;
            clrScr;
            setWindowText (crtWindow, 'TTRAD');
            sintInic (0, '');
            aFalar := cmdline;
            if aFalar = '"' then
                begin
                    delete (aFalar, 1, 1);
                    while copy (aFalar, 1, 1) <> '"' do delete (aFalar, 1, 1);
                end;
            delete (aFalar, 1, pos(' ', aFalar));
            sintWrite(aFalar);
            sintFim;
            donewincrt;
        end;

    setWindowText (crtWindow, 'TTRAD');
    if tradinic <> 0 then
        begin
            writeln ('Erro de inicialização' );
            writeln ('verifique os arquivos \windows\dosvox.ini, difones*.dif e difones*.ind' );
            doneWincrt;
        end;
    tradFim;

    sintInic (0, '');
    writeln ('Teste do sintetizador do Dosvox');
    writeln ('Tecle fim para terminar');

    sintInic (0, '');
    s2 := '';

    repeat
        sintReadln (s);
        if s = '' then s := s2;
        s2 := s;
        if sapiPresente then
            sintWriteln (s)
        else
            begin
                compilaFonemas (s, fonemas);
                writeln (s, fonemas);
                falaFonemas (fonemas, true);
            end;
    until s = 'fim';

    while sintFalando do keypressed;

    sintFim;
    donewincrt;
end.
