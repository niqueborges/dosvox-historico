unit dostec;
interface
uses dvcrt, dvwin, windows, sysUtils,
     dosgeral, dosmsg, dvform;

procedure testaTeclado;

implementation

{--------------------------------------------------------}
{                  opcao de teste de teclado
{--------------------------------------------------------}

    function KbStatus: byte;
        var retorno: byte;
    begin
        retorno := 0;
        If getKeyState (vk_shift) < 0  then
            retorno := retorno + $10;
        If (getKeyState (vk_numlock) and 1) <> 0  then
            retorno := retorno + $20;
        If (getkeystate (vk_capital) and 1) <> 0  then
            retorno := retorno + $40;

        kbStatus := retorno;
    end;

procedure interControles (var status: word);
var dif, novostatus: word;

begin
    novostatus := kbStatus;

    dif := status xor novostatus;
    status := novostatus;
    if dif = 0 then exit;

    if (dif and $10) <> 0 then
        if (status and $10) <> 0 then
            mensagem ('DV_SHIFT', 0);   { '<shift>' }

    if (dif and $20) <> 0 then
        if (status and $20) <> 0 then
            mensagem ('DV_NUM', 0)      { '<num.lock>' }
        else
            mensagem ('DV_NONUM', 0);   { '<sem num.lock>' }

    if (dif and $40) <> 0 then
        if (status and $40) <> 0 then
            mensagem ('DV_CAPS', 0)     { '<caps lock>' }
        else
            mensagem ('DV_NOCAPS', 0);  { '<sem caps lock>' }
end;

function processaEspeciais: boolean;
type
    TSpecKey = record
         key: integer;
         msg: string[20];
         redraw: boolean;
    end;

const
    NSK = 9;
    specKeys: array [1..NSK] of TSpecKey = (
        (key: VK_RMENU   ; msg: 'DV_CTLALT'; redraw: false),  { '<control alt>' }
        (key: VK_CONTROL ; msg: 'DV_CONTRL'; redraw: false),  { '<control>' }
        (key: VK_LMENU   ; msg: 'DV_ALT';    redraw: false),  { '<alt>' }
        (key: VK_LWIN    ; msg: 'DV_BLWIN';  redraw: true),   { '<iniciar>' }
        (key: VK_RWIN    ; msg: 'DV_BRWIN';  redraw: true),   { '<iniciar>' }
        (key: VK_APPS    ; msg: 'DV_BRAPPL'; redraw: false),  { '<aplicações>' }
        (key: VK_PAUSE   ; msg: 'DV_BPAUSE'; redraw: false),  { '<pause>' }
        (key: VK_SCROLL  ; msg: 'DV_BSLOCK'; redraw: false),  { '<scroll lock>' }
        (key: VK_SNAPSHOT; msg: 'DV_BPRSCR'; redraw: false)   { '<print screen>' }
    );

var
    i: integer;

begin
    result := false;
    for i := 1 to NSK do
        with specKeys[i] do
            if getkeystate(key) < 0 then
                begin
                    while getkeystate(key) < 0 do delay (50);
                    limpaBuf;
                    mensagem (msg, 0);
                    while sintFalando do waitMessage;
                    if redraw then
                        begin
                            showWindow(crtWindow, SW_MINIMIZE);
                            showWindow(crtWindow, SW_SHOWMAXIMIZED);
                        end;
                    result := true;
                end;
end;

{--------------------------------------------------------}

procedure testaTeclado;
var
    terminou: boolean;
    status: word;
    c, c2: char;

begin
    textBackground (RED);
    mensagem ('DV_TECLEFAL', 1);    { 'Aperte as teclas e eu falarei.' }
    mensagem ('DV_FIMTECESC', 1);   { 'O teste será terminado quando você apertar ESCAPE' }
    textBackground (BLACK);
    writeln;

    status := kbstatus;
    checkBreak := false;

    terminou := false;
    while not terminou do
        begin
            if keypressed then
                begin
                    pegaTeclado (c, c2);
                    if c <> #0 then
                        begin
                            case c of
                                #$08: mensagem ('DV_TEC_BS',    0); { '<backspace>' }
                                #$09: mensagem ('DV_TEC_TAB',   0); { '<tab>' }
                                '´':  mensagem ('DV_TEC_AGU',   0); { '<agudo>' }
                               '''':  mensagem ('DV_TEC_APOST', 0); { '<apóstrofo>' }
                                ' ':  mensagem ('DV_TEC_BRNCO', 0); { '<barra de espaços>' }
                                #$0d: begin
                                          mensagem ('DV_TEC_ENTER', 0); { '<enter>' }
                                          writeln;
                                      end;
                                GOTFOCUS:    sintBip;

                                #$21..#$26, #$28..#$b3, #$b5..#$dd, #$e0..#255:
                                       soletra (c, 0);
                                #$1b: begin
                                          mensagem ('DV_TEC_ESC', 0);   { '<escape>' }
                                          terminou := true;
                                      end;
                            end;
                        end
                    else
                        begin
                            case c2 of
                                F1:  mensagem ('DV_TEC_F1',  0);    { '<F1>' }
                                F2:  mensagem ('DV_TEC_F2',  0);    { '<F2>' }
                                F3:  mensagem ('DV_TEC_F3',  0);    { '<F3>' }
                                F4:  mensagem ('DV_TEC_F4',  0);    { '<F4>' }
                                F5:  mensagem ('DV_TEC_F5',  0);    { '<F5>' }
                                F6:  mensagem ('DV_TEC_F6',  0);    { '<F6>' }
                                F7:  mensagem ('DV_TEC_F7',  0);    { '<F7>' }
                                F8:  mensagem ('DV_TEC_F8',  0);    { '<F8>' }
                                F9:  mensagem ('DV_TEC_F9',  0);    { '<F9>' }
                                F10: mensagem ('DV_TEC_F10', 0);    { '<F10>' }
                                F11: mensagem ('DV_TEC_F11', 0);    { '<F11>' }
                                F12: mensagem ('DV_TEC_F12', 0);    { '<F12>' }

                                INS:    mensagem ('DV_TEC_INS',  0);    { '<ins>' }
                                DEL:    mensagem ('DV_TEC_DEL',  0);    { '<del>' }
                                HOME:   mensagem ('DV_TEC_HOME', 0);    { '<home>' }
                                TEND:   mensagem ('DV_TEC_END',  0);    { '<end>' }
                                PGUP:   mensagem ('DV_TEC_PGUP', 0);    { '<page up>' }
                                PGDN:   mensagem ('DV_TEC_PGDN', 0);    { '<page down>' }

                                CIMA:   mensagem ('DV_TEC_CIMA', 0);    { '<cima>' }
                                BAIX:   mensagem ('DV_TEC_BAIX', 0);    { '<baixo>' }
                                ESQ:    mensagem ('DV_TEC_ESQ',  0);    { '<esquerda>' }
                                DIR:    mensagem ('DV_TEC_DIR',  0);    { '<direita>' }
                            end;
                        end;

                    if c <> #$0d then write (' ');
                end
            else
                begin
                    delay (50);
                    interControles (status);
                    processaEspeciais;
                end;
        end;

    checkBreak := true;

    writeln;
    textBackground (RED);
    mensagem ('DV_FIMTESTE', 0);    { 'O teste está encerrado.' }
    textBackground (BLACK);
    writeln;
    writeln;
end;

end.
