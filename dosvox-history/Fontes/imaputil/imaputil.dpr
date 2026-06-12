{--------------------------------------------------------}
{                                                        }
{    Programa de acesso rápido usando imap               }
{                                                        }
{    Programa principal                                  }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em abril/2013                                       }
{                                                        }
{--------------------------------------------------------}

program imaputil;

uses
  dvcrt,
  dvwin,
  windows,
  sysutils,
  classes,
  dvinet,
  dvssl,
  dvform,
  dvarq,
  iuenvel,
  iuproces,
  iurede,
  iuvars,
  iupastas,
  iumsg,
  iuleit,
  iutela,
  iuleitin;

{--------------------------------------------------------}
{ Inicializa e obtem informações para conexão            }
{--------------------------------------------------------}

procedure inicializa;
var ambiente: string;
begin
    clrscr;
    setwindowtitle('Imaputil');
    ambiente := sintambiente('IMAPUTIL', 'DIRIMAPUTIL');
    if ambiente = '' then
        ambiente := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\imaputil';
    sintinic (0, ambiente);

    write (pegaTextoMensagem('IUINIC'));   {'Imaputil - versão '}
    writeln (versao);
    writeln;

    if sintFalarTudo then
        begin
            mensagem ('IUINIC', -1);   {'Imaputil - versão '}
            sintetiza (versao);
        end
    else
            mensagem ('IUIMAPUTIL', -1);   {'Imaputil'}

    respserv := TStringList.create;
    pastasImap := TStringList.create;
    serialDownload := 1;

    debug := upcase(sintambiente('IMAPUTIL', 'DEBUG', 'NAO')[1]) = 'S';

    dirRecebeCartavox := sintAmbiente('CARTAVOX', 'DIRRECEBE');
    nomeConfiguracao := sintAmbiente ('CARTAVOX', 'CONFIGURACAO');
    if nomeConfiguracao <> '' then setwindowtitle('Imaputil ' + nomeConfiguracao);
    clek := upcase((sintAmbiente('CARTAVOX', 'CLEK') + 'S')[1]) = 'S';
end;

{--------------------------------------------------------}
{ fecha a conexão e encerra o programa                   }
{--------------------------------------------------------}

procedure termina;
begin
    if sock > 0 then
    begin
        fimBufRede (pbuf);
        fechaConexao (sock);
        fechaWinsock;
    end;

    if sintFalarTudo then mensagem ('IUFIM', 1)   {'Fim do processamento.'}
    else writeln (pegaTextoMensagem('IUFIM'));   {'Fim do processamento.'}
    sintfim;
end;

{--------------------------------------------------------}
{ programa principal                                     }
{--------------------------------------------------------}

begin
    inicializa;
    if pedeDadosParaLogin (true) and conecta then
        processa;
    termina;
end.
