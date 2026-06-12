{--------------------------------------------------------}
{
{     Monitvox - módulo de variáveis
{     Autor: Antonio Borges
{     Em 23/3/2003
{
{--------------------------------------------------------}

unit mvvars;

interface
uses Windows, Messages, oleacc;

const
    versao = '2.1b';
    
var
    monitConfigs: string;

type
    HWINEVENTHOOK = DWORD;

    TEvento = record
        ev_event: DWORD;
        ev_hwndMsg: HWND;
        ev_idObject: DWORD;
        ev_idChild: DWORD;
    end;

const
    ACORDA = WM_USER+2;

var
    filaEventos: array [0..100] of TEvento;
    pinsEvento, pretEvento: integer;
    hevHook: HWINEVENTHOOK;

var
    idObject: DWORD;
    idChild: DWORD;
    piacc: IAccessible;
    vId, vob: variant;
    hwndMsg: HWND;
    xob, yob, dxob, dyob: integer;
    xobant, yobant: integer;

var
    editorando: boolean;
    monitorando: boolean;
    lendoMouse: boolean;
    mostrarInfo: integer;
    alterandoLinha: boolean;
    suspenso: boolean;

    codTipo, codTipoAnt: integer;
    tipo, nome, estado, valor: string;
    numFilhos: longint;
    tipoAnt, nomeAnt, estadoAnt, valorAnt: string;
    mouseAnt: Tpoint;
    evento: integer;

    ultJan: HWND;
    nomeUltJan: string;
    xultJan, yultJan: integer;

    arq: textFile;
    salvaMouse: TPoint;
    cortaFala: boolean;

    veloc, tipoFalaSapi, vozSapi, velSapi, tomSapi: integer;
    usaSapi: boolean;
    lerClipboard, lerStatus,
    posicionarRapido, registrarNome: boolean;

const
    tempoMaxPiolhice = 25;
var
    janelaPiolhice: HWND;
    piolhando: boolean;
    tempoPiolhice: integer;
    bip: boolean;

implementation

end.
