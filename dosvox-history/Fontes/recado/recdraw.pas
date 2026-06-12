{--------------------------------------------------------}
{                                                        }
{    Programa de envio e recepção de recados             }
{                                                        }
{    Módulo de desenho                                   }
{                                                        }
{    Autor: José Antonio Borges                          }
{                                                        }
{    Em novembro/2014                                    }
{                                                        }
{--------------------------------------------------------}

unit recdraw;

interface
uses dvcrt, sysutils, jpeg, classes, windows, graphics;

procedure exibeFigura (nomeArqFig: string; x, y: integer);

implementation

{--------------------------------------------------------}
{                    exibe uma figurinha
{--------------------------------------------------------}

procedure exibeFigura (nomeArqFig: string; x, y: integer);
var
    FJpeg    : TJpegImage;
    FTela    : TBitmap;
    FStreamJpg  : TStream;
    crtDc, MemDc: HDC;

begin
    if not fileExists (nomeArqFig) then exit;

    FStreamJpg := TFileStream.Create(nomeArqFig, fmOpenRead);
    FJpeg := TJPEGImage.Create;
    FJpeg.LoadFromStream(FStreamJpg);

    FTela := TBitmap.Create;
    FTela.Width := FJpeg.Width;
    FTela.Height := FJpeg.Height;
    FTela.PixelFormat := pf24bit;
    FTela.Canvas.Draw (0, 0, FJpeg);
    FJpeg.Free;
    FStreamJpg.Free;

    crtDC := GetDC (crtWindow);
    Memdc := CreateCompatibleDC (crtDc);
    SelectObject(MemDC, FTela.Handle);
    StretchBlt(crtDC,
               WindowSize.x-FTela.Width*2 -50, 30, FTela.Width*2, FTela.height*2,
               MemDC, 0, 0, FTela.Width-1, FTela.Height-1, SRCCopy);
    DeleteDC(MemDC);
    releaseDC (crtWindow, crtDC);

    FTela.Free;
end;

end.
