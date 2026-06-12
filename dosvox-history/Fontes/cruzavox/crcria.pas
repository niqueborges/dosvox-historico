{--------------------------------------------------------}
{                                                        }
{    Programa de palavras cruzadas                       }
{                                                        }
{    Módulo de criação de jogos                          }
{                                                        }
{    Autores: José Antonio Borges                        }
{             Jorge Carlos dos Santos                    }
{                                                        }
{    Em agosto/2010                                      }
{                                                        }
{--------------------------------------------------------}

unit crcria;

interface

uses dvcrt, dvwin, windows, sysutils,
     dvForm, dvarq, dvHora,
     crmsg, crvars, crdesen, crArq, crLegend;

procedure criaJogo;
procedure alteraJogo;

implementation

procedure configura (emLegenda: boolean);
begin
    if emLegenda then
        begin
            areaLegendas;
            clrscr;
        end;

    mensagem ('CRENTINF', 2);  {'Entre as informações deste jogo, ao final tecle ESC'}
    formCria;
    tamRotulosForm := 7;
    formCampo('CRTITULO', pegaTextoMensagem('CRTITULO'), titulo, 25);       {'Título'}
    formCampo('CRTEMA',   pegaTextoMensagem('CRTEMA'),   tema, 25);         {'Tema'}
    formCampo('CRAUTOR',  pegaTextoMensagem('CRAUTOR'),  autor, 25);        {'Autor'}
    formCampo('CRDATA',   pegaTextoMensagem('CRDATA'),   dataCriacao, 25);  {'Data'}
    formEdita(true);

    alterou := true;
end;

procedure insereLinCol (var x, y: integer);
var tipoIns: char;
    ondeIns: char;
    xx, yy: integer;
label fim;
begin
    areaLegendas;
    clrscr;

    tipoIns := pergunta ('CRINSLC', 1, BLACK); {'Insere linha ou coluna? '}
    tipoIns := upcase (tipoIns);
    if not (tipoIns in ['L', 'C']) then
        begin
            mensagem ('CRDESIST', 1);   {'Desistiu...'}
            goto fim;
        end;

    if ((tipoIns = 'C') and (nx = MAXDIM)) or
       ((tipoIns = 'L') and (ny = MAXDIM)) then
        begin
            mensagem ('CRCAPEXC', 1);  {'Capacidade máxima foi excedida.'}
            goto fim;
        end;

    ondeIns := pergunta ('CRINSANT', 1, BLACK); {'Antes ou depois desta? '}
    ondeIns := upcase (ondeIns);
    if not (ondeIns in ['A', 'D']) then
        begin
            mensagem ('CRDESIST', 1);   {'Desistiu...'}
            goto fim;
        end;

    if tipoIns = 'C' then
        begin
            if ondeIns = 'D' then x := x + 1;
            for yy := 1 to ny do
                begin
                    insert ('.', modelo[yy], x);
                    for xx := nx downto x do
                         begin
                             legendasHoriz [yy, xx+1] := legendasHoriz [yy, xx];
                             legendasVert [yy, xx+1] := legendasVert [yy, xx];
                         end;
                    legendasHoriz [yy, x] := '';
                    legendasVert [yy, x] := '';
                end;
            nx := nx + 1;
        end
    else
    { if tipoIns = 'L' then }
        begin
            if ondeIns = 'D' then y := y + 1;
            for yy := ny downto y do
                begin
                    modelo [yy+1] := modelo [yy];
                    for xx := 1 to nx-1 do
                        begin
                            legendasHoriz [yy+1, xx] := legendasHoriz [yy, xx];
                            legendasVert [yy+1, xx] := legendasVert [yy, xx];
                        end;
                end;
            modelo [y] := copy ('...............', 1, nx);
            for xx := 1 to nx do
                begin
                    legendasHoriz [y, xx] := '';
                    legendasVert [y, xx] := '';
                end;
            ny := ny + 1;
        end;

fim:
    alterou := true;
    limpaTela;
    desenhaCruzadas(nx, ny, modelo);
end;

procedure removeLinCol (var x, y: integer);
var tipoRem: char;
    xx, yy: integer;
