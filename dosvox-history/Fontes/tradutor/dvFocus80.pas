{--------------------------------------------------------}
{
{     Funções da Linha Braille Focus80
{
{     Autores: José Antonio Borges
{              Júlio Tadeu Silveira
{
{     Versão 0.0: Em Janeiro/2014
{     Versão 1.0: Em Agostro/2019
{
{    Modificado por Patrick Barboza
{    Em Julho/Agosto/2024
{
{--------------------------------------------------------}

unit dvFocus80;

interface

uses
    dvcrt, dvwin, dvbrunif,
    SysUtils, Windows, messages;

var
    focusProductName: string  = '';
    focusVersion:     string  = '';
    focusNumCells:    integer = -1;

{--------------------------------------------------------}
{       Debug specific.
{--------------------------------------------------------}
var
    wPar: WPARAM;
    lPar: LPARAM;

{--------------------------------------------------------}

function  focus80_Open: boolean;
procedure focus80_Write (s: string);
procedure focus80_EnableReading (habilitaTeclado: boolean);
procedure focus80_Close;

implementation

const
    Wp_x01_GenKeys   = $00000001;
    Wp_x02_Disconn   = $00000002;
    Wp_x03_RocBars   = $00000003;

    Lp_x03_GenKeysUp = $00000003;
    Lp_x00_RocBarsUp = $00000000;

const
    {* Teclas/botões - vista superior: WPARAM = $00000001*}

    Lp_LefNavUpx0105 = $00000105;   Lp_LefNavDnx0905 = $00000905;
    Lp_RigNavUpx1905 = $00001905;   Lp_RigNavDnx1105 = $00001105;

    {** Códigos depois do shr 8 - todos são seguidos de $03 **}

    LefModex0100  = $000100;
    RigModex0200  = $000200;

    Dot1x01 = $000001;   Dot2x02 = $000002; Dot3x04 = $000004;
    Dot4x08 = $000008;   Dot5x10 = $000010; Dot6x20 = $000020;
    Dot7x40 = $000040;   Dot8x80 = $000080;

    Dots12   = Dot1x01 or Dot2x02;
    Dots123  = Dot1x01 or Dot2x02 or Dot3x04;
    Dots1256 = Dot1x01 or Dot2x02 or Dot5x10 or Dot6x20;
    Dots13   = Dot1x01 or Dot3x04;
    Dots134  = Dot1x01 or Dot3x04 or Dot4x08;
    Dots15   = Dot1x01 or Dot5x10;

    Dots25   = Dot2x02 or Dot5x10;
    Dots2345 = Dot2x02 or Dot3x04 or Dot4x08 or Dot5x10;

    Dots45   = Dot4x08 or Dot5x10;
    Dots456  = Dot4x08 or Dot5x10 or Dot6x20;
    Dots46   = Dot4x08 or Dot6x20;

    Dots78   = Dot7x40 or Dot8x80;                          { $C0 => ESC }

    KeysMaskxFFFF = $00FFFF;
    Spacex8000    = $008000;                                {* 00:80:00:03 *}

const
    {* Teclas/botões - vista frontal:    * WPARAM = $00000001 (exceto RocBars) *}
    {
    {   Focus 80 Front View
                                                    +-----------+
                                                    | SPACEBAR  |
    +-----------+-----------+-----------+-----------+-----------+
    |    <<     |   ====    |     O     | ==== ==== |    []     |
    +-----------+-----------+-----------+-----------+-----------+
    | LefPanBtn | LefRocBar | LefSelBtn | LefPanRoc | LefShfkey |
    +-----------+-----------+-----------+-----------+-----------+

    +-----------+
    | SPACEBAR  |
    +-----------+-----------+-----------+-----------+-----------+
    |    []     | ==== ==== |     O     |   ====    |    >>     |
    +-----------+-----------+-----------+-----------+-----------+
    | RigShfkey | RigPanRoc | RigSelBtn | RigRocBar | RigPanBtn |
    +-----------+-----------+-----------+-----------+-----------+
}

    Lp_LefRocBarUp  = $00000010;   {* WPARAM = $00000003 *}
    Lp_LefRocBarDn  = $00000020;   {* WPARAM = $00000003 *}
    Lp_RigRocBarUp  = $00000040;   {* WPARAM = $00000003 *}
    Lp_RigRocBarDn  = $00000080;   {* WPARAM = $00000003 *}

    {** Códigos depois do shr 8 - todos são seguidos de $03 **}

    LefPanBtn    = $001000;
    LefSelBtn    = $010000;
    LefPanRocUp  = $100000;
    LefPanRocDn  = $200000;

    LefShift     = $000400;  {* 00:04:00:03 *}
    RigShift     = $000800;  {* 00:08:00:03 *}

    RigPanRocUp  = $400000;
    RigPanRocDn  = $800000;
    RigSelBtn    = $020000;
    RigPanBtn    = $002000;


{--------------------------------------------------------}
const
    LPx00_ARROW = $00;
    LPx03_CHAR  = $03;
    LPx04_SEL   = $04;
    LPx05_WHEEL = $05;
    LPx07_ALL   = $07;

    CR   = #$0D;
    LF   = #$0A;
    CRLF = CR+LF;

var
    hBrlLib:    THandle;
    hbrl:       THandle;
    brNumCells: integer;

{--------------------------------------------------------}
{       Focus80 specific.
{--------------------------------------------------------}
var
    fbOpen: function (port: pchar; windowToCallback: hWnd; wMsg: longint): THandle; stdcall;
    fbGetCellCount: function (h: THandle): integer; stdcall;
    fbWrite: procedure (h: THandle; seila: integer; nbytes: integer; cells: pchar); stdcall;
    fbClose: procedure (h: THandle); stdcall;
    fbConfigure: procedure (h: THandle; config: integer); stdcall;
    fbGetDisplayName: procedure (h: THandle; buf: pchar; bufSize: integer); stdcall;
    fbGetFirmwareVersion: procedure (h: THandle; buf: pchar; bufSize: integer); stdcall;
    fbBeep: procedure (h: THandle); stdcall;

procedure getDllReferences (hlib: THandle);
begin
    fbOpen := getProcAddress(hlib, '_fbOpen@12');
    fbGetCellCount := getProcAddress(hlib, '_fbGetCellCount@4');
    fbWrite := getProcAddress(hlib, '_fbWrite@16');
    fbClose := getProcAddress(hlib, '_fbClose@4');
    fbConfigure := getProcAddress(hlib, '_fbConfigure@8');
    fbGetDisplayName := getProcAddress(hlib, '_fbGetDisplayName@12');
    fbGetFirmwareVersion := getProcAddress(hlib,  '_fbGetFirmwareVersion@12');
    fbBeep := getProcAddress(hlib, '_fbBeep@4');
end;

var
    buf: array [0..80] of char;
    acumDot: integer;

{-------------------------------------------------------}
{       CallBack: versoes de depuração e oficial.
{-------------------------------------------------------}

procedure focus80_BrailleKbdCallback (Window: HWnd;
                              WParam: WPARAM; LParam: LPARAM;
                              var key1, key2: char);
var
    bits:   integer;

begin
{$IFDEF DEBUG}
    wPar := wParam;
    lPar := lParam;
{$ENDIF}
    key1 := #0;
    key2 := #0;
    if not (WParam in [Wp_x01_GenKeys,Wp_x03_RocBars]) then
        begin
            key1 := '?';
            exit;
        end;
{$IFDEF DEBUG}
    exit;
{$ELSE}
    if WParam = Wp_x03_RocBars then
        begin
            case LParam of
                Lp_LefRocBarUp, Lp_RigRocBarUp: key2 := CIMA;
                Lp_LefRocBarDn, Lp_RigRocBarDn: key2 := BAIX;
            end;
            exit;
        end;

    {* Neste ponto, WParam = Wp_x01_GenKeys *}


    case LParam of

        Lp_LefNavUpx0105, Lp_RigNavUpx1905: begin
                                                key2 := CIMA;
                                                exit;
                                            end;
        Lp_LefNavDnx0905, Lp_RigNavDnx1105: begin
                                                key2 := BAIX;
                                                exit;
                                            end;
        Lp_x03_GenKeysUp:
            begin
                if (acumDot and KeysMaskxFFFF) <> 0 then
                    begin
                        case acumDot of
                            Spacex8000: key1 := ' ';
                            Dot7x40:    key1 := BS;
                            Dot8x80:    key1 := CR;
                            Dots78:     key1 := ESC;
                        else
                            if      (acumDot and LefModex0100) <> 0 then
                                key2 := HOME
                            else if (acumDot and RigModex0200) <> 0 then
                                key2 := TEND
                            else if (acumDot and Spacex8000) <> 0 then
                                key1 := chr(ord(tabAscii2[acumDot and $3F]) and $1F)
                            else
                                key1 := tabAscii2 [acumDot];
                        end;
                        acumDot := 0;
                    end;
            end;
        else
            bits := lparam shr 8;
            if bits <> 0 then
                acumDot := acumDot or bits
    end;
{$ENDIF}
end;

(*

{-------------------------------------------------------}

procedure focus80_BrailleKbdCallback (Window: HWnd;
                                      WParam: WPARAM; LParam: LPARAM;
                                      var key1, key2: char);
const
    FB_INPUT      = 1;
    FB_DISCONNECT = 2;

    FB_ARROW = $00;
    FB_CHAR  = $03;
    FB_SEL   = $04;
    FB_WHEEL = $05;
    FB_ALL   = $07;

    CR = #0D;
    LF = #0A;

var
    bits:   integer;
begin
    key1 := #0;
    key2 := #0;

    if WParam = FB_DISCONNECT then
        begin
            key1 := '?';
            exit;
        end;

    case (LParam and FB_ALL) of

        FB_ARROW:
            begin
                bits := (LParam shr 4) and $F;  // Setas
                case bits of
                    1: key2 := CTLPGUP;
                    2: key2 := CTLPGDN;
                    4: key2 := CTLUP;
                    8: key2 := CTLDOWN;
                end;
            end;

        FB_CHAR:             // Letras comuns
            begin
                bits := LParam shr 8;
                if bits <> 0 then
                    acumDot := acumDot or bits
                else
                    begin
                        if      (acumDot and $c0 ) = $c0 then key1 := ESC
                        else if (acumDot and $80 ) = $80 then key1 := CR
                        else if (acumDot and $40 ) = $40 then key1 := LF
                        else if (acumDot and $100) <>  0 then key2 := HOME
                        else if (acumDot and $200) <>  0 then key2 := TEND

                        else if (acumDot and $8000) <> 0 then
                            begin
                                // espaço ou controle
                                if acumDot = $8000 then
                                     key1 := ' '
                                else
                                     key1 := chr(ord(tabAscii2[
                                                acumDot and $3f]) and $1f);
                            end
                        else
                            key1 := tabAscii2 [acumDot];
                        acumDot := 0;
                    end;
            end;

        FB_SEL:       ;   // Teclinhas de seleção
        FB_WHEEL:         // Rodinha ou push button duplo lateral
            begin
                bits := LParam shr 8;
                case bits of
                     1: key2 := CTLESQ;
                     9: key2 := CTLDIR;
                    25: key2 := ESQ;
                    17: key2 := DIR;
                end;
            end;
    end;
end;
*)

{-------------------------------------------------------}

function focus80_Open: boolean;
begin
    result := false;

    hBrlLib := LoadLibrary('fsbrldspapi.dll');
    if hBrlLib <= 0 then exit;

    if brailleKbdMsg = 0 then
        exit;
    getDllReferences (hBrlLib);
    hbrl := fbOpen('USB', CrtWindow, brailleKbdMsg);
    if hbrl = 0 then exit;

    brNumCells    := fbGetCellCount(hbrl);
    focusNumCells := brNumCells;
    if focusNumCells <= 0 then exit;

    fbGetDisplayName (hbrl, buf, 80);
    focusProductName := strPas(buf);
    focusProductName := focusProductName + ' ' + intToStr (focusNumCells) + ' ' + 'Blue';
    fbGetFirmwareVersion (hbrl, buf, 80);
    focusVersion := strPas(buf);

    //Patrick
    //Definição das variáveis linhaBraillePresente e linhaBrailleTecAtivo
    //São feitas na unit dvBrlCliente
    focus80_EnableReading(true);   //Patrick. Originalmente em dvCrt. Inicialização sempre ativará o teclado
    result := true;
end;

procedure focus80_Close;
begin
    hasBrailleKbdCallback := False;
    fbClose(hbrl);
    FreeLibrary(hBrlLib);
end;

procedure focus80_Write (s: string);
var i: integer;
    br: string;
begin
    br := brailleUnificado(s);

    for i := 1 to length(br) do
        if br[i] > #$ff then  br[i] := ' ';
    while length(br) <= brNumCells do
        br := br + '          ';

    for i := 1 to length(br) do
        br[i] := chr(AmbCodeParaBin[chr(MetaBrailleParaAMBCode[br[i]])]);

    fbWrite(hbrl, 0, brNumCells, pchar(br));
end;

procedure focus80_EnableReading (habilitaTeclado: boolean);
begin
    if habilitaTeclado then
        begin
            fbConfigure(hbrl, $02);
            brailleKbdCallback := focus80_BrailleKbdCallback;
            hasBrailleKbdCallback := true;
        end
    else
        hasBrailleKbdCallback := False;
end;

end.
