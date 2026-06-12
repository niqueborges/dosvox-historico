var
    arq1, arq2: file of byte;
    c, d: byte;

begin
    assign (arq1, paramstr(1));
    if paramcount = 1 then
        assign (arq2, 'A:'+paramstr(1))
    else
        assign (arq2, paramstr(2));

    write ('Testando ', paramstr(1), ' -> ');
    {$i-} reset (arq1); {$i+}
    if ioresult <> 0 then
        begin
            writeln ('Nao existe arq1.');
        end;

    {$i-} reset (arq2); {$i+}
    if ioresult <> 0 then
        begin
            writeln ('Nao existe arq2.');
        end;

    while not eof (arq1) do
        begin
            if eof (arq2) then
                 begin
                     writeln('Diferentes');
                     halt;
                 end;

            read (arq1, c);
            read (arq2, d);
            if c <> d then
                 begin
                     writeln('Diferentes');
                     halt;
                 end;
        end;
    writeln ('Ok');
    close (arq1);
    close (arq2);
end.