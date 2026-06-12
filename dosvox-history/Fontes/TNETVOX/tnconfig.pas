unit tnconfig;

interface

uses
    winprocs, wintypes, dvcrt, sysUtils, dvWin, winsock, dvForm,
    tnvars, tnMsg, tnCmdLoc, tnvideo;

function pegaNoAmbiente (qualAmbiente, qualChave: string): string;
procedure configDefault (qualAmbiente: string);
procedure configura;
procedure reconfigura;
procedure guardaConfig (qualAmbiente: string);

implementation

const
    tabModos: array [TModoFala] of char = ('N', 'L', 'V', 'C', 'M');
    tabTerm: array[TTYPE] of pchar = ('vt100', 'TI200', 'HP700');

{-------------------------------------------------------------}
{         pega uma chave num arquivo de configuração
{-------------------------------------------------------------}

function pegaNoAmbiente (qualAmbiente, qualChave: string): string;
begin
    if qualAmbiente = '' then
        pegaNoAmbiente := sintAmbiente ('TNETVOX', qualChave)
    else
        pegaNoAmbiente := sintAmbienteArq (qualAmbiente, qualChave, '',
                                                                tnetvoxConfigs);
end;

{-------------------------------------------------------------}
{                    guarda configuração
{-------------------------------------------------------------}

procedure guardaNoAmbiente (qualAmbiente, qualChave, qualValor: string);
begin
    if qualAmbiente = '' then
        sintGravaAmbiente    ('TNETVOX', qualChave, qualValor)
    else
        sintGravaAmbienteArq (qualAmbiente, qualChave, qualValor, tnetvoxConfigs);
end;

{-------------------------------------------------------------}
{                   pega configuração default
{-------------------------------------------------------------}

procedure configDefault (qualAmbiente: string);
var s: string;
    v, i: integer;
    erro: integer;
begin
    debugging := false;

    nomeComput := pegaNoAmbiente (qualAmbiente, 'NOMECOMPUT');
    strPCopy (nomeHost, nomeComput);

    s := pegaNoAmbiente (qualAmbiente, 'VELOCIDADE');
    if s <> '' then
        begin
            val (s, v, erro);
            sintVeloc (v);
        end;

    porta := 23;
    s := pegaNoAmbiente (qualAmbiente, 'PORTA');
    if s <> '' then
        begin
            val (s, porta, erro);
            if erro <> 0 then porta := 23;
        end;

    soletrando := copy (pegaNoAmbiente (qualAmbiente, 'SOLETRA'), 1, 1) <> 'N';

    s := pegaNoAmbiente (qualAmbiente, 'TERMINAL');
    for i := 1 to length (s) do s[i] := upcase (s[i]);
    if copy (s, 1, 2) = 'TI' then
        tipoTerm := TERM_TI
    else
    if copy (s, 1, 2) = 'HP' then
        tipoTerm := TERM_HP
    else
        tipoTerm := TERM_ANSI;

    s := pegaNoAmbiente (qualAmbiente, 'NUMLINHAS');
    if s = '' then
        numLinhasTerm := 24
    else
        begin
            val (s, numLinhasTerm, erro);
            if erro <> 0 then
                numLinhasTerm := 24;
        end;

    s := pegaNoAmbiente (qualAmbiente, 'COLUNABIP');
    while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
    colbip := 0;
    val (s, colbip, erro);

    s := pegaNoAmbiente (qualAmbiente, 'USAACENTOS');
    usaAcentos := (s = '') or (upcase(s[1]) <> 'N');
    SelectOemFont := not usaAcentos;

    if tipoTerm = TERM_HP then
        begin
            screenSize.y := numLinhasTerm+5;
            enterCRLF := true;
        end
    else
        screenSize.y := numLinhasTerm+1;

    s := pegaNoAmbiente (qualAmbiente, 'MODOFALA');
    if s = '' then s := ' ';
    case upcase (s[1]) of
        'L': modoFala := falaLynx;
        'V': modoFala := falaTudo;
        'C': modoFala := falaCalado;
        'M': modoFala := falaMudo;
    else
        modoFala := falaNormal;
    end;
    modoDefault := modoFala;

    s := pegaNoAmbiente (qualAmbiente, 'ENVIASONOENTER');
    if s = '' then
        if porta = 23 then acumulaTeclado := false
                      else acumulaTeclado := false
    else
        acumulaTeclado := copy (s, 1, 1) = 'S';

    s := pegaNoAmbiente (qualAmbiente, 'ENTERGERACRLF');
    if s = '' then
        if porta = 23 then enterCRLF := false
                      else enterCRLF := false
    else
        enterCRLF := copy (s, 1, 1) = 'S';

    s := pegaNoAmbiente (qualAmbiente, 'PGUPCOMCTL');
    pgUpComCtl := (s <> '') and (upcase (s[1]) = 'S');

    tamTabAlt := 0;
    nomeArqAlt := pegaNoAmbiente (qualAmbiente, 'ARQALTS');
    if nomeArqAlt <> '' then
        carregaTabAlt (nomeArqAlt);

    delayBusca := 200;
    s := pegaNoAmbiente (qualAmbiente, 'DELAYBUSCA');
    if s <> '' then
        begin
            val (s, delayBusca, erro);
            if erro <> 0 then delayBusca := 200;
        end;

    nomeArqLynx := pegaNoAmbiente (qualAmbiente, 'ARQLYNX');
    if nomeArqLynx = '' then
        nomeArqLynx := 'lynx.$$$';

    nomeArqTelas := pegaNoAmbiente (qualAmbiente, 'ARQTELAS');
    if nomeArqTelas = '' then
        nomeArqTelas := 'telas.$$$';
end;

{-------------------------------------------------------------}
{                   pega configuração default
{-------------------------------------------------------------}

procedure guardaConfig (qualAmbiente: string);

    function boolToStr (v: boolean): string;
    begin
        if v then boolToStr := 'SIM' else boolToStr := 'NAO';
    end;

begin
    guardaNoAmbiente (qualAmbiente, 'NOMECOMPUT', nomeComput);
    guardaNoAmbiente (qualAmbiente, 'PORTA', intToStr (porta));
    guardaNoAmbiente (qualAmbiente, 'VELOCIDADE', intToStr(velocAtual));
    guardaNoAmbiente (qualAmbiente, 'MODOFALA', tabModos[modoFala]);
    guardaNoAmbiente (qualAmbiente, 'SOLETRA', boolToStr (soletrando));
    guardaNoAmbiente (qualAmbiente, 'TERMINAL', tabTerm[tipoTerm]);
    guardaNoAmbiente (qualAmbiente, 'NUMLINHAS', intToStr (numLinhasTerm));
    guardaNoAmbiente (qualAmbiente, 'COLUNABIP', intToStr(colbip));
    guardaNoAmbiente (qualAmbiente, 'USAACENTOS', boolToStr(usaAcentos));
    guardaNoAmbiente (qualAmbiente, 'ENVIASONOENTER', boolToStr(acumulaTeclado));
    guardaNoAmbiente (qualAmbiente, 'ENTERGERACRLF', boolToStr(enterCRLF));
    guardaNoAmbiente (qualAmbiente, 'PGUPCOMCTL', boolToStr(pgUpComCtl));
    guardaNoAmbiente (qualAmbiente, 'ARQALTS', nomeArqAlt);
    guardaNoAmbiente (qualAmbiente, 'DELAYBUSCA', intToStr(delayBusca));
    guardaNoAmbiente (qualAmbiente, 'ARQLYNX', nomeArqLynx);
    guardaNoAmbiente (qualAmbiente, 'ARQTELAS', nomeArqTelas);
end;

{--------------------------------------------------------}
{                    configura
{--------------------------------------------------------}

procedure configura;
var
    v: integer;
    strModoFala: shortString;
    tipoTm: shortString;
    sNomeHost: shortString;
    s: string;

label fim;
begin
    tamRotulosForm := 35;

    strModoFala := tabModos [modoFala];
    v := velocAtual;
    sNomeHost := strPas(nomeHost);

    writeln;
    writeln (pegaTextoMensagem ('TNMODFAL'));
    writeln;

    strModoFala := tabModos[modoFala];
    tipotm := tabTerm[tipoTerm];
    formCria;
    formCampo     ('TNCHOST',  pegaTextoMensagem ('TNCHOST'),  sNomeHost, 80);      {Nome ou endereço remoto:}
    formCampoInt  ('TNCPORTA', pegaTextoMensagem ('TNCPORTA'), porta);              {Porta}
    formCampoInt  ('TNCVELOC', pegaTextoMensagem ('TNCVELOC'), v);                  {Velocidade 1 a 4}
    formCampo     ('TNCMODOF', pegaTextoMensagem ('TNCMODOF'), strModoFala, 20);    {Modo de fala}
    formCampoBool ('TNCSOLET', pegaTextoMensagem ('TNCSOLET'), soletrando);         {Soletra digitação}
    formCampo     ('TNCTTERM', pegaTextoMensagem ('TNCTTERM'), tipotm, 20);         {VT100, HP ou TI200}
    formCampoInt  ('TNCNLIN',  pegaTextoMensagem ('TNCNLIN'),  numLinhasTerm);      {Número de linhas}
    formCampoInt  ('TNCCLBIP', pegaTextoMensagem ('TNCCLBIP'), colbip);             {Coluna do bip}
    formCampoBool ('TNCACENT', pegaTextoMensagem ('TNCACENT'), usaAcentos);         {Apresenta acentos na tela}
    formCampoBool ('TNCENVTC', pegaTextoMensagem ('TNCENVTC'), acumulaTeclado);     {Envia teclagem só no enter}
    formCampoBool ('TNCECRLF', pegaTextoMensagem ('TNCECRLF'), enterCRLF);          {Enter gera CRLF}
    formCampoBool ('TNCPGUPC', pegaTextoMensagem ('TNCPGUPC'), pgUpComCtl);         {PAGE UP com Control}
    formCampoInt  ('TNCDELAY', pegaTextoMensagem ('TNCDELAY'), delayBusca);         {Espera (ms) nas buscas}
    formCampo     ('TNCARQAL', pegaTextoMensagem ('TNCARQAL'), nomeArqAlt, 80);     {Arquivo de definição dos ALT}
    formCampo     ('TNCARQLX', pegaTextoMensagem ('TNCARQLX'), nomeArqLynx, 80);    {Arquivo de armazenagem Lynx}
    formCampo     ('TNCARQTL', pegaTextoMensagem ('TNCARQTL'), nomeArqTelas, 80);   {Arquivo para guardar de telas}

    formEdita (true);

    if sNomeHost <> '' then
        strPCopy (nomeHost, sNomeHost); 

    if strModoFala = '' then strModoFala := ' ';
    case upcase (strModoFala[1]) of
        'L': modoFala := falaLynx;
        'V': modoFala := falaTudo;
        'C': modoFala := falaCalado;
        'M': modoFala := falaMudo;
    else
        modoFala := falaNormal;
    end;

    s := maiuscAnsi (tipoTm);
    if copy (s, 1, 2) = 'TI' then
        tipoTerm := TERM_TI
    else
    if copy (s, 1, 2) = 'HP' then
        tipoTerm := TERM_HP
    else
        tipoTerm := TERM_ANSI;

    sintVeloc (v);

fim:
    writeln;
    mensagem ('TNOK', 1);      {'OK'}
end;

{-------------------------------------------------------------}
{                   reconfigura
{-------------------------------------------------------------}

procedure reconfigura;
var v: integer;
    strModoFala: shortString;
begin
    salvaTela;
    textBackGround (BLACK);
    clrscr;

    writeln (pegaTextoMensagem ('TNMODFAL'));
    tamRotulosForm := 50;
    formCria;

    strModoFala := tabModos [modoFala];
    v := velocAtual;
    formCampoInt  ('TNVELFAL', pegaTextoMensagem ('TNVELFAL'), v);               {'Velocidade de fala'}
    formCampo     ('TNMODFAL', pegaTextoMensagem ('TNMODFA1'), strModoFala, 15); {'Modo: '}
    formCampoBool ('TNSOLET',  pegaTextoMensagem ('TNSOLET'),  soletrando);      {'Soletra digitação ? '}

    formEdita (true);

    if strModoFala = '' then strModoFala := ' ';
    case upcase (strModoFala[1]) of
        'L': modoFala := falaLynx;
        'V': modoFala := falaTudo;
        'C': modoFala := falaCalado;
        'M': modoFala := falaMudo;
    else
        modoFala := falaNormal;
    end;
    sintVeloc (v);
    guardaConfig (nomeComput);

    writeln;
    mensagem ('TNOK', 1);      {'OK'}

    clrscr;
    selectOemFont := not usaAcentos;
    restauraTela;
end;

end.

