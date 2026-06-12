{-------------------------------------------------------------}
{                                                             }
{     Um jogo da memoria para a Liane                         }
{                                                             }
{     Autor: Jose Antonio Borges                              }
{                                                             }
{     Em 28/09/91                                             }
{                                                             }
{-------------------------------------------------------------}

program memo;

{$R memojogo.res}

uses
  dvcrt,
  dvwin,
  windows,
  sysutils,
  mjmsg;

const
    MAXCOL = 10;
    MAXLIN = 4;
    tabCols: array [1..3] of integer = (4, 7, 10);

const
    costas = -1;
    MAXFIGS = 20;
    tabFigurasOrig: array [0..MAXFIGS-1] of pchar = (
        'TOURO',
        'BOMBA',
        'CADEADO',
        'CALCULADORA',
        'COMPUTADOR',
        'FANTASMA',
        'HOMEM',
        'JORNAL',
        'LADRILHO',
        'LINUX',
        'LIVRO',
        'MALA',
        'PALETA',
        'PASTA',
        'PEIXE',
        'PORTA',
        'SETA',
        'TECLADO',
        'TERMINAL',
        'TELA'
    );

    fig_costas: pchar = '_COSTAS';
    fig_cursor: pchar = '_CURSOR';
    fig_marca: pchar = '_MARCA';
    fig_desmarca: pchar = '_DESMARCA';
    fig_logotipo: pchar = '_INICIAL';

var
    xcur, ycur: integer;
    ultx, ulty: integer;
    faltam, tentativas, vez, tempoGasto: integer;
    horaInicial, horaFinal: double;

    saiu: array [0..9, 0..3] of boolean;
    imagem: array [0..9, 0..3] of integer;
    tabFiguras: array [0..19] of pchar;

    arqpontos: text;
    ngaleria: integer;
    pontos: array [0..10] of integer;
    tempo: array [0..10] of integer;
    nome: array [0..10] of string;
    dirScore: string;

    nlin, ncol, npecas: integer;
    nivelAtual: integer;
    falandoCoord: boolean;

    dcTrab, dcTela: hDC;
    bm: hbitmap;
    penaPreta, penaBranca: HGDIOBJ;


procedure score; forward;
procedure passeiaNasCartas; forward;

{-------------------------------------------------------------}
{            efeitos sonoros                                  }
{-------------------------------------------------------------}

const
    DESISTIU = 0;
    ACERTOU  = 1;
    ERROU    = 2;
    FIM      = 3;
    INICIO   = 4;
    PARABENS = 5;
    FECHADA  = 6;

procedure sonoros (qual: integer);
begin
   case qual of
        INICIO:   begin
                      if existeArqSom ('MJINICIO') then
                          sintSom ('MJINICIO');
                  end;

        DESISTIU: sintSom ('MJCANCEL');
        ACERTOU:  if existeArqSom ('MJACERTO') then
                       sintSom ('MJACERTO')
                  else
                       begin
                           sintBip;  sintBip; sintBip;
                       end;
        ERROU:    begin
                        if existeArqSom ('MJERRO') then
                            sintSom ('MJERRO')
                        else
                            begin
                                delay (500);
                                sintBip;
                            end;
                  end;
        FIM:
                sintSom ('MJFIM');

        PARABENS: if existeArqSom ('MJPARABE') then
                      sintSom ('MJPARABE')
                  else
                      sintetiza (pegaTextoMensagem ('MJPARAB'));
   end;

end;

{-------------------------------------------------------------}
{            limpa tela e coloca cabeçalho                    }
{-------------------------------------------------------------}

procedure limpaTela;
var tit: string;
begin
    clrscr;
    write ('                   ');
    textBackground (RED);
    tit := pegaTextoMensagem('MJLIANE');    {'Jogo da Liane - a Garota da Memória'}
    writeln (tit);
    textBackground (BLACK);
    writeln;
end;

{-------------------------------------------------------------}
{                      instruções                             }
{-------------------------------------------------------------}

