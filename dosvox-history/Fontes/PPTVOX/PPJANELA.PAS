{--------------------------------------------------------------}
{
{   PPTVOX - exibidor interativo de apresentações
[
{   Tratamento da janela de exibição (através do GDI)
{
{   Autores: Antonio Borges, Bernard Condorcet e Mara Caldeira
{
{   Junho/2015
{
{--------------------------------------------------------------}

unit ppjanela;

interface
uses
  dvcrt, dvwin, windows, messages, classes, graphics, SysUtils,
  ppvars, ppdesen;

type
    TPaintProc = procedure (dc: HDC; ps: TPaintStruct);

procedure criaTelaGrafica (rotDesenho: TPaintProc; fundoPreto: boolean);
procedure visualizaTelaGrafica;
procedure escondeTelaGrafica;
procedure destroiTelaGrafica;

procedure redesenhaTelaGrafica (apagaTela: boolean);  // na verdade pede o redesenho
function telaGraficaEstaMorta: boolean;

implementation

var
    minhaWin: HWnd;
    minhaClasse: TWNDCLASS;
    minhaDesenhaTela: TPaintProc;

{--------------------------------------------------------}
{             vê as largura e altura do display
{--------------------------------------------------------}

procedure pegaParamTelaFisica;
var
    dc: hDC;
begin
    dc := getDC(0);
    larguraTela := getDeviceCaps (dc, HORZRES);
    alturaTela := getDeviceCaps (dc, VERTRES);
    resolucaoGrafica:= (intToStr (larguraTela) + ' por ' + intToStr(alturaTela));
    releaseDC (0, dc);
end;

{--------------------------------------------------------}
{          cria uma fonte, dada sua especificidade
{--------------------------------------------------------}

function criaFonte (tam: integer; nomeFonte: string; negrito: boolean): HFont;
var
    yf: integer;
    dc: HDC;
    tipoBold: integer;
begin
    dc := getDC (minhaWin);

    if negrito then tipoBold := FW_BOLD
               else tipoBold := FW_NORMAL;

    yf := trunc (tam / 72.0 * getDeviceCaps (dc, LOGPIXELSY));
    result := createFont (
               yf, 0, 0, 0,     {altura, largura, angulo, anguloletra }
               tipoBold,        { FW_NORMAL ou FW_BOLD }
               0, 0, 0,         { 1/0 se itálico, sublinhado, riscado }
               ANSI_CHARSET,
               OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, DEFAULT_QUALITY,
               DEFAULT_PITCH,
               @nomeFonte[1]);

    ReleaseDC(minhaWin, dc);
end;

{--------------------------------------------------------}
{          cria as fontes usadas na apresentação
{--------------------------------------------------------}

procedure criaFontes;
begin
    fonteTitulo := criaFonte (t_tit, f_tit, true);
    fonteDetalhe := criaFonte (t_lin, f_lin, false);
    fonteSimbolo := criaFonte (24, 'Symbol', true);
end;

{--------------------------------------------------------}
{                  destrói as fontes criadas
{--------------------------------------------------------}

procedure destroiFontes;
begin
    deleteObject (fonteTitulo);
    deleteObject (fonteDetalhe);
    deleteObject (fonteSimbolo);
end;

{--------------------------------------------------------}
{       rotina de callback para redesenho da tela
(                 e tratamento do teclado
{--------------------------------------------------------}

function minhaWinProc (Window: HWnd; Message: UINT;
                    WParam: WPARAM; LParam: LPARAM): LRESULT;
         stdcall;

label defproc;
var
    minhaDC: HDC;
    minhaPS: TPaintStruct;
begin
    MinhaWinProc := 0;
    case Message of

        WM_PAINT:  begin
                        minhaDC := BeginPaint(MinhaWin, minhaPS);
                        desenhaSlideCompleto (minhaDC, minhaPS);
                        EndPaint(minhaWin, minhaPS);
                   end;

        WM_KEYDOWN, WM_KEYUP,
        WM_CHAR:
            postMessage (crtWindow, Message, WParam, LParam);

        WM_CLOSE:  begin
                       minhaWin := 0;
                       goto defProc;
                   end;
    else
        begin
defProc:
            minhaWinProc := DefWindowProc(Window, Message, WParam, LParam);
        end;
    end;
end;

{--------------------------------------------------------}
{  cria a janela de apresentação, fora do estilo Dosvox
{  e as fontes necessárias para sua exibição.
{--------------------------------------------------------}

procedure criaTelaGrafica (rotDesenho: TPaintProc; fundoPreto: boolean);
begin
    pegaParamTelaFisica;

    with minhaClasse do
        begin
            style := CS_VREDRAW or CS_HREDRAW;
            lpfnWndProc := @minhaWinProc;
            cbClsExtra := 0;
            cbWndExtra := 0;
            lpszMenuName := nil;
            lpszClassName := 'minhaJan';

            minhaClasse.hInstance := HInstance;
            hIcon := LoadIcon(0, idi_Application);
            hCursor := LoadCursor(0, idc_Arrow);
            if fundoPreto then
                hbrBackground := getStockObject (BLACK_BRUSH)
            else
                hbrBackground := getStockObject (WHITE_BRUSH);
        end;

    Windows.RegisterClass(minhaClasse);

    minhaDesenhaTela := rotDesenho;

    minhaWin := CreateWindow(
        minhaClasse.lpszClassName,
        NIL,
        WS_POPUP,
        0, 0,
        larguraTela, alturaTela,
        crtWindow, 0, HInstance, nil);

    criaFontes;
end;

{--------------------------------------------------------}
{                visualiza a tela gráfica
{--------------------------------------------------------}

procedure visualizaTelaGrafica;
begin
    showWindow (minhaWin, SW_SHOW);
    UpdateWindow(minhaWin);
end;

{--------------------------------------------------------}
{                esconde a tela gráfica
{--------------------------------------------------------}

procedure escondeTelaGrafica;
begin
    ShowWindow(minhaWin, SW_HIDE);
end;

{--------------------------------------------------------}
{            destroi a tela gráfica
{--------------------------------------------------------}

procedure destroiTelaGrafica;
begin
    destroiFontes;
    DestroyWindow(minhaWin);
end;

{--------------------------------------------------------}
{            pede para redesenhar a janela
{--------------------------------------------------------}

procedure redesenhaTelaGrafica (apagaTela: boolean);
begin
    InvalidateRect(minhaWin, NIL, apagaTela);
end;

{--------------------------------------------------------}
{            verifica se alguém matou a janela
{--------------------------------------------------------}

function telaGraficaEstaMorta: boolean;
begin
    result := minhaWin = 0;
end;

end.
