{---------------------------------------------------------}
{                                                         }
{    Programa Palavrox                                    }
{                                                         }
{    Execução de uma partida                              }
{                                                         }
{    Autor: João Marcelo de Andrade & João Pedro Souza    }
{                                                         }
{    Em Outubro/2018                                      }
{                                                         }
{    Revisão: Júlio Silveira e Antonio Borges             }
{                                                         }
{    Em Dezembro/2018                                     }
{                                                         }
{---------------------------------------------------------}

unit pvjoga;

interface
uses
  dvcrt,
  dvwin,
  dvForm,
  dvDic,
  dvMacro,
  sysutils,
  classes,
  windows,
  pvvars,
  pvmsg,
  pvtempo,
  pvbanner,
  pvdiag,
  pvscores;

procedure jogarPartida (nomeArqNivel: string);

implementation

{--------------------------------------------------------}
{               ordena as letras da palavras             }
{--------------------------------------------------------}

function ordenaPalavra(raiz: string): string;
var i: integer;
    ordenou: boolean;
    temp: char;
begin
    repeat
        ordenou := true;
        for i := 1 to length(raiz)-1 do
            if raiz[i]>raiz[i+1] then
                begin
                    ordenou := false;
                    temp := raiz[i];
                    raiz[i] := raiz[i+1];
                    raiz[i+1] := temp;
                end;
    until ordenou;
    result := raiz;
end;

{--------------------------------------------------------}
{          seleciona palavra aleatoriamente              }
{--------------------------------------------------------}

function selecionaPalavra (nomeArq : string): string;
var
    palavrasGrandes: TStringList;
    n: integer;
    raiz: string;

begin
    palavrasGrandes := TStringList.Create;
    palavrasGrandes.loadFromFile (nomeArq);
    repeat
        n := random (palavrasGrandes.count);
        raiz := palavrasGrandes[n];
    until (pos ('-', raiz) = 0) and procuraDic(raiz);

    raiz := AnsiLowerCase(raiz);

    result := raiz;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas              }
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem(msg));
    end;

var n: integer;
const
    tabLetrasOpcao: string = 'CLTP' + ESC;
    tabLetrasOpcao2:  string = 'ACDLTP' + ESC;

