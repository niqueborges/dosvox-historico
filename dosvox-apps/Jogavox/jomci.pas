{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo controle da Mídia
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit jomci;

interface
uses dvcrt, sysUtils, windows, mmsystem;

function enviaComandoMCI (s: string): integer;

procedure iniciaMciLugar (nomeArq: string);
procedure terminaMciLugar;

procedure iniciaMciSlide (nomeArq: string);
function tocandoMciSlide: boolean;
procedure terminaMciSlide;

var erroMci: string;
    retornoMci: string;

implementation

var tocando: boolean;

procedure myMCICallback (Window: HWnd; WParam: WPARAM; LParam: LPARAM);
begin
    tocando := false;
end;

function enviaComandoMCI (s: string): integer;
var p, retorno: array [0..255] of char;
    erro: integer;
begin
    strPcopy (p, s);
    erro := mciSendString (p, retorno, 255, crtWindow);
    if erro <> 0 then
        mciGetErrorString (erro, p, 255)
    else
        erroMci := '';
    retornoMci := strPas (retorno);
    result := erro;
end;

procedure iniciaMciLugar (nomeArq: string);
var dir: string;
begin
    nomeArq := trim(nomeArq);
    if nomeArq = '' then exit;

    if pos ('\', nomeArq) = 0 then
        begin
            getDir (0, dir);
            if dir [length(dir)] <> '\' then dir := dir + '\';
            nomeArq := dir + nomeArq;
        end;

    nomeArq := '"' + nomeArq + '"';

    enviaComandoMci ('open ' + nomeArq + ' alias midiaLugar');
    enviaComandoMci ('play midiaLugar');
end;

procedure terminaMciLugar;
begin
    enviaComandoMci ('stop midiaLugar');
    enviaComandoMci ('close midiaLugar');
end;

procedure iniciaMciSlide (nomeArq: string);
var dir, ext: string;

    procedure preparaParamVideo;
    begin
        // enviaComandoMci ('where midiaSlide source');  // saber tamanho
        enviaComandoMci ('window midiaSlide handle ' + intToStr(crtwindow));
        enviaComandoMci ('put midiaSlide destination');
    end;

begin
    nomeArq := trim(nomeArq);
    if nomeArq = '' then exit;

    ext := upperCase(copy (nomeArq, lastDelimiter ('.', nomeArq)+1, 999));

    if pos ('\', nomeArq) = 0 then
        begin
            getDir (0, dir);
            if dir [length(dir)] <> '\' then dir := dir + '\';
            nomeArq := dir + nomeArq;
        end;

    nomeArq := '"' + nomeArq + '"';

    if enviaComandoMci ('open ' + nomeArq + ' alias midiaSlide') = 0 then
        begin
            tocando := true;
            MCICallback := myMciCallback;
            hasMCICallback := true;

            if (ext = 'MPG') or (ext = 'MPEG') or (ext = 'MP4') or
               (ext = 'AVI') or (ext = 'WMV') then
                   preparaParamVideo;

            enviaComandoMci ('play midiaSlide notify');
        end
    else
        tocando := false;
end;

procedure terminaMciSlide;
begin
    hasMCICallback := false;
    tocando := false;
    enviaComandoMci ('stop midiaSlide');
    enviaComandoMci ('close midiaSlide');
end;

function tocandoMciSlide: boolean;
begin
    result := tocando;
end;

end.


