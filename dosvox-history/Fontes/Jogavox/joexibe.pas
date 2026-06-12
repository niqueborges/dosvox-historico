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
    dvwin, dvcrt, dvWav, mmsystem, jpeg, pngImage, windows, sysutils, classes,
    graphics, jovars, jomsg, jomci, joefeito, dvscript, strUtils;

function expandeVar (s: string): string;
procedure exibeSlide (pl: PLugar; n: integer; efeito: string);
procedure visualizaLugar (indLocal: integer;
                          var ultTecla: char; var lido: string);

function obtemVarLongaScript (vari: string): string;
procedure alteraVarLongaScript (vari, valor: string);
function extIS (filename, ext: string): boolean;

implementation

{--------------------------------------------------------}
{            pega/altera uma variável do scriptvox       }
{--------------------------------------------------------}

function obtemVarLongaScript (vari: string): string;
begin
    vari := '$' + vari;
    if not extraiValor(vari, result) then
        result := '';
end;

{--------------------------------------------------------}

procedure alteraVarLongaScript (vari, valor: string);
begin
    vari := '$' + vari;
    guardaValor (vari, valor);  // ignora erros
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
                              if not (s[j] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) then break;
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
            s := s + '.';  // sentinela
            p2 := p+1;
            while s[p2] <> '.' do
                p2 := p2 + 1;
            valorVariavel := obtemVarLongaScript (copy (s, p+1, p2-p-1));
            delete (s, p, p2-p);
            insert (valorVariavel, s, p);
            delete (s, length(s), 1);  // tira sentinela
        end;
    result := s;
end;

