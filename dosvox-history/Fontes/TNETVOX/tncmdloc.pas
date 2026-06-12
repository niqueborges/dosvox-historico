{-------------------------------------------------------------}
{
{    Telnet Falado
{
{    Controles locais
{
{    Autor: Jose' Antonio Borges
{
{    Em 13/1/99
{
{-------------------------------------------------------------}

unit tncmdloc;
interface
uses
    winprocs, wintypes, dvcrt, sysUtils, dvWin, winsock,
    tnvars, tnfala, tnansi, tnRede, tnMsg,
    dvHora, videovox;

procedure carregaTabAlt (nomeArqAlt: string);
procedure executaComando (c: char);
procedure programaComando;

implementation

{-------------------------------------------------------------}
{                   compara trecho da tela
{-------------------------------------------------------------}

function comparaTela (xchave, ychave: integer; chave: string): boolean;
var i, x: integer;
begin
    comparaTela := false;
    for i := 1 to length(chave) do
        begin
            x := xchave+i-1;    
            if (x <= 80) and
               (getScreenChar (xchave+i-1, ychave) <> chave [i]) then
                    exit;
        end;
    comparaTela := true;
end;

{-------------------------------------------------------------}
{              carrega tabela de comandos ALT
{-------------------------------------------------------------}

procedure carregaTabAlt (nomeArqAlt: string);
label erro;
var arqAlt: text;
    i: integer;
    s: string;

begin
    for i := 1 to tamTabAlt do
        dispose (tabAlt [i]);
    tamTabAlt := 0;

    if nomeArqAlt = '' then
        nomeArqAlt := 'c:\dosvox\tnetvox.amb';

    assign (arqAlt, nomeArqAlt);
    {$I-} reset (arqAlt);  {$I+}
    if ioresult <> 0 then exit;

    while not eof (arqAlt) do
        begin
            tamTabAlt := tamTabAlt + 1;
            new (tabAlt [tamTabAlt]);
            with tabAlt [tamTabAlt]^ do
                begin
                    letra := '*';
                    repeat
                        {$I-} readln (arqAlt, s);  {$I+}
                        if ioresult <> 0 then goto erro;
                        if s <> '' then letra := s[1];
                    until letra <> '*';
                    {$I-} readln (arqAlt, xchave, ychave);  {$I+}
                    if ioresult <> 0 then goto erro;
                    {$I-} readln (arqAlt, chave);  {$I+}
                    if ioresult <> 0 then goto erro;
                    {$I-} readln (arqAlt, acao);  {$I+}
                    if ioresult <> 0 then goto erro;
                end;
        end;

    close (arqAlt);
    exit;

erro:
    mensagem ('TNERRALT', 1);
    sintWriteInt (tamTabAlt);
    writeln;

    close (arqAlt);
end;

{-------------------------------------------------------------}
{                executa um comando ALT
{-------------------------------------------------------------}

procedure executaComando (c: char);

{ Relacao de codigos:
{
{ L -> le area retangular com l1,c1,l2,c2
{      exemplo: ler tela inteira:  L1,1,25,80
{ S -> soletra area retangular com l1,c1,l2,c2
{ G -> gravar um arquivo em disco com l1,c1,l2,c2
}
var i, p: integer;
    l1, l2, c1, c2: integer;
    s: string;

    {-------------------------------------------------------------}

    function pegaInt: integer;
    var v: integer;
    begin
        v := 0;
        s := s + ' ';
        while s[p] in ['0'..'9'] do
            begin
                v := v * 10 + ord (s[p]) - ord ('0');
                p := p + 1;
            end;
        pegaInt := v;
        delete (s, length(s), 1);
    end;

    {-------------------------------------------------------------}

label achou;

begin
    for i := 1 to tamTabAlt do
        with tabAlt [i]^ do
            if (letra = c) and comparaTela (xchave, ychave, chave) then
                begin
                    s := acao;
                    goto achou;
                end;

    sintBip;  sintBip;
    exit;

achou:
    p := 1;
    case upcase(s[p]) of

       'D', 'S',    {deletrear na versão espanhol }
       'L'  : begin
                p := p + 1;
                l1 := pegaInt;
                if l1 = 0 then l1 := wherey;
                p := p + 1;

                c1 := pegaInt;
                if c1 = 0 then c1 := wherex;
                p := p + 1;

                l2 := pegaInt;
                if l2 = 0 then l2 := wherey;
                p := p + 1;

                c2 := pegaInt;
                if c2 = 0 then c2 := wherex;
                p := p + 1;
                for i := l1 to l2 do
                    begin
                        lePedacoLinhaVideo (i, c1, c2, upcase(s[1]) <> 'L');
                        sintClek;
                    end;
                end;

           'G': begin
                p := p + 1;
                l1 := pegaInt;
                if l1 = 0 then l1 := wherey;
                p := p + 1;

                c1 := pegaInt;
                if c1 = 0 then c1 := wherex;
                p := p + 1;

                l2 := pegaInt;
                if l2 = 0 then l2 := wherey;
                p := p + 1;

                c2 := pegaInt;
                if c2 = 0 then c2 := wherex;
                p := p + 1;

                for i := l1 to l2 do
                    begin
                        gravaPedacoLinhaVideo (i, c1, c2, upcase(s[1]) = 'S');
                        sintClek;
                    end;
                end;
    end;
end;

{-------------------------------------------------------------}
{                 le posicao desejada da tela
{-------------------------------------------------------------}

function lepos (var x, y: integer): boolean;
var c: char;
begin
    lePos := false;
    repeat
        gotoxy (x, y);
        sintCarac (getScreenChar (x, y));

        c := readkey;
        if c = ESC then exit;

        if c = #$0 then
            case readkey of
                CIMA: y := y - 1;
                BAIX: y := y + 1;
                ESQ:  x := x - 1;
                DIR:  x := x + 1;
            end;

        if x < 1  then x := 1;
        if x > 80 then x := 80;
        if y < 1  then y := 1;
        if y > numLinhasTerm then y := numLinhasTerm;

    until c = ENTER;
    lePos := true;
end;

{-------------------------------------------------------------}
{                 regrava tabela de alts
{-------------------------------------------------------------}

procedure gravaTabAlt;
var
    arqAlt: text;
    nomeArqAlt: string;
    i: integer;
label erro;
begin
    nomeArqAlt := sintAmbiente ('TNETVOX', 'ARQALTS');
    if nomeArqAlt = '' then
        nomeArqAlt := 'c:\winvox\tnetvox.amb';

    assign (arqAlt, nomeArqAlt);
    {$I-} rewrite (arqAlt);  {$I+}
    if ioresult <> 0 then goto erro;

    for i := 1 to tamTabAlt do
      with tabAlt [i]^ do
        begin
            {$I-} writeln (arqAlt, '*');  {$I+}
            if ioresult <> 0 then goto erro;
            {$I-} writeln (arqAlt, letra);  {$I+}
            if ioresult <> 0 then goto erro;
            {$I-} writeln (arqAlt, xchave, ' ', ychave);  {$I+}
            if ioresult <> 0 then goto erro;
            {$I-} writeln (arqAlt, chave);  {$I+}
            if ioresult <> 0 then goto erro;
            {$I-} writeln (arqAlt, acao);  {$I+}
            if ioresult <> 0 then goto erro;
        end;

    {$I-}  close (arqAlt);  {$I+}
    if ioresult <> 0 then goto erro;
    exit;

erro:
    {$I-}  close (arqAlt);    {$i+}
    if ioresult <> 0 then;

    gotoxy (1, numLinhasTerm+1);
    msgBaixo ('TNTRUNC');   {'Arquivo foi truncado'}
end;

{-------------------------------------------------------------}
{                 programa um comando ALT
{-------------------------------------------------------------}

procedure programaComando;
var
    salvax, salvay, xch, ych: integer;
    posTab, i: integer;
    x, x1, y1, x2, y2: integer;
    ch, s: string;
    sn: string [5];
    let, c, tipoacao: char;
    novaProg: TCmdAlt;

label achou, programa, cancela, fim;

begin
    salvax := wherex;
    salvay := wherey;

    msgBaixo ('TNLETPRG');   {'Pressione a letra a programar'}
    c := upcase(sintReadkey);
    msgBaixo ('');
    if not (c in ['A'..'Z']) then
        goto cancela;

    let := c;
    ch := '';
    xch := 1;  ych := 1;
    x2 := 1;   y2 := 1;

    gotoxy (1, numLinhasTerm+1);
    msgBaixo ('TNUSACHV');   {'Usa algum campo para ativar esta tecla ?'}
    c := upcase (sintReadkey);
    if c = ESC then
        goto cancela;
    msgBaixo ('');

    if c = 'S' then
        begin
            msgBaixo ('TNINICHV');   {'Posicione o cursor no início da chave'}
            if not lePos (xch, ych) then goto cancela;
            msgBaixo ('');

            msgBaixo ('TNFIMCHV');   {'Posicione o cursor no fim da chave'}
            x2 := xch;  y2 := ych;
            if not lePos (x2, y2) then goto cancela;
            msgBaixo ('');

            for x := xch to x2 do
                ch := ch + getScreenChar (x, ych);
        end;

    { ve se reprogramada }

    posTab := 0;
    for i := 1 to tamTabAlt do
        with tabAlt [i]^ do
            if (letra = let) and comparaTela (xch, ych, ch) then
                begin
                    goto achou;
                    posTab := i;
                end;
    goto programa;

achou:
    msgBaixo ('TNCHVEXI');   {'Chave existe: soma, reprograma, apaga ou ESC ? '}
    c := upcase(sintReadkey);
    if c = ESC then goto cancela;

    if c = 'S' then
        postab := 0
    else
    if (c = 'A') or (c = 'B') then
        begin
            dispose (tabAlt [posTab]);
            for i := posTab to tamTabAlt do
                 tabAlt [i] := tabAlt [i+1];
            tamTabAlt := tamTabAlt - 1;
            goto fim;
        end;

programa:
    msgBaixo ('TNINIARE');   {'Posicione o cursor no início da área'}
    x1 := x2;   y1 := y2;
    if not lePos (x1, y1) then goto cancela;
    msgBaixo ('');

    msgBaixo ('TNFIMARE');   {'Posicione o cursor no fim da área'}
    x2 := x1;  y2 := y1;
    if not lePos (x2, y2) then goto cancela;
    msgBaixo ('');

    msgBaixo ('TNLESOLG');   {'Ler, soletrar ou gravar ? '}
    tipoacao := upcase (sintReadkey);
    if not (tipoacao in ['L', 'G', 'S', 'D']) then
        goto cancela;
    msgBaixo ('');

    s := tipoacao;
        str (y1, sn);  s := s + sn + ',';
        str (x1, sn);  s := s + sn + ',';
        str (y2, sn);  s := s + sn + ',';
        str (x2, sn);  s := s + sn;

    with novaProg do
        begin
            letra := let;
            xchave := xch;
            ychave := ych;
            chave := ch;
            acao := s;
        end;

    if posTab = 0 then    {poe nova programacao na frente}
        begin
            if tamTabAlt > 0 then
                for i := 1 to tamTabAlt do
                    tabAlt [tamTabAlt-i+2] := tabAlt [tamTabAlt-i+1];
            tamTabAlt := tamTabAlt + 1;
            posTab := 1;
            new (tabAlt [posTab]);
        end;

    tabAlt [posTab]^ := novaProg;
    gravaTabAlt;

    goto fim;

cancela:
    msgBaixo ('');
    msgBaixo ('TNNAOPRG');     {'Programação cancelada'}

fim:
    delay (1000);
    msgBaixo ('');
    sintBip;
    window (1, 1, 80, numLinhasTerm);
    gotoxy (salvax, salvay);
end;

end.
