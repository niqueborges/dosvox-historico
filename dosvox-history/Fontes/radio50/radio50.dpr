{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Programa principal                                  }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{--------------------------------------------------------}

program radio50;

uses
  windows,
  dvcrt,
  dvwin,
  dvamplia,
  sysutils,
  dvinet,
  rdProces,
  rdvars,
  rdmsg,
  rdBass,
  rdFFPlay;

{--------------------------------------------------------}
{                     fecha o programa                   }
{--------------------------------------------------------}

procedure termina;
begin
    EnableMenuItem(GetSystemMenu(CrtWindow, False), SC_CLOSE, MF_ENABLED);
    checkBreak := true;

    fechaWinsock;
    fimBass;
// Deixa a saída muito lenta, sem necessidade.    delay (1000);

    if sintFalarTudo and (paramCount = 0) then
        mensagem ('RDFIM', 1);   {'Fim do Radio50.'}
    sintfim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                    Inicializa                          }
{--------------------------------------------------------}

procedure inicializa;
var ambiente: string;
    salva: integer;
begin
    clrscr;
    setwindowtitle('Radio50');
    ambiente := sintambiente('RADIO50', 'DIRRADIO50');
    if ambiente = '' then
        ambiente := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\radio50';
    sintinic (0, ambiente);

    salva := amplFator;
    amplFim;
    amplInic(26-salva, salva);

    cabecalho (paramCount = 0);   // fala ou não a apresentação

    if not inicBass then
        begin
            mensagem ('RDEIBASS', 2);  {'Erro ao inicializar a biblioteca BASS.DLL'}
            termina;
        end;

    if not abrewinsock then
        mensagem ('RDNAOCON', 1);  {'Atenção: seu computador não está conectado à internet.'}

    arqIndice := sintAmbiente('RADIO50', 'DIRINDICE');
    if arqIndice = '' then
        arqIndice := sintDirAmbiente + '\radio50.ini';

    EnableMenuItem(GetSystemMenu(CrtWindow, False), SC_CLOSE, MF_DISABLED);
    checkBreak := false;
end;

{--------------------------------------------------------}
{                   programa principal                   }
{--------------------------------------------------------}

begin
    inicializa;
    if paramCount = 0 then
        processa
    else
    if paramCount = 2 then
        tocaRadioExterna (paramStr(2), paramStr(2))
    else
        tocaRadioBass (paramStr(1), paramStr(1));

    termina;
end.
