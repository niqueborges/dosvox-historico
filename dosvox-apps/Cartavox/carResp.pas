{-------------------------------------------------------------}
{
{           CartaVox - Resposta Automática
{
{           Atualizado por: Neno Henrique da Cunha Albernaz
{          Em Novembro de 2015
{
{-------------------------------------------------------------}

unit carResp;

interface

uses
    dvArq,
    dvcrt,
    dvForm,
    dvWin,
    classes,
    sysUtils,
    windows,
    carDecod,
    carLeit,
    carMsg,
    carTela,
    carUtil,
    carVars,
    carEst,
    carSMTP;

procedure respostaAutomatica;
procedure ativaRespAut (preparar, ativar: boolean; nCar: integer);
function colocaRespostaCarta(var nomeArq: string): boolean;

implementation

uses
    carMonit,
    carEnvia;

var
    dir: string;

{--------------------------------------------------------}
{  seleciona a função com as setas, opções do menu
{  principal da resposta automática
{--------------------------------------------------------}

function selSetasConfig: char;
var n: integer;
const
    tabLetrasConfig: string [2] = 'EA';

begin
    popupMenuCria (wherex, wherey, 50, 2, MAGENTA);
        MenuAdiciona ('CTAJRE01'); {'E - Escrever resposta automática'}
        MenuAdiciona ('CTAJRE02'); {'A - Ativar resposta automática de férias'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= 2) then
        selSetasConfig := tabLetrasConfig[n]
    else
        selSetasConfig := ESC;
end;

{--------------------------------------------------------}
{  seleciona a função com as setas, opções de edição
{  da resposta automática
{--------------------------------------------------------}

function selSetasConfigEdicao: char;
var n: integer;
const
    tabLetrasConfig: string [2] = 'AC';

begin
    popupMenuCria (wherex, wherey, 50, 2, MAGENTA);
        MenuAdiciona ('CTAJRE03'); {'A - Editar assunto da resposta automática'}
        MenuAdiciona ('CTAJRE04'); {'C - Editar corpo da resposta automática'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= 2) then
        selSetasConfigEdicao := tabLetrasConfig[n]
    else
        selSetasConfigEdicao := ESC;
end;

{--------------------------------------------------------}
{  cria arquivo de controle da resposta automática
{  e escreve as informações necessárias nele
{--------------------------------------------------------}

function escreveArquivo (nomeArq, assunto: string): boolean;
var
    arquivoDestino, arquivoOrigem: TextFile;
    nomeArqRespAut, s: string;
    sz, szConfig: array [0..144] of char;
    cont: integer;

begin
    escreveArquivo := false;
    if arqRespAut = '' then
        begin
            if not fileExists(dirRecebe + '\' + 'respAut.ini') then
                nomeArqRespAut := dirRecebe + '\respAut.ini'
            else
                begin
                    cont := 1;
                    while fileExists(dirRecebe + '\' + 'respAut' + IntToStr(cont) + '.txt') do
                        cont := cont + 1;
                    nomeArqRespAut := dirRecebe + '\' + 'respAut' + IntToStr(cont) + '.txt';
                end;
        end
    else
        nomeArqRespAut := arqRespAut;

    AssignFile(arquivoDestino, nomeArqRespAut);
    {$i-} ReWrite(arquivoDestino); {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('CTERRDSK', 1); {'Erro de escrita no disco'}
            exit;
        end;

    AssignFile(arquivoOrigem, nomeArq);
    {$i-} Reset(arquivoOrigem); {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('CTERRLEI', 1);  {'Erro de leitura do arquivo'}
            exit;
        end;

    while not eof (arquivoOrigem) do
        begin
            {$i-} readln (arquivoOrigem, s); {$i+}
            if ioresult <> 0 then
                begin
                    mensagem ('CTERRLEI', 1);  {'Erro de leitura do arquivo'}
                    {$i-} closeFile(arquivoOrigem); {$i+}
                    if ioresult <> 0 then;
                    {$i-} closeFile(arquivoDestino); {$i+}
                    if ioresult <> 0 then;
                    exit;
                end;
            {$i-} writeln (arquivoDestino, s); {$i+}
            if ioresult <> 0 then
                begin
                    mensagem ('CTERRDSK', 1); {'Erro de escrita no disco'}
                    {$i-} closeFile(arquivoOrigem); {$i+}
                    if ioresult <> 0 then;
                    {$i-} closeFile(arquivoDestino); {$i+}
                    if ioresult <> 0 then;
                    exit;
                end;
        end;

    {$i-} closeFile(arquivoOrigem); {$i+}
    if ioresult <> 0 then;
    {$i-} closeFile(arquivoDestino); {$i+}
    if ioresult <> 0 then;

    if arqRespAut = '' then arqRespAut := nomeArqRespAut;
    strPCopy (szConfig, nomeConfiguracao);
    strPCopy (sz, nomeArqRespAut);
    sintGravaAmbiente('CARTAVOX', 'ARQRESPAUT', nomeArqRespAut);
    writePrivateProfileString(szConfig, 'ARQRESPAUT', sz, PChar(cartavoxConfigs));

    assRespAut := assunto;
    strPCopy (sz, assunto);
    sintGravaAmbiente('CARTAVOX', 'ASSRESPAUT', assRespAut);
    writePrivateProfileString(szConfig, 'ASSRESPAUT', sz, PChar(cartavoxConfigs));

    escreveArquivo := true;
end;

{--------------------------------------------------------}
{  pergunta se adiciona a assinatura na resposta automática
{--------------------------------------------------------}

function perguntaAssinatura: boolean;
var
    c: char;
    szConfig: array [0..144] of char;
begin
    perguntaAssinatura := false;
    if nomeAssinatura <> '' then
        begin
            repeat
                textBackGround (MAGENTA);
                mensagem ('CTADIASS', 0);   {'Adiciona sua assinatura ? '}
                textBackGround (BLACK);
                c := upcase(popupMenuPorLetra ('SN'));
                writeln (c);
            until c in ['S', 'N', ENTER, ESC];
            if c <> ESC then
                begin
                    strPCopy (szConfig, nomeConfiguracao);
                    if c in ['S', ENTER] then
                        begin
                            sigRespAut := true;
                            sintGravaAmbiente('CARTAVOX', 'SIGRESPAUT', 'SIM');
                            writePrivateProfileString(szConfig, 'SIGRESPAUT', 'SIM', PChar(cartavoxConfigs));
                        end
                    else
                        begin
                            sigRespAut := false;
                            sintGravaAmbiente('CARTAVOX', 'SIGRESPAUT', 'NAO');
                            writePrivateProfileString(szConfig, 'SIGRESPAUT', 'NAO', PChar(cartavoxConfigs));
                        end;
                    perguntaAssinatura := true;
                end;
        end
    else
        perguntaAssinatura := true;
end;

{--------------------------------------------------------}
{  obtém o assunto da resposta automática para a criação de
{  uma nova resposta automática
{--------------------------------------------------------}

function editaAssunto (var assunto: string): boolean;
var c: char;
begin
    assunto := '';
    repeat
        textBackground (BLACK);
        mensagem ('CTQASSRE', 1); {'Qual o assunto da resposta automática?'}
        c := sintEditaCampo (assunto, 1, wherey, 255, 80, true);
        writeln;
    until c in [ENTER, ESC];
    if c = ESC then
        editaAssunto := false
    else
        editaAssunto := true;
end;

{--------------------------------------------------------}
{  pergunta se o usuário deseja ativar a resposta automática,
{  se sim, ativa
{--------------------------------------------------------}

procedure escreveRespAtivar;
var
    c: char;

begin
    repeat
        textBackground (BLACK);
        mensagem ('CTATREAU', 1); {'Deseja ativar a resposta automática de férias?'}
        c := upcase(popupMenuPorLetra ('SN'));
        writeln;
    until c in ['S', 'N', ENTER, ESC];
    if c in ['N', ESC] then
        mensagem ('CTREAUNA', 1) {'Resposta automática de férias não foi ativada'}
    else
        begin
            monitorarRespAut;
            mensagem ('CTREAUDE', 1); {'Resposta automática de férias desativada'}
        end;
end;

{--------------------------------------------------------}
{       retorna a data de criação do arquivo passado
{--------------------------------------------------------}

function pegaDatArq (nome: string): integer;
var
    data: Integer;

begin
    data := FileAge(nome);
    pegaDatArq := data;
end;

{-------------------------------------------------------------}
{       Confirma o destino da carta
{-------------------------------------------------------------}

function confirmaDestino (nomeDest:string): boolean;
var c: char;
begin
    repeat
        textBackground (MAGENTA);
        mensagem ('CTPPREAU', 0); {'Preparando resposta automática para '}
        sintWriteln (nomeDest);
        textBackground (BLACK);
        clreol;
        mensagem ('CTCNFDST', 0);  {'Confirma destino {s/n) ? '}
        c := upcase(popupMenuPorLetra ('SN'));
        writeln;
    until c in ['S', 'N', ENTER, ESC];
        confirmaDestino := c in ['S', ENTER];
end;

{--------------------------------------------------------}
{  Prepara e transmite a resposta automática para as
{  cartas do folheamento
{--------------------------------------------------------}

procedure preparaRespAut (nCar: integer);
var
    c: char;
    i: integer;
    enviarSelecionado: boolean;
    nomeDest: string;
label esperaResp;

begin
    enviarSelecionado := false;
    if temItemSelecionado then
        begin
            repeat
esperaResp:
                mensagem ('CTREAUSE', 1); {'Deseja preparar resposta automática para as selecionadas?'}
                mensagem ('CTINFSEL', 1);{'Tecle c para conhecer as selecionadas.'}
                c := upcase(popupMenuPorLetra ('SNC'));
                writeln;
            until c in ['S', 'N', 'C', ENTER, ESC];
            if c = ESC then
                begin
                    msgBaixo ('CTDESIST');  {'Desistiu'}
                    exit;
                end;
            if c = 'C' then
                begin
                    for i := 1 to numRegs do
                        if regLido [i]^.selecionado then
                            begin
                                mensagem ('CTCARTA', 0); {'Carta'}
                                write (' ');
                                sintWriteInt (i);
                                writeln;
                                mensagem ('CTENVPOR', 0); {'Enviada por '}
                                sintWriteln ( regLido [i]^.carta^.from);
                                mensagem ('CTASSUNT', 0); {'Assunto: '}
                                sintWriteln (regLido[i]^.carta^.subject);
                            end;
                    goto esperaResp;
                end;
            enviarSelecionado := upcase (c) in ['S', ENTER];
        end;

    if not enviarSelecionado then
        begin
            nomeDest := regLido [nCar]^.carta^.from;
            if not confirmaDestino (nomeDest) then
                begin
                    msgBaixo ('CTDESIST');  {'Desistiu'}
                    exit;
                end
            else
                begin
                    if prepararCartaRespAut (nCar, false) then
                        msgBaixo ('CTCARPRP')  {'Carta preparada para envio'}
                end;
        end
    else
        begin
             for i := 1 to numRegs do
                if regLido [i]^.selecionado then
                    if not prepararCartaRespAut (i, false) then break;
            mensagem ('CTCARPRS', 1); {'Cartas preparadas para envio'}
        end;
end;

{--------------------------------------------------------}
{  pergunta ao usuário o assunto e o texto da resposta automática
{  para a criação de uma nova resposta automática e chama a função
{  'escreveArquivo' para criar o arquivo de controle que guarda
{  estas informações
{--------------------------------------------------------}

function perguntaNovaResp: boolean;
var
    assunto, nomeArq, dirAtual: string;
    editar: boolean;
begin
    perguntaNovaResp := false;
    if not editaAssunto(assunto) then exit;

    dir := ExtractFilePath(ParamStr(0));
    Delete(dir, Length(dir), 1);
    getDir (0, dirAtual);
    {$I-}  chdir (dir);  {$I+}
    if ioresult <> 0 then ;
    nomeArq := escolheNomeArq (editar, dir);
    {$I-}  chdir (dirAtual);  {$I+}
    if ioresult <> 0 then ;

    if trim (nomeArq) = '' then exit;
    if editar then
        begin
            mensagem ('CTABREDI', 1);  {'Abrindo editor'}
            editaArquivo (nomeArq);
            limpaBufTec;
            sintBip;
        end;

    if perguntaAssinatura then
        if escreveArquivo(nomeArq, assunto) then
            perguntaNovaResp := true;
end;

{--------------------------------------------------------}
{  edita o texto da resposta automática e grava ele no arquivo
{  de controle da resposta automática
{--------------------------------------------------------}

procedure perguntaEditaTextoRespAut;
begin
    // Abre o arquivo temporário para edição
    mensagem ('CTABREDI', 1);  {'Abrindo editor'}
    editaArquivo (arqRespAut);
    limpaBufTec;
    sintBip;

    if perguntaAssinatura then;
    msgBaixo ('CTOK'); {'OK'}
end;

{--------------------------------------------------------}
{  edita o assunto da resposta automática e grava ele no
{  arquivo de controle da resposta automática
{--------------------------------------------------------}

procedure perguntaEditaAssuntoRespAut;
var
    assunto: string;
    c: char;
    sz, szConfig: array [0..144] of char;

begin
    assunto := trim(assRespAut);
    repeat
        textBackground (BLACK);
        mensagem ('CTEASSUN', 1); {'Editore o assunto da carta'}
        sintetiza (assunto);
        c := sintEditaCampo (assunto, 1, wherey, 255, 80, true);
        writeln;
    until c in [ENTER, ESC];

    if c = ESC then
        msgBaixo ('CTDESIST')   {'Desistiu...'}
    else
        begin
            assRespAut := assunto;
            strPCopy (szConfig, nomeConfiguracao);
            strPCopy (sz, assunto);
            sintGravaAmbiente('CARTAVOX', 'ASSRESPAUT', assRespAut);
            writePrivateProfileString(szConfig, 'ASSRESPAUT', sz, PChar(cartavoxConfigs));
            msgBaixo ('CTOK'); {'OK'}
        end;
end;

{-------------------------------------------------------------}
{       anexa assinatura a resposta automática
{-------------------------------------------------------------}

function anexaAssinaturaRespAut (nomeArq: string; arqVazio: boolean): string;
var
    arqAssina, arqNovo: text;
    nomeArqNovo, s: string;
    tempPath, tempFileName: array [0..144] of char;
    i: integer;
begin
    anexaAssinaturaRespAut := nomeArq;
    if nomeAssinatura = '' then exit;
    if nomeArq = '' then exit;
    if not sigRespAut then exit;
    getTempPath (144, tempPath);
    GetTempFileName(tempPath, 'RES', 0, TempFileName);
    nomeArqNovo := strPas(TempFileName);

    if arqVazio then
        begin
            assign (arqNovo, nomeArqNovo);
            {$I-} rewrite (arqNovo); {$I+}
            if ioresult <> 0 then
                begin
                    msgBaixo ('CTERRDSK');   {'Erro de escrita no disco'}
                    exit;
                end;
        end
    else
    if not arqVazio and carregaLinhasArquivo (nomeArq) then
        begin
            assign (arqNovo, nomeArqNovo);
            {$I-} rewrite (arqNovo); {$I+}
            if ioresult <> 0 then
                msgBaixo ('CTERRDSK')   {'Erro de escrita no disco'}
            else
            if linhasArquivo.count < 1 then
                arqVazio := true
            else
            for i := 0 to (linhasArquivo.count-1) do
                begin
                    {$I-}  writeln (arqNovo, linhasArquivo[i]);   {$I+}
                    if ioresult <> 0 then
                        begin
                            msgBaixo ('CTERRDSK');   {'Erro de escrita no disco'}
                            break;
                        end;
                end;
            destroiLinhasArquivo;
        end
    else
        exit;

    if arqVazio then
        begin
            {$I-}  writeln (arqNovo, '');   {$I+}
            if ioresult <> 0 then;
        end;

    assign (arqAssina, nomeAssinatura);
    {$I-}  reset (arqAssina);  {$I+}
    if ioresult = 0 then
    while not eof (arqAssina) do
        begin
            {$I-}  readln (arqAssina, s);  {$I+}
            if ioresult = 0 then
                begin
                    {$I-}  writeln (arqNovo, s);   {$I+}
                    if ioresult <> 0 then
                        begin
                            msgBaixo ('CTERRDSK');   {'Erro de escrita no disco'}
                            break;
                        end;
                end;
        end;

    {$I-} close (arqNovo); {$I+}
    if ioresult <> 0 then;
    {$I-} close (arqAssina); {$I+}
    if ioresult <> 0 then;

    anexaAssinaturaRespAut := nomeArqNovo;
end;

{-------------------------------------------------------------}
{     Coloca a resposta na carta da resposta automática
{-------------------------------------------------------------}

function colocaRespostaCarta(var nomeArq: string): boolean;
var
    i: integer;
    arquivoDestino, arquivoOrigem: TextFile;
    vetorMsg : TStringList;
    s, arquivoTemp, nomeArqRespAut: string;

label fim;
begin
    colocaRespostaCarta := false;
    //nomeArqRespAut recebe o nome do arquivo da resposta automática
    if arqRespAut <> '' then
        nomeArqRespAut := arqRespAut
    else
        begin
            mensagem ('CTERESPA', 1);   {'Erro no arquivo da resposta automática'}
            exit;
        end;

    arquivoTemp := anexaAssinaturaRespAut (nomeArqRespAut, false);

    AssignFile(arquivoOrigem, nomeArq);
    {$I-} Reset(arquivoOrigem); {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('CTERRLEI',1);  {'Erro de leitura do arquivo'}
            exit;
        end;

    vetorMsg := TStringList.Create;
    while not eof (arquivoOrigem) do
        begin
            {$I-} readln (arquivoOrigem, s); {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('CTERRLEI', 1);  {'Erro de leitura do arquivo'}
                    goto fim;
                end;
            vetorMsg.add (s);
        end;

    {$i-} CloseFile(arquivoOrigem); {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('CTERFECH', 1);  {'Erro ao fechar o arquivo'}
            goto fim;
        end;

    AssignFile(arquivoOrigem, arquivoTemp);
    {$i-} Reset(arquivoOrigem); {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('CTERRLEI', 1);  {'Erro de leitura do arquivo'}
            goto fim;
        end;
    AssignFile(arquivoDestino, nomeArq);
    {$i-} Rewrite(arquivoDestino); {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('CTERRDSK', 1); {'Erro de escrita no disco'}
            goto fim;
        end;
    while not eof (arquivoOrigem) do
        begin
            {$i-} readln (arquivoOrigem, s); {$i+}
            if ioresult <> 0 then
                begin
                    mensagem ('CTERRLEI', 1);  {'Erro de leitura do arquivo'}
                    goto fim;
                end;
            {$i-} writeln (arquivoDestino, s); {$i+}
            if ioresult <> 0 then
                begin
                    mensagem ('CTERRDSK', 1);  {'Erro de escrita no disco'}
                    goto fim;
                end;
        end;
    {$i-} CloseFile(arquivoOrigem); {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('CTERFECH', 1);  {'Erro ao fechar o arquivo'}
            goto fim;
        end;

    if arquivoTemp <> nomeArqRespAut then
        if not deletaArquivo (arquivoTemp) then
            mensagem ('CTERRTMP', 1); {'Problemas no arquivo temporário'}

    for i := 0 to (vetorMsg.count -1) do
        begin
            {$i-} writeln(arquivoDestino, vetorMsg[i]); {$i+}
            if ioresult <> 0 then
                begin
                    mensagem ('CTERRDSK', 1);  {'Erro de escrita no disco'}
                    goto fim;
                end;
        end;
    {$i-} CloseFile(arquivoDestino); {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('CTERFECH', 1);  {'Erro ao fechar o arquivo'}
            goto fim;
        end;

    colocaRespostaCarta := true;
fim:
    vetorMsg.free;
end;

{--------------------------------------------------------}
{       ajuda do menu principal da resposta automática
{--------------------------------------------------------}

procedure ajudaConfig;
begin
    writeln;
    if not keypressed then
        mensagem ('CTAJUD01', 2); {'As opções são'}
    if not keypressed then
        mensagem ('CTAJRE01', 1);{'   E - Escrever Resposta automática'}
    if not keypressed then
        mensagem ('CTAJRE02', 1);{'   A - Ativar Resposta automática de férias'}
end;

{--------------------------------------------------------}
{       ajuda do menu de edição da resposta automática
{--------------------------------------------------------}

procedure ajudaConfigEdicao;
begin
    writeln;
    textBackground (BLUE);
    mensagem ('CTAJUD01', 1); {'As opções são'}
    textBackground (BLACK);
    if not keypressed then
        mensagem ('CTAJRE03', 1);{'   A - Editar o assunto da resposta automática'}
    if not keypressed then
        mensagem ('CTAJRE04', 1);{'   C - Editar o corpo da resposta automática'}
end;

{--------------------------------------------------------}
{  escreve uma nova resposta automática se ela ainda não foi escrita ou
{  entra no menu de edição se a resposta automática já foi escrita.
{  No final chama a rotina para enviar resposta automática
{--------------------------------------------------------}

procedure escreveRespAut (preparar, ativar: boolean; nCar: integer);
var
    c, c2: char;
    respEmBranco: boolean;
label desistiu, continuaMenu;

begin
    respEmBranco := false;

    if (arqRespAut = '') or (not fileExists (arqRespAut)) then respEmBranco := true;

    if respEmBranco then
        begin
            if not perguntaNovaResp then
                msgBaixo ('CTDESIST') {'Desistiu ...'}
            else
                begin
                    msgBaixo('CTREAUPP'); {'Resposta automática preparada'}
                    if preparar then preparaRespAut (nCar);
                    if ativar then escreveRespAtivar;
                end;
        end
    else
        begin
            mensagem ('CTEXREAU', 2); {'Já existe uma resposta automática configurada.'}
continuaMenu:
            textBackground (BLACK);
            mensagem ('CTQUALOP', 0); {'Qual sua opção ? '}
            mensagem ('CTF1AJUD', 0); {'F1 ajuda '}
            sintLeTecla (c, c2);
            writeln;

            if c = #0 then
                if c2 = F1 then
                    begin
                        ajudaConfigEdicao;
                        goto continuaMenu;
                    end
                else if c2 in [BAIX, CIMA] then
                    c := selSetasConfigEdicao;

            case upcase (c) of
                'A': perguntaEditaAssuntoRespAut;
                'C': perguntaEditaTextoRespAut;
            else
                msgBaixo ('CTDESIST'); {'Desistiu ...'}
            end;
    end;
end;

{--------------------------------------------------------}
{  se existe resposta automática, pergunta se o usuário deseja
{  ativá-la ou enviá-la, caso contrário, pergunta se o usuário
{  deseja escrevê-la
{--------------------------------------------------------}

procedure ativaRespAut (preparar, ativar: boolean; nCar: integer);
var
    respAutExiste: boolean;
    var c: char;
label desistiu;
begin
    respAutExiste := false;

    if (arqRespAut <> '') and (fileExists (arqRespAut)) then respAutExiste := true;

    if not respAutExiste then
        begin
            repeat
                textBackground (BLACK);
                mensagem ('CTMEAUNE', 1); {'A resposta automática não foi escrita, deseja escrevê-la agora?'}
                c := upcase(popupMenuPorLetra ('SN'));
                writeln;
            until c in ['S', 'N', ENTER, ESC];
            if c in ['N', ESC] then goto desistiu
            else escreveRespAut (preparar, ativar, nCar);
            exit;
        end
    else
        begin
            if preparar then
                preparaRespAut (nCar)
            else
                escreveRespAtivar;
        end;
    exit;

desistiu:
    mensagem ('CTDESIST', 1);   {'Desistiu...'}
end;

{--------------------------------------------------------}
{       execução do menu principal da resposta automática
{--------------------------------------------------------}

procedure respostaAutomatica;
var c, c2: char;
label inicioResp;
begin
inicioResp:
    telaPrincipal;
    textBackground (BLUE);
    mensagem ('CTRESAUT', 1); {'Resposta automática'}
    textBackground (BLACK);
    mensagem ('CTQUALOP', 0); {'Qual sua opção ? '}
    mensagem ('CTF1AJUD', 0); {'F1 ajuda '}
    sintLeTecla (c, c2);
    writeln;

    if (c = #0) and ((c2 = BAIX) or (c2 = CIMA)) then
        c := selSetasConfig
    else
    if c = #0 then
        begin
            ajudaConfig;
            goto inicioResp;
        end;

    case upcase (c) of
        'E':  escreveRespAut (false, false, 0);
        'A':  ativaRespAut (false, true, 0);
    else
        if c <> ESC then
            msgBaixo ('CTOPCINV')  {'Opção inválida'}
        else
            msgBaixo ('CTDESIST');  {'Desistiu'}
    end;

end;

end.