begin
    if tentativa = '' then
        begin
            garanteEspacoTela (9);
            popupMenuCria (wherex, wherey, 25, length(tabLetrasOpcao), MAGENTA);
            menuAdiciona ('PVO_C');   {'C   - Continuar montando'}
            menuAdiciona ('PVO_L');   {'L   - Listar Palavras}
            menuAdiciona ('PVO_T');   {'T   - Consultar tempo'}
            menuAdiciona ('PVO_P');   {'P   - Pontuação'}
            menuAdiciona ('PVO_ESC'); {'ESC - Abandonar partida'}

            n := popupMenuSeleciona;
            if n > 0 then
                selSetasOpcao := tabLetrasOpcao[n]
            else
                selSetasOpcao := ESC;
        end
    else
        begin
            garanteEspacoTela (9);
            popupMenuCria (wherex, wherey, 25, length(tabLetrasOpcao2), MAGENTA);
            menuAdiciona ('PVO_A');   {'A   - Avaliar palavra'}
            menuAdiciona ('PVO_C');   {'C   - Continuar montando'}
            menuAdiciona ('PVO_D');   {'D   - Deletar palavra'}
            menuAdiciona ('PVO_L');   {'L   - Listar Palavras'}
            menuAdiciona ('PVO_T');   {'T   - Consultar tempo'}
            menuAdiciona ('PVO_P');   {'P   - Pontuação'}
            menuAdiciona ('PVO_ESC'); {'ESC - Abandonar partida'}

            n := popupMenuSeleciona;
            if n > 0 then
                selSetasOpcao := tabLetrasOpcao2[n]
            else
                selSetasOpcao := ESC;
        end;
end;

{--------------------------------------------------------}
{              Deleta última letra                       }
{--------------------------------------------------------}

procedure deletaUltimaLetra (var strMontada, strDisponiveis: string);
begin
    strDisponiveis := strDisponiveis + strMontada[length(strMontada)];
    strDisponiveis := ordenaPalavra(strDisponiveis);
    delete (strMontada, length(strMontada), 1);
end;

{--------------------------------------------------------}
{          Adiciona letra à palavra montada.             }
{--------------------------------------------------------}

procedure adicionaLetraPalavra (c: char; var strMontada, strDisponiveis: string);
begin
    delete (strDisponiveis, pos(c, strDisponiveis), 1);
    strMontada := strMontada + ansiLowerCase(c);
end;

{--------------------------------------------------------}
{                Montando uma palavra                    }
{--------------------------------------------------------}

procedure mostraPalavraParcial (strParcial: string);
begin
    mensagem ('PVTECL', -1);       {'Tecladas: '}
    sintSoletra (strParcial);
end;

{--------------------------------------------------------}
{            Mostra as palavras já achadas              }
{--------------------------------------------------------}

procedure mostraPalavrasAnteriores;
var i: integer;
begin
    limpaBaixo(8);
    textColor (Yellow);
    for i := 1 to 30 do
        if quantasAchadas-i+1 > 0 then
            begin
                if i < 16 then gotoxy (65, i+7)
                          else gotoxy (49, i-15+7);
                write (listaDeAchadas[quantasAchadas-i+1]);
        end;
    textColor (white);
end;

{--------------------------------------------------------}
{                Montando uma palavra                    }
{--------------------------------------------------------}

function montaUmaPalavra (var montada: string; var disponiveis: string; var c: char): string;
var
    salvay: integer;
begin
    if not verificaTempos then
        begin
            c := ESC;
            exit;
        end;

    banner (disponiveis, montada);
    salvay := wherey;
    repeat
        gotoxy (1, salvay);
        mostraPalavrasAnteriores;

        while not keypressed do
            begin
                displayTempo(false);
                if not verificaTempos then
                    begin
                        c := ESC;
                        exit;
                    end;
                delay (50);
            end;

        gotoxy (1, salvay);
        c := readkey;
        if c = #$0 then readkey;
        case c of
            #$0: begin
                    limpaBufTec;
                    { injeta seta para cima no teclado }
                    keyboardVirtKey (VK_UP, False, False, False, 100);
                    banner (disponiveis, montada);
                    c := popupMenuPorLetra(disponiveis);
                    if c <> ESC then
                        begin
                            sintClek;
                            sintCarac (c);
                            adicionaLetraPalavra (c, montada, disponiveis);
                        end
                    else
                        sintBip;
                 end;

            ' ': mostraPalavraParcial (montada);

            BS:  if montada = '' then
                        mensagem ('PVPALVAZ', -1)
                   else
                       begin
                           sintCarac (montada[length(montada)]);
                           deletaUltimaLetra (montada, disponiveis);
                       end;

            ENTER:
                    if not verificaTempos then
                        begin
                            c := ESC;
                            exit;
                        end;

             ESC:   ;
        else
            begin
                sintcarac (c);
                if letraNaPalavra (c, disponiveis) then
                    adicionaLetraPalavra (c, montada, disponiveis)
                else
                    begin
                        sintBip; sintBip;
                    end;
            end;
        end;

        banner (disponiveis, montada);

    until (c = ESC) or (c = ENTER);
end;

{--------------------------------------------------------}
{         Processa uma partida: várias palavras.         }
{--------------------------------------------------------}

procedure jogarPartida (nomeArqNivel: string);
var
    i: integer;
    c, c2, o: char;
    salvaDisponiveis: string;
    salvaY: integer;
    firstTime: boolean;
    diag: integer;
    caracTermino: char;

label
    envia;

begin
    closeBmp;
    clrscr;
    cabecalho;
    salvaY := whereY;

    palavraSorteada := selecionaPalavra (nomeArqNivel);
    letrasDisponiveis := ordenaPalavra (palavraSorteada);
    salvaDisponiveis  := letrasDisponiveis;

    quantasAchadas := 0;
    SetLength(listaDeAchadas, 1000);
    tentativa := '';
    pontuacaoExtra := 0;

    limpaBaixo (salvaY);

    limpaBufTec;
    mensagem ('PVFORMEP', 1);       {'Forme palavras selecionando as letras a seguir: '}
    banner(letrasDisponiveis, '');

    sintSom ('EF_PLIN');
    for i := 1 to length(letrasDisponiveis) do
        sintSoletra (letrasDisponiveis[i]);

    limpaBufTec;
    mensagem ('PVCOMEC', 0);        {'Começando...'}
    sintSom ('EF_PLIN');
    write (#$0d);

    resetTempoDaJogada;
    firstTime := True;

    salvaY := WhereY;
    repeat
        limpaBaixo (salvaY);
        banner(letrasDisponiveis, tentativa);

        if firstTime then
            firstTime := False
        else
            begin
                if tentativa <> '' then
                    mostraPalavraParcial (tentativa)
                else
                    mensagem ('PVPALVAZ', -1);       {'Palavra vazia.'}

                GotoXY (1, salvaY);
                sintSom ('EF_PLIN');
                mensagem('PVCONTSL', -1);           {'Continue ou tecle ESC'}
            end;

        montaUmaPalavra (tentativa, letrasDisponiveis, caracTermino);
        if tempoEsgotado then
            break;

        limpaBaixo (8);
        mostraPalavrasAnteriores;
        gotoxy (1, 8);
        if tentativa = '' then
            mensagem ('PVPALVAZ', 1)            {'Palavra vazia.'}
        else
            begin
                mensagem ('PVPALFOR', 0);       {'Palavra formada: '}
                sintWriteln (tentativa);
                if caracTermino = ENTER then
                    begin
                        c := ENTER;
                        goto envia;
                    end;
            end;

        while sintfalando do WaitMessage;

        textBackground (BLUE);
        mensagem ('PVQUALOP', 0);           {'Qual sua opção? '}
        textBackground (BLACK);

        sintLeTecla (c, c2);
        if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = 'N') or (c2 = F9)) then
             c := selSetasOpcao;

        if not verificaTempos then
            break;

