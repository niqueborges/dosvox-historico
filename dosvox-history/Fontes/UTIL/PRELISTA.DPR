{-------------------------------------------------------------}
{
{     Preparador de lista de cartas a enviar
{
{     Autor: José Antonio Borges
{
{     Em 15 de maio de 1999
{
{-------------------------------------------------------------}

program preLista;
uses dvcrt, dvwin;
var
    nomeArqOrig, nomeArqDest, nomeArqLista: string;
    arqOrig, arqDest, arqLista: text;
    diretEnvio: string;
    nomeUsuario, enderUsuario: string;
    nomeDest: string;
    assunto: string;
    nbase, nger: integer;

{-------------------------------------------------------------}
{                     mensagens do programa
{-------------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;
begin
    if nomeArq = 'PCINIC' then
        s := 'Preparador de cartas para lista de pessoas'
    else
    if nomeArq = 'PCNOMARQ' then
        s := 'Nome do arquivo com a lista de pessoas'
    else
    if nomeArq = 'PCARQNAO' then
        s := 'Arquivo com a lista de pessoas não existe'
    else
    if nomeArq = 'PCNOMDST' then
        s := 'Nome do arquivo a distribuir'
    else
    if nomeArq = 'PCTXTNAO' then
        s := 'Arquivo de texto não existe'
    else
    if nomeArq = 'PCASSUNT' then
        s := 'Assunto'
    else
    if nomeArq = 'PCGERAND' then
        s := 'Gerando cartas'
    else
    if nomeArq = 'PCFALESP' then
        s := 'Faltou espaço no disco'
    else
    if nomeArq = 'PCCARGER' then
        s := 'Cartas geradas  '
    else
    if nomeArq = 'PCFIM' then
        s := 'Programa terminado'
    else
        s := '--> Mensagem invalida: ' + nomeArq;

    write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomeArq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{-------------------------------------------------------------}
{               gera um novo nome de arquivo .CPR
{-------------------------------------------------------------}

function novoNomeCarta: string;
var
    resulta: integer;
    s: string;
    arq: file;
    dirAtual: string;

begin
    getDir (0, dirAtual);
    {$I-}  chdir (diretEnvio);  {$I+}
    if ioresult <> 0 then
        begin
            novoNomeCarta := '';
            exit;
        end;
    chDir (dirAtual);

    if diretEnvio [length(diretEnvio)] = '\' then
           delete (diretEnvio, length(diretEnvio), 1);

    repeat
        nbase := nbase + 1;
        str (nbase, s);
        assign (arq, diretEnvio + '\' + s + '.CPR');

        {$I-} reset (arq);  {$I+}
        resulta := ioresult;
        {$I-} close (arq);  {$I+}
        if ioresult <> 0 then ;
    until resulta <> 0;

    novoNomeCarta := diretEnvio + '\' + s + '.CPR';
end;

{-------------------------------------------------------------}
{                prepara formato SMTP para envio
{-------------------------------------------------------------}

procedure geraTextoSMTP;
var
    s: string;
    Year, Month, Day, DayOfWeek: Word;
    Hour, Minute, Second, Sec100: Word;
    i1, i2: integer;
const
    tabMes: array [1..12] of string [3] = (
       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
label erro;

begin
    assign (arqOrig, nomeArqOrig);
    {$I-}  reset (arqOrig);  {$I+}
    if ioresult <> 0 then exit;   { teoricamente sempre vai existir }

    nomeArqDest := novoNomeCarta;

    assign (arqDest, nomeArqDest);
    {$I-}  rewrite (arqDest);  {$I+}
    if ioresult <> 0 then goto erro;

    i1 := pos ('<', enderUsuario);
    {$I-}
    if i1 <> 0 then
        begin
            i2 := pos ('>', enderUsuario);
            enderUsuario := copy (enderUsuario, i1, i2-i1+1);
            writeln (arqDest, 'MAIL FROM:', enderUsuario);
        end
    else
        writeln (arqDest, 'MAIL FROM:<', enderUsuario, '>');
    {$I+}
    if ioresult <> 0 then goto erro;

    i1 := pos ('<', nomeDest);
    if i1 <> 0 then
        begin
            i2 := pos ('>', nomeDest);
            nomeDest := copy (nomeDest, i1, i2-i1+1);
            writeln (arqDest, 'RCPT TO:', nomeDest)
        end
    else
        writeln (arqDest, 'RCPT TO:<', nomeDest, '>');

    {$I-} writeln (arqDest, 'DATA'); {$I+}
    if ioresult <> 0 then goto erro;

    getDate(Year, Month, Day, DayOfWeek);
    {$I-} write (arqDest, 'Date: ', Day, ' ', tabMes [Month], ' ', Year);  {$I+}
    if ioresult <> 0 then goto erro;

    getTime (Hour, Minute, Second, Sec100);
    {$I-} writeln (arqDest,  ' ', Hour, ':', Minute, ':', Second);  {$I+}
    if ioresult <> 0 then goto erro;

    {$I-}
    if nomeUsuario <> '' then
        writeln (arqDest, 'From: "', nomeUsuario, '" <', enderUsuario, '>')
    else
        writeln (arqDest, 'From: <', enderUsuario, '>');
    {$I+}
    if ioresult <> 0 then goto erro;

    {$I-} writeln (arqDest, 'To: ', nomeDest);  {$I+}
    if ioresult <> 0 then goto erro;

    {$I-} writeln (arqDest, 'Subject: ', assunto); {$I+}
    if ioresult <> 0 then goto erro;

    {$I-}  writeln (arqDest);
    while not eof (arqOrig) do
        begin
            readln (arqOrig, s);
            {$I-}  writeln (arqDest, s);  {$I+}
            if ioresult <> 0 then goto erro;
        end;

    close (arqOrig);
    if ioresult <> 0 then goto erro;

    {$I-}  writeln (arqDest, '.');  {$I+}
    if ioresult <> 0 then
        begin
            {$I-} close (arqDest);  {$I+}
            if ioresult <> 0 then;
            close (arqOrig);
            goto erro;
        end;

    close (arqDest);
    while keypressed do readkey;
    exit;

erro:
    mensagem ('PCFALESP', 1);  {'Faltou espaço no disco'}
    nomeArqOrig := '';   { impede enviar mais }
end;

{-------------------------------------------------------------}

procedure finaliza;
begin
    mensagem ('PCCARGER', 0);  {'Cartas geradas  '}
    sintWriteInt (nger);
    writeln;

    mensagem ('PCFIM', 1);     {'Programa terminado'}
    sintFim;
    doneWinCrt;
end;

{-------------------------------------------------------------}
{                        inicialização
{-------------------------------------------------------------}

procedure inicializa;
begin
    sintInic (0, sintambiente ('PRELISTA', 'DIRPRELISTA'));
    mensagem ('PCINIC', 2);      {'Preparador de cartas para lista de pessoas'}

    mensagem ('PCNOMARQ', 1);    {'Nome do arquivo com a lista de pessoas'}
    sintReadln (nomeArqLista);
    if nomeArqLista = '' then finaliza;

    assign (arqLista, nomeArqLista);
    {$I-}  reset (arqLista);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('PCARQNAO', 1);   {'Arquivo com a lista de pessoas não existe'}
            finaliza;
        end;

    mensagem ('PCNOMDST', 1);           {'Nome do arquivo a distribuir'}
    sintReadln (nomeArqOrig);
    if nomeArqOrig = '' then finaliza;

    assign (arqOrig, nomeArqOrig);
    {$I-}  reset (arqOrig);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('PCTXTNAO', 1);     {'Arquivo de texto não existe'}
            finaliza;
        end;
    close (arqOrig);

    mensagem ('PCASSUNT', 1);             {'Assunto'}
    sintReadln (assunto);

    nomeUsuario  := sintAmbiente ('CARTAVOX', 'NOMEUSUARIO');
    enderUsuario := sintAmbiente ('CARTAVOX', 'ENDERUSUARIO');
    diretEnvio   := sintAmbiente ('CARTAVOX', 'DIRENVIA');

    nbase := 0;
    nger := 0;
end;

{-------------------------------------------------------------}
{                     programa principal
{-------------------------------------------------------------}

begin
    inicializa;
    if nomeArqOrig <> '' then
         mensagem ('PCGERAND', 1);     {'Gerando cartas'}

    while (not eof (arqLista)) and (nomeArqOrig <> '') do
        begin
            readln (arqLista, nomeDest);
            if (nomeDest <> '') and (upcase(nomeDest[1]) in ['A'..'Z', '"']) then
                begin
                    geraTextoSmtp;
                    nger := nger + 1;
                end;
        end;
    finaliza;
end.
