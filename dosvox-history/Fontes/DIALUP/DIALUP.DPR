{--------------------------------------------------------}
{   DIALUP-VOX - versão 2
{   Acesso discado ao provedor de Internet
{   Autor: Bernard Condorcet
{   Em agosto/2006
{--------------------------------------------------------}

program dialup;

uses dvCrt, dvWin, dvExec, dvForm, dvHora,
    windows, sysUtils,
    diMsg;

const
    versao = '2.0';

var
    conect: array [1..30] of shortString;
    telefone: array [1..30] of shortString;
    conta: array [1..30] of shortString;
    senha: array [1..30] of shortString;
    numConect, maxConect: integer;
    dirDosvox, comando, servDefault: string;
    memIndice: integer;
    velocidadeDosVox: integer;
    verParam: string;
    hMutex: THandle;
    iniDialup: string;

{--------------------------------------------------------}
{Toca efeito trocando a velocidade da síntese
{--------------------------------------------------------}

procedure tocaEfeito (arqEfeito: string);
begin

    sintVeloc (1);
    sintSom ((arqEfeito));
    while sintFalando do waitMessage;
    sintVeloc (velocidadeDosvox);

end;

{--------------------------------------------------------}
{Finaliza o programa
{--------------------------------------------------------}

procedure finaliza;
begin

    mensagem ('DIFIM', 1);   {'Fim do programa'}

    tocaEfeito ('E_FIM');

    sintFim;
    doneWinCrt;

end;

{--------------------------------------------------------}
{Verifica se está conectado
{--------------------------------------------------------}

function conectAtiva: boolean;
var arq: text;
    linha, resultado: string;
begin

    conectAtiva:= false;

    assign (arq, 'c:\dos.$$$');
    {$i-} erase(arq); {$i+}
    if IoResult <> 0 then;

    delay (250);
    if executaProg (comando, '', '/C '+ dirDosvox + '\rcl.exe > c:\dos.$$$') < 32 then;
        esperaProgVoltar;

    {$i-} reset(arq); {$i+}
    if IoResult <> 0 then
        exit //Informar problemas no disco
    else
        while not eof (arq) do
        readln (arq, linha);
        {$i-} close(arq); {$i+}
        if IoResult <> 0 then;

    resultado:= copy(linha, 1, (pos(' ', linha) -1));
    if resultado = 'Connected' then
    begin
        mensagem ('DIVOCCON', 0);   {'Você está conectado a '}
        delete (linha, 1, 13);
        sintWriteln (linha);
        conectAtiva:= true;
    end;

end;

{--------------------------------------------------------}
{Zera vetor OBS: Não obrigatório para WINDOWS XP
{--------------------------------------------------------}

procedure zeraVetor;
var n: integer;
begin

    for n := 1 to maxConect do
    begin
        conect[n]:= '';
        telefone[n]:= '';
        conta[n]:= '';
        senha[n]:= '';
    end;

end;

{--------------------------------------------------------}
{Carrega vetor a partir de c:\windows\dialup.ini
{--------------------------------------------------------}

procedure pegaNomesConect;
var arq: text;
    linha: string;
begin

    numConect:= 0;
    maxConect:= 0;
    memIndice:= 0;

    assign (arq, iniDialup);
    {$i-} reset(arq); {$i+}
    if IoResult <> 0 then
    begin
        mensagem ('DIVAICRI', 1);  {'Arquivo de configuração será criado agora'}
        {$i-} rewrite(arq); {$i+}
        if IoResult <> 0 then;
        {$i-} close(arq); {$i+}
        if IoResult <> 0 then;
    end
    else
    begin
        while not eof (arq) do
        begin
            readln (arq, linha);
            if linha <> '' then
                if linha[1] = '[' then
                begin
                    numConect:= numConect +1;
                    conect[numConect]:= linha;
                    delete (conect[numConect], 1, 1);
                    delete (conect[numConect], length(conect[numConect]), 1);
                    if servDefault <> '' then
                        if maiuscAnsi(conect[numConect]) = maiuscAnsi(servDefault) then
                            memIndice:= numConect;
                    readln (arq, telefone[numConect]);
                    delete (telefone[numConect], 1, pos('=', telefone[numConect]));
                    readln (arq, conta[numConect]);
                    delete (conta[numConect], 1, pos('=', conta[numConect]));
                    readln (arq, senha[numConect]);
                    delete (senha[numConect], 1, pos('=', senha[numConect]));
                end;
        end;
    end;

    {$i-} close(arq); {$i+}
    if IoResult <> 0 then;

    maxConect:= numConect;
    numConect:= 0;

end;

{--------------------------------------------------------}
{Verifica se existe servidor selecionado pelo usuário
{--------------------------------------------------------}

function existServ: boolean;
begin

    existServ:= false;

    if numConect = 0 then
    begin
        mensagem ('DINAOEXI', 1);  {'Não existe servidor selecionado'}
        exit
    end
    else
        existServ:= true;

end;

{--------------------------------------------------------}
{Possibilita a escolha de um servidor com as setas
{--------------------------------------------------------}

procedure listaConect;
var i: integer;
begin

    if maxConect = 0 then
        exit;

    mensagem ('DIUSESET', 1);   {'Use as setas e pressione ENTER no servidor desejado'}

    garanteEspacoTela(maxConect);
    popupMenuCria (wherex, wherey, 30, maxConect, RED);
    for i := 1 to maxConect do
        popupMenuAdiciona ('', conect[i]);
    numConect := popupMenuSeleciona;

    if numConect < 1 then
    begin
        numConect:= 0;
        exit;
    end;

    mensagem ('DIOKASSU', 0);  {'OK, assumi : '}
    sintBip; sintBip;
    sintWriteln (conect[numConect]);

end;

{--------------------------------------------------------}
{Configura novo servidor
{--------------------------------------------------------}

procedure novaConect;
var conect_n, telefone_n, conta_n, senha_n: shortString;
     sz, szConect: array [0..144] of char;
    opcao: char;
begin

    mensagem ('DICNFNOV', 1);  {'Use as setas e configure um novo servidor'}

    garanteEspacoTela (8);

    conect_n:= '';
    telefone_n:= '';
    conta_n:= '';
    senha_n:= '';

    formCria;
    formCampo    ('', 'Servidor : ', conect_n, 80);
    formCampo    ('', 'Telefone : ', telefone_n, 80);
    formCampo    ('', 'Conta : ', conta_n, 80);
    formCampo    ('', 'Senha : ', senha_n, 80);
    formEdita (true);

    if conect_n = '' then
        exit;

    mensagem ('DIGRVDSK', 0);   {'Irei gravar em disco, confirma ? sim ou não: '}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
    begin
        strPCopy (szConect, conect_n);
        strPCopy (sz, telefone_n);
        writePrivateProfileString (szConect, 'TELEFONE', sz, pchar(iniDialup));
        strPCopy (sz, conta_n);
        writePrivateProfileString (szConect, 'CONTA', sz, pchar(iniDialup));
        strPCopy (sz, senha_n);
        writePrivateProfileString (szConect, 'SENHA', sz, pchar(iniDialup));
        tocaEfeito ('E_GRAVOU');
        sintSom ('DIOK');
        pegaNomesConect;
    end
    else
        mensagem ('DIOKCANC', 1);  {'OK, operação cancelada e não irei gravar em disco'}

end;

{--------------------------------------------------------}
{Remove uma configuração
{--------------------------------------------------------}

procedure removeConect;
var szConect: array [0..144] of char;
    opcao: char;
begin

    listaConect;
    if not existServ then
        exit;

    mensagem ('DICONREM', 0); {'Confirma a remoção de '}
    sintWrite (conect[numConect] + '? ');
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
    begin
        strPCopy (szConect, conect[numConect]);
        writePrivateProfileString (szConect, nil, nil, pchar(iniDialup));
        tocaEfeito ('E_GRAVOU');
        sintSom ('DIOK');
        zeraVetor;
        pegaNomesConect;
    end
    else
        mensagem ('DIOKCAN', 1);  {'OK, operação cancelada'}

end;

{--------------------------------------------------------}
{Apresenta ao usuário informações colhidas em c:\windows\dialup.ini
{--------------------------------------------------------}

procedure informConect;
var sz, szConect: array [0..144] of char;
    opcao: char;
begin

    if numConect = 0 then
    begin
        listaConect;
        if not existServ then
            exit;
    end;

    writeln;
    textBackground (BLUE);
    mensagem ('DIEDITE', 1);  {'Use as setas e edite os campos'}
    textBackground (BLACK);
    writeln;

    garanteEspacoTela (6);

    formCria;
    formCampo    ('', 'Telefone : ', telefone[numConect], 80);
    formCampo    ('', 'Conta : ', conta[numConect], 80);
    formCampo    ('', 'Senha : ', senha[numConect], 80);
    formEdita (true);

    mensagem ('DIREALT', 0);  {'Deseja realterar itens anteriormente criados ? sim ou não : '}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
    begin
        strPCopy (szConect, conect[numConect]);
        strPCopy (sz, telefone[numConect]);
        writePrivateProfileString (szConect, 'TELEFONE', sz, pchar(iniDialup));
        strPCopy (sz, conta[numConect]);
        writePrivateProfileString (szConect, 'CONTA', sz, pchar(iniDialup));
        strPCopy (sz, senha[numConect]);
        writePrivateProfileString (szConect, 'SENHA', sz, pchar(iniDialup));
        tocaEfeito ('E_GRAVOU');
        sintSom ('DIOK');
    end
    else
        mensagem ('DIOKNGRV', 1);  {'OK, não irei gravar em disco'}

end;

{--------------------------------------------------------}
{Desconecta ao servidor
{--------------------------------------------------------}

procedure desfazConect;
var opcao: char;
begin

    mensagem ('DIVERIF', 1);   {'Aguarde por favor, irei verificar o status da conexão'}
    while sintFalando do waitMessage;

    if not conectAtiva then
    begin
        mensagem ('DINAOCON', 1);  {'Você não está conectado a nenhum servidor'}
        exit;
    end;

    mensagem ('DIIREICN', 0);  {'Irei desconectar ao servidor, confirma ? sim ou não : '}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase(opcao) = 'S' then
    begin
        delay (250);

        if executaProg (dirDosvox + '\rcl.exe', '', ' -d') < 32 then;
        esperaProgVoltar;

    tocaEfeito ('E_DESCON');

        numConect:= 0;

    end;

end;

{--------------------------------------------------------}
{Conecta ao servidor
{--------------------------------------------------------}

procedure fazConect;
var parametros: string;
    tec: char;
label pula, deNovo, fim;
begin

    if memIndice > 0 then
    begin
        numConect:= memIndice;
        goto pula;
    end;

    if numConect = 0 then
    begin
        listaConect;
        if not existServ then
            exit;
    end;

    pula:

    mensagem ('DIVERIF', 1);  {'Aguarde por favor, irei verificar o status da conexão'}
    while sintFalando do waitMessage;

    if conectAtiva then
        exit;

    deNovo:

    if telefone[numConect] = '' then
        begin
            mensagem ('DITELVAZ', 1);  {'Campo telefone está vazio, será necessário preenchê-lo'}
            informConect;
            goto deNovo;
        end;
    if conta[numConect] = '' then
        begin
            mensagem ('DICTAVAZ', 1);  {'Campo conta está vazio, será necessário preenchê-lo'}
            informConect;
            goto deNovo;
        end;
    if senha[numConect] = '' then
        begin
            mensagem ('DISENVAZ', 1);  {'Campo senha está vazio, será necessário preenchê-lo'}
            informConect;
            goto deNovo;
        end;

    telefone[numConect]:= ' -n' + telefone[numConect];
    conta[numConect]:= ' -u' + conta[numConect];
    senha[numConect]:= ' -p' + senha[numConect];

    parametros:= telefone[numConect] + conta[numConect] + senha[numConect];

    mensagem ('DIPRESSE', 0);  {'Pressione ENTER para conectar, ESC desiste'}
    tec:= readkey;
    writeln;

    if tec = ESC then
        goto fim;

    delay (250);
    if executaProg (dirDosvox + '\rcl.exe', '', parametros) < 32 then;
        esperaProgVoltar;

    tocaEfeito ('E_CONECT');

    fim:
    delete (telefone[numConect], 1, 3);
    delete (conta[numConect], 1, 3);
    delete (senha[numConect], 1, 3);

    numConect:= 0; //se conectou

end;

{--------------------------------------------------------}
{Mostra menu principal
{--------------------------------------------------------}

procedure menuPrincipal;
begin

    tocaEfeito ('E_MENU');

    mensagem ('DIOPTEC', 1);    {'Opções nas teclas : '}
    mensagem ('DICONCT',  1);   {'C  - Conecta ao servidor'}
    mensagem ('DIINFO',  1);    {'I  - Informações sobre o servidor'}
    mensagem ('DIDESF',  1);    {'D  - Desconecta do servidor'}
    mensagem ('DINOVO',  1);    {'N  - Novo servidor'}
    mensagem ('DIREMO',  1);    {'R  - Remove servidor'}

end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

function selSetasOpcao: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'cidnr';

begin
    garanteEspacoTela (5);
    popupMenuCria (wherex, wherey, 50, 5, MAGENTA);
    menuAdiciona ('DICONCT'); {'C  - Conecta ao servidor'}
    menuAdiciona ('DIINFO');  {'I  - Informações sobre o servidor'}
    menuAdiciona ('DIDESF');  {'D  - Desconecta ao servidor'}
    menuAdiciona ('DINOVO');  {'N  - Novo servidor'}
    menuAdiciona ('DIREMO');  {'R  - Remove servidor'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;

{--------------------------------------------------------}
{          Tratamento do teclado no menu principal
{--------------------------------------------------------}

procedure trataTecladoMenuPrincipal;
var c1, c2: char;
    processando: boolean;
label deNovo, executa;

begin

deNovo:

    processando := true;

    while (processando)  do
       begin

           writeln;
           TextBackGround (blue);
           mensagem ('DIQUALOP', 0);  {'DIALUP, qual sua opção ? '}
           TextBackGround (black);

           sintLeTecla (c1, c2);
           writeln;

           if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
                begin
                    c1 := selSetasOpcao;
                    goto executa;
                end
           else
           if (c1 = #0) and (c2 = F1) then
               menuPrincipal
           else
           if (c1 = #0) and (c2 = CTLF8) then
               falaDia
           else
executa:
               case upcase(c1) of

                   'C': fazConect;
                   'I': informConect;
                   'D': desfazConect;
                   'N': novaConect;
                   'R': removeConect;

                   ESC:  processando := false;
                   #$0d: ;
               else
                   mensagem ('DIOPINV', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

end;

{--------------------------------------------------------}
{Inicializa o programa
{--------------------------------------------------------}

procedure inicializa;
var
    infoSistOp: _OSVERSIONINFO;
    erro: integer;
begin
    // Evita duas instâncias do Dosvox em execução.
    hMutex := CreateMutex (NIL, false, 'Dialup.NCE.UFRJ');
    if GetLastError = ERROR_ALREADY_EXISTS then
        Halt;

    SintInic (0, sintAmbiente('DIALUP', 'DIRDIALUP'));
    iniDialup := sintDirAmbiente+'\dialup.ini';

    clrscr;
    setWindowText (crtWindow, 'DIALUP/VOX');
    delay (200);

    val (sintAmbiente('TRADUTOR', 'VELOCIDADE'), velocidadeDosvox, erro);
    if erro <> 0 then
        velocidadeDosvox:= 0;

    tocaEfeito ('E_INIC');

    textBACKGROUND (BLUE);
    mensagem ('DIINIC', 0); {'Programa DIALUP/VOX - NCE/UFRJ - v.'}
    writeln (VERSAO);
    sintSoletra (VERSAO);
    textBackground (BLACK);
    writeln;

    infoSistOp.dwOSVersionInfoSize := sizeof(infoSistOp);
    GetVersionEx(infoSistOp);
    if infoSistop.dwMajorVersion >= 5 then
        comando := 'cmd'
    else
        comando := 'command';
    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');

    servDefault:= sintAmbiente ('DIALUP', 'SERVIDOR');

    verParam:= '';
    if paramCount >= 1 then
    begin
        verParam:= paramStr(1);
        if maiuscAnsi(verParam[1]) = 'D' then
        begin
            desfazConect;
            finaliza;
        end;
    end;

end;

{--------------------------------------------------------}
{Rotina principal
{--------------------------------------------------------}

begin

    inicializa;
    pegaNomesConect;
    trataTecladoMenuPrincipal;
    finaliza;

end.
