{--------------------------------------------------------}
{                                                        }
{    Jogo aterrisagem lunar                              }
{                                                        }
{    Módulo de tratamento dos Scores                     }
{                                                        }
{    Autor: Diego Costa Pontes                           }
{                                                        }
{    Em agosto/2006                                      }
{                                                        }
{--------------------------------------------------------}

unit luscores;

interface
uses
  dvcrt,
  dvwin,
  dvForm,
  sysutils,
  luvars,
  lumsg;

procedure inicializaScores;
procedure atualizaScores (novosPontos: integer);
procedure mostraScore (numeroScores : integer);
procedure produzScores;
procedure gravaScores;

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
    assignfile(f, sintDirAmbiente + '\luplacar.ini');
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
    nomeArq: string;

begin
    nomeArq := sintAmbiente ('LUNARVOX', 'ARQPLACAR');
    if nomeArq = '' then
        nomeArq := sintDirAmbiente + '\luplacar.ini';

    if fileExists(nomeArq) then
        begin
           nScores := 0;
           assignfile(f, nomeArq);
           reset(f);
           while not eof(f) do
              begin
                    nScores := nScores + 1;
                    try
                        readln(f, scores[nScores].nome);
                        readln(f, scores[nScores].pontos);
                    except
                        mensagem ('LUERRARQ', 1);  {'Erro no arquivo de configuração!'}
                    end;
              end; {while}
           closefile(f);
        end {if}
     else
        begin
           // se arquivo no disco não existe ou não tem nada dentro dele,
           // inicializa com estes valores de brinquedo

           scores[1].nome := 'Diego Pontes';
           scores[1].pontos := 3130;
           scores[2].nome := 'Antonio Borges';
           scores[2].pontos := 1725;
           scores[3].nome := 'Zé Sá';
           scores[3].pontos := 531;
           nScores := 3;
        end; {else}

    ordenaScores;
end;

{-----------------------------------------------------------------------}
{                   Produz os scores do jogo                            }
{-----------------------------------------------------------------------}

procedure produzScores;
begin

    if (velocFinal < velocAterrisagem) AND (velocFinal > 0) then
        scoreTemp := trunc (5000 - ((t * 7) + ((combInicial - comb) * 3)
                                                        + (velocFinal * 113)))
    else
        scoreTemp := trunc (2000 - ((t * 4) + ((combInicial - comb) * 3)
                                                        + (velocFinal * 113)));

    if (scoreTemp < 0) OR (foraOrb) then scoreTemp := 0;

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
    mensagem ('LUPNTMAX', 1);  {'Use as setas para conhecer os ases pilotos e sua pontuação'}
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

    if novosPontos > 200 then
       begin
          if (nScores < 10) then
              begin
                  nScores := nScores + 1;
                  posicao := nScores ;
              end {if}
          else
              if novosPontos > scores[10].pontos then posicao := 10;
       end; {if}

    if (posicao > 0) then
       begin
          writeln;
          if novosPontos > 3500 then
              sintsom ('FOGOS')
          else
              sintsom ('APLAUSOS');
          mensagem ('LUPARABE', 1); {'Parabéns, você entrará para o quadro de ases pilotos!'}
          mensagem ('LULENOME', 1); {'Entre com seu nome:'}
          sintreadln(s);
          if s = '' then s := '<sem nome>';

          with scores[posicao] do
              begin
                  nome := s;
                  pontos := novosPontos;
              end;

          ordenaScores;
          gravaScores;

       end;
end;

end.
