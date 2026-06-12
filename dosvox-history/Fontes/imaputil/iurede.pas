{--------------------------------------------------------}
{                                                        }
{    Programa de acesso rápido usando imap               }
{                                                        }
{    Módulo de acesso a funções de rede                  }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em abril/2013                                       }
{                                                        }
{--------------------------------------------------------}

unit iurede;

interface

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
    iuvars,
    iumsg;

function conecta: boolean;
function transmiteComando (tag, qualcomando: string): boolean;
function recebeResposta (tag: string): boolean;
function criatag: string;
function execComando (cmd: string): boolean;

implementation

{--------------------------------------------------------}
{ Grava arquivo de debug
{--------------------------------------------------------}

procedure gravarDebug(s: string);
begin
    assignfile (arqdebug, 'arqdebug.txt');
    {$I-}     append(arqDebug); {$I+}
    if ioresult <> 0 then
        rewrite (arqdebug);
    writeln(arqdebug, s);
    closefile(arqDebug);
end;

{--------------------------------------------------------}
{ conecta com o servidor imap e realiza o login          }
{--------------------------------------------------------}

function conecta: boolean;
var s: string;

begin
    result := false;
    if sintFalarTudo then mensagem ('IUTENCON', 1)  {'Tentando estabelecer conexão'}
    else writeln (pegaTextoMensagem('IUTENCON'));  {'Tentando estabelecer conexão'}
    if not abreWinSock then
        begin
            mensagem ('IUCONECTE', 1);  {'Por favor, conecte seu computador à Internet.'}
            exit;
        end;
    if usassl then
        sock := abreConexaossl (servidor, 993)
    else
        sock := abreConexao (servidor, 143);
    if sock <= 0 then
        begin
            mensagem ('IUNAOCON', 1);  {'não consegui conectar com o servidor.'}
            exit;
        end;

    pbuf := inicBufRede (sock);
    result := readlnBufRede (pbuf, s, 5000);
    if not ((result) and (copy(s,1,4) = '* OK')) then
        mensagem ('IUPROBLM', 1);  {'Problemas na comunicação com o servidor.'}
    result := true;
end;

{--------------------------------------------------------}
{ transmite nova tag e comando ao servidor               }
{--------------------------------------------------------}

function transmiteComando (tag, qualcomando: string): boolean;
begin
    if debug then gravarDebug (tag + ' '+ qualcomando);

    result := writelnrede(sock, tag + ' '+ qualcomando);
end;

{--------------------------------------------------------}
{ obtem o texto de resposta gerado pelo servidor         }
{--------------------------------------------------------}

function recebeResposta (tag: string): boolean;
var respfim: boolean;
    s: string;
    ok: boolean;
    i: integer;
    nlinrec: integer;
begin
    result := false;
    respfim := false;
    respserv.clear;
    nlinrec := 0;
    while not respfim do
        begin
            ok := readlnBufRede (pbuf, s, 5000);
            if not ok then
                begin
                    mensagem ('IUCONCAI', 1);  {'Conexão caiu!'}
                    exit;
                end;
            respserv.add(s);
            respfim := copy (s, 1, length(tag)+1) = tag + ' ';

            nlinrec := (nlinrec + 1) mod 1000;
            if nlinrec = 0 then
                if clek then sintclek;
        end;
    result := copy (s, length(tag)+2, 2) = 'OK';

    if debug then
        begin
            gravarDebug ('*************');
            for i := 0 to respserv.count-1 do
                gravarDebug (respserv[i]);
        end;

    limpabuftec;
end;

{--------------------------------------------------------}
{ Cria a próxima tag                                     }
{--------------------------------------------------------}

function criatag: string;
begin
    serial := serial + 1;
    result := 'yvw'+inttostr(serial);
end;

{--------------------------------------------------------}
{ processa um comando                                    }
{--------------------------------------------------------}

function execComando (cmd: string): boolean;
var
    tag: string;
begin
    tag := criatag;
    result := transmiteComando (tag, cmd) and receberesposta(tag);
end;

end.
