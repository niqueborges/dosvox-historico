{--------------------------------------------------------}
{    Programa de comunicação online com voz
{    Autores: Antonio Borges e Bernard Condorcet
{    Em 14/07/99
{--------------------------------------------------------}

program papovox;

uses dvwin, dvcrt, dvinet, dvform, dvDic,
    windows, winsock,
    ppvars, ppconf, ppsnomes, ppconec, ppliga, ppurgent, pprede, ppmsg;

procedure finaliza; forward;

{--------------------------------------------------------}
{               rotina de inicialização
{--------------------------------------------------------}

procedure inicializa;
var jan: hwnd;
    c, c2: char;
    s: string;
    erro: integer;
    entraDireto: string;
    dir: string;
label pula;
begin
    jan := findWindow ('dvwincrt', 'PAPOVOX');
    if jan <> 0 then
        begin
            setFocus (jan);
            halt;
        end;

    dir :=  sintambiente ('PAPOVOX', 'DIRPAPOVOX');
    if dir = '' then
        dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\papovox';
    sintInic (0, dir);

    clrscr;
    setWindowText (crtWindow, 'PAPOVOX');
    delay (200);

    textBackground (BLUE);
    mensagem ('PPINIC', 0);    {'Papovox v.'}
    write (versao);
    sintSoletra (versao);
    textBackground (BLACK);
    sintWriteln (' '+ ALFABETA);
    writeln ('Projeto DOSVOX - NCE/UFRJ - 1999-2005');
    writeln;

    if not abreWinSock then
         begin
             mensagem ('PPWSOCK', 1);   {Acesso a Internet não habilitado}
             finaliza;
         end;

    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');

    entraDireto:= sintAmbiente ('PAPOVOX', 'ENTRADIRETO');
    if entraDireto = '' then
        entraDireto:= 'N'
    else
        if maiuscAnsi(entraDireto[1]) = 'S' then
            begin
                nomeUsuario:= 'Anônimo';
                enderUsuario:= 'anonimo@lugar.com.br';
                anonimo:= true;
                goto pula;
            end;

    delay (500);        {evita esbarrar nos benditos clicks que o povo ama !}

    mensagem ('PPIDSECR', 0);    {Deseja manter sua real identidade em segredo ? }
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then
        begin
            mensagem ('PPFIM', 1);     {'Até a próxima'}
            fechaWinSock;
            sintFim;
            doneWinCrt;
        end;

    anonimo := upcase(c) <> 'N';
    if anonimo then
        mensagem ('PPNOMFAN', 1)    {Informe então seus dados de fantasia}
    else
        begin
            nomeUsuario  := sintAmbiente ('PAPOVOX', 'NOMEUSUARIO');
            enderUsuario := sintAmbiente ('PAPOVOX', 'ENDERUSUARIO');
        end;

    if anonimo then
         begin
             mensagem ('PPNOMUSU', 1);   {Qual o seu nome ?}
             sintReadln (s);
             nomeUsuario:= s;
             s:= '';
             if nomeUsuario = '' then
               finaliza;
             enderUsuario := 'anonimo@lugar.com.br';
         end
    else
        if (nomeUsuario = '') or (enderUsuario = '') then
            begin
                configura;
                if (nomeUsuario = '') or (enderUsuario = '') then
                    begin
                        anonimo := true;
                        finaliza;
                    end;
            end;

    pula:

    logonUsuario (enderUsuario, 'logon');

    selecionado:= sintAmbiente ('PAPOVOX', 'SERVNOMES');
    if selecionado = '' then
        selecionado:= 'chat.saci.org.br';
    soletra:= sintAmbiente ('PAPOVOX', 'SOLETRA');
    if soletra = '' then
        soletra:= 'S';
    pontua:= sintAmbiente ('PAPOVOX', 'PONTUA');
    if pontua = '' then
        pontua:= 'N';
    acelerado:= sintAmbiente ('PAPOVOX', 'ACELERADO');
    if acelerado = '' then
        acelerado:= 'S';
    dicion:= sintAmbiente ('PAPOVOX', 'COMDIC');
    if dicion = '' then
    dicion:= 'N';
    s := sintAmbiente ('PAPOVOX', 'TAMLINHA');
    val (s, maxtec, erro);
    if erro <> 0 then
         maxtec := 250;
    contaSpeaker := 0;

    inicMsgUrgente;

    EnableMenuItem(GetSystemMenu(CrtWindow, False), sc_Close, mf_Disabled);
    checkBreak := false;

    nomeArqEfeitos := sintAmbiente ('PAPOVOX', 'ARQEFEITOS');
    if nomeArqEfeitos = '' then
        nomeArqEfeitos := sintDirAmbiente + '\sompapo.ini';

    nomeArqComandos:= sintAmbiente ('PAPOVOX', 'ARQCOMANDOS');
    if nomeArqComandos = '' then
        nomeArqComandos:= sintDirAmbiente + '\comsaci.ini';

    nomeArqLog := sintAmbiente ('PAPOVOX', 'ARQLOG');
    if nomeArqLog = '' then
        nomeArqLog := sintDirAmbiente + '\papovox.log';

    nomeArqDic := sintAmbiente ('DICIONARIO', 'ARQDIC');
    if nomeArqDic = '' then
        nomeArqDic := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\diciona.dic';

    nomeArqSufixos := sintAmbiente ('DICIONARIO', 'ARQSUFIXOS');
    if nomeArqSufixos = '' then
        nomeArqSufixos := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\diciona.suf';

    nomeArqInexist := sintAmbiente ('DICIONARIO', 'ARQINEXIST');
    if nomeArqInexist = '' then
        nomeArqInexist := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\diciona.exc';

    nomeArqNomes := sintAmbiente ('DICIONARIO', 'ARQNOMES');
    if nomeArqNomes = '' then
        nomeArqNomes := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\diciona.nom';

    nomeArqSugTroca := sintAmbiente ('DICIONARIO', 'ARQSUGERE');
    if nomeArqSugTroca = '' then
        nomeArqSugTroca := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\diciona.sug';

    soletrando    := (soletra = '')   or (maiuscAnsi (copy (soletra, 1, 1)) <> 'N');
    sintFalaPont  := (pontua  = '')   or (maiuscAnsi (copy (pontua, 1, 1)) <> 'N');
    modoAcelerado := (acelerado = '') or (maiuscAnsi (copy (acelerado, 1, 1)) = 'S');
    comDic := (dicion <> '') and (maiuscAnsi (dicion[1]) = 'S');

    if comDic then
        if carregaDic (nomeArqDic, nomeArqSufixos, nomeArqInexist, nomeArqNomes, nomeArqSugTroca) = 0 then
            sintSom ('PPDA') {'Dicionário ativado'}
        else
            sintSom ('PPNCD'); {'Não pude carregar o dicionário'}

    if maiuscAnsi(entraDireto[1]) = 'S' then
        liga;

end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasOpcoes: string [5] = 'pcelm';

begin
    garanteEspacoTela(5);
    popupMenuCria (wherex, wherey, 60, 5, MAGENTA);
    MenuAdiciona ('PPAJUD1');  {'P - pesquisa usuários no servidor de nomes'}
    MenuAdiciona ('PPAJUD2');  {'C - configura o programa'}
    MenuAdiciona ('PPAJUD3');  {'E - Espera que alguém inicie uma conexão com este programa'}
    MenuAdiciona ('PPAJUD4');  {'L - Inicia uma ligação com outro usuário'}
    MenuAdiciona ('PPAJUD5');  {'M - Envia mensagem urgente para outro usuário'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := #0;
end;

{-------------------------------------------------------------}
{                       ajuda
{-------------------------------------------------------------}

procedure ajuda;
begin
    mensagem ('PPAJUD0', 1);    {'As opções são as seguintes:'}
    mensagem ('PPAJUD1', 1);    {'P - pesquisa usuários no servidor de nomes'}
    mensagem ('PPAJUD2', 1);    {'C - configura o programa'}
    mensagem ('PPAJUD3', 1);    {'E - Espera que alguém inicie uma conexão com este programa'}
    mensagem ('PPAJUD4', 1);    {'L - Inicia uma ligação com outro usuário'}
    mensagem ('PPAJUD5', 1);    {'M - Envia mensagem urgente para outro usuário'}
    mensagem ('PPAJUD6', 1);    {'ESC - termina o programa'}

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{               testa se usuario quer terminar
{--------------------------------------------------------}

function testaFim: boolean;
var c, c2: char;
begin
    mensagem ('PPCNFFIM', 0);   {'Confirma fim ? '}
    sintLeTecla (c, c2);
    writeln;
    testaFim :=  upcase (c) = 'S';
end;

{--------------------------------------------------------}
{               ciclo de processamento geral
{--------------------------------------------------------}

procedure processa;
var
    processando: boolean;
    c, c2: char;
label opcao, executa;
begin
    processando := true;
    while processando do
        begin
opcao:
            while temMsgUrgente do
                recebeMsgUrgente;

            while keypressed do readkey;

            textBackground (BLUE);
            mensagem ('PPOPCAO', 0);   {'Qual sua opcao? '}
            textBackground (BLACK);
            while not keypressed do
                if temMsgUrgente then
                    begin
                        writeln;
                        recebeMsgUrgente;
                        goto opcao;
                    end;

            sintLeTecla (c, c2);
            writeln;
            if c = #$0 then
                begin
                    if c2 = F1 then
                        ajuda
                    else
                    if (c2 = CIMA) or (c2 = BAIX) then
                        begin
                            c := selSetasOpcao;
                            goto executa;
                        end
                end
            else
               begin
        executa:
                    case upcase(c) of
                        'C':  configura;
                        'P':  begin
                                  pesquisaUsuarios;
                                  if selecionado <> '' then
                                      liga;
                              end;
                        'E':  esperaConexao;
                        'L':  liga;
                        'M':  enviaMsgUrgente;
                        ESC:  processando := not testaFim;
                    else
                        mensagem ('PPAPTF1', 2);
                    end;
                end;
        end;
end;

{--------------------------------------------------------}
{                        Finaliza o programa
{--------------------------------------------------------}

procedure finaliza;
begin
    if not anonimo then
        logonUsuario (enderUsuario, 'logoff');

    finalMsgUrgente;

    if comDic then
        fechaDic;

    mensagem ('PPFIM', 1);     {'Até a próxima'}
    sintFim;
    fechaWinSock;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                    programa principal
{--------------------------------------------------------}

begin
    inicializa;
    processa;
    finaliza;
end.
