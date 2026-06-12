{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de efeitos de transição
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Julho/2012
{
{--------------------------------------------------------}

unit joefeito;

interface
uses windows, dvcrt, sysUtils;

procedure mostraComEfeito (efeito: string;
                           crtDC, memDC: HDC;
                           largura, altura: integer);

implementation

procedure mostraComEfeito (efeito: string;
                           crtDC, memDC: HDC;
                           largura, altura: integer);

var i, i2, l, a, n, r, temp, dimq, x, y: integer;
    matAleat: array of integer;
begin
    if ansiUpperCase(efeito) = 'ESQUERDA' then
        begin
            i := 0;
            while i < largura do
                begin
                    BitBlt(crtDC, i, 0, 16, altura, MemDC, i, 0, SRCCopy);
                    delay (10);
                    i := i + 16;
                end;
        end
    else
    if ansiUpperCase(efeito) = 'DIREITA' then
        begin
            i := largura-1;
            while i >= 0 do
                begin
                    BitBlt(crtDC, i, 0, 16, altura, MemDC, i, 0, SRCCopy);
                    delay (10);
                    i := i - 16;
                    if (i < 0) and (i >= -15) then i := 0;
                end;
        end
    else
    if ansiUpperCase(efeito) = 'CIMA' then
        begin
            i := 0;
            while i < altura do
                begin
                    BitBlt(crtDC, 0, i, largura, 16, MemDC, 0, i, SRCCopy);
                    delay (10);
                    i := i + 16;
                end;
        end
    else
    if ansiUpperCase(efeito) = 'BAIXO' then
        begin
            i := altura-1;
            while i >= 0 do
                begin
                    BitBlt(crtDC, 0, i, largura, 16, MemDC, 0, i, SRCCopy);
                    delay (10);
                    i := i - 16;
                    if (i < 0) and (i >= -15) then i := 0;
                end;
        end
    else
    if ansiUpperCase(efeito) = 'ESQUERDA DIREITA' then
        begin
            i := 0;
            while i <= largura div 2 do
                begin
                    BitBlt(crtDC, i, 0, 4, altura, MemDC, i, 0, SRCCopy);
                    BitBlt(crtDC, largura-i, 0, 4, altura, MemDC, largura-i, 0, SRCCopy);
                    i := i + 4;
                    delay (5);
                end;
        end
    else
    if ansiUpperCase(efeito) = 'CIMA BAIXO' then
        begin
            i := 0;
            while i <= altura div 2 do
                begin
                    BitBlt(crtDC, 0, i, largura, 4, MemDC, 0, i, SRCCopy);
                    BitBlt(crtDC, 0, altura-i, largura, 4, MemDC, 0, altura-i, SRCCopy);
                    i := i + 4;
                    delay (5);
                end;
        end
    else
    if ansiUpperCase(efeito) = 'QUADRADOS' then
        begin
            i := 0;
            while ((i-3) <= altura div 2) and ((i-3) <= largura div 2) do
                begin
                    BitBlt(crtDC, i, 0, 4, altura, MemDC, i, 0, SRCCopy);
                    BitBlt(crtDC, largura-i, 0, 4, altura, MemDC, largura-i, 0, SRCCopy);
                    BitBlt(crtDC, 0, i, largura, 4, MemDC, 0, i, SRCCopy);
                    BitBlt(crtDC, 0, altura-i, largura, 4, MemDC, 0, altura-i, SRCCopy);
                    i := i + 4;
                    delay (5);
                end;
        end
    else
    if ansiUpperCase(efeito) = 'CRESCER' then
        begin
            i := 16;
            while i < largura div 2 do
                begin
                    x := largura div 2 - i;
                    y := altura div 2 - i;
                    if y > 0 then
                        i2 := i
                    else
                        begin
                            y := 0;
                            i2 := altura div 2;
                        end;
                    StretchBlt(crtDC, x, y, i*2, i2*2, MemDC, 0, 0, largura, altura, SRCCopy);
                    i := i + 16;
                    delay (10);
                end;
            BitBlt(crtDC, 0, 0, largura, altura, MemDC, 0, 0, SRCCopy);
        end
    else
    if ansiUpperCase(efeito) = 'PREENCHER' then
        begin
            dimq := 8;
            l := largura div dimq;
            a := altura div dimq;
            n := l * a;
            setLength(matAleat, n);
            for y := 0 to a-1 do
                for x := 0 to l-1 do
                    matAleat [y*l+x] := (y shl 16) or x;
            for i := 0 to n-1 do
                begin
                    r := random (n);
                    temp := matAleat[r];
                    matAleat[r] := matAleat[i];
                    matAleat[i] := temp;
                end;
            for i := 0 to n-1 do
                begin
                    x := matAleat [i] and $ffff;
                    y := (matAleat [i] shr 16) and $ffff;
                    bitBlt (crtdc, x*dimq, y*dimq, dimq, dimq, memDc, x*dimq, y*dimq, SRCCopy);
                    if i mod 512 = 0 then delay (5);
                end;
        end
    else
    if ansiUpperCase(efeito) = 'DIAGONAL' then
        begin
            i := 0;
            while i < largura do
                begin
                    BitBlt(crtDC, largura-i, altura-(trunc(i * 1.0*altura/largura)), largura, altura,
                           MemDC, 0, 0, SRCCopy);
                    i := i + 32;
                    delay (5);
                end;
            BitBlt(crtDC, 0, 0, largura, altura, MemDC, 0, 0, SRCCopy);
        end
    else
        BitBlt(crtDC, 0, 0, largura, altura, MemDC, 0, 0, SRCCopy);
end;

end.

