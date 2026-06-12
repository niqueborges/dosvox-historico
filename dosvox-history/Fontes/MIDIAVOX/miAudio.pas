{---------------------------------------------------------------}
{                                                               }
{    Programa de execução de midias                      }
{                                                               }
{    módulo de reprodução de áudios para legendas              }
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

unit miAudio;

interface

uses
    sysutils,
    dvCrt,
    dvWav,
    dvWin,
    mmsystem;

function tocandoSom: boolean;
procedure tocaSom (nomeArq: string);
procedure paraSom;

implementation

{--------------------------------------------------------}
function tocandoSom: boolean;
begin
    dvWav.waveIsPlaying;
end;

{--------------------------------------------------------}
procedure paraSom;
begin
    dvWav.waveStop;
end;

{--------------------------------------------------------}
procedure tocaSom (nomeArq: string);
var
    dir:  string;
begin
    if pos (':\', nomeArq) <> 0 then
        wavePlayFile (nomeArq)
    else
        begin
            getDir (0, dir);
            wavePlayFile (dir+'\'+nomeArq);
        end;
end;

begin
    dvWav.keyStopsWave := true;
end.
