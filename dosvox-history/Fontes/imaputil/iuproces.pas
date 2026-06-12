{--------------------------------------------------------}
{                                                        }
{    Programa de acesso rápido usando imap               }
{                                                        }
{    Módulo de interação                                 }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em abril/2013                                       }
{                                                        }
{--------------------------------------------------------}

unit iuproces;

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
    iurede,
    iufolhe,
    iupastas,
    iuvars,
    iumsg;

function pedeDadosParaLogin (noInicio: boolean): boolean;
procedure processa;

implementation

{--------------------------------------------------------}
{ abre a comunicação com o imap server                   }
{--------------------------------------------------------}

function login (conta, senha: string): boolean;
begin
    result := false;
    pastaAtual := 'INBOX';

    if execComando ('login '+ conta+' '+ senha) then
        begin
            if sintFalarTudo then mensagem ('IULOGIOK', 1) {'Login bem sucedido.'}
            else writeln (pegaTextoMensagem('IULOGIOK')); {'Login bem sucedido.'}
            select (pastaAtual, true);
            result := true;
        end
    else
        mensagem ('IUERLOGI', 1); {'Erro no processamento da conta ou senha.'}
end;

{--------------------------------------------------------}
{ fecha a comunicação com o imap server                  }
{--------------------------------------------------------}

procedure logout;
begin
    execComando('close');
    execComando('logout');
end;

{--------------------------------------------------------}
{ novo login                                             }
{--------------------------------------------------------}

function pedeDadosParaLogin (noInicio: boolean): boolean;
var c: char;
    novoServidor: string;
begin
    result := false;

    if noInicio and (paramCount >= 1) then
        servidor := paramStr(1)
    else
        begin
            mensagem ('IUINFNOM', 1);   {'Informe o nome do servidor imap de correio:'}
            novoServidor := '';
            c := sintEdita(novoServidor, wherex, wherey, 80, true);
            writeln (novoServidor);
            if (c <> ESC) and (novoServidor = '') then
                begin
                    gotoxy (1, wherey-1);
                    novoServidor := sintAmbiente ('IMAPUTIL', 'SERVIDOR', sintAmbiente ('CARTAVOX', 'SERVIDORIMAP'));
                    sintWriteln (novoServidor);
                end;

            if novoServidor = '' then
                exit;
            servidor := novoServidor;
        end;

    c := 'S';
    if noInicio and (paramCount >= 2) then
        usaSSL := paramStr(2) = '993'
    else
        begin
            mensagem ('IUUSASEG', 0);   {'Servidor usa segurança? '}
                c := sintreadkey;
            if c = ENTER then
                begin
                    c := copy (sintAmbiente ('IMAPUTIL', 'USASSL', sintAmbiente('CARTAVOX', 'IMAPUSASSL')) + 'S', 1, 1)[1];
                    sintCarac(c);
                end;
            if c = ESC then
                exit;
            writeln (c);
            usassl := (upcase(c) <> 'N');
        end;

    if noInicio and (paramCount >= 3) then
        conta := paramStr(3)
    else
        begin
            mensagem ('IUCONTA', 1);   {'Qual a conta? '}
            sintreadln (conta);
            if conta = '' then
                begin
                    conta := sintAmbiente ('IMAPUTIL', 'CONTA', sintAmbiente('CARTAVOX', 'CONTAUSUARIO'));
                    gotoxy (1, wherey-1);
                    sintWriteln (conta);
                end;

            if conta = '' then
                begin
                    mensagem ('IUDESIST', 1);  {'Desistiu'}
                    exit;
                end;
        end;

    if noInicio and (paramCount >= 4) then
        senha := paramStr(4)
    else
        begin
            mensagem ('IUSENHA', 0);   {'Qual a senha? '}
            sintSenha(senha);
            if senha = '' then
                begin
                    mensagem ('IUDESIST', 1);  {'Desistiu'}
                    exit;
                end;
        end;

    if noInicio and (paramCount >= 5) then
        prefixoImap := paramStr(5)
    else
        prefixoImap := copy (servidor, 1, pos('.',servidor)-1);

    sintGravaAmbiente ('IMAPUTIL', 'SERVIDOR', servidor);
    sintGravaAmbiente ('IMAPUTIL', 'USASSL', c+'');
    sintGravaAmbiente ('IMAPUTIL', 'CONTA', conta);

    result := true;
