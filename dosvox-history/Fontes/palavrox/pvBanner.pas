unit pvBanner;

interface

function GetTempFile(filetype: string): String;
procedure banner (strBanner1, strBanner2: string);

implementation

uses
    dvcrt, windows, graphics, SysUtils, Classes;

{--------------------------------------------------------}

function GetTempFile(filetype: string): String;
var
    tempFileName, tempPath: array[0..255] of Char;
begin
    getTempPath (255, tempPath);
    getTempFileName(tempPath, pchar(filetype), 0, tempFileName);
    result := strPas (tempFileName);
end;

{--------------------------------------------------------}

function geraBanner (palavra1, palavra2, nomeArqBmp: string): string;
var
    FFundo: TBitmap;
    lpRect: TRect;
    dxtexto, dytexto: integer;
begin
    FFundo := TBitmap.Create;
    GetClientRect(crtWindow, lpRect);

    FFundo.PixelFormat := pf32bit;
    FFundo.Width := (lpRect.Right - lpRect.Left) div 2;
    FFundo.Height := 100;

    FFundo.Canvas.Brush.Style := bsSolid;
    FFundo.Canvas.Brush.Color := colorNumber (BLUE);
    FFundo.Canvas.FillRect(rect(0,0,FFundo.Width, FFundo.Height));

    FFundo.Canvas.Font.Name := 'Arial';
    FFundo.Canvas.Font.Size := -36;
    FFundo.Canvas.Font.Color := colorNumber (YELLOW);
    FFundo.Canvas.Brush.Style := bsClear;

    dxTexto := FFundo.Canvas.TextWidth (palavra1);
    dyTexto := FFundo.Canvas.TextHeight (palavra1);
    FFundo.Canvas.TextOut((FFundo.Width  - dxtexto) div 2,
                          (FFundo.Height - dytexto) div 8, palavra1);

    FFundo.Canvas.Font.Color := colorNumber (LIGHTGREEN);
    dxTexto := FFundo.Canvas.TextWidth (palavra2);
    dyTexto := FFundo.Canvas.TextHeight (palavra2);
    FFundo.Canvas.TextOut((FFundo.Width  - dxtexto) div 2,
                        7*(FFundo.Height - dytexto) div 8, palavra2);

    FFundo.Canvas.Pen.Color := colorNumber (MAGENTA);
    FFundo.Canvas.MoveTo(0,FFundo.Height div 2);
    FFundo.Canvas.LineTo(FFundo.Width, FFundo.Height div 2);
    FFundo.SaveToFile(nomeArqBmp);
    FFundo.Free;
end;

{--------------------------------------------------------}

var
    lpRect: TRect;
    nomeArqBanner: string;

{--------------------------------------------------------}

procedure banner (strBanner1, strBanner2: string);
begin
    geraBanner (strBanner1, strBanner2, nomeArqBanner);

    closeBMP;   { não tem problema se não estiver aberto }
    openBMP(nomeArqBanner);

    GetClientRect(crtWindow, lpRect);
    paintBmp ((lpRect.Right - lpRect.Left) div 2 - 64, 128);
end;

initialization
    nomeArqBanner := getTempFile ('bmp');

finalization
    closeBmp;
    DeleteFile(nomeArqBanner);
end.
