{-------------------------------------------------------------}
{
{    Programa de Transferência Remota de Arquivos
{
{    Autor: Jose' Antonio Borges
{
{    Em 21/04/98
{
{-------------------------------------------------------------}

{-------------------------------------------------------------}
{                arquivos de inclusao obrigatoria
{-------------------------------------------------------------}

uses
    dvCrt, dvWin, dvForm, sysUtils, winsock, winprocs,
    dvHora,
    ftpVars, ftpMsg, ftpLogin, ftpDir, ftpDlg, ftpRede, ftpArq, ftpPort;

{-------------------------------------------------------------}
{                     rotina de inicializacao
{-------------------------------------------------------------}

function inicializa: boolean;
var
    c: char;
    tempPath, tempFileName: array [0..144] of char;
    tituloJan: array [0..144] of char;

begin
    sintInic (0, sintAmbiente ('FTPVOX', 'DIRFTPVOX'));

    clrscr;
    setWindowText (crtWindow, 'FTPVOX');

    textBackground (BLUE);
    mensagem ('FTINIC', 0);  {'FTP VOX - NCE/UFRJ - v.'}
    writeln (VERSAO + ' ' + TIPOVERSAO);
    sintSoletra (VERSAO);
    sintetiza (TIPOVERSAO);
    textBackground (BLACK);
    writeln;

    debug := false;
    processando := true;
    fimProg := false;
    canalAberto := false;
    escutando := false;

    totalTransmitido := 0;
    verboso := false;
    pins := 0;
    pret := 0;
    linhaParcial := '';
    portaLocal := $400 + 20;

    modoPassivo := not (copy (sintAmbiente ('FTPVOX', 'PASSIVO'), 1, 1) <> 'N');
    selModoPassivo;   // inverte

    getTempPath (144, tempPath);
    getTempFileName(tempPath, 'dir', 0, tempFileName);
    nomeArqDir := strPas (tempFileName);

    if paramcount > 0 then
        nomeHost := paramStr(1)
    else
        begin
            mensagem ('FTCOMPUT', 0);  {'[Nome do computador: '}
            nomeHost := sintAmbiente ('FTPVOX', 'NOMECOMPUTADOR', 'intervox.nce.ufrj.br');
            c := sintEditaCampo (nomeHost, 1, wherey, 255, 80, true);
            writeln;
        end;

    if c = ESC then nomeHost := '';

    strPCopy (tituloJan, 'FTPVOX ' + nomeHost);
    setWindowText (crtWindow, tituloJan);

    porta := 21;
    portaPassiva := 9999;

    result := nomeHost <> '';
end;

{-------------------------------------------------------------}
{                         ajuda
{-------------------------------------------------------------}

procedure ajuda;
begin
    mensagem ('FTAJUD00', 1);  {'As opçoes são'}
    mensagem ('FTAJUD01', 1);  {'  L  login conta e senha'}
    mensagem ('FTAJUD03', 1);  {'  R  receber arquivo remoto'}
    mensagem ('FTAJUD04', 1);  {'  T  transmitir'}
    mensagem ('FTAJUD07', 1);  {'  Q  Informar quantidade transmitida'}
    mensagem ('FTAJUD02', 1);  {'  D  diretorio remoto'}
    mensagem ('FTAJUD05', 1);  {'  A  apagar arquivo'}
    mensagem ('FTAJUD8C', 1);  {'  I  Identificação do diretório atual'}
    mensagem ('FTAJUD06', 1);  {'  S  Trocar subdiretorio'}
    mensagem ('FTAJUD8D', 1);  {'  C  Criar subdiretório'}
    mensagem ('FTAJUD08', 1);  {'  V  modo verborágico'}
    mensagem ('FTAJUD8A', 1);  {'  P  modo passivo'}
    mensagem ('FTAJUD8B', 1);  {'  /  comandos do ftp'}
    mensagem ('FTAJUD09', 1);  {'  ?  ajuda'}
    mensagem ('FTAJUD10', 1);  {'ESC  fim do programa'}
    while keypressed do readkey;
    sintBip;
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
    tabLetrasOpcoes: string [14] = 'lrtqdaiscvp/?' + ESC;

begin
    popupMenuCria (wherex, wherey, 50, 13, MAGENTA);
    MenuAdiciona ('FTAJUD01');  {'  L  login conta e senha'}
    MenuAdiciona ('FTAJUD03');  {'  R  receber arquivo remoto'}
    MenuAdiciona ('FTAJUD04');  {'  T  transmitir'}
    MenuAdiciona ('FTAJUD07');  {'  Q  Informar quantidade transmitida'}
    MenuAdiciona ('FTAJUD02');  {'  D  diretorio remoto'}
    MenuAdiciona ('FTAJUD05');  {'  A  apagar arquivo'}
    MenuAdiciona ('FTAJUD8C');  {'  I  Identificação do diretório atual'}
    MenuAdiciona ('FTAJUD06');  {'  S  Trocar subdiretorio'}
    MenuAdiciona ('FTAJUD8D');  {'  C  Criar subdiretório'}
    MenuAdiciona ('FTAJUD08');  {'  V  modo verborágico'}
    MenuAdiciona ('FTAJUD8A');  {'  P  modo passivo'}
    MenuAdiciona ('FTAJUD8B');  {'  /  comandos do ftp'}
    MenuAdiciona ('FTAJUD09');  {'  ?  ajuda'}
    MenuAdiciona ('FTAJUD10');  {'ESC  fim do programa'}
    while keypressed do readkey;

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;

{-------------------------------------------------------------}
{               cria diretório remoto
{-------------------------------------------------------------}

procedure criaDiretorio;
var
    nome, s: string;
    codigo: integer;

begin
    mensagem ('FTQUESBD', 1);    {'Qual o nome do subdiretorio? '}
    sintReadln (nome);

    if nome = ''   then
        begin
            mensagem ('FTDESIS', 1);  {'Desistiu'}
            exit;
        end;

    if nome = '..' then   s := 'MKD'
    else                  s := 'MKD '+ ansiToUtf8(nome);

    if enviaComando (s) then
        begin
            mostraRespostas (codigo);
            if (codigo = 257) then
                mensagem ('FTOK', 1)  {'OK'}
            else
                mensagem ('FTNCRIA', 1);  {'Não consegui criar'}
        end;
end;

{-------------------------------------------------------------}
{                     processa tecla
{-------------------------------------------------------------}

procedure processaTecla;
var c, c2: char;
    s: string;
    codigo: integer;

label executa;
begin
    fimProg := false;

    c := readkey;
    c2 := #$0;
    if c = #0 then
        c2 := readkey
    else
    if sintEcoarOpcao and (upcase(c) in ['A'..'Z']) then
        sintCarac (c);

    if c = #0 then
        begin
            if c2 in [#16..#18] then
                c := readkey; {ALT-GR q,w,e}
        end;

executa:
    writeln (c);
    case upcase(c) of

        ENTER: ;
        '?':  ajuda;

        'L':  pedeContaESenha (true);
        'R':  iniciaRecepcao ('');
        'T':  iniciaEnvio ('');
        ^V:  iniciaEnvioAreaTransf;
        'D':  processaDiretorio;
        'Q':  mostraTransmitidos;
        'P':  selModoPassivo;

        'A':  apagaArquivo;
        'S':  trocaSubdiretorio;

        'V':
            begin
                verboso := not verboso;
                if verboso then
                    mensagem ('FTVERBO', 1)  {'Modo verborragico ligado'}
                else
                    mensagem ('FTNAOVRB', 1);  {'Modo verborragico desligado'}
            end;

        'I':
            begin
                if enviaComando ('PWD') then
                    falaRespostas (codigo, false, false);
            end;

        'C':  criaDiretorio;

        '/':
            begin
                mensagem ('FTCMDFTP', 1);  {'Entre o comando em codigo FTP'}
                sintReadln (s);
                if s <> '' then
                begin
                    if enviaComando (ansiToUtf8(s)) then
                        falaRespostas (codigo, true, false);
                end;
            end;

        #$1b:
            begin
                fimProg := true;
                if enviaComando ('QUIT') then
                    mostraRespostas (codigo);
                processando := false;
            end;

        #0: case c2 of
                F8: falaHora;
                CTLF8: falaDia;
                F1: ajuda;
                CIMA, BAIX, F9:
                    begin
                        c := selSetasOpcao;
                        goto executa;
                    end;
            else
                exit;
            end;

    else
        mensagem ('FTERRCMD', 1);  {'Comando inexistente'}
    end;

    { por garantia }

    while pins <> pret do
        mostraRespostas (codigo);
end;

{-------------------------------------------------------------}
{                      termina o programa
{-------------------------------------------------------------}

procedure terminaProg;
begin
    assign (arqLocal, nomeArqDir);
    {$I-}  erase (arqLocal);  {$I+}
    if ioresult <> 0 then;

    mensagem ('FTFIMPRG', 1);  {'Programa terminado'}
    sintFim;
    delay (1000);

    doneWinCrt;
end;

{-------------------------------------------------------------}
{                       programa principal
{-------------------------------------------------------------}

var ev: integer;
    s: string;
    codigo: integer;
    continua: boolean;
label fim;
begin
    if not inicializa then
        terminaProg;

    if abreConexao then
        begin
            repeat
                processaRede;
                while pins <> pret do
                    pegaResposta (s, codigo, continua);
                if (codigo <> 220) and (not continua) then
                    begin
                        mensagem ('FTERRSRV', 1);  {'Servidor não está disponível, codigo'}
                        sintWriteln (s);
                        goto fim;
                    end;
            until not continua;

            pedeContaeSenha (false);

            textBackground (BLUE);
            mensagem ('FTCMD', 0);  {'Comando ? '}
            textBackground (BLACK);

            while (processando)  do
                begin
                    if keypressed then
                        begin
                            processaTecla;

                            if (not fimProg) then
                                begin
                                    textBackground (BLUE);
                                    mensagem ('FTCMD', 0);  {'Comando ? '}
                                    textBackground (BLACK);
                                end;
                        end;

                    ev := checaEventoRede;
                    if ev = CHEGOU_REDE then
                        begin
                            processaRede;

                            while pins <> pret do
                                begin
                                    pegaResposta (s, codigo, continua);
                                    case codigo of
                                        221:  mensagem ('FTDESCON', 1);  {'Desconectando'}
                                        226:  mensagem ('FTFIMENV', 1);  {'Envio Completado'}
                                    else
                                        if not verboso then
                                            sintWriteln (s);
                                    end;

                                end;
                        end;
                end;
        end;

fim:
    fechaConexao;
    terminaProg;
end.
