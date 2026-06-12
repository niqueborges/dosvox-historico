{--------------------------------------------------------}
{                                                        }
{    Programa de execução de midias                      }
{                                                        }
{    Módulo de variáveis                                 }
{                                                        }
{    Autor: Marcolino Matheus Nascimento                 }
{                                                        }
{    Em setembro/2015                                    }
{                                                        }
{--------------------------------------------------------}

unit mivars;

interface

Uses SysUtils, classes;

const
    versao = '3.0';

const
    MINVOL   = 0;           { Limites extraídos da inferface MCI }
    MAXVOL   = 1000;
    volBaixo = 50;          { Nível do volume atenuado }
    passoVol = 100;         { Passo para ajuste do volume }

var
    playlist: TStringList;
    repetidos: TStringList;// salva os indices já executados, usado quando a execução é randomica
    extensoes: TStringList;
    nomePlayList: string;

    // Informações sobre a midia
    midiaAtual:    string;
    extMidiaAtual: string;
    duracao: String;
    tempo: array [0..80] of char;
    item: integer;           {Indice da musica na playlist}

    avanca, volta, repete, fimplaylist,
    reinicia, execucaoAutomatica, aleatorio: boolean;

    volumeMidia: integer;

    //Controle de síntese de legendas
    ultimaLegendaFalada, ultimaLegendaMostrada: integer;
    dublando: boolean;

    modosilencioso: boolean;

Type
    TStatusTerm = (CANCELOU, TERMINOU, VAZIO);

function extensaoVideo (ext: string): boolean;

implementation

function extensaoVideo (ext: string): boolean;
begin
    ext := UpperCase (ext);
    result := (ext = '.MP4') or (ext = '.WMV') or (ext = '.MPEG') or (ext = '.RMVB') or
              (ext = '.AVI') or (ext = '.3GP') or (ext = '.MOV' ) or (ext = '.FLV' );
end;

end.
