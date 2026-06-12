{-------------------------------------------------------------}
{           CartaVox - configurador
{-------------------------------------------------------------}

unit carConf;

interface

uses
    dvcrt,
    dvForm,
    dvWin,
    classes,
    sysUtils,
    windows,
    carDecod,
    carMsg,
    carSMTP,
    carTela,
    carUtil,
    carCopia,
    carAjuda,
    carVars;

procedure configurar;
procedure pegaConfigInicial;
function recuperaConfig(perguntaSeTransmite, diretoNasSetas: boolean): boolean;
procedure recuperaConfigGrupoContas (contaGrupo: string);
procedure mudarParaConfigLixeira (perguntaSeTransmite: boolean);
procedure mudarParaConfigSpam (perguntaSeTransmite: boolean);

implementation

const
    booleanToStr: array [boolean] of string = ('NAO', 'SIM');
    numChavesConta = 34; //Chaves que não são genéricas para todas as contas
    numChaves = 52; //Total de chaves
    tabChaves: array [1..numChaves] of pchar = (
        'SERVIDORSMTP',
        'SMTPCOMSENHA',
        'SMTPCOMSSL',
        'SMTPCOMTLS',
        'PORTASMTP',
        'SERVIDORPOP3',
        'USASSL',
        'PORTAPOP3',
        'SERVIDORIMAP',
        'IMAPUSASSL',
        'PORTAIMAP',
        'ENDERRESPOSTA',
        'ENDERUSUARIO',
        'CONTAUSUARIO',
        'NOMEUSUARIO',
        'DIRRECEBE',
        'DIRENVIA',
        'DIRANEXO',
        'LIMITEAUTOREC',
        'ASSINATURA',
        'APELIDOS',
        'COPIAENVIADAS',
        'ARMAZENASENHA',
        'SCCV',
        'APLICARREGRAS',
        'INSERIRASSINATURA',
        'INSERIRCONFIRMACAOLEITURA',
        'ARQRESPAUT',
        'ASSRESPAUT',
        'SIGRESPAUT',
        'GRUPODECONTAS',
        'TEMPOREMONITORAR',
        'AVISANOVASNOMONITORAR',
        'RECEBERAUTONOMONITORAR',
        'ADICIONAORIGINAL',
        'ANTIGONOMEARQ',
        'AUTOENVIADUPLICADASLIXEIRA',
        'MATARSPAMAUTOMATICAMENTE',
        'BIPANOSPEAKER',
        'CABECALHORESUMIDO',
        'CLEK',
        'DIRLIXEIRA',
        'DIRSPAM',
        'ARQCONFIGS',
        'FALANOMEPRIMEIRO',
        'OPCOESBASICAS',
        'ORDEMINVERSA',
        'ORDENARDATAENVIO',
        'PERGUNTAAOSAIR',
        'PERGUNTAAOSAIRFOLHEAMENTO',
        'PERGUNTARCRIARRESPOSTAAUTOMATICA',
        'DIRPROVEDOR'
    );

var
    v_configuracao, v_senha: string; //Utilizados para voltar a configuração anterior.

{-------------------------------------------------------------}
{       Grava as informações principais para voltar a configuração anterior
{-------------------------------------------------------------}

procedure gravarNomeConfiguracaoParaVoltar;
begin
    if (nomeConfiguracao = 'Lixeira') or (nomeConfiguracao = 'Spam') or (trim(nomeConfiguracao) = '') then exit;
    v_configuracao := nomeConfiguracao;
    v_senha := senhaSalva;
end;

{-------------------------------------------------------------}
{       Volta a última configuração que gravou o nome e a senha.
{-------------------------------------------------------------}

procedure voltarUltimaConfiguracao;
var configuracaoAux, senhaAux: string;
begin
    if v_configuracao <> '' then
        begin
            configuracaoAux := v_configuracao;
            senhaAux := v_senha;
            gravarNomeConfiguracaoParaVoltar;
            if nomeConfiguracao <> configuracaoAux then
                begin
                    if  (nomeConfiguracao <> 'Lixeira') and (nomeConfiguracao <> 'Spam') then
                        transmitirPreparadas; //Pergunta se transmite caso exista
                    sintetiza (configuracaoAux);
                    recuperaConfigGrupoContas (configuracaoAux);
                    if senhaSalva = '' then senhaSalva := senhaAux;
                end
            else sintclek;
        end
    else sintbip;
end;

{-------------------------------------------------------------}
{       Simplifica o nome da function pegaTextoMensagem de carMsg.pas
{-------------------------------------------------------------}

function ms (s: string): string;
begin
    ms := pegaTextoMensagem(s);
end;

{-------------------------------------------------------------}
{       consiste nomes de diretórios e arquivos da configuração
{-------------------------------------------------------------}

procedure consisteDirArq;
var
    erro: boolean;
    c: char;
begin
    erro := false;
    if not existeDir (dirRecebe) then
        begin
            mensagem ('CTERDREC', 1);  {'Diretório de recepção de cartas inexistente'}
            mensagem ('CTPOSCRI', 0);  {'Posso criá-lo? '}
            c := upcase(popupMenuPorLetra ('SN'));
            writeln;
            if c = 'N' then
                erro := true
            else
                begin
                     {$I-}  mkdir (dirRecebe);  {$I+}
                     if ioresult <> 0 then
                         begin
                             erro := true;
                             mensagem ('CTDRNCRI', 2);  {'Diretório de recepção não foi criado.'}
                         end;
                end;
        end;

    if erro then
         mensagem ('CTNESQCR', 0);  {'Não esqueca de criar o diretório antes de receber ou enviar cartas.'}

    erro := false;
    if not existeDir (dirEnvia) then
        begin
            mensagem ('CTERDENV', 1);  {'Diretório para cartas a enviar inexistente'}
            mensagem ('CTPOSCRI', 0);  {'Posso criá-lo? '}
            c := upcase(popupMenuPorLetra ('SN'));
            writeln;
            if c = 'N' then
                erro := true
            else
                begin
                     {$I-}  mkdir (dirEnvia);  {$I+}
                     if ioresult <> 0 then
                         begin
                             erro := true;
                             mensagem ('CTDENCRI', 2);  {'Diretório de envio não foi criado.'}
                         end;
                end;
        end;

    if erro then
         mensagem ('CTNESQCR', 0);  {'Não esqueca de criar o diretório antes de receber ou enviar cartas.'}

    if (nomeAssinatura <> '') and (not fileExists (nomeAssinatura)) then
        mensagem ('CTEDIASS', 1);   {'Arquivo de assinatura não existe, não se esqueça de editá-lo.'}
end;

{-------------------------------------------------------------}
{       configura programa
{-------------------------------------------------------------}

procedure configuraTudo;
var
    contaUsuarioAntigo: string;
    c: char;

label deNovo;

begin
    if  (nomeConfiguracao <> 'Lixeira') and (nomeConfiguracao <> 'Spam') then
        transmitirPreparadas; //Pergunta se transmite caso exista
    gravarNomeConfiguracaoParaVoltar;
    clrscr;
    textBackground (BLUE);
    writeln (CONF_CARTAVOX);   {'CARTAVOX - Configuração'}
    textBackground (BLACK);
    writeln;

    contaUsuarioAntigo := contaUsuario;

    repeat
        formCria;
        formCampo     ('CT_POP3',  ms('CT_POP3'),   hostPOP3, 60);        {'Nome do servidor POP3'}
        formCampoInt  ('CT_PPOP3', ms('CT_PPOP3'),  portaPOP3);           {'Porta POP3'}
        formCampoBool ('CT_SSL',   ms('CT_SSL'),    usaSSL);              {'Usa segurança SSL'}

        formCampo     ('CT_SMTP',  ms('CT_SMTP'),   hostSMTP, 60);        {'Nome do servidor SMTP'}
        formCampoInt  ('CT_PSMTP', ms('CT_PSMTP'),  portaSMTP);           {'Porta SMTP'}
        formCampoBool ('CT_SENHA', ms('CT_SENHA'),  smtpComSenha);        {'SMTP opera com senha'}
        formCampoBool ('CT_SMSSL', ms('CT_SMSSL'),  smtpComSSL);          {'SMTP com segurança SSL'}    //*** Antonio
        formCampoBool ('CT_SMTLS',  ms('CT_SMTLS'), smtpComTLS);          {'SMTP exige segurança TLS'}

        formCampo     ('CT_IMAP',  ms('CT_IMAP'),   hostIMAP, 60);        {'Nome do servidor IMAP'}
        formCampoBool ('CT_IMAPSSL',  ms('CT_IMAPSSL'), IMAPUsaSSL);      {'IMAP exige segurança'}
        formCampoInt  ('CT_PIMAP', ms('CT_PIMAP'),  portaImap);           {'Porta IMAP'}

        formCampo     ('CT_NOME',  ms('CT_NOME'),   nomeUsuario, 60);     {'Nome registrado como'}
        formCampo     ('CT_RESP',  ms('CT_RESP'),   enderResposta, 60);   {'Endereço para resposta'}
        formCampo     ('CT_ENDER', ms('CT_ENDER'),  enderUsuario, 60);    {'Endereço eletrônico'}
        formCampo     ('CT_CONTA', ms('CT_CONTA'),  contaUsuario, 60);    {'Conta no servidor'}
        formCampo     ('CT_DIRRC', ms('CT_DIRRC'),  dirRecebe, 144);       {'Diretório cartas recebidas'}
        formCampo     ('CT_DIREN', ms('CT_DIREN'),  dirEnvia, 144);        {'Diretório cartas a enviar'}
        formCampoInt  ('CT_LIMRC', ms('CT_LIMRC'),  maxTamAuto);          {'Limite carta recebida'}
        formCampo     ('CT_ARQAS', ms('CT_ARQAS'),  nomeAssinatura, 200);  {'Arquivo de assinatura'}
        formCampo     ('CT_ARQAP', ms('CT_ARQAP'),  nomeArqApelidos, 200); {'Arquivo de apelidos'}
        formCampoBool ('CT_GUARD', ms('CT_GUARD'),  guardaEnviadas);      {'Guardar cartas enviadas'}
        formCampoBool ('CT_GSENH', ms('CT_GSENH'),  guardaSenha);         {'Guardar a senha'}
        formCampoBool ('CT_APREG', ms('CT_APREG'),  aplicRegras);         {'Aplicar regras'}
        formCampoBool ('CT_INASS', ms('CT_INASS'),  inserirAssinatura); {'Inserir assinatura'}
        formCampoBool ('CT_INCOR', ms('CT_INCOR'),  inserirConfRec); {'Confirmar recebimento'}
        formCampo     ('CT_DIRAN', ms('CT_DIRAN'),  dirAnexo, 144);        {'Diretório para anexos'}

        c := formEdita (true);
    until c = ESC;

    consisteDirArq;

    sintGravaAmbiente('CARTAVOX', 'SERVIDORIMAP', hostIMAP);
    sintGravaAmbiente('CARTAVOX', 'SERVIDORSMTP', hostSMTP);
    sintGravaAmbiente('CARTAVOX', 'SERVIDORPOP3', hostPOP3);
    sintGravaAmbiente('CARTAVOX', 'NOMEUSUARIO',  nomeUsuario);
    sintGravaAmbiente('CARTAVOX', 'ENDERRESPOSTA', enderResposta);
    sintGravaAmbiente('CARTAVOX', 'ENDERUSUARIO', enderUsuario);
    sintGravaAmbiente('CARTAVOX', 'CONTAUSUARIO', contaUsuario);
    sintGravaAmbiente('CARTAVOX', 'DIRRECEBE',    dirRecebe);
    sintGravaAmbiente('CARTAVOX', 'DIRENVIA',     dirEnvia);
    sintGravaAmbiente('CARTAVOX', 'DIRANEXO',     dirAnexo);
    sintGravaAmbiente('CARTAVOX', 'LIMITEAUTOREC', intToStr (maxTamAuto));
    sintGravaAmbiente('CARTAVOX', 'ASSINATURA',   nomeAssinatura);
    sintGravaAmbiente('CARTAVOX', 'APELIDOS',   nomeArqApelidos);

    sintGravaAmbiente ('CARTAVOX', 'COPIAENVIADAS', booleanToStr[guardaEnviadas]);
    sintGravaAmbiente ('CARTAVOX', 'USASSL',        booleanToStr[usaSSL]);
    sintGravaAmbiente ('CARTAVOX', 'IMAPUSASSL',    booleanToStr[IMAPUsaSSL]);

    sintGravaAmbiente ('CARTAVOX', 'ARMAZENASENHA', booleanToStr[guardaSenha]);
    if guardaSenha then
        begin
            if contaUsuarioAntigo = contaUsuario then
                sintGravaAmbiente('CARTAVOX', 'SCCV', codFraseMime64 (senhaSalva));
        end
    else
        sintRemoveAmbiente('CARTAVOX', 'SCCV');

    sintGravaAmbiente ('CARTAVOX', 'APLICARREGRAS', booleanToStr[aplicRegras]);
    sintGravaAmbiente ('CARTAVOX', 'INSERIRASSINATURA', booleanToStr[inserirAssinatura]);
    sintGravaAmbiente ('CARTAVOX', 'INSERIRCONFIRMACAOLEITURA', booleanToStr[inserirConfRec]);
    sintGravaAmbiente ('CARTAVOX', 'SMTPCOMSENHA', booleanToStr[smtpComSenha]);
    sintGravaAmbiente ('CARTAVOX', 'SMTPCOMSSL', booleanToStr[smtpComSSL]);
    sintGravaAmbiente ('CARTAVOX', 'SMTPCOMTLS', booleanToStr[smtpComTLS]);

    if portaSMTP = 0 then
        if smtpComSSL then portaSMTP := 465
                      else portaSMTP := 25;
    sintGravaAmbiente('CARTAVOX', 'PORTASMTP', intToStr (portaSMTP));

    if portaPOP3 = 0 then
        if not usaSSL then portaPOP3 := 995
                      else portaPOP3 := 110;
    sintGravaAmbiente('CARTAVOX', 'PORTAPOP3', intToStr(portaPOP3));

    if portaImap = 0 then
        if IMAPUsaSSL then portaImap := 993
        else portaImap := 143;

    sintGravaAmbiente('CARTAVOX', 'PORTAIMAP', intToStr(portaImap));

    while keypressed do readkey;
    gotoxy (1, 25);
    writeln;
    mensagem ('CTFIMCNF', 2);   {'Fim da configuração'}
end;

{-------------------------------------------------------------}
{       configura monitoramento
{-------------------------------------------------------------}

procedure configuraMonitoramento;
var
    s: string;

label deNovo;
begin
    clrscr;
    textBackground (BLUE);
    writeln (CONFMONIT_CARTAVOX);   {'CARTAVOX - Configuração do monitoramento'}
    textBackground (BLACK);
    writeln;

    formCria;
    formCampoInt  ('CTINTERV', ms('CTINTERV'),  tempoRemonitorar);
                                {'Após quantos segundos remonitoro (sugiro 60)? '}
    formCampoBool ('CTAVINOV', ms('CTAVINOV'),  avisaNovasMonitorar);
                                {'Aviso só quando chegarem cartas novas? '}
    formCampoBool ('CTRECAUT', ms('CTRECAUT'),  receberaAutMonitorar);
                                { 'Deseja receber as cartas automaticamente: '}
    formEdita (true);

    consisteDirArq;

    str (tempoRemonitorar, s);
    sintGravaAmbiente ('CARTAVOX', 'TEMPOREMONITORAR', intToStr(tempoRemonitorar));
    sintGravaAmbiente ('CARTAVOX', 'AVISANOVASNOMONITORAR', booleanToStr[avisaNovasMonitorar]);
    sintGravaAmbiente ('CARTAVOX', 'RECEBERAUTONOMONITORAR', booleanToStr[receberaAutMonitorar]);

    while keypressed do readkey;
    mensagem ('CTFIMCNF', 2);   {'Fim da configuração'}
end;

{-------------------------------------------------------------}
{       Outras configurações - Itens que não aparecem na procedure configuraTudo
{-------------------------------------------------------------}

procedure outrasConfiguracoes;
var sh: shortstring;
begin
    clrscr;
    textBackground (BLUE);
    writeln (CONFAVAN_CARTAVOX); {'CARTAVOX - Configuração avançada';}
    writeln;

    sh := cartavoxConfigs;    //Passando para shortstring

    formCria;
    tamRotulosForm := tamRotulosForm + 5;
    if not opcoesBasicas then
        begin
            formCampoBool ('CT_FALNP', ms('CT_FALNP'), falaNomePrimeiro);  {'Falar nome antes do assunto'}
            formCampoBool ('CT_ORDEN', ms('CT_ORDEN'), ordenarDataEnvio);  {'Ordenar por data de envio'}
            formCampoBool ('CT_CAORD', ms('CT_CAORD'), ordemInversa);      {'Folhear em ordem decrescente'}
            formCampoBool ('CT_CLEK', ms('CT_CLEK'), clek);                {'Sonorizar na recepção e transmição'}
            formCampoBool ('CT_PERSA', ms('CT_PERSA'), perguntaAoSair);    {'Perguntar ao sair'}
            formCampoBool ('CT_PERSF', ms('CT_PERSF'), perguntaAoSairFolhe); {'Perguntar ao sair do folheamento'}
            formCampoBool ('CT_PERCL', ms('CT_PERCL'), perguntarCriarRespostaAutomatica); {'Perguntar confirmação de leitura'}
            formCampoBool ('CT_CABRE', ms('CT_CABRE'), cabecalhoResumido); {'Cabeçalho resumido na resposta'}
            formCampoBool ('CT_AUDUL', ms('CT_AUDUL'), autoEnviaDuplicadasLixeira); {'Enviar duplicadas automaticamente para lixeira'}
            formCampoBool ('CT_AUTSP', ms('CT_AUTSP'), matarSpamAutomaticamente); {'Matar spam após receber'}
            formCampoBool ('CT_ADIOR', ms('CT_ADIOR'), adicionaOriginal);  {'Adicionar original na cópia'}
            formCampo ('CT_DIRLI', ms('CT_DIRLI'), dirLixeira, 144); {'Diretório da lixeira'}
            formCampo ('CT_DIRSP', ms('CT_DIRSP'), dirSpam, 144); {'Diretório de Spam'}
            formCampo ('CT_ARQCONF', ms('CT_ARQCONF'), sh, 200); {'Arquivo de configurações'}
        end;
    formCampoBool ('CT_OPCBA', ms('CT_OPCBA'), opcoesBasicas); {'Somente opções básicas'}
    formEdita (true);
    tamRotulosForm := tamRotulosForm - 5;

    sintGravaAmbiente('CARTAVOX', 'OPCOESBASICAS', booleanToStr[opcoesBasicas]);

    if not opcoesBasicas then
        begin
            sintGravaAmbiente('CARTAVOX', 'FALANOMEPRIMEIRO', booleanToStr[falaNomePrimeiro]);
            sintGravaAmbiente('CARTAVOX', 'ORDENARDATAENVIO', booleanToStr[ordenarDataEnvio]);
            sintGravaAmbiente('CARTAVOX', 'ORDEMINVERSA', booleanToStr[ordemInversa]);
            sintGravaAmbiente('CARTAVOX', 'CLEK', booleanToStr[clek]);
            sintGravaAmbiente('CARTAVOX', 'PERGUNTAAOSAIR', booleanToStr[perguntaAoSair]);
            sintGravaAmbiente('CARTAVOX', 'PERGUNTAAOSAIRFOLHEAMENTO', booleanToStr[perguntaAoSairFolhe]);
            sintGravaAmbiente('CARTAVOX', 'PERGUNTARCRIARRESPOSTAAUTOMATICA', booleanToStr[perguntarCriarRespostaAutomatica]);
            sintGravaAmbiente('CARTAVOX', 'CABECALHORESUMIDO', booleanToStr[cabecalhoResumido]);
            sintGravaAmbiente('CARTAVOX', 'AUTOENVIADUPLICADASLIXEIRA', booleanToStr[autoEnviaDuplicadasLixeira]);
            sintGravaAmbiente('CARTAVOX', 'MATARSPAMAUTOMATICAMENTE', booleanToStr[matarSpamAutomaticamente]);
            sintGravaAmbiente('CARTAVOX', 'ADICIONAORIGINAL', booleanToStr[adicionaOriginal]);

            if (dirLixeira = '') or (not existeDir (dirLixeira))  then
                dirLixeira := sintAmbiente ('DOSVOX', 'DIRLIXEIRA');
            sintGravaAmbiente('CARTAVOX', 'DIRLIXEIRA', dirLixeira);

            if (dirSpam = '') or (not existeDir (dirSpam))  then
                dirSpam := sintDirAmbiente + '\Spam';
            sintGravaAmbiente('CARTAVOX', 'DIRSPAM', dirSpam);

            cartavoxConfigs := sh;
            if (uppercase(cartavoxConfigs) <> 'CARTAVOX.INI') and
               ((cartavoxConfigs = '') or (not existeArq(cartavoxConfigs)))  then
                cartavoxConfigs := sintDirAmbiente + '\Cartavox.ini';
            sintGravaAmbiente('CARTAVOX', 'ARQCONFIGS', cartavoxConfigs);
        end;

    while keypressed do readkey;
    mensagem ('CTFIMCNF', 2);   {'Fim da configuração'}
end;

{-------------------------------------------------------------}
{       Configura a procura automatizada, abre formulário para edição.
{-------------------------------------------------------------}

procedure configurarProcuraAutomatizada;
type
    tProcura = array [0..9] of shortstring;

var
    i: integer;
    tabProcura: tProcura;

    function tipoProcuraValido: boolean;
    begin
        tipoProcuraValido := (tabProcura[i] = '') or
          ((length(tabProcura[i]) > 2) and
          (tabProcura[i][2] = ' ') and
          (upcase(tabProcura[i][1]) in ['C', 'B', 'T']));
    end;

begin
    clrscr;
    textBackground (BLUE);
    writeln (CONFPROCURA_CARTAVOX); {'CARTAVOX - Configuração da procura';}
    writeln;
    writeln ('Formato: <Tipo de procura(C, B ou T)> <Texto da procura>');
    writeln;
    mensagem ('CTEDTIPR', 2); {'Editore os tipos de procura, ao final tecle ESC'}
    if not keypressed then delay(200);

    for i := 0 to 9 do
        tabProcura[i] := sintAmbiente ('CARTAVOX', 'PROCURAAUTOMATIZADA' + intToStr(i));

    formCria;
    for i := 1 to 9 do
        formCampo ('Tipo '+ intToStr(i), 'Tipo '+ intToStr(i), tabProcura[i], 200);
    formCampo ('Tipo 0', 'Tipo 0', tabProcura[0], 200);

    formEdita (true);

    for i := 0 to 9 do
        if tipoProcuraValido then
            sintGravaAmbiente('CARTAVOX', 'PROCURAAUTOMATIZADA' + intToStr(i), tabProcura[i])
        else
            begin
                sintGravaAmbiente('CARTAVOX', 'PROCURAAUTOMATIZADA' + intToStr(i), '');
                mensagem ('CTPROAER', 0);  {'Erro na procura automatizada número '}
                sintWriteln (intToStr(i));
            end;
    while keypressed do readkey;
    mensagem ('CTFIMCNF', 2);   {'Fim da configuração'}
end;

{-------------------------------------------------------------}
{           pega configuração inicial
{-------------------------------------------------------------}

procedure pegaConfigInicial;
var s: string;
    erro: integer;

    {-------------------------------------------------------------}
    function ambToBool (chave, padrao: string): boolean;
    begin
        result := upcase(sintAmbiente ('CARTAVOX', chave, padrao)[1]) = 'S';
    end;
    {-------------------------------------------------------------}

begin
    SOWindows := sintAmbiente ('DOSVOX', 'WINDOWS') <> '';

    nomeConfiguracao := sintAmbiente ('CARTAVOX', 'CONFIGURACAO');
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
    criaPrefixoNomeArq (nomeConfiguracao);

    agruparPorAssunto := false;

    hostIMAP      := sintAmbiente ('CARTAVOX', 'SERVIDORIMAP');
    hostSMTP      := sintAmbiente ('CARTAVOX', 'SERVIDORSMTP');
    hostPOP3      := sintAmbiente ('CARTAVOX', 'SERVIDORPOP3');
    nomeUsuario   := sintAmbiente ('CARTAVOX', 'NOMEUSUARIO');
    enderUsuario  := sintAmbiente ('CARTAVOX', 'ENDERUSUARIO');
    enderResposta := sintAmbiente ('CARTAVOX', 'ENDERRESPOSTA');
    contaUsuario  := sintAmbiente ('CARTAVOX', 'CONTAUSUARIO');
    dirRecebe     := sintAmbiente ('CARTAVOX', 'DIRRECEBE');
    dirEnvia      := sintAmbiente ('CARTAVOX', 'DIRENVIA');

    dirLixeira    := sintAmbiente ('CARTAVOX', 'DIRLIXEIRA', sintAmbiente ('DOSVOX', 'DIRLIXEIRA'));

    dirSpam := sintAmbiente ('CARTAVOX', 'DIRSPAM');
    if (dirSpam = '') or (not existeDir (dirSpam))  then
        begin
            dirSpam := sintDirAmbiente + '\Spam';
            if not existeDir (dirSpam)  then
                begin
                    {$I-}  mkDir (dirSpam);  {$I+}
                    if ioresult <> 0 then;
                end;
            sintGravaAmbiente('CARTAVOX', 'DIRSPAM', dirSpam);
        end;

    dirAnexo := sintAmbiente ('CARTAVOX', 'DIRANEXO');
    if (dirAnexo <> '') and (dirAnexo[length(dirAnexo)] in ['\', '/']) then
        delete (dirAnexo, length(dirAnexo), 1);

    nomeArqApelidos := sintAmbiente ('CARTAVOX', 'APELIDOS', sintDirAmbiente + '\apelidos.ini');
    nomeAssinatura  := sintAmbiente ('CARTAVOX', 'ASSINATURA');

    antigoNomeArq    := ambToBool ('ANTIGONOMEARQ',    'NAO');
    ordenarDataEnvio := ambToBool ('ORDENARDATAENVIO', 'SIM');
    ordemInversa     := ambToBool ('ORDEMINVERSA',     'NAO');
    usaSSL           := ambToBool ('USASSL',           'SIM');
    autoEnviaDuplicadasLixeira := ambToBool ('AUTOENVIADUPLICADASLIXEIRA', 'NAO');
    matarSpamAutomaticamente := ambToBool ('MATARSPAMAUTOMATICAMENTE', 'NAO');
    guardaEnviadas   := ambToBool ('COPIAENVIADAS',    'SIM');

    falaraposLeituraCarta := ambToBool ('FALARAPOSLEITURACARTA',    'NAO');

    if usaSSL then
        IMAPUsaSSL := ambToBool ('IMAPUSASSL', 'SIM')
    else
        IMAPUsaSSL := ambToBool ('IMAPUSASSL', 'NAO');

    s := sintAmbiente ('CARTAVOX', 'LIMITEAUTOREC');
    if s <> '' then
        val (s, maxTamAuto, erro);
    if (erro > 0) or (maxTamAuto < 1000) then
        maxTamAuto := 10000000;

    perguntaAoSair       := ambToBool ('PERGUNTAAOSAIR', 'SIM');
    perguntaAoSairFolhe  := ambToBool ('PERGUNTAAOSAIRFOLHEAMENTO',  'SIM');
    perguntarCriarRespostaAutomatica
                         := ambToBool ('PERGUNTARCRIARRESPOSTAAUTOMATICA', 'SIM');
    falaNomePrimeiro     := ambToBool ('FALANOMEPRIMEIRO',  'SIM');
    cabecalhoResumido    := ambToBool ('CABECALHORESUMIDO',  'NAO');
    guardaSenha          := ambToBool ('ARMAZENASENHA', 'NAO');
    aplicRegras          := ambToBool ('APLICARREGRAS',  'NAO');
    inserirAssinatura    := ambToBool ('INSERIRASSINATURA',  'NAO');
    inserirConfRec       := ambToBool ('INSERIRCONFIRMACAOLEITURA',  'NAO');
    avisaNovasMonitorar  := ambToBool ('AVISANOVASNOMONITORAR', 'SIM');
    receberaAutMonitorar := ambToBool ('RECEBERAUTONOMONITORAR',  'NAO');
    bipaNoSpeaker        := ambToBool ('BIPANOSPEAKER',  'NAO');
    clek                 := ambToBool ('CLEK',  'SIM');
    adicionaOriginal     := ambToBool ('ADICIONAORIGINAL',  'NAO');
    opcoesBasicas        := ambToBool ('OPCOESBASICAS',  'NAO');
    smtpComSenha         := ambToBool ('SMTPCOMSENHA', 'SIM');
    smtpComTLS           := ambToBool ('SMTPCOMTLS',  'SIM');
    sigRespAut           := ambToBool ('SIGRESPAUT',  'NAO');
    grupoContas          := ambToBool ('GRUPODECONTAS',  'NAO');

    arqRespAut           := sintAmbiente ('CARTAVOX', 'ARQRESPAUT');
    assRespAut           := sintAmbiente ('CARTAVOX', 'ASSRESPAUT');

    s := sintAmbiente ('CARTAVOX', 'SCCV');
    if  guardaSenha and (trim(s) <> '') then senhaSalva := decodFraseMime64 (s)
                                        else senhaSalva := '';

    val (sintAmbiente ('CARTAVOX', 'TEMPOREMONITORAR', '60'), tempoRemonitorar, erro);
    if (erro > 0) or (tempoRemonitorar < 5) then
        tempoRemonitorar := 60;

    val (sintAmbiente ('CARTAVOX', 'PORTASMTP'), portaSMTP, erro);
    if erro <> 0 then
        begin
            if usaSSL and (not smtpComTLS) then portaSMTP := 465
            else portaSMTP := 25;
            sintGravaAmbiente('CARTAVOX', 'PORTASMTP', intToStr(portaSMTP));
        end;

    if portaSMTP = 465 then
        smtpComSSL := ambToBool ('SMTPCOMSSL', 'SIM')
                           else
        smtpComSSL := ambToBool ('SMTPCOMSSL', 'NAO');

    s := sintAmbiente ('CARTAVOX', 'PORTAPOP3');
    erro := 1;
    if s <> '' then
        val (s, portaPOP3, erro);
    if erro <> 0 then
        if usaSSL then portaPOP3 := 995
                  else portaPOP3 := 110;
    sintGravaAmbiente('CARTAVOX', 'PORTAPOP3', intToStr(portaPOP3));

    s := sintAmbiente ('CARTAVOX', 'PORTAIMAP');
    erro := 1;
    if s <> '' then
        val (s, portaImap, erro);
    if erro <> 0 then
        if imapUsaSSL then portaImap := 995
                  else portaImap := 110;
    sintGravaAmbiente('CARTAVOX', 'PORTAIMAP', intToStr(portaImap));

    s := sintAmbiente ('CARTAVOX', 'ESPERAPOP3');
    erro := 1;
    if s <> '' then
        val (s, esperaPOP3, erro);
    if erro <> 0 then esperaPOP3 := -1;
    sintGravaAmbiente('CARTAVOX', 'ESPERAPOP3', intToStr(esperaPOP3));
    esperaPOP3 := esperaPOP3 * 1000;

    s := sintAmbiente ('CARTAVOX', 'QUANTASRECEBER');
    erro := 1;
    if s <> '' then
        val (s, quantasReceber, erro);
    if erro <> 0 then quantasReceber := 25;
    sintGravaAmbiente('CARTAVOX', 'QUANTASRECEBER', intToStr(quantasReceber));

    s := sintAmbiente ('CARTAVOX', 'ESPERASMTP');
    erro := 1;
    if s <> '' then
        val (s, esperaSMTP, erro);
    if erro <> 0 then esperaSMTP := -1;
    sintGravaAmbiente('CARTAVOX', 'ESPERASMTP', intToStr(esperaSMTP));
    esperaSMTP := esperaSMTP * 1000;

    s := sintAmbiente ('CARTAVOX', 'QUANTASENVIAR');
    erro := 1;
    if s <> '' then
        val (s, quantasEnviar, erro);
    if erro <> 0 then quantasEnviar := 50;
    sintGravaAmbiente('CARTAVOX', 'QUANTASENVIAR', intToStr(quantasEnviar));
end;

{-------------------------------------------------------------}
{       seleção interativa
{-------------------------------------------------------------}

function selecInterativa: string;
var
    nomes: array [0..1000] of char;
    p: pchar;
    nnomes, tam: integer;
begin
    tam := getprivateProfileString (NIL, NIL, '', nomes, 1000, PChar(cartavoxConfigs));
    p := nomes;
    if (tam >= 1) and (p^ = #$0) then p := p + 1;   {evita falha em cartavox.ini com erro}

    nnomes := 0;
    while p^ <> #$0 do
        begin
            nnomes := nnomes + 1;
            p := p + strlen(p) + 1;
        end;

    p := nomes;
    if (tam >= 1) and (p^ = #$0) then p := p + 1;

    popupMenuCria (wherex, wherey, 79-wherex, nnomes, MAGENTA);
    while p^ <> #$0 do
        begin
            popupMenuAdiciona ('', maiuscansi(strPas(p)));
            p := p + strlen(p) + 1;
        end;

    popupMenuOrdena;
    popupMenuSeleciona;
    selecInterativa := opcoesItemSelecionado;
    writeln (opcoesItemSelecionado);
end;

{--------------------------------------------------------}
{       guarda configuração
{--------------------------------------------------------}

procedure guardaConfig (gravarAtual: boolean);
var
    nomeConfig: string;
    c: char;
    i: integer;

begin
    if gravarAtual and (trim(nomeConfiguracao) <> '') then
        nomeConfig := nomeConfiguracao
    else
        begin
            mensagem ('CTNOMCNF', 1);   {'Informe o nome da configuração (até 20 letras)'}
            nomeConfig := '';
            c := sintEditaCampo (nomeConfig, 1, wherey, 255, 80, true);
            writeln;
            if (uppercase(nomeConfig) = 'LIXEIRA') or (uppercase(nomeConfig) = 'SPAM') then  nomeConfig := '';
            if (c = BAIX) or (c = CIMA) then nomeConfig := selecInterativa;

            nomeConfig := trim (semAcentos (nomeConfig)); // Não aceita acentuação ao recuperar a configuração.
            if nomeConfig = '' then
                begin
                    mensagem ('CTDESIST', 1); {'Desistiu'}
                    exit;
                end;
        end;

    sintGravaAmbiente('CARTAVOX', 'CONFIGURACAO', nomeConfig);
    nomeConfiguracao := nomeConfig;
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
    criaPrefixoNomeArq (nomeConfiguracao);

    for i := 1 to numChavesConta do //Até o numChavesConta não são genéricas
        writePrivateProfileString(PChar(nomeConfig), tabChaves[i], PChar(sintAmbiente ('CARTAVOX', tabChaves[i])), PChar(cartavoxConfigs));

    mensagem ('CTOK', 2);    {'OK'}
end;

{--------------------------------------------------------}
{     recupera uma configuração no grupo de contas
{--------------------------------------------------------}

procedure recuperaConfigGrupoContas (contaGrupo: string);
var
    nomeConfig, s: string;
    i: integer;

    {--------------------------------------------------------}
    procedure transfereIni (chave: string);
    var r: string;
    begin
        r := sintAmbienteArq (nomeConfig, chave, '', cartavoxConfigs);
        sintGravaAmbiente ('CARTAVOX', chave, r);
    end;
    {--------------------------------------------------------}

begin
    nomeConfig := contaGrupo;

    s := sintAmbienteArq (nomeConfig, 'SERVIDORSMTP', '', cartavoxConfigs);
    if s = '' then
        begin
            mensagem ('CTCNFNAO', 1);   {'Configuração não achada'}
            exit;
        end;

    if (guardaSenha) and (trim(senhaSalva) <> '') then
        sintGravaAmbienteArq (nomeConfiguracao, 'SCCV', codFraseMime64 (senhaSalva), cartavoxConfigs);

    nomeConfiguracao := nomeConfig;
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);

    sintGravaAmbiente('CARTAVOX', 'CONFIGURACAO', nomeConfiguracao);
    criaPrefixoNomeArq (nomeConfiguracao);

    for i := 1 to numChavesConta do //Até o numChavesConta não são genéricas
        transfereIni (strPas(tabChaves[i]));

    pegaConfigInicial;
end;

{--------------------------------------------------------}
{                         recupera configuração
{--------------------------------------------------------}

function recuperaConfig(perguntaSeTransmite, diretoNasSetas: boolean): boolean;
var
    c: char;
    nomeConfig: string;

begin
    recuperaConfig := false;
    if perguntaSeTransmite and (nomeConfiguracao <> 'Lixeira') and (nomeConfiguracao <> 'Spam') then
        transmitirPreparadas;       { Pergunta se transmite caso exista }

    if diretoNasSetas then
        begin
            mensagem ('CTSETCON', 1); {'Escolha com as setas a configuração'}
            nomeConfig := selecInterativa;
        end
    else
        begin
            mensagem ('CTNOMCNF', 1);   {'Informe o nome da configuração (até 20 letras)'}
            nomeConfig := '';
            c := sintEditaCampo (nomeConfig, 1, wherey, 255, 80, true);
            writeln;
            if (c = BAIX) or (c = CIMA) then nomeConfig := selecInterativa;
        end;

    nomeConfig := trim (nomeConfig);
    if nomeConfig = '' then exit;

    gravarNomeConfiguracaoParaVoltar;
    recuperaConfigGrupoContas (nomeConfig);
    recuperaConfig := true;
end;

{-------------------------------------------------------------}
{       Remove a configuração do arquivo cartavox.ini
{-------------------------------------------------------------}

procedure removeConfiguracao;
var
    nomeConfig: string;
    szNomeConfig: array [0..144] of char;
    c: char;
    i: integer;
begin
    mensagem ('CTCONFRM', 1);      {'Escolha com as setas a configuração a remover'}
    nomeConfig := '';
    c := sintEditaCampo (nomeConfig, 1, wherey, 255, 80, true);
    writeln;
    if (c = BAIX) or (c = CIMA) then nomeConfig := selecInterativa;

    nomeConfig := trim (nomeConfig);
    if nomeConfig = '' then
        begin
            mensagem ('CTDESIST', 1); {'Desistiu'}
            exit;
        end;
    if nomeConfig = nomeConfiguracao then
        begin
            mensagem ('CTTROCON', 1); {'Deve trocar a configuração para realizar esta operação'}
            exit;
        end;

    repeat
        mensagem ('CTCNFRMS', 0);    {'Confirma remoção da configuração '}
        sintWrite (nomeConfig);
        write ('? ');
        c := upcase(popupMenuPorLetra ('SN'));
        writeln;
    until c in ['S', 'N', ENTER, ESC];
    if c <> 'S' then
        begin
            mensagem ('CTDESIST', 2);
            exit;
        end;

    strPCopy (szNomeConfig, nomeConfig);
    for i := 1 to numChavesConta do //Até o numChavesConta não são genéricas
        writePrivateProfileString(sznomeConfig, tabChaves[i], NIL, PChar(cartavoxConfigs));
    writePrivateProfileString(sznomeConfig, NIL, NIL, Pchar(cartavoxConfigs));

    mensagem ('CTOKRM', 2);        {'Ok, removida'}
end;

{--------------------------------------------------------}
{                   cria nova configuração
{--------------------------------------------------------}

procedure novaConfiguracao;
var
    nome, dirCartas: string;
    secoes: array [0..1000] of char;
    valor: array [0..100] of char;
    v: string;
    p: pchar;
    n, i, x, nsecoes: integer;
    conta, email: string;
    provedor: array [0..100] of char;
    dirProg, arqModeloProvedor: string;
    c: char;

const
    modelo: pchar = 'modelo';

    procedure gravaNovoDirCartas;
    begin
        if trim(dirCartas) = '' then exit;
        if (pos ('\', dirCartas) = 0) and (pos ('/', dirCartas) = 0) then
            begin
                if not existeDir (dirRecebe) then
                    begin
                        {$I-}  mkdir (dirRecebe);  {$I+}
                        if ioresult <> 0 then;
                    end;
                dirRecebe := dirRecebe + '\' + dirCartas;
            end
        else
            dirRecebe := dirCartas;

        dirEnvia := dirRecebe;
    sintGravaAmbiente('CARTAVOX', 'DIRRECEBE',    dirRecebe);
    sintGravaAmbiente('CARTAVOX', 'DIRENVIA',     dirEnvia);
    end;

begin
    clrscr;
    textBackground (BLUE);
    mensagem ('CTNOVCNF', 1);   {'Nova configuração do Cartavox')}
    textBackground (BLACK);
    writeln;

    dirProg := sintAmbiente('DOSVOX', 'PGMDOSVOX');
    if dirProg = ''then
        begin
            v := sintAmbiente('CARTAVOX', 'DIRCARTAVOX');
            dirProg := copy (v, 1, pos('\', v));
            delete (v, 1, pos('\', v));
            dirProg := dirProg + copy (v, 1, pos('\', v) - 1);
        end;

    arqModeloProvedor := sintAmbiente('DOSVOX', 'DIRPROVEDOR');
    if arqModeloProvedor = ''then
        arqModeloProvedor := sintDirAmbiente + '\provedor.ini';

    mensagem ('CTSETACO', 1);  {'Use as setas para escolher um dos correios abaixo'}

    getprivateProfileString (NIL, NIL, '', secoes, 1000, pchar(arqModeloProvedor));
    p := secoes;
    nsecoes := 0;
    while p^ <> #$0 do
        begin
            nsecoes := nsecoes + 1;
            p := p + strlen(p) + 1;
        end;

    p := secoes;
    popupMenuCria (1, wherey, 29, nsecoes+1, MAGENTA);
    while p^ <> #$0 do
        begin
            popupMenuAdiciona ('', strPas(p));
            p := p + strlen(p) + 1;
        end;

    popupMenuOrdena;
    n := popupMenuSeleciona;
    if n <= 0 then exit;

    p := secoes;
    for i := 2 to n do
        p := p + strlen(p) + 1;
    gotoxy (1, wherey-1);
    clreol;

    strCopy (provedor, p);
    sintwriteln (strPas(provedor));

    mensagem ('CTNOME', 1);  {'Informe seu nome:'}
    sintReadln (nome);
    if nome = '' then
        begin
            mensagem ('CTDESIST', 2);    {'Desistiu'}
            exit;
        end;
    writeln;

    mensagem ('CTSEUEML', 1);  {'Qual o seu email neste servidor?'}
    sintReadln (email);
    if email = '' then
        begin
            mensagem ('CTDESIST', 2);    {'Desistiu'}
            exit;
        end;
    conta := email;
    x := pos ('@', conta);
    if x <> 0 then
        delete (conta, x, 9999);
    writeln;

    repeat
        dirCartas := conta + '_' + provedor;
        delete (dirCartas, pos('.', dirCartas), length(dirCartas));
        delete (dirCartas, pos(' ', dirCartas), length(dirCartas));
        mensagem ('CTEDDIEM', 1);  {'Editore o diretório de e-mail ou tecle enter para utilizar o padrão:'}
        sintetiza (dirCartas);
        c := sintEditaCampo (dirCartas, 1, wherey, 255, 130, true);
        writeln;
    until c in [ENTER, ESC];
    if c = ESC then
        begin
            mensagem ('CTDESIST', 2);    {'Desistiu'}
            exit;
        end;

    gravarNomeConfiguracaoParaVoltar;

    // *** Atualiza o Dosvox.ini com o MODELO do provedor.ini ***
    getprivateProfileString (modelo, NIL, '', secoes, 1000, pchar(arqModeloProvedor));
    p := secoes;
    while p^ <> #$0 do
        begin
            v := sintAmbienteArq (modelo, strPas(p), '', arqModeloProvedor);

            i := pos ('@@', v);
            if i <> 0 then
                begin
                    delete (v, i, 2);
                    insert (sintDirAmbiente, v, i);
                end
            else
            if copy (v, 1, 2) = '@\' then
                begin
                    delete (v, 1, 1);
                    insert (dirProg, v, 1);
                end
            else
            if copy (v, 1, 3) = '"@\' then
                begin
                    delete (v, 2, 1);
                    insert (dirProg, v, 2);
                end;

            strPCopy (valor, v);
            sintGravaAmbiente('CARTAVOX', p, v);
            p := p + strlen(p) + 1;
        end;

    // *** Atualiza o Dosvox.ini com o provedor escolhido.ini ***
    getprivateProfileString (provedor, NIL, '', secoes, 1000, pchar(arqModeloProvedor));
    p := secoes;
    while p^ <> #$0 do
        begin
            v := sintAmbienteArq (provedor, strPas(p), '', arqModeloProvedor);
            if copy (v, 1, 7) = '<conta>' then
                begin
                    delete (v, 1, 7);
                    insert (conta, v, 1);
                end
            else
            if copy (v, 1, 6) = '<nome>' then
                begin
                    delete (v, 1, 6);
                    insert (nome, v, 1);
                end;

            strPCopy (valor, v);
            sintGravaAmbiente('CARTAVOX', p, v);
            p := p + strlen(p) + 1;
        end;

    pegaConfigInicial;   // a que acabou de gravar
    gravaNovoDirCartas;
    consisteDirArq;
    clreol;
end;

{-------------------------------------------------------------}
{       Configura os parâmetros necessários para acessar o diretório da lixeira
{-------------------------------------------------------------}

procedure mudarParaConfigLixeira (perguntaSeTransmite: boolean);
begin
    if perguntaSeTransmite and (nomeConfiguracao <> 'Lixeira') and (nomeConfiguracao <> 'Spam') then
        transmitirPreparadas;       { Pergunta se transmite caso exista }
    gravarNomeConfiguracaoParaVoltar;
    dirRecebe := dirLixeira;
    dirEnvia := dirLixeira;
    hostIMAP := 'imap.servidor.com';
    hostSMTP := 'smtp.servidor.com';
    hostPOP3 := 'pop3.servidor.com';
    guardaSenha := false;
    nomeConfiguracao := 'Lixeira';
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
end;

{-------------------------------------------------------------}
{       Configura os parâmetros necessários para acessar o diretório de Spam
{-------------------------------------------------------------}

procedure mudarParaConfigSpam (perguntaSeTransmite: boolean);
begin
    if perguntaSeTransmite and (nomeConfiguracao <> 'Lixeira') and (nomeConfiguracao <> 'Spam') then
        transmitirPreparadas;       { Pergunta se transmite caso exista }
    gravarNomeConfiguracaoParaVoltar;
    dirRecebe := dirSpam;
    dirEnvia := dirSpam;
    hostIMAP := 'imap.servidor.com';
    hostSMTP := 'smtp.servidor.com';
    hostPOP3 := 'pop3.servidor.com';
    guardaSenha := false;
    nomeConfiguracao := 'Spam';
    setWindowTitle ('CARTAVOX ' + nomeConfiguracao);
end;

{-------------------------------------------------------------}
{       Aplica valores padrão nos itens gerais da configuração do Cartavox
{       Copia provedor.ini para diretório de configuração do Dosvox
{-------------------------------------------------------------}

procedure restaurarConfigPadrao;
var
    c: char;
    dirProg, s, arqModeloProvedor: string;

begin
    telaPrincipal;
    repeat
        textBackground (RED);
        mensagem ('CTRECOPA', 0);   {'Deseja restaurar as configurações padrão? '}
        mensagem ('CTSIMNAO', 0); {'(S/N) ? '}
        c := upcase(popupMenuPorLetra ('SN'));
        textBackGround (BLACK);
        writeln;
    until c in ['S', 'N', ESC];
    if c = ESC then
        begin
            mensagem ('CTDESIST', 2);    {'Desistiu...'}
            exit;
        end;

    dirProg := sintAmbiente('DOSVOX', 'PGMDOSVOX');
    if dirProg = ''then
        begin
            s := sintAmbiente('CARTAVOX', 'DIRCARTAVOX');
            dirProg := copy (s, 1, pos('\', s));
            delete (s, 1, pos('\', s));
            dirProg := dirProg + copy (s, 1, pos('\', s) - 1);
        end;

    // *** Grava no Dosvox.ini cada item com o valor padrão correspondente
    if c = 'S' then
        begin
            sintGravaAmbiente('CARTAVOX', 'DIRCARTAVOX', dirProg + '\som\cartavox');
            sintGravaAmbiente('CARTAVOX', 'ADICIONAORIGINAL', 'NAO');
            sintGravaAmbiente('CARTAVOX', 'ANTIGONOMEARQ', 'NAO');
            sintGravaAmbiente('CARTAVOX', 'AUTOENVIADUPLICADASLIXEIRA', 'NAO');
            sintGravaAmbiente('CARTAVOX', 'MATARSPAMAUTOMATICAMENTE', 'NAO');
            sintGravaAmbiente('CARTAVOX', 'BIPANOSPEAKER', 'NAO');
            sintGravaAmbiente('CARTAVOX', 'CABECALHORESUMIDO', 'NAO');
            sintGravaAmbiente('CARTAVOX', 'CLEK', 'SIM');
            sintGravaAmbiente('CARTAVOX', 'DIRLIXEIRA', dirProg + '\lixeira');
            sintGravaAmbiente('CARTAVOX', 'DIRSPAM', sintDirAmbiente + '\Spam');
            sintGravaAmbiente('CARTAVOX', 'ARQCONFIGS', sintDirAmbiente + '\Cartavox.ini');
            sintGravaAmbiente('CARTAVOX', 'FALANOMEPRIMEIRO', 'SIM');
            sintGravaAmbiente('CARTAVOX', 'OPCOESBASICAS', 'NAO');
            sintGravaAmbiente('CARTAVOX', 'ORDEMINVERSA', 'NAO');
            sintGravaAmbiente('CARTAVOX', 'ORDENARDATAENVIO', 'NAO');
            sintGravaAmbiente('CARTAVOX', 'PERGUNTAAOSAIR', 'SIM');
            sintGravaAmbiente('CARTAVOX', 'PERGUNTAAOSAIRFOLHEAMENTO', 'NAO');
            sintGravaAmbiente('CARTAVOX', 'PERGUNTARCRIARRESPOSTAAUTOMATICA', 'SIM');
            sintGravaAmbiente('CARTAVOX', 'QUANTASENVIAR', '50');
            sintGravaAmbiente('CARTAVOX', 'QUANTASRECEBER', '25');
            sintGravaAmbiente('CARTAVOX', 'ESPERASMTP', '-1');
            sintGravaAmbiente('CARTAVOX', 'ESPERAPOP3', '-1');
            sintGravaAmbiente('CARTAVOX', 'EDITOR', dirProg + '\edivox.exe');
            sintGravaAmbiente('CARTAVOX', 'LEITOR', '"' + dirProg + '\edivox.exe" /L');
            sintGravaAmbiente('CARTAVOX', 'LEITORHTML', '"' + dirProg + '\webvox.exe" /M');
            sintGravaAmbiente('CARTAVOX', 'TOCADOR', dirProg + '\midiavox.exe');
            sintGravaAmbiente('CARTAVOX', 'DIRPROVEDOR',  sintDirAmbiente + '\provedor.ini');

            pegaConfigInicial;
            sintBip;
        end;

    // *** Verifica se existe o provedor.ini para ser copiado
    if not existeArq(dirProg + '\iniOriginal\provedor.ini') then
        begin
            mensagem ('CTERRLEI', 0); {'Erro de leitura do arquivo'}
            write (' ');
            sintWriteln (dirProg + '\iniOriginal\provedor.ini');
            exit;
            end;

    arqModeloProvedor := sintAmbiente('DOSVOX', 'DIRPROVEDOR');
    if arqModeloProvedor = ''then
        arqModeloProvedor := sintDirAmbiente + '\provedor.ini';

    // *** Pergunta se deseja restaurar o provedor.ini do usuário
    if existeArq(arqModeloProvedor) then
        repeat
            textBackground (RED);
            mensagem ('CTRENOCO', 0); {'Deseja restaurar o arquivo de novas configurações? '}
            mensagem ('CTSIMNAO', 0); {'(S/N) ? '}
            c := upcase(popupMenuPorLetra ('SN'));
            textBackGround (BLACK);
            writeln;
        until c in ['S', 'N', ESC]
    else
        c := 'S';

    if c = 'S' then
        if copiaUm (dirProg + '\iniOriginal\provedor.ini', arqModeloProvedor) then
            sintBip;
    mensagem ('CTOK', 1); {'Ok'}
end;

{--------------------------------------------------------}
{       Opções de configuração
{--------------------------------------------------------}

procedure configurar;
var c, c2: char;
label inicioConfig;
begin
inicioConfig:
    telaPrincipal;
    textBackground (RED);
    mensagem ('CTCONFIG', 1);{'Configuração'}
    mensagem ('CTQUALOP', 0); {'Qual sua opção ? '}
    mensagem ('CTF1AJUD', 0); {'F1 ajuda '}
    sintLeTecla (c, c2);
    textBackground (BLACK);
    writeln;

    if (c = #0) and ((c2 = BAIX) or (c2 = CIMA)) then
        c := selSetasConfig
    else
    if c = #0 then
        begin
            ajudaConfig;
            goto inicioConfig;
        end;

    case upcase (c) of
        'R': recuperaConfig (true, false);
        'C': configuraTudo;
        'N': novaConfiguracao;
        'G': guardaConfig (false);
        ^G: guardaConfig (true);
        'A': removeConfiguracao;
        'M': configuraMonitoramento;
        'O': outrasConfiguracoes;
        'L': mudarParaConfigLixeira (true);
        'S': mudarParaConfigSpam (true);
        'V': voltarUltimaConfiguracao;
        'P': restaurarConfigPadrao;
        'F': configurarProcuraAutomatizada;
    else
        if c <> ESC then
            msgBaixo ('CTOPCINV')   {'Opção inválida'}
        else
            msgBaixo ('CTDESIST'); {'Desistiu'}
    end;
end;

{-------------------------------------------------------------}
begin
end.