label fim;
begin
    areaLegendas;
    clrscr;

    tipoRem := pergunta ('CRREMLC', 1, BLACK); {'Remove linha ou coluna? '}
    tipoRem := upcase (tipoRem);
    if not (tipoRem in ['L', 'C']) then
        begin
            mensagem ('CRDESIST', 1);   {'Desistiu...'}
            goto fim;
        end;

    if ((tipoRem = 'C') and (nx = 3)) or
       ((tipoRem = 'L') and (ny = 3)) then
        begin
            mensagem ('CRCAPMIN', 1);  {'Capacidade mínima foi excedida.'}
            goto fim;
        end;

    if tipoRem = 'C' then
        begin
            for yy := 1 to ny do
                begin
                    delete (modelo[yy], x, 1);
                    for xx := x to nx-1 do
                        begin
                            legendasVert [yy, xx] := legendasVert [yy, xx+1];
                            legendasHoriz [yy, xx] := legendasHoriz [yy, xx+1];
                        end;
                    legendasVert [yy, nx] := '';
                    legendasHoriz [yy, nx] := '';
                end;
            nx := nx - 1;
        end
    else
    { if tipoRem = 'L' then }
        begin
            for yy := y to ny-1 do
                begin
                    modelo [yy] := modelo [yy+1];
                    for xx := 1 to nx-1 do
                        begin
                            legendasVert [yy, xx] := legendasVert [yy+1, xx];
                            legendasHoriz [yy, xx] := legendasHoriz [yy+1, xx];
                        end;
                    modelo [ny] := copy ('...............', 1, nx);
                    for xx := 1 to nx-1 do
                        begin
                            legendasVert [ny, xx] := '';
                            legendasHoriz [ny, xx] := '';
                        end;
                end;
            ny := ny - 1;

        end;

fim:
    alterou := true;
    limpaTela;
    desenhaCruzadas(nx, ny, modelo);
end;

procedure falaTrecho (t: string);
var i: integer;
    s: string;
begin
    s := '';
    for i := 1 to length (t) do
        begin
            if t[i] = '*' then
                begin
                    if s <> '' then
                        if length (s) = 1 then sintSoletra (s)
                                          else sintetiza (s);
                    s := '';
                    sintBip;
                end
            else
            if t[i] = '.' then
                begin
                    if s <> '' then
                        if length (s) = 1 then sintSoletra (s)
                                          else sintetiza (s);
                    s := '';
                    sintClek;
                end
            else
                s := s + t[i];
        end;

    if s <> '' then
         if length (s) = 1 then sintSoletra (s)
                           else sintetiza (s);
end;

procedure interacao (var x, y: integer);

var n: integer;
begin
    areaLegendas;
    clrscr;

    popupMenuCria (wherex, wherey, 30, 22, RED);

    MenuAdiciona ('CROSALVA');    // 'S - salvar jogo');
    MenuAdiciona ('CROSALVC');    // 'O - salvar com outro nome');
    MenuAdiciona ('CROVERIF');    // 'V - verifica o jogo');
    MenuAdiciona ('CROCONF');     // 'C - configura o jogo');
    MenuAdiciona ('CROINSER');    // 'I - insere linha ou coluna');
    MenuAdiciona ('CROREMOV');    // 'R - remove linha ou coluna');
    MenuAdiciona ('CRCRILG');     // 'L - cria legenda');

    n := popupMenuSeleciona;

    case n of
        1: salvaJogoModelo (nomeArq);
        2: begin
               nomeArq := '';
               salvaJogoModelo (nomeArq);
           end;
        3: consisteLegendas;
        4: configura (true);
        5: insereLinCol (x, y);
        6: removeLinCol (x, y);
        7: criaLegenda (x, y);
    else
        mensagem ('CRDESIST', 1);  // Desistiu
    end;

    todaTela;
end;

procedure ajuda;
begin
    areaLegendas;
    clrscr;
    textColor (WHITE);

    mensagem ('CRCOMAND', 1);    // 'Comandos:'
    writeln;
    mensagem ('CRCRISEP', 1);    // 'Asterisco cria separador.'
    mensagem ('CRCRILEG', 1);    // 'ENTER - cria legenda'
    mensagem ('CRCTLSET', 1);    // 'Control setas - le campo ou linha'
    mensagem ('CRF2',     1);    // 'F2    - salva'
    mensagem ('CRCTLF2',  1);    // 'CTLF2 - salva com outro nome'
    mensagem ('CRF3',     1);    // 'F3    - verifica se há erros'
    mensagem ('CRF4',     1);    // 'F4    - configura'
    mensagem ('CRF5',     1);    // 'F5    - informa posição'
    mensagem ('CRF6',     1);    // 'F6    - insere linha ou coluna'
    mensagem ('CRF7',     1);    // 'F7    - remove linha ou coluna'
    mensagem ('CRF8',     1);    // 'F8    - fala data e hora'
    mensagem ('CRF9',     1);    // 'F9    - menu interativo'
    writeln;
    mensagem ('CRAPENTC', 1);    // 'Aperte enter para continuar'
    readln;
    gotoxy (wherex, wherey-2);
    clreol;
    todaTela;
