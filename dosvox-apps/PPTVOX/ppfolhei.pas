Unit ppFolhei;

interface

uses dvCrt, dvWin, dvForm, dvArq, dvDic, dvHora,
    windows, sysUtils,
    ppEstilo, ppdic, ppEdita, ppArq, ppDesen, ppJanela, ppNavega, ppCria, ppMsg, ppVars;

procedure editaLinhas;
procedure falaQualDeQuantos;
procedure editaTitulos;

implementation

var linha_ed: string;

{--------------------------------------------------------}

procedure indentarLinha;
var nivel: char;
begin

    with slides[slideAtual] do
        if modelo <> listaSimples then
        begin
            sintBip; sintBip;
            sintetiza ('FUNÇÃO DISPONÍVEL APENAS PARA O MODELO LISTA SIMPLES');
            exit;
        end;

    writeln;
    mensagem ('PPINDEN', 1); {('Indentando');}
    delay (100);

    writeln;
    mensagem ('PPNIV12', 0); {('Nível 1 ou 2 ? ');}
    nivel:= sintReadkey;
    writeln (nivel);

    if nivel = '1' then
        insert ('.', linha_ed, 1)
    else
    if nivel = '2' then
        insert ('-->', linha_ed, 1)
    else
    begin
        mensagem ('PPOPECAN', 1);
        exit;
    end;

    salvarSlide:= true;

    mensagem ('PPOK', 1);

end;

{--------------------------------------------------------}

procedure remove (qualslide: integer);
var estaSelec: boolean;
    opcao: char;
    s: string;
    i: integer;
    nitem: integer;

begin
    nitem := qualSlide + 1;
    folheiaObtemItem (nitem, s, estaSelec);

    gotoxy (1, 20);
    writeln;
    mensagem ('PPCONREM', 0); {('Confirma a remoção de : ');}
    sintWrite (s);
    write (' ? ');
    opcao := sintReadkey;
    writeln (opcao);

    if upcase (opcao) = 'S' then
        begin
            mensagem ('PPOKREM', 1); {('OK, removido');}

            if slides[qualSlide].linhas <> NIL then // libera as linhas do slide
                slides[qualSlide].linhas.free;

            for i := qualSlide to nslides-2 do    // remove da estrutura
                slides[i] := slides[i+1];

            nslides := nslides - 1;

            folheiaRemoveItem(nitem);
        end
        else
        mensagem ('PPDESIST', 1);

end;

{--------------------------------------------------------}

procedure insereAntesDe (qualSlide: integer);
var salva_atual, nslidesAntes, inseridos: integer;
    i, n: integer;
begin
    salva_atual := slideAtual;
    nslidesAntes := nslides;

    criandoSlide := true;
    slideAtual := nslides;
    criaSlides (true);

//    if not salvarSlide then
//        mensagem ('PPDESIST', 1);

    nSlides:= slideAtual;
    criandoSlide := false;

    inseridos := nslides-nslidesAntes;
    for n := 1 to inseridos do
        begin
            for i := nslides downto salva_atual+1 do
                slides[i] := slides [i-1];
            slides[salva_atual] := slides[nslides];
        end;

    folheiaDestroi;
    folheiaCria (1, wherey, 80, 10);
    for i := 0 to nslides - 1 do
        begin
            folheiaAdiciona (slides[i].titulo);
        end;
end;

{--------------------------------------------------------}

procedure menuLinhas;
var x, y: integer;
begin

    x := wherex;
    y := wherey;
    gotoxy (1, 17);

    sintSom ('PPMENU');
    delay (100);
    writeln;
    mensagem ('PPOP', 1); {'Opções nas teclas:'}
    writeln;
    delay (100);

    mensagem ('PPEDICAM', 1); {('  ENTER   Editar campo');}
    mensagem ('PPEDIMOD', 1); {('  E   Editar modelo');}
    mensagem ('PPIDELIN', 1); {('  I   Indentar linha');}
    mensagem ('PPF12', 1); {('  F12   Atribuir programa');}
    mensagem ('PPCTLF12', 1); {('  CTL-F12   Atribuir elo');}

    delay (100);
    mensagem ('PPQUALOP', 0);  {'Qual sua opção ? F1 ajuda : '}
    writeln;

    gotoxy (x, y);

