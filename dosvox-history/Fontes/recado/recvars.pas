{--------------------------------------------------------}
{                                                        }
{    Programa de envio e recepção de recados             }
{                                                        }
{    Módulo de variáveis                                 }
{                                                        }
{    Autor: José Antonio Borges                          }
{                                                        }
{    Em novembro/2014                                    }
{                                                        }
{--------------------------------------------------------}

unit recvars;

interface

const
    versao = '1.1';

var
    debug: boolean;

    nomeUsuario : shortString;
    enderUsuario: shortString;
    contaUsuario: shortString;
    senhaUsuario: shortString;

    hostSMTP    : shortString;
    hostPOP3    : shortString;

    portaPOP3 : integer;
    pop3UsaSSL: boolean;

    portaSMTP   : integer;
    smtpComSSL  : boolean;
    smtpComSenha: boolean;
    smtpComTLS  : boolean;

    dirRecados: shortString;
    tempoMonitoracao: integer;

    sock: integer;

implementation

end.
