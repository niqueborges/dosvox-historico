unit sujoga;

interface
uses
    dvcrt, dvwin, sysutils, windows, dvform, dvhora,
    suconfig, sucalc, sudesen, sumsg, suarq, suvars;

procedure joga;

implementation

var
    procurado: integer;

{--------------------------------------------------------}
{             fala o conteúdo de uma célula              }
{--------------------------------------------------------}

procedure falaCelula (x, y: integer);
begin
    if sudoku [x, y] = 0 then
        sintClek
    else
    if fixo [x, y] then
        sintetiza (intToStr (sudoku [x, y]))
    else
        sintSoletra (intToStr (sudoku [x, y]));
end;

{---------------------------------------------------------------}
{                  limpa área de interação                      }
{---------------------------------------------------------------}

procedure limpaInteracao;
var i: integer;
begin
    for i := 4 to 24 do
        begin
            gotoxy (50, i);
            clreol;
        end;

    gotoxy (50, 5);
end;

{---------------------------------------------------------------}
{                        mostra o manual                        }
{---------------------------------------------------------------}

procedure mostraManual;
begin
    instrucoes;
    inicTelaJogo;
    mostraSudoku;
end;

{---------------------------------------------------------------}
{                        mostra hora
{---------------------------------------------------------------}

procedure mostraHora;
begin
    falaHora;
end;

{---------------------------------------------------------------}
{                         mostra o dia
{---------------------------------------------------------------}

procedure mostraData;
begin
    falaDia;
end;

{---------------------------------------------------------------}
{                      le a linha atual                         }
{---------------------------------------------------------------}

procedure leLinha;
var x: integer;
begin
    for x := 0 to 8 do
        if sudoku [x, ycur] <> 0 then
            sintCarac (chr (sudoku [x, ycur] + ord ('0')))
        else
            begin
                sintClek;
                delay (500);
            end;
end;

{---------------------------------------------------------------}
{                     le a coluna atual                         }
{---------------------------------------------------------------}

procedure leColuna;
var y: integer;
begin
    for y := 0 to 8 do
        if sudoku [xcur, y] <> 0 then
            sintCarac (chr (sudoku [xcur, y] + ord ('0')))
        else
            begin
                sintClek;
                delay (500);
            end;
end;

{---------------------------------------------------------------}
{                     le a grade atual                          }
{---------------------------------------------------------------}

procedure leGrade;
var x0, y0, x, y: integer;
begin
    x0 := xcur - (xcur mod 3);
    y0 := ycur - (ycur mod 3);

    for y := 0 to 2 do
        for x := 0 to 2 do
            if sudoku [x+x0, y+y0] <> 0 then
                sintCarac (chr (sudoku [x+x0, y+y0] + ord ('0')))
            else
                begin
                    sintClek;
                    delay (700);
                end;
end;

{---------------------------------------------------------------}
{                 ve o que falta numa linha                     }
{---------------------------------------------------------------}

procedure faltaNaLinha;
var presentes: integer;
    x: integer;
    s: string;
begin
    presentes := 0;
    for x := 0 to 8 do
        if sudoku [x, ycur] <> 0 then
             presentes := presentes or (1 shl (sudoku [x, ycur]-1));

    presentes := presentes xor $ffff;
    mensagem ('SUFALTA', 0);   {'Falta: '}

    for x := 0 to 8 do
        if (presentes and (1 shl x)) <> 0 then
             s := s + intToStr (x+1) + ' ';

    if s = '' then
        mensagem ('SUNADA', 0)     {'Nada'}
    else
        sintWrite (s);
end;

{---------------------------------------------------------------}
{                 ve o que falta numa coluna                    }
{---------------------------------------------------------------}

procedure faltaNaColuna;
var presentes: integer;
    y: integer;
    s: string;
begin
    presentes := 0;
    for y := 0 to 8 do
        if sudoku [xcur, y] <> 0 then
             presentes := presentes or (1 shl (sudoku [xcur, y]-1));

    presentes := presentes xor $ffff;
    mensagem ('SUFALTA', 0);   {'Falta: '}

    s := '';
    for y := 0 to 8 do
        if (presentes and (1 shl y)) <> 0 then
             s := s + intToStr (y+1) + ' ';

    if s = '' then
        mensagem ('SUNADA', 0)     {'Nada'}
    else
        sintWrite (s);
end;

{---------------------------------------------------------------}
{                 ve o que falta numa grelha                    }
{---------------------------------------------------------------}

procedure faltaNaGrelha;
var x0, y0, x, y: integer;
    presentes: integer;
    s: string;
begin
    x0 := xcur - (xcur mod 3);
    y0 := ycur - (ycur mod 3);

    presentes := 0;
    for y := 0 to 2 do
        for x := 0 to 2 do
            if sudoku [x+x0, y+y0] <> 0 then
                 presentes := presentes or (1 shl (sudoku [x+x0, y+y0]-1));

    presentes := presentes xor $ffff;
    mensagem ('SUFALTA', 0);   {'Falta: '}

    s := '';
    for y := 0 to 8 do
        if (presentes and (1 shl y)) <> 0 then
             s := s + intToStr (y+1) + ' ';

    if s = '' then
        mensagem ('SUNADA', 0)     {'Nada'}
    else
        sintWrite (s);
end;

{---------------------------------------------------------------}
{       calcula o que falta na linha coluna e grelha            }
{---------------------------------------------------------------}

function faltaLinhaColunaGrelha (xc, yc: integer): integer;
var presentes, faltaLin, faltaCol, faltaGrl: integer;
    x, y: integer;
    x0, y0: integer;
begin
    presentes := 0;
    for x := 0 to 8 do
        if sudoku [x, yc] <> 0 then
             presentes := presentes or (1 shl (sudoku [x, yc]-1));
    faltaLin := presentes xor $ffff;

    presentes := 0;
    for y := 0 to 8 do
        if sudoku [xc, y] <> 0 then
             presentes := presentes or (1 shl (sudoku [xc, y]-1));
    faltacol := presentes xor $ffff;

    x0 := xc - (xc mod 3);
    y0 := yc - (yc mod 3);

    presentes := 0;
    for y := 0 to 2 do
        for x := 0 to 2 do
            if sudoku [x+x0, y+y0] <> 0 then
                 presentes := presentes or (1 shl (sudoku [x+x0, y+y0]-1));

    faltaGrl := presentes xor $ffff;

    faltaLinhaColunaGrelha := faltaLin and faltaCol and faltaGrl;
end;

{---------------------------------------------------------------}
{                      informa a posição atual                  }
{---------------------------------------------------------------}

procedure informaCursor;
begin
    mensagem ('SULIN', 0);       {'linha '}
    sintWriteint (ycur+1);
    mensagem ('SUCOL', 0);       {' coluna '}
    sintWriteint (xcur+1);
end;

{---------------------------------------------------------------}
{                escolhe ponto de menos opções                  }
{---------------------------------------------------------------}

procedure autoEscolha;
var menor, b, falta, nbits: integer;
    x, y: integer;
    xesc, yesc: integer;
label achou;
begin
    menor := 9999;
    xesc := 0;
    yesc := 0;

    for y := 0 to 8 do
        for x := 0 to 8 do
            if sudoku[x, y] = 0 then
                begin
                    falta := faltaLinhaColunaGrelha (x, y);
                    nbits := 0;
                    for b := 0 to 8 do
                         if (falta and (1 shl b)) <> 0 then
                             nbits := nbits + 1;
                    if nbits < menor then
                        begin
                            menor := nbits;
                            xesc := x;
                            yesc := y;
                            if menor = 1 then goto achou;
                            sintClek;
                        end;
                end;

achou:
    xcur := xesc;
    ycur := yesc;

    mensagem ('SUPOSICI', 0);    {'Posicionei no ponto fácil'}
    gotoxy (50, 7);
    informaCursor;
    sintBip; sintBip;
    falaCelula(xcur, ycur);
end;

{---------------------------------------------------------------}
{               dica sobre as possibilidades                    }
{---------------------------------------------------------------}

procedure faltaAqui;
var falta, i: integer;
    s: string;
begin
    if sudoku[xcur, ycur] <> 0 then
        falta := 0
    else
        falta := faltaLinhaColunaGrelha (xcur, ycur);

    s := '';
    for i := 0 to 8 do
        if (falta and (1 shl i)) <> 0 then
             s := s + intToStr (i+1) + ' ';

    if s = '' then
        mensagem ('SUNADA', 0)     {'Nada'}
    else
        sintWrite (s);
end;

{---------------------------------------------------------------}
{                    calcula tempo gasto                        }
{---------------------------------------------------------------}

procedure tempo;
var tempoGasto: integer;
begin
    tempoGasto := trunc (frac (time - horaInicial) * (24*60*60));
    if tempoGasto = 0 then
        exit;
        
    mensagem ('SUTEMPO', 0);   {'Tempo gasto: '}
    sintWriteint (tempoGasto);
end;

{---------------------------------------------------------------}
{                     zera o Sudoku                             }
{---------------------------------------------------------------}

procedure zeraSudoku;
var c, c2: char;
    x, y: integer;
begin
    mensagem ('SUQUERZE', 0);    {'Quer mesmo zerar o que entrou? '}
    sintLeTecla (c, c2);
    if upcase(c) = 'S' then
        begin
            for x := 0 to 8 do
                for y := 0 to 8 do
                    if not fixo [x, y] then
                         sudoku [x, y] := 0;

            sintClek; sintClek; sintClek;
        end;

    xcur := 0;
    ycur := 0;
    limpaBufTec;
end;

{---------------------------------------------------------------}
{                    checa duplicatas                           }
{---------------------------------------------------------------}

function checaDuplicatas (xc, yc, v: integer): integer;
var x, y: integer;
    x0, y0: integer;
    checa: integer;
begin
    checa := 0;

    for x := 0 to 8 do
        if sudoku [x, yc] = v then
            checa := 1;

    for y := 0 to 8 do
        if sudoku [xc, y] = v then
            checa := checa or 2;

    x0 := xc - (xc mod 3);
    y0 := yc - (yc mod 3);

    for y := 0 to 2 do
        for x := 0 to 2 do
            if sudoku [x+x0, y+y0] = v then
                 checa := checa or 4;

    checaDuplicatas := checa;
end;

{---------------------------------------------------------------}
{                       estatística                             }
{---------------------------------------------------------------}

procedure estatistica;
var i, x, y: integer;
    xt, yt: integer;
    vezes: array [0..9] of integer;
begin
    for i := 0 to 9 do
        vezes[i] := 0;

    for y := 0 to 8 do
        for x := 0 to 8 do
            inc (vezes[sudoku [x, y]]);

    xt := wherex;
    yt := wherey;
    sintWriteint (vezes[0]);
    mensagem ('SUCELVAZ', 0);    {' células vazias'}

    for i := 1 to 9 do
        begin
            yt := yt + 1;  gotoxy (xt, yt);
            sintWriteint (i);
            mensagem ('SUOCORRE', 0);  {' em '}
            sintWriteint (vezes[i])
        end;
end;

{---------------------------------------------------------------}
{                        Entra um número                        }
{---------------------------------------------------------------}

procedure entraDados (c: char);
var v, xt: integer;
    conflitos: integer;
begin
    if fixo [xcur, ycur] then
        begin
            limpaBufTec;
            mensagem ('SUNAOPOS', 0);  {'Não posso alterar pistas'}
            falaCelula(xcur, ycur);
            while not keypressed do
                waitMessage;
            exit;
        end;

    v := ord (c) - ord('0');
    if c = '0' then
        conflitos := 0
    else
        conflitos := checaDuplicatas (xcur, ycur, v);

    if conflitos <> 0 then
        begin
            sintBip; sintBip; sintBip;

            xt := wherex;
            mensagem ('SUCONFLI', 0);    {'Conflitos'}
            gotoxy (xt, wherey+1);

            if (conflitos and 1) <> 0 then
                 mensagem ('SUNALIN', 0);    {'linha '}
            if (conflitos and 2) <> 0  then
                 mensagem ('SUNACOL', 0);    {'coluna '}
            if (conflitos and 4) <> 0  then
                 mensagem ('SUNAGREL', 0);   {'grelha '}

            while not keypressed do
                waitMessage;
        end
    else
        begin
            sudoku [xcur, ycur] := v;
            falaCelula(xcur, ycur);
        end;
end;

{---------------------------------------------------------------}
{                     abandona o jogo
{---------------------------------------------------------------}

function abandonaJogo: boolean;
var c, c2: char;
    abandona: boolean;
begin
    mensagem ('SUABAND', 0);  {'Quer mesmo abandonar o jogo? '}
    sintLeTecla (c, c2);

    abandona := upcase(c) = 'S';
    if not abandona then
         begin
             gotoxy (50, 7);
             mensagem ('SUDESIST', 0);   {'Desistiu'}
         end;
    abandonaJogo := abandona;
end;

{---------------------------------------------------------------}
{            vê se todas as células estão preenchidas           }
{---------------------------------------------------------------}

function checaTudoPreenchido: boolean;
var x, y: integer;
begin
    checaTudoPreenchido := false;
    for y := 0 to 8 do
        for x := 0 to 8 do
            if sudoku[x, y] = 0 then
                exit;

    checaTudoPreenchido := true;
end;

{---------------------------------------------------------------}
{                     faz festa pois ganhou                     }
{---------------------------------------------------------------}

procedure fazFesta;
begin
    limpaBufTec;
    tempo;
    gotoxy (50, wherey+2);
    mensagem ('SUPARABE', 0);    {'Parabéns, desafio completado!'}
    while not keypressed do
        begin
            gotoxy (50, 10);
            mensagem ('SUFOGOS', 0);     {'*** Fogos de artifício! ***'}
        end;
    limpaBufTec;
end;

{---------------------------------------------------------------}
{             procura um número a partir do cursor              }
{---------------------------------------------------------------}

procedure procura (pergunta: boolean);
var x, xini, y: integer;
    c, c2: char;
begin
    xini := xcur + 1;
    if pergunta then
        begin
            mensagem ('SUNUMBUS', 0);   {'Número a buscar: '}
            sintLeTecla (c, c2);
            gotoxy (50, 7);
            if c = '.' then c := '0';
            if not (c in ['0'..'9']) then
                begin
                    mensagem ('SUDESIST', 0);  {'Desistiu...'}
                    exit;
                end;
            procurado := ord (c) - ord ('0');
        end;

    for y := ycur to 8 do
        begin
            for x := xini to 8 do
                begin
                    if procurado = sudoku [x, y] then
                        begin
                            xcur := x;
                            ycur := y;
                            mostraQuadrinho (x, y);
                            informaCursor;
                            exit;
                        end;

                end;
            xini := 0;
        end;

    mensagem ('SUFIMTAB', 0);    {'Fim do tabuleiro'}
end;

{---------------------------------------------------------------}
{             executa as funções interativamente                }
{---------------------------------------------------------------}

function execFuncoes: char;
var ind: integer;
const tabfuncoes: string = 'LCGFAITEZN$';

    procedure menuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem(msg));
    end;

begin
    popupMenuCria (50, 5, 30, 20, BLUE);
    MenuAdiciona ('SUFUN_L');    {'L - ler linha'}
    MenuAdiciona ('SUFUN_C');    {'C - ler coluna'}
    MenuAdiciona ('SUFUN_G');    {'G - ler grelha'}
    MenuAdiciona ('SUFUN_F');    {'F - o que falta aqui'}
    MenuAdiciona ('SUFUN_A');    {'A - auto escolha'}
    MenuAdiciona ('SUFUN_I');    {'I - informa cursor'}
    MenuAdiciona ('SUFUN_T');    {'T - informa tempo'}
    MenuAdiciona ('SUFUN_E');    {'E - estatística'}
    MenuAdiciona ('SUFUN_Z');    {'Z - zera o Sudoku'}
    MenuAdiciona ('SUFUN_DL');   {'$ - calcula a solucao'}

    ind := popupMenuSeleciona;
    if ind < 1 then
        execFuncoes := ^I
    else
        execFuncoes := tabFuncoes[ind];
end;

{---------------------------------------------------------------}
{                        corpo do jogo                          }
{---------------------------------------------------------------}

procedure joga;
var c, c2: char;
    fala: boolean;
label interpreta, fim;

        procedure checaPosCursor;
        begin
            if xcur < 0 then
                begin  xcur := 0;  sintBip; end;
            if xcur > 8 then
                begin  xcur := 8;  sintBip; end;
            if ycur < 0 then
                begin  ycur := 0;  sintBip; end;
            if ycur > 8 then
                begin  ycur := 8;  sintBip; end;
        end;

begin
    xcur := 0;
    ycur := 0;
    fimDoJogo := false;

    inicTelaJogo;
    mostraSudoku;

    horainicial := time;
    c := ESC;
    if checaTudoPreenchido then goto fim;

    gotoxy (50, 5);
    mensagem ('SUJOGINI',  0);    {'Jogo iniciado'}
    falaCelula (xcur, ycur);

    repeat
        mostraSudoku;
        fala := false;

        c := readkey;
        if c = #0 then
            begin
                fala := true;
                c2 := readkey;
                case c2 of
                    F1: mostraManual;
                    F2: salvaJogo (nomeArqTrab);
                    F3: carregaJogo (nomeArqTrab);
                    F4: ;
                    F5: procura (true);
                 CTLF5: procura (false);
                    F6: ;
                    F7: ;
                    F8: mostraHora;
                 CTLF8: mostraData;
                    F9: begin
                            c := execFuncoes;
                            goto interpreta;
                        end;

                    CIMA: ycur := ycur - 1;
                    BAIX: ycur := ycur + 1;
                    ESQ:  xcur := xcur - 1;
                    DIR:  xcur := xcur + 1;
                    PGUP: ycur := 0;
                    PGDN: ycur := 8;
                    HOME: xcur := 0;
                    TEND: xcur := 8;
                end;
            end
        else
            begin
interpreta:
                limpaInteracao;
                case upcase(c) of
                    ^L: leLinha;
                    ^C: leColuna;
                    ^G: leGrade;

                    'L': faltaNaLinha;
                    'C': faltaNaColuna;
                    'G': faltaNaGrelha;
                    'F': faltaAqui;
                    'A': autoEscolha;
                    'I': informaCursor;
                    'T': tempo;
                    'E': estatistica;
                    'Z': zeraSudoku;
                    '$':  if calculaSolucao then
                              begin
                                  mostraSudoku;
                                  fimDoJogo := true;
                                  c := ESC;
                              end;
               '.', ' ': entraDados ('0');
               '0'..'9': entraDados (c);
                    ESC: if abandonaJogo then
                             fimDoJogo := true;
                  ENTER: begin
                             xcur := 0;
                             ycur := ycur + 1;
                         end;
                    ^I : ;
                else
                    begin
                        mensagem ('SUAPF1', 0);  {'Aperte F1 para ler manual'}
                        gotoxy (50, 8);
                        mensagem ('SUAPF9', 0);  {'F9 para opções'}
                    end;
                end;

            end;

        checaPosCursor;
        if fala then
            falaCelula (xcur, ycur);

        if not fimDoJogo then
            if checaTudoPreenchido then
                 begin
                      limpaBufTec;
                      if not fimDoJogo then
                          begin
                              limpaInteracao;
                              fazFesta;
                          end;
        fim:
                      limpaBufTec;
                      gotoxy (50, 15);
                      mensagem ('SUARQFIN', 1);    {'Arquivo com a solução final'}
                      gotoxy (50, 16);
                      sintWriteln (nomeArqTrab);
                      fimDoJogo := true;
                 end;

    until fimDoJogo;

    gotoxy (50, 23);
    if c <> ESC then
        salvaJogo (nomeArqTrab);
end;

end.

