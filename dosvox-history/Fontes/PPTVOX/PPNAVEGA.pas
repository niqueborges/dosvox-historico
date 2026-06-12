unit ppnavega;

interface
uses
  dvCrt,
  dvWin,
  windows,
  sysUtils,
  ppjanela,
  ppvars;

procedure linkSlide (salto: integer);
procedure exibeSlide;
procedure recuaSlide;
procedure avancaSlide;

procedure avancaELeLinha (passo: integer);

implementation

{--------------------------------------------------------}

procedure linkSlide (salto: integer);
var apagaTela: boolean;
begin
    saltarSlide:= 0;
    nomeProg:= '';

    if (salto < 1) or (salto > nSlides) then
    begin
        sintetiza ('TELA INEXISTENTE');
        exit;
    end;

    tocarSlide:= true;
    tocarFundoMusical:= true;
    informarFoto:= true;
    ativarPlayer:= true;
    setCursorPos (1024, 768);

    if leAuto then
        primeiraVez:= true;

    sintPara;

    slideAtual := salto - 1;
    linhaAtual := -1;

    apagaTela := apagaSempreOFundo or (figuraDeFundo = '') or
                (slideAtual < 0) or (slideAtual > nSlides);
    redesenhaTelaGrafica (apagaTela);

    if trocSlides <> '' then
        sintSom ((trocSlides));

end;

{--------------------------------------------------------}

procedure exibeSlide;
begin
    visualizaTelaGrafica;
    if (not debugEditando) and (slideAtual >= 0) and (slideAtual <= nslides) then
        sintetiza (slides[slideAtual].titulo);
    linhaAtual := -1;
end;

{--------------------------------------------------------}

procedure recuaSlide;
var apagaTela: boolean;
begin

    saltarSlide:= 0;

    tocarSlide:= true;
    tocarFundoMusical:= true;
    informarFoto:= true;
    ativarPlayer:= true;
    setCursorPos (1024, 768);

    if leAuto then
        primeiraVez:= true;

    sintPara;
    slideAtual := slideAtual - 1;
    if slideAtual < 0 then
        begin
            slideAtual := 0;
            if primSlide <> '' then
                sintSom ((primSlide))
            else
            sintBip;
            delay (250);
        end;

    linhaAtual := -1;

    apagaTela := apagaSempreOFundo or (figuraDeFundo = '') or
                (slideAtual < 0) or (slideAtual > nSlides);
    redesenhaTelaGrafica (apagaTela);

    if trocSlides <> '' then
        sintSom ((trocSlides));

    if slideAtual >= 0 then
            sintetiza (slides[slideAtual].titulo);

end;

{--------------------------------------------------------}

procedure avancaSlide;
var apagaTela: boolean;
begin

    saltarSlide:= 0;

    tocarSlide:= true;
    tocarFundoMusical:= true;
    informarFoto:= true;
    ativarPlayer:= true;
    setCursorPos (1024, 768);

    if leAuto then
        primeiraVez:= true;

    sintPara;
    slideAtual := slideAtual + 1;
    if slideAtual > nSlides then
    begin
        slideAtual := nSlides - 1;
        if ultSlide <> '' then
            sintSom ((ultSlide))
         else
            sintBip;
        delay (250);
    end;

    linhaAtual := -1;

    apagaTela := apagaSempreOFundo or (figuraDeFundo = '') or
                (slideAtual < 0) or (slideAtual > nSlides);
    redesenhaTelaGrafica (apagaTela);

    if trocSlides <> '' then
        sintSom ((trocSlides));

    if slideAtual <= nSlides then
        if not ativFigSom then
            sintetiza (slides[slideAtual].titulo);

end;

{--------------------------------------------------------}

procedure avancaELeLinha (passo: integer);
var s: string;
    dc: HDC;
begin

    saltarSlide:= 0;
    nomeProg:= '';

    sintPara;

    with slides[slideAtual] do
    begin
        if linhas.count = 0 then
        begin
            sintBip; sintBip;
            sintSom ('PPNAEXLI');
            exit;
        end;
    end;

    if (slideAtual < 0) or (slideAtual > nslides) then
        begin
            sintBip; sintBip;
            sintetiza ('SLIDE INVÁLIDO');
            exit;
        end;

    dc := getDC (0);

    with slides[slideAtual] do
        begin
            linhaAtual := linhaAtual + passo;

            if linhaAtual < 0 then
                linhaAtual := -1
            else
                if linhaAtual >= linhas.count then
                    linhaAtual := linhas.count;

            if linhaAtual < 0 then
            begin
                sintSom ('PPTIT');
                if debugar then
                    if erroNoTitulo = true then
                        sintSom ('PPEFEIT1');
                setCursorPos (xtit - 10, ytit+40);
                sintetiza (titulo);
            end
            else
                if linhaAtual < linhas.count then
                begin

                    s:= linhas[linhaAtual];

                    if pos ('&', s) <> 0 then
                    begin
                        nomeProg:= copy (s, pos ('&', s) + 1, length (s));
                        delete (s, pos ('&', s) - 1, length (s));
                        sintSom ('PPPROG');
                    end;

                    if pos ('#', s) <> 0 then
                    begin
                        SaltarSlide:= strToInt(copy (s, pos ('#', s) + 1, length(s)));
                        delete (s, pos ('#', s) - 1, length (s));
                        sintSom ('PPLINK');
                    end;

                    if s[1] = ';' then
                        delete (s, 1, 1);

                    if s <> '' then
                        if trocLinhas <> '' then
                            sintSom ((trocLinhas));

                    if debugar then
                        if erroNaLinha[linhaAtual] = 1 then
                            sintSom ('PPEFEIT1');

                    if slides[slideAtual].modelo <> listaSimples  then
                        setCursorPos (xdet - 10, ydet + 30 + linhaAtual*40)
                    else
                        setCursorPos (xdet - 10, ydet + 10 + linhaAtual*40);

                    sintetiza (s);
                end
                else
                begin
                    linhaAtual:= linhas.count -1;
                    if ultLinha <> '' then
                        sintSom ((ultLinha))
                    else
                        sintBip;
                    delay (250);
//                    sintetiza (linhas[linhaAtual]);
                    s:= linhas[linhaAtual];

                    if pos ('&', s) <> 0 then
                    begin
                        nomeProg:= copy (s, pos ('&', s) + 1, length (s));
                        delete (s, pos ('&', s) - 1, length (s));
                        sintSom ('PPPROG');
                    end;

                    if pos ('#', s) <> 0 then
                    begin
                        saltarSlide:= strToInt(copy (s, pos ('#', s) + 1, length (s)));
                        delete (s, pos ('#', s) - 1, length (s));
                        sintSom ('PPLINK');
                    end;

                    if s[1] = ';' then
                        delete (s, 1, 1);

                    sintetiza (s);
                end;
        end;

    releaseDC (0, dc);
end;

end.
