Unit ppCria;

interface

uses dvCrt, dvWin, dvArq, dvForm, dvJpeg, videoVox,
    windows, sysUtils,
    ppEstilo, ppNavega, ppDesen, ppJanela, ppArq, ppEdita, ppMsg, ppVars;

procedure debugarSlide;
procedure criaSlides (inserindoSlides: boolean);
procedure trataTecladoCria;
procedure defineNome;

implementation

{--------------------------------------------------------}

procedure debugarSlide;
var opcao: char;
label deNovo;
begin

    debugCriando:= true;
    debugar:= true;

    deNovo:

    apresentando:= true;
    criaTelaGrafica (@desenhaSlideCompleto, figuraDeFundo <> '');
    exibeSlide;

    sintSom ('PPVISUAL');
    while sintFalando do waitMessage;

    if not sintDimensoesOK then
    begin
        sintSom ('PPVISPRE');
        readkey;

        destroiTelaGrafica;
        apresentando:= false;
        escondeTelaGrafica;
        limpaBufTec;
        sintSom ('PPESCOND');
        while sintFalando do waitMessage;

        writeln;
        mensagem ('PPDESRED', 0); {'Deseja redefinir agora ? ');}
        opcao:= sintReadkey;
        writeln (opcao);
        writeln;

        if upcase (opcao) = 'S' then
        begin
            with slides[slideAtual] do
            begin
                if modelo = capa then
                    editaCapa;
                if modelo = listaSimples then
                    editaListaSimples;
                if modelo = figura then
                    editaFigura;
                if modelo = video then
                    editaVideo;
                if modelo = textofigura then
                    editaTextoFigura;
                goto deNovo;
            end;
        end;
    end
    else
    begin
        delay (500);
        destroiTelaGrafica;
        apresentando:= false;
        escondeTelaGrafica;
        limpaBufTec;
    end;

    debugar:= false;
    debugCriando:= false;

end;

{--------------------------------------------------------}

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

{--------------------------------------------------------}

procedure menuCria;
begin

    sintSom ('PPMENU');
    delay (100);
    writeln;
    mensagem ('PPOP', 1);      {'Opções nas teclas:'}
    writeln;
    delay (100);

    mensagem ('PPCAPA', 1);    {'  C   Capa');}
    mensagem ('PPLISTA', 1);   {'  L   Lista');}
    mensagem ('PPFIG', 1);     {'  F   Figura');}
    mensagem ('PPVID', 1);     {'  V   Vídeo');}
    mensagem ('PPTEXTOFIG', 1);     {'  T   TextoFigura');}

    writeln;

end;

{--------------------------------------------------------}

function selSetasCria: char;
var n: integer;
const
    tabLetrasOpcoes: string [5] = 'clfvt';

begin
    garanteEspacoTela(9);
    popupMenuCria (wherex, wherey, 50, 9, MAGENTA);
    MenuAdiciona ('PPCAPA');    {'  C   Capa');}
    MenuAdiciona ('PPLISTA');   {'  L   Lista');}
    MenuAdiciona ('PPFIG');     {'  F   Figura');}
    MenuAdiciona ('PPVID');     {'  V   Vídeo');}
    MenuAdiciona ('PPTEXTOFIG');     {'  T   TextoFigura');}

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasCria := tabLetrasOpcoes[n]
    else
        selSetasCria := ESC;
end;

{--------------------------------------------------------}

procedure criaSlides (inserindoSlides: boolean);
var c1, c2: char;
    processando: boolean;
label executa;
begin

    processando := true;

    while (processando)  do
        begin

            clrscr;
            salvarSlide:= false;

            sintSom ('PPNOVSLI');
            delay (100);

            if not inserindoSlides then
                begin
                    mensagem ('PPIRECRI', 0); {('Irei criar o slide ');}
                    sintWriteInt (slideAtual + 1);
                    writeln;
                end
            else
                    mensagem ('PPINSSLI', 1); {('Inserindo slide');}

           textBackground (BLUE);
           mensagem ('PPQUALCR', 0);  {'Qual o modelo ? F1 ajuda : '}
           textBackground (BLACK);

           sintLeTecla (c1, c2);
           writeln;
           if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
                begin
                    c1 := selSetasCria;
                    goto executa;
                end
           else
           if (c1 = #0) and (c2 = F1) then
               menuCria
           else
           if (c1 = #0) and (c2 = F9) then
               leitorDeTela
           else
executa:
               case upcase(c1) of


                   'C': begin
                        with slides[slideAtual] do
                        begin
                            modelo:= capa;
                            editaCapa;
                            if salvarSlide then
                            begin
                                debugarSlide;
                                slideAtual:= slideAtual + 1;
                            end;
                        end;
                   end;
                   'L': begin
                        with slides[slideAtual] do
                        begin
                            modelo:= listaSimples;
                            editaListaSimples;
                            if salvarSlide then
                            begin
                                debugarSlide;
                                slideAtual:= slideAtual + 1;
                            end;
                        end;
                   end;
                   'F': begin
                        with slides[slideAtual] do
                        begin
                            modelo:= figura;
                            editaFigura;
                            if salvarSlide then
                            begin
                                debugarSlide;
                                slideAtual:= slideAtual + 1;
                            end;
                        end;
                   end;
                   'V': begin
                        with slides[slideAtual] do
                        begin
                            modelo:= video;
                            editaVideo;
                            if salvarSlide then
                            begin
                                debugarSlide;
                                slideAtual:= slideAtual + 1;
                            end;
                        end;
                   end;

                   'T': begin
                                with slides[slideAtual] do
                                begin
                                        modelo:= textofigura;
                                        editaTextoFigura;
                                        if salvarSlide then
                                        begin
                                                debugarSlide;
                                                slideAtual:= slideAtual + 1;
                                        end;
                                end;
                        end;



                 ESC: begin processando := false; sintSom ('PPDESIST'); end;
               else
                   mensagem ('PPOPINV', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

end;

{--------------------------------------------------------}

procedure trataTecladoCria;
begin

    criandoSlide := true;

    slideAtual := 0;
    nSlides := 0;

    criaSlides (false);

    if slideAtual > 0 then
    begin
        nSlides:= slideAtual;
        salvaArqPPX;
    end;

    criandoSlide:= false;

end;

{--------------------------------------------------------}

procedure defineNome;
begin

    writeln;
    mensagem ('PPINFDES', 0); {('Informe o nome desta apresentação : ');}
    garanteEspacoTela (11);
    nomeArq:= obtemNomeArqMasc (10, '*.PPX');
    writeln (nomeArq);
    if nomeArq = '' then
    begin
        mensagem ('PPDESIST', 1);
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
        nomeEstilo:= '';
        defineEstilo;
        trataTecladoCria;
//        if not SalvarSlide then
//            mensagem ('PPDESIST', 1);
    end
    else
    begin
        capTurouEstilo:= false;
        if not carregaArq then
            exit
        else
            defineEstilo;
    end;

    clrscr;
    limpaBufTec;

end;

end.