procedure instrucoes;
var c: char;
begin
    mensagem ('MGINSTRU', 0);  {'Deseja Instruções? '}
    c := sintReadkey;
    if c = #$0 then
        begin
            readkey;
            c := 'N';
        end;
    writeln (c);
    writeln;

    if upcase(c) = 'S' then
        begin
            mensagem ('MJAJUDA', 2);
            {'O jogo apresenta um tabuleiro de cartas dispostas em 4 linhas.'}
            {'Cada carta ocorre duas vezes neste tabuleiro'}
            {'O objetivo do jogo é combinar as cartas, duas a duas.'}
            {'Busca-se fazer isso com o menor número possível de tentativas.'}
            {'Ao início do jogo, as cartas são previamente mostradas para o jogador.'}
            {'Apertando-se uma tecla, as cartas serão viradas e o jogo começa'}
            {'Para caminhar no tabuleiro usa-se as setas.  Enter seleciona uma peça'}
            {'Para saber a pontuação no momento, usa-se a barra de espaços.'}

            while keypressed do readkey;
            mensagem ('MJAPENT', 0);  {'Aperte enter para continuar'}
            repeat
                c := readkey;
                sintPara;
            until c = ENTER;
        end;

    limpaTela;
end;

{-------------------------------------------------------------}
{            inicializa contexto gráfico                      }
{-------------------------------------------------------------}

procedure inicVideo;
begin
    limpaTela;

    dcTela := getDC (crtWindow);
    dcTrab := createCompatibleDC (dcTela);
    penaPreta := createPen (0, 2, RGB (0, 0, 0));
    penaBranca := createPen (0, 2, RGB (255, 255, 255));
end;

{-------------------------------------------------------------}
{                     mostra uma figurinha                    }
{-------------------------------------------------------------}

procedure mostraFigura (posx, posy, indice: integer);
var
   xt, yt: integer;

begin
   if indice = costas then
       bm := LoadBitmap (hinstance, fig_costas)
   else
       begin
           indice := indice mod ((ncol*nlin) div 2);
           bm := LoadBitmap (hinstance, tabFiguras[indice]);
       end;

   selectObject (dcTrab, bm);

   xt := 10 + posx * 80;
   yt := 50 + posy * 100;

   bitBlt (dcTela, xt, yt, 64, 64, dcTrab, 0, 0, srcCopy);
end;

{-------------------------------------------------------------}
{                     mostra uma moldura                    }
{-------------------------------------------------------------}

procedure mostraMoldura (posx, posy: integer; marcado: boolean);
var
   bm: hbitmap;
   dcTrab, dcTela: hDC;
   xt, yt: integer;

begin
   dcTela := getDC (crtWindow);
   dcTrab := createCompatibleDC (dcTela);

   if marcado then
       bm := LoadBitmap (hinstance, fig_marca)
   else
       bm := LoadBitmap (hinstance, fig_desmarca);

   selectObject (dcTrab, bm);

   xt := 10 + posx * 80 - 2;
   yt := 50 + posy * 100 - 2;

   bitBlt (dcTela, xt, yt, 68, 68, dcTrab, 0, 0, srcCopy);
   deleteDC (dcTrab);
   deleteObject (bm);
   releaseDc (crtWindow, dcTela);
end;

{-------------------------------------------------------------}
{                     mostra o cursor                         }
{-------------------------------------------------------------}

procedure cursor (posx, posy: integer; exibe: boolean);
var
   bm: hbitmap;
   dcTrab, dcTela: hDC;
   xt, yt: integer;

begin
   dcTela := getDC (crtWindow);
   dcTrab := createCompatibleDC (dcTela);

   bm := LoadBitmap (hinstance, fig_cursor);

   selectObject (dcTrab, bm);

   xt := 10 + posx * 80+16;
   yt := 50 + posy * 100 + 66;

   if exibe then
       bitBlt (dcTela, xt, yt, 64, 20, dcTrab, 0, 0, srcCopy)
   else
       bitBlt (dcTela, xt, yt, 64, 20, dcTrab, 0, 0, BLACKNESS);
   deleteDC (dcTrab);
   deleteObject (bm);
   releaseDc (crtWindow, dcTela);
