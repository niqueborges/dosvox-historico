unit pacdesen;

interface
uses dvcrt, windows, pacvars;

procedure mostraCartaGrafica (posx, posy, naipe, valor:integer);

implementation

const
    tabgraf: array [COPAS..ESPADAS] of integer = (27,14,1,40);

{--------------------------------------------------------}
{                   mostra uma carta
{--------------------------------------------------------}

procedure mostraCartaGrafica (posx, posy, naipe, valor:integer);
var
   bm: hbitmap;
   dcTrab, dcTela: hDC;
   cartaReal:integer;
   rect: TRect;
   distXLetra, distYLetra: integer;

begin
   getClientRect (crtWindow, rect);
   distXLetra := ((rect.Right-rect.Left) div 80);
   distYLetra := ((rect.Bottom-rect.Top) div 25);

   dcTela := getDC (crtWindow);
   dcTrab := createCompatibleDC (dcTela);

   cartaReal:= tabGraf[naipe]+valor;
   bm := LoadBitmap (hinstance, makeIntResource (cartaReal));

   selectObject (dcTrab, bm);

{
   if 71-distXletra*8 <= 0 then
       bitBlt (dcTela, (posx-1)*distXletra - (71-distXletra*8) div 2,
                       (posy-1)*distYletra - (96-distYletra*5) div 2, 71, 96,
               dcTrab, 0, 0, srcCopy)
   else
}
       stretchBlt (dcTela, (posx-1)*distXletra+2, (posy-1)*distYletra+2,
               distXLetra*8-4, distyLetra*5-4,
               dcTrab, 0, 0,  71, 96, srcCopy);

   deleteDC (dcTrab);
   deleteObject (bm);
   releaseDc (crtWindow, dcTela);
end;

end.