{--------------------------------------------------------}
{            testa o tipo da extensão
{--------------------------------------------------------}

function extIS (filename, ext: string): boolean;
begin
    if (ext <> '') and (ext[1] <> '.') then
        ext := '.' + ext;
        result :=(AnsiEndsText(ext, filename));
end;

{--------------------------------------------------------}
{            exibe o slide[n] de um lugar
{--------------------------------------------------------}


procedure exibeSlide (pl: PLugar; n: integer; efeito: string);
var
    FFundo   : TBitmap;
    FFigura  : TPNGObject;

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

    procedure carregaFundoComArquivo (arqFundo: string);
    var
        FJpeg: TJpegImage;
        FPng:  TPNGObject;
    begin
        arqFundo := expandeVar(arqFundo);
        if (arqFundo = '') or (not fileExists (arqFundo)) then
            exit;

       if extIS (arqFundo, 'JPG') or extIS (arqFundo, 'JPEG') then
            begin
                FJpeg := TJPEGImage.Create;
                FJpeg.LoadFromFile (arqFundo);
                FFundo.Canvas.StretchDraw(rect(0,0,FFundo.Width-1, FFundo.Height-1), FJpeg);
                FJpeg.Free;
            end
        else
        if extIS (arqFundo, 'PNG') then
            begin
                FPng := TPngObject.Create;
                FPng.LoadFromFile (arqFundo);
                FFundo.Canvas.StretchDraw(rect(0,0,FFundo.Width-1, FFundo.Height-1), FPng);
                FPng.Free;
            end
        else
        if extIS (arqFundo, 'BMP') then
            FFundo.LoadFromFile(arqFundo);
    end;

    {--------------------------------------------------------}

    function carregaFundoComCor (corAPintar: string): integer;
    var codCorFundo: integer;
    begin
        if corAPintar = '' then
            corAPintar := 'PRETO';
        codCorFundo := transfCor(corAPintar);

        FFundo.Canvas.Brush.Style := bsSolid;
        FFundo.Canvas.Brush.Color := colorNumber (codCorFundo);
        FFundo.Canvas.FillRect(rect(0,0,FFundo.Width, FFundo.Height));
        result := codCorFundo;
    end;

    {--------------------------------------------------------}


    procedure carregaFiguraComArquivo (arqFigura: string);
    var
        FJpeg: TJpegImage;
        FPng:  TPNGObject;
        FBmp:  TBitmap;
    begin
        if extIS (arqFigura, 'JPG') or extIS (arqFigura, 'JPEG') then
            begin
                FBmp := TBitmap.Create;
                FJpeg := TJPEGImage.Create;
                FJpeg.LoadFromFile (arqFigura);
                FBmp.Assign (FJpeg);
                FJpeg.Free;
                FFigura.Assign(FBmp);
                FBmp.Free;
            end
        else
        if extIS (arqFigura, 'PNG') then
            begin
                FPng := TPngObject.Create;
                FPng.LoadFromFile (arqFigura);
                FFigura.Assign(FPng);
                FPng.Free;
            end
        else
        if extIS (arqFigura, 'BMP') then
            begin
                FBmp := TBitmap.Create;
                FBmp.LoadFromFile (arqFigura);
                FFigura.Assign(FBmp);
                FBmp.Free;
            end
        else
            begin
            end;
    end;

    {--------------------------------------------------------}

    procedure carimbaFundoComFigura (x0Fig, y0Fig: integer);
    begin
        FFundo.Canvas.Draw(x0Fig, y0Fig, FFigura);
    end;

    {--------------------------------------------------------}

    procedure set_bkMode_textColor (memDC: HDC; codifCorFundo: integer);
    begin
        if pl^.corFundo = '' then
            setBkMode (memDC, TRANSPARENT)
        else
            begin
                setBkMode (memDC, OPAQUE);
                setBkColor (memDC, colorNumber (codifCorFundo));
            end;

        if pl^.corLetra = '' then
            if jogo.corLetraDefault = '' then
                setTextColor (memDC, colorNumber (transfCor('BRANCO')))
            else
                setTextColor (memDC, colorNumber (transfCor(jogo.corLetraDefault)))
        else
            setTextColor (memDC, colorNumber (transfCor(pl^.corLetra)));
    end;

    {--------------------------------------------------------}

    procedure calculaPosObjeto (posicao: string; teladx, telady, dxobj, dyobj: integer;
                                var x, y: integer);
    begin
        if pos('ESQUERDA',  ansiUpperCase (posicao)) <> 0 then
            x := (teladx div 2 - dxobj) div 2
        else
        if pos('DIREITA',  ansiUpperCase (posicao)) <> 0 then
            x := teladx div 2 + ((teladx div 2 - dxobj) div 2)
        else
            x := (teladx - dxobj) div 2;

        if x < 0 then x := 0;
        if x+dxobj >= teladx then x := teladx-dxobj-1;

        if pos('CIMA', ansiUpperCase (posicao)) <> 0 then
            y := (telady div 2 - dyobj) div 2
        else
        if pos('BAIXO', ansiUpperCase (posicao)) <> 0 then
            y := telady div 2 + ((telady div 2 - dyobj) div 2)
        else
            y := (telady - dyobj) div 2;

        if y < 0 then y := 0;
        if y+dyobj >= telady-30 then y := telady-dyobj-31;
    end;

    {--------------------------------------------------------}

var
    salvaAttr: byte;

    sl: PSlide;

    lpRect: TRect;
    i, v: integer;
    s: string;

    x0Texto, y0Texto: integer;
    dxTexto, dyTexto, dyLetra: integer;
    x0Fig, y0Fig: integer;

    posicTexto, posicFigura: string;
    corAPintar: string;
    crtDc, MemDc: HDC;

begin
    gotoxy (1, 25);
    salvaAttr := TextAttr;

    // -------------- cria bitmap para o fundo

    GetClientRect(crtWindow, lpRect);
    FFundo := TBitmap.Create;
    FFundo.PixelFormat := pf32bit;
    FFundo.Width := lpRect.Right - lpRect.Left;
    FFundo.Height := lpRect.bottom - lpRect.top-42;
    FFigura := TPNGObject.Create;

    // -------------- pinta o fundo geral com a cor padrão e pode ativar imagem de fundo

    if pl^.corFundo = '' then corAPintar := jogo.corFundoDefault
                         else corAPintar := pl^.corFundo;
    carregaFundoComCor (corAPintar);

    carregaFundoComArquivo (jogo.fundoDefault);
    carregaFundoComArquivo (pl^.fundo);

    // -------------- prepara as figuras A e B do lugar  (provisório)

    carregaFundoComArquivo (pl^.imagemA);
    carregaFundoComArquivo (pl^.imagemB);

    // -------------- prepara a figura e calcula seu tamanho

    sl := pl^.slides[n];
    if (n <= pl.numSlides) and (fileExists (sl^.figura)) then
        carregaFiguraComArquivo(sl^.figura);

    // -------------- cria fonte e calcula o tamanho do texto

    FFundo.Canvas.Font.Name := jogo.fonteTexto.nomeFonte;
    FFundo.Canvas.Font.Size := -jogo.fonteTexto.tamFonte;
    FFundo.Canvas.Font.Color := colorNumber (transfCor(pl^.corLetra));
    FFundo.Canvas.Brush.Style := bsClear;
    if jogo.fonteTexto.negrito then
        FFundo.Canvas.Font.Style := [fsBold];

    dxTexto := 0;
    for i := 0 to sl^.texto.count-1 do
        begin
            v := FFundo.Canvas.TextWidth (sl^.texto[i]);
            if v > dxTexto then
                 dxTexto := v;
        end;

    dyTexto := 0;
    dyLetra := FFundo.Canvas.TextHeight ('ÁÇ') * 3 div 2;  // espaço 1,5
    for i := sl^.texto.count-1 downto 0 do
        if sl^.texto[i] <> '' then
            begin
                dyTexto := (i+1) * dyLetra;
                break;
            end;

    // -------------- calcula as posições do texto e da figura

    if sl^.posTexto <> ''  then
        posicTexto := sl^.posTexto
    else
        if FFigura.Width <> 0 then posicTexto := 'esquerda'
                              else posicTexto := 'centro';

    if sl^.posFigura <> ''  then
        posicFigura := sl^.posFigura
    else
        if dxTexto <> 0 then posicFigura := 'direita'
                        else posicFigura := 'centro';

    calculaPosObjeto (posicTexto, FFundo.Width, FFundo.Height,
                      dxTexto, dyTexto,
                      x0Texto, y0Texto);

    calculaPosObjeto (posicFigura, FFundo.Width, FFundo.Height,
                      FFigura.Width, FFigura.Height, x0Fig, y0Fig);

    // -------------- copia o texto e o fundo para a tela

    for i := 0 to sl^.texto.Count-1 do
        begin
            s := sl^.texto[i];
            pegaVariaveisScript(s);
            FFundo.Canvas.TextOut(x0Texto, y0Texto+(i*dyLetra), s);
        end;

    FFundo.Canvas.Draw(x0Fig, y0Fig, FFigura);

    // -------------- copia o fundo para a tela

    if efeito = 'minitela' then
        begin
        end
    else
        begin
            if efeito <> '' then
                mostraComEfeito (efeito, crtDC, memDC, FFundo.Width, FFundo.Height);

            FFundo.SaveToFile(arqTempGrafico);
            openBMP(arqTempGrafico);
            paintBmp (0,0);
        end;

    FFundo.Free;
    FFigura.Free;

    TextAttr := salvaAttr;
end;

{--------------------------------------------------------}
{                espera um tempo ou tecla
{--------------------------------------------------------}

function espera (tempo: string): char;
var t, erro: integer;
    c: char;
    bipando: boolean;
begin
    bipando := false;
    tempo := trim (tempo);
    if ansiUpperCase(copy (tempo, length(tempo)-1, 2)) = 'MS' then
        begin
            delete (tempo, length(tempo)-1, 2);
            tempo := trim (tempo);
            val (tempo, t, erro);
            if erro <> 0 then t := 1000;
        end
    else
        begin
            if ansiUpperCase(copy (tempo, length(tempo)-3, 4)) = 'BIPS' then
                begin
                    delete (tempo, length(tempo)-3, 4);
                    bipando := true;
                end
            else
            if ansiUpperCase(copy (tempo, length(tempo), 1)) = 'S' then
                delete (tempo, length(tempo), 1);
            tempo := trim (tempo);
            val (tempo, t, erro);
            if erro <> 0 then
                t := 1000
            else
                t := t * 1000;
        end;

    c := ' ';
    repeat
        if keypressed then
            begin
                c := readkey;
                if c = #$0 then c := readkey;
            end;
        delay (50);
        t := t - 50;
        if bipando and ((t mod 1000) = 0) then sintClek;
    until t <= 0;

    result := c;
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
    nomeSom, sons: string;
    col: integer;
    sintetizando: boolean;
    aFalar: string;

begin
    if (indLocal <= 0) or (indLocal > jogo.numLugares) then
        begin
            sintBip;
            exit;
        end;

    window (1, 1, 80, 25);
    gotoxy (1, 25);
    clreol;
    ultTecla := ESC;
    lido := '';

    lug := jogo.lugares[indLocal];
    iniciaMciLugar (expandeVar(lug^.midiaLugar));

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
                 sl := lug^.slides[n];
                 exibeSlide (lug, n, sl.efeito);
                 sintPara;

                 if sl^.midiaSlide <> '' then
                     begin
                         sons := expandeVar(sl^.midiaSlide);
                         repeat
                             col := pos ('|', sons);
                             if col <> 0 then
                                 begin
                                     nomeSom := trim(copy(sons, 1, col-1));
                                     delete (sons, 1, col);
                                     if nomeSom <> '' then
                                         begin
                                             iniciaMciSlide (nomeSom);
                                             while tocandoMciSlide and (not keypressed) do
                                                 delay (100);
                                             terminaMciSlide;
                                         end;
                                 end;
                         until col = 0;

                         iniciaMciSlide (sons);
                         if sl^.esperaMidia then
                             begin
                                 textRefreshInhibited := true;
                                 while tocandoMciSlide and (not keypressed) do
                                     delay (100);
                                 textRefreshInhibited := false;
                                 terminaMciSlide;
                             end;
                     end;

                 limpaBufTec;

                 // a variável fala texto pode os seguintes valores
                 // sim ou branco   usa sintetizador se narrando
                 // não             não sintetiza nunca
                 // "texto"         sintetiza sempre (pode ter variáveis no texto)
                 //                 ex.: "sua pontuação foi $pontos"

                 aFalar := trim(sl^.falaTexto);
                 if copy (aFalar, 1, 1) = '"' then
                     begin
                         delete (aFalar, 1, 1);
                         if copy (aFalar, length(aFalar), 1) = '"' then
                             delete (aFalar, length(aFalar), 1);
                         sintetiza (expandeVar(aFalar));
                         while sintFalando do waitMessage;
                     end
                 else
                     begin
                         sintetizando := (aFalar = '') or
                                         (ansiUpperCase(copy (aFalar, 1, 1)) <> 'N');
                         if sintetizando and jogo.narrando then
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
                     end;

                 if keypressed then
                     c := readkey
                 else
                     begin
                         if (sl^.avancaEm = '') or
                            (upcase (sl.avancaEm[1]) = 'N') then
                                c := readkey
                         else
                         if sl.avancaEm[1] in ['0'..'9'] then
                             begin
                                  c := espera (sl.avancaEm);
                                  if (c = ' ') and (n = lug^.numSlides) then
                                      c := ENTER;
                             end
                         else
                         if (n < lug^.numSlides) and
                                 ((ansiUpperCase(sl.avancaEm) = 'AUTO') or
                                  (upcase (sl.avancaEm[1]) = 'S'))  then
                              c := ' '
                         else
                              c := readkey;
                     end;
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
                                lido := '';
                                if c = ENTER then
                                    ultTecla := ENTER
                                else
                                    begin
                                        insertKeyBuf(c);
                                        ultTecla := sintEdita (lido, 1, 25, 40, true);
                                    end;
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

