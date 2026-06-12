program geradon;
uses dvwin, dvcrt, windows, sysUtils;

var
    arq, arqsai: text;
    nomeArq, nomeArqSai: string;
    s: string;
    i: integer;
label fim;
begin
    sintInic (0, '');

    sintwriteln ('Conversor de arquivos para formato DON');
    if paramCount <> 0 then
        begin
            nomeArq := paramStr(1);
            nomeArqSai := paramStr(2);
        end
    else
        begin
            sintWriteln ('Qual o arquivo a converter?');
            sintReadln (nomeArq);
            sintWriteln ('Qual o arquivo de saída? (padrão: \winvox\dosvox.don) ');
            sintReadln (nomeArqSai);
        end;

    if nomeArqSai = '' then
        nomeArqSai := '\winvox\dosvox.don';

    if nomeArq = nomeArqSai then
        begin
            sintWriteln ('Nomes tem que ser diferentes');
            goto fim;
        end;

    assignFile (arq, nomeArq);
    {$I-} reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            sintWriteln ('Arquivo inexistente');
            goto fim;
        end;

    assignFile (arqsai, nomeArqSai);
    rewrite (arqsai);

    while not eof (arq) do
        begin
            readln (arq, s);
//            sintWriteln (s);
            if s = '' then s := ' ';
            AnsiToOem (@s[1], @s[1]);
            for i := 1 to length (s) do
                s[i] := chr (ord (s[i]) xor ((i+10) mod 20));
            writeln (arqSai, s);
        end;

    closeFile (arq);
    closeFile (arqsai);
    sintWriteln ('Ok, convertido');
fim:
    sintFim;
    doneWincrt;
end.
