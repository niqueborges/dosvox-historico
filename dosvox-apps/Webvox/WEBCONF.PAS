{-------------------------------------------------------------}
{
{    Webvox - Módulo de configuração
{
{    Autor: Jose Antonio Borges
{
{    Em 18/12/99
{
{-------------------------------------------------------------}

unit webConf;

interface
uses
    dvcrt, dvWin, sysUtils, dvInet, dvForm, winsock,
    miniReg,
    webUtil, webVars, webMsg, Windows;

function getMeusDownloads: string;
procedure configura;
procedure trocaLingua;

implementation

{--------------------------------------------------------}
{       Retorna a pasta Meus downloads
{--------------------------------------------------------}

function getMeusDownloads: string;
const
    SearchTree = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\';
var
    dirDocs: string;
begin
    if not regGetString (HKEY_CURRENT_USER, SearchTree+
        '{374DE290-123F-4565-9164-39C4925E467B}', dirDocs) then
        result := ''
    else
        result := dirDocs;
end;

{-------------------------------------------------------------}
{                   troca o sintetizador Sapi
{-------------------------------------------------------------}

procedure trocaLingua;
begin
    emPortug := not emPortug;
    if emPortug then
        begin
            mensagem ('WBLEORIG',1);    {Lendo com síntese original}
            sintReinic (velocAtual, usaSapi, tipoSapi1, vozSapi1, velSapi1, tomSapi1);
        end
    else
        begin
            mensagem ('WBLEALT',1);    {Lendo com a síntese alternativa}
            sintReinic (velocAtual, true, tipoSapi2, vozSapi2, velSapi2, tomSapi2);
        end;
end;

{-------------------------------------------------------------}
{                   configura o programa
{-------------------------------------------------------------}

procedure configura;
var
    vel: integer;
    s: string;
    clek: boolean;
    mf,  hProxy, xProxy: shortString;
    arqBuscador, dirBuscador: shortString;
    editor: shortString;

begin
    clrscr;
    writeln ('WEBVOX');
    mensagem ('WBSETCNF', 2);   {'Use as setas, editore as configurações e depois tecle ESC'}

    mf := modoFala;
    clek := upcase((sintAmbiente ('WEBVOX', 'CLEK') + 'S')[1]) = 'S';

    vel := obtemInt (sintAmbiente('WEBVOX', 'VELOCIDADE'), 0); //Neno era  velocAtual

    tamRotulosForm := 45;
    formCria;
    formCampoInt  ('WBVELFAL', pegaTextoMensagem('WBVELFAL'), vel);
                                {'Qual a velocidade de fala ? De 1 a 5 '}
    formCampoBool ('WBFALAPT', pegaTextoMensagem('WBFALAPT'), falandoPontuacao);
                                {'Fala pontuação ? '}
    formCampo     ('WBNIVINF', pegaTextoMensagem ('WBNIVINF'), mf, 1);
                                {'Nível textual, resumido, normal ou detalhado '}

    formCampoBool ('WBSONREC', pegaTextoMensagem('WBSONREC'), clek);
                                {'Sonorizar no download'}

    formCampoInt  ('WBTIPSAP', pegaTextoMensagem ('WBTIPSAP'), tipoSapi2);
                                {'Tipo SAPI (4 ou 5) da língua alternativa'}
    formCampoInt  ('WBSAPALT', pegaTextoMensagem ('WBSAPALT'), vozSapi2);
                                {'Voz sapi da língua alternativa'}
    formCampoInt  ('WBVELALT', pegaTextoMensagem ('WBVELALT'), velSapi2);
                                {'Velocidade da língua alternativa'}
    formCampoInt  ('WBTOMALT', pegaTextoMensagem ('WBTOMALT'), tomSapi2);
                                {'Tonalidade da língua alternativa'}

    formCampoBool ('WBCOMPXY', pegaTextoMensagem('WBCOMPXY'), comProxy);
                                {'Sua conexão utiliza um proxy?'}
    hProxy := hostProxy;
    formCampo     ('WBENDPXY', pegaTextoMensagem('WBENDPXY'), hProxy, 40);
                                {'Endereço do Proxy'}
    formCampoInt  ('WBPORPXY', pegaTextoMensagem('WBPORPSY'), portaProxy);
                                {'Porta do Proxy'}
    xProxy := arqExcProxy;
    formCampo     ('WBEXCPXY', pegaTextoMensagem('WBEXCPXY'), xProxy, 80);
                                {'Arquivo de excessões de proxy'}

    editor := sintAmbiente ('WEBVOX', 'EDITOR');
    if editor = '' then
        editor := sintAmbiente ('DOSVOX', 'MINIED');
    formCampo     ('WBEDITOR', pegaTextoMensagem('WBEDITOR'), editor, 128);
                                {'Editor de textos'}

    arqBuscador := sintAmbiente ('WEBVOX', 'ARQBUSCADOR');
    formCampo     ('WBCARQBU', pegaTextoMensagem('WBCARQBU'), arqBuscador, 128);
                                {'Arquivo de páginas do Buscador'}

    dirBuscador := sintAmbiente ('WEBVOX', 'DIRBUSCADOR');
    formCampo     ('WBCDIRBU', pegaTextoMensagem('WBCDIRBU'), dirBuscador, 128);
                                {'Diretório do Buscador'}

    dirDownload := sintAmbiente ('WEBVOX', 'DIRDOWNLOAD');
    formCampo     ('WBCDIRDW', pegaTextoMensagem('WBCDIRDW'), dirDownload, 255);
                                {'Diretório de downloads'}

    formEdita (true);

    if vel in [0..5] then
        begin
            sintFim;
            sintInic (vel, sintambiente ('WEBVOX', 'DIRWEBVOX'));
            sintGravaAmbiente ('WEBVOX', 'VELOCIDADE', intToStr(vel));
        end;

    sintGravaAmbiente ('WEBVOX', 'FALANDOPONTUACAO',      booleanToStr[falandoPontuacao]);

    modoFala := upcase((mf + 'N')[1]);
    sintGravaAmbiente( 'WEBVOX', 'MODOFALA', modoFala);
    case modoFala of
       'T', 'R':
              prepSonsTags ('');

       'N':   begin
                  s := sintAmbiente ('WEBVOX', 'AMBWEBTAGS');
                  if s = '' then
                    s := sintDirAmbiente + '\webtags.ini';
                  prepSonsTags (s);
              end;
       'D':   begin
                  s := sintAmbiente ('WEBVOX', 'AMBWEBTAGS2');
                  if s = '' then
                    s := sintDirAmbiente + '\webtags2.ini';
                  prepSonsTags (s);
              end;
    end;

    sintGravaAmbiente ('WEBVOX', 'CLEK',      booleanToStr[clek]);

    sintGravaAmbiente ('WEBVOX', 'TIPOSAPI',  intToStr(tipoSapi2));
    sintGravaAmbiente ('WEBVOX', 'VOZSAPI',   intToStr(vozSapi2));
    sintGravaAmbiente ('WEBVOX', 'VELOCSAPI', intToStr(velSapi2));
    sintGravaAmbiente ('WEBVOX', 'TOMSAPI',   intToStr(tomSapi2));

    sintGravaAmbiente ('WEBVOX', 'COMPROXY',      booleanToStr[comProxy]);
    hostProxy := hProxy;
    sintGravaAmbiente ('WEBVOX', 'ENDERPROXY',    hostProxy);
    sintGravaAmbiente ('WEBVOX', 'PORTAPROXY',    intToStr(portaProxy));
    arqExcProxy := xProxy;
    sintGravaAmbiente ('WEBVOX', 'SITESSEMPROXY', arqExcProxy);

    sintGravaAmbiente ('WEBVOX', 'EDITOR',      editor);
    sintGravaAmbiente ('WEBVOX', 'ARQBUSCADOR', arqBuscador);
    sintGravaAmbiente( 'WEBVOX', 'DIRBUSCADOR', dirBuscador);

    if uppercase(dirDownload) = '*DOWNLOADS' then dirDownload := getMeusDownloads;
    if not DirectoryExists (dirDownload)  then dirDownload := '';
    sintGravaAmbiente( 'WEBVOX', 'DIRDOWNLOAD', dirDownload);
end;

begin
end.