end;

{--------------------------------------------------------}
{ sai do servidor e entra em outro                       ?
{--------------------------------------------------------}

procedure novoLogin;
begin
    if pedeDadosParaLogin (false) then
        begin
            logout;
            if conecta then
                login (conta, senha);
        end;
end;

{--------------------------------------------------------}
{ informa as opções disponíveis                          }
{--------------------------------------------------------}

procedure ajuda;
begin
    writeln;
    mensagem ('IUOPCAO',  1);   {'As opções são:'}
    mensagem ('IUSELPAS', 1);   {'P - escolher pasta'}
    mensagem ('IUCRIA',   1);   {'C - criar pasta'}
    mensagem ('IUFOLPAS', 1);   {'F - folhear pasta'}
    mensagem ('IUAPAGP', 1);    {'A - apagar pasta'}
    mensagem ('IURENPAS', 1);   {'N - renomear pasta'}
    mensagem ('IUINFOP',  1);   {'I - informa pasta atual'}
    mensagem ('IUNOVLOG', 1 );  {'L - novo login'}
    mensagem ('IUOP_ESC', 2);   {'ESC - Cancelar'}
    readkey;
    limpaBufTec;
end;

{--------------------------------------------------------}
{ seleciona interativamente a opção
{--------------------------------------------------------}

procedure menuAdiciona (cod: string);
begin
    popupMenuAdiciona (cod, pegaTextoMensagem(cod));
end;

function selSetasOpcao: char;
var n: integer;
const
    opmenu: string = 'PCFANIL'+#$1b;
begin
    garanteEspacoTela (8);
    popupMenuCria(wherex, wherey, 50, 8, RED);
    MenuAdiciona ('IUSELPAS');  {'P - escolher pasta'}
    MenuAdiciona ('IUCRIA');    {'C - criar pasta'}
    MenuAdiciona ('IUFOLPAS');  {'F - folhear pasta'}
    MenuAdiciona ('IUAPAGP');   {'A - apagar pasta'}
    MenuAdiciona ('IURENPAS');  {'N - renomear pasta'}
    MenuAdiciona ('IUINFOP');   {'I - informa pasta atual'}
    MenuAdiciona ('IUNOVLOG');  {'L - novo login'}
    MenuAdiciona ('IUOP_ESC');  {'ESC - Cancelar'}

    n := popupMenuSeleciona;
    if (n < 1) then
        result := BS
    else
        result := opmenu[n];
end;

{--------------------------------------------------------}
{       loop de processamento
{--------------------------------------------------------}

function processaFuncao (c1, c2: char): boolean;
label processa;
begin
    result := true;

processa:
    case upcase(c1) of
        'P',
        'S': escolherPasta;
        'C': criarPasta;
        'A': apagarPasta;
        'N': renomearPasta;
        ENTER:;
        'F': folheiacartas;
        'I': sintetiza (pastaAtual);
        'L': novoLogin;
        'D': begin debug := not debug; if debug then sintbip else sintclek; end;
         BS: ;

        #0: case c2 of
                F1: ajuda;
                HOME: sintetiza (versao);
                BAIX,
                F9:  begin
                         c1 := selSetasOpcao;
                         goto processa;
                     end;
             else
                 sintbip;
             end;

        ESC: begin
                 result := false;
             end;
    else
        mensagem ('IUNAOSEI', 1);  {'Não sei fazer isso não'}

    end;
end;

{--------------------------------------------------------}
{ loop de processamento de opções                        }
{--------------------------------------------------------}

procedure processa;
var c1, c2: char;
begin
    clrScr;
    pastaAtual := 'INBOX';
    writeln ('Imaputil: ' + servidor);
    writeln;

    login (conta, senha);

    repeat
        clrScr;
        writeln ('Imaputil: ' + servidor + ' - ' + pastaAtual);
        writeln;
        write (pegaTextoMensagem('IUOPPAST'));  {'Qual a opção de pasta: '}
        if not ((c1 = #0) and (c2 = HOME)) then
            if sintFalarTudo then mensagem ('IUOPPAST', -1)  {'Qual a opção de pasta: '}
            else mensagem ('IUOPC', -1);  {'Opção'}
        sintLeTecla (c1, c2);
        writeln;
    until not processaFuncao (c1, c2);

    logout;
end;

end.
