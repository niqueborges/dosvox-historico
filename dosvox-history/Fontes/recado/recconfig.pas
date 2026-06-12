{--------------------------------------------------------}
{                                                        }
{    Programa de envio e recepção de recados             }
{                                                        }
{    Módulo de configuração                              }
{                                                        }
{    Autor: José Antonio Borges                          }
{                                                        }
{    Em novembro/2014                                    }
{                                                        }
{--------------------------------------------------------}

unit recconfig;

interface
uses
    windows, dvcrt, dvwin, dvform, uaudio, recvars, recmsg, sysutils, synacode;

procedure configurar;
procedure pegaConfig (onde: string);

implementation

const
    bufsize = 1024;
    samplesPerSecond = 11025;

var
    buf: array [0..BUFSIZE-1] of byte;
    nread: integer;

{--------------------------------------------------------}

function calculateVolume: integer;
var i, max: integer;
    sample: byte;
begin
    max := 0;
    for i := 0 to nread-1 do
        begin
            sample := abs (buf[i]-128);
            if max < sample then max := sample;
        end;
    result := max;
end;

{--------------------------------------------------------}

procedure showVolume (v: integer);
var i: integer;
    s: string[64];
begin
    setLength (s, 64);
    for i := 1 to v div 2 do
        s[i] := '@';
    for i := v div 2 + 1 to 64 do
        s[i] := '.';
    write (s, #$0d);
end;

{--------------------------------------------------------}

function calculateMaxVolume (maxTime: integer): integer;
var status, v, t, max: integer;
begin
    status := initWaveRecording (samplesPerSecond, 8, 1, sizeof (buf));
    if status <> 0 then
        begin
            mensagem ('RCPROBLM', 2); {'Problemas com o microfone, código ':}
            sintWriteint (status);
            writeln;
            readln;
            result := -99999;
            exit;
        end;

    showVolume (0);
    max := 0;
    for t := 1 to round (maxTime * samplesPerSecond / bufsize) do
        begin
            nread := getWaveBuffer (@buf);
            v := calculateVolume;
            showVolume (v);
            if max < v then max := v;
        end;

    terminateWaveRecording;
    result := max;
end;

{--------------------------------------------------------}

procedure medirAudio;
var
    volume: integer;
begin
    writeln;
    mensagem ('RCMEDVOL', 2);   {'Medindo o volume do áudio gravado'}
    mensagem ('RCFALE', 2);     {'Fale uma frase longa ao microfone'}

    while sintFalando do waitMessage;

    volume := calculateMaxVolume (10);
    if volume = 10000 then
        exit;

    textColor (yellow);
    showVolume (volume);
    writeln;
    writeln;

    mensagem ('RCVOLUME', 0);   {'Volume: '}
    sintWriteInt (trunc(volume * 100 / 128));

    mensagem ('RCPORCEN', 1);  {' por cento.'}
    textColor (lightGray);
    if volume < 30  then
        mensagem ('RCMUIBAI', 1)     {'Está muito baixo'}
    else
    if volume > 126 then
        mensagem ('RCMUIALT', 1);    {'Está estourando.'}

    while sintFalando do waitMessage;
    delay (2000);

    end;

{-------------------------------------------------------------}

procedure pegaConfig (onde: string);
var s: string;
    erro: integer;
begin
    hostSMTP      := sintAmbiente (onde, 'SERVIDORSMTP');
    hostPOP3      := sintAmbiente (onde, 'SERVIDORPOP3');

    nomeUsuario   := sintAmbiente (onde, 'NOMEUSUARIO');
    enderUsuario  := sintAmbiente (onde, 'ENDERUSUARIO');
    contaUsuario  := sintAmbiente (onde, 'CONTAUSUARIO');
    senhaUsuario := '';
    s := sintAmbiente (onde, 'SCCV');
    if  trim(s) <> '' then
        senhaUsuario := DecodeBase64 (s);

    pop3UsaSSL   := (sintAmbiente (onde, 'USASSL')       + ' ')[1] = 'S';
    smtpComSenha := (sintAmbiente (onde, 'SMTPCOMSENHA') + ' ')[1] = 'S';
    smtpComSSL   := (sintAmbiente (onde, 'SMTPCOMSSL')   + ' ')[1] = 'S';
    smtpComTLS   := (sintAmbiente (onde, 'SMTPCOMTLS')   + ' ')[1] = 'S';

    val (sintAmbiente (onde, 'PORTAPOP3'), portaPOP3, erro);
    if erro <> 0 then portaPOP3 := 110;
    val (sintAmbiente (onde, 'PORTASMTP'), portaSMTP, erro);
    if erro <> 0 then portaSMTP := 25;

    dirRecados := sintAmbiente (onde, 'DIRRECADOS');
    if dirRecados = '' then
        dirRecados := 'c:\winvox\recados';
end;

{--------------------------------------------------------}

procedure guardaConfig;

    procedure writeProfileString (chave, valor: string);
    begin
        sintGravaAmbiente ('RECADO', chave, valor);
    end;

    procedure writeProfileInt (chave: string; valor: integer);
    var s: string;
    begin
        s := intToStr(valor);
        sintGravaAmbiente ('RECADO', chave, s);
    end;

    procedure writeProfileBool (chave: string; valor: boolean);
    begin
        if valor then
            sintGravaAmbiente ('RECADO', chave, 'SIM')
        else
            sintGravaAmbiente ('RECADO', chave, 'NÃO');
    end;

begin

    writeProfileString('NOMEUSUARIO',  nomeUsuario);
    writeProfileString('ENDERUSUARIO', enderUsuario);
    writeProfileString('CONTAUSUARIO', contaUsuario);
    writeProfileString('SCCV',         encodeBase64(senhaUsuario));

    writeProfileString('SERVIDORPOP3', hostPOP3);
    writeProfileInt   ('PORTAPOP3',    portaPOP3);
    writeProfileBool  ('USASSL',       pop3UsaSSL);

    writeProfileString('SERVIDORSMTP', hostSMTP);
    writeProfileInt   ('PORTASMTP',    portaSMTP);
    writeProfileBool  ('SMTPCOMSENHA', smtpComSenha);
    writeProfileBool  ('SMTPCOMSSL',   smtpComSSL);
    writeProfileBool  ('SMTPCOMTLS',   smtpComTLS);

    writeProfileString('DIRRECADOS',   dirRecados);

    limpaBufTec;
    writeln;
    mensagem ('RCFIMCNF', 2);   {'Fim da configuração'}
end;

{--------------------------------------------------------}

procedure configurarUsuario;
var c: char;
    salva: integer;
begin
    writeln;
    mensagem ('RCPGCART', 0);  {'Pega a configuração atual do cartavox? '}
    c := upcase(popupMenuPorLetra ('SN'));
    if c = ESC then
        begin
            mensagem ('RCDESIST', 1);   {'Desistiu'}
            exit;
        end;

    if c = 'S' then pegaConfig ('CARTAVOX')
               else pegaConfig ('RECADO');

    formCria;
    formCampo('RCUSUARI', pegaTextoMensagem('RCUSUARI'), nomeUsuario,  40);
    formCampo('RCENDUSU', pegaTextoMensagem('RCENDUSU'), enderUsuario, 40);
    formCampo('RCCONTA',  pegaTextoMensagem('RCCONTA'),  contaUsuario, 40);

    formCampo    ('RCHPOP3',  pegaTextoMensagem('RCHPOP3'),  hostPOP3,  40);
    formCampoInt ('RCPORPOP', pegaTextoMensagem('RCPORPOP'), portaPOP3);
    formCampoBool('RCPOPSSL', pegaTextoMensagem('RCPOPSSL'), pop3UsaSSL);

    formCampo    ('RCHSMTP',   pegaTextoMensagem('RCHSMTP'),   hostSMTP,  40);
    formCampoInt ('RCPORSMTP', pegaTextoMensagem('RCPORSMTP'), portaSMTP);
    formCampoBool('RCSMTPSEN', pegaTextoMensagem('RCSMTPSEN'), SMTPComsenha);
    formCampoBool('RCSMTPSSL', pegaTextoMensagem('RCSMTPSSL'), smtpComSSL);
    formCampoBool('RCSMTPTLS', pegaTextoMensagem('RCSMTPTLS'), SMTPComTLS);

    formCampo    ('RCDIRREC',  pegaTextoMensagem('RCDIRREC'),  dirRecados, 80);

    formEdita(true);

    mensagem ('RCINFSEN', 0);   {'Informe a senha: '}
    salva := textAttr;
    textBackground (textAttr and $f);
    readln (senhaUsuario);
    textAttr := salva;

    guardaConfig;
end;

{--------------------------------------------------------}

procedure ajudaFolheamento;
begin
    limpaBaixo;
    writeln;
    mensagem ('RCOPSAO', 2);  {'As opções são:'}
    mensagem ('RCCF_C', 1);   {'C - Configurar usuário'}
    mensagem ('RCCF_M', 1);   {'M - Medir o volume do áudio de gravação'}
end;

{--------------------------------------------------------}

function selSetasOpcao: char;
var n: integer;
const
    opmenu: string = 'CM' + #$1b;
begin
    popupMenuCria(wherex, wherey, 40, 4, RED);
    MenuAdiciona ('RCCF_C');   {'C - configurar usuário'^}
    MenuAdiciona ('RCCF_M');   {'M - Medir o volume do áudio de gravação'}
    MenuAdiciona ('RCOP_ESC'); {'ESC - terminar'}

    n := popupMenuSeleciona;
    if (n < 1) then
        result := #$0
    else
        result := opmenu[n];
end;

{-------------------------------------------------------------}

procedure configurar;
var c, c2: char;
label deNovo;
begin
    titulo (true);
deNovo:
    gotoxy (1, 5);
    textBackground (MAGENTA);
    mensagem ('RCOPCCNF', 0);   {'Qual a opção de configurações? '}
    textBackground (BLACK);
    clreol;
    sintLeTecla (c, c2);

    if c = #$0 then
        case c2 of
                F1:  begin
                        ajudaFolheamento;
                        c := ' ';
                     end;
                CIMA, BAIX, F9:
                     begin
                         c := selSetasOpcao;
                         write (c);
                         if c = #0 then c := ESC;
                     end;
            end;

        writeln;
        limpaBaixo;
        if c in ['a'..'z'] then
            c := upcase(c);
        case c of
            'C': configurarUsuario;
            'M': medirAudio;
            ESC: ;
        else
            mensagem ('RCOPINV', 1);   {'Opção inválida, F1 ajuda.'}
            goto deNovo;
        end;
end;

end.



