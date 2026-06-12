{--------------------------------------------------------}
{    Programa servidor para bate papo via papovox
{    Autor: Antonio Borges
{    Em 16/08/99
{--------------------------------------------------------}

program sitiovox;

uses
    dvwin, dvcrt, windows, sysutils,
    winsock, dvinet,
    svvars, svsNomes, svproc, svmsg, svditado;

procedure finaliza; forward;

var
    arqConf: text;

{--------------------------------------------------------}
{              cria arquivo de configuracao
{--------------------------------------------------------}

function criaArqConfig: boolean;
var c, c2: char;
label erro;
begin
    criaArqConfig := false;

    mensagem ('SVVOUCRI', 0);      {'Vou criar o arquivo '}
    sintWriteln (nomeConf);
    mensagem ('SVPODSER', 0);      {'Pode ser ? '}
    sintLeTecla (c, c2);
    writeln;

    if upcase (c) = 'N' then
         exit;

    assign (arqConf, nomeConf);
    {$I-} rewrite (arqConf);  {$I+}
    if ioresult <> 0 then
         begin
erro:
             mensagem ('SVNAOCRI', 1);   {'Não consegui criar o arquivo de configuração'}
             {$I-} erase (arqConf);  {$I+}
             if ioresult <> 0 then;
             exit;
         end;

    mensagem ('SVPEDNOM', 1);
         {Informe o nome-fantasia deste sítio, por exemplo, Cantinho da mamãe}
    sintReadln (nomeSitio);
    if nomeSitio = '' then
        goto erro;

    mensagem ('SVPEDEND', 1);
        {Informe o endereço de acesso deste sitio, por exemplo, sitio.fulano@servidor.com.br'}
    sintReadln (enderSitio);
    if pos ('@', enderSitio) = 0 then
         goto erro;

    mensagem ('SVMSGINI', 1);
        {Qual a mensagem de boas vindas a dar aos usuários ?}
    sintReadln (msgBoasVindas);

    mensagem ('SVNOMLOG', 1);
        {Nome do arquivo de log ou enter se não quer'}
    sintReadln (nomeArqLog);

    mensagem ('SVINFSEN', 1);
        {Informe a senha do sítio'}
    sintReadln (senha);

    writeln (arqConf, '[SITIOVOX]');
    writeln (arqConf, 'NOME=',nomeSitio);
    writeln (arqConf, 'EMAIL=',enderSitio);
    writeln (arqConf, 'MENSAGEM=',msgBoasVindas);
    writeln (arqConf, 'REGISTRO=',nomeArqLog);
    writeln (arqConf, 'SENHA=',senha);
    writeln (arqConf);
    writeln (arqConf, '[SENHAS]');
    close (arqConf);

    criaArqConfig := true;
end;

{--------------------------------------------------------}
{               rotina de inicialização
{--------------------------------------------------------}

procedure inicializa;
var jan: hwnd;
    i: integer;
    linha: string;
    dir: string;

    procedure leConfig (chave: string; var s: string);
    begin
        s := sintAmbienteArq ('SITIOVOX', chave, '', nomeConf);
    end;

    function valor (var s: string): integer;
    var v: integer;
    begin
        v := 0;
        while (s <> '') and (s[1] = ' ') do
            delete (s, 1, 1);
        while (s <> '') and (s[1] in ['0'..'9']) do
           begin
               v := v * 10 + (ord (s[1]) - ord ('0'));
               delete (s, 1, 1);
           end;
        while (s <> '') and (s[1] = ' ') do
            delete (s, 1, 1);
        valor := v;
    end;

label recria, deNovo;
begin
     jan := findWindow ('dvwincrt', 'SITIOVOX');
     if jan <> 0 then
         begin
             setFocus (jan);
             halt;
         end;

    dir := sintAmbiente ('SITIOVOX', 'DIRSITIOVOX');
    if dir = '' then
        dir := 'c:\winvox\som\sitiovox';
    sintInic (0, dir);

    clrscr;
    setWindowText (crtWindow, 'SITIOVOX');
    delay (200);

    textBackground (BLUE);
    mensagem ('SVINIC', 0);    {'Sítiovox v.'}
    write (versao);
    sintSoletra (versao);
    sintWriteln (' '+ ALFABETA);
    textBackground (BLACK);
    writeln;

    if not abreWinSock then
         begin
             mensagem ('SVWSOCK', 1);   {Acesso a Internet não habilitado}
             readkey;
             sintFim;
             doneWinCrt;
         end;

    linha := sintAmbiente ('SITIOVOX', 'COMCACHORRO');
    comCachorro := (linha <> '') and (upcase(linha[1]) = 'S');

    linha := sintAmbiente ('SITIOVOX', 'OBRIGASENHA');
    senhaObrigatoria := (linha <> '') and (upcase(linha[1]) = 'S');

    if paramcount <> 0 then
        nomeConf := paramstr(1)
    else
        nomeConf := sintAmbiente ('SITIOVOX', 'ARQCONFIG');
        if nomeConf = '' then
            nomeConf := '\winvox\sitiovox.ini';

deNovo:
    assign (arqConf, nomeConf);
    {$I-}  reset (arqConf); {$I+}
    if ioresult <> 0 then
        begin
             mensagem ('SVCNFNAO', 1);    {'Arquivo de configuracao não existe'}
recria:
             if criaArqConfig then
                  goto deNovo
             else
                  begin
                      mensagem ('SVPROCAN', 1);     {'Servidor cancelado'}
                      sintFim;
                      doneWinCrt;
                  end;
        end
    else
        close (arqConf);

    leConfig ('NOME', nomeSitio);
    leConfig ('EMAIL', enderSitio);
    if (nomeSitio = '') or (enderSitio = '') then
        goto recria;

    portaSitio := PORTA_SITIOVOX;     {por enquanto fica fixa}
    leConfig ('MENSAGEM', msgBoasVindas);
    leConfig ('REGISTRO', nomeArqLog);
    leConfig ('SENHA', senha);
    if senha = '' then senha := 'ABRACADABRA';

    textColor (YELLOW);
    sintWriteln (nomeSitio);
    if portaSitio <> PORTA_SITIOVOX then
        writeln (enderSitio, ':', portaSitio)
    else
        writeln (enderSitio);
    writeln (msgBoasVindas);
    writeln (nomeArqLog);
    textColor (LIGHTGRAY);

    if nomeArqLog = '' then
        fazLog := false
    else
        begin
            fazLog := true;
            assign (arqLog, nomeArqLog);
            {$I-}  append (arqLog);  {$I+}
            if ioresult <> 0 then
                 begin
                     {$I-}  rewrite (arqLog);  {$I+}
                     if ioresult <> 0 then
                         begin
                              mensagem ('SVLOGNAO', 1);   {Erro na criação do arquivo de registro de conversação}
                              fazLog := false;
                         end;
                 end;
        end;

    checkBreak := false;
    EnableMenuItem(GetSystemMenu(CrtWindow, False), sc_Close, mf_Disabled);

    registraSitio (enderSitio, nomeSitio, portaSitio);

    ffila := 0;
    rfila := 0;                   { fila de mensagens }
    for i := 0 to MAXMSG-1 do
        new (filaEnviar[i]);

    carregaDitados;
end;

{--------------------------------------------------------}
{               testa se usuario quer terminar
{--------------------------------------------------------}

function testaFim: boolean;
var c, c2: char;
begin
    mensagem ('SVCNFFIM', 0);   {'Confirma fim ? '}
    sintLeTecla (c, c2);
    writeln;
    testaFim :=  upcase (c) = 'S';
end;

{--------------------------------------------------------}
{                        finalização
{--------------------------------------------------------}

procedure finaliza;
begin
    desRegistraSitio (enderSitio, portaSitio);

    mensagem ('SVFIM', 1);     {'Sítio desativado'}

    if fazLog then close (arqlog);

    sintFim;
    fechaWinSock;
    doneWinCrt;
end;

{-------------------------------------------------------------}
{                  informa meu endereço IP
{-------------------------------------------------------------}

procedure informaMeuIp;
var
    HEnt: pHostEnt;
    HName: array [0..100] of char;
    IPAddr: string;
    i: integer;
begin
    if GetHostName(@HName, SizeOf(HName)) = 0 then
        begin
            HEnt := GetHostByName(HName);
            for i := 0 to HEnt^.h_length - 1 do
                 IPaddr := Concat(IPaddr, IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.');
            delete (IPaddr, Length(IPaddr), 1);
            mensagem ('SVENDIP', 0);  {'O endereço IP deste sítio é '}
            sintWriteln (IPaddr + ' ' + strPas (HName));
          end
      else
          sintWriteln ('127.0.0.1');
end;

{--------------------------------------------------------}
{                    programa principal
{--------------------------------------------------------}

begin
    inicializa;
    informaMeuIp;
    if iniciaServidor then
        processa;
    finaliza;
end.
