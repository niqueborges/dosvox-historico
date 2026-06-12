{--------------------------------------------------------}
{                                                        }
{    Programa de palavras cruzadas                       }
{                                                        }
{    Módulo de controle da interação do jogo             }
{                                                        }
{    Autores: José Antonio Borges                        }
{             Jorge Carlos dos Santos                    }
{                                                        }
{    Em agosto/2010                                      }
{                                                        }
{--------------------------------------------------------}

unit crjoga;

interface

uses windows, dvcrt, dvwin, dvForm, dvArq, sysutils, mmsystem,
     crmsg, crarq, crvars, crdesen, credipal, crinstru, crimport;

function iniciaJogo: boolean;
procedure joga;

implementation

var
    jogando: boolean;

procedure mostraTempo;
var tempoGasto: integer;
begin
    tempoGasto := trunc (frac (time - horaInicial) * (24*60*60));
    if tempoGasto = 0 then
        exit;

    mensagem ('CRTEMPO', 0);   {'Tempo de jogo: '}
    sintWriteint (tempoGasto div 60);
    sintWrite (' minutos ');
    sintWriteint (tempoGasto mod 60);
    sintWrite (' segundos');
end;

function ganhouJogo: boolean;
var x, y: integer;
begin
    ganhouJogo := true;
    for y := 1 to ny do
        for x := 1 to nx do
            if (modelo [y,x] <> '*') and
               (modelo [y,x] <> '.') and
               (modelo [y,x] <> ' ') then
                    if modelo[y,x] <> tabuleiro[y,x] then
                        begin
                            ganhouJogo := false;
                            exit;
                        end;
end;

procedure parabens;
var i, j: integer;
begin
    areaLegendas;
    clrscr;
    for i := 1 to 17 do
        begin
            for j := 1 to i-1 do
                write (' ');
            textColor (random (15) + 1);
            writeln ('Parabéns');
        end;
    writeln;
    sndPlaysound ('\windows\media\tada.wav', SND_SYNC);
    mensagem ('CRPARABE', 1);   {'Parabéns, você ganhou o jogo!'}
    mostraTempo;
    writeln;
    mensagem ('CRNUMDIC', 0);   {'Número de dicas utilizadas: '}
    sintWriteInt (numDicas);
    writeln;
    textColor (White);
    mensagem ('CRAPTENT', 0);   {'Aperte enter...'}
    readln;
end;

procedure copiaModeloParaTabuleiro;
var lin, col: integer;
    s: string;
begin
    for lin := 1 to ny do
        begin
            s := modelo[lin];
            for col := 1 to length (s) do
                if (s[col] = ' ') or (s[col] = '.') or (s[col] = '*') then
                    s[col] := '*'
                else
                    s[col] := '.';
            tabuleiro[lin] := s;
        end;
end;

procedure salvarJogo;
var ano, mes, dia, sem: word;
begin
    mensagem ('CRINSCOM', 1);  {'Insira um comentário nesta gravação'}
    sintReadln (comentario);
    tempo := trunc (frac (time - horaInicial) * (24*60*60));
    mensagem ('CRDIGNOM', 1);  {'Jogador, digite seu nome'}
    sintReadln (jogador);
    getdate (ano, mes, dia, sem);
    data := intToStr(dia) + '/' + intToStr(mes) + '/' + intToStr(ano);

    salvaJogoAtivo (nomeArq);
end;

procedure lerJogo;
begin
    carregaJogoAtivo(nomeArq);
    horaInicial := time - tempo;   { acumula o tempo }

    sintWriteln (comentario);
    mensagem ('CRJOGADO', 1);      {'Jogado por'}
    sintWriteln (jogador);
    mensagem ('CRDATAJO', 0);      {'Data: '}
    sintWriteln (data);
    mensagem ('CRTEMPAC', 0);      {'Tempo acumulado: '}
    sintWriteint (tempo);
    writeln;
end;

function iniciaJogo: boolean;
var
    numJogos: integer;
    carregou: boolean;
    nomeArqJogando: string;
    c, c2: char;
