{-----------------------------------------------------------}
{                                                           }
{    Jogo de montar palavras                                }
{                                                           }
{    Módulo de tratamento dos Scores                        }
{                                                           }
{    Autores: João Marcelo de Andrade & João Pedro Souza    }
{                                                           }
{    Em Outubro/2018                                        }
{                                                           }
{-----------------------------------------------------------}

unit plscores;

interface
uses
  dvcrt,
  dvwin,
  dvForm,
  sysutils,
  plvars;

procedure inicializaScores; forward;
procedure atualizaScores (novosPontos: integer); forward;
procedure mostraScore (numeroScores : integer); forward;
procedure produzScores; forward;
procedure gravaScores; forward;

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
    nomePlacar: string;

begin
    nomeplacar := sintAmbiente ('PALAVROX', 'ARQPLACAR');
    if nomeplacar = '' then nomeplacar := 'c:\winvox\som\palavrox\plplacar.ini';
    assignfile(f, nomeplacar);
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
    nomeArq := sintAmbiente ('PALAVROX', 'ARQPLACAR');
    if nomeArq = '' then nomeArq := 'c:\winvox\som\palavrox\plplacar.ini';

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
                        sintwriteln('Erro no arquivo de configuração!');
                    end;
              end; {while}
           closefile(f);
        end {if}
     else
        begin
           // se arquivo no disco não existe ou não tem nada dentro dele,
           // inicializa com estes valores de brinquedo

           scores[1].nome := 'João Marcelo';
           scores[1].pontos := 1700;
           scores[2].nome := 'João Pedro';
           scores[2].pontos := 1650;
           nScores := 2;
        end; {else}

    ordenaScores;
end;

{-----------------------------------------------------------------------}
{                   Produz os scores do jogo                            }
{-----------------------------------------------------------------------}

procedure produzScores;
var i : integer;
begin
    if nivel=1 then
    begin
        for i:=1 to num do
            scoretemp := scoretemp + 10; // reconpensa pela quantidade de palavras

        for i:=1 to num do
        begin
            if length(vetpalavras[i])<=4 then
                scoretemp :=scoretemp + 50; // recompensa por 4 çletras

            if(length(vetpalavras[i])>4) and (length(vetpalavras[i])<=6) then
                scoretemp :=scoretemp + 100 // recompensa com palavras de 4 a 6 letras

            else
                scoretemp :=scoretemp + 150; // palavras maiores que 6
            end;
        end;{for}


     scoretemp :=scoretemp + 100; // recompensa pelo nivel 1

    if num < 2 then scoretemp :=0;

//    end;{if nivel 1}

    if nivel = 2 then
    begin
        for i:=1 to num do
            scoretemp := scoretemp + 20; // reconpensa pela quantidade de palavras

        for i:=1 to num do
        begin
            if length(vetpalavras[i])<=4 then
                scoretemp :=scoretemp + 70 // recompensa por 4 letras
            else
            if(length(vetpalavras[i])>4) and (length(vetpalavras[i])<=6) then
                scoretemp :=scoretemp + 120 // recompensa com palavras de 4 a 6 letras
            else
                scoretemp :=scoretemp + 170; // palavras maiores que 6
        end;{for}

        scoretemp :=scoretemp + 200; // recompensa pelo nivel 1

    if num < 2 then scoretemp :=0;

    end;{if nivel 1}

    if nivel = 3 then
    begin
        for i:=1 to num do
            scoretemp := scoretemp + 30; // reconpensa pela quantidade de palavras

        for i:=1 to num do
        begin
            if length(vetpalavras[i])<=4 then
                scoretemp :=scoretemp + 90 // recompensa por 4 çletras
            else
                scoretemp :=scoretemp + 190; // palavras maiores que 6
        end;{for}

     scoretemp :=scoretemp + 300; // recompensa pelo nivel 1

    if num < 2 then scoretemp :=0;

    end;{if nivel 1}
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
    sintwriteln('Use as setas para conhecer os jogadores e suas pontuações');
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

    if posicao = -1 then     posicao :=posicao +2;

    if (posicao > 0) then
       begin
          writeln;
          if novosPontos < scores[10].pontos then
            begin
                sintsom('palmas');
                sintwriteln('Você fez ' +inttostr(novospontos)
                                      + ' pontos! Parabéns!!');
                sintwriteln('Infelizmente não entrou para o quadro dos'
                       + ' melhores. Continue tentando!');
            end
          else
              begin
                  sintsom ('fogos');
               sintwriteln('Parabéns! Você entrará para o quadro dos melhores'
                                                         + ' jogadores');

                  limpabuftec;
                  repeat
                       limpabuftec;
                       sintwriteln('Entre com seu nome:');
                        limpabuftec;
                        sintreadln(s);
                  until  (s <> CIMA) and (s <> BAIX) and (length(s)>1);

                  if s = '' then s := '<sem nome>';

                  with scores[posicao] do
                      begin
                          nome := s;
                          pontos := novosPontos;
                      end;

                  ordenaScores;
                  gravaScores;

                  if (s <> CIMA) and (s <> BAIX) and (length(s)>1) then
                  mostrascore(nscores);
              end;

       end;
end;

end.
