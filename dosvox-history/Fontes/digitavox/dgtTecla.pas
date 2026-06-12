{-------------------------------------------------------------}
{
{       Digitavox - Reconhecimneto do teclado
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 14 de Março de 2020
{       * Boa parte reaproveitada da unit dosTec.pas do Dosvox.
{
{-------------------------------------------------------------}

unit dgtTecla;

interface
uses
    dvcrt, dvwin, windows, sysUtils,
    dvform, dvExec,
    dgtMsg, dgtUtil, dgtOriDedo;

procedure testaTeclas;

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
    msg: string;

begin
    novostatus := kbStatus;

    dif := status xor novostatus;
    status := novostatus;
    if dif = 0 then exit;

    msg := '';
    if (dif and $10) <> 0 then
        if (status and $10) <> 0 then
            msg := 'DGTSHIFT';   { '<shift>' }

    if (dif and $20) <> 0 then
        if (status and $20) <> 0 then
            msg := 'DGTNUM'       { '<num.lock>' }
        else
            msg := 'DGTNONUM';   { '<sem num.lock>' }

    if (dif and $40) <> 0 then
        if (status and $40) <> 0 then
            msg := 'DGTCAPS'     { '<caps lock>' }
        else
            msg := 'DGTNOCAPS';  { '<sem caps lock>' }

    if msg <> '' then mensagem (msg, 0);
    explicarEspeciais (msg);
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
        (key: VK_RMENU   ; msg: 'DGTCTLALT'; redraw: false),  { '<control alt>' }
        (key: VK_CONTROL ; msg: 'DGTCONTRL'; redraw: false),  { '<control>' }
        (key: VK_LMENU   ; msg: 'DGTALT';    redraw: false),  { '<alt>' }
        (key: VK_LWIN    ; msg: 'DGTBLWIN';  redraw: true),   { '<iniciar>' }
        (key: VK_RWIN    ; msg: 'DGTBRWIN';  redraw: true),   { '<iniciar>' }
        (key: VK_APPS    ; msg: 'DGTBRAPPL'; redraw: false),  { '<aplicações>' }
        (key: VK_PAUSE   ; msg: 'DGTBPAUSE'; redraw: false),  { '<pause>' }
        (key: VK_SCROLL  ; msg: 'DGTBSLOCK'; redraw: false),  { '<scroll lock>' }
        (key: VK_SNAPSHOT; msg: 'DGTBPRSCR'; redraw: false)   { '<print screen>' }
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
                    limpaBufTec;
                    mensagem (msg, 0);
                    explicarEspeciais (msg);
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

procedure testaTeclas;
var
    terminou: boolean;
    status: word;
    c, c2: char;

begin
    textBackground (RED);
    mensagem ('DGTAPEFAL', 1);    { 'Aperte as teclas e eu falarei.' }
    mensagem ('DGTRECTER', 1);   { 'O reconhecimento será terminado quando você apertar ESCAPE' }
    textBackground (BLACK);
    writeln;

    status := kbstatus;
    checkBreak := false;

    terminou := false;
    while not terminou do
        begin
            if keypressed then
                begin
                    pegaTeclado (false, c, c2);
                    if c <> #0 then
                        begin
                            case c of
                                #$08: mensagem ('DGTTEC_BS',    0); { '<backspace>' }
                                #$09: mensagem ('DGTTEC_TAB',   0); { '<tab>' }
                                '´':  mensagem ('DGTTEC_AGU',   0); { '<agudo>' }
                               '''':  mensagem ('DGTTEC_APOST', 0); { '<apóstrofo>' }
                                ' ':  mensagem ('DGTTEC_BRNCO', 0); { '<barra de espaços>' }
                                #$0d: begin
                                          mensagem ('DGTTEC_ENTER', 0); { '<enter>' }
                                          writeln;
                                      end;
                                GOTFOCUS:    sintBip;

                                #$21..#$26, #$28..#$b3, #$b5..#$dd, #$e0..#255:
                                       soletra (c, 0);
                                #$1b: begin
                                          mensagem ('DGTTEC_ESC', 0);   { '<escape>' }
                                          terminou := true;
                                      end;
                            end;
                        end
                    else
                        begin
                            case c2 of
                                F1:  mensagem ('DGTTEC_F1',  0);    { '<F1>' }
                                F2:  mensagem ('DGTTEC_F2',  0);    { '<F2>' }
                                F3:  mensagem ('DGTTEC_F3',  0);    { '<F3>' }
                                F4:  mensagem ('DGTTEC_F4',  0);    { '<F4>' }
                                F5:  mensagem ('DGTTEC_F5',  0);    { '<F5>' }
                                F6:  mensagem ('DGTTEC_F6',  0);    { '<F6>' }
                                F7:  mensagem ('DGTTEC_F7',  0);    { '<F7>' }
                                F8:  mensagem ('DGTTEC_F8',  0);    { '<F8>' }
                                F9:  mensagem ('DGTTEC_F9',  0);    { '<F9>' }
                                F10: mensagem ('DGTTEC_F10', 0);    { '<F10>' }
                                F11: mensagem ('DGTTEC_F11', 0);    { '<F11>' }
                                F12: mensagem ('DGTTEC_F12', 0);    { '<F12>' }

                                INS:    mensagem ('DGTTEC_INS',  0);    { '<ins>' }
                                DEL:    mensagem ('DGTTEC_DEL',  0);    { '<del>' }
                                HOME:   mensagem ('DGTTEC_HOME', 0);    { '<home>' }
                                TEND:   mensagem ('DGTTEC_END',  0);    { '<end>' }
                                PGUP:   mensagem ('DGTTEC_PGUP', 0);    { '<page up>' }
                                PGDN:   mensagem ('DGTTEC_PGDN', 0);    { '<page down>' }

                                CIMA:   mensagem ('DGTTEC_CIMA', 0);    { '<cima>' }
                                BAIX:   mensagem ('DGTTEC_BAIX', 0);    { '<baixo>' }
                                ESQ:    mensagem ('DGTTEC_ESQ',  0);    { '<esquerda>' }
                                DIR:    mensagem ('DGTTEC_DIR',  0);    { '<direita>' }
                            end;
                        end;

                    orientacaoTecla (c, c2);

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
    mensagem ('DGTRECENC', 0);    { 'O reconhecimento está encerrado.' }
    textBackground (BLACK);
    writeln;
    writeln;
end;

{--------------------------------------------------------}

begin
end.
