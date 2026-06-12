{-------------------------------------------------------------}
{          sitiovox - comunicacao com o servidor de nomes
{-------------------------------------------------------------}

unit svsnomes;

interface
uses dvwin, dvcrt, winsock, dvinet, sysutils,
     svvars, svmsg;


function registraSitio (enderSitio, nomeSitio: string; portaSitio: integer): boolean;
function desRegistraSitio (enderSitio: string; portaSitio: integer): boolean;

implementation

const
    debug = true;
var
    sockNomes: integer;
    bufNomes:  pBufRede;           { Buffer do soquete }

{--------------------------------------------------------}
{                forma endereco complexo
{--------------------------------------------------------}

function formaEmail (email: string; porta: integer): string;
var
    s: string [6];
begin
    if porta = PORTA_SITIOVOX then
        formaEmail := email
    else
        begin
           str (porta, s);
           formaEmail := email + ':' + s;
        end;
end;

{--------------------------------------------------------}
{                conecta com servidor
{--------------------------------------------------------}

function conectaServidor: boolean;
var s: string;
begin
    conectaServidor := false;
    bufNomes := NIL;

    servNomes := sintAmbiente ('SITIOVOX', 'SERVNOMES');
    if servNomes = '' then
        servNomes := SERV_DEFAULT;
    writeln (servNomes);

    sockNomes := abreConexao (servNomes, PORTA_NOMES);
    if sockNomes < 0 then
        begin
            mensagem ('SVERCON', 1);  {Não consegui realizar a conexão}
            exit;
        end;

    bufNomes := inicBufRede (sockNomes);
    if not readlnBufRede (bufNomes, s, 15) then exit;
    writeln (s);

    conectaServidor := true;
end;

{--------------------------------------------------------}
{     registra fim do servidor no servidor de nomes
{--------------------------------------------------------}

function desRegistraSitio (enderSitio: string; portaSitio: integer): boolean;
var
    s: string;

label naoConec;

begin
    desRegistraSitio := true;
    mensagem ('SVLOGOFF', 1);  {Registrando fim do servidor}

    if not conectaServidor then goto naoConec;

    s := 'REMOVE ' + formaEmail (enderSitio, portaSitio);
    if debug then writeln (s);
    writelnRede (sockNomes, s);
    if not readlnBufRede (bufNomes, s, 15) then goto naoConec;
    if debug then writeln (s);

    if s[1] = '-' then
        begin
            mensagem ('SVDESREG', 1); {Servidor desconheceu registro}
            sintWriteln (s);
            desRegistraSitio := false;
        end;

    s := 'QUIT';
    writelnRede (sockNomes, s);
    if debug then writeln (s);
    readlnBufRede (bufNomes, s, 15);
    if debug then writeln (s);

    fimBufRede (bufNomes);
    fechaConexao (sockNomes);
    exit;

naoConec:
    if bufNomes <> NIL then
        fimBufRede (bufNomes);
    fechaConexao (sockNomes);

    mensagem ('SVNAOCON', 2);  {Não consegui registrar saida}
    desRegistraSitio := false;
end;

{--------------------------------------------------------}
{                Registra usuário na rede
{--------------------------------------------------------}

function registraSitio (enderSitio, nomeSitio: string; portaSitio: integer): boolean;
var s: string;
label naoConec;

begin
    mensagem ('SVLOGON', 1);    {Registrando início do servidor}

    if not conectaServidor then goto naoConec;

    s := 'REGISTER ' + formaEmail (enderSitio, portaSitio);
    writeln (s);
    writelnRede (sockNomes, s);
    if not readlnBufRede (bufNomes, s, 15) then goto naoConec;
    writeln (s);

    if s[1] = '-' then goto naoConec;

    writeln (nomeSitio);
    writelnRede (sockNomes, nomeSitio);
    if not readlnBufRede (bufNomes, s, 15) then goto naoConec;
    writeln (s);

    if s[1] = '-' then goto naoConec;

    writelnRede (sockNomes, '.');
    readlnBufRede (bufNomes, s, 15);

    writelnRede (sockNomes, 'QUIT');
    readlnBufRede (bufNomes, s, 15);
    writeln (s);

    fimBufRede (bufNomes);
    fechaConexao (sockNomes);

    mensagem ('SVREGOK', 2);    {Registro ok}
    registraSitio := true;
    exit;

naoConec:
    if bufNomes <> NIL then
        fimBufRede (bufNomes);
    fechaConexao (sockNomes);
    mensagem ('SVERRSRV', 2);   {Não consegui acionar servidor de nomes}
    registraSitio := false;
end;

end.
