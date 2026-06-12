{---------------------------------------------------------------}
{                                                               }
{    Programa de execução de midias                      }
{                                                               }
{    módulo de processamento de legendas                        }
{                                                               }
{    Autor: Patrick Barboza                                     }
{                                                               }
{    Código extraído e adaptado do programa dublavox            }
{                                                               }
{    Autores:   Antonio Borges                                  }
{               Fabiano Ferreira                                }
{               Júlio Silveira                                  }
{                                                               }
{                                                               }
{    Em Fevereiro/2024                                          }
{                                                               }
{---------------------------------------------------------------}

unit miLegendas;

interface

uses
    dvcrt,
    dvwin,
    mivars,
    windows,
    sysutils;

type
    TLegenda = record
        tempoinicial,
        tempofinal: integer;
        texto,
        texto2: string;
        arqSom: string;
    end;

const
    MAXLEGENDAS = 20000;

var
    legendas: array[1..MAXLEGENDAS] of TLegenda;
    numlegendas: integer;
    PosArqLegendas: integer;
    nomeArqLegendas: string;

function inicializaLegendas: boolean;
function carregaLegendas (nomearq : string): boolean;
function converteTempo(hor, min, seg, mili: word): integer; Overload;
function converteTempo(s : string): integer; Overload;

implementation

    {--------------------------------------------------------}

function inicializaLegendas: boolean;
var
    p: integer;
begin
    inicializaLegendas := false;
    nomeArqLegendas := midiaAtual;
    p := LastDelimiter('.', nomeArqLegendas);
    if p <> 0 then
    begin
        delete (nomeArqLegendas, p, 999);
        nomeArqLegendas := nomeArqLegendas + '.srt';
        end;
    if not carregaLegendas(nomeArqLegendas) then exit;
    inicializaLegendas := true;
end;

{---------------------------------------------------------------------------}
function converteTempo(hor, min, seg, mili: word): integer;
begin
    result  := ((hor*60+min)*60+seg)*1000+mili;
end;

{---------------------------------------------------------------------------}
function converteTempo(s : string): integer;
var
    hora, minuto, segundo, mili : integer;

begin
    hora    := strToInt (copy(s, 1, 2));
    minuto  := strToInt (copy(s, 4, 2));
    segundo := strToInt (copy(s, 7, 2));
    mili    := strToInt (copy(s, 10, 3));
    result  := converteTempo(hora, minuto, segundo, mili);
end;

{---------------------------------------------------------------------------}
function carregaLegendas (nomearq : string): boolean;
var
    arq : textfile;
    lixo,
    linha: string;
    intervalo, t1, t2 : string;

begin
    numlegendas := 0;
    if not fileexists(nomearq) then
        begin
            result := false;
            exit;
        end;
    assignfile (arq, nomearq);
    reset (arq);
    while not eof (arq) do
        begin
            numlegendas:= numlegendas + 1;
            with legendas[numlegendas] do
                begin
                    readln(arq, lixo);
                    readln(arq, linha);
                    intervalo := copy (linha, 1, 29);
                    delete (linha, 1, 29);
                    linha := trim (linha);
                    if (linha <> '') and (linha[1] = '[') and
                                         (linha[length(linha)] = ']') then
                        arqSom := copy(linha,2,length(linha)-2)
                    else
                        arqSom := '';
                    readln(arq, texto);
                    texto2 := '';
                    if texto <> '' then
                    begin
                        if not eof (arq) then
                            readln(arq, texto2);
                    end;
                    if texto2 <> '' then
                        readln(arq, lixo);

                    t1 := copy(intervalo,  1, 12);
                    t2 := copy(intervalo, 18, 12);
                    tempoinicial := converteTempo(t1);
                    tempofinal := converteTempo(t2);
                end;
        end;

     closefile (arq);
    result := true;
end;

begin
    numLegendas := 0;
end.
