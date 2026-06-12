unit dosjanel;
interface
uses
    windows, sysutils, classes, shellapi,
    dvcrt, dvwin,
    dosgeral, dosmsg, dvform;

procedure vaiParaJanela;

implementation

{--------------------------------------------------------}
{           converte nomes para fala mais rapida
{--------------------------------------------------------}

function simplifica (s: string): string;
var final, palavra: string;
    p: integer;
begin
    final := '';
    while s <> '' do
        begin
             while (s <> '') and (s[1] = ' ') do
                 delete (s, 1, 1);

             if s <> '' then
                 begin
                     palavra := '';
                     while (s <> '') and (s[1] <> ' ') do
                         begin
                             palavra := palavra + copy (s, 1, 1);
                             delete (s, 1, 1);
                        end;

                    repeat
                        p := pos ('\', palavra);
                        if (p <> 0) and (p <> length (palavra)) then
                            delete (palavra, 1, p);

                    until (p = 0) or (p = length (palavra));

                    final := final + palavra + ' ';
                 end;

        end;

    while (length (final) > 0) and (final [length (final)] = ' ') do
        delete (final, length(final), 1);
    while (length (final) > 0) and (final [length (final)] = ']') do
        delete (final, length(final), 1);

    simplifica := final;
end;

{--------------------------------------------------------}
{                 vai para outra janela
{--------------------------------------------------------}

procedure vaiParaJanela;
type
    INFORM_JANELA = record
        jan: hwnd;
        visivel, iconica: boolean;
        titulo: string;
    end;

var
    currWnd: hwnd;
    txt: array [0..144] of char;
    njan: integer;
    infoJan: array [1..100] of ^INFORM_JANELA;
    i, numSelec: integer;
    c: char;
    nlfol: integer;

label fim;

begin
    CurrWnd := GetWindow(crtWindow, GW_HWNDFIRST);

    njan := 0;
    While CurrWnd <> 0 do
        begin
            if isWindowEnabled (currWnd) then
                begin
                    njan := njan + 1;
                    new (infoJan[njan]);
                    with infoJan[njan]^ do
                        begin
                            jan := currWnd;
                            visivel := isWindowVisible (currWnd);
                            iconica := isIconic (currWnd);
                            GetWindowText(CurrWnd, txt, 144);
                            titulo := strPas (txt);
                            if not ((visivel or iconica) and (length (titulo) <> 0)) then
                                 begin
                                     dispose (infoJan[njan]);
                                     njan := njan - 1;
                                 end;
                        end;
                end;

           CurrWnd := GetWindow(CurrWnd, GW_HWNDNEXT);
        end;

    mensagem ('DV_SELJAN', 1);  { 'Selecione a janela com as setas depois ENTER' }
    nlfol := 20;
    if nlfol > njan then nlfol := njan;
    garanteEspacoTela(nlfol);

    popupMenuCria (1, wherey, 80, nlfol, RED);   ////////////////// se > 20 estraga tela ao retornar

    for i := 1 to njan do
         popupMenuAdiciona ('', infojan[i]^.titulo);

    textBackground(RED);

    numSelec := popupMenuSeleciona;
    if (numSelec >0) and (numSelec <= njan) then c := ENTER else c := ESC;
    textBackground(BLACK);

    if c = ESC then
    begin
            if sintFalarTudo then
                mensagem ('DV_DESIST', 1);       {'Desistiu...'}
        end
    else
        if (numSelec >= 1) and (numSelec <= njan) then
            begin
                if sintFalarTudo then
                mensagem ('DV_OK', 0);      { 'Ok ! '}
                setWindowPos (infoJan[numSelec]^.jan, HWND_TOP, 0, 0, 0, 0,
                            SWP_NOMOVE+SWP_NOSIZE+SWP_SHOWWINDOW);
            end
        else
            sintBip;

fim:
    for i := 1 to njan do
        dispose (infoJan [i]);

    if c <> ESC then
        repeat
            delay (50);
        until getActiveWindow = crtWindow;

    writeln;
end;

begin
end.
