{ --------------------------------------------------------}
{
{    Mini gravador de som
{
{    Por José Antonio Borges
{        Mara Lúcia Caldeira
{        Marcolino Matheus de Souza Nascimento
{
{    Versão 1.0 Em 29/05/98
{    Versão 2.0 em maio/2006
{    Versão 3.0 em fevereiro/2016
{
{--------------------------------------------------------}

program minigrav;

uses
  dvcrt, dvwin, dvform, dvarq, dvwav,
  windows, messages, sysutils, mmsystem,
  grAmost,  mgVars, mgMsg, mgEfeito, mgefeitoSox, mgmp3,
  mgdivide, mgconfig, mgArquivo, mgRemove,
  mgToca, mgMistura, mgGrava;

{---------------------------------------------------------------------}

procedure checarSox;  //Patrick
begin
    if not fileExists(dirSox) then
    begin
        if sintFalarTudo then
            begin
            mensagem ('MGPGNAOENC', 0); {'Programa não encontrado'}
            sintWriteln(dirSox);
            mensagem ('MGEFND', 0); {'Alguns efeitos não estarão disponíveis'}
        end;
        sox_existe := false;
    end
    else
        sox_existe := true;
end;

{---------------------------------------------------------------------}

procedure inicializa;
var dir: string;
begin
    clrscr;
    setWindowText (crtWindow, 'GRAVADOR DE SOM');

    getDir (0, dirTrab);
    if dirTrab [length (dirTrab)] <> '\' then dirTrab := dirTrab + '\';

    dir := sintAmbiente ('MINIGRAV', 'DIRMINIGRAV');
    if dir = '' then
        dir := 'c:\winvox\som\minigrav';

    qualidade := sintAmbiente ('MINIGRAV', 'QUALIDADE');
    if qualidade = '' then
        qualidade := '44100';
        rAmostra := strToInt(qualidade);
    sintGravaAmbiente('MINIGRAV', 'QUALIDADE',  qualidade);

    dirSox := sintAmbiente ('MINIGRAV', 'DIRSOX');
    if dirSox = '' then
        dirSox := sintAmbiente('DOSVOX', 'PGMDOSVOX')+'\sox\sox.exe';

    sintInic (0, dir);

    mensagem ('MGINIC', 0);  {'Gravador de som'}
    write (' - v.');
    if sintFalarTudo then
        begin
            sintSoletra (VERSAO);
            Write (VERSAO);
            if TIPOVERSAO <> '' then sintWrite(' '+TIPOVERSAO);
            writeln;
            writeln;
            mensagem ('MGGLC', 0);  {'Um tributo a Glauco Férius Constantino'}
        end
    else
        begin
            Write (VERSAO);
            if TIPOVERSAO <> '' then sintWrite(' '+TIPOVERSAO);
            writeln;
            writeln;
            write (pegaTextoMensagem('MGGLC'));  {'Um tributo a Glauco Férius Constantino'}
        end;

    writeln;
    writeln;
    while sintFalando do waitMessage;

    nomeArq := '';
    som:= TAmostras.Create;
    cursor := 0;
    marca := 0;

    checarSox;  //Patrick
    configPadrao;
    pegaParamConfig;
    som.maxMemoria := maxMemoria * 1024 * 1024;
end;

{--------------------------------------------------------}

function finaliza: boolean;
var opcao: char;
    c, c2: char;
begin
    finaliza := false;
    mensagem ('MGCONFIM', 0); {'Confirma o fim do programa ? '}
    opcao:= popupMenuPorLetra('SN');
    writeln;

    if upcase(opcao) <> 'S' then
        exit;

    if (nomeArq <> '') or (som.numAmostras <> 0) then
        begin
            mensagem ('MGQUERSV', 0);   {'Quer salvar arquivo atual? '}
            sintLeTecla (c, c2);
            writeln;
            if c = ESC then exit;

            if upcase(c) <> 'N' then
                begin
                    salvaArquivoRapido;
                    veSeSalvaMP3 (nomeArq );
                end;
        end;

    som.free;
    DeleteFile(pchar(arqtemp1));
    finaliza := true;
end;

{--------------------------------------------------------}

procedure desfaz;
var c, c2: char;
begin
    mensagem ('MGCNFUND', 0);   {'Vou recuperar a última versão salva, confirma? '}
    sintLeTecla (c, c2);
    writeln;
    if upcase (c) <> 'S' then exit;

    som.leArquivo(nomeArq);
    mensagem ('MGUNDO', 1);  {'Voltei ao último arquivo gravado'}
end;

{--------------------------------------------------------}

procedure infoSom;
var s: string;
begin
    mensagem ('MGARQTRB', 0);           {'Arquivo de trabalho: '}
    s := nomeArq;
    if maiuscAnsi (copy (s, length(s)-7, 8)) = '.MP3.WAV' then
        delete (s, length(s)-3, 4);
    sintWriteln (s);

    mensagem ('MGIVEL', 0);             {'Velocidade: '}
    sintWriteint (som.velocidade);
    writeln;

    mensagem ('MGIQUALI', 0);           {'Qualidade: '}

    if som.bitsPorAmostra = 8 then
        mensagem ('MGI8BIT',  1)        {'8 Bits '}
    else
        mensagem ('MGI16BIT', 1);       {'16 Bits '}

    if som.canais = 1 then
        mensagem ('MGIMONO', 1)         {'Mono'}
    else
        mensagem ('MGISTERE', 1);       {'Stereo'}

    while sintFalando do waitMessage;
    writeln;
end;

{--------------------------------------------------------}

procedure ajudaPrincipal;
begin
    textBackground (RED);
    mensagem ('MGASOPC',1); {'As opções são:'}
    textBackground (BLACK);
    writeln;

    mensagem ('MGTOCA', 1);   {'T - Toca'}
    mensagem ('MGGRAVA', 1);  {'G - Grava mais'}
    mensagem ('MGNOVO', 1);   {'N - Novo som'}
    mensagem ('MGREMOVE', 1); {'R - Remove'}
    mensagem ('MGMIXA', 1);   {'M - Mistura'}
    mensagem ('MGEFEIT', 1);  {'E - Efeito'}
    mensagem ('MGDESFAZ', 1); {'D - Desfaz'}
    mensagem ('MGSALVA', 1);  {'S - Salva'}
    mensagem ('MGEXTRAI', 1); {'X - Extrai'}
    mensagem ('MGCONFIG', 1); {'C - Configura'}
    mensagem ('MGPARTE', 1); {'P - Parte'}
    mensagem ('MGINFO', 1);   {'I - Informações'}
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

procedure MenuAdiciona (msg: string);
begin
    popupMenuAdiciona (msg, pegaTextoMensagem (msg));
end;

{--------------------------------------------------------}

function selSetasPrincipal: char;
var n: integer;

const tabLetrasOpcoes: string = 'tgnrmedsxcpi';
var nopc: integer;

begin

    nopc := length (tabLetrasOpcoes);
    garanteEspacoTela(nopc);
    popupMenuCria (wherex, wherey, 18, nopc, MAGENTA);
    menuAdiciona ('MGTOCA');    {'T - Toca'}
    menuAdiciona ('MGGRAVA');   {'G - Grava mais'}
    menuAdiciona ('MGNOVO');    {'N - Novo som'}
    menuAdiciona ('MGREMOVE');  {'R - Remove'}
    menuAdiciona ('MGMIXA');    {'M - Mistura'}
    menuAdiciona ('MGEFEIT');   {'E - Efeito'}
    menuAdiciona ('MGDESFAZ');  {'D - Desfaz'}
    menuAdiciona ('MGSALVA');   {'S - Salva'}
    menuAdiciona ('MGEXTRAI');  {'X - Extrai'}
    menuAdiciona ('MGCONFIG');  {'C - Configura'}
    menuAdiciona ('MGPARTE');  {'P - Parte o arquivo'}
    menuAdiciona ('MGINFO');    {'I - Informações'}

    n := popupMenuSeleciona;

    if (n > 0) and (n <= nopc) then
        selSetasPrincipal := tabLetrasOpcoes[n]
    else
        selSetasPrincipal := ESC;
end;

{--------------------------------------------------------}
{               ciclo de processamento geral
{--------------------------------------------------------}

procedure menuPrincipal;
var
    processando: boolean;
    c, c2: char;
label executa;
begin
    processando := true;
    while processando do
        begin
            while keypressed do readkey;

            textBackground (BLUE);
            mensagem ('MGOPMG', 0);   {'Gravador, qual sua opcao? '}
            textBackground (BLACK);

            sintLeTecla (c, c2);
            writeln;

            if c = #$0 then
                begin

                    if c2 = HOME then
                        begin
                            sintSoletra (VERSAO);
                            if TIPOVERSAO <> '' then sintetiza (TIPOVERSAO);
                            delay(100);
                            mensagem ('MGGLC', -1);  {'Um tributo a Glauco Férius Constantino'}
                        end
                    else
                    if c2 = DEL then
                        clrscr
                    else
                    if c2 = F1 then
                        ajudaPrincipal
                    else
                    if c2 = F2 then
                        salvaArquivoRapido
                    else
                    if c2 = F3 then
                    begin
                        mensagem ('MGQUERSV', 0);   {'Quer salvar arquivo atual? '}
                        sintLeTecla (c, c2);
                        writeln;
                        if upcase(c) <> 'N' then
                            salvaArquivoRapido;
                        nomeArq := '';
                        carregaSom;
                        mensagem ('MGOK', 1);
                    end
                    else
                    if (c2 = CIMA) or (c2 = BAIX) then
                        begin
                            c := selSetasPrincipal;
                            goto executa;
                        end
                end
            else
               begin
        executa:
                    case upcase(c) of
                        'I': infoSom;
                        'T': tocaSom;
                        'G': gravaMais;
                   'A', 'R': trataRemocao;
                        'M': misturaOutroSom;
                        'E': menuEfeito;
                        'S': salvaArquivo (nomeArq);
                        ^S:
        begin
            salvaArquivoRapido;
            veSeSalvaMP3 (nomeArq );
    delay (3);
        SintFim;
        doneWinCrt;
        end;
                        'X': extraiArquivo;
                        ^X: begin
    delay (3);
        SintFim;
        doneWinCrt;
                        end;
                        'P': extraiTrechoMarcado (nomeArq);
                        'C': configura;
                        'N': novaGravacao;
                        'D': desfaz;
                        ESC: if finaliza then
                                 processando := false;
                    else
                    if c <> ESC then
                        mensagem ('MGOPINV', 2); {'Opção inválida, F1 ajuda'}
                    end;
                end;
        end;
end;

{--------------------------------------------------------}

procedure termina;
begin
    mensagem ('MGFIM', 1);      {'Fim do programa'}
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}

begin
    inicializa;

    obtemNomeArquivo (true);
    if nomeArq <> '' then
        begin
            if not FileExists(nomeArq) then
                 gravaSomInicial;

            carregaSom;
            arqtemp1 := GetTempDir+ExtractFileName(nomeArq); // salva memória em temp
        end;

    writeln;
    menuPrincipal;

    termina;
end.
