{--------------------------------------------------------}
{                                                        }
{    Programa acesso simplificado ao Google              }
{                                                        }
{    Variáveis globais                                   }
{                                                        }
{    Autores: Antonio Borges e Fabiano Ferreira          }
{       Em maio/2013                                     }
{                                                        }
{    Atualizado por Antonio Borges e Patrick Barboza     }
{       Em fevereiro/2025                                }
{                                                        }
{--------------------------------------------------------}

unit gvvars;

interface
uses classes;

const
    versao = '4.0';
    alfaBeta = 'beta2';

var
    debug: boolean;

    defaultBrowser: string;
    siteGoogle: string;
    urlGoogle: string;
    cookies: TStringList;
    iflsig: string;
    pagAtual: integer;

    newLocation: string;
    resultado: TStringList;

    ultimasBuscas: array [1..10] of string;

implementation

end.