end;

{--------------------------------------------------------}

procedure editaLinhas;
var estaSelec: boolean;
    c1, c2, c3: char;
    navegando: boolean;
    i, nitem: integer;
label emBranco;
begin

    clrscr;
    mensagem ('PPEDILIN', 1); {('Edite a linha, F1 ajuda');}

    folheiaCria (1, 3, 80, 10);

    with slides[slideAtual] do
        for i := 0 to linhas.count - 1 do
        begin
            folheiaAdiciona (linhas[i]);
            if erroNaLinha[i] = 1 then
                folheiaSeleciona (i + 1, true);
        end;

    nitem := 1;
    navegando := true;

    repeat

        sintSom ('PPLINHA');

        emBranco:

        folheiaExecuta (nitem, nitem, c1, c2, true);
        linhaAtual:= nItem - 1;

        if (c1 = #0) and (c2 = F1) then
        begin
            menuLinhas;
            limpaBufTec;
        end;

        if (c1 = #0) and (c2 = F9) then
        begin
//            sintetiza ('NÃO IMPLEMENTADO');
                with slides[slideAtual] do
                    if (linhaAtual < 0) or (linhaAtual >= linhas.count) then
                    begin
                        sintSom ('PPBRANCO');
                        goto emBranco;
                    end;
            limpaBufTec;
        end;

        if (c1 = #0) and (c2 = F12) then
        begin
                with slides[slideAtual] do
                    if (linhaAtual < 0) or (linhaAtual >= linhas.count) then
                    begin
                        sintSom ('PPBRANCO');
                        goto emBranco;
                    end;
            nomeProg:= '';
            folheiaObtemItem (nItem, linha_ed, estaSelec);
            if pos ('#', linha_ed) <> 0 then
                sintSom ('PPSOACEI') {('Só aceito um comando por linha');}
            else
            begin
                if pos ('&', linha_ed) <> 0 then
                begin
                    nomeProg:= copy (linha_ed, pos ('&', linha_ed) + 1, length (linha_ed));
                    delete (linha_ed, pos ('&', linha_ed) - 1, length (linha_ed));
                end;
                if programaLinha then
                begin
                    folheiaCria (1, 3, 80, 10);
                    with slides[slideAtual] do
                        for i := 0 to linhas.count - 1 do
                        begin
                            folheiaAdiciona (linhas[i]);
                            if erroNaLinha[i] = 1 then
                                folheiaSeleciona (i + 1, true);
                        end;
                end
                else
                    sintBip;
                limpaBufTec;
            end;
        end;

        if (c1 = #0) and (c2 = CTLF12) then
        begin
                with slides[slideAtual] do
                    if (linhaAtual < 0) or (linhaAtual >= linhas.count) then
                    begin
                        sintSom ('PPBRANCO');
                        goto emBranco;
                    end;
            saltarSlide:= 0;
            folheiaObtemItem (nItem, linha_ed, estaSelec);
            if pos ('&', linha_ed) <> 0 then
                sintSom ('PPSOACEI') {('Só aceito um comando por linha');}
            else
            begin
                if pos ('#', linha_ed) <> 0 then
                begin
                    saltarSlide:= strToInt(copy (linha_ed, pos ('#', linha_ed) + 1, length (linha_ed)));
                    delete (linha_ed, pos ('#', linha_ed) - 1, length (linha_ed));
                end;
                if programaElo then
                begin
                    folheiaCria (1, 3, 80, 10);
                    with slides[slideAtual] do
                        for i := 0 to linhas.count - 1 do
                        begin
                            folheiaAdiciona (linhas[i]);
                            if erroNaLinha[i] = 1 then
                                folheiaSeleciona (i + 1, true);
                        end;
                end
                else
                    sintBip;
                limpaBufTec;
            end;
        end;

        case upcase (c1) of
            'E': begin
                sintSom ('PPNOVSLI');
                delay (100);
                defineModelo;
                if salvarSlide then
                begin
                    folheiaCria (1, 3, 80, 10);
                    with slides[slideAtual] do
                        for i := 0 to linhas.count - 1 do
                            folheiaAdiciona (linhas[i]);
                    salvarSlide:= false;
                end;
            end;
            'I': begin
                with slides[slideAtual] do
                    if (linhaAtual < 0) or (linhaAtual >= linhas.count) then
                    begin
                        sintSom ('PPBRANCO');
                        goto emBranco;
                    end;
                folheiaObtemItem (nItem, linha_ed, estaSelec);
                indentarLinha;
                if salvarSlide then
                begin
                    slides[slideAtual].linhas[nItem - 1]:= linha_ed;
                    folheiaCria (1, 3, 80, 10);
                    with slides[slideAtual] do
                        for i := 0 to linhas.count - 1 do
                            folheiaAdiciona (linhas[i]);
                    salvarSlide:= false;
                end;
            end;
            ENTER: begin
                with slides[slideAtual] do
                    if (linhaAtual < 0) or (linhaAtual >= linhas.count) then
                    begin
                        sintSom ('PPBRANCO');
                        goto emBranco;
                    end;
                sintSom ('PPSEDIT');
                folheiaObtemItem (nItem, linha_ed, estaSelec);
                soletrando:= true;
                c3:= sintEditaDic (linha_ed, 1, wherey, 200, 80, true);
                writeln;
                if c3 = ENTER then
                begin
                    if linha_ed = '' then
                        linha_ed:= ';';
                    slides[slideAtual].linhas[nItem - 1]:= linha_ed;
                    folheiaCria (1, 3, 80, 10);
                    with slides[slideAtual] do
                        for i := 0 to linhas.count - 1 do
                        begin
                            folheiaAdiciona (linhas[i]);
                            if erroNaLinha[i] = 1 then
                                folheiaSeleciona (i + 1, true);
                        end;
                    sintSom ('PPOK');
                end
                else
                    sintSom ('PPDESIST');
            end;
            ESC: navegando:= false;
        end;

    until not navegando;

    clrscr;
    mensagem ('PPRETTIT', 2); {('Retornando aos títulos, F1 ajuda');}

    folheiaDestroi;
    limpaBufTec;

end;

{--------------------------------------------------------}

procedure menuTitulos;
var x, y: integer;
begin

    x := wherex;
    y := wherey;
    gotoxy (1, 12);

    mensagem('PPMENU', -1);
    delay (100);
    writeln;
    mensagem ('PPOP', 1); {'Opções nas teclas:'}
    writeln;
    delay (100);

    mensagem ('PPEDICAM', 1); {'  ENTER   Editar campo'}
    mensagem ('PPEDILIS', 1); {'  E   Editar conteúdo'}
    mensagem ('PPINSSLD', 1); {'  I   Inserir slide'}
    mensagem ('PPREMSLI', 1); {'  R   Remover slide'}
    mensagem ('PPDIMSLI', 1); {'  D   Dimensionar slide'}
    mensagem ('PPVISSLI', 1); {'  V   Visualizar slide'}
    mensagem ('PPINFDET', 1); {'  T   Informações detalhadas'}
    mensagem ('PPIRSLD',  1); {'  S   Ir para o slide'}
    mensagem ('PPF3',     1); {'  F3  Informar qual slide do total'}
    mensagem ('PPF11',    1); {'  F11 Ativar verificador ortográfico'}

    delay (100);
    mensagem ('PPQUALOP', 0);  {'Qual sua opção ? F1 ajuda : '}

    gotoxy (x, y);

end;

{--------------------------------------------------------}

procedure falaQualDeQuantos;
begin
    sintetiza(intToStr(slideAtual+1));
    mensagem ('PPDE', -1);
    sintetiza(intToStr(nSlides));
end;

{--------------------------------------------------------}


procedure editaTitulos;
var estaSelec: boolean;
    c1, c2, c3: char;
    navegando: boolean;
    i, j, nitem, guardaNitem, guardaNitemSel: integer;
    opcao: char;
    s: string;
label deNovo, emBranco;
begin

    if nomeArq = '' then
    begin
        writeln;
        mensagem ('PPINFAPR', 0); {('Informe com as setas a apresentação desejada : ');}
        garanteEspacoTela (11);
        nomeArq:= obtemNomeArqMasc (10, '*.PPX');
        writeln (nomeArq);
        if nomeArq = '' then
        begin
            mensagem ('PPDESIST', 1);
            exit;
        end
        else
            capturouEstilo:= false;
    end;

    if not carregaArq then
        exit
    else
        defineEstilo;

    criaTelaGrafica (@desenhaSlideCompleto, figuraDeFundo <> '');

    debugEditando:= true;
    guardaNitem:= 0;
    guardaNitemSel:= 0;

    if nomeEstilo <> '' then
    begin
        delay (100);
        writeln;
        mensagem ('PPUSUEST', 0); {('Usarei como estilo : ');}
        s:= nomeEstilo;
        if pos ('.', s) <> 0 then
            delete (s, pos ('.', s), length (s));
        sintWriteln (s);
        delay (100);
    end;

    clrscr;
    mensagem ('PPSELTIT', 2); {('Selecione o título, F1 ajuda');}

    deNovo:

    folheiaCria (1, wherey, 80, 10);

    for i := 0 to nslides - 1 do
    begin
        folheiaAdiciona (slides[i].titulo);
    end;

    if guardaNitem = 0 then
        nitem := 1
    else
        nitem:= guardaNitem;

    navegando := true;

    repeat

        sintSom ('PPTIT');

        emBranco:

        folheiaExecuta (nitem, nitem, c1, c2, true);
        slideAtual:= nItem - 1;

        if c1 = #0 then
         begin
          case c2 of
            F1: begin
                    menuTitulos;
                    limpaBufTec;
                 end;
            F2: begin
                    salvaArqPPX;
                    limpaBufTec;
                 end;
            F3: falaQualDeQuantos;
            F8: falaHora;
            CTLF8: falaDia;
            F9: begin
                    if (slideAtual < 0) or (slideAtual >= nSlides) then
                    begin
                        sintSom ('PPBRANCO');
                        goto emBranco;
                    end;
//            sintetiza ('NÃO IMPLEMENTADO');
                 end;
            F11: begin
                    ativaDicionario;
                    limpaBufTec;
                  end;
          end;
         end
        else
        case upcase (c1) of
            'E': begin
                if (slideAtual < 0) or (slideAtual >= nSlides) then
                begin
                    sintSom ('PPBRANCO');
                    goto emBranco;
                end;
                guardaNitem:= nitem;
                if nitem <> guardaNitemSel then
                    for j:=0 to 20 do
                        erroNaLinha[j]:= 0;
                editaLinhas;
                goto deNovo;
            end;
            'I': begin
                    if slideAtual >= 0 then
                        insereAntesDe (slideAtual)
                    else
                        sintBip;
                end;
            'S', 'F': begin
                    mensagem ('PPQUALSL', 0); {'Qual o slide?'}
                    sintReadInt(saltarSlide);
                    if (saltarSlide >0) and (saltarSlide <= nSlides) then
                        begin
                            sintetiza('Ok '+intToStr(saltarSlide));
                            nItem := saltarSlide;
                        end;
                end;
            'Q': falaQualDeQuantos;
            'R': begin
                    if (slideAtual >= 0) and (slideAtual < nSlides) then
                        remove (slideAtual)
                    else
                        sintBip;
                end;
            'D': begin
                    if (slideAtual >= 0) and (slideAtual < nSlides) then
                    begin
                        debugar:= true;
                        apresentando:= true;
                        criaTelaGrafica (@desenhaSlideCompleto, figuraDeFundo <> '');
                        exibeSlide;
                        if not sintDimensoesOK then
                        begin
                            folheiaSeleciona (nitem, true);
                            guardaNitemSel:= nitem;
                        end
                        else
                        begin
                            folheiaSeleciona (nitem, false);
                            guardaNitemSel:= 0;
                        end;
                        delay (250);
                        destroiTelaGrafica;
                        apresentando:= false;
                        escondeTelaGrafica;
                        limpaBufTec;
                        debugar:= false;
                    end
                    else
                        sintBip;
                end;
            'V': begin
                    if (slideAtual >= 0) and (slideAtual < nSlides) then
                    begin
                        apresentando:= true;
                        criaTelaGrafica (@desenhaSlideCompleto, figuraDeFundo <> '');
                        exibeSlide;
                        sintSom ('PPVISUAL');
                        while sintFalando do waitMessage;
                        sintSom ('PPVISPRE');
                        readkey;

                        destroiTelagrafica;
                        apresentando:= false;
                        escondeTelaGrafica;
                        limpaBufTec;

                        sintSom ('PPESCOND');
                        while sintFalando do waitMessage;
                    end
                    else
                        sintBip;
                end;
            'T': begin
                if (slideAtual >= 0) and (slideAtual < nSlides) then
                begin
                    with slides[slideAtual] do
                    begin
                        if modelo = capa then
                            sintSom ('PPMCAP')
                        else
                        if modelo = listaSimples then
                            sintSom ('PPMLIS')
                        else
                        if modelo = figura then
                            sintSom ('PPMFIG')
                        else
                        if modelo = video then
                            sintSom ('PPMVID');
                    end;
                    delay (100);
                    sintSom ('PPPOSSLI'); {('Posição do slide : ');}
                    delay (100);
                    sintetiza (intToStr(slideAtual + 1));
                    delay (100);
                    sintSom ('PPRESGRA'); {('Resolução gráfica: ');}

                    apresentando:= true;
                    criaTelaGrafica (@desenhaSlideCompleto, figuraDeFundo <> '');
                    exibeSlide;
                    destroiTelaGrafica;
                    apresentando:= false;
                    escondeTelaGrafica;
                    sintetiza (resolucaoGrafica);

                    if resolucaoGrafica <> resolucaoEstilo then
                    begin
                        delay (100);
                        sintBip; sintBip;
                        sintSom ('PPGRANAO'); {('A resolução atual não corresponde a do estilo original');}
                    end;
                end
                else
                    sintBip;
            end;
            ENTER: begin
                if (slideAtual < 0) or (slideAtual >= nSlides) then
                begin
                    sintSom ('PPBRANCO');
                    goto emBranco;
                end;
                sintSom ('PPSEDIT');
                folheiaObtemItem (nItem, linha_ed, estaSelec);
                soletrando:= true;
                c3:= sintEditaDic (linha_ed, 1, wherey, 200, 80, true);
                writeln;
                if c3 = ENTER then
                begin
                    if linha_ed <> '' then
                    begin
                        slides[slideAtual].titulo:= linha_ed;
                        folheiaCria (1, 3, 80, 10);
                        for i := 0 to nslides - 1 do
                            folheiaAdiciona (slides[i].titulo);
                        sintSom ('PPOK');
                    end;
                end
                else
                    sintSom ('PPDESIST');
            end;
            ESC: navegando:= false;
        end;

    until not navegando;

    destroiTelaGrafica;

    repeat
        gotoxy (1, 20);
        writeln;
        mensagem ('PPDESDIS', 0); {('Deseja salvar em disco ? ');}
        opcao:= readkey;
        write (opcao);
    until upcase(opcao) in ['S', 'N'];

    if upcase(opcao) = 'S' then
        salvaArqPPX
    else
        mensagem ('PPDESIST', 1);

    mensagem ('PPFIMEDI', 1); {('Fim da edição');}

    sintDimensoesOK:= false;
    debugEditando:= false;

    clrscr;
    limpaBufTec;

end;

end.
