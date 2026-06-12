{--------------------------------------------------------}
{                  Módulo de configuração
{--------------------------------------------------------}

unit brConfig;
interface
uses dvCrt, dvWin, dvForm, windows, sysutils, brVars, brMsg, brUtil;

procedure pedeParametros;
procedure assumeParamDefaults;

implementation

{--------------------------------------------------------}
{            processa arquivo de configuracao
{--------------------------------------------------------}

{--------------------------------------------------------}
{                  converte lido hexa
{--------------------------------------------------------}

function cnvhexa (c1, c2: char): byte;
var v1, v2: integer;
begin
    c1 := upcase (c1);
    c2 := upcase (c2);

    if c1 >= 'A' then
        v1 := ord (c1) - ord ('A') + 10
    else
        v1 := ord (c1) - ord ('0');

    if c2 >= 'A' then
        v2 := ord (c2) - ord ('A') + 10
    else
        v2 := ord (c2) - ord ('0');

    cnvhexa := (v1 shl 4) or v2;
end;

{--------------------------------------------------------}
{                 pede parametros de impressao
{--------------------------------------------------------}

procedure pedeParametros;
var
    tituloEmAmbosLados: boolean;
    nomeSaiAux: shortString;
begin
    tituloEmAmbosLados := tipoCabec = 2;

    tamRotulosForm := 51;

    gotoxy (1,5);
    formCria;
    nomeSaiAux := nomeSai;
    if nomeSaiAux = '' then nomeSaiAux := 'LPT1';
    formCampo     ('BRARQIMP', pegaTextoMensagem('BRARQIMP'), nomeSaiAux, 144);    {'Nome do dispositivo, sugiro PRN'}
    formCampoInt  ('BRNCOP',   pegaTextoMensagem('BRNCOP'), ncopias);              {'Quantas cópias ? '}
    formCampoInt  ('BRLPPAG',  pegaTextoMensagem('BRLPPAG'), maxlin);              {'Quantas linhas por pagina (0 para nao paginar) ? '}
    formCampoInt  ('BRCPLIN',  pegaTextoMensagem('BRCPLIN'), maxCarac);            {'Quantos caracteres por linha ? '}
    formCampoInt  ('BRPAGINI', pegaTextoMensagem('BRPAGINI'), paginic);            {'Página inicial (sugiro 1): '}
    formCampoInt  ('BRPAGFIN', pegaTextoMensagem('BRPAGFIN'), pagfinal);           {'Página final (sugiro 9999): '}
    formCampoInt  ('BRNUMINI', pegaTextoMensagem('BRNUMINI'), numinic);            {'Numero a imprimir na pagina inicial: '}
    formCampoBool ('BRFAZTIT', pegaTextoMensagem('BRFAZTIT'), comTitulo);          {'Deseja titulos e numeração ? '}
    formCampo     ('BRTIT',    pegaTextoMensagem('BRTIT'), titulo, 80);            {'Informe o título'}
    formCampoBool ('BRNUMORG', pegaTextoMensagem('BRNUMORG'), numeraOrig);         {'Apresenta numeração original?'}
    formCampoBool ('BRAUTOJU', pegaTextoMensagem('BRAUTOJU'), autoFormata);        {'Deseja auto-reformatação para Braille (s/n) ? '}
    formCampoBool ('BRFREVER', pegaTextoMensagem('BRFREVER'), frenteVerso);        {'Frente e verso (s/n) ? '}
    formCampoBool ('BRDOEDIT', pegaTextoMensagem('BRDOEDIT'), veioDoEdit);         {'Texto foi digitado no EDIT do DOS ? '}
    formCampoBool ('BRTITFV',  pegaTextoMensagem('BRTITFV'), tituloEmAmbosLados);  {'Título em ambos os lados: '}
    formCampoBool ('BRAFASTA', pegaTextoMensagem('BRAFASTA'), afastaCabecPar);     {'Afasta para a direita os cabeçalhos pares ? '}
    formCampoBool ('BRSEPARA', pegaTextoMensagem('BRSEPARA'), separaSilabas);      {'Separa sílabas ao fim da linha ?'}
    formCampoBool ('BRINGLES', pegaTextoMensagem('BRINGLES'), textoIngles);        {'Maiúsculas e grifo estilo inglês ?'}
    formCampoBool ('BRANTIGO', pegaTextoMensagem('BRANTIGO'), usaBrailleAntigo);   {'Usa Braille Antigo ?'}

    formEdita (true);

    nomeSai := nomeSaiAux;
    if nomeSai = '' then nomesai := 'PRN';
    sintGravaAmbiente('BRAIVOX', 'DISPSAIDA', nomeSai);

    if not comTitulo then
        tipoCabec := 0
    else
        tipoCabec := 1;
    if frenteVerso and comTitulo and tituloEmAmbosLados then
        tipoCabec := 2;

    cabecIngles := textoIngles;

    if maxlin <= 0 then
        begin
            paginando := false;
            maxlin := 30000;
        end
    else
        begin
            paginando := true;
            if paginic <= 0  then paginic := 1;
            if pagfinal <= 0 then pagfinal := 9999;
            if numinic <= 0 then numinic := 1;
        end;

    carregaTabBraille;

    mensagem ('BRCNFDEF', 1);   {'Use a configuração avançada do Dosvox para mudar definitivamente.'}
    mensagem ('BRCNFDF2', 1);   {'Para configurar, edite ali a seção BRAIVOX.'}
end;

{--------------------------------------------------------}
{              assume parametros default
{--------------------------------------------------------}

procedure assumeParamDefaults;
var s: string;
    i, erro, linhasPorMinuto: integer;
begin
    maxlin := 28;
    maxcarac := 34;

    frenteVerso := false;
    paginando := true;
    autoFormata := true;
    comTitulo := true;
    veioDoEdit := false;

    numinic := 1;
    ncopias := 1;
    paginic := 1;
    pagfinal := 9999;
    titulo := '';
    tempoLinha := 0;
    pagOrig := 0;
    tiraBrancasInicioPag := true;

    textoIngles := false;
    cabecIngles := false;

    nomeSai := sintAmbiente ('BRAIVOX', 'DISPSAIDA');
    if nomeSai = '' then nomeSai := 'LPT1';

    s := sintAmbiente ('BRAIVOX', 'COLUNAS');
    val (s, i, erro);
    if erro = 0 then maxCarac := i;

    s := sintAmbiente ('BRAIVOX', 'LINHAS');
    val (s, i, erro);
    if erro = 0 then maxLin := i;

    s := sintAmbiente ('BRAIVOX', 'FRENTEVERSO');
    frenteVerso := (s <> '') and (upcase (s[1]) = 'S');

    s := sintAmbiente ('BRAIVOX', 'AUTOFORMATA');
    autoFormata := (s <> '') and (upcase (s[1]) = 'S');

    s := sintAmbiente ('BRAIVOX', 'TEXTODOEDIT');
    veioDoEdit := (s <> '') and (upcase (s[1]) = 'S');

    s := sintAmbiente ('BRAIVOX', 'TITULA');
    comTitulo := (s <> '') and (upcase (s[1]) = 'S');

    s := sintAmbiente ('BRAIVOX', 'PAGINA');
    paginando := (s <> '') and (upcase (s[1]) = 'S');

    s := sintAmbiente ('BRAIVOX', 'NUMERAORIG');
    numeraOrig := (s <> '') and (upcase (s[1]) = 'S');

    s := sintAmbiente ('BRAIVOX', 'TITULOATRAS');
    if (s <> '') and (upcase (s[1]) = 'S') then tipoCabec := 2
                                           else tipoCabec := 1;
    s := sintAmbiente ('BRAIVOX', 'AFASTACABECPAR');
    afastaCabecPar := (s <> '') and (upcase (s[1]) = 'S');

    s := sintAmbiente ('BRAIVOX', 'TEXTOINGLES');
    textoIngles := (s <> '') and (upcase (s[1]) = 'S');

    s := sintAmbiente ('BRAIVOX', 'SEPARASILABAS');
    separaSilabas := (s <> '') and (upcase (s[1]) = 'S');

    s := sintAmbiente ('BRAIVOX', 'LINHASPORMINUTO');
    val (s, linhasPorMinuto, erro);
    if (erro = 0) and (linhasPorMinuto <> 0) then
        tempoLinha := trunc (60000.0 / linhasPorMinuto)
    else
        tempoLinha := 0;

    s := sintAmbiente ('BRAIVOX', 'USABRAILLEANTIGO');
    usaBrailleAntigo := (s <> '') and (upcase (s[1]) = 'S');

    nomeAmBCode  := sintAmbiente ('BRAIVOX', 'AMBCODE');
    if nomeAmbCode = '' then
        nomeAmbCode := sintAmbiente ('DOSVOX', 'PGMDOSVOX') + '\ambcode.cfg';

    nomeAmBCode2 := sintAmbiente ('BRAIVOX', 'AMBCODE2');
    if nomeAmbCode2 = '' then
        nomeAmbCode2 := sintAmbiente ('DOSVOX', 'PGMDOSVOX') + '\ambcode2.cfg';

    if not carregaTabBraille then halt;
end;

end.
