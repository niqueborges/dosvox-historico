{--------------------------------------------------------}
{                                                        }
{    Programa de envio e recepção de recados             }
{                                                        }
{    Programa principal                                  }
{                                                        }
{    Autor: José Antonio Borges                          }
{                                                        }
{    Em novembro/2014                                    }
{                                                        }
{--------------------------------------------------------}

program recado;

uses
  dvcrt,
  dvwin,
  dvform,
  sysUtils,
  winsock,
  dvinet,
  recvars,
  recmsg,
  recconfig,
  recdraw,
  recenvia,
  recfolhe,
  recsmtp,
  recmime64,
  recmonit;

{--------------------------------------------------------}

procedure finaliza;
var pendentes: integer;
begin
    if contabiliza ('CPR') > 0 then
        begin
            mensagem ('RCENVPEN', 2); {'Tentando enviar recados pendentes'}
            enviaPendentes;
        end;
    fechaWinSock;

    pendentes := contabiliza ('CPR');
    if pendentes > 0 then
        begin
            sintWriteint (pendentes);
            mensagem ('RCHAPEND', 0);  {' recados pendentes para envio'}
            writeln;
        end;

    gotoxy (1, 25);
    mensagem ('RCFIM', 0);  {'Fim do Recado Vox'}
    delay (2000);
    while sintFalando do;
    doneWinCrt;
end;

{--------------------------------------------------------}

procedure inicializa;
var ambiente: string;
begin
    debug := false;

    ambiente := sintAmbiente ('RECADO', 'DIRRECADO');
    if ambiente = '' then
        ambiente := 'c:\winvox\som\recado';
    sintInic (0, ambiente);

    clrscr;

    setWindowTitle ('Recado Vox - v.' + versao);
    exibeFigura ('recado.jpg', 400, 10);

    textBackground (BLUE);
    mensagem ('RCINIC',0);  {'Recado Vox - versão '}
    sintWriteln (versao);
    writeln;
    textBackground (BLACK);

    if not abreWinSock then
        begin
            mensagem ('RCERRCOM', 1);  {'Não consegui ativar o sistema de comunicação do micro'}
            finaliza;
        end;

    tamRotulosForm := 24;
    tempoMonitoracao := 60000;    { 60 segundos }

    pegaConfig ('RECADO');
    if nomeUsuario = '' then
         nomeUsuario := 'Desconhecido';

    {$i-}  chdir (dirRecados);   {$I+}
    if ioresult <> 0 then
        mensagem ('RCDIRNAO', 2);    {'Diretório de recados não está configurado ou não existe.'}
end;

{--------------------------------------------------------}

procedure ajudaPrincipal;
begin
    limpaBaixo;
    writeln;
    mensagem ('RCOPSAO', 1);   {'As opções são:'}
    mensagem ('RCOP_R', 1);    {'R - enviar um recado falado'}
    mensagem ('RCOP_T', 1);    {'T - enviar um recado textual'}
    mensagem ('RCOP_F', 1);    {'F - folhear recados'}
    mensagem ('RCOP_M', 1);    {'M - monitorar recados'}
    mensagem ('RCOP_Q', 1);    {'Q - mostra quantos recados'}
    mensagem ('RCOP_C', 1);    {'C - configurações'}
    mensagem ('RCOP_ESC', 2);  {'ESC - terminar'}
end;

{--------------------------------------------------------}

function selSetasOpcao: char;
var n: integer;
const
    opmenu: string = 'RTFMQC' + #$1b;
begin
    popupMenuCria(wherex, wherey, 50, length(opmenu), RED);
    MenuAdiciona ('RCOP_R');     {'R - enviar um recado falado'}
    MenuAdiciona ('RCOP_T');     {'T - enviar um recado textual'}
    MenuAdiciona ('RCOP_F');     {'F - folhear recados'}
    MenuAdiciona ('RCOP_M');     {'M - monitorar recados'}
    MenuAdiciona ('RCOP_Q');     {'Q - mostra quantos recados'}
    MenuAdiciona ('RCOP_C');     {'C - configurações'}
    MenuAdiciona ('RCOP_ESC');   {'ESC - terminar'}

    n := popupMenuSeleciona;
    if (n < 1) then
        result := ' '
    else
        result := opmenu[n];
end;

{--------------------------------------------------------}

procedure processa;
var c, c2: char;
    acabou: boolean;
begin
    clrscr;
    setWindowTitle ('Recado Vox ' + nomeUsuario);
    titulo (true);

    acabou := false;
    repeat
        titulo (false);

        sintBip;
        textBackground (BLUE);
        mensagem ('RCOPCAO', 0);   {'Opção de recado: '}
        textBackground (BLACK);
        clreol;
        sintLeTecla (c, c2);
        writeln;
        limpaBaixo;


        if c = #$0 then
            case c2 of
            F1, F9:  begin
                        ajudaPrincipal;
                        c := ' ';
                     end;
                CIMA, BAIX: c := selSetasOpcao;
            end;

        if c = ' ' then
            continue;
        if c in ['a'..'z'] then
            c := upcase(c);

        case c of
            'R': enviarRecadoFalado ('');
            'T': enviarRecadoTextual ('');
            'F': folhearRecados;
            'M': monitorarRecados;
            'Q': mostraQuantosRecados;
            'C': configurar;

            'D': begin
                     debug := not debug;
                     if debug then mensagem ('RCDEBUGL', 2)     {'Debug ligado'}
                              else mensagem ('RCDEBUGD', 2);    {'Debug desligado'}
                 end;

            ESC: begin
                     mensagem ('RCCNFFIM', 0);   {'Confirma fim? '}
                     sintLeTecla (c, c2);
                     writeln;
                     if upcase (c) = 'S' then
                         acabou := true;
                 end;
        else
            mensagem ('RCOPINV', 1);   {'Opção inválida, F1 ajuda.'}
        end;
    until acabou;
    writeln;
end;

{--------------------------------------------------------}

begin
    inicializa;
    processa;
    finaliza;
end.

