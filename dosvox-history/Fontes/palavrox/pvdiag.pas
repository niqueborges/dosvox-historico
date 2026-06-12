{---------------------------------------------------------}
{                                                         }
{    Programa Palavrox                                    }
{                                                         }
{    Módulo de diagnóstico da palavra                     }
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

unit pvdiag;

interface
uses
  sysutils,
  windows,
  classes,
  dvcrt,
  dvwin,
  dvWav,
  dvdic,
  pvvars,
  pvmsg;

function letraNaPalavra (c: char; palavra: string): boolean;
function validarpalavra( palavra: string) : integer;
procedure diagErro (diag: string; comEnter: boolean);
procedure info (diag: string);
function fazDiagnostico: integer;

implementation

{--------------------------------------------------------}
{           testa se letra existe na palavra             }
{--------------------------------------------------------}

function letraNaPalavra (c: char; palavra: string): boolean;
var s: string;
begin
    palavra := ansiLowerCase(palavra);
    s := ansiLowerCase(c);
    result := pos (s[1], palavra) <> 0;
end;

{--------------------------------------------------------}
{                       testa letra                      }
{--------------------------------------------------------}

function testaletra(palavra : string) : boolean;
var
    t, p : integer;
    achou : boolean;
    copia : string;

begin
    copia := palavra;
    achou := false;

    for t:= 1 to length(tentativa) do
    begin
        achou :=false;
        for p := 1 to length(copia) do
        begin
            if tentativa[t] = copia[p] then
            begin
                achou := true;
                copia[p]:='-';
                break;
            end;
        end;
        if not achou then
            break;
    end;

    result := achou;
end;

{--------------------------------------------------------}
{                  validar  palavra                      }
{--------------------------------------------------------}

function validarpalavra( palavra: string) : integer;
var
    j : integer;
begin
    if not procuradic(tentativa) then
        result := _Desconhecida
    else
        if not testaletra(palavra) then
            result := _inexistente
        else
            begin
                result := _Valida;
                for j := 1 to quantasAchadas do
                begin
                    if tentativa = listaDeAchadas[j] then
                        begin
                            result := _repetida;
                            break;
                        end;
                end;
            end;
end;

{--------------------------------------------------------}
{                 diagnóstico de erro                    }
{--------------------------------------------------------}

procedure diagErro (diag: string; comEnter: boolean);
var salvaY: integer;
begin
    limpaBufTec;
    salvaY := whereY;
    limpaBaixo(23);
    textBackground(MAGENTA);
    mensagem (diag, 0);
    textBackground(BLACK);

    if comEnter then
        begin
            write (' ');
            sintSom ('EF_PLIN');
            mensagem ('PVAPTENT', 0);   {'Aperte Enter...'}
            readln;
            limpaBaixo (salvaY);
        end;
end;

{--------------------------------------------------------}
{                 diagnóstico de erro                    }
{--------------------------------------------------------}

procedure info (diag: string);
var salvaY: integer;
begin
    limpaBufTec;
    salvaY := whereY;
    limpaBaixo(24);
    mensagem (diag, 0);
    repeat WaitMessage until KeyPressed;
    limpaBaixo (salvaY);
end;

{--------------------------------------------------------}
{                 ve se a palavra está ok                }
{--------------------------------------------------------}

function fazDiagnostico: integer;
var diagnostico: integer;
begin
    diagnostico := validarpalavra(tentativa);

    case diagnostico of
        _Desconhecida:  diagErro ('PVDESCON', true);  {'Palavra desconhecida.'}
        _Inexistente:   diagErro ('PVLETINE', true);  {'Palavra utilizou letras inexistentes.'}
        _Repetida:      diagErro ('PVPALREP', true);  {'Palavra repetida não vale!'}
        _Valida:
            if (length(tentativa) <= 2) then
                begin
                    diagErro ('PVPEQUEN', true);  {'Palavra recusada: muito pequena.'}
                    diagnostico := _Pequena;
                end
            else
                begin
                    quantasAchadas := quantasAchadas + 1;
                    if length(listaDeAchadas) < quantasAchadas then
                        setLength(listaDeAchadas, quantasAchadas+99);
                    listaDeAchadas[quantasAchadas] := tentativa;
                    diagErro ('PVVALIDA', false);      {'Palavra válida!'}
                end;
    end;

    result := diagnostico;
end;

end.