end;

procedure editaJogo (var modelo: TModelo; var nx, ny: integer);
var
    x, y: integer;
    c, c2: char;
    ix, iy: integer;
    s, aux: string;
    soletragemInib: boolean;

            procedure falaCelula;
            begin
                 if modelo [y, x] = '.' then
                     sintClek
                 else
                 if modelo [y, x] = '*' then
                     sintBip
                 else
                     sintCarac (modelo [y, x]);
            end;


            procedure informaLinhaEColuna;
            begin
                sintetiza ('Coluna');
                sintSoletra (chr(x+ord('A') - 1));
                sintetiza (' Linha ' + intToStr(y));
                while sintFalando do waitMessage;
                delay (500);
            end;

begin
    limpaTela;
    desenhaCruzadas(nx, ny, modelo);
    x := 1;
    y := 1;

    while keypressed do readkey;
    areaLegendas;
    clrscr;

    mensagem ('CRSETCR1', 1);  {'Digite usando as setas após cada letra'}
    mensagem ('CRSETCR2', 1);  {'Use asterisco para separadores'}
    mensagem ('CRSETCR3', 1);  {'F1 ajuda'}

    alterou := false;
    falaCelula;
    repeat
        todaTela;
        gotoxy (2+x*2,3+y);
        soletragemInib := false;

        c := readkey;
        areaLegendas;
        if c = #$0 then  // teclas de controle
             begin
                 c2 := readkey;
                 case c2 of
                     F1:   ajuda;
                     CIMA: y := y - 1;
                     BAIX: y := y + 1;
                     ESQ:  x := x - 1;
                     DIR:  x := x + 1;
                     HOME: x := 1;
                     TEND: x := nx;
                     PGUP: y := 1;
                     PGDN: y := ny;
                     DEL:  begin
                                modelo [y, x] := '.';
                                alterou := true;
                           end;

                     CTLESQ:  begin
                                  s := '';
                                  for ix := 1 to nx do s := s + modelo [y, ix];
                                  falaTrecho (s);
                                  soletragemInib := true;
                              end;
                     CTLDIR:  begin
                                  s := '';
                                  for ix := x to nx do
                                      begin
                                          if (modelo [y, ix] = '*') or (modelo [y, ix] = '.')  then break;
                                          s := s + modelo [y, ix];
                                      end;
                                  falaTrecho (s);
                                  soletragemInib := true;
                              end;
                     CTLUP:   begin
                                  s := '';
                                  for iy := 1 to ny do s := s + modelo [iy, x];
                                  falaTrecho (s);
                                  soletragemInib := true;
                              end;
                     CTLDOWN: begin
                                  s := '';
                                  for iy := y to ny do
                                      begin
                                          if (modelo [iy, x] = '*') or (modelo [iy, x] = '.')  then break;
                                          s := s + modelo [iy, x];
                                      end;
                                  falaTrecho (s);
                                  soletragemInib := true;
                              end;

                     F2: salvaJogoModelo (nomeArq);
                  CTLF2: begin
                             nomeArq := '';
                             salvaJogoModelo (nomeArq);
                         end;
                     F3: consisteLegendas;
                     F4: configura (true);
                     F5: informaLinhaEColuna;
                     F6: insereLinCol (x, y);
                     F7: removeLinCol (x, y);
                     F8: begin
                             falaHora;
                             faladia;
                         end;
                     F9: interacao (x, y);
                 end;
             end
         else
             begin
                 if c = ^L then
                     informaLinhaEColuna
                 else
                 if c = ESC then
                     begin
  		                 if not alterou then break;
                         clrscr;
                         limpaBufTec;
                         mensagem ('CRSALVEJ', 1);   {'Você não salvou seu trabalho'}
                         mensagem ('CRQRSAIR', 0);   {'Quer mesmo sair sem gravar? '}
                         c := upcase (sintReadkey);
                         writeln (c);
                         if c <> 'N' then c := ESC;
                     end
                 else
                     begin
                         alterou := true;

                         case c of
                             ENTER: criaLegenda (x, y);

                             '*': modelo [y, x] := c;

                             BS, ' ', '.': modelo [y, x] := '.';

                             'a'..'z', 'A'..'Z', 'Ç', 'Ñ', 'ç', 'ñ',
                             'á', 'é', 'í', 'ó', 'ú', 'Á', 'É', 'Í', 'Ó', 'Ú',
                             'â', 'ê', 'ô', 'Â', 'Ê', 'Ô',
                             'ã', 'õ', 'Ã', 'Õ',
                             'ü', 'Ü':
                                  begin
                                      aux := ansiUppercase (c);
                                      modelo [y, x] := aux[1];
                                  end;
                         end;
                     end;
             end;

         if (x < 1) or (y < 1) or (x > nx) or (y > ny) then
             begin
                 sintbip; sintbip;
             end;

         if x < 1  then x := 1;
         if y < 1  then y := 1;
         if x > nx then x := nx;
         if y > ny  then y := ny;

         if c <> ESC then
             begin
                 todaTela;
                 if alterou then
                     desenhaCruzadas(nx, ny, modelo);
                 if not soletragemInib then
                     falaCelula;
                 areaLegendas;
             end;

    until c = ESC;
    todaTela;
    limpaTela;
