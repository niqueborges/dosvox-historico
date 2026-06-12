{-------------------------------------------------------------}
{
{     Registro dos sites Miniweb ativos
{
{     Autor: José Antonio Borges
{
{     Em 21/4/2001
{
{-------------------------------------------------------------}

uses dvwin, dvcrt, dvinet, winsock, strings, windos;
const
    PORTA_POP = 110;
    TAM_BUFFER = 4096;

type
    PSite = ^TSite;
    TSite = record
        ip: string[25];
        porta: integer;
        nome: string;
    end;

var ncartas: integer;
    nsites: integer;
    site: array [1..5000] of PSite;
    emailDef: string;
    correioDef: string;
    senhaDef: string;
    caracVivo: integer;
    acessouCorreio: boolean;
    siteChecado: integer;

{-------------------------------------------------------------}
{                 faz um desenhinho na tela
{-------------------------------------------------------------}

procedure mostraQueEstaVivo;
const
    tabVivo: array [0..3] of char = ('-', '\', '|', '/');
begin
    caracVivo := (caracVivo + 1) mod 4;
    write (tabVivo [caracVivo]);
    gotoxy (1, wherey);
    keypressed;
end;

{-------------------------------------------------------------}
{                    registra um novo site
{-------------------------------------------------------------}

procedure novoSite (s: string);
var
    p: integer;
    erro: integer;
begin
    nsites := nsites + 1;
    new (site[nsites]);
    with site[nsites]^ do
         begin
             porta := 80;
             p := pos (' ', s);
             ip := copy (s, 1, p-1);
             delete (s, 1, p);
             p := pos (':', ip);
             if p <> 0 then
                 begin
                     val (copy (ip, p+1, 6), porta, erro);
                     delete (ip, p, 99);
                 end;

             while (s <> '') and (s[1] = ' ') do
                 delete (s, 1, 1);
             nome := s;
         end;
end;

{-------------------------------------------------------------}
{                     inicializacao
{-------------------------------------------------------------}

procedure inicializa;
var arq: text;
    s: string;
    p: integer;
begin
    writeln ('Controle de sites Miniweb ativos');
    writeln;

    abreWinSock;

    nsites := 0;

    assign (arq, 'c:\siteativ.$$$');
    {$I-} reset (arq); {$I+}
    if ioresult <> 0 then exit;

    while not eof (arq) do
        begin
            readln (arq, s);
            if s <> '' then
                novoSite (s);
        end;
    close (arq);
end;

{-------------------------------------------------------------}
{                     pega uma carta
{-------------------------------------------------------------}

function pegaCarta(sock: SOCKET; nc: integer): boolean;
var s, s2, snum: string;
    pbuf: PbufRede;
    i: integer;
    v: array [0..2000] of char;
label fim;
begin
    pbuf := inicBufRede (sock);
    str (nc, snum);
    writelnRede (sock, 'TOP ' + snum + ' 0');

    pegaCarta := true;
    repeat
        if not readlnBufRede (pbuf, s, 10) then
            begin
                pegaCarta := false;
                goto fim;
            end;

        s2 := maiuscAnsi (copy (s, 1, 7));
        if (s2 = 'SUBJECT') or (s2 = 'SUJECT') then
            begin
                if pos ('MINIWEB', s) = 0 then
                    continue;

                delete (s, 1, pos ('MINIWEB', s)+7);

                novoSite (s);
            end;

    until s = '.';

fim:
    write ('*');
    writelnRede (sock, 'DELE ' + snum);
    fimBufRede (pbuf);
end;

{-------------------------------------------------------------}
{                 pega cartas pelo correio
{-------------------------------------------------------------}

procedure pegaCorreio;
var
    sock: SOCKET;
    resp: array [0..TAM_BUFFER] of char;
    nc, n, err: integer;
    s, s2: string;

label erro;

    function correioReclamou: boolean;
    begin
        correioReclamou := resp[0] <> '+';
    end;

    procedure pegaNumCartas;
    begin
        resp[nc] := #$0;
        s := strpas (resp);

        while (s <> '') and (s[1] <> ' ') do delete (s, 1, 1);
        while (s <> '') and (s[1] = ' ')  do delete (s, 1, 1);
        s2 := '';
        while (s <> '') and (s[1] <> ' ') do
            begin
                s2 := s2 + s[1];
                delete (s, 1, 1);
            end;

        val (s2, ncartas, err);
        if ncartas <> 0 then
            writeln ('Novos sites registrados: ', ncartas);
    end;

begin
    nc := 0;
    sock := abreConexao (correioDef, PORTA_POP);
    if sock <= 0 then goto erro;

    nc := recv (sock, resp, sizeof(resp), 0);
    if (nc <= 0) or correioReclamou then goto erro;

    writelnRede (sock, 'USER ' + emailDef);
    nc := recv (sock, resp, sizeof(resp), 0);
    if (nc <= 0) or correioReclamou then goto erro;

    writelnRede (sock, 'PASS ' + senhaDef);
    nc := recv (sock, resp, sizeof(resp), 0);
    if (nc <= 0) or correioReclamou then goto erro;

    writelnRede (sock, 'STAT');
    nc := recv (sock, resp, sizeof(resp), 0);
    if (nc <= 0) or correioReclamou then goto erro;

    pegaNumCartas;
    for n := 1 to ncartas do
        pegaCarta(sock, n);

    writelnRede (sock, 'QUIT');
    nc := recv (sock, resp, sizeof(resp), 0);
    if (nc <= 0) or correioReclamou then goto erro;

    fechaConexao (sock);
    acessouCorreio := true;
    exit;

erro:
    writeln ('Erro de correio: ', correioDef);
    fechaConexao (sock);
end;

{-------------------------------------------------------------}
{                    pega os novos sites
{-------------------------------------------------------------}

procedure pegaNovosSites;
var i: integer;
begin
    acessouCorreio := false;

    correioDef := 'intervox.nce.ufrj.br';
    emailDef := 'miniweb';
    senhaDef := 'amoreluz';
    pegaCorreio;

    correioDef := 'caec.nce.ufrj.br';
    emailDef := 'miniweb';
    senhaDef := 'amoreluz';
    pegaCorreio;
end;

{-------------------------------------------------------------}
{              traduz um inteiro para caracteres
{-------------------------------------------------------------}

const
    tabint: array [0..9] of char = ('0','1','2','3','4','5','6','7','8','9');

function int2str (v: longint): string;
var s: string;
begin
    s := '';
    if v < 0 then
        begin
            v := -v;
            s := '-';
        end;

    while v > 0 do
         begin
             s := tabint [v mod 10] + s;
             v := v div 10;
         end;

    if s = '' then
        int2Str := '0'
    else
        int2Str := s;
end;

{-------------------------------------------------------------}
{               traduz um byte para caracteres
{-------------------------------------------------------------}

function int2 (x: byte): string;
begin
    int2 := tabint [x div 10] + tabint [x mod 10];
end;

{-------------------------------------------------------------}
{                  grava a lista de sites
{-------------------------------------------------------------}

procedure gravaLista;
var i: integer;
    s: string;
    arq: text;

begin
    clrscr;
    writeln ('Controle de sites Miniweb ativos');
    writeln;

    assign (arq, 'c:\siteativ.$$$');
    {$I-} rewrite (arq); {$I+}
    if ioresult <> 0 then exit;

    {$I-} rewrite (arq); {$I+}
    if ioresult <> 0 then exit;

    if nsites = 0 then
        writeln ('Nenhum site ativo')
    else
        begin
            writeln;
            writeln ('Sites ativos');
            writeln;
        end;

    for i := 1 to nsites do
        with site[i]^ do
            begin
                s := ip;
                if porta <> 80 then
                    s := s + ':' + int2str (porta);
                s := s + ' ';
                s := s + nome;
                writeln (s);
                writeln (arq, s);
            end;

    close (arq);
end;

{-------------------------------------------------------------}
{                  publica a lista de sites
{-------------------------------------------------------------}

procedure publicaLista;
var i: integer;
    s: string;
    arq, arq2: text;
    dir: string;

begin
    dir := sintAmbiente ('MINIWEB', 'DIR');
    if (dir = '') or (dir[length(dir)] <> '\') then
        dir := dir + '\';
    assign (arq, dir+'00sites.htm');
    {$I-} rewrite (arq); {$I+}
    if ioresult <> 0 then exit;

    if nsites = 0 then
        writeln (arq, '<html><h3>Nenhum site MINIWEB ativo</H3></html>')
    else
        begin
             writeln (arq, '<html>');
             writeln (arq, '<head><title>Lista de sites Miniweb</title></head>');
             writeln (arq, '<h3>Sites ativos</H3>');
        end;

    for i := 1 to nsites do
        with site[i]^ do
            begin
                s := ip;
                if porta <> 80 then
                    s := s + ':' + int2str (porta);
                writeln (arq, '<a href="http://', s, '">', nome, '</a><br>');
            end;

    writeln (arq, '</html>');
    close (arq);
end;

{-------------------------------------------------------------}
{                 elimina os sites duplicados
{-------------------------------------------------------------}

procedure eliminaSitesDuplicados;
var i, i2, j: integer;
    sock: socket;
begin
    i := 1;
    while i <= nsites-1 do
        begin
            i2 := i+1;
            while i2 <= nsites do
                begin
                    if (site[i]^.ip    = site[i2]^.ip)    and
                       (site[i]^.porta = site[i2]^.porta) then
                       begin
                           dispose (site[i]);
                           for j := i to nsites-1 do
                               site[j] := site[j+1];
                           nsites := nsites - 1;
                       end;
                    i2 := i2 + 1;
                end;
            i := i + 1;
        end;
end;

{-------------------------------------------------------------}
{                 elimina os sites que sairam
{-------------------------------------------------------------}

function checaSeSiteFora: boolean;
var j: integer;
    sock: socket;
begin
    checaSeSiteFora := false;

    if nsites = 0 then exit;
    if (siteChecado >= nsites) or (siteChecado < 1) then
        siteChecado := 1
    else
        siteChecado := siteChecado + 1;

    with site[siteChecado]^ do
        begin
            sock := abreConexao (ip, porta);
            if sock < 0 then
                begin
                    dispose (site[siteChecado]);
                    for j := siteChecado to nsites-1 do
                         site[j] := site[j+1];

                    nsites := nsites - 1;
                    siteChecado := siteChecado - 1;
                    checaSeSiteFora := true;
                end;
            fechaConexao (sock);
        end;
end;

{-------------------------------------------------------------}
{                  publica lista de sites
{-------------------------------------------------------------}

var n, antes: integer;
label fim;
begin
    inicializa;

    eliminaSitesDuplicados;
    gravaLista;
    publicaLista;

    repeat
        for n := 1 to 30 do
            begin
               delay (1000);
               if keypressed then
                   if readkey = ESC then goto fim;
            end;

        antes := nsites;
        pegaNovosSites;
        eliminaSitesDuplicados;
        if antes <> nsites then
            begin
                gravaLista;
                publicaLista;
            end;

        if keypressed then
            if readkey = ESC then goto fim;

        for n := 1 to 30 do
            begin
               delay (1000);
               if keypressed then
                   if readkey = ESC then goto fim;
            end;

        n := 0;
        repeat
            n := n+1;
            if acessouCorreio and checaSeSiteFora then
                begin
                    gravaLista;
                    publicaLista;
                end;

        until (siteChecado = nsites) or (n > 10);

    until false;

fim:
    doneWincrt;
end.