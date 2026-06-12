{--------------------------------------------------------}
{
{     Cria um texto com pedacos substituidos interativamente
{
{     Autor: Jose' Antonio Borges
{
{     Em 20/07/97
{
{--------------------------------------------------------}

program CARTEX;
uses dvwin, dvcrt, dvarq, sysUtils;
var
    nomearq, nomesai: string;
    arq, arqsai: text;
    texto: array [1..5000] of string;
    lin, col: integer;
    maxLin, iniTab: integer;
    lido: string;

{--------------------------------------------------------}

procedure cancela;
begin
    textBackground (RED);
    sintWriteln ('Programa cancelado');
    textBackground (BLACK);
    delay (20);
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}

procedure abreArquivos;
var c: char;
label abre;
begin
    if paramcount <> 0 then
        begin
            nomeArq := paramStr(1);
            goto abre;
        end;

    writeln;

    sintWrite ('Nome do arquivo de entrada: ');
    nomearq := obtemNomeArq (20);
    writeln (nomeArq);
    if nomearq = '' then
        cancela;

    abre:
    assign (arq, nomearq);
    {$I-} reset (arq); {$I+}
    if ioresult <> 0 then
        begin
            sintWriteln ('Arquivo não existe');
            cancela;
        end;

    sintWrite ('Nome do arquivo de saída: ');
    sintReadln (nomesai);
    assign (arqsai, nomesai);
    if nomeSai = '' then
        begin
            sintWriteln ('Arquivo não pode ser criado');
            cancela;
        end;

    if fileExists (nomesai) then
        begin
            sintWrite ('Confirma reescrita deste arquivo já existente? ');
            c := sintReadkey;
            writeln (c);
            if upcase(c) <> 'S' then cancela;
        end;

    {$I-} rewrite (arqsai); {$I+}
    if ioresult <> 0 then
        begin
            sintWriteln ('Arquivo não pode ser criado');
            cancela;
        end;

    lin := 0;
    col := 0;
    lido := '';
    maxlin := 0;
    iniTab := 9999;
end;

{--------------------------------------------------------}

procedure carregaTexto;
begin
    maxLin := 0;
    while not eof (arq) do
        begin
            maxLin := maxLin + 1;
            readln (arq, texto[maxLin]);
        end;

    close (arq);
end;

{--------------------------------------------------------}

function upper (s: string): string;
var s2: string;
    i: integer;
begin
    s2 := '';
    for i := 1 to length (s) do
        s2 := s2 + upcase (s[i]);
    upper := s2;
end;

{--------------------------------------------------------}

function codifData: string;
const
    nomeMes: array [1..12] of string[10] =
       ('janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
        'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro');

var
    d, m, a, s: word;
    s1, s2: string;
begin
    getDate (a, m, d, s);
    str (d, s1);
    str (a, s2);
    codifData := s1 + ' de ' + nomeMes[m] + ' de ' + s2;
end;

{--------------------------------------------------------}

procedure substitui;

    procedure substNome;
    var s, subst: string;
    begin
        delete (lido, 1, 1);
        s := '';
        while (lido <> '') and (lido[1] <> '}') do
            begin
               s := s + lido[1];
               delete (lido, 1, 1);
            end;

        if lido = '' then
            begin
                str (lin, s);
                sintWriteln ('Faltou fechar chave na linha ' + s);
                close (arqSai);
                cancela;
            end;

       delete (lido, 1, 1);

       if upper (s) = 'DATA' then
           subst := codifData
       else
           begin
               textBackground (RED);
               sintWrite (s + ':');
               textBackground (BLACK);
               sintReadln (subst);
           end;

       write (arqSai, subst);
    end;


begin
    while lido <> '' do
        begin
            if lido [1] = '{' then
                substNome
            else
                begin
                    write (arqSai, lido[1]);
                    delete (lido, 1, 1);
                end;
        end;

    writeln (arqSai);
end;

{--------------------------------------------------------}

var c: char;
begin
    sintinic (0, '');

    clrscr;
    textBackGround (BLUE);
    write ('Projeto DOSVOX - ');
    sintWriteln ('Preparador de cartas padronizadas');
    textBackGround (BLACK);
    writeln;

    abreArquivos;
    carregaTexto;

    lin := 1;

    while lin < maxLin do
       begin
           lido := texto [lin];
           if copy (lido, 1, 2) = '{*' then
               begin
                   delete (lido, 1, 2);
                   if lido [length(lido)] = '}' then
                       delete (lido, length(lido), 1);
                   if lido [length(lido)] = '*' then
                       delete (lido, length(lido), 1);

                   textBackGround (MAGENTA);
                   sintWriteln (lido);
                   textBackGround (BLACK);
                   writeln;
               end
           else
           if upper (lido) = '{INITAB}' then
               iniTab := lin
           else
           if upper (lido) = '{FIMTAB}' then
               begin
                   textBackGround (MAGENTA);
                   sintbip; sintbip;
                   sintWrite ('Tem mais ? ');
                   textBackGround (BLACK);
                   c := readkey;
                   writeln (c);
                   sintcarac (c);

                   if upcase(c) <> 'N' then lin := iniTab;
               end
           else
               substitui;

           lin := lin + 1;
       end;

    close (arqsai);

    sintBip;
    sintBip;
    writeln;
    sintWriteln ('Texto gerado');

    delay (20);
    sintFim;
    doneWinCrt;
end.
