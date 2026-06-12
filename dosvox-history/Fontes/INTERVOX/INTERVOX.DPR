{-------------------------------------------------------------}
{
{    Programa gerador automatico de paginas para o Intervox
{
{    Autores: Jose' Antonio Borges e Bernard Condorcet Porto
{
{    Em 29/05/2000
{
{-------------------------------------------------------------}

uses dvcrt, dvWin, windows, sysutils, inMsg;

const
    VERSAO = '1.3';
    ALFABETA = '';

var
    arq, arqSai: text;
    nomeArqModelo: string;

    titulo, cabecalho, topico, autor, email, logotipo: string;

{-------------------------------------------------------------}
{            transforma uma cadeia em maiúsculas
{-------------------------------------------------------------}

function maiusc (s: string): string;
var s2: string;
    i: integer;
begin
    s2 := s;
    for i := 1 to length (s) do
        s2 [i] := upcase (s[i]);
    maiusc := s2;
end;

{-------------------------------------------------------------}
{                     finaliza o programa
{-------------------------------------------------------------}

procedure finaliza;
begin
    writeln;
    while keypressed do readkey;
    sintSom ('SAIDA');
    mensagem ('INFIM', 1);  {'Fim do gerador'}
    while sintFalando do;
    sintFim;
    doneWinCrt;
end;

{-------------------------------------------------------------}
{                     rotina de inicializacao
{-------------------------------------------------------------}

procedure inicializa;
var s: string;
    nomeArq, nomeSai: string;
    c: char;
    dir: string;
begin
    clrscr;
    setWindowText (crtWindow, 'INTERVOX');
    dir := sintambiente ('INTERVOX', 'DIRINTERVOX');
    if dir = '' then
        dir := 'c:\winvox\som\intervox';
    sintInic (0, dir);

    sintSom ('INICIAL');
    mensagem ('ININIC', 0);   {'Gerador automático de páginas HTML - v'}
    write (VERSAO);
    sintSoletra (VERSAO);
    sintWriteln (ALFABETA);
    writeln;

    if paramCount > 0 then
        nomeArq := paramStr(1)
    else
        begin
            nomeArq:= sintAmbiente('INTERVOX', 'ARQPAG');
            mensagem ('INNOMARQ', 1);   {'Qual o nome do arquivo .PAG ? '}
            sintEditaCampo(nomeArq, wherex, wherey, 250, 80, true);
            if maiusc (copy (nomeArq, length (nomeArq)-3, 4)) = '.PAG' then
                delete (nomeArq, length (nomeArq)-3, 4);
            if nomeArq = '' then finaliza;
            nomeArq := nomeArq + '.PAG';
        end;

    assign (arq, nomeArq);
    {$I-}  reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('INARQNAO', 1);    {'Arquivo não existe'}
            finaliza;
        end;
    close (arq);

    mensagem ('INNOMHTM', 1);   {'Qual o nome do arquivo .HTM ? '}
    sintReadln (nomeSai);
    if nomeSai = '' then
        begin
            nomeSai := copy (nomeArq, 1, length(nomeArq)-4) + '.htm';
            mensagem ('IMASSUME', 0);   {'Assumido '}
            sintWriteln (nomeSai);
        end;

    assign (arqSai, nomeSai);
    {$I-}  rewrite (arqSai);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('INERRCRI', 1);    {'Erro ao criar arquivo'}
            finaliza;
        end;

    reset (arq);

    nomeArqModelo := sintAmbiente ('INTERVOX', 'MODELO');
    if nomeArqModelo = '' then
        nomeArqModelo := '\winvox\modelo.mdl';

    mensagem ('INPADRAO', 0);   {'Posso usar o modelo padrão ? '}
    c := sintReadkey;
    writeln (c);
    if upcase(c) = 'N' then
        begin
            mensagem ('INNOMMOD', 1);  {'Qual o nome completo do arquivo de modelo ?'}
            sintReadln (s);
            if (s <> '') then nomeArqModelo := s;
        end;
end;

{-------------------------------------------------------------}
{                pega os parametros principais
{-------------------------------------------------------------}

procedure pegaParametros;
var s: string;
label fim;
begin
    titulo := sintAmbiente ('INTERVOX', 'TITULO');
    cabecalho := sintAmbiente ('INTERVOX', 'CABEÇALHO');
    email := sintAmbiente ('INTERVOX', 'EMAIL');
    if email = '' then
        email := sintAmbiente ('CARTAVOX', 'ENDERUSUARIO');
    autor := sintAmbiente ('INTERVOX', 'AUTOR');
    if autor = '' then
        autor := sintAmbiente ('CARTAVOX', 'NOMEUSUARIO');
    logotipo := sintAmbiente ('INTERVOX', 'LOGOTIPO');
    if logotipo = '' then
        logotipo := 'logotipo.gif';

    while not eof (arq) do
        begin
            {$I-} readln (arq, s);  {$I+}
            if ioresult <> 0 then exit;
            if s = '' then goto fim;

            if pos (':', s) = 0 then
                begin
                    if titulo = '' then titulo := s;
                    if cabecalho = '' then cabecalho := s;
                    goto fim;
                end;

            if (maiusc (copy (s, 1, 7)) = 'TÍTULO:') or
               (maiusc (copy (s, 1, 7)) = 'TITULO:') then
                titulo := copy (s, 8, 999);
            while (titulo <> '') and (titulo[1] = ' ') do delete (titulo, 1, 1);

            if (maiusc(copy (s, 1, 9)) = 'LOGOTIPO:') then
                logotipo := copy (s, 10, 999);
            while (logotipo <> '') and (logotipo[1] = ' ') do delete (logotipo, 1, 1);

            if (maiusc (copy (s, 1, 10)) = 'CABEÇALHO:') or
               (maiusc (copy (s, 1, 10)) = 'CABECALHO:') then
                cabecalho := copy (s, 11, 999);
            while (cabecalho <> '') and (cabecalho[1] = ' ') do delete (cabecalho, 1, 1);

            if maiusc (copy (s, 1, 6)) = 'AUTOR:' then
                autor := copy (s, 7, 999);
            while (autor <> '') and (autor[1] = ' ') do delete (autor, 1, 1);

            if (maiusc (copy (s, 1, 6)) = 'EMAIL:') then
                email := copy (s, 7, 999);
            while (email <> '') and (email[1] = ' ') do delete (email, 1, 1);

            {também em português}
            if (maiusc (copy (s, 1, 9)) = 'ENDEREÇO:') or
               (maiusc (copy (s, 1, 9)) = 'ENDERECO:') then
                email := copy (s, 10, 999);
            while (email <> '') and (email[1] = ' ') do delete (email, 1, 1);
        end;

fim:
    sintSom ('SINAL');
    mensagem ('IMTITULO', 0);   {'Título da página  '}
    sintwriteln (titulo);
    sintSom ('SINAL');
    mensagem ('IMCABEC', 0);    {'Cabeçalho         '}
    sintwriteln (cabecalho);
    sintSom ('SINAL');
    mensagem ('IMAUTOR', 0);    {'Autor             '}
    sintwriteln (autor);
    sintSom ('SINAL');
    mensagem ('IMEMAIL', 0);    {'Endereço          '}
    sintwriteln (email);
    sintSom ('SINAL');
    mensagem ('IMLOGO', 0);    {'Logotipo          '}
    sintwriteln (logotipo);
end;

{-------------------------------------------------------------}
{                     transcreve modelo
{-------------------------------------------------------------}

procedure transcreveModelo (nomeArqModelo: string; parteModelo: string);
var arqModelo: text;
    s: string;
    p: integer;
label achou;
begin
   assign (arqModelo, nomeArqModelo);
   {$I-}  reset (arqModelo);  {$I+}
   if ioresult <> 0 then
       begin
            mensagem ('INMODNAO', 1);   {'Arquivo de modelos não está presente, transcrição incompleta'}
            sintWriteln (nomeArqModelo);
            exit;
       end;

{ busca uma das seguintes partes
     <<<CABEÇALHO>>>
     <<<TÓPICO>>>
     <<<ASSINATURA>>>
     <<<FIM>>>
}

   while not eof (arqModelo) do
       begin
           readln (arqModelo, s);
           if maiusc (s) = maiusc (parteModelo) then goto achou;
       end;

   mensagem ('IMARQDAN', 1);  {'Arquivo de modelo está danificado'}
   close (arqModelo);
   exit;

achou:
   s := '';
   while (not eof (arqModelo)) and (maiusc (s) <> '<<<FIM>>>') do
       begin
           readln (arqModelo, s);

           p := pos ('[TÍTULO]', s);
           if p <> 0 then
               begin
                   delete (s, p, 8);
                   insert (titulo, s, p);
               end;

           p := pos ('[CABEÇALHO]', s);
           if p <> 0 then
               begin
                   delete (s, p, 11);
                   insert (cabecalho, s, p);
               end;

           p := pos ('[TÓPICO]', s);
           if p <> 0 then
               begin
                   delete (s, p, 8);
                   insert (topico, s, p);
               end;

           p := pos ('[EMAIL]', s);
           if p <> 0 then
               begin
                   delete (s, p, 7);
                   insert (email, s, p);
               end;

           p := pos ('[AUTOR]', s);
           if p <> 0 then
               begin
                   delete (s, p, 7);
                   insert (autor, s, p);
               end;

           p := pos ('[LOGOTIPO]', s);
           if p <> 0 then
               begin
                   delete (s, p, 10);
                   insert (logotipo, s, p);
               end;

           if maiusc (s) <> '<<<FIM>>>' then
               writeln (arqSai, s);
       end;

   close (arqModelo);
end;

{-------------------------------------------------------------}
{                     cria o rótulo local
{-------------------------------------------------------------}

procedure criaRotuloLocal (lido: string);
begin
   delete (lido, 1, 1);
   writeln (arqSai, '<A NAME="', lido, '">');
end;

{-------------------------------------------------------------}
{                     cria o rótulo local
{-------------------------------------------------------------}

procedure criaReferenciaExterna (lido: string);
var referencia, texto: string;
    p: integer;
begin
   delete (lido, 1, 1);
   lido := trim (lido);

   p := pos (' ', lido);
   if p <> 0 then
       begin
           texto := copy (lido, p+1, 999);
           referencia := copy (lido, 1, p-1);
       end
   else
       begin
           referencia := lido;
           texto := '???';
           if not eof (arq) then
               readln (arq, texto) ;   { le proxima linha }
       end;

   if (texto <> '') and (texto [length (texto)] = '}') then
       delete (texto, length (texto), 1);

   {$I-}  write (arqSai, '<A HREF="', referencia, '">');  {$I+}
   if ioresult <> 0 then exit;
   {$I-}  write (arqSai, texto);  {$I+}
   if ioresult <> 0 then exit;
   {$I-}  writeln (arqSai, '</A>');  {$I+}
end;

{-------------------------------------------------------------}
{                     cria imagem
{-------------------------------------------------------------}

procedure criaFoto (lido: string);
var referencia, texto: string;
    p: integer;
begin
   delete (lido, 1, 1);
   lido := trim (lido);

   p := pos (' ', lido);
   if p <> 0 then
       begin
           texto := copy (lido, p+1, 999);
           referencia := copy (lido, 1, p-1);
       end
   else
       begin
           referencia := lido;
           texto := '???';
           if not eof (arq) then
               readln (arq, texto) ;   { le proxima linha }
       end;

   if (texto <> '') and (texto [length (texto)] = '$') then
       delete (texto, length (texto), 1);

   {$I-}  write (arqSai, '<CENTER><IMG SRC="', referencia, '"');  {$I+}
   if ioresult <> 0 then exit;
   if texto <> '' then
       begin
          {$I-}  write (arqSai, ' ALT="', texto, '"');  {$I+}
          if ioresult <> 0 then exit;
       end;
   {$I-}  writeln (arqSai, '></CENTER>');  {$I+}
end;

{-------------------------------------------------------------}
{                     gera cabeçalho
{-------------------------------------------------------------}

procedure geraCabecalho;
begin
    transcreveModelo (nomeArqModelo, '<<<CABEÇALHO>>>');
end;

{-------------------------------------------------------------}
{                     cria subtítulos
{-------------------------------------------------------------}

procedure criaSubtitulo (lido: string);
begin
    topico := copy (lido, 2, length(lido)-1);
    transcreveModelo (nomeArqModelo, '<<<TÓPICO>>>');
end;

{-------------------------------------------------------------}
{                     gera comandos finais
{-------------------------------------------------------------}

procedure geraComandosFinais;
begin
    transcreveModelo (nomeArqModelo, '<<<ASSINATURA>>>');
end;

{-------------------------------------------------------------}
{                     processamento
{-------------------------------------------------------------}

procedure processa;
label erro, erro2, proximaLinha;
var lido: string;
    ultBranca: boolean;

begin
    geraCabecalho;

    ultBranca := true;
    while not eof (arq) do
        begin
            readln (arq, lido);

            if lido = '' then
                begin
                    if ultBranca then
                        {$I-} writeln (arqSai, '<br>')
                    else
                        {$I-} writeln (arqSai, '<p>');
                    ultBranca := true;
                    goto proximaLinha;
                end
            else
                ultBranca := false;

            if lido[1] = ' ' then
                begin
                    {$I-} writeln (arqSai, '<br>'); {$I+}
                    if ioresult <> 0 then goto erro;
                    delete (lido, 1, 1);
                    while (lido <> '') and (lido[1] = ' ') do
                        begin
                            {$I-} write (arqSai, '&nbsp;'); {$I+}
                            if ioresult <> 0 then goto erro;
                            delete (lido, 1, 1);
                        end;
                end;

            if lido[1] = '.' then
                begin
                    delete (lido, 1, 1);
                    writeln (arqSai, '<li>', lido);
                end
            else
            if lido = '>>' then
                writeln (arqSai, '<blockquote>')
            else
            if lido = '<<' then
                writeln (arqSai, '</blockquote>')
            else
            if lido[1] = '#' then
                criaRotuloLocal (lido)
            else
            if lido[1] = '$' then
                criaFoto (lido)
            else
            if lido[1] = '{' then
                criaReferenciaExterna (lido)
            else
            if lido[1] = '*' then
                criaSubtitulo (lido)
            else
            if copy (lido, 1, 5) = '-----' then
                writeln (arqSai, '<hr>')
            else
                {$I-} writeln (arqSai, lido);  {$I+}

proximaLinha:
            if ioresult <> 0 then
                goto erro;
        end;

    geraComandosFinais;

    {$I-} close (arq);  {$I+}
    if ioresult <> 0 then goto erro;
    {$I-} close (arqSai); {$I+}
    if ioresult <> 0 then goto erro2;
    exit;

erro:
    mensagem ('IMERRDSK', 1);  {'Erro de escrita em disco'}

    {$I-} close (arq);  {$I+}
    if ioresult <> 0 then;
erro2:
    {$I-} close (arqSai); {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{                     programa principal
{-------------------------------------------------------------}

begin
    inicializa;
    pegaParametros;
    processa;
    finaliza;
end.
