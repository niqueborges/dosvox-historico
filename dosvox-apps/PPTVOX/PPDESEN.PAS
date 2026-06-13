{--------------------------------------------------------------}
{
{   PPTVOX - exibidor interativo de apresentações
[
{   Desenho dos elementos na tela gráfica
{
{   Autores: Antonio Borges, Bernard Condorcet e Mara Caldeira
{
{   Junho/2015
{
{--------------------------------------------------------------}

unit ppDesen;

interface

uses
    dvCrt,
    dvwin,
    dvJpeg,
    Windows,
    sysUtils,
    ppArq,
    ppvars,
    jpeg,
    graphics,
    classes;

procedure desenhaSlideCompleto (dc: HDC; ps: TPaintStruct);
procedure calculaPosicoes (dc: HDC);
procedure desenhaFundo (dc: HDC; ps: TPaintStruct; arquivo: string);
function tamanhoJpeg (nomeArq: string; var dx, dy: integer): boolean;
function jogaJpegNaJanela (dc: hdc;nomeArq: string; xdest1, ydest1, xdest2, ydest2:integer;
                           amplia, manterProporcao, centraliza: boolean): boolean;

implementation

var
    fatorXtela, fatorYtela: real;

{----------------------------------------------------------------------------}

procedure calculaPosicoes (dc: HDC);
begin
    // compensa coordenadas com a proporção da tela em relação a 1024 x 768

    fatorXtela := larguraTela / 1024;
    fatorYtela := alturaTela / 768;

    {--- calcula posição das coisas na tela ---}

    with slides[slideAtual] do
        case modelo of
            capa:
                begin
                    //@@@setTextAlign (dc, TA_CENTER);
                    xtit := getDeviceCaps (dc, HORZRES) div 2;
                    ytit := getDeviceCaps (dc, VERTRES) div 7;

                    xdet := xtit;
                    ydet := ytit + trunc (200 * fatorYtela);
                end;

            listaSimples:
                begin
                    //@@@setTextAlign (dc, TA_CENTER);
                    xtit := larguraTela div 2;
                    ytit := alturaTela div 7;

                    xdet := xtit;
                    ydet := alturaTela div 3;
                end;

            figura:
                begin
                    //@@@setTextAlign (dc, TA_CENTER);

                    xtit := larguraTela div 2;
                    ytit := ytitulo;

                    xdet := larguraTela div 2;
                    ydet := trunc (alturaTela div 5);

                    x1fig := trunc(larguraTela div 4 - (10 * fatorXtela) );
                    y1fig := trunc (alturaTela div 2 - (100 * fatorYtela));

                    x2fig := trunc(larguraTela div 2 +(250 * fatorXtela));
                    y2fig := trunc(alturatela - 50)
                end;

            video:
                begin
                    //@@@setTextAlign (dc, TA_CENTER);
                    xtit := larguraTela div 2;
                    ytit := alturaTela div 3;
                    xdet := xtit;
                    ydet := ytit + trunc(200 * fatorYtela);
                end;

            textofigura:
                begin
                    //@@@setTextAlign (dc, TA_CENTER);
                    xtit := trunc(larguraTela div 2);// - (100*fatorXtela));
                    ytit := 30 * trunc(fatorXtela);

                    //@@@setTextAlign(dc,TA_LEFT);

                    x1fig := larguraTela div 20;
                    y1fig := alturaTela div 30;

                    x2fig := ((larguraTela div 2)- trunc(3 * fatorXtela));
                    y2fig := alturaTela - (alturaTela div 14);

(*
x1Fig := 300;
y1Fig := 300;
x2Fig := x1Fig + 200;
y2Fig := Y1Fig + 200;
*)

                    xdet := trunc((larguraTela div 2) + (8 * fatorXtela));
                    ydet := trunc(yFigura* (3 * fatorYtela));
                end;

        end;
end;

{----------------------------------------------------------------------------}

procedure desenhaSlideCompleto (dc: HDC; ps: TPaintStruct);

{--- Nota: esta rotina é chamada a partir de um callback, nesta implementação ---}

var
    salvaFonteAnterior: HFont;
    i,j: integer;
    s, ss: string;
    alinhamentoPadrao: word;
    dim: integer;
    deletTit: integer;
    deletLin: array [0..20] of integer;
    x: integer;

const bullet: pchar = #$b7;
      setinha: pchar = '    ' + #$ae;


    function dimensaoTexto (texto: string): integer;
    var tam: TSize;
    begin
        with slides[slideAtual] do
            getTextExtentPoint32 (dc, pchar(texto), length(texto), tam);

        if copy (texto, 1, 1) = '.'   then tam.cx := tam.cx + 25
        else
        if copy (texto, 1, 3) = '-->' then tam.cx := tam.cx + 50;

        result := tam.cx;
    end;

    procedure consisteDimensaoTitulo;
    begin
        if debugar then
            with slides[slideAtual] do
            begin
                erroNoTitulo:= false;
                erroNaFigura:= false;
                dim := dimensaoTexto (titulo);
                if (modelo = capa) or (modelo = figura) or (modelo = video) or (modelo = textofigura) then
                    dim := dim div 2;
                if xtit + dim >= larguraTela then
                    begin
                        erroNoTitulo:= true;
                        s:= titulo;
                        deletTit:= 0;
                        repeat
                            delete (s, length (s), 1);
                            deletTit:= deletTit + 1;
                            dim := dimensaoTexto (s);
                            if (modelo = capa) or (modelo = figura) or (modelo = video)or (modelo = textofigura) then
                                dim := dim div 2;
                        until xtit + dim < larguraTela;
                    end;
        end;
    end;

    procedure debugaAparencia;
    var j: integer;
    begin
        if debugar then
        with slides[slideAtual] do
        begin
            sintDimensoesOK:= true;

            if erroNoTitulo then
                begin
                    sintSom ('PPDIMNAO');
                    delay (100);
                    sintSom ('PPREETIT'); {('Deve-se reeditar o título');}
                    delay (100);
                    sintSom ('PPREMAPR'); {('Remova aproximadamente ');}
                    sintetiza (intToStr(deletTit));
                    sintSom ('PPCARAC'); {(' caracteres');}
                    delay (100);
                    sintDimensoesOK:= false;
                end;
            if erroNaFigura then
                begin
                    sintSom ('PPDIMNAO');
                    delay (100);
                    sintSom ('PPFIGNAO'); {('A figura indicada não existe');}
                    delay (100);
                    sintDimensoesOK:= false;
                end;

            for j := 0 to linhas.Count-1 do
                if erroNaLinha[j] = 1 then
                    begin
                        sintSom ('PPDIMNAO');
                        delay (100);
                        sintSom ('PPREELIN'); {('Deve-se reeditar a linha ');}
                        sintetiza (intToStr (j + 1));
                        delay (100);
                        sintSom ('PPREMAPR'); {('Remova aproximadamente ');}
                        sintetiza (intToStr (deletLin[j]));
                        sintSom ('PPCARAC'); {(' caracteres');}
                        delay (100);
                        sintDimensoesOK:= false;
                    end;

            if sintDimensoesOK then
            begin
                sintSom ('PPDIMOK');
                delay (100);
                sintSom ('PPBEMDIM'); {('Bem dimensionado');}
            end;
        end;
    end;

begin
    alinhamentoPadrao := GetTextAlign (dc);
    SetBkMode(dc, TRANSPARENT);

    if maiuscAnsi(corLetra) = 'BRANCA' then
        textoBranco:= true
    else
        textoBranco:= false;

    if textoBranco then
        SetTextColor(dc, RGB (255, 255, 255))
    else
        SetTextColor(dc, RGB (0, 0, 0));

    (* Nota: se precisar, minhaPS contém o também o indicativo da área a desenhar *)

    if not debugCriando then
        if (slideAtual < 0) or (slideAtual >= nSlides) then
        begin
            setTextColor (dc, RGB (0, 0, 255));
            TextOut (dc, 20, 20, 'Fim da apresentação, aperte ESC', 31);
            sintBip; sintBip;
            exit;
        end;

    {--- desenha as coisas ---}

    calculaPosicoes (dc);
    with slides[slideAtual] do
        begin
            if (trim(fundo) <> '') and (existeArq(trim(fundo))) then
                  jogaJpegNaJanela (dc, fundo, 0, 0, larguraTela, alturaTela,
                                    true, false, false)
            else
                  jogaJpegNaJanela (dc, figuraDeFundo, 0, 0, larguraTela, alturaTela,
                                    true, false, false);

            salvaFonteAnterior := SelectObject(dc, fonteTitulo);

            {--- desenha o titulo ---}

            consisteDimensaoTitulo;

            setTextAlign (dc, TA_CENTER);
            TextOut (dc, xtit, ytit, @titulo[1], length (titulo));

            {--- desenha a figura ---}

           if ((modelo = figura) or  (modelo = textofigura))  and (trim(arquivo) <> '') then
                    if existeArq (arquivo) then
                    begin
                           jogaJpegNaJanela (dc,arquivo,
                                    x1fig, y1fig, x2fig, y2fig, true, true, true);
                           if modelo <> textofigura then setTextAlign (dc, TA_CENTER) //O nome vai abaixo centrado
                    end
                else
                    erroNaFigura:= true;

            {--- desenha as linhas---}

            for j:=0 to 20 do
                erroNaLinha[j] := 0;

            if modelo = textofigura then
                setTextAlign (dc, TA_LEFT)
            else
                setTextAlign (dc, TA_CENTER);
            for i := 0 to linhas.Count-1 do

                begin
                    s := linhas[i];
                    if pos ('&', s) <> 0 then
                        delete (s, pos ('&', s) - 1, length (s));
                    if pos ('#', s) <> 0 then
                        delete (s, pos ('#', s) - 1, length (s));
                    if s[1] = ';' then
                        delete (s, 1, 1);
                    if trim(s) = '' then continue;

                    SelectObject (dc, fonteDetalhe);
                    dim := dimensaoTexto (s);
                    if (modelo = capa) or (modelo = figura) or (modelo = video) or  (modelo = textofigura)  then
                        dim := dim div 2;
                    if xdet + dim >= larguraTela then
                        begin
                            erroNaLinha[i]:= 1;
                            ss:= s;
                            deletLin[i]:= 0;
                            repeat
                                delete (ss, length (ss), 1);
                                deletLin[i]:= deletLin[i] + 1;
                                dim := dimensaoTexto (ss);
                                if (modelo = capa) or (modelo = figura) or (modelo = video) or (modelo = textofigura) then
                                    dim := dim div 2;
                            until xdet + dim < larguraTela;
                        end;

                    x := xdet;
                    if copy (s, 1, 1) = '.'  then
                        begin
                            SelectObject (dc, fonteSimbolo);
                            setTextAlign (dc, TA_LEFT);
                            TextOut (dc, larguratela div 5, ydet + i*40, bullet, 1);
                            delete (s, 1, 1);

                            setTextAlign (dc, TA_LEFT);
                            SelectObject (dc, fonteDetalhe);
                            TextOut (dc, larguratela div 4, ydet + i*40, @s[1], length(s));

                        end
                    else
                    if copy (s, 1, 3) = '-->' then
                        begin
                            setTextAlign (dc, TA_LEFT);
                            SelectObject (dc, fonteSimbolo);
                            TextOut (dc, larguratela div 5, ydet + i*40, setinha, 5);
                            delete (s, 1, 3);

                            setTextAlign (dc, TA_LEFT);
                            SelectObject (dc, fonteDetalhe);
                            TextOut (dc, larguratela div 4, ydet + i*40, @s[1], length(s));

                        end
                      else
                        begin
                            SelectObject (dc, fonteDetalhe);
                            TextOut (dc, x, ydet + i*40, @s[1], length(s));
                        end;
                end;

            {deixa escolhida a fonte anterior}
            SelectObject(dc, salvaFonteAnterior);

            SetTextAlign (dc, alinhamentoPadrao);
            SetBkMode(dc, OPAQUE);

            debugaAparencia;
        end;

end;

{----------------------------------------------------------------------------}

function tamanhoJpeg (nomeArq: string; var dx, dy: integer): boolean;
var
    FStreamJpg  : TStream;
    FJpeg:  TJPEGImage;
begin
    dx := 0;
    dy := 0;
    try
        FStreamJpg := TFileStream.Create(nomeArq, fmOpenRead); // trago arquivo jpeg para o canto superior esquerdo deste bitmap
        FJpeg := TJPEGImage.Create;
        FJpeg.LoadFromStream(FStreamJpg);
        dx := FJpeg.width;
        dy := FJpeg.Height;
        FJpeg.Free;
        FStreamJpg.Free;
        result := true;
    except
        result := false;
    end;
    x2fig :=dx;
    y2fig :=dy ;
end;
{------------------------------------------------------------------------------}

function jogaJpegNaJanela (dc: hdc;nomeArq: string;
                           xdest1, ydest1, xdest2, ydest2:integer;
                           amplia, manterProporcao, centraliza: boolean): boolean;
var
    FTela: TBitmap;
    FStreamJpg  : TStream;
    FJpeg:  TJPEGImage;
    crtDC, memDC: HDC;
    dxmax, dymax: integer;
    dximagem, dyimagem: integer;
    fatorEscalax, fatorEscalay: real;
    dxfinal, dyfinal: integer;
    xfinal, yfinal: integer;

begin
    if not fileExists (nomeArq) then
        begin
            result := false;
            exit;
        end;

    dxmax := xdest2 - xdest1;
    dymax := ydest2 - ydest1;

    FStreamJpg := TFileStream.Create(nomeArq, fmOpenRead); // trago arquivo jpeg para o canto superior esquerdo deste bitmap
    FJpeg := TJPEGImage.Create;
    FJpeg.LoadFromStream(FStreamJpg);
    dximagem := FJpeg.width;
    dyimagem := FJpeg.Height;

    fatorEscalax := dxmax / dximagem;
    fatorEscalay := dymax / dyimagem;

    // se manter proporção, escalona em x e y, usando a menor escala

    if manterProporcao then
        if  fatorEscalax < fatorEscalay then
            fatorEscalay := fatorEscalax
        else
            fatorEscalax := fatorEscalay;

    dxfinal := trunc (dximagem * fatorEscalax);
    dyfinal := trunc (dyimagem * fatorEscalay);

    // calcula onde a imagem ficará na área destino

    if not centraliza then
        begin
            xfinal := xdest1;
            yfinal := ydest1;
        end
    else
        begin
          xfinal := xdest1 + (dxmax-dxfinal)div 2;
          yfinal := ydest1 + (dymax-dyfinal)div 2;
       end;

    //  aloca bitmap com tamanho da largura e altura da tela

    FTela := TBitmap.Create;
    FTela.Width := dxfinal;
    FTela.Height := dyfinal;
    FTela.PixelFormat := pf24bit;

    // abre o jpeg, redimensiona e joga no bitmap da tela

    FTela.Canvas.StretchDraw (rect(0, 0, dxfinal, dyfinal), FJpeg);

    FJpeg.Free;
    FStreamJpg.Free;

    // crio uma área de conversão compatível

    crtDc := Dc;
    Memdc := CreateCompatibleDC (crtDc);
    SelectObject(MemDC, FTela.Handle);

    // jogo na tela física

    BitBlt(crtDC, xfinal, yfinal, dxfinal, dyfinal, MemDC, 0, 0, SRCCopy);

    // limpo áreas intermediárias
    DeleteDC(MemDC);
    FTela.Free;

    // instrumentalização para debug

  {  MoveToEx (crtdc, 0, ydest1, NIL);
    LineTo (crtdc,  1440, ydest1);
    MoveToEx (crtdc, 0, ydest2, NIL);
    LineTo (crtdc,  1440, ydest2);
    MoveToEx (crtdc, xdest1, 0, NIL);
    LineTo (crtdc,  xdest1, 900);
    MoveToEx (crtdc, xdest2, 0, NIL);
    LineTo (crtdc,  xdest2, 900);
   }
    result := true;
end;

{----------------------------------------------------------------------------}

procedure desenhaFundo (dc: HDC; ps: TPaintStruct;
                         arquivo: string);
var arqbmp, ext: string;
    MemDc: HDC;

begin
    larguraTela := getDeviceCaps (dc, HORZRES);
    alturaTela := getDeviceCaps (dc, VERTRES);

    ext := ansiUpperCase (extractfileext (arquivo));
    if (ext = 'JPEG') or (ext = 'JPG') or (ext = '.JPEG') or (ext = '.JPG') then
       begin
           arqbmp := 'c:\winvox\$.BMP';    // Mudar para um arquivo temporário decente
           CopyJpegToBmp(arquivo, arqbmp);
       end
    else
        arqbmp := arquivo;

    if openBmp (arqbmp) then    // só funciona com bmp de 24 bits
       begin
           Memdc := CreateCompatibleDC (dc);
           SelectObject(MemDC, BMPHandle);

           stretchBlt (dc,
                       0, 0, larguraTela, alturaTela,
                       MemDC, 0, 0, BMPWidth, BMPHeight,
                       SRCCopy);
           DeleteDC(MemDC);
           closeBmp;
       end;

    if (ext = 'JPEG') or (ext = 'JPG') then
      DeleteFile ('c:\winvox\$.BMP');
end;

end.
