{---------------------------------------------------------}
{                                                         }
{    Programa Palavrox                                    }
{                                                         }
{    Módulo de tratamento da pontuação                    }
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

unit pvscores;

interface
uses
  dvcrt,
  dvwin,
  dvForm,
  sysutils,
  windows,
  minireg,
  pvvars,
  pvmsg;

procedure inicializaScores; forward;
procedure atualizaScores (novosPontos: integer); forward;
procedure mostraScore (numeroScores : integer); forward;
procedure produzScores; forward;
procedure gravaScores; forward;
procedure mostraPontos;

const
    tabPontos: array[1..3,1..5] of integer = ( (10, 50, 100, 150, 300),
                                               (20, 70, 120, 170, 400),
                                               (30, 90, 140, 190, 500) );
    pontosExtras = 2000;

implementation

{-------------------------------------------------------------}
{                   Ordena os scores                          }
{-------------------------------------------------------------}

procedure ordenaScores;
var i, j: integer;
    temp: TScore;

begin
    for i := 1 to nScores-1 do
        for j := i to nScores do
            if scores[i].pontos < scores[j].pontos then
                begin
                    temp := scores[i];
                    scores[i] := scores[j];
                    scores[j] := temp;
                end;
end;

{-------------------------------------------------------------}
{                   Grava no arquivo                          }
{-------------------------------------------------------------}

procedure gravaScores;
var
    f : textfile;
    s : string;
    i : integer;
    j : integer;

begin
    assignfile(f, nomeArqScores);
    rewrite(f);
    for j := 1 to nScores do
        begin
        s := scores[j].nome;
        i := scores[j].pontos;
        writeln(f, s);
        writeln(f, i);
        end;
    closefile(f);
end;

{-----------------------------------------------------------------------}
{             Inicializa com um Score qualquer                          }
{-----------------------------------------------------------------------}

procedure inicializaScores;
var
    f : textfile;
    dirConfigs: string;

begin
    nomeArqScores := sintAmbiente ('PALAVROX', 'ARQPLACAR');
    if nomeArqScores = '' then
        begin
            regGetString (HKEY_CURRENT_USER,
                'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\AppData',
                    DirConfigs);
            nomeArqScores := DirConfigs + '\Dosvox\pvplacar.ini';
        end;

    if fileExists(nomeArqScores) then
        begin
           nScores := 0;
           assignfile(f, nomeArqScores);
           reset(f);
           while not eof(f) do
              begin
                    nScores := nScores + 1;
                    try
                        readln (f, scores[nScores].nome);
                        readln (f, scores[nScores].pontos);
                    except
                        mensagem ('PVERRCNF', 2);       {'Erro no arquivo de configuração.'}
                    end;
              end;
           closefile(f);
        end
     else
        begin
           { se arquivo no disco não existe ou não tem nada dentro dele, }
           { inicializa com estes valores de brinquedo ? }

           scores[1].nome := 'João Marcelo - 20/10/2018';
           scores[1].pontos := 1700;
           scores[2].nome := 'João Pedro - 18/10/2018';
           scores[2].pontos := 1650;
           nScores := 2;
        end; 

    ordenaScores;
end;

{-----------------------------------------------------------------------}
{                   Produz os scores do jogo                            }
{-----------------------------------------------------------------------}

procedure produzScores;
var
    i: integer;
begin
    pontuacaoTotal := 0;

    if quantasAchadas = 0 then
        exit;

    pontuacaoTotal := quantasAchadas * tabPontos[nivel][1] +
                      tabPontos[nivel][5];   { recompensa padrão do nível }

    for i := 1 to quantasAchadas do
        begin
            if length(listaDeAchadas[i]) <= 4 then
                pontuacaoTotal := pontuacaoTotal + tabPontos[nivel][2]
            else
            if length(listaDeAchadas[i]) <= 6 then
                pontuacaoTotal := pontuacaoTotal + tabPontos[nivel][3]
            else
            if length(listaDeAchadas[i]) <= 8 then
                pontuacaoTotal := pontuacaoTotal +  tabPontos[nivel][4]
            else
                pontuacaoTotal := pontuacaoTotal +  tabPontos[nivel][5];
        end;

    pontuacaoTotal := pontuacaoTotal + pontuacaoExtra;
end;

{-----------------------------------------------------------------------}
{             Mostra as pontuações.                                     }
{-----------------------------------------------------------------------}

procedure mostraScore (numeroScores : integer);
var
    i: integer;
const brancos = '                                               ';
begin
    writeln;
    limpabuftec;
    mensagem ('PVCONJOG', 1); {'Use as setas para conhecer os jogadores e suas pontuações'}
    writeln;

    garanteEspacoTela(nScores);
    popupMenuCria(wherex, wherey, 50, nscores, RED);
    for i := 1 to nScores do
       with scores[i] do
          popupMenuAdiciona('', copy (nome+brancos, 1, 40) + ' ' + intToStr(pontos) );
    popupMenuSeleciona;
    writeln;
end;

{-------------------------------------------------------------}
{                     atualiza os scores                      }
{-------------------------------------------------------------}

procedure atualizaScores (novosPontos: integer);
var posicao: integer;
    s: string;
begin
    posicao := -1;

    if novosPontos >= 0 then
        begin
            if (nScores < 10) then
                begin
                    nScores := nScores + 1;
                    posicao := nScores ;
                end {if}
            else
                if (novosPontos > scores[10].pontos) then posicao := posicao +11;
        end; {if}

    if posicao = -1 then
        posicao := posicao + 2;

    if (posicao > 0) then
        begin
            writeln;
            textBackground (MAGENTA);
            mensagem ('PVVOCFEZ', 0);   {'Sua pontuaçao: '}
            sintWriteInt (novospontos);
            textBackground (BLACK);
            writeln;
            writeln;

            if novospontos >= 1000 then
                begin
                    textBackground (RED);
                    mensagem ('PVPARABE', 2);   {'Parabéns pelo ótimo desempenho!'}
                    textBackground (BLACK);
                end;

            if novosPontos <= scores[10].pontos then
                begin
                    mensagem ('PVNAOENT', 1);   {'Infelizmente não entrou para o quadro dos melhores.'}
                    mensagem ('PVCNTENT', 1);   {'Continue tentando!'}
                end
            else
                begin
                    textBackground (RED);
                    mensagem ('PVMELHOR', 1);    {'Você entrará para o quadro dos melhores jogadores.'}
                    textBackground (BLACK);

                    repeat
                        limpabuftec;
                        mensagem ('PVDIGNOM', 0);   {'Digite o seu nome:'}
                        sintReadln(s);
                    until length(s) > 1;

                    with scores[posicao] do
                        begin
                            nome := s + ' - ' + copy (DateToStr(now), 1, 10);
                            pontos := novosPontos;
                        end;

                    ordenaScores;
                    gravaScores;

                    if (s <> CIMA) and (s <> BAIX) and (length(s)>1) then
                        mostrascore(nscores);
                end;

       end;
end;

{-------------------------------------------------------------}
{                Mostra a pontuação até o momento             }
{-------------------------------------------------------------}

procedure mostraPontos;
var salvay: integer;
begin
    salvay := wherey;

    produzScores;
    gotoxy (1, 24);
    write (pegaTextoMensagem('PVPNTAGO') + intToStr(pontuacaoTotal));

    gotoxy (1, 24);
    mensagem ('PVPNTAGO', -1);           {'Pontuação: '}
    sintetiza (intToStr(pontuacaoTotal));
    gotoxy (1, salvay);
end;

end.
