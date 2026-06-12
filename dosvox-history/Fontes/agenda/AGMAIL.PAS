{--------------------------------------------------------}
{                  AGENVOX - geração de e-mail automático
{--------------------------------------------------------}

unit agMail;

interface

uses dvCrt, dvWin,
    agUtil, agVars, agMsg;

function novoNomeCarta: string;
procedure geraTextoSMTP;
procedure preparaCarta (endEnviar, compromissoAssunto, arqEnviar: string);

var nomeArqOrig, nomeArqDest: string;
    arqOrig, arqDest: text;
    diretEnvio: string;
    nomeUsuario, enderUsuario: string;
    nomeDest: string;
    assunto: string;
    nbase: integer;

implementation

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
    if ioresult <> 0 then
        begin
            nomeArqOrig:= '';
            exit;
        end;

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
    mensagem ('AGFALESP', 1);  {'Faltou espaço no disco'}
    nomeArqOrig := '';   { impede enviar mais }
end;

{-------------------------------------------------------------}
{                     Carrega variáveis e chama procedure SMTP
{-------------------------------------------------------------}

procedure preparaCarta (endEnviar, compromissoAssunto, arqEnviar: string);
label erro;
begin

    nomeDest:= endEnviar;
    nomeArqOrig:= arqEnviar;
    assunto:= compromissoAssunto;
    nomeUsuario  := sintAmbiente ('CARTAVOX', 'NOMEUSUARIO');
    enderUsuario := sintAmbiente ('CARTAVOX', 'ENDERUSUARIO');
    diretEnvio   := sintAmbiente ('CARTAVOX', 'DIRENVIA');

    if (nomeUsuario <> '') and (enderUsuario <> '') and (diretEnvio <> '') then
        mensagem ('AGGERCAR', 1)     {'Gerando carta'}
    else
        goto erro;

    geraTextoSmtp;

    tocaEfeito ('agApiDec');

    if nomeArqOrig <> '' then
        begin
            mensagem ('AGCARGER', 1);  {'Carta gerada  '}
            exit;
        end;

erro:
    mensagem ('AGNAOGER', 1);  {'Ocorreu erro na geração da carta'}
    mensagem ('AGINFERR', 1);  {'Confira o formulário de entrada e/ou configurações do Cartavox'}

end;

end.
