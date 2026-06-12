{--------------------------------------------------------}
{
{     Monitvox - módulo de edição de linha
{     Autor: Antonio Borges
{     Em 23/3/2003
{
{--------------------------------------------------------}

unit mvedita;

interface
uses dvcrt, dvwin, dvmacro, Windows, sysUtils, mvVars, mvmsg, mvPosjan;

procedure editaLinha (podeAlterarTexto: boolean);
function pegaBloco: string;

implementation

{--------------------------------------------------------}
{              traz um bloco marcado
{--------------------------------------------------------}

function pegaBloco: string;
var linha: array [0..255] of char;
begin
    putClipBoard ('');

    keyboardVirtKey (VK_END, false, false, false, 20);
    keyboardVirtKey (VK_HOME, false, true, false, 20);
    keyboardVirtKey (VK_INSERT, true, false, false, 20);
    keyboardVirtKey (VK_END, false, false, false, 20);
    delay (200);

    getClipBoard (linha, 254);
    pegaBloco := strPas(linha);
end;

{--------------------------------------------------------}
{              reenvia o bloco alterado
{--------------------------------------------------------}

procedure reenviaBloco (s: string);
begin
    s := s + #$0;
    putClipBoard (@s[1]);

    keyboardChar (' ', 20);
    keyboardVirtKey (VK_END, false, false, false, 20);
    keyboardVirtKey (VK_SPACE, false, false, false, 20);
    keyboardVirtKey (VK_HOME, false, true, false, 20);
    keyboardVirtKey (VK_BACK, false, false, false, 20);
    keyboardVirtKey (VK_INSERT, false, true, false, 20);
    keyboardVirtKey (VK_END, false, false, false, 20);
end;

{--------------------------------------------------------}
{              edita um bloco marcado
{--------------------------------------------------------}

procedure editaLinha (podeAlterarTexto: boolean);
var linha, linhaOrig: string;
    c: char;
    f: integer;
    tinhaCRLF: boolean;
label fim;
begin
    sintBip;
    writeln;

    showWindow (crtWindow, SW_HIDE);
    delay (200);

    repeat
        linha := pegaBloco;
        posJan (0, 0, 80, 4);
        showWindow (crtWindow, SW_SHOW);
        setForegroundWindow (crtWindow);
        while keypressed do readkey;

        tinhaCRLF := false;
        f := pos (#$0d+#$0a, linha);
        if f <> 0 then
             begin
                 delete (linha, f, 999);
                 tinhaCRLF := true;
             end;

        linhaOrig := linha;
        clreol;
        write (copy (linha, 1, 79) + #$0d);
        sintetiza (linha);

        c := sintEdita(linha, wherex, wherey, 254, true);
        posJan (0, 0, 40, 4);
        if c <> ESC then
            begin
                showWindow (crtWindow, SW_HIDE);
                delay (200);
                if podeAlterarTexto and (linhaOrig <> linha) then
                    begin
                        if tinhaCRLF then
                            linha := linha + #$0d#$0a;
                        reenviaBloco (linha);
                    end;
            end;

        case c of
            CIMA:   keyboardVirtKey (VK_UP, false, false, false, 100);
            BAIX:   keyboardVirtKey (VK_DOWN, false, false, false, 100);
            ESQ:    keyboardVirtKey (VK_LEFT, false, false, false, 100);
            DIR:    keyboardVirtKey (VK_RIGHT, false, false, false, 100);
            PGUP:   keyboardVirtKey (VK_PRIOR, false, false, false, 100);
            PGDN:   keyboardVirtKey (VK_NEXT, false, false, false, 100);
            ENTER:  c := ESC;   // termina
            ESC:    ;
        end;
    until (c = ESC);

    writeln;
    sintBip;
end;

end.