envia:
        case upcase(c) of
            ENTER, 'A':            { Avaliar ou enviar palavra }
                begin
                    diag := fazDiagnostico;

                    displayTempo (true);

                    if diag = _Valida then
                        begin
                            if letrasDisponiveis = '' then
                                begin
                                    textBackground(RED);
                                    mensagem ('PVPEXTRA', 1);   {'Parabéns, pontos extras...'}
                                    textBackground(BLACK);
                                    pontuacaoExtra := pontosExtras;
                                end;

                            resetTempoDaJogada;   {Só reseta tempo quando acerta...}
                        end;

                    mostraPontos;

                    delay (500);
                    tentativa := '';
                    letrasDisponiveis := salvaDisponiveis;

                    banner (letrasDisponiveis, tentativa);
                    mostraPalavrasAnteriores;

                    gotoxy (1, 11);
                    textBackground(RED);
                    sintSom ('PVPLIN');
                    mensagem ('PVMONTPA', 0);   {'Monte uma nova palavra!'}
                    sintSom ('PVPLIN');
                    textBackground(BLACK);
                    firstTime := true;

                    while not keypressed do waitMessage;
                    limpaBaixo(salvaY);
                end;

            'D':
                begin
                    tentativa := '';
                    letrasDisponiveis := salvaDisponiveis;
                    mensagem ('PVDELPAL', -1);          {'Palavra deletada!'}
                end;

            'P': mostraPontos;
            'T': displayTempo(true);
            'L':
                if quantasAchadas >= 1 then
                    begin
                        limpaBaixo(salvaY);
                        GotoXY(5, whereY);
                        mensagem ('PVNUMPAL', 0);       {'Número de palavras: '}
                        sintwriteint (quantasAchadas);
                        writeln;
                        writeln;
                        popupMenuCria(5, whereY, length(salvaDisponiveis), 20, RED);
                        for i :=1 to quantasAchadas do
                            popupMenuAdiciona('', listaDeAchadas[i]);
                        popupMenuSeleciona;
                    end
                else
                    diagErro ('PVNACERT', true);          {'Você ainda não acertou nenhuma palavra.'}

            ESC:
                begin
                    closeBMP;
                    limpaBaixo (salvaY);
                    if tentativa <> '' then
                        mensagem ('PVPALNAO', 1);   {'A palavra atual não será computada.'}
                    writeln;
                    writeln;
                    mensagem ('PVQPARAR', 0);       {'Deseja parar de jogar (S/N)? '}
                    o := popupMenuPorLetra('SN');
                    if o = 'S' then
                        begin
                            mensagem ('PVDESIST', -1);   {'Desistiu de continuar.'}
                            writeln; writeln;
                            break;
                        end;
                end;

            'C':  begin end;                    { Só continuar... Nada a fazer }

        else
            diagErro ('PVOPCINV', false);              {'Opção inválida.'}
        end;

    until false;        { forever... }

    if tempoEsgotado then
        diagErro ('PVTESGOT', true);          {'Tempo esgotado!'}

    closeBMP;
    ClrScr;
    cabecalho;

    produzScores;
    atualizaScores(pontuacaoTotal);

    while sintfalando do waitMessage;
end;

end.
