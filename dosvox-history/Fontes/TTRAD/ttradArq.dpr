program ttradArq;
uses dvcrt, dvwin, dvtradut, dvinter, windows, dvsapi;

var
    nomeArq, nomeArqSai: string;
    aFalar: string;
    arq: textFile;

begin
    screenSize.y := 5;
    clrScr;
    setWindowText (crtWindow, 'TTRAD');

    if paramcount = 0 then
        begin
            writeln ('Nome do arquivo a falar');
            readln (nomeArq);
            writeln ('Nome do arquivo a produzir');
            readln (nomeArqSai);
        end
    else
    if paramcount <> 2 then
        begin
            writeln ('uso: ttradarq arq.txt arq.wav');
            doneWinCrt;
        end
    else
        begin
            nomeArq := paramStr(1);
            nomeArqSai := paramStr(2);
        end;

    sintNomeArq := nomeArqSai;
    sintInic (0, '');

    assign (arq, nomeArq);
    reset (arq);
    sintAcumulaFala := true;
    while not eof (arq) do
        begin
            readln (arq, aFalar);
            sintetiza (aFalar);
        end;
    closeFile (arq);
    sintetiza ('');
    sintAcumulaFala := false;

    while sintFalando do keypressed;
    sintFim;
    donewincrt;
end.
