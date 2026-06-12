{--------------------------------------------------------}
{
{    Converte acentos do DOSVOX para o EDIT e vice-versa
{    Autor: Jose' Antonio Borges
{    Em 15/5/95
{
{--------------------------------------------------------}

program dvtxt;
uses dvWin, dvCrt, dvArq, dvForm, windows;
var
    arq, arqsai: file;
    nomearq, nomesai: string;
    texto: array [0..4096] of char;
    opcao, lixo: char;
    i, lidos: integer;

label fim;

{--------------------------------------------------------}

begin
    sintInic (0, sintAmbiente ('DVTXT', 'DIRDVTXT'));

    writeln ('Conversor de acentos');
    sintSom ('TXINIC');

    writeln;
    delay (500);
    writeln ('Nome do arquivo original: ');
    sintSom ('TXNOMORG');

    garanteEspacoTela(21);
    nomearq := obtemNomeArq (21);
    writeln (nomeArq);
    if nomearq = '' then goto fim;

    assign (arq, nomearq);
    {$i-} reset (arq, 1); {$i+}
    if ioresult <> 0 then
        begin
            writeln ('Arquivo nao existe');
            sintSom ('TXARQNAO');
            goto fim;
        end;

    writeln ('Nome do arquivo destino: ');
    sintSom ('TXNOMDST');
    sintReadln (nomesai);
    if nomesai = '' then goto fim;

    assign (arqsai, nomesai);
    {$i-} rewrite (arqsai, 1); {$i+}
    if ioresult <> 0 then
        begin
            writeln ('Erro de escrita');
            sintSom ('TXERRESC');
            goto fim;
        end;

    repeat
        writeln
             ('Escolha  I para saida em formato IBM  A para ANSI  ESC para cancelar');
        sintSom ('TXOPCAO');

        sintleTecla (opcao, lixo);
        writeln;
        opcao := upcase (opcao);
        if opcao = #$1b then goto fim;
    until opcao in ['I', 'A'];

    while not eof (arq) do
        begin
            blockRead (arq, texto, 4096, lidos);

            if opcao = 'I'then
                AnsiToOemBuff (@texto, @texto, lidos)
            else
                begin
                    OemToAnsiBuff (@texto, @texto, lidos);
                    for i := 0 to 4095 do
                        if texto[i] = 'ä' then
                            texto[i] := 'ã'
                        else
                            if texto[i] = 'ö' then texto[i] := 'õ';
                end;

            {$I-} blockWrite (arqsai, texto, lidos); {$I+}
            if ioresult <> 0 then
                begin
                    writeln ('Erro de escrita');
                    sintSom ('TXERRESC');
                    goto fim;
                end;
        end;

    writeln ('Arquivo gerado');
    sintSom ('TXARQGER');

fim:
    {$I-} close (arqsai); {$I+}  if ioresult <> 0 then;
    {$I-} close (arq);    {$I+}  if ioresult <> 0 then;

    writeln ('Fim do conversor');
    sintSom ('TXFIM');
    sintFim;
    delay (2000);
    doneWinCrt;
end.
