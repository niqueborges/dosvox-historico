{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de exibição do jogo
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit joexibe;

interface

uses
    dvwin, dvcrt, jpeg, windows, sysutils, classes, graphics,
    jovars, jomsg, jomci, dvscript, dvWav, mmsystem;

function expandeVar (s: string): string;
procedure exibeSlide (pl: PLugar; n: integer);
procedure visualizaLugar (indLocal: integer;
                          var ultTecla: char; var lido: string);

implementation

{--------------------------------------------------------}
{                      cria fonte
{--------------------------------------------------------}

function criaFonte (tam: integer; nomeFonte: string; negrito: boolean;
                    var yf: integer): HFont;
var
    dc: HDC;
    tipoBold: integer;
begin
    dc := getDC (crtWindow);

    if negrito then tipoBold := FW_BOLD
               else tipoBold := FW_NORMAL;

    yf := trunc (tam / 72.0 * getDeviceCaps (dc, LOGPIXELSY));
    result := createFont (
               yf, 0, 0, 0,     { altura, largura, angulo, anguloletra }
               tipoBold,        { FW_NORMAL ou FW_BOLD }
               0, 0, 0,         { 1/0 se itálico, sublinhado, riscado }
               ANSI_CHARSET,
               OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, DEFAULT_QUALITY,
               DEFAULT_PITCH,
               @nomeFonte[1]);

    ReleaseDC(crtWindow, dc);
end;

{--------------------------------------------------------}
{                     cria a fonte
{--------------------------------------------------------}

function alocaFonte (crtDC: HDC): HFont;
var yfonte: integer;
begin
    with jogo, fonteTexto do
        begin
            hfonte := criaFonte (fonteTexto.tamFonte,
                   fonteTexto.nomeFonte, fonteTexto.negrito, yfonte);
            result := SelectObject(crtDc, jogo.fonteTexto.hfonte);
            larguraLetra := yfonte div 2;   // aproximação
            alturaLetra := yfonte;
        end;
end;

{--------------------------------------------------------}
{                     libera as fontes
{--------------------------------------------------------}

procedure liberaFonte;
begin
    deleteObject (jogo.fonteTexto.hfonte);
end;

{--------------------------------------------------------}
{    substitui iniciados por $ por variáveis do script
{--------------------------------------------------------}

procedure pegaVariaveisScript(var s: string);
var i, j: integer;
    vari, valorVariavel: string;
begin
    for i := length(s) downto 1 do
        begin
            if s[i] = '$' then
                begin
                     vari := '';
                     for j := i+1 to length(s) do
                         begin
                              if s[j] in [' ', '.', ','] then break;
                              vari := vari + s[j];
                         end;

                     valorVariavel := obtemVarLongaScript (vari);

                     if valorVariavel <> '' then
                         begin
                             delete (s, i, length(vari)+1);
                             insert (valorVariavel, s, i);
                         end;
                end;
        end;
end;

{--------------------------------------------------------}
{         expande uma variavel dentro de um nome
{--------------------------------------------------------}

function expandeVar (s: string): string;
var p, p2: integer;
    valorVariavel: string;
begin
    p := pos ('$', s);
    if p <> 0 then
        begin
            p2 := p+1;
            while (p2 <= length(s)) and (s[p2] <> '.') do
                p2 := p2 + 1;
            valorVariavel := obtemVarLongaScript (copy (s, p+1, p2-p));
            delete (s, p, p2-p);
            insert (valorVariavel, s, p);
        end;
    result := s;
end;

{--------------------------------------------------------}
{            exibe o slide[n] de um lugar
{--------------------------------------------------------}

procedure exibeSlide (pl: PLugar; n: integer);
var
    FJpeg    : TJpegImage;
    FTela    : TBitmap;
    FStreamJpg  : TStream;
    sl: PSlide;
    crtDc: HDC;
    fontAnt: HFont;
    x, y, i: integer;
    x0, y0: integer;
    p: array [1..100] of char;

    {--------------------------------------------------------}

    procedure calculaPosObjeto (posicao: string; teladx, telady, dxobj, dyobj: integer;
                                var x, y: integer);
    begin
        if pos('ESQUERDA',  ansiUpperCase (posicao)) <> 0 then
            x := 30
        else
        if pos('DIREITA',  ansiUpperCase (posicao)) <> 0 then
            x := (teladx-dxobj) - 30
        else
            x := (teladx-dxobj) div 2;

        if pos('CIMA', ansiUpperCase (posicao)) <> 0 then
            y := 30
        else
        if pos('BAIXO', ansiUpperCase (posicao)) <> 0 then
            y := (telady-dyobj) - 30
        else
            y := (telady-dyobj) div 2;
    end;

    {--------------------------------------------------------}

    procedure calculaTamTexto (texto: TStringList; dc: HDC; fonteLetras: TFonteLetras;
                               var dx, dy: integer);
    var dxl, i: integer;
        size: TSize;
    begin
        dy := fonteLetras.alturaLetra * texto.Count;
        for i := texto.count-1 downto 0 do
            begin
                if texto[i] <> '' then break;
                dy := dy - fonteLetras.alturaLetra;
            end;

        dx := 0;
        for i := 0 to texto.count-1 do
            begin
                GetTextExtentExPoint(dc, pchar(texto[i]), length(texto[i]), 9999, NIL, NIL, size);
                dxl := size.cx;
                if dxl > dx then dx := dxl;
            end;
    end;

    {--------------------------------------------------------}

    function transfCor (cor: string): integer;
    var n, erro: integer;
    begin
        transfCor := 0;
        cor := ansiUpperCase (trim(cor));
        if (cor <> '') and (cor[1] in ['0'..'9']) then
            begin
                val (cor, n, erro);
                if erro <> 0 then n := 0;
                transfCor := n;
            end
        else if (cor = 'PRETO') or
                (cor = 'PRETA') or (cor = 'BLACK')    then transfCor := 0
        else if (cor = 'AZUL') or (cor = 'BLUE')      then transfCor := 1
        else if (cor = 'VERDE') or (cor = 'GREEN')    then transfCor := 2
        else if (cor = 'CIANO') or (cor = 'CYAN')     then transfCor := 3
        else if (cor = 'VERMELHO') or
                (cor = 'VERMELHA') or (cor = 'RED')   then transfCor := 4
        else if (cor = 'ROXO') or
                (cor = 'ROXA') or (cor = 'MAGENTA')   then transfCor := 5
        else if (cor = 'MARROM') or (cor = 'BROWN')   then transfCor := 6
        else if (cor = 'CINZA') or (cor = 'GRAY')     then transfCor := 7
        else if (cor = 'AMARELO') or
                (cor = 'AMARELA') or (cor = 'YELLOW') then transfCor := 14
        else if (cor = 'BRANCO') or
                (cor = 'BRANCA') or (cor = 'WHITE')   then transfCor := 15;
    end;

    {--------------------------------------------------------}

var lpRect: TRect;
    corDoFundo: integer;
    s: string;
    salvaAttr: byte;
    fundo: string;
    dxt, dyt: integer;
    posic: string;

begin
    window (1, 1, 80, 25);
    gotoxy (1, 25);
    salvaAttr := TextAttr;

    GetWindowRect(crtWindow, lpRect);
    FTela := TBitmap.Create;
    FTela.Width := lpRect.Right + lpRect.Left;
    FTela.Height := lpRect.bottom + lpRect.top;
    FTela.PixelFormat := pf24bit;

    if pl^.corFundo = '' then
        corDoFundo := 0
    else
        begin
            corDoFundo := transfCor(pl^.corFundo);
            FTela.Canvas.Brush.Style := bsSolid;
            FTela.Canvas.Brush.Color := colorNumber (transfCor(pl^.corFundo));
            FTela.Canvas.FillRect(rect(0,0,Ftela.Width, Ftela.Height));
        end;

    fundo := jogo.fundoDefault;
    if pl^.fundo <> '' then fundo := expandeVar(pl^.fundo);
    if fileExists (fundo) then
        begin
            FStreamJpg := TFileStream.Create(fundo, fmOpenRead);
            FJpeg := TJPEGImage.Create;
            FJpeg.LoadFromStream(FStreamJpg);
            FTela.Canvas.StretchDraw(rect(0,0,Ftela.Width, Ftela.Height), FJpeg);
            FJpeg.Free;
            FStreamJpg.Free;
        end;

    sl := pl^.slides[n];
    if (n <= pl.numSlides) and (fileExists (pl^.slides[n]^.figura)) then
        begin
            FStreamJpg := TFileStream.Create(sl^.figura, fmOpenRead);
            FJpeg := TJPEGImage.Create;
            FJpeg.LoadFromStream(FStreamJpg);
            if sl^.posFigura = '' then
                posic := 'direita'
            else
                posic := sl^.posFigura;
            calculaPosObjeto (posic, FTela.Width, FTela.Height,
                              FJpeg.Width, FJpeg.Height, x, y);
            FTela.Canvas.Draw(x, y, FJpeg);
            FJpeg.Free;
            FStreamJpg.Free;
        end;

    crtDc := getDc (crtWindow);
    fontAnt := alocaFonte (crtDc);
    calculaTamTexto (sl^.texto, crtDc, jogo.fonteTexto, dxt, dyt);
    if sl^.posTexto = '' then
         if sl^.figura = '' then
             posic := 'centro'
         else
             posic := 'esquerda'
    else
        posic := sl^.posTexto;
    calculaPosObjeto (posic, FTela.Width, FTela.Height, dxt, dyt, x0, y0);

    if (pl^.corFundo = '') and (jogo.fundoDefault <> '') then
        setBkMode (crtDC, TRANSPARENT)
    else
        begin
            setBkMode (crtDC, OPAQUE);
            setBkColor (crtDC, colorNumber (corDoFundo));
        end;

    if jogo.fundoDefault = '' then
        begin
            textBackground (corDoFundo); 
            clrscr;
        end;

    if pl^.corLetra = '' then
        setTextColor (crtDC, colorNumber (15))
    else
        setTextColor (crtDC, colorNumber (transfCor(pl^.corLetra)));

    for i := 0 to sl^.texto.Count-1 do
        begin
            s := sl^.texto[i];
            pegaVariaveisScript(s);
            strPCopy (@p, s);
            TextOut (crtDc, x0, y0+(i*jogo.fonteTexto.alturaLetra), @p, length (s));
        end;

    SelectObject(crtDc, fontAnt);
    SetBkMode(crtDc, OPAQUE);
    SetTextAlign(CrtDc, TA_LEFT or TA_TOP);
    releaseDc (crtWindow, crtDc);

    FTela.Free;
    liberaFonte;
    TextAttr := salvaAttr;
end;

{--------------------------------------------------------}
{                     visualiza um lugar
{--------------------------------------------------------}

procedure visualizaLugar (indLocal: integer;
                          var ultTecla: char; var lido: string);
var n, i: integer;
    c: char;
    lug: PLugar;
    sl: PSlide;
    fimVis: boolean;
    s, s1: string;
begin
    if (indLocal <= 0) or (indLocal > jogo.numLugares) then
        begin
            sintBip;
            exit;
        end;

    window (1, 1, 80, 25);
    gotoxy (1, 80);
    ultTecla := ESC;
    lido := '';

    lug := jogo.lugares[indLocal];
    iniciaMciLugar (expandeVar(lug^.midiaLugar));

    clrscr;

    fimVis := false;
    n := 1;
    repeat
         if (n > lug^.numSlides) or (n < 1) then
             begin
                 sintBip;
                 c := readkey;
             end
         else
             begin
                 exibeSlide (lug, n);
                 sl := lug^.slides[n];
                 sintPara;

                 if sl^.midiaSlide <> '' then
                     begin
                         iniciaMciSlide (expandeVar(sl^.midiaSlide));
                         if sl^.esperaMidia then
                             begin
                                 while tocandoMciSlide and (not keypressed) do
                                     delay (100);
                                 terminaMciSlide;
                             end;
                     end;

                 limpaBufTec;

                 if sl^.falaTexto then
                     begin
                         s := '';
                         for i := 0 to sl^.texto.Count-1 do
                             begin
                                 s1 := sl^.texto[i];
                                 if s1 = '' then
                                     begin
                                          if s <> '' then
                                              begin
                                                  sintetiza (s);
                                                  s := '';
                                              end;
                                     end
                                 else
                                     begin
                                         pegaVariaveisScript(s1);
                                         s := s + ' ' + s1;
                                     end;
                             end;

                         if s <> '' then sintetiza (s);
                         while sintFalando do waitMessage;
                     end;

                 if keypressed then
                     c := readkey
                 else
                     if sl^.autoAvanca and (n < lug^.numSlides) then
                         c := ' '
                     else
                         c := readkey;
             end;

         if c = #0 then
             begin
                 c := readkey;
                 case c of
                     HOME: n := 1;
                     TEND: n := lug^.numSlides;
                     PGUP, ESQ:  if n > 1 then
                                       n := n - 1
                                 else
                                       sintbip;
                     PGDN, DIR:  if n < lug^.numSlides then
                                       n := n + 1
                                 else
                                       sintbip;
                 end;
             end
         else
             begin
                 if n = lug^.numSlides then
                            begin
                                insertKeyBuf(c);
                                lido := '';
                                ultTecla := sintEdita (lido, 1, 25, 80, true);
                                if (ultTecla = ENTER) or (ultTecla = ESC) then
                                    fimVis := true;
                            end
                 else
                 if (c = ' ') or (c = ENTER) then
                     begin
                         n := n + 1;
                         while n > lug^.numSlides do
                              begin
                                  sintBip;
                                  n := n - 1;
                              end;
                     end
                 else
                 if c = BS then
                     begin
                         n := n - 1;
                         while n < 1 do
                              begin
                                  sintBip;
                                  n := n + 1;
                              end;
                     end
                 else
                 if c = ESC then
                     begin
                         ultTecla := ESC;
                         terminaMciSlide;
                         fimVis := true;
                     end;
             end;

         terminaMciSlide;
    until fimVis;

    terminaMciLugar;
end;

end.
