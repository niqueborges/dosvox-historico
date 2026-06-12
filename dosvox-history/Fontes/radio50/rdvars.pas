{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Módulo de variáveis globais                         }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{    Modificado por Patrick Barboza                      }
{                                                        }
{    Em outubro / novembro / 2021                        }
{                                                        }
{--------------------------------------------------------}

unit rdvars;

interface

uses classes, dvinet;

const
    VERSAO = '3.3';
    TOTALLETRAS = 256000; {    Para a exibição de rádios}
    MAXPREFERIDAS = 50;

var
    arqIndice: string;
    sock: integer;
    pbuf: PbufRede;
    ultimaTocada: string;

implementation

begin
end.