end;

{-------------------------------------------------------------}
{            mostra galeria da fama                           }
{-------------------------------------------------------------}

procedure mostraGaleria;
var i: integer;
    c: char;
begin
    mensagem ('MJQUERCO', 0);  {'Quer conhecer a galeria da fama? '}
    c := sintReadkey;
    writeln (c);
    if upcase (c) <> 'S' then exit;

    writeln;
    mensagem ('MJGALERI', 2); {'GALERIA DA FAMA - Jogadores que conseguiram em menos tentativas'}

    if ngaleria = 0 then
        begin
            writeln;
            mensagem ('MJNENHUM', 2); {'Nenhuma pessoa registrada...'}
        end
    else
        for i := 0 to ngaleria-1 do
            begin
                nome[i] := nome[i] + '                    ';
                writeln (pontos[i]:3, '   ', tempo[i]:6, 's   ', nome[i]);
                sintetiza (intToStr (pontos[i]) +
                           ', ' + intToStr (tempo[i]) + pegaTextoMensagem ('MJSEGUND') +
                           ', ' + nome[i]);
            end;

    writeln;
    mensagem ('MJAPENT', 0);   {'Aperte enter para continuar'}
    readln;
    limpaTela;
end;

{-------------------------------------------------------------}
{            traz galeria da fama                             }
{-------------------------------------------------------------}