end;

procedure criaJogo;
var
    autor: string;
    x, y: integer;
    gerou: boolean;
    dirModelo, nomeModelo: string;
    ano, mes, dia, sem: word;

begin
    repeat
        nx := 0;
        ny := 0;

        dirModelo := sintAmbiente ('CRUZAVOX', 'DIRMODELOS');
        if dirModelo = '' then dirModelo := 'c:\winvox\cruzadas\modelos';

        {$I-}  chdir (dirModelo); {$I+}
        if ioresult <> 0 then
            begin
                mensagem ('CRDIRMNO', 2);  {'Diretório de modelos não foi achado'}
                sintWriteln (dirModelo);
                nomeModelo := '';
            end
        else
            begin
                garanteEspacoTela (10);
                mensagem ('CRMODBAS', 0);    {'Escolha o modelo básico com as setas: '}
                nomeModelo := obtemNomeArq (24-wherey);
                writeln (nomeModelo);
            end;

        if nomeModelo = '' then
            begin
                mensagem ('CRMODBRC', 1);   {'Modelo em branco de 15 por 15 foi assumido'}
                for y := 1 to MAXDIM do
                    begin
                        modelo [y] := '...............';
                        for x := 1 to MAXDIM do
                            begin
                               legendasHoriz [x, y] := '';
                               legendasVert  [x, y] := '';
                               nx := MAXDIM;
                               ny := MAXDIM;
                               gerou := true;
                            end;
                    end
            end
        else
            gerou := carregaJogoModelo (nomeModelo);
    until gerou;

    titulo := 'Palavras cruzadas';
    tema := 'Diversão';
    autor:= sintAmbiente ('CRUZAVOX', 'AUTOR');
    getdate (ano, mes, dia, sem);
    dataCriacao := intToStr(dia) + '/' + intToStr(mes) + '/' + intToStr(ano);

    writeln;
    configura (false);

    nomeArq := '';
    salvaJogoModelo (nomeArq);

    editaJogo (modelo, nx, ny);
end;

procedure alteraJogo;
var numJogos: integer;
begin
    if not escolhePastaJogo (dirAtual) then
        exit;

    chdir (dirAtual);
    garanteEspacoTela (10);
    writeln;

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

    mensagem ('CRESCARQ', 0);    {'Escolha o arquivo com as setas: '}

    nomeArq := obtemNomeArq (24-wherey);
    writeln (nomeArq);
    if nomeArq = '' then
        begin
            mensagem ('CRERRARQ', 2);  {'Erro no arquivo de jogo'}
            exit;
        end;

    if carregaJogoModelo (nomeArq) then
        editaJogo (modelo, nx, ny)
    else
        begin
            mensagem ('CRPROBLE', 1);  {'Problemas na leitura do arquivo.'}
            exit;
        end;
end;

end.

