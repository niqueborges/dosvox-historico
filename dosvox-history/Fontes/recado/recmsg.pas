{--------------------------------------------------------}
{                                                        }
{    Programa de envio e recepção de recados             }
{                                                        }
{    Módulo de mensagens                                 }
{                                                        }
{    Autor: José Antonio Borges                          }
{                                                        }
{    Em novembro/2014                                    }
{                                                        }
{--------------------------------------------------------}

unit recmsg;

interface
uses
    dvcrt, dvWin, dvForm, recvars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure menuAdiciona (cod: string);
procedure limpaBaixo;
procedure titulo (falandoNome: boolean);
procedure naoImplem;

implementation

{--------------------------------------------------------}
{       descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'RCINIC' then
        s := 'Recado Vox - versão '
    else
    if nomeArq = 'RCCNFFIM' then
        s := 'Confirma fim? '
    else
    if nomeArq = 'RCFIM' then
        s := 'Fim do Recado Vox'
    else

    if nomeArq = 'RCOPCAO' then
        s := 'Opção de recado: '
    else
    if nomeArq = 'RCOPINV' then
        s := 'Opção inválida, F1 ajuda.'
    else

    if nomeArq = 'RCOK' then
        s := 'Ok'
    else
    if nomeArq = 'RCAPTENT' then
        s := 'Aperte enter...'
    else
    if nomeArq = 'RCDESIST' then
        s := 'Desistiu...'
    else

    if nomeArq = 'RCOPSAO' then
        s := 'As opções são:'
    else

    if nomeArq = 'RCOP_R' then
        s := 'R - enviar um recado falado'
    else
    if nomeArq = 'RCOP_T' then
        s := 'T - enviar um recado textual'
    else
    if nomeArq = 'RCOP_F' then
        s := 'F - folhear recados'
    else
    if nomeArq = 'RCOP_M' then
        s := 'M - monitorar recados'
    else
    if nomeArq = 'RCOP_Q' then
        s := 'Q - mostra quantos recados'
    else
    if nomeArq = 'RCOP_C' then
        s := 'C - configurações'
    else
    if nomeArq = 'RCOP_ESC' then
        s := 'ESC - terminar'
    else

    if nomeArq = 'RCUSUATU' then
        s := 'Usuário atual: '
    else
    if nomeArq = 'RCDIGTXT' then
        s := 'Digite o texto a enviar'
    else
    if nomeArq = 'RCRESNDN' then
        s := 'Respondendo a '
    else
    if nomeArq = 'RCENVMSG' then
        s := 'Enviando mensagem...'
    else
    if nomeArq = 'RCMSGENV' then
        s := 'Mensagem enviada.'
    else
    if nomeArq = 'RCMSNENV' then
        s := 'Mensagem não foi enviada.'
    else
    if nomeArq = 'RCSOLIC' then
        s := 'Solicitando... '
    else
    if nomeArq = 'RCQUERDS' then
        s := 'Quer mesmo destruir esta mensagem? '
    else

    if nomeArq = 'RCOPCCNF' then
        s := 'Qual a opção de configurações? '
    else
    if nomeArq = 'RCCF_C' then
       s := 'C - configurar usuário'
    else
    if nomeArq = 'RCCF_M' then
       s := 'M - Medir o volume do áudio de gravação'
    else

    if nomeArq = 'RCMEDVOL' then
        s := 'Medindo o volume do áudio gravado.'
    else
    if nomeArq = 'RCFALE' then
        s := 'Fale uma frase longa ao microfone.'
    else
    if nomeArq = 'RCVOLUME' then
        s := 'Volume: '
    else
    if nomeArq = 'RCPORCEN' then
        s := ' por cento.'
    else
    if nomeArq = 'RCMUIBAI' then
        s := 'Está muito baixo.'
    else
    if nomeArq = 'RCMUIALT' then
        s := 'Está estourando.'

    else
    if nomeArq = 'RCERRCOM' then
        s := 'Não consegui ativar o sistema de comunicação do micro.'

    else
    if nomeArq = 'RCPGCART' then
        s := 'Pega a configuração atual do cartavox? '
    else
    if nomeArq = 'RCUSUARI' then
        s := 'Nome do usuário'
    else
    if nomeArq = 'RCENDUSU' then
        s := 'E-mail'
    else
    if nomeArq = 'RCCONTA' then
        s := 'Conta no servidor'
    else
    if nomeArq = 'RCHPOP3' then
        s := 'Servidor POP3'
    else
    if nomeArq = 'RCPORPOP' then
        s := 'Porta POP3'
    else
    if nomeArq = 'RCPOPSSL' then
        s := 'POP3 com segurança?'
    else
    if nomeArq = 'RCHSMTP' then
        s := 'Servidor SMTP'
    else
    if nomeArq = 'RCPORSMTP' then
        s := 'Porta SMTP'
    else
    if nomeArq = 'RCSMTPSEN' then
        s := 'SMTP utiliza senha?'
    else
    if nomeArq = 'RCSMTPSSL' then
        s := 'SMTP com segurança?'
    else
    if nomeArq = 'RCSMTPTLS' then
        s := 'SMTP com TLS?'
    else
    if nomeArq = 'RCDIRREC' then
        s := 'Diretório de recados'

    else
    if nomeArq = 'RCINFSEN' then
        s := 'Informe a senha: '
    else
    if nomeArq = 'RCFIMCNF' then
        s := 'Fim da configuração'

    else
    if nomeArq = 'RCINFDST' then
       s := 'Informe o email do destinatário ou use as setas:'
    else
    if nomeArq = 'RCFIMESC' then
        s := 'Ao final tecle ESC'
    else
    if nomeArq = 'RCCNFENV' then
        s := 'Confirma envio? '
    else
    if nomeArq = 'RCENVIAN' then
        s := 'Enviando...'
    else
    if nomeArq = 'RCENVIAD' then
        s := 'Recado enviado.'
    else
    if nomeArq = 'RCNENVIA' then
        s := 'Recado não foi enviado.'

    else
    if nomeArq = 'RCERRINT' then
        s := 'Internet não responde'
    else
    if nomeArq = 'RCERRCON' then
        s := 'Erro de conexão com servidor'
    else
    if nomeArq = 'RCERRLGN' then
        s := 'Erro no login com o servidor'

    else
    if nomeArq = 'RCENTINI' then
        s := 'Aperte Enter para gravar, Enter de novo termina.'
    else
    if nomeArq = 'RCGRVCAN' then
        s := 'Gravação cancelada.'
    else
    if nomeArq = 'RCPRBMP3' then
        s := 'Problema ao converter para MP3, código: '
    else
    if nomeArq = 'RCESCUTA' then
        s := 'Quer escutar o recado? '
    else
    if nomeArq = 'RCAGRTXT' then
        s := 'Deseja agregar uma anotação escrita? '
    else
    if nomeArq = 'CTSRVNGO' then
        s := 'Servidor não gostou dessa conexão, ele mandou esta mensagem:'

    else
    if nomeArq = 'RCMONIT' then
        s := 'Monitorando...'
    else
    if nomeArq = 'RCDIRNAO' then
        s := 'Diretório de recados não está configurado ou não existe.'
    else
    if nomeArq = 'RCSRVNAO' then
        s := 'Servidor de recados não está operacional'
    else
    if nomeArq = 'RCERRPOP' then
        s := 'Problemas no servidor, veja mensagem:'

    else
    if nomeArq = 'RCERRCNT' then
        s := 'Erro ao fazer login na sua conta.'

    else
    if nomeArq = 'RCEXISTM' then
        s := 'Existem:'
    else
    if nomeArq = 'RCNAOLID' then
        s := ' recados não lidos, '
    else
    if nomeArq = 'RCPENDEN' then
        s := ' pendentes, '
    else
    if nomeArq = 'RCENVIDO' then
        s := ' enviados, '
    else
    if nomeArq = 'RCLIDOS' then
        s := ' lidos, '
    else
    if nomeArq = 'RCMSGTOT' then
        s := ' no total.'

    else
    if nomeArq = 'RCOPFOL' then
        s := 'O que deseja folhear? '
    else
    if nomeArq = 'RCFOLTOD' then
        s := 'T - folhear Todos'
    else
    if nomeArq = 'RCFOLNAO' then
        s := 'N - folhear Não lidas'
    else
    if nomeArq = 'RCFOLIND' then
        s := 'I - folhear Individualmente'
    else
    if nomeArq = 'RCFOLENV' then
        s := 'E - folhear recados Enviados'
    else
    if nomeArq = 'RCFOLPEN' then
        s := 'P - folhear recados Pendentes'

    else
    if nomeArq = 'RCFLEREC' then
        s := 'L - le Recado'
    else
    if nomeArq = 'RCFTEXTO' then
        s := 'T - editora o Texto do recado'
    else
    if nomeArq = 'RCFAPAGA' then
        s := 'A - Apaga o recado'
    else
    if nomeArq = 'RCRESPON' then
        s := 'R - Responde ao recado'
    else
    if nomeArq = 'RCSALVAS' then
        s := 'S - Salva o som do recado'

    else
    if nomeArq = 'RCFOLHEN' then
        s := 'Folheando...'
    else
    if nomeArq = 'RCCFOLHE' then
        s := 'Continue folheando...'

    else
    if nomeArq = 'RCCNFREM' then
        s := 'Confirma remoção? '
    else
    if nomeArq = 'RCREMOVI' then
        s := 'Arquivo removido: '
    else
    if nomeArq = 'RCNREMOV' then
        s := 'Arquivo não removido: '
    else
    if nomeArq = 'RCFEDESC' then
        s := 'Ao final da edição, tecle ESC'
    else
    if nomeArq = 'RCCNTFOL' then
        s := 'Continue folheando...'

    else
    if nomeArq = 'RCDEBUGL' then
        s := 'Debug ligado'
    else
    if nomeArq = 'RCDEBUGD' then
        s := 'Debug desligado'

    else
    if nomeArq = 'RCFALGRV' then
        s := 'Vai responder como fala gravada? '
    else
    if nomeArq = 'RCRESPA' then
        s := 'Respondendo ao recado de'
    else
    if nomeArq = 'RCSEMAUD' then
        s := 'O recado original não continha áudio.'
    else
    if nomeArq = 'RCQNOMEC' then
        s := 'Informe o nome do arquivo MP3 destino:'
    else
    if nomeArq = 'RCERRGRV' then
        s := 'Erro de gravação de arquivo.'

    else
    if nomeArq = 'RCINFNOM' then
        s := 'Informe algumas letras do nome ou e-mail'

    else
    if nomeArq = 'RCENVPEN' then
        s := 'Tentando enviar recados pendentes'
    else
    if nomeArq = 'RCHAPEND' then
        s := ' recados pendentes para envio'

    else
    if nomeArq = 'RCNAOIMP' then
        s := 'Não foi implementado ainda.'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{       dá uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{       facilitador para adicionar opção em menu
{--------------------------------------------------------}

procedure menuAdiciona (cod: string);
begin
    popupMenuAdiciona (cod, pegaTextoMensagem(cod));
end;

{--------------------------------------------------------}
{              mensagem de não implementado
{--------------------------------------------------------}

procedure naoImplem;
begin
    mensagem ('RCNAOIMP', 1);  // 'Não foi implementado ainda'
    mensagem ('RCAPTENT', 0);  // 'Aperte enter para continuar'
    readln;
end;

{--------------------------------------------------------}
{                  produz o título
{--------------------------------------------------------}

procedure titulo (falandoNome: boolean);
begin
    clrscr;
    textBackground (BLUE);
    write (pegaTextoMensagem ('RCINIC'));  {'Recado Vox - versão '}
    writeln (versao);
    writeln;
    textBackground (BLACK);
    if falandoNome then
        begin
            mensagem ('RCUSUATU', 0);
            sintWriteln (nomeUsuario);
        end
    else
        writeln (pegaTextoMensagem ('RCUSUATU') + nomeUsuario);
    limpabuftec;
    writeln;
end;

{--------------------------------------------------------}
{               limpa tela daqui para baixo
{--------------------------------------------------------}

procedure limpaBaixo;
var sx, sy, y: integer;
begin
    sx := wherex;
    sy := wherey;
    clreol;
    for y := wherey to 25 do
        begin
            gotoxy (1, y);
            clreol;
        end;
    gotoxy (sx, sy);
end;

end.