begin
    iniciaJogo := false;

    if not escolhePastaJogo (dirAtual) then
        exit;
    if dirAtual <> '' then
        begin
            {$I-}  chdir (dirAtual); {$I+}
            if ioresult <> 0 then
            begin
                mensagem ('CRDIRNAO', 2);  {'Diretório de jogos não foi achado'}
                sintWriteln (dirAtual);
                exit;
            end;
        end;

    numJogos := pegaNumArqs;
    writeln;
    mensagem ('CRDISPON', 0);     {'Número de jogos disponíveis: '}
    sintWriteln (intToStr (numJogos));
    writeln;
    if numJogos = 0 then
        begin
            delay(1000);
            limpatela;
            exit;
        end;

    mensagem ('CRNOMJOG', 1);     {'Use as setas ou informe o nome do jogo'}
    nomeArq := obtemNomeArqMasc(24-wherey, '*.crz');
    writeln (nomeArq);

    carregou := carregaJogoModelo (nomeArq);
    copiaModeloParaTabuleiro;

    nomeArqJogando := trocaExtensao ('JOG', nomeArq);
    if FileExists(nomeArqJogando) then
        begin
            writeln;
            mensagem ('CRJOGINT', 1);   {'Este jogo tinha sido interrompido.'}
            mensagem ('CRCONTIN', 0);   {'Deseja continuar de onde parou? '}
            sintLeTecla (c, c2);
            writeln; writeln;

            if upcase(c) = 'S' then
                lerJogo;
        end;

    iniciaJogo := carregou;
    xatu := 1;
    yatu := 1;
end;

function editoraPalavra(var palavra: string; palavraModelo: string): char;
var
    tam, i: integer;
    c: char;
    vazia: boolean;
