Unit ppEdita;

interface

uses dvCrt, dvWin, dvForm, dvExec, videoVox,
    windows, classes, sysUtils,
    ppArq, ppNavega, ppMsg, ppVars;

procedure editaCapa;
procedure editaListaSimples;
procedure editaFigura;
procedure editaVideo;
procedure editaTextoFigura;

procedure defineModelo;

function programaLinha: boolean;
function programaElo: boolean;

implementation

{--------------------------------------------------------}

procedure editaCapa;
var tit, toc, fund: shortString;
    lin: array [0..5] of shortString;
    i: integer;
    s: string;
    opcao: char;
begin

    writeln;
    mensagem ('PPMODCAP', 1); {('O modelo CAPA será assumido');}

    tit:= '';
    toc:= '';
    fund:= '';
    for i:= 0 to 5 do
        lin[i]:= '';

    if (not criandoSlide) or (debugCriando) then
    begin
        with slides[slideAtual] do
        begin
            tit:= titulo;
            toc:= som;
            fund:= fundo;
            for i:= 0 to linhas.count - 1 do
                lin[i] := linhas[i];
        end;
    end;

    textBackground (BLUE);
    writeln;
    mensagem ('PPSETEDI', 1); {('Use as setas e edite o slide');}
    textBackground (BLACK);

    garanteEspacoTela(13);
    formCria;

    formCampo    ('PPFTIT', 'Título: ', tit, 200);
    formCampo    ('PPFSOM', 'Som: ', toc, 200);
    formCampo    ('PPFFUN', 'Fundo: ', fund, 200);
    formCampo    ('', '1 ', lin[0], 200);
    formCampo    ('', '2 ', lin[1], 200);
    formCampo    ('', '3 ', lin[2], 200);
    formCampo    ('', '4 ', lin[3], 200);
    formCampo    ('', '5 ', lin[4], 200);

    formEdita (true);

    writeln;

    if tit = '' then
    begin
        sintBip; sintBip;
        mensagem ('PPTITBRA', 1); {('Título em branco');}
        delay (100);
        mensagem ('PPOPECAN', 1); {('Operação cancelada');}
        exit;
    end;

    if copy(maiuscAnsi(toc), 1, 12) = 'FUNDOMUSICAL' then
        s:= copy(toc, 14, length(toc))
    else
        s:= toc;

    if not existeArq(s) then
    begin
        sintBip;
        writeln;
        mensagem ('PPOSONAO', 1); {('O som especificado não existe');}
        writeln;
    end;

    if not existeArq(fund) then
    begin
        sintBip;
        writeln;
        mensagem ('PPOFUNAO', 1); {('O fundo especificado não existe');}
        writeln;
    end;

    mensagem ('PPSALEDI', 0); {('Irei salvar a edição desse slide, confirma ? ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
    begin
        salvarSlide:= true;
        with slides[slideAtual] do
        begin
            titulo:= tit;
            som:= toc;
            fundo:= fund;
            linhas := TStringList.Create;
            for i:= 0 to 4 do
            begin
                if lin[i] = '' then
                    lin[i]:= ';';
                linhas.Add(lin[i]);
            end;
        end;
            mensagem ('PPOKSALV', 1); {('OK, slide salvo');}
    end
    else
        mensagem ('PPOPECAN', 1); {('OK, operação cancelada');}

end;

{--------------------------------------------------------}

procedure editaListaSimples;
var tit, fund: shortString;
    lin: array [0..10] of shortString;
    i: integer;
    opcao: char;
begin

    writeln;
    mensagem ('PPMODLIS', 1); {('O modelo LISTA será assumido');}

    tit:= '';
    fund:= '';
    for i:= 0 to 10 do
        lin[i]:= '';

    if (not criandoSlide) or (debugCriando) then
    begin
        with slides[slideAtual] do
        begin
            tit:= titulo;
            fund:= fundo;
            for i:= 0 to linhas.count - 1 do
                lin[i] := linhas[i];
        end;
    end;

    textBackground (BLUE);
    writeln;
    mensagem ('PPSETEDI', 1); {('Use as setas e edite o slide');}
    textBackground (BLACK);

    garanteEspacoTela(17);
    formCria;

    formCampo    ('PPFTIT', 'Título: ', tit, 200);
    formCampo    ('PPFFUN', 'Fundo: ', fund, 200);
    formCampo    ('', '1 ', lin[0], 200);
    formCampo    ('', '2 ', lin[1], 200);
    formCampo    ('', '3 ', lin[2], 200);
    formCampo    ('', '4 ', lin[3], 200);
    formCampo    ('', '5 ', lin[4], 200);
    formCampo    ('', '6 ', lin[5], 200);
    formCampo    ('', '7 ', lin[6], 200);
    formCampo    ('', '8 ', lin[7], 200);
    formCampo    ('', '9 ', lin[8], 200);
    formCampo    ('', '10 ', lin[9], 200);

    formEdita (true);

    writeln;

    if tit = '' then
    begin
        sintBip; sintBip;
        mensagem ('PPTITBRA', 1); {('Título em branco');}
        delay (100);
        mensagem ('PPOPECAN', 1); {('Operação cancelada');}
        exit;
    end;

    if not existeArq(fund) then
    begin
        sintBip;
        writeln;
        mensagem ('PPOFUNAO', 1); {('O fundo especificado não existe');}
        writeln;
    end;

    mensagem ('PPSALEDI', 0); {('Irei salvar a edição desse slide, confirma ? ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
    begin
        salvarSlide:= true;
        with slides[slideAtual] do
        begin
            titulo:= tit;
            fundo:= fund;
            linhas := TStringList.Create;
            for i:= 0 to 9 do
            begin
                if lin[i] = '' then
                    lin[i]:= ';';
                linhas.Add(lin[i]);
            end;
        end;
            mensagem ('PPOKSALV', 1); {('OK, slide salvo');}
    end
    else
        mensagem ('PPOPECAN', 1); {('OK, operação cancelada');}

end;

{--------------------------------------------------------}

procedure editaFigura;
var tit, arq, toc, fund: shortString;
    lin: array [0..2] of shortString;
    i: integer;
    s: string;
    opcao: char;
begin

    writeln;
    mensagem ('PPMODFIG', 1); {('O modelo FIGURA será assumido');}

    tit:= '';
    arq:= '';
    toc:= '';
    fund:= '';
    for i:= 0 to 2 do
        lin[i]:= '';

    if (not criandoSlide) or (debugCriando) then
    begin
        with slides[slideAtual] do
        begin
            tit:= titulo;
            arq:= arquivo;
            toc:= som;
            fund:= fundo;
            for i:= 0 to linhas.count - 1 do
                lin[i] := linhas[i];
        end;
    end;

    textBackground (BLUE);
    writeln;
    mensagem ('PPSETEDI', 1); {('Use as setas e edite o slide');}
    textBackground (BLACK);

    garanteEspacoTela(10);
    formCria;

    formCampo    ('PPFTIT', 'Título: ', tit, 200);
    formCampo    ('PPFFIG', 'Figura: ', arq, 200);
    formCampo    ('PPFSOM', 'Som: ', toc, 200);
    formCampo    ('PPFFUN', 'Fundo: ', fund, 200);
    formCampo    ('', '1 ', lin[0], 200);
    formCampo    ('', '2 ', lin[1], 200);

    formEdita (true);

    writeln;

    if tit = '' then
    begin
        sintBip; sintBip;
        mensagem ('PPTITBRA', 1); {('Título em branco');}
        delay (100);
        mensagem ('PPOPECAN', 1); {('Operação cancelada');}
        exit;
    end;

    if not existeArq(arq) then
    begin
        sintBip;
        writeln;
        mensagem ('PPAIMNAO', 1); {('A imagem especificada não existe');}
        writeln;
    end;

    if copy(maiuscAnsi(toc), 1, 12) = 'FUNDOMUSICAL' then
        s:= copy(toc, 14, length(toc))
    else
        s:= toc;

    if not existeArq(s) then
    begin
        sintBip;
        writeln;
        mensagem ('PPOSONAO', 1); {('O som especificado não existe');}
        writeln;
    end;

    if not existeArq(fund) then
    begin
        sintBip;
        writeln;
        mensagem ('PPOFUNAO', 1); {('O fundo especificado não existe');}
        writeln;
    end;

    mensagem ('PPSALEDI', 0); {('Irei salvar a edição desse slide, confirma ? ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
    begin
        salvarSlide:= true;
        with slides[slideAtual] do
        begin
            titulo:= tit;
            arquivo:= arq;
            som:= toc;
            fundo:= fund;
            linhas := TStringList.Create;
            for i:= 0 to 1 do
            begin
                if lin[i] = '' then
                    lin[i]:= ';';
                linhas.Add(lin[i]);
            end;
        end;
            mensagem ('PPOKSALV', 1); {('OK, slide salvo');}
    end
    else
        mensagem ('PPOPECAN', 1); {('OK, operação cancelada');}

end;

{--------------------------------------------------------}

procedure editaVideo;
var tit, arq: shortString;
    lin: array [0..5] of shortString;
    i: integer;
    opcao: char;
begin

    writeln;
    mensagem ('PPMODVID', 1); {('O modelo VÍDEO será assumido');}

    tit:= '';
    arq:= '';
    for i:= 0 to 5 do
        lin[i]:= '';

    if (not criandoSlide) or (debugCriando) then
    begin
        with slides[slideAtual] do
        begin
            tit:= titulo;
            arq:= arquivo;
            for i:= 0 to linhas.count - 1 do
                lin[i] := linhas[i];
        end;
    end;

    textBackground (BLUE);
    writeln;
    mensagem ('PPSETEDI', 1); {('Use as setas e edite o slide');}
    textBackground (BLACK);

    garanteEspacoTela(12);
    formCria;

    formCampo    ('PPFTIT', 'Título: ', tit, 200);
    formCampo    ('PPFVID', 'Vídeo: ', arq, 200);
    formCampo    ('', '1 ', lin[0], 200);
    formCampo    ('', '2 ', lin[1], 200);
    formCampo    ('', '3 ', lin[2], 200);
    formCampo    ('', '4 ', lin[3], 200);
    formCampo    ('', '5 ', lin[4], 200);

    formEdita (true);

    writeln;

    if tit = '' then
    begin
        sintBip; sintBip;
        mensagem ('PPTITBRA', 1); {('Título em branco');}
        delay (100);
        mensagem ('PPOPECAN', 1); {('Operação cancelada');}
        exit;
    end;

    if not existeArq(arq) then
    begin
        sintBip;
        writeln;
        mensagem ('PPOVINAO', 1); {('O vídeo especificado não existe');}
        writeln;
    end;

    mensagem ('PPSALEDI', 0); {('Irei salvar a edição desse slide, confirma ? ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
    begin
        salvarSlide:= true;
        with slides[slideAtual] do
        begin
            titulo:= tit;
            arquivo:= arq;
            linhas := TStringList.Create;
            for i:= 0 to 4 do
            begin
                if lin[i] = '' then
                    lin[i]:= ';';
                linhas.Add(lin[i]);
            end;
        end;
            mensagem ('PPOKSALV', 1); {('OK, slide salvo');}
    end
    else
        mensagem ('PPOPECAN', 1); {('OK, operação cancelada');}

end;

{--------------------------------------------------------}

procedure editaTextoFigura;
var tit, arq, toc, fund: shortString;
 lin: array [0..10] of shortString;
    i: integer;
    s: string;
    opcao: char;
Begin
    writeln;
    mensagem ('PPMODTEXTOFIG', 1); {('O modelo TEXTOFIGURA será assumido');}
    tit:= '';
    fund:= '';
    arq:= '';
    toc:= '';

    for i:= 0 to 10 do
        lin[i]:= '';
    if (not criandoSlide) or (debugCriando) then
    begin
        with slides[slideAtual] do
        begin
            tit:= titulo;
            fund:= fundo;
            arq:= arquivo;
            toc:= som;
            for i:= 0 to linhas.count - 1 do
                lin[i] := linhas[i];
        end;
    end;

    textBackground (BLUE);
    writeln;
    mensagem ('PPSETEDI', 1); {('Use as setas e edite o slide');}
    textBackground (BLACK);

    garanteEspacoTela(12);
    formCria;

    formCampo    ('PPFTIT', 'Título: ', tit, 100);
    formCampo    ('PPFFUN', 'Fundo: ', fund, 50);
    formCampo    ('PPFFIG', 'Figura: ', arq, 100);
    formCampo    ('PPFSOM', 'Som: ', toc, 200);
    formCampo    ('', '1 ', lin[0], 50);
    formCampo    ('', '2 ', lin[1], 50);
    formCampo    ('', '3 ', lin[2], 50);
    formCampo    ('', '4 ', lin[3], 50);
    formCampo    ('', '5 ', lin[4], 50);
    formCampo    ('', '6 ', lin[5], 50);
    formCampo    ('', '7 ', lin[6], 50);
    formCampo    ('', '8 ', lin[7], 50);
    formCampo    ('', '9 ', lin[8], 50);
    formCampo    ('', '10 ', lin[9], 50);
    formEdita (true);

    writeln;

    if tit = '' then
    begin
        sintBip; sintBip;
        mensagem ('PPTITBRA', 1); {('Título em branco');}
        delay (100);
        mensagem ('PPOPECAN', 1); {('Operação cancelada');}
        exit;
    end;
    if not existeArq(arq) then
    begin
        sintBip;
        writeln;
        mensagem ('PPAIMNAO', 1); {('A imagem especificada não existe');}
    end;
    if not existeArq(fund) then
    begin
        sintBip;
        writeln;
        mensagem ('PPOFUNAO', 1); {('O fundo especificado não existe');}
        if copy(maiuscAnsi(toc), 1, 12) = 'FUNDOMUSICAL' then
                s:= copy(toc, 14, length(toc))
        else
                s:= toc;
    end;
    if not existeArq(s) then
    begin
        sintBip;
        writeln;
        mensagem ('PPOSONAO', 1); {('O som especificado não existe');}
        writeln;
    end;

    if not existeArq(fund) then
    begin
        sintBip;
        writeln;
        mensagem ('PPOFUNAO', 1); {('O fundo especificado não existe');}
        writeln;
    end;

    mensagem ('PPSALEDI', 0); {('Irei salvar a edição desse slide, confirma ? ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
    begin
        salvarSlide:= true;
        with slides[slideAtual] do
        begin
            titulo:= tit;
            arquivo:= arq;
            som:= toc;
            fundo:= fund;
            linhas := TStringList.Create;
            for i:= 0 to 9 do
            begin
                if lin[i] = '' then
                    lin[i]:= ';';
                linhas.Add(lin[i]);
            end;
        end;
            mensagem ('PPOKSALV', 1); {('OK, slide salvo');}
    end
    else
        mensagem ('PPOPECAN', 1); {('OK, operação cancelada');}

end;

{--------------------------------------------------------}
procedure defineModelo;
begin

    with slides[slideAtual] do
    begin
        if modelo = capa then
            editaCapa;
        if modelo = listasimples then
            editaListaSimples;
        if modelo = figura then
            editaFigura;
        if modelo = video then
            editaVideo;
        if modelo = textofigura then
            editaTextoFigura;

    end;

end;

{--------------------------------------------------------}

function programaLinha: boolean;
var s: string;
    programa: string;
begin

    programaLinha:= false;

    if nomeProg <> '' then
    begin
        writeln;
        mensagem ('PPNESLIN', 0); {('Nesta linha, a execução de ');}
        sintWrite (nomeProg);
            mensagem ('PPJAREAL', 1); {(' já será realizada');}
        sintBip; sintBip;
        mensagem ('PPOPECAN', 1); {('Operação cancelada');}
        exit;
    end;

    with slides[slideAtual] do
    begin
        if (linhaAtual <0) or (linhaAtual > linhas.count) then
            linhaAtual:= 0;
        s:= linhas[linhaAtual];
    end;

    writeln;
    mensagem ('PPCONSEL', 1); {('O conteúdo da linha selecionada é : ');}
    sintWriteln (s);
    writeln;
mensagem ('PPINFPROG', 0); {( 'Informe o programa que será executado nessa linha : ');}
    sintReadln (programa);

    if programa = '' then
    begin
        mensagem ('PPDESIST', 1);
        exit;
    end;

    if programa <> '' then
    begin
        s:= programa;
        if pos (' ', programa) <> 0 then
            delete (s, pos (' ', s), length (s));
        if not existeArq(s) then
        begin
            sintBip; sintBip;
            writeln;
            mensagem ('PPPRONEX', 1); {('O programa indicado não existe');}
            delay (100);
            mensagem ('PPOPECAN', 1);
            exit;
        end;
    end;

    programa:= ' &' + programa;

    with slides[slideAtual] do
        linhas[linhaAtual]:= linhas[linhaAtual] + programa;

    mensagem ('PPLINEXE', 0); {('OK, esta linha irá executar : ');}
    delete (programa, 1, 2);
    sintWriteln (programa);

    salvarSlide:= true;

    programaLinha:= true;

end;

{--------------------------------------------------------}

function programaElo : boolean;
var s: string;
    elo: string;
    i, erro: integer;
begin

    programaElo:= false;

    if saltarSlide > 0 then
    begin
        writeln;
        mensagem ('PPESTASS', 0); {('Esta linha já associa a tela : ');}
        sintWriteint (saltarSlide);
        writeln;
        sintBip; sintBip;
        mensagem ('PPDEREPO', 1); {('Você deverá redefinir então sua posição');}
    end;

    with slides[slideAtual] do
    begin
        if (linhaAtual <0) or (linhaAtual > linhas.count) then
            linhaAtual:= 0;
        s:= linhas[linhaAtual];
    end;

    writeln;
    mensagem ('PPCONSEL', 1); {('O conteúdo da linha selecionada é : ');}
    if pos ('#', s) <> 0 then
        delete (s, pos ('#', s) - 1, length (s));
    sintWriteln (s);
    writeln;
mensagem ('PPINFELO', 0); {( 'Informe a tela que será associada a esta linha : ');}
    sintReadln (elo);

    if elo = '' then
    begin
        mensagem ('PPDESIST', 1);
        exit;
    end
    else
    begin
        val (elo, i, erro);
        if erro <> 0 then
            exit;
        if (i < 0) or (i > nSlides -1) then
        begin
            sintBip; sintBip;
            writeln;
            mensagem ('PPTELINE', 1); {('Tela inexistente');}
            delay (100);
            mensagem ('PPOPECAN', 1);
            exit;
        end;
        elo:= ' #' + elo;
    end;

    with slides[slideAtual] do
    begin
        s:= linhas[linhaAtual];
        if pos ('#', s) <> 0 then
            delete (s, pos ('#', s) - 1, length (s));
        linhas[linhaAtual]:= s + elo;
    end;

    mensagem ('PPLINASSO', 0); {('OK, esta linha irá associar a tela : ');}
    delete (elo, 1, 2);
    sintWriteln (elo);

    salvarSlide:= true;

    programaElo:= true;

end;

end.
