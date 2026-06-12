{--------------------------------------------------------}
{                                                        }
{    Programa de acesso rápido usando imap               }
{                                                        }
{    Módulo de variáveis globais                         }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em abril/2013                                       }
{                                                        }
{--------------------------------------------------------}

unit iuvars;

interface

uses classes, dvinet;

const
    versao = '1.7';
    MAXCARTAS = 50000;

var
    debug: boolean;
    arqDebug: textFile;

    usassl: boolean;
    porta: integer;
    sock: integer;
    pbuf: PbufRede;
    serial: integer;
    respserv: TStringList;
    servidor, conta, senha: string;
    prefixoImap: string;
    dirRecebeCartavox: string;
    nomeConfiguracao: string;
    serialDownload: integer;
    pastaAtual: string;
    cartasNaPasta: integer;
    pastasImap: TStringList;
    clek: boolean; {Sonoriza na recepção}

type
    PEnvelope = ^TEnvelope;
    TEnvelope = record
        data, assunto, enviador: string;
    end;

implementation

begin
end.
