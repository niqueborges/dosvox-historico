{--------------------------------------------------------}
{
{    Interface sonora para o mixer de áudio do Windows
{
{    Módulo de ajuste de controles
{
{    Por José Antonio Borges
{
{    Em 27/06/2002
{
{---------------------------------------------------------------------}

unit mxajust;

interface
uses windows, dvcrt, dvWin, dvForm, mmsystem, sysUtils, mxVars, mxMsg;

procedure ajustaDispositivoMixer;

implementation

{---------------------------------------------------------------------}

procedure mixerAjusta;
var classif: string;
    i: integer;
    escala: real;
    booleano: boolean;
const
    tabCanal: array [0..5] of string[2] = ('L', 'R', 'X', 'Y', 'A', 'B');
begin
    classif := 'Fora do padrão';
    case mxctrl_list[ctlSelec].dwControlType and MIXERCONTROL_CT_CLASS_MASK of
        MIXERCONTROL_CT_CLASS_CUSTOM:   ;
        MIXERCONTROL_CT_CLASS_METER:    classif := 'Medidor';
        MIXERCONTROL_CT_CLASS_SWITCH:   classif := 'Chaveador';
        MIXERCONTROL_CT_CLASS_NUMBER:   classif := 'Número';
        MIXERCONTROL_CT_CLASS_SLIDER:   classif := 'Potenciômetro';
        MIXERCONTROL_CT_CLASS_FADER:    classif := 'Redutor';
        MIXERCONTROL_CT_CLASS_TIME:     classif := 'Tempo';
        MIXERCONTROL_CT_CLASS_LIST:     classif := 'Lista de classes';
    end;

    booleano := (mxctrl_list[ctlSelec].dwControlType and MIXERCONTROL_CT_UNITS_MASK) <>
                                        MIXERCONTROL_CT_UNITS_BOOLEAN;

    case mxctrl_list[ctlSelec].dwControlType and MIXERCONTROL_CT_UNITS_MASK of
        MIXERCONTROL_CT_UNITS_CUSTOM:   classif := classif + ' - Medida customizada';
        MIXERCONTROL_CT_UNITS_BOOLEAN:  classif := classif + ' - Booleano';
        MIXERCONTROL_CT_UNITS_SIGNED:   classif := classif + ' - Número com sinal';
        MIXERCONTROL_CT_UNITS_UNSIGNED: classif := classif + ' - Número sem sinal';
        MIXERCONTROL_CT_UNITS_DECIBELS: classif := classif + ' - Decibéis';
        MIXERCONTROL_CT_UNITS_PERCENT:  classif := classif + ' - Percentual';
    end;

    classif := pegaTextoMensagem ('MXTIPO') + classif;  {'Tipo: '}

    if booleano then
        classif := classif + ' '
    else
        classif := classif + pegaTextoMensagem ('MXENTRE');   {' entre '}

    if ((mxctrl_list[ctlSelec].dwControlType and MIXERCONTROL_CT_UNITS_MASK) = MIXERCONTROL_CT_UNITS_SIGNED) or
       ((mxctrl_list[ctlSelec].dwControlType and MIXERCONTROL_CT_UNITS_MASK) = MIXERCONTROL_CT_UNITS_UNSIGNED) then
        classif := classif + '0' + pegaTextoMensagem ('MXE') + '100'
    else
        classif := classif +
                        intToStr(mxctrl_list[ctlSelec].Bounds.lMinimum) +
                        pegaTextoMensagem ('MXE') +      {' e '}
                        intToStr(mxctrl_list[ctlSelec].Bounds.lMaximum);

    sintWriteln (classif);
    while sintFalando do waitMessage;
    delay (500);

    for i := 0 to 5 do mxval[i] := 0;

    mxcd.cbStruct := sizeof (mxcd);
    mxcd.dwControlID := mxctrl_list[ctlSelec].dwControlID;
    mxcd.cMultipleItems := 0;   {simplificação}
    mxcd.cbDetails := {6*}sizeof(integer);
    mxcd.paDetails := @mxval;
    mxcd.cChannels := mxl.cChannels;  {multiple uniform}

    if mixerGetControlDetails(hmx, @mxcd, MIXER_GETCONTROLDETAILSF_VALUE) <> MMSYSERR_NOERROR then
        begin
            mxcd.cChannels := 1;  {uniform}
            if mixerGetControlDetails(hmx, @mxcd, MIXER_GETCONTROLDETAILSF_VALUE) <> MMSYSERR_NOERROR then
                mensagem ('MXNAOLI', 0);  {'Não consegui ler valores atuais'}
        end;

    with mxctrl_list[ctlSelec].Bounds do
        escala := lMaximum - lMinimum;

    if ((mxctrl_list[ctlSelec].dwControlType and MIXERCONTROL_CT_UNITS_MASK) = MIXERCONTROL_CT_UNITS_SIGNED) or
       ((mxctrl_list[ctlSelec].dwControlType and MIXERCONTROL_CT_UNITS_MASK) = MIXERCONTROL_CT_UNITS_UNSIGNED) then
          with mxctrl_list[ctlSelec].Bounds do
              for i := 0 to mxcd.cChannels-1 do
                  mxval[i] := round ((mxval[i] - lMinimum) / escala * 100.0);

    formCria;
    for i := 0 to mxcd.cChannels-1 do
        formCampoInt ('', tabCanal [i], mxval[i]);
    formEdita (true);

    if ((mxctrl_list[ctlSelec].dwControlType and MIXERCONTROL_CT_UNITS_MASK) = MIXERCONTROL_CT_UNITS_SIGNED) or
       ((mxctrl_list[ctlSelec].dwControlType and MIXERCONTROL_CT_UNITS_MASK) = MIXERCONTROL_CT_UNITS_UNSIGNED) then
          with mxctrl_list[ctlSelec].Bounds do
              for i := 0 to mxcd.cChannels-1 do
                  mxval[i] := round ((mxval[i] / 100.0) * escala) + lMinimum;

    if mixerSetControlDetails(hmx, @mxcd, MIXER_SETCONTROLDETAILSF_VALUE) <> MMSYSERR_NOERROR then
        mensagem ('MXNAOALT', 1)   {'Não consegui alterar'}
    else
        mensagem ('MXOK', 1);      {'OK'}
end;

{---------------------------------------------------------------------}

procedure mixerAjustaLista;
var i, n: integer;
    sel: integer;
begin
    writeln;
    sintWriteln ('Edite os valores da lista');
    writeln;

    for sel := 0 to 20 do
        mxcd_f[sel].fValue := 0;

    mxcd.cbStruct := sizeof (mxcd);
    mxcd.dwControlID := mxctrl_list[ctlSelec].dwControlID;
    mxcd.cMultipleItems := mxctrl_list[ctlSelec].cMultipleItems;
    mxcd.cbDetails := sizeof(MIXERCONTROLDETAILS_LISTTEXT);
    mxcd.paDetails := @mxdet_list;
    mxcd.cChannels := 1;  {uniform}

    if mixerGetControlDetails (hmx, @mxcd, MIXER_GETCONTROLDETAILSF_LISTTEXT) <> MMSYSERR_NOERROR then
        begin
            mensagem ('MXNAOLIS', 1);   {'Não consegui ler os valores da lista'}
            exit;
        end
    else
        begin
            mxcd.cbDetails := sizeof(MIXERCONTROLDETAILS_BOOLEAN);
            mxcd.paDetails := @mxcd_f;
            if mixerGetControlDetails (hmx, @mxcd, MIXER_GETCONTROLDETAILSF_VALUE) <> MMSYSERR_NOERROR then
                mensagem ('MXNAOBOO', 1);   {'Não consegui ler os valores booleanos'}
        end;

    n := mxl.cConnections;
    formCria;
    for i := 0 to n-1 do
        formCampoInt ('', mxdet_list[i].szName, mxcd_f[i].fValue);
    formEdita (true);

    if mixerSetControlDetails (hmx, @mxcd, MIXER_SETCONTROLDETAILSF_VALUE) <> MMSYSERR_NOERROR then
        mensagem ('MXNESLIS', 1);  {'Não consegui escrever os valores da lista'}
end;

{---------------------------------------------------------------------}

procedure ajustaDispositivoMixer;
var nctls, sel, i: integer;
label inicio;

begin
inicio:
    nctls := mxl.cControls;
    ZeroMemory(@mxlc, SizeOf(mxlc));
    mxlc.cbStruct   := sizeof(mxlc);
    mxlc.dwLineID   := mxl.dwLineID;
    mxlc.cControls  := mxl.cControls;
    mxlc.cbmxctrl   := sizeof (MIXERCONTROL);
    mxlc.pamxctrl   := @mxctrl_list;
    mixerGetLineControls (hmx, @mxlc, MIXER_GETLINECONTROLSF_ALL);

    if nctls > 1 then
        begin
            limpaBaixo (9);
            mensagem ('MXESCCTL', 1);   {'Escolha o controle'}

            popupMenuCria(wherex, wherey, 50, nctls, RED);
            for i := 0 to nctls-1 do
                popupMenuAdiciona ('', mxctrl_list[i].szName);
            sel := popupMenuSeleciona - 1;
            if sel < 0 then
                begin
                    mensagem ('MXDESIST', 1);  {'Desistiu...'}
                    exit;
                end;

            limpaBaixo (9);
            writeln (mxctrl_list[sel].szName);
        end
    else
        begin
            sel := 0;
            sintWriteln (mxctrl_list[sel].szName);
        end;

    ctlSelec := sel;

    if (mxctrl_list[ctlSelec].dwControlType and MIXERCONTROL_CT_CLASS_MASK) =
        MIXERCONTROL_CT_CLASS_LIST then
        mixerAjustaLista
    else
        mixerAjusta;

    if nctls > 1 then goto inicio;
end;

end.

