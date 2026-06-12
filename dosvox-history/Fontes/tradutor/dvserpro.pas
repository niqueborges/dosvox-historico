{------------------------------------------------------------}
{   Rotinas de tratamento de fala SAPI
{   Autor: José Antonio Borges
{   Em 9/10/2000
{------------------------------------------------------------}

unit dvserpro;

interface

uses
    dvcrt, dvsapglb, sysutils, uttsLiane, windows, messages, minireg;

function sapiInic (voz, veloc, tom: integer; nomeArq: string): boolean;
procedure sapiFim;
procedure sapiFala (s: string);
procedure sapiFalaPchar (p: pchar);
function sapiAtivo (masc: byte): boolean;
// parametro masc não usado: mantido por compatibilidade com outros SAPI
procedure sapiReset;
procedure sapiPegaParam (var param: TParamVoz);
procedure sapiMudaParam (param: TParamVoz);
procedure sapiInfo (nvoz: integer; var paramSapi: TInfoSAPI);
function sapiNumVozes: integer;

var
    sapiPosFalada: DWORD;

implementation
uses uttsUtils, dvWin;

var
    dir, base, mbrola_db, arq_regras, arq_excessoes, arq_abrev,
    arq_prosodia, arq_listadif: string;

{----------------------------------------------------------}

function sapiInic (voz, veloc, tom: integer; nomeArq: string): boolean;
begin
    liane_setOutputFile(nomeArq);
    result := liane_open (mbrola_db,
              arq_regras, arq_excessoes, arq_abrev, arq_prosodia, arq_listadif);

    liane_config (0.8 - (veloc/15) , (tom+11) / 11);
end;

{----------------------------------------------------------}

procedure sapiFim;
begin
    while sapiAtivo (1) do delay (500);
    sapiReset;
    liane_close;
end;

{----------------------------------------------------------}

procedure sapiFalaPchar (p: pchar);
begin
    sapiFala (strPas(p));
end;

{----------------------------------------------------------}

procedure sapiFala (s: string);
begin
    liane_speak(s);
    postMessage (crtWindow, WM_USER+1956, 0, 0);
end;

{----------------------------------------------------------}

function sapiAtivo (masc: byte): boolean;
var ativo: boolean;
begin
    ativo := liane_isSpeaking;
    if keypressed {and ativo} then
        begin
            sapiReset;
            ativo := false;
        end;

    postMessage (crtWindow, WM_USER+1956, 0, 0);
    sapiAtivo := ativo;
end;

{----------------------------------------------------------}

procedure sapiReset;
begin
    liane_stop;
    postMessage (crtWindow, WM_USER+1956, 0, 0);
end;

{----------------------------------------------------------}

procedure sapiPegaParam (var param: TParamVoz);
begin
    sapiReset;
    with param do
          begin
              tipoSapi := 3;
              voz := 1;
              velocidade := round((0.8-liane_durationRate) * 15);
              tom := round(liane_pitchRate*10) - 10;

              minVeloc := -10;
              maxVeloc := 10;
              minTom := -10;
              maxTom := 10;
          end;
end;

{----------------------------------------------------------}

function sapiNumVozes: integer;
begin
    sapiNumVozes := 1;
end;

{----------------------------------------------------------}

procedure sapiMudaParam (param: TParamVoz);
begin
    sapiReset;
    with param do
        begin
            if (velocidade > 10) or (velocidade < -10) then velocidade := 0;
            if (tom > 10) or (tom < -10) then tom := 3;
            liane_config (0.8 - (velocidade/15) , (tom+10) / 10);
        end;
end;

{----------------------------------------------------------}

procedure sapiInfo (nvoz: integer; var paramSapi: TInfoSAPI);
const
    naoDisponivel: string = 'Não disponível';
begin
    sapiReset;
    with paramSapi do
        begin
            voz := 1;
            nomeVoz   := 'Liane';
            lingua    := 1046;
            dialeto   := 'Carioca';
            produtor  := 'Serpro Brasil';
            sexo      := 1;
            idade     := 25;
            estilo    := naoDisponivel;
            modo      := naoDisponivel;
            produto   := 'LianeTTS';
        end;
end;

begin
    mbrola_db := sintAmbiente ('LIANETTS', 'MBROLA_DB', 'br4');
    dir := sintAmbiente ('LIANETTS', 'DIR');
    base := sintAmbiente ('LIANETTS', 'BASE');
    if dir = '' then
        dir := getDLLPath_MBR + '\';
    if base = '' then
        base := 'portug';

    if dir[length(dir)] <> '\' then
        dir := dir + '\';   {   Em caso de vir do Dosvox.ini sem a raiz   }

    if not fileExists (dir+base+'.nrl') then
         dir := dir+'lianetts\';

    arq_regras :=    dir + base + '.nrl';
    arq_excessoes := dir + base + '.exc';
    arq_abrev :=     dir + base + '.abr';
    arq_prosodia :=  dir + base + '.pro';
    arq_listadif :=  dir + base + '.dfn';
end.
