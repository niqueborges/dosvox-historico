{--------------------------------------------------------}
{                                                        }
{    Programa leitor de notícias e RSS                   }
{                                                        }
{    Módulo de variáveis globais                         }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em maio/2013                                        }
{                                                        }
{    Versão 2.0 em setembro/2019                         }
{                                                        }
{--------------------------------------------------------}

unit nevars;

interface

uses classes, dvinet;

const
    versao = '2.0 beta';

var
    arqIndice: string;
    debug: boolean;
    usassl: boolean;
    porta: word;
    sock: integer;
    pbuf: PbufRede;

implementation

end.
