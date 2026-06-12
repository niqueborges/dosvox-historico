{--------------------------------------------------------}
{                                                        }
{    Programa leitor de notícias e RSS                   }
{                                                        }
{    Programa principal                                  }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em maio/2013                                        }
{                                                        }
{--------------------------------------------------------}

program voxnews;

uses
  dvcrt,
  dvwin,
  sysutils,
  dvinet,
  nerede,
  nevars,
  nemsg,
  neProces,
  nerss,
  nenavega,
  neutil,
  neleit,
  neatom;

{--------------------------------------------------------}
{                    Inicializa                          }
{--------------------------------------------------------}

procedure inicializa;
var ambiente: string;
begin
    clrscr;
    setwindowtitle('VoxNews');
    ambiente := sintambiente('VOXNEWS', 'DIRVOXNEWS');
    if ambiente = '' then
        ambiente := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\voxnews';
    sintinic (0, ambiente);

    textBackground (BLUE);
    mensagem ('NEINIC', 0);   {'VoxNews - versão '}
    sintWriteln (versao);
    textBackground (BLACK);
    writeln;
    if not abrewinsock then
        begin
            mensagem ('NENAOCON', 1);  {'Seu computador não está conectado à internet.'}
            mensagem ('NEPROCAN', 1);  {'Programa cancelado.'}
            sintFim;
            halt;
        end;

    arqIndice := sintambiente('VOXNEWS', 'DIRINDICE');
    if arqIndice = '' then
        arqIndice := sintDirAmbiente + '\voxnews.ini';
end;

{--------------------------------------------------------}
{                     fecha o programa                   }
{--------------------------------------------------------}

procedure termina;
begin
    fechaWinsock;

    mensagem ('NEFIM', 1);   {'Fim do processamento.'}
    sintfim;
end;

{--------------------------------------------------------}
{                   programa principal                   }
{--------------------------------------------------------}

begin
    inicializa;
    processa;
    termina;
end.