procedure trazgaleria;
var espaco: char;
begin
    if nivelAtual < 3 then
        assign (arqpontos, dirScore + 'memojogo_'+intToStr(nivelAtual)+'.sco')
    else
        assign (arqpontos, dirScore + 'memojogo.sco');
    {$I-}  reset (arqpontos);  {$I+};
    ngaleria := 0;
    if ioresult = 0 then
        begin
            while not eof (arqpontos) do
                begin
                    {$I-}
                    readln (arqpontos, pontos[ngaleria], tempo[ngaleria],
                            espaco, nome[ngaleria]);
                    {$I+}
                    if (ioresult = 0) and (nome[ngaleria] <> '') and
                                          (nome[ngaleria] <> #$1A) then
                        ngaleria := ngaleria + 1;
                end;

            {$I-} close (arqpontos); {$I+}
            if ioresult <> 0 then;
        end;
end;

{-------------------------------------------------------------}
{            trata score atual                                }
{-------------------------------------------------------------}

procedure tratascore;

var entranagaleria: boolean;
    i: integer;

{-------------------------------------------------------------}

    procedure acertagaleria;
    var
        i, j: integer;
        temp: integer;
        ntemp: string;
    begin
        for i := 0 to ngaleria - 2 do
            for j := i to ngaleria-1 do
                if (pontos[i] > pontos[j]) or
                   ((pontos[i] = pontos[j]) and (tempo[i] > tempo[j]))  then
                    begin
                         temp := pontos[j]; pontos[j] := pontos[i]; pontos[i] := temp;
                         temp := tempo[j];  tempo[j] := tempo[i];   tempo[i] := temp;
                         ntemp := nome[j];  nome[j] := nome[i];     nome[i] := ntemp;
                    end;

        if ngaleria > 10 then
            ngaleria := 10;

        if nivelAtual < 3 then
            assign (arqpontos, dirScore + 'memojogo_'+intToStr(nivelAtual)+'.sco')
        else
            assign (arqpontos, dirScore + 'memojogo.sco');
        {$I-}  rewrite (arqpontos);  {$I+};
        if ioresult = 0 then
            for i := 0 to ngaleria-1 do
                writeln (arqpontos, pontos[i], ' ', tempo[i], ' ', nome[i]);

        {$I-} close (arqpontos); {$I+}
    end;

{-------------------------------------------------------------}

    procedure insereGaleria;
    begin
        limpaTela;
        mensagem ('MJENTROU', 1);  {'VOCE ENTROU PARA GALERIA DA FAMA !'}

        mensagem ('MJTENT', 0);  {'Seu número de tentativas foi '}
        sintWriteint (tentativas);
        writeln;
        repeat
            mensagem ('MJQNOME', 0);  {'Qual o seu nome ? '}
            sintReadln (nome[ngaleria]);
            nome[ngaleria] := trim (nome[ngaleria]);
        until (nome [ngaleria] <> '');
        pontos [ngaleria] := tentativas;
        tempo [ngaleria] := tempoGasto;
        ngaleria := ngaleria + 1;

        limpaTela;
        acertagaleria;
        trazgaleria;
        mostragaleria;
    end;

{-------------------------------------------------------------}

begin
    trazgaleria;

    entranagaleria := false;
    if ngaleria = 10 then
        begin
            for i := 0 to 9 do
                if pontos [i] > tentativas then
                     entranagaleria := true;
        end
    else
        entranagaleria := true;

    if entranagaleria then
        begin
            sonoros (PARABENS);
            insereGaleria;
        end;
end;

{-------------------------------------------------------------}
{            abre uma carta                                   }
{-------------------------------------------------------------}

procedure abreCarta (x, y: integer);
begin
    mostraFigura (x, y, imagem[x,y]);
end;

{-------------------------------------------------------------}
{            poe uma tampa                                    }
{-------------------------------------------------------------}

procedure tampaCarta (x, y: integer);
begin
    mostraFigura (x, y, COSTAS);
end;

{-------------------------------------------------------------}
{            marca uma carta como selecionada                 }
{-------------------------------------------------------------}

procedure marca (x, y: integer);
begin
    mostraMoldura (x, y, true);
    abreCarta (x, y);
end;

{-------------------------------------------------------------}
{            desmarca carta selecionada                       }
{-------------------------------------------------------------}

procedure desmarca (x, y: integer);
begin
    mostraMoldura (x, y, false);
    abreCarta (x, y);
end;

{-------------------------------------------------------------}
{            embaralha o jogo                                 }
{-------------------------------------------------------------}

procedure embaralha;
var
    i, x, y: integer;
    temp: pchar;

begin
    randomize;

    for x := 0 to ncol-1 do
        for y := 0 to nlin-1 do
            saiu [x,y] := false;

    for i := 0 to MAXFIGS-1 do
        tabFiguras [i] := tabFigurasOrig [i];
    for i := 1 to 30 do
        begin
            x := random (MAXFIGS);
            y := random (MAXFIGS);
            temp := tabFiguras [x];
            tabFiguras [x] := tabFiguras [y];
            tabFiguras [y] := temp;
        end;

    for i := 0 to (ncol*nlin)-1 do
        begin
            repeat
                x := round (random * (ncol-1));
                y := round (random * (nlin-1));
            until not saiu [x,y];

            saiu [x,y] := true;
            imagem [x,y] := i;
        end;
end;

{-------------------------------------------------------------}
{            mostra o logotipo                                }
{-------------------------------------------------------------}

procedure mostraLogotipo;
var
    WindRect : TRect;
begin
    GetClientRect(crtWindow, WindRect);

   bm := LoadBitmap (hinstance, fig_logotipo);
   selectObject (dcTrab, bm);
   bitBlt (dcTela, windRect.Right-200, windRect.Bottom-140, 231, 200, dcTrab, 0, 0, srcCopy);
end;

{-------------------------------------------------------------}
{            pede o nível                                     }
{-------------------------------------------------------------}

procedure pedeNivel;
var c: char;
begin
    mensagem ('MJINFNIV', 0);   {'Nível desejado: Noviço, Experiente ou Sênior? '}
    c := upcase(sintReadkey);
    if c = #$0 then readkey;

    nivelAtual := 1;
    if c = 'E' then nivelAtual := 2
    else
    if c = 'S' then nivelAtual := 3;
end;

{-------------------------------------------------------------}
{            inicializa o jogo                                }
{-------------------------------------------------------------}

procedure inicializa;
var
    x, y: integer;
    dir: string;

begin
    dir := sintAmbiente ('MEMOJOGO', 'DIRMEMOJOGO');
    if dir = '' then
        dir := 'c:\winvox\som\memojogo';
    sintInic (0, dir);

    dirScore := sintAmbiente ('MEMOJOGO', 'DIRSCORE');
    if dirScore = '' then
        dirScore := 'c:\winvox\';
    if dirScore[length(dirScore)] <> '\' then
        dirScore := dirScore + '\';

    inicVideo;
    mostraLogotipo;
    sonoros (INICIO);
    sintSom ('MJLIANE');

    while keypressed do readkey;
    instrucoes;

    pedeNivel;

    ncol := tabCols[nivelAtual];
    nlin := 4;
    npecas := (ncol*nlin) div 2;
    falandoCoord := false;

    limpaTela;
    trazgaleria;

    if ngaleria <> 0 then
         mostragaleria;

    limpaTela;
    embaralha;

    passeiaNasCartas;

    gotoxy (1, 24);
    while keypressed do readkey;

    for x := 0 to ncol-1 do
        for y := 0 to nlin-1 do
            begin
                tampacarta (x, y);
                saiu [x,y] := false;
                if y = 0 then sintClek;
            end;

    xcur := 0;
    ycur := 0;
    tentativas := 0;
    tempoGasto := 0;
    gotoxy (1, 25);
end;

{-------------------------------------------------------------}
{                            finaliza                         }
{-------------------------------------------------------------}

procedure finaliza;
begin
    deleteDC (dcTrab);
    deleteObject (bm);
    releaseDc (crtWindow, dcTela);

    gotoxy (1, 24); clreol;
    mensagem ('MJFIMJOG', 1);   {'Fim do Jogo'}
    while sintFalando do;
    readkey;

    sintFim;
    doneWinCrt;
end;

{-------------------------------------------------------------}
{            poe a setinha na tela                            }
{-------------------------------------------------------------}

procedure poesetinha;
begin
   cursor (xcur, ycur, true);
end;

{-------------------------------------------------------------}
{            tira a setinha na tela                           }
{-------------------------------------------------------------}

procedure tirasetinha;
begin
   cursor (xcur, ycur, false);
end;

{-------------------------------------------------------------}
{            redesenha toda parte gráfica                     }
{-------------------------------------------------------------}

procedure redesenhaTudo;
var x, y: integer;
begin
    for x := 0 to ncol-1 do
        for y := 0 to nlin-1 do
            begin
                if saiu [x, y] then
                    abrecarta (x, y)
                else
                    if (vez = 1) and (ultx = x) and (ulty = y) then
                        begin
                            abrecarta (x, y);
                            marca(x, y);
                        end
                    else
                        tampacarta (x, y);
            end;
end;

{-------------------------------------------------------------}
{`                     fala nome da carta                     }
{-------------------------------------------------------------}

procedure falaCarta (forcando: boolean);
begin
    gotoxy (1, 24);
    write ('                    ');
    if falandoCoord then
        sintetiza (intToStr (xcur));
    gotoxy (1, 24);
    if forcando or (saiu [xcur, ycur]) or
       ((vez = 1) and (ultx = xcur) and (ulty = ycur)) then
        sintWrite (tabFiguras [imagem[xcur, ycur] mod NPECAS])
    else
        sonoros(FECHADA);
    gotoxy (1, 24);
end;

{-------------------------------------------------------------}
{                    reposiciona o cursor                     }
{-------------------------------------------------------------}

procedure reposCursor (c: char);

begin
    c := readkey;
    case c of
        CIMA:
            begin
                ycur := ycur - 1;
                if ycur < 0 then
                    begin
                        sintBip;
                        ycur := 0;
                    end;
            end;
        BAIX:
            begin
                ycur := ycur + 1;
                if ycur > (nlin-1) then
                    begin
                        sintBip;
                        ycur := nlin-1;
                    end;
            end;
        DIR:
            begin
                xcur := xcur + 1;
                if xcur > (ncol-1) then
                    begin
                        sintBip;
                        xcur := ncol-1;
                    end;
            end;
        ESQ:
            begin
                xcur := xcur - 1;
                if xcur < 0 then
                    begin
                        sintBip;
                        xcur := 0;
                    end;
            end;

        HOME: xcur := 0;
        TEND: xcur := ncol-1;
        PGUP: begin
                  xcur := 0;
                  ycur := ycur + 1;
                  if ycur > (nlin-1) then
                      begin
                          sintBip;
                          ycur := nlin-1;
                      end;
                  if falandoCoord then
                      sintetiza (pegaTextoMensagem('MJLINHA') + intToStr (ycur));
              end;
        PGDN: begin
                  xcur := 0;
                  ycur := ycur + 1;
                  if ycur > (nlin-1) then
                      begin
                          sintBip;
                          ycur := nlin-1;
                      end;
                  if falandoCoord then
                      sintetiza (pegaTextoMensagem('MJLINHA') + intToStr (ycur));
              end;

        F4: begin
                falandoCoord := not falandoCoord;
                if falandoCoord then
                    mensagem ('MJFALCOR', -1)   {'Falando coordenadas'}
                else
                    mensagem ('MGSEMCOR', -1);  {'Coordenadas mudas'}
            end;

    end;

    gotoxy (70, 24);
    write (ycur:2, ',', xcur:2);
end;

{-------------------------------------------------------------}
{            move o cursor                                    }
{-------------------------------------------------------------}

procedure movecursor;
var
    c: char;

begin
    repeat
        poesetinha;
        c := readkey;
        tirasetinha;
        if c = #$0 then
            begin
                reposCursor (c);
                sintClek;
                falaCarta (false);
            end
        else
        if c = ' ' then
            begin
                redesenhaTudo;
                score;
                sintetiza (pegaTextoMensagem ('MJLINHA') + intToStr (ycur) + ' ' + intToStr (xcur) + '.');
                sintetiza (intToStr (tentativas) + ' ' + pegaTextoMensagem ('MJTENTAT'));
                sintetiza (intToStr (faltam) + ' ' + pegaTextoMensagem ('MJCARFAL'));
            end;
    until (c = ENTER) or (c = ESC);

    if c = ESC then
        faltam := -1;
end;

{-------------------------------------------------------------}
{                       passeia nas cartas                    }
{-------------------------------------------------------------}

procedure passeiaNasCartas;
var
    c: char;
    x, y: integer;
begin
    for x := 0 to ncol-1 do
        for y := 0 to nlin-1 do
            begin
                 abrecarta (x, y);
                 if y = 0 then sintClek;
            end;

    sonoros (ACERTOU);
    gotoxy (1, 23);
    mensagem ('MJUSESET', 0);  {'Use as setas para conhecer as cartas, ENTER inicia o jogo'}

    xcur := 0;
    ycur := 0;

    while sintFalando do waitMessage;
    while keypressed do readkey;

    falaCarta (true);
    repeat
        poesetinha;
        c := readkey;
        tirasetinha;
        if c = #$0 then
            begin
                reposCursor (c);
                falaCarta (true);
            end
        else
        if c = ' ' then
            begin
                redesenhaTudo;
                sintetiza (intToStr (ycur) + ' ' + intToStr (xcur) + '.')
            end;
    until (c = ENTER) or (c = ESC);

    gotoxy (1, 23);
    clreol;
end;

{-------------------------------------------------------------}
{               desenha sete segmentos                        }
{-------------------------------------------------------------}

procedure seteseg (x0, y0, ampl, n: integer);
{
               0                          011 1111     -> 0
              ---                         000 0110     -> 1
          5  !   ! 1                      101 1011     -> 2
              ---                         100 1111     -> 3
          4  ! 6 ! 2                      110 0110     -> 4
              ___                         110 1101     -> 5
                                          111 1101     -> 6
               3                          000 0111     -> 7
                                          111 1111     -> 8
                                          110 1111     -> 9
}
const
    tab7seg: array [0..9] of byte =
        ($3f, $06, $5b, $4f, $66, $6d, $7d, $07, $7f, $6f);

    tabxini: array [0..6] of byte = (0, 1, 1, 0, 0, 0, 0);
    tabxfim: array [0..6] of byte = (1, 1, 1, 1, 0, 0, 1);
    tabyini: array [0..6] of byte = (0, 0, 1, 2, 1, 0, 1);
    tabyfim: array [0..6] of byte = (0, 1, 2, 2, 2, 1, 1);

var
    i, bit: integer;
    modelo: byte;

    procedure apaga7seg;
    var
        i: integer;
    begin
        selectObject (dcTela, penaPreta);
        for i := 0 to 6 do
            begin
                movetoex (dcTela, x0 + tabxini [i] * ampl, y0 + tabyini [i] * ampl, NIL);
                lineto (dcTela, x0 + tabxfim [i] * ampl, y0 + tabyfim [i] * ampl);
            end;
    end;

    procedure pinta (i, bit: integer);
    begin
        selectObject (dcTela, penaBranca);
        movetoEx (dcTela, x0 + tabxini [i] * ampl, y0 + tabyini [i] * ampl, NIL);
        lineto (dcTela, x0 + tabxfim [i] * ampl, y0 + tabyfim [i] * ampl);
    end;

begin
    modelo := tab7seg [n];
    apaga7seg;
    for i := 0 to 6 do
        begin
            bit := modelo and 1;
            modelo := modelo shr 1;
            if bit = 1 then
                pinta (i, bit);
        end;
end;

{-------------------------------------------------------------}
{            mostra o score atual                             }
{-------------------------------------------------------------}

procedure score;
begin
    gotoxy (16, 23);
    writeln (pegaTextoMensagem ('MJTENFAL'));  {'Tentativas               Faltam'}
    seteseg (270,    440, 20, tentativas div 100);
    seteseg (270+30, 440, 20, (tentativas div 10) mod 10);
    seteseg (270+60, 440, 20, tentativas mod 10);

    seteseg (470,    440, 20, (faltam div 10) mod 10);
    seteseg (470+30, 440, 20, faltam mod 10);
end;

{-------------------------------------------------------------}
{            programa principal                               }
{-------------------------------------------------------------}

begin
    inicializa;

    sonoros (INICIO);
    ultx := 0;
    ulty := 0;
    faltam := ncol * nlin;
    vez := 0;

    gotoxy (70, 24);
    write (ycur:2, ',', xcur:2);

    horaInicial := time;
    repeat
        score;
        movecursor;

        if not saiu [xcur, ycur] then
            begin
                if vez = 0 then
                    begin
                        vez := 1;
                        abrecarta (xcur, ycur);
                        marca (xcur, ycur);

                        ultx := xcur;
                        ulty := ycur;
                    end
                else
                    begin
                        vez := 0;
                        tentativas := tentativas + 1;

                        if (ultx = xcur) and (ulty = ycur) then
                            begin
                                sonoros (ERROU);
                                desmarca (xcur, ycur);
                                tampacarta (xcur, ycur);
                            end
                        else
                            begin
                                abrecarta (xcur, ycur);
                                falaCarta (true);

                                desmarca (ultx, ulty);
                                if imagem [xcur,ycur] mod NPECAS = imagem[ultx, ulty] mod NPECAS then
                                    begin
                                         saiu [xcur,ycur] := true;
                                         saiu [ultx,ulty] := true;
                                         faltam := faltam - 2;
                                         sonoros (ACERTOU);
                                     end
                                else
                                    begin
                                        sonoros (ERROU);
                                        tampacarta (xcur, ycur);
                                        tampacarta (ultx, ulty);
                                    end;
                            end;
                    end;
            end
        else
            sintBip;

        if faltam <> -1 then falaCarta (false);

    until faltam < 1;

    horaFinal := time;
    tempoGasto := trunc (frac (horaFinal - horaInicial) * (24*60*60));

    if faltam = -1 then
        begin
            gotoxy (1, 24);   clreol;
            mensagem  ('MJDESIST', 1);  {'Desistiu, que pena...'}
            sonoros (DESISTIU);
        end
    else
        begin
            sonoros (FIM);

            gotoxy (1, 24);  clreol;
            mensagem ('MJTEMPO', 0);    {'Tempo: '}
            sintWriteint (tempoGasto);
            while sintFalando do;

            score;
            tratascore;
        end;

    finaliza;
end.