begin
    sintetiza (intTostr (length (palavra)) +
               pegaTextoMensagem('CRCARACT'));  {' caracteres'}

    write (palavra, #$0d);
    tam := length(palavra);

    vazia := true;
    for i := 1 to tam do
        if (palavra[i] <> '.') and (palavra[i] <> ' ') then
            begin
                vazia := false;
                break;
            end;

    if not vazia then
        begin
            sintSoletra (palavra);
            delay (500);
        end;

    c := editaPalavra (palavra, palavraModelo);
    for i := 1 to tam do
         if palavra[i] = ' ' then palavra[i] := '.';
    palavra := copy (ansiUpperCase(palavra) + '................', 1, tam);
    write (#$0d);  clreol;

    result := c;
end;

procedure  folhearHorizontais;
var n, i, x, y: integer;
    s, palavra, palavraModelo: string;
    c: char;
begin
    n := 1;
    while true do
        begin
            clrscr;
            mensagem ('CRHORIZS', 1); {'Horizontais, selecione com as setas'}
            writeln;

            opcoesCria (wherex, wherey, 40);
            for y := 1 to ny do
                for x := 1 to nx do
                    if legendasHoriz[y, x] <> '' then
                        opcoesAdiciona ('', chr(x-1+ord('A')) + intToStr(y) + ' ' +
                                            legendasHoriz[y,x]);
            n := opcoesSelecInic(n);
            if n <= 0 then exit;

            s := opcoesItemSelecionado;
            x := ord(s[1]) - ord('A') + 1;
            y := strToInt (trim (copy (s, 2, 2)));
            xatu := x;
            yatu := y;

            todaTela;
            textBackground (Brown);
            palavra := '';
            palavraModelo := '';

            for i := x to nx do
                 if tabuleiro[y][i] <> '*' then
                     begin
                         palavra := palavra + tabuleiro[y][i];
                         palavraModelo := palavraModelo + modelo[y][i];
                         gotoxy (i*2+1, yatu+3);
                         write (' ', tabuleiro[y][i]);
                     end
                 else
                     break;

            textBackground (Black);
            areaLegendas;
            gotoxy (1, 21);
            c := editoraPalavra(palavra, palavraModelo);

            if c = #$1b then
                mensagem ('CRDESIST', 1)   {'Desistiu'}
            else
                begin
                    n := n + 1;
                    for i := 1 to length(palavra) do
                         tabuleiro [y, x+i-1] := palavra[i];
                    todaTela;
                    desenhaCruzadas(nx, ny, tabuleiro);
                    areaLegendas;

                    if ganhouJogo then
                        sndPlaysound ('\windows\media\chimes.wav', SND_SYNC);
                end;
        end;
end;

procedure  folhearVerticais;
var n, i, x, y: integer;
    s, palavra, palavraModelo: string;
    c: char;
begin
    n := 1;
    while true do
        begin
            clrscr;
            mensagem ('CRVERTS', 1); {'Verticais, selecione com as setas'}
            writeln;

            opcoesCria (wherex, wherey, 40);
            for y := 1 to ny do
                for x := 1 to nx do
                    if legendasVert[y, x] <> '' then
                        opcoesAdiciona ('', chr(x-1+ord('A')) + intToStr(y) + ' ' +
                                            legendasVert[y,x]);

            n := opcoesSelecInic(n);
            if n <= 0 then exit;

            s := opcoesItemSelecionado;
            x := ord(s[1]) - ord('A') + 1;
            y := strToInt (trim (copy (s, 2, 2)));
            xatu := x;
            yatu := y;

            todaTela;
            textBackground (Brown);
            palavra := '';
            palavraModelo := '';

            for i := y to ny do
                 if tabuleiro[i][x] <> '*' then
                     begin
                         palavra := palavra + tabuleiro[i][x];
                         palavraModelo := palavraModelo + modelo[i][x];
                         gotoxy (1+xatu*2, i+3);
                         write (' ', tabuleiro[i][x]);
                     end
                 else
                     break;

            textBackground (Black);
            areaLegendas;
            gotoxy (1, 21);
            c := editoraPalavra(palavra, palavraModelo);

            if c = #$1b then
                mensagem ('CRDESIST', 1)   {'Desistiu'}
            else
                begin
                    n := n + 1;
                    for i := 1 to length(palavra) do
                         tabuleiro [y+i-1, x] := palavra[i];
                    todaTela;
                    desenhaCruzadas(nx, ny, tabuleiro);
                    areaLegendas;

                    if ganhouJogo then
                        sndPlaysound ('\windows\media\chimes.wav', SND_SYNC);
                end;
    end;
end;

procedure  informacoes;
begin
    mensagem ('CRTITUJG', 1); {'Título deste jogo'}
    sintWriteln (titulo);
    writeln;
    mensagem ('CRTEMAJG', 1); {'Tema'}
    sintWriteln (tema);
    writeln;
    mensagem ('CRAUTRJG', 1); {'Autor'}
    sintWriteln (autor);
    writeln;
    mensagem ('CRDATAJG', 1); {'Data de elaboração'}
    sintWriteln (dataCriacao);
    writeln;
    writeln;
    mensagem ('CRAPTENT', 1); {'Aperte enter para continuar...'}
    readln;
end;

procedure LimparTabuleiro;
var c: char;
begin
    mensagem ('CRNAODSF', 1);  {'Atenção esta operação não pode ser desfeita'}
    mensagem ('CRAPTC', 0);    {'Aperte C para confirmar'}
    c := sintReadkey;
    if upcase(c) = 'C' then
        begin
            writeln (c);
            sintBip;
            copiaModeloParaTabuleiro;
            mensagem ('CTTABLIM', 1);    {'Tabuleiro foi limpo'}
        end
    else
        mensagem ('CTDESIST', 1);    {'Desistiu'}
end;

procedure falaLetra (x, y: integer);
var c: char;
begin
    c := tabuleiro[y, x];
    case c of
        '*':  begin sintBip; sintbip; end;
        ' ', '.':  sintClek;
    else
        sintCarac (c);
    end;
end;

procedure falaPos (x, y: integer);
begin
    sintetiza (chr(x-1+ord('A')) + intToStr(y));
end;

procedure alteraatuxy (dx, dy: integer);
begin
    xatu := xatu + dx;
    yatu := yatu + dy;
    if (xatu >= 1) and (xatu <= nx) and
       (yatu >= 1) and (yatu <= ny) then exit;

    sintBip; sintBip; sintBip;
    if xatu < 1 then xatu := 1;
    if yatu < 1 then yatu := 1;
    if xatu > nx then xatu := nx;
    if yatu > ny then yatu := ny;
end;

procedure diagnostico;
var i, x, y: integer;
    houveErro, erroPalavra: boolean;
begin
    mensagem ('CRDIAGJG', 2);   {'Diagnóstico do jogo'}
    if ganhouJogo then
        begin
            parabens;
            jogando := false;
        end
    else
        begin
              mensagem ('CRPOSERR', 2);  {'Posições com erros'}

              mensagem ('CRHOR', 1); {'Horizontais'}
              houveErro := false;
              for y := 1 to ny do
                  for x := 1 to nx do
                      if legendasHoriz[y, x] <> '' then
                          begin
                              erroPalavra := false;
                              for i := x to nx do
                                   begin
                                       if tabuleiro[y][i] = '*' then break;
                                       if tabuleiro[y][i] <> modelo[y][i] then
                                           begin
                                               erroPalavra := true;
                                               break;
                                           end;
                                   end;
                              if erroPalavra then
                                  begin
                                      sintWrite(chr(x-1+ord('A')) + intToStr(y) + ' ');
                                      houveErro := true;
                                  end;
                          end;

              if not houveErro then
                  mensagem ('CRTUDOOK', 1)  {'Todas perfeitas'}
              else
                  writeln;

              writeln;
              mensagem ('CRVER', 1); {'Verticais'}
              houveErro := false;
              for y := 1 to ny do
                  for x := 1 to nx do
                      if legendasVert[y, x] <> '' then
                          begin
                              erroPalavra := false;
                              for i := y to ny do
                                   begin
                                       if tabuleiro[i][x] = '*' then break;
                                       if tabuleiro[i][x] <> modelo[i][x] then
                                           begin
                                               erroPalavra := true;
                                               break;
                                           end;
                                   end;
                              if erroPalavra then
                                  begin
                                      sintWrite(chr(x-1+ord('A')) + intToStr(y) + ' ');
                                      houveErro := true;
                                  end;
                          end;

              if not houveErro then
                 mensagem ('CRTUDOOK', 1);  {'Todas perfeitas'}
        end;

    delay (2000);
end;

procedure ajudaNavegacao;
var i: char;
begin
    areaLegendas;
    clrscr;
    for i := '1' to '7' do
        mensagem ('CRAJUN'+i, 1);
    todaTela;
end;

procedure navegar (podeAlterar: boolean);
var c, letraAtual: char;
    acabou: boolean;
    x, y: integer;
    salvax, salvay: integer;

                procedure lePalavraHoriz;
                var s: string;
                begin
                    x := xatu;
                    if letraAtual <> '*' then
                        begin
                            mensagem ('CRHORIZ', -1);  {'Horizontal'}

                            while (x > 1) and (tabuleiro[yatu, x-1] <> '*') do
                                x := x - 1;
                            xatu := x;
                            repeat
                                s := s + tabuleiro[yatu, x];
                                x := x + 1;
                            until (x > nx) or (tabuleiro[yatu, x] = '*');

                            if legendasHoriz [yatu, xatu] <> '' then
                                 sintetiza (legendasHoriz [yatu, xatu]);
                            sintClek;

                            sintetiza (intTostr (length (s)) +
                                pegaTextoMensagem('CRCARACT'));  {' caracteres'}
                            delay (500);
                            if copy ('...............', 1, length(s)) <> s then
                                if pos('.', s) <> 0 then
                                    sintSoletra(s)
                                else
                                    sintetiza(s);
                            sintBip;
                        end;
                end;

                procedure lePalavraVert;
                var s: string;
                begin
                    y := yatu;
                    s := '';
                    if letraAtual <> '*' then
                        begin
                            mensagem('CRVERT', -1);  {'Vertical'}

                            while (y > 1) and (tabuleiro[y-1, xatu] <> '*') do
                                y := y - 1;
                            yatu := y;
                            repeat
                                s := s + tabuleiro[y, xatu];
                                y := y + 1;
                            until (y > ny) or (tabuleiro[y, xatu] = '*');

                            if legendasVert [yatu, xatu] <> '' then
                                 sintetiza (legendasHoriz [yatu, xatu]);
                            sintClek;

                            sintetiza (intTostr (length (s)) + ' caracteres');
                            delay (500);
                            if copy ('...............', 1, length(s)) <> s then
                                if pos('.', s) <> 0 then
                                    sintSoletra(s)
                                else
                                    sintetiza(s);
                            sintBip;
                        end;
                end;

begin
    mensagem ('CRNAVEG', 1);   {'Navegando, F1 ajuda'}
    sintetiza (pegaTextoMensagem ('CRVOCEST'));   {'Você está em '}
    falaPos (xatu, yatu);

    todaTela;
    acabou := false;
    repeat
        gotoxy (2+(xatu*2), 3+yatu);

        falaLetra (xatu, yatu);
        letraAtual := tabuleiro[yatu, xatu];

        c := readkey;
        if c = #$0 then
            begin
                c := readkey;
                case c of
                    F1:   ajudaNavegacao;

                    F5:   begin
                              falaPos (xatu, yatu);
                              delay (500);
                          end;
                    F6:   if (modelo[yatu, xatu] <> '.') and (modelo[yatu, xatu] <> '.') then
                              begin
                                  mensagem ('CRDICAPO', -1);  {'Dica para esta posição: '}
                                  tabuleiro[yatu, xatu] := modelo[yatu, xatu];
                                  desenhaCruzadas(nx, ny, tabuleiro);
                                  numDicas := numDicas + 1;
                              end;

                    CIMA: if GetKeyState(VK_CONTROL) < 0 then
                              lepalavraVert
                          else
                              alteraatuxy (0, -1);

                    BAIX: if GetKeyState(VK_CONTROL) < 0 then
                              begin
                                  y := yatu;
                                  if letraAtual <> '*' then
                                      begin
                                          while (y <= ny) and (tabuleiro[y, xatu] <> '*') do
                                              y := y + 1;
                                          yatu := y;
                                      end;
                              end
                          else
                              alteraatuxy (0, 1);

                    ESQ:  if GetKeyState(VK_CONTROL) < 0 then
                              lePalavraHoriz
                          else
                              alteraatuxy (-1, 0);

                    DIR:  if GetKeyState(VK_CONTROL) < 0 then
                              begin
                                  x := xatu;
                                  if letraAtual <> '*' then
                                      begin
                                          while (x < nx) and (tabuleiro[yatu, x+1] <> '*') do
                                              x := x + 1;
                                          xatu := x;
                                      end;
                              end
                          else
                              alteraatuxy (1, 0);

                    HOME: xatu := 1;
                    TEND: xatu := nx;
                    PGUP: yatu := 1;
                    PGDN: yatu := ny;
                end;
            end
        else
            begin
                if c = #$0d then
                    begin
                        salvax := xatu;  salvay := yatu;
                        falaPos (xatu, yatu);
                        falaLetra (xatu, yatu);
                        delay (500);

                        lePalavraHoriz;
                        xatu := salvax;  yatu := salvay;
                        delay (500);

                        lePalavraVert;
                        xatu := salvax;  yatu := salvay;
                        delay (500);
                    end;

                if c = #$1b then
                    acabou := true
                else
                if c = ^L then
                    begin
                        falaPos (xatu, yatu);
                        delay (500);
                    end
                else
                if (c >= 'A') and podeAlterar then
                    begin
                        c := ansiUpperCase(c)[1];
                        if c <> letraAtual then
                            sintBip;
                        if tabuleiro[yatu, xatu] <> '*' then
                            tabuleiro[yatu, xatu] := c;
                        desenhaCruzadas(nx, ny, tabuleiro);
                        if ganhouJogo then
                            acabou := true;
                    end;

            end;
    until acabou;

end;

function mostraSolucao: boolean;
var c: char;
    x, y: integer;
begin
    mostraSolucao := false;
    mensagem ('CRACABAR', 1);   {'Ver a solução encerrará o jogo.'}
    mensagem ('CRTEMCRT', 0);   {'Tem certeza que quer ver a solução?'}

    c := upcase(sintReadkey);
    writeln (c);
    limpaBufTec;
    if c <> 'S' then
        begin
            mensagem ('CRDESIST', 1);  {'Desistiu'}
            exit;
        end;

    for y := 1 to ny do
        begin
            tabuleiro[y] := modelo[y];
            for x := 1 to length (tabuleiro[y]) do
                if tabuleiro[y, x] = '.' then
                    tabuleiro[y, x] := '*';
        end;

    mensagem ('CRJOGCAN', 1);   {'Jogo cancelado'}
    mensagem ('CRVERSOL', 1);   {'Pode ver a solução, use as setas'}

    todaTela;
    desenhaCruzadas(nx, ny, tabuleiro);

    areaLegendas;
    gotoxy (1, 12);
    navegar(false);

    mostraSolucao := true;
end;

function interrompeJogo: boolean;
var c: char;
begin
    interrompeJogo := false;

    mensagem ('CRQURINT', 0);   {'Quer mesmo interromper o jogo? '}
    c := upcase(sintReadkey);
    writeln (c);
    limpaBufTec;
    if c <> 'S' then
        begin
             mensagem ('CRDESIST', 1);   {'Desistiu'}
             exit;
        end;

    mensagem ('CRQUERGV', 0);   {'Quer gravar para continuar depois? '}
    c := upcase(sintReadkey);
    writeln (c);
    limpaBufTec;
    if c = #$1b then
        begin
             mensagem ('CRDESIST', 1);   {'Desistiu'}
             exit;
        end
    else
        if c = 'S' then
            salvarJogo;

    interrompeJogo := true;
end;

function selecionaAcaodoJogo: char;
var opcao: integer;
const
    tabOpcoes: array [0..12] of char = (' ', 'H','V','N','D','I','S','L','T','Z','X','?', #27);

    procedure menuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

begin
    popupMenuCria (wherex, wherey,44, 4, blue);
    MenuAdiciona ('CRFOHO');    {'H - folhear as posições horizontais'}
    MenuAdiciona ('CRFOVE');    {'V - folhear as posições verticais'}
    MenuAdiciona ('CRNATAB');   {'N - navegar sobre o tabuleiro'}
    MenuAdiciona ('CRDIAG');    {'D - diagnóstico'}
    MenuAdiciona ('CRINFPACR'); {'I - informações sobre este jogo'}
    MenuAdiciona ('CRSALPACR'); {'S - salvar este jogo'}
    MenuAdiciona ('CRLERARQ');  {'L - ler um jogo previamente salvo'}
    MenuAdiciona ('CRMOTE');    {'T - mostra o tempo do jogo'}
    MenuAdiciona ('CRZETAB');   {'Z - Limpar o tabuleiro'}
    MenuAdiciona ('CRMOSSOL');  {'X - mostrar solução'}
    MenuAdiciona ('CRINSTR');   {'F1 - instruções do Jogo'}
    MenuAdiciona ('CRESCINT');  {'ESC - Interrompe o Jogo'}

    opcao := popupMenuSeleciona;
    sintCarac (tabOpcoes [opcao]);
    result := tabOpcoes [opcao];
end;

procedure joga;
var c, c2: char;
begin
    limpaTela;
    desenhaCruzadas(nx, ny, tabuleiro);

    horainicial := time;
    numDicas := 0;
    jogando := true;
    while jogando do
        begin
             limpabuftec;
             while sintFalando do;
             areaLegendas;
             clrscr;
             mensagem ('CROPCJOG', 0);    {'Qual opção? '}
             sintLeTecla (c, c2);
             writeln;

             if (c = #0) and (c2 = F1) then
                 c := '?'
             else
             if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                 c := selecionaAcaodoJogo;

            clrscr;
            case upcase(c) of
                'H': folhearHorizontais;
                'V': folhearVerticais;
                'N': navegar (true);
                'D': diagnostico;
                'I': informacoes;
                'S': salvarJogo;
                'L': lerJogo;
                'T': mostraTempo;
                'Z': LimparTabuleiro;
                'X': jogando := not mostraSolucao;
                '?': instrucoes;
                #27: jogando := not interrompeJogo;
            else
            	mensagem ('CROPINV', 1);   {'Opção inválida'}
            end;

            todaTela;
            desenhaCruzadas(nx, ny, tabuleiro);

        end;
    limpaTela;
end;

end.

