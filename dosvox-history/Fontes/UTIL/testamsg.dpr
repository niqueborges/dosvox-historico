program testamsg;
uses dvcrt, dvwin, sysutils, classes;

var nomePas, variavel, dirmsg: string;
    linha, linhaSalva: string;
    arq, arqFalta: textfile;
    p: integer;
    quantas: integer;

begin
    sintInic (0, '');
    sintWriteln ('Verificador de mensagens faltando em programas do Dosvox');
    writeln;
    sintwriteln ('Informe o nome completo do arquivo .PAS com mensagens');
    sintreadln (nomePas);
    if not fileExists (nomePas) then
        begin
            sintWriteln ('Arquivo não existe.  Programa cancelado.  Tecle enter.');
            readln;
            doneWinCrt;
        end;

    sintWriteln ('Informe a variável utilizada no teste de código');
    sintReadln (variavel);
    sintWriteln ('Informe o diretório de mensagens');
    sintReadln (dirmsg);
    if not DirectoryExists (dirmsg) then
        begin
            sintWriteln ('Diretório não existe.  Programa cancelado.  Tecle enter.');
            readln;
            doneWinCrt;
        end;
    quantas := 0;

    assignFile (arq, nomePas);
    reset (arq);
    assignFile (arqFalta, dirMsg+'\_faltam.txt');
    rewrite (arqFalta);
    writeln (arqFalta, '!22050');

    while not eof (arq) do
        begin
            readln (arq, linha);
            linha := trim (linha);
            if copy (uppercase (linha), 1, 3) = 'IF ' then
                delete (linha, 1, 3)
            else
            if copy (uppercase (linha), 1, 8) = 'ELSE IF ' then
                delete (linha, 1, 8)
            else
                continue;

            linha := trim (linha);
            linhaSalva := linha;

            if upperCase(copy (linha, 1, length(variavel))) <> upperCase(variavel) then
                continue;
            while (linha <> '') and (linha[1] <> '''') do
                delete (linha, 1, 1);
            delete (linha, 1, 1);
            linha := copy (linha, 1, pos ('''', linha)-1);

            clreol; write (linha, #$0d);

            if not fileExists (dirmsg + '\' + linha + '.wav') then
                 begin
                     write (linha + '    ');
                     write (arqFalta, linha + '    ');
                     p := pos (':=', linhaSalva);
                     if p = 0 then
                         begin
                             readln (arq, linhaSalva);
                             p := pos (':=', linhaSalva);
                         end;
                     if p <> 0 then
                         begin
                             delete (linhaSalva, 1, p+1);
                             linhaSalva := trim (linhaSalva);
                             write (linhaSalva);
                             write (arqFalta, linhaSalva);
                         end;
                     writeln;
                     writeln (arqFalta);
                     quantas := quantas + 1;
                 end;

        end;

    clreol;

    closefile (arq);
    closefile (arqFalta);
    sintWriteln ('Mensagens faltando: ' + intTostr(quantas));

    readln;
    donewincrt;
end.
