{--------------------------------------------------------------}
{
{   PPTVOX - exibidor interativo de apresentações
[
{   Controle geral do processamento
{
{   Em 11/06/2015
{
{--------------------------------------------------------------}

unit ppproc;

interface

uses
  dvcrt,
  dvwin,
  dvjpeg,
  dvForm,
  dvArq,
  dvExec,
  dvWav,
  dvMacro,
  dvhora,
  videoVox,

  windows,
  messages,
  classes,
  graphics,
  SysUtils,

  ppvars,
  ppmsg,
  ppdesen,
  ppnavega,
  ppjanela,
  ppEdita,
  ppArq,
  ppCria,
  ppFolhei,
  ppConf,
  ppExport,
  ppAuto,
  ppEstilo,
  ppImport,
  ppInic;

procedure processa;

implementation

{--------------------------------------------------------}
{ Som, slide, esconde tela, limpa o buffer do teclado
{--------------------------------------------------------}

function executaPlayer: boolean;
var arq: text;
begin

    executaPlayer:= false;

    tocaArqSom ('parar', musicaDeFundo);
    musicaDeFundo:= '';

    sintSom ('PPAGUATP'); {('Aguarde, ativando o PLAYER');}

    with slides[slideAtual] do
    begin

        assign (arq, '$.m3u');
        {$I-} rewrite(arq); {$I+}
        if ioResult <> 0 then
            exit
        else
            begin
                writeln (arq, arquivo);
                {$I-} close(arq); {$I+}
            end;

        delay (500);
        escondeTelaGrafica;
        limpaBufTec;
        sintSom ('PPESCOND');

        GetWindowText (getForegroundWindow, nomeJan, 256);
        delay (100);
        if executaProg (e_player, '', dirEstilos + '\$.m3u') > 32 then
        begin

            repeat
                delay (1000);
                GetWindowText (getForegroundWindow, nomeJanProg, 256);
            until strComp (nomeJan, nomeJanProg) <> 0;

            if (maiuscAnsi(e_player) = 'WMPLAYER') or
            (maiuscAnsi(e_player) = 'MPLAYER2') or
            (maiuscAnsi(e_player) = 'REALPLAY') then
            begin
                delay (250);
                keyBoardAlt (#32, 100); // ALT+BARRA DE ESPAÇO
                delay (250);
                keyBoardClick (#120); // LETRA X (MAXIMIZAR)
                delay (250);
            end;

            sintSom ('PPALTF4'); {('PRESSIONE ALT+F4 PARA SAIR');}
            esperaProgVoltar;
            executaPlayer:= true;
        end;
        exibeSlide;
        limpaBufTec;
        sintSom ('PPVISUAL');
    end;

end;

{--------------------------------------------------------}
{           Rotina auxiliar para popup menu
{--------------------------------------------------------}

procedure MenuAdiciona (msg: string);
begin
     popupMenuAdiciona (msg, pegaTextoMensagem (msg));
end;

{--------------------------------------------------------}
{           Apresenta as mensagens do menu
{--------------------------------------------------------}

procedure menuApresenta;
begin

    mensagem('PPMENU', -1);
    delay (100);
    mensagem('PPOP', -1);
    delay (100);

    mensagem('PPUPDN', -1);
    mensagem('PPCIMBAI', -1);
    mensagem('PPIRSLD', -1); {'  s   Ir para o slide'}
    mensagem('PPF3', -1);
    mensagem('PPF4', -1);
    mensagem('PPCTRLF4', -1);
    mensagem('PPF8', -1);
    mensagem('PPHOMEND', -1);
    mensagem('PPCTECTD', -1);
    if musicaDeFundo <> '' then
        mensagem('PPBARINT', -1);

    delay (100);
    mensagem('PPQUALOP', -1);
end;

{--------------------------------------------------------}
{              Fala a hora
{--------------------------------------------------------}

procedure falaTempo;
var s: string;
begin
    dvcrt.gettime (hora, min, seg, cent);

    min := hora * 60 + min;
    if min < minInic then min := min + 24*60;

    s:= intTostr (min - minInic);
    sintetiza (s);
    sintSom ('PPXMINUT');
end;

{--------------------------FIM---------------------------}


{--------------------------------------------------------}
{                       Fala dia e hora
{--------------------------------------------------------}


procedure comparaTempo;
var s: string;
begin
    dvcrt.gettime (hora, min, seg, cent);

    sintSom ('PPHORA');
    falaHora;
    falaDia;

    sintSom ('PPTEMDEC');

    min := hora * 60 + min;
    if min < minInic then min := min + 24*60;

    s:= intTostr (min - minInic);
    sintetiza (s);
    sintSom ('PPXMINUT');

    sintSom ('PPINIAPR');
    str (horaInic, s);
    sintetiza (s);
    sintSom ('PPXHORAS');
    str (minInic_bk, s);
    sintetiza (s);
    sintSom ('PPXMINUT');

    limpaBufTec;
end;

{--------------------------------------------------------}
{            Seleciona o som de acordo com o slide
{--------------------------------------------------------}

procedure leTodoSlide;
var c3: char;
    s: string;
    i: integer;
begin

    limpaBufTec;

    with slides[slideAtual] do
    begin
        if linhas.count = 0 then
        begin
            sintSom ('PPNAEXLI');
            exit;
        end;
    end;

    linhaAtual:= -1;

    with slides[slideAtual] do
        while linhaAtual < linhas.count - 1 do
        begin
            linhaAtual:= linhaAtual + 1;
            if (tempoLinha > 0) and (linhas[linhaAtual] <> ';') then
            begin
                i:= 0;
                limpaBufTec;
                repeat
                    delay (1000);
                    i:= i + 1;
                until (i = tempoLinha) or (keyPressed);
            end;
            s:= linhas[linhaAtual];
            if pos ('&', s) <> 0 then
            begin
                delete (s, pos ('&', s) - 1, length (s));
                sintSom ('PPPROG');
            end;
            if pos ('#', s) <> 0 then
            begin
                delete (s, pos ('#', s) - 1, length (s));
                sintSom ('PPLINK');
            end;
            if s[1] = ';' then
                delete (s, 1, 1);
            if s <> '' then
            begin
                if trocLinhas <> '' then
                    sintSom ((trocLinhas));
                sintetiza (s);
            end;
            if keypressed then
            begin
                c3:= readkey;
                if c3 <> ' ' then
                    break
                else
                begin
                    limpaBufTec;
                    sintSom ('PPPAUSA'); {('PAUSA');}
                    repeat until keypressed;
                end;
                limpaBufTec;
            end;
        end;

        with slides[slideAtual] do
            if linhaAtual = linhas.count - 1 then
            begin
                if ultLinha <> '' then
                    sintSom ((ultLinha));
                linhaAtual:= -1;
            end;

end;

{--------------------------------------------------------}
{               Mostra tela gráfica e som
{--------------------------------------------------------}

procedure trataTecladoApresenta;
var arq: text;
    c1, c2, c3: char;
    guardaLinhaAtual, i: integer;
    cmd, paramProg: string;
    comandoSom: string;
    opcao: char;
label inicio, fim, avancouSlide, naoAchouSom;

begin
    limpaBufTec;

    exibeSlide;
    sintSom ('PPVISUAL');
    while sintFalando do waitMessage;

    dvcrt.gettime (horaInic, minInic, seg, cent);
    minInic_bk:= minInic;
    minInic := horaInic * 60 + minInic;

    inicio:

    c1 := '@';
    c3 := '@';

    limpaBufTec;

    repeat

        avancouSlide:

// Relativo ao som emitido ao surgir uma imagem

    with slides[slideAtual] do
    begin
        if ((modelo = figura) or (modelo = textofigura)) and (arquivo <> '') and (existeArq(arquivo)) then
            if informarFoto then
            begin
                sintSom ('PPFOTO');
                informarFoto:= false;
            end;
    end;

// Relativo à leitura das linhas

        if leAuto then
            if primeiraVez then
            begin
                primeiraVez:= false;
                leTodoSlide;
            end;

// Relativo ao arquivo WAV

        if tocarSlide then
        begin
            tocarSlide:= false;
            limpaBufTec;
            with slides[slideAtual] do
            begin
                if (modelo = capa) and (maiuscAnsi(trim(som)) <> '')
                or ((modelo = figura)or (modelo = textofigura)) and (maiuscAnsi(trim(som)) <> '') then
                begin
                    assign (arq, som);
                    {$I-} reset(arq); {$I+}
                    if ioResult <> 0 then
                        goto naoAchouSom
                    else
                        {$I-} close(arq); {$I+}
                    wavePlayFile (som);
                    if tempoSlide > 0 then
                        if keyPressed then
                        begin
                            c3:= readkey;
                            if c3 = ESC then
                                goto fim;
                        end;
                end;
            end;
        end;

        naoAchouSom:

// Relativo apenas ao fundo musical

    with slides[slideAtual] do
        if (modelo = capa) or((modelo = textofigura)or (modelo = figura)) then
        begin
            if tocarFundoMusical then
            begin
                comandoSom:= copy(som, 1, 12);
                if comandoSom <> '' then
                begin
                    comandoSom:= maiuscAnsi(comandoSom);
                    musicaDeFundo:= copy(som, 14, length(som));
                end;
                if comandoSom = 'FUNDOMUSICAL' then
                begin
                    tocarFundoMusical:= false;
                    tocaArqSom ('parar', musicaDeFundo); //Caso haja troca de arquivo e/ou comando para interromper
                    if (musicaDeFundo <> '') and (existeArq(musicaDeFundo)) then
                        tocaArqSom ('tocar', musicaDeFundo);
                end;
            end;
        end;

// Relativo à troca automatica dos slides

        if tempoSlide > 0 then
        begin
            limpaBufTec;
            i:= 0;
            repeat
                delay (1000);
                i:= i + 1;
                if keyPressed then
                    c3:= readkey;
            until (i = tempoSlide) or (keyPressed);

            if c3 = ESC then
                goto fim;

            limpaBufTec;
            if slideAtual < nSlides - 1 then
                begin
                    avancaSlide;
                    goto avancouSlide;
                end
            else
                begin
                    sintSom ('PPULTSLI'); {('Último slide');}
                    if not repeteAuto then
                        tempoSlide:= 0
                    else
                        begin
                            slideAtual:= -1;
                            avancaSlide;
                            goto avancouSlide;
                        end;
                end;
        end;

// relativo ao vídeo (não executa em modo automático)

    with slides[slideAtual] do
    begin
        if (modelo = video) and (arquivo <> '') and (existeArq(arquivo)) then
            if ativarPlayer then
                begin
                    if executaPlayer then
                        ativarPlayer:= false
                    else
                        sintBip;
                end;
    end;

        sintClek;

        if tempoSlide = 0 then
            c1 := upcase(readkey);

        if telaGraficaEstaMorta then
            halt;    // aborta o programa (que coisa feia)!

        if c1 = #0 then    // teclas de função
            begin
                c2 := readkey;
                case c2 of
                    F1: menuApresenta;
                    F3: falaQualDeQuantos;
                    F4: leTodoSlide;
                 CTLF4: begin
                            limpaBufTec;
                            leAuto:= not leAuto;
                            if not leAuto then
                                sintetiza ('SÍNTESE DESATIVADA')
                            else
                                sintetiza ('SÍNTESE ATIVADA')
                        end;
                    F8: falaTempo;
                 CTLF8: comparaTempo;
                  HOME: begin //#71
                            with slides[slideAtual] do
                                begin
                                    linhaAtual:= -1;
                                    sintSom ('PPTIT');
                                    sintetiza (titulo);
                                end;
                            end;
                  TEND: begin
                            with slides[slideAtual] do
                                begin
                                    linhaAtual:= linhas.count -1;
                                    if trocLinhas <> '' then
                                        sintSom ((trocLinhas));
                                end;
                        end;
                CTLESQ: begin
                            limpaBufTec;
                            saltarSlide:= 1;
                            linkSlide (saltarSlide);
                            exibeSlide;
                        end;
                CTLDIR: begin
                            limpaBufTec;
                            saltarSlide:= nSlides;
                            linkSlide (saltarSlide);
                            exibeSlide;
                        end;
             PGDN, DIR:  avancaSlide;
             PGUP, ESQ:  recuaSlide;
                  BAIX:  avancaELeLinha (1);
                  CIMA:  avancaELeLinha (-1);
                end;

            end
        else
            case c1 of
                'Q': falaQualDeQuantos;
                'S', 'F': begin
                        limpaBufTec;
                        mensagem ('PPQUALSL', 0); {'Qual o slide?'}
                        sintReadInt(saltarSlide); //Neno - erro - pegando duplicado
                        if (saltarSlide >0) and (saltarSlide <= nSlides) then
                        begin
                            sintetiza('Ok '+intToStr(saltarSlide));
                            linkSlide (saltarSlide);
                            visualizaTelaGrafica;
                        end;
                    end;

                ' ': begin
                        tocaArqSom ('parar', musicaDeFundo);
                        musicaDeFundo:= '';
                end;
                ^D: begin
                    debugar:= not debugar;
                    limpaBufTec;
                    if not debugar then
                        sintetiza ('Modo debug dezativado')
                    else
                        sintetiza ('Modo debug ativo');
                end;
                #13: begin
                    if saltarSlide > 0 then
                    begin
                        limpaBufTec;
                        linkSlide (saltarSlide);
                        visualizaTelaGrafica;
                    end
                    else
                    if nomeProg <> '' then
                    begin
                        paramProg:= '';
                        if pos (' ', nomeProg) <> 0 then
                        begin
                            paramProg:= copy (nomeProg, pos (' ', nomeProg) + 1, length (nomeProg));
                            paramProg:= '"' + paramProg + '"';
                            delete (nomeProg, pos (' ', nomeProg), length (nomeProg));
                        end;
                        guardaLinhaAtual:= linhaAtual;
                        escondeTelaGrafica;
                        limpaBufTec;
                        sintSom ('PPESCOND');
                        while sintFalando do waitMessage;
                            tocaArqSom ('parar', musicaDeFundo);
                            musicaDeFundo:= '';
                        delay (500);
                        if executaProg (nomeProg, '', paramProg) > 32 then
                        begin
                            delay (2000);
                            esperaProgVoltar;
                            limpaBufTec;
                            sintSom ('PPRETORN'); {('RETORNANDO');}
                        end
                        else
                            sintSom ('PPNAOEXE'); {('NÃO CONSEGUI EXECUTAR');}
                        delay (500);
                        visualizaTelaGrafica;
                        sintSom ('PPVISUAL');
                        while sintFalando do waitMessage;
                        linhaAtual:= guardaLinhaAtual;
                        limpaBufTec;
                    end;
                end;
                #10: begin
                    if nomeProg <> '' then
                    begin
                        paramProg:= '';
                        if pos (' ', nomeProg) <> 0 then
                        begin
                            paramProg:= copy (nomeProg, pos (' ', nomeProg) + 1, length (nomeProg));
                            paramProg:= '"' + paramProg + '"';
                            delete (nomeProg, pos (' ', nomeProg), length (nomeProg));
                        end;
                        cmd:= nomeProg + ' ' + paramProg;
                        guardaLinhaAtual:= linhaAtual;
                        escondeTelaGrafica;
                        limpaBufTec;
                        sintSom ('PPESCOND');
                        while sintFalando do waitMessage;
                            tocaArqSom ('parar', musicaDeFundo);
                            musicaDeFundo:= '';
                        delay (500);
//                        if WinExecAndWait32 (cmd, SW_SHOWNORMAL) then
//                        if WinExecAndWait32 (cmd, SW_SHOWMINIMIZED) then
                        GetWindowText (getForegroundWindow, nomeJan, 256);
                        if executaProg (nomeProg, '', paramProg) > 32 then
                        begin
                            repeat
                                delay (1000);
                                GetWindowText (getForegroundWindow, nomeJanProg, 256);
                            until strComp (nomeJan, nomeJanProg) <> 0;

                            keyBoardAlt (TAB, 100);
                            visualizaTelaGrafica;
                        end;

                        delay (500);
                        visualizaTelaGrafica;
                        sintSom ('PPVISUAL');

                        while sintFalando do waitMessage;
                        linhaAtual:= guardaLinhaAtual;
                        limpaBufTec;
                    end;
                end;
            end;

    until c1 = ESC;

    limpaBufTec;

        tocaArqSom ('parar', musicaDeFundo);
        musicaDeFundo:= '';

    if existeArqSom ('PPOPTTER') then
        sintSom ('PPOPTTER')
    else
        sintetiza ('Deseja realmente optar pelo término desta apresentação ? SIM ou NÃO : ');

    opcao:= sintReadkey;
    if upcase(opcao) <> 'S' then
    begin
        limpaBufTec;
        tocarSlide:= true;
        tocarFundoMusical:= true;
        informarFoto:= true;
        sintSom ('PPCONAPR'); {('OK, continue então apresentando');}
        sintSom ('PPVISUAL');
        with slides[slideAtual] do
        sintetiza (titulo);
        while sintFalando do waitMessage;
        limpaBufTec;
        goto inicio;
    end;

fim:
    tocaArqSom ('parar', musicaDeFundo); //Caso esteja executando no modo automático
    inicializaVariaveis;

    escondeTelaGrafica;
    limpaBufTec;
    sintSom ('PPESCOND');
    while sintFalando do waitMessage;

    writeln;
    mensagem ('PPFIMAPR', 1); {('Fim da apresentação, irei retornar ao menu principal');}
    writeln;

end;

{--------------------------------------------------------}
{ Apresenta os slides, criaJanela, criaFontes,
{ destroiFontes e DestroiJanela
{--------------------------------------------------------}

procedure apresentaSlides;
var s: string;
label pula, fim;
begin

    if apresentaAuto then
    begin
        capturouEstilo:= false;
        goto pula;
    end;

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
            goto fim;
        end
        else
            capturouEstilo:= false;
    end;

    pula:

    if not carregaArq then
        goto fim
    else
    begin
        defineEstilo;
        apresentando:= true;
    end;

    writeln;
    mensagem ('PPOKINI', 1); {('OK, darei início a apresentação, F1 ajuda');}

    writeln;
    if tempoSlide > 0 then
        mensagem ('PPTROSLI', 1); {('Irei trocar os SLIDES no tempo especificado');}
    delay (100);
    if repeteAuto then
        mensagem ('PPREPIF', 1); {('Repetirei do início ao fim até que seja pressionado ESCAPE');}
    delay (100);
    if tempoLinha > 0 then
        mensagem ('PPSINLIN', 1); {('Irei sintetizar as linhas no intervalo definido');}
    writeln;

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

    //------------------- Apresentação propriamente dita --------------------------

    criaTelaGrafica (@desenhaSlideCompleto, figuraDeFundo <> '');

    trataTecladoApresenta;

    destroiTelaGrafica;

    fim:
    apresentando:= false;
    apresentaAuto:= false;
    tempoSlide:= 0;
    repeteAuto:= false;

end;

{--------------------------------------------------------}
{  Definindo som e mensagens da tela do menu
{--------------------------------------------------------}

procedure menuPPTVOX;
begin
    sintSom ('PPMENU');
    delay (100);
    writeln;
    mensagem ('PPOP', 1); {'Opções nas teclas:'}
    writeln;
    delay (100);

    mensagem ('PPCRIA', 1);
    mensagem ('PPNOVEST', 1);
    mensagem ('PPEDITA', 1);
    mensagem ('PPAPRESE', 1);
    mensagem ('PPCONF', 1);
    mensagem ('PPIMPRIM', 1);
    mensagem ('PPIMPORT', 1);
    mensagem ('PPEXPORT', 1);
    mensagem ('PPSCRITT', 1);

//    sintBip; sintBip;
//    delay (100);
//    sintetiza ('PARA DESENVOLVEDORES');
//    delay (100);
//    sintetiza ('CONTROL+D, ATIVA MODO DEBUG');
//    sintetiza ('CONTROL+P, EDITA .PPX');
//    sintetiza ('CONTROL+T, EDITA .TXT');
//    sintetiza ('CONTROL+E, EDITA .EST');

    writeln;
end;

{--------------------------------------------------------}
{            Seleciona uma das opções do Menu
{--------------------------------------------------------}

function selSetasOpcao: char;
var n: integer;
const
    tabLetrasOpcoes: string [9] = 'nseacpixg';

begin
    garanteEspacoTela(14);
    popupMenuCria (wherex, wherey, 50, 14, MAGENTA);
    MenuAdiciona ('PPCRIA');
    menuAdiciona ('PPNOVEST');
    MenuAdiciona ('PPEDITA');
    MenuAdiciona ('PPAPRESE');
    MenuAdiciona ('PPCONF');
    MenuAdiciona ('PPIMPRIM');
    MenuAdiciona ('PPIMPORT');
    MenuAdiciona ('PPEXPORT');
    MenuAdiciona ('PPSCRITT');

    n := popupMenuSeleciona;

    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;

end;

{--------------------------------------------------------}
{        Abre apresentação ou abre uma nova
{--------------------------------------------------------}


function carregaApresentacao: boolean;
begin
    result := true;

    writeln;
    mensagem ('PPINFDES', 0); {('Informe o nome desta apresentação : ');}
    garanteEspacoTela (11);
    nomeArq:= obtemNomeArqMasc (10, '*.PPX');
    writeln (nomeArq);
    if nomeArq = '' then
        begin
            mensagem ('PPDESIST', 1);    {'Desistiu'}
            exit;
        end;

    if pos ('.', nomeArq) <> 0 then
        delete (nomeArq, pos ('.', nomeArq), length (nomeArq));
    nomeArq:= nomeArq + '.PPX';

    if not existearq (nomeArq) then
        begin
            writeln;
            mensagem ('PPCRIANO', 1); {('Nova apresentação');}
            writeln;
            clrscr;
            titulo;
            defineEstilo;


            trataTecladoCria;
        end
    else
        if not carregaArq then
            result := false
        else
            titulo;
            defineEstilo;
end;


{--------------------------------------------------------}
{           edita um dos arquivos de configuração
{--------------------------------------------------------}

procedure editaTexto (msg: string; masc: string);
var
    nomArqEdit: string;
begin
    writeln;
    mensagem (msg, 0);
    garanteEspacoTela (11);
    nomArqEdit:= obtemNomeArqMasc (10, masc);
    writeln (nomArqEdit);
    if nomArqEdit <> '' then
        editaArqEdivox (nomArqEdit);
end;

{--------------------------------------------------------}
{      Apresenta Slides, informa o arquivo e processa
{--------------------------------------------------------}

procedure processa;
var
    c1, c2: char;
    processando: boolean;

label executa;

begin
    if apresentaAuto then
        apresentaSlides
    else
        if not carregaApresentacao then
            exit;

    writeln;

    processando := true;
    while (processando)  do
       begin
           delay (100);

           textBackground (BLUE);

           mensagem ('PPQUALOP', 0);  {'Qual sua opção ? F1 ajuda : '}
           textBackground (BLACK);

           sintLeTecla (c1, c2);
           writeln;

           if c1 = #0 then
             begin
                 case c2 of
                   CIMA, BAIX:
                    begin
                        c1 := selSetasOpcao;
                        goto executa;
                    end;
                   F1: menuPPTVOX;
                   CTLF8: falaDia;
                   F9: leitorDeTela;
                 end;
             end
           else
executa:
               case upcase(c1) of
                   'N': begin nomeArq:= ''; defineNome; end;
                   'S': begin nomeEstilo:= ''; defineEstilo; end;
                   'E': editaTitulos;
                   'A': apresentaSlides;
                   'C': configuraPPT;
                   'P': imprimeArqTXT;
                   'I': defineTipoImport;
                   'X': defineTipoExport;
                   'G': if not defineScript then;

                   ^P:  editaTexto ('PPINFPPX', '*.PPX'); {'Informe o arquivo PPX a editar : '}
                   ^T:  editaTexto ('PPINFTXT', '*.TXT'); {'Informe o arquivo TXT a editar : '}
                   ^E:  editaTexto ('PPINFEST', '*.EST'); {'Informe o arquivo EST a editar : '}

                   ^D: begin
                           debugar:= not debugar;
                           if not debugar then
                               sintetiza ('Modo debug desativado')
                           else
                               sintetiza ('Modo debug ativo');
                       end;

                   ESC:  processando := false;

                   #$0d: ;
               else
                   mensagem ('PPOPINV', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

end;

end.


