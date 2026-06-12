program tgramost;

uses
  dvcrt, dvwin, dvwav, gramost;

var
    som, som2, som3, som4: TAmostras;
    a, b: TStereo16;
    i, n, dist: integer;
    inicio, fim: integer;
    c: char;
    x: real;
begin
sintInic (0, '');
sintWriteln ('Demonstrativo da classe de gravação de amostras');
sintWriteln ('Aperte enter após cada anúncio');

sintWriteln ('vou tocar som 1');  readln;
    som := TAmostras.Create;
    if not som.leArquivo ('c:\tgramost\blimblim.wav') then
        begin
            sintWriteln ('arquivo inexistente');
            readln;
            doneWinCrt;
        end;
    som.tocaTudo;

sintWriteln ('vou tocar som 2');  readln;
    som2 := TAmostras.Create;
    if not som2.leArquivo ('c:\winvox\som\dosvox\dvnce.wav') then
        begin
            sintWriteln ('arquivo inexistente');
            readln;
            doneWinCrt;
        end;
    som2.tocaTudo;

sintWriteln ('vou aumentar tonalidade');  readln;
    som3 := TAmostras.Create;
    som3.clone (som2);
    som3.zera;

    i := 0;
    x := 0;
    while x < som2.numAmostras-1 do
        begin
            som3.amostra[i] := som2.amostra[trunc(x)];
            i := i + 1;
            x := x + i * 0.00002;
        end;
    som3.tocaTudo;
    som3.free;

sintWriteln ('vou diminuir volume');    readln;
    som3 := TAmostras.Create;
    som3.clone (som2);
    with som3 do
        begin
            for i := 0 to numAmostras-1 do
                begin
                     a := amostra[i];
                     a.left := a.left div 5;
                     a.right := a.right div 5;
                     amostra[i] := a;
                end;
            tocaTudo;
        end;
    som3.Free;

sintWriteln ('vou aumentar volume de uma parte');    readln;
                        // implementar com rampa é mais fácil
    som3 := TAmostras.Create;
    som3.clone (som2);
    inicio := som3.numAmostras-30000;
    fim := som3.numAmostras-1;
    som3.rampa(inicio, fim, 2.0, 2.0);
    som3.tocaTudo;
    som3.Free;

sintWriteln ('vou fazer fade in');  readln;
    som3 := TAmostras.Create;
    som3.clone (som2);
    inicio := 0;
    fim := som3.numAmostras-1;
    som3.rampa (inicio, fim, 0.0, 1.0);
    som3.tocaTudo;
    som3.free;

sintWriteln ('vou fazer fade out');  readln;
    som3 := TAmostras.Create;
    som3.clone (som2);
    inicio := 0;
    fim := som3.numAmostras-1;
    som3.rampa (inicio, fim, 1.0, 0.0);
    som3.tocaTudo;
    som3.free;

sintWriteln ('vou ecoar');   readln;
    som3 := TAmostras.Create;
    som3.Clone(som2);
    som3.zera;
    with som3 do
        begin
            n := som2.numAmostras-1;
            dist := 6000;
            amostra [numAmostras+dist] := SILENCIO;   // precria area de silencio no fim
            for i := 0 to n do
                begin
                     a := som2.amostra[i];
                     b := som2.amostra [i-dist];
                     a.left  := trunc(a.left*0.8) + trunc(b.left  * 0.2);
                     a.right := trunc(a.right*0.8) + trunc(b.right * 0.2);
                     amostra[i] := a;
                end;
            tocaTudo;
        end;
    som3.Free;

sintWriteln ('vou reverberar');     readln;
    som3 := TAmostras.Create;
    som3.clone (som2);
    with som3 do
        begin
            dist := 6000;
            amostra [numAmostras+dist] := SILENCIO;   // precria area de silencio no fim
            n := numAmostras-1;
            for i := dist to n+(dist*2) do   // deixa reverberar um pouco mais
                begin
                     a := amostra[i];
                     b := amostra [i-dist];
                     a.left  := trunc(a.left*0.6) + trunc(b.left  * 0.4);
                     a.right := trunc(a.right*0.6) + trunc(b.right * 0.4);
                     amostra[i] := a;
                end;
            tocaTudo;
        end;
    som3.Free;

sintWriteln ('vou trocar velocidade de exibição para 8000, 11025 e 44100'); readln;
    som2.velocidade := 8000;
    som2.tocaTudo;
    som2.velocidade := 11025;
    som2.tocaTudo;
    som2.velocidade := 44100;
    som2.tocaTudo;
    som2.velocidade := 22050;

sintWriteln ('vou trocar velocidade de amostragem'); readln;
    som3 := TAmostras.Create;
    som3.reamostra(som2, 8000);
    som3.tocaTudo;
    som3.reamostra(som2, 11025);
    som3.tocaTudo;
    som3.reamostra(som2, 44100);
    som3.tocaTudo;

sintWriteln ('vou gravar arquivo cópia \bli.wav');  readln;
    som3.gravaArquivo ('\bli.wav');
    som3.free;

sintWriteln ('vou misturar');    readln;
    som3 := TAmostras.Create;
    som3.Clone(som2);
    som3.mistura(som, 2000, 1.0, 0.50);
    som3.tocaTudo;
    som3.free;

sintWriteln ('vou adicionar ao final');   readln;
    som3 := TAmostras.Create;
    som3.Clone(som2);
    som3.adiciona(som);
    som3.tocaTudo;
    som3.free;

sintWriteln ('vou chipmunkizar');    readln;
    som3 := TAmostras.Create;
    som3.clone (som);
    with som3 do
        begin
            for i := 0 to (numAmostras div 2) - 1 do
                amostra[i] := amostra[i*2];
            removeTrecho(numAmostras div 2, 99999999);
            tocaTudo;
        end;
    som3.Free;

sintWriteln ('vou reverter');    readln;
    som3 := TAmostras.Create;
    som3.clone (som);
    with som3 do
        begin
            for i := 0 to (numAmostras-1) div 2 do
                begin
                     a := amostra[i];
                     amostra[i] := amostra[numAmostras-1-i];
                     amostra[numAmostras-1-i] := a;
                end;
            tocaTudo;
        end;
    som3.Free;

sintWriteln ('vou pipocar');  readln;
    som3 := TAmostras.Create;
    som3.clone (som);
    som3.zera;

    som4 := TAmostras.Create;
    som4.clone (som);
    som4.removeTrecho(0, 10000);
    som4.removeTrecho(5000, 9999999);

    for i := 1 to 10 do
        som3.adiciona(som4);

    som3.tocaTudo;
    som4.Free;
    som3.free;

sintWriteln ('Use mais e menos para passear escutando as amostras, esc termina');
    c := ' ';
    i := -1;
    keyStopsWave := false;   // para teclado não interromper tocagem
    while c <> #$1b do
        begin
             c := readkey;
             case c of
                 '+':  i := i + 1;
                 '-':  i := i - 1;
             end;
             while keypressed do readkey;
             if i < 0 then i := 0;
             if i > som.numAmostras div 2000 then
                 i := som.numAmostras div 2000;

             som.toca(i*2000, 2000);
             write (i*2000, '    ',#$0d);
        end;
    keyStopsWave := true;
    writeln;

    som.Free;
    som2.Free;

sintWriteln ('Fim');
    sintfim;
    doneWinCrt;
end.
