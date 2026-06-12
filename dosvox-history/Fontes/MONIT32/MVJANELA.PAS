{--------------------------------------------------------}
{
{     Monitvox - módulo de leitura de janelas
{     Autor: Antonio Borges
{     Em 23/3/2003
{
{--------------------------------------------------------}

unit mvjanela;

interface
uses
    dvcrt, dvwin, windows, oleacc, sysutils, mvvars, mvmsaa, mvmostra, mvmsg;

procedure leTituloJanela;
procedure leMessageBox;
procedure leStatus;
procedure leJanela;
procedure leJanelaArq;

implementation

{--------------------------------------------------------}
{           mostra um rótulo interno da janela
{--------------------------------------------------------}

const
    SO_OBTEM_OBJETO = 0;
    QUALQUER_OBJETO = 1;
    SO_ROTULOS = 2;

function mostraObjetoInterno (opcao: integer): boolean;
begin
    result := true;
    processWindowsQueue;
    piacc._AddRef;
    obtemObjetoMSAA;
    case opcao of
        SO_OBTEM_OBJETO:  ;
        QUALQUER_OBJETO:  mostraObjeto (false);
        SO_ROTULOS:       if (codTipo = ROLE_SYSTEM_STATICTEXT) or
                             (codTipo = ROLE_SYSTEM_CLIENT) then
                                        mostraObjeto (false)
                          else
                              result := false;
    end;
    piacc._Release;
    piacc := NIL;
end;

{--------------------------------------------------------}
{              mostra título da janela
{--------------------------------------------------------}

procedure leTituloJanela;
begin
    ShowWindow(crtWindow, SW_HIDE);
    delay (200);

    if ultJan = 0 then
        ultjan := getForegroundWindow;

    vId := 0;
    if AccessibleObjectFromWindow(ultjan, OBJID_TITLEBAR,
                                  IID_IAccessible, piacc) = S_OK then
        mostraObjetoInterno (QUALQUER_OBJETO);

    vId := 0;
    if AccessibleObjectFromWindow(ultjan, OBJID_WINDOW,
                                  IID_IAccessible, piacc) = S_OK then
        mostraObjetoInterno (QUALQUER_OBJETO);
end;

{--------------------------------------------------------}
{           mostra texto interno de Message Box
{--------------------------------------------------------}

procedure leMessageBox;

var pt: TPoint;
    maxy: integer;

begin
    pt.X := xob;
    pt.y := yob-1;
    maxy := 0;
    if AccessibleObjectFromPoint (pt, piacc, vId) = S_OK then
        begin
            mostraObjetoInterno (QUALQUER_OBJETO);
            pt.x := xob+dxob div 2;
            pt.y := yob+20;
            maxy := yob+dyob-10;
        end;

    repeat
        if AccessibleObjectFromPoint (pt, piacc, vId) = S_OK then
            mostraObjetoInterno (SO_ROTULOS);
        pt.y := pt.y + 10;
    until (pt.y > maxy) or keypressed;
end;

{--------------------------------------------------------}
{                 ler linha de status
{--------------------------------------------------------}

procedure leStatus;

var pt: TPoint;
    maxx: integer;

begin
    ultJan := getForegroundWindow;
    vId := 0;
    if AccessibleObjectFromWindow(ultjan, OBJID_WINDOW,
                                  IID_IAccessible, piacc) = S_OK then
         mostraObjetoInterno (SO_OBTEM_OBJETO);

    pt.X := xob+15;
    pt.Y := yob+dyob-15;
    maxx := xob+dxob-1;
                     
    repeat
        if AccessibleObjectFromPoint (pt, piacc, vId) = S_OK then
            begin
                mostraObjetoInterno (SO_ROTULOS);
                // sintClek;
            end;
        pt.x := pt.x + 10;
    until (pt.x >= maxx) or keypressed;
end;

{--------------------------------------------------------}
{                 processa toda a janela
{--------------------------------------------------------}

procedure processaJanela (mostraCoord: boolean; nomeArq: string);
var
    pt: TPoint;
    xi, yi, maxx, maxy: integer;
    nobj: integer;
    listaObj: array [1..10000] of TPoint;
    listaCoord: array [1..10000] of TPoint;
    i, x, y, dx, dy, xant, yant: integer;
    achou: boolean;
    vRole: variant;

begin
    ShowWindow(crtWindow, SW_HIDE);
    delay (500);
//    mensagem ('MOCALCUL', 1);    {'Calculando'}
    ultjan := getForegroundWindow;

    if AccessibleObjectFromWindow(ultjan, OBJID_WINDOW, IID_IAccessible, piacc) = S_OK then
        begin
            processWindowsQueue;
            piacc._AddRef;
            obtemObjetoMSAA;
            piacc._Release;
            piacc := NIL;
        end;

    xi := xob;
    yi := yob;
    maxx := xob+dxob-1;
    maxy := yob+dyob-1;
    setCursorPos (xi, yi);

    nobj := 0;

    monitorando := true;
    pt.y := yi;
    while monitorando and (pt.y < maxy) do
        begin
            pt.x := xi;
            xant := -9999;
            yant := -9999;
            while monitorando and (pt.x < maxx) do
                begin
                    if AccessibleObjectFromPoint (pt, piacc, vId) = S_OK then
                        begin
                            processWindowsQueue;
                            piacc._AddRef;
                            if not succeeded (piacc.get_accRole (vId, vRole)) then
                                 continue;

                            piacc.accLocation (x, y, dx, dy, vId);

                            piacc._Release;
                            piacc := NIL;
                            processWindowsQueue;

                            if (x <> xant) or (y <> yant) then
                                begin
                                    xant := x;
                                    yant := y;

                                    achou := false;
                                    for i := 1 to nobj do
                                        if (x = listaObj[i].x) and (y = listaObj[i].y) then
                                            begin
                                                achou := true;
                                                break;
                                            end;

                                    if not achou then
                                        begin
                                            if nobj mod 20 = 0 then sintClek;
                                            nObj := nObj + 1;
                                            listaObj[nobj].x := x;
                                            listaObj[nobj].y := y;
                                            if vrole = ROLE_SYSTEM_LISTITEM then
                                                begin
                                                    listaCoord[nobj].x := x + dx div 2;
                                                    listaCoord[nobj].y := y + dy div 2;
                                                end
                                            else
                                                begin
                                                    listaCoord[nobj].x := x;
                                                    listaCoord[nobj].y := y;
                                                end;
                                        end;
                                end;
                        end;

                    pt.x := pt.x + 10;
                end;

            pt.y := pt.y + 10;
        end;

    for i := 1 to nobj do
        begin
            if not monitorando then break;
            pt := listaCoord[i];
            if AccessibleObjectFromPoint (pt, piacc, vId) = S_OK then
                begin
                    processWindowsQueue;
                    piacc._AddRef;
                    obtemObjetoMSAA;
                    setCursorPos (pt.x, pt.y);
                    if nomeArq <> '' then
                        mostraObjetoArq (mostraCoord)
                    else
                        mostraObjeto (false);
                    piacc._Release;
                    piacc := NIL;
                    while sintFalando do waitMessage;
                end;
        end;

    if nomeArq <> '' then closeFile (arq);
    monitorando := false;
end;

{--------------------------------------------------------}
{        joga conteúdo da janela num arquivo texto
{--------------------------------------------------------}

procedure leJanelaArq;
var nomeArq: string;
    mostraCoord: boolean;
    c: char;
begin
    mensagem ('MONOMARQ', 1);   {'Informe o nome do arquivo destino'}
    sintReadln (nomeArq);
    nomeArq := trim (nomeArq);

    if nomeArq = '' then
        mensagem ('MODESIST', 1);   {'Desistiu');

    assign (arq, nomeArq);
    {$I-}  rewrite (arq);   {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MOERRARQ', 1);  {'Erro ao criar o arquivo'}
            exit;
        end;

    mensagem ('MOREGCOR', 0);   {'Registra coordenadas ? '}
    c := sintReadkey;
    writeln (c);
    mostraCoord := upcase(c) = 'S';

    processaJanela (mostraCoord, nomeArq);
end;

{--------------------------------------------------------}
{              fala conteúdo da janela
{--------------------------------------------------------}

procedure leJanela;
begin
    processaJanela (false, '');
end;

end.
