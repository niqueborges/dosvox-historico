{--------------------------------------------------------------}
{
{   PPTVOX - exibidor interativo de apresentações
[
{   Inicializadores
{
{   Em 11/06/2015
{
{--------------------------------------------------------------}

unit ppinic;

interface
uses
  dvcrt,
  dvwin,
  dvjpeg,
  dvForm,
  dvArq,
  dvExec,
  dvWav,
  dvMacro,
  dvhora,
  videoVox,
  windows,
  messages,
  classes,
  graphics,
  SysUtils,
  ppvars,
  ppmsg,
  ppdesen,
  ppnavega,
  ppjanela,
  ppEdita,
  ppArq,
  ppCria,
  ppFolhei,
  ppConf,
  ppExport,
  ppAuto,
  ppEstilo,
  ppImport;

procedure inicializaVariaveis;
procedure inicializaConfigPlayer;
procedure inicializaCoresEFontes;
function pegaParamLinhaDeComando: boolean;

implementation

{--------------------------------------------------------}
{                 Inicializando as Variaveis
{--------------------------------------------------------}

procedure inicializaVariaveis;
begin
    nomeArq := '';
    nomeEstilo := '';
    nomeProg := '';
    debugar:= false;
    capturouEstilo:= false;

    ativFigSom:= false; // No caso do PPTVOX será sempre false;

    apresentando:= false;

    criandoSlide:= false;
    salvarSlide:= false;

    tempoSlide:= 0;
    tempoLinha:= 0;
    apresentaAuto:= false;
    repeteAuto:= false;
    leAuto:= false;
    primeiraVez:= true;

    tempoApresentacao:=0;

    exportandoPPT:= FALSE;

    tocarSlide:= true;
    tocarFundoMusical:= true;
    musicaDeFundo:= '';
    informarFoto:= true;
    ativarPlayer:= true;
end;

{--------------------------------------------------------}
{        pega os parâmetros do player em dosvox.ini
{--------------------------------------------------------}

procedure inicializaConfigPlayer;
begin
    dirEstilos:= sintAmbiente ('PPTVOX', 'DIRPADRAO');
    if dirEstilos = '' then
        dirEstilos:= 'c:\winvox\PPTVOX';

    e_player:= sintAmbiente ('PPTVOX', 'PLAYER');
    if e_player = '' then
        e_player:= 'WMPLAYER';

    trocSlides := (sintAmbiente('PPTVOX', 'TROCADESLIDES'));
    trocLinhas := (sintAmbiente('PPTVOX', 'TROCADELINHAS'));
    primSlide  := (sintAmbiente('PPTVOX', 'PRIMEIROSLIDE'));
    ultSlide   := (sintAmbiente('PPTVOX', 'ULTIMOSLIDE'));
    ultLinha   := (sintAmbiente('PPTVOX', 'ULTIMALINHA'));

    if pos ('.', trocSlides) <> 0 then
        delete (trocSlides, pos ('.', trocSlides), length (trocSlides));
    if pos ('.', trocLinhas) <> 0 then
        delete (trocLinhas, pos ('.', trocLinhas), length (trocLinhas));
    if pos ('.', primSlide) <> 0 then
        delete (primSlide, pos ('.', primSlide), length (primSlide));
    if pos ('.', ultSlide) <> 0 then
        delete (ultSlide, pos ('.', ultSlide), length (ultSlide));
    if pos ('.', ultLinha) <> 0 then
        delete (ultLinha, pos ('.', ultLinha), length (ultLinha));

end;

{--------------------------------------------------------}
{       Inicialização das cores e das fontes
{--------------------------------------------------------}

procedure inicializaCoresEFontes;
var erro: integer;
begin
    // Relativo ao fundo e cor da fonte

    figuraDeFundo:= (sintAmbiente('PPTVOX', 'FIGURADEFUNDO'));
    if not existeArq(trim(figuraDeFundo)) then
        figuraDeFundo := fundoPadrao;

    corLetra:= (sintAmbiente('PPTVOX', 'CORDALETRA'));
    if corLetra = '' then
        corLetra:= 'PRETA';

    // Relativo às fontes

    f_tit:= (sintAmbiente('PPTVOX', 'FONTETITULO'));
    if f_tit = '' then f_tit:= 'Times New Roman';
    f_lin:= (sintAmbiente('PPTVOX', 'FONTELINHA'));
    if f_lin = '' then f_lin:= 'Arial';

    val (sintAmbiente('PPTVOX', 'TAMTITULO'), t_tit, erro);
    if erro <> 0 then t_tit:= 36;
    val (sintAmbiente('PPTVOX', 'TAMLINHA'), t_lin, erro);
    if erro <> 0 then t_lin:= 24;
end;

{--------------------------------------------------------}
{           Pega parâmetros da linha de comando
{--------------------------------------------------------}

function pegaParamLinhaDeComando: boolean;
var s: string;
    erro: integer;
begin
    apresentando:= true;
    apresentaAuto:= true;

    nomeArq:= paramStr(1);

    s:= paramStr(2);
    val (s, tempoSlide, erro);
    if erro <> 0 then
        tempoSlide:= 0;

    s:= upperCase(paramStr(3));
    if s = 'R' then
        repeteAuto:= true;

    s:= paramStr(4);
    val (s, tempoLinha, erro);
    if erro <> 0 then
        tempoLinha:= 0
    else
        begin
            leAuto:= true;
            primeiraVez:= true;
        end;

    result := TrocaDir(dirPPX);
end;

end.

