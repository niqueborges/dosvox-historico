unit doslogo;

interface

uses
    windows, graphics, classes, jpeg, sysutils,
    dvcrt, dvwin,
    dosmsg, dosVars;

procedure logoGrafico;
procedure mostraLogo;

implementation

function carregaJpegNaTela (nomeArq: string; xdest, ydest, dx, dy: integer): boolean;
var
    FTela: TBitmap;
    FStreamJpg  : TStream;
    FJpeg:  TJPEGImage;
    crtDC, memDC: HDC;
    w, h: integer;

begin
    if not fileExists (nomeArq) then
        begin
            result := false;
            exit;
        end;

    //  aloca bitmap com tamanho da largura e altura da tela

    FTela := TBitmap.Create;
    FTela.Width := dx;
    FTela.Height := dy;
    FTela.PixelFormat := pf24bit;
//    FTela.Canvas.StretchDraw(rect(0, 0, dx, dy), FJpeg);

    // abre o jpeg, redimensiona e joga no bitmap da tela

    FStreamJpg := TFileStream.Create(nomeArq, fmOpenRead); // trago arquivo jpeg para o canto superior esquerdo deste bitmap
    FJpeg := TJPEGImage.Create;
    FJpeg.LoadFromStream(FStreamJpg);

    w := FJpeg.width;
    h := FJpeg.height;
    if w > dx then
        begin
            h := trunc (h * (dx / w));
            w := dx;
        end;
    if h > dy then
        begin
            w := trunc (w * (dy / h));
            h := dy;
        end;

    FTela.Canvas.StretchDraw(rect(0, 0, w, h), FJpeg);
    FJpeg.Free;
    FStreamJpg.Free;

    // crio uma área de conversão compatível

    crtDc := getDc (crtWindow);
    Memdc := CreateCompatibleDC (crtDc);
    SelectObject(MemDC, FTela.Handle);

    // jogo na tela física
//    BitBlt(crtDC, xdest, ydest, dx, dx, MemDC, 0, 0, SRCCopy);
    BitBlt(crtDC, xdest + (dx-w) div 2, ydest + (dy-h) div 2, w, h, MemDC, 0, 0, SRCCopy);

    // limpo áreas intermediárias
    DeleteDC(MemDC);
    releaseDc (crtWindow, crtDc);
    FTela.Free;

    result := true;
end;

{--------------------------------------------------------}
{             mostra o logotipo do DOSVOX
{--------------------------------------------------------}

procedure logoGrafico;
var dirDosvox: string;
begin
    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
    carregaJpegNaTela (dirDosvox+ '\dosvox_logo.jpg',
                        0, 0, CharSize.X*80, CharSize.Y*8);
end;

{--------------------------------------------------------}

procedure mostraLogo;
begin
    textBackground (BLACK);
    clrscr;
(*
    textColor (WHITE);
    textBackground (BLUE);
    writeln ('  *****     *****    *****   **   **   *****   **   **  ');
    writeln ('  **  **   **   **  **    *  **   **  **   **   ** **   ');
    writeln ('  **   **  **   **  **       **   **  **   **    ***    ');
    writeln ('  **   **  **   **   *****   **   **  **   **     *     ');
    writeln ('  **   **  **   **       **   ** **   **   **    ***    ');
    writeln ('  **  **   **   **  *    **    ***    **   **   ** **   ');
    writeln ('  *****     *****    *****      *      *****   **   **  ');
    textBackground (BLACK);
*)
    gotoxy (1, 9);
    logoGrafico;

    textcolor(green);
    gotoxy (28-(length(versao)+length(tipoVersao)) div 2, wherey);
    write (pegaTextoMensagem ('DV_SISTOP'));        { 'Sistema DOSVOX' - versão x.x}
    write (pegaTextoMensagem ('DV_VERSAO'));
    write (versao);
    writeln (tipoVersao);
    textcolor(White);
    gotoxy (23, wherey);
    writeln (pegaTextoMensagem ('DV_NCE'));         { 'Instituto Tércio Pacitti - CRTA - NCE/UFRJ' }
end;

end.
