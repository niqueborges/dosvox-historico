{-------------------------------------------------------------}
{
{    Programa de Transferência Remota de Arquivos
{
{    Rotina para ler diretorio remoto
{
{    Autor: Jose' Antonio Borges
{
{    Em 21/04/98
{
{-------------------------------------------------------------}

unit ftpArq;
interface

uses
dvCrt, dvWin, dvarq, dvform, sysUtils, winsock, winprocs,
    ftpVars, ftpMsg, ftpDlg, ftpPort, ftpRede;

function iniciaEnvio (nomeArqLocal: string): boolean;
procedure iniciaEnvioAreaTransf;
procedure iniciaRecepcao (nomeDesejado: string);
procedure apagaArquivo;

implementation

{-------------------------------------------------------------}
{                   inicia envio de arquivo
{-------------------------------------------------------------}

function selModo (pegouAreaTransf: boolean): boolean;
var c: char;
    modoTransm: char;
    codigo: integer;
begin
    result := false;

    if pegouAreaTransf then
        c := 'S'
    else
        begin
            mensagem ('FTMODIMG', 0);  {'Devo usar o modo imagem (sugiro que sim) ? '}
            c := popupMenuPorLetra('SN');
        end;

    if c = ESC then
        begin
            mensagem ('FTDESIS', 2);   {'Desistiu'}
            exit;
        end;

    writeln (c);
    if upcase (c) = 'N' then
        modoTransm := 'A'
    else
        modoTransm := 'I';

    if enviaComando ('TYPE ' + modoTransm) then
        mostraRespostas (codigo)
    else
        begin
            mensagem ('FTERRMOD', 1);  {'Problemas ao selecionar modo de transmissão'}
            exit;
        end;

    result := true;
end;

{-------------------------------------------------------------}
{                   inicia envio de arquivo
{-------------------------------------------------------------}

function iniciaEnvio (nomeArqLocal: string): boolean;
var
    c: char;
    codigo, ev: integer;
    pegouAreaTransf: boolean;
    s: string;
    continua: boolean;
    tituloJan: array [0..144] of char;

label fim, cancelaTudo;
begin
    result := false;
    textBackGround (MAGENTA);
    if sintFalarTudo then mensagem ('FTTRANSM', 0)  {'Transmitir'}
    else                  write (pegaTextoMensagem('FTTRANSM'));  {'Transmitir'}
    textBackground (BLACK);
    writeln;

    pegouAreaTransf := nomeArqLocal <> '';

    if not  pegouAreaTransf then
        begin
            mensagem ('FTNOMLOC', 0);  {'Qual o nome do arquivo local ? '}
            garanteEspacoTela(6);
            nomeArqLocal := obtemNomeArq(6);
        end;

    writeln (nomeArqLocal);
    if nomeArqLocal = '' then exit;

    assign (arqLocal, nomeArqLocal);
    {$I-}  reset (arqLocal, 1);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('FTARQNAO', 1);  {'Arquivo não existe...'}
            exit;
        end;

    nomeArqHost := '';
    if not pegouAreaTransf then
        begin
            mensagem ('FTNOMREM', 0);  {'Qual o nome do arquivo remoto ? '}
            c := sintEditaCampo (nomeArqHost, 1, wherey, 255, 80, true);
            writeln;
            if c = ESC then
                begin
                    mensagem ('FTDESIS', 1);  {'Desistiu ...'}
                    goto cancelaTudo;
                end;
        end;

    if trim(nomeArqHost) = '' then
        begin
            nomeArqHost := nomeArqLocal;
            while pos ('\', nomeArqHost) <> 0 do
                delete (nomeArqHost, 1, pos ('\', nomeArqHost));
            writeln ('(Assumindo ', nomeArqHost, ')');
        end;

    if not selModo (pegouAreaTransf) then exit;

    if not modoPassivo then
        trocaPortaLocal
    else
        if not trocaPortaPassiva then exit;

    if not abreConexaoArq then
        goto cancelaTudo
    else
        begin
            totalTransmitido := 0;
            if enviaComando ('STOR ' + ansiToUtf8(nomeArqHost)) then
                begin
                    mostraRespostas (codigo);
                    if (codigo <> 125) and (codigo <> 150) then
                        begin
                            mensagem ('FTTRAREC', 1);  {'Transferência de arquivo foi recusada'}
                            fechaConexaoArq;
                            exit;
                        end
                    else
                        begin
                            while (not eof (arqLocal)) and (processaTransf (ev)) do
                                begin
                                    enviaCanalArq;

                                    str ((totalTransmitido+1023) div 1024, s);
                                    strPCopy (tituloJan, copy(s + 'K ' + nomeArqHost + ' - FTPVOX ' + nomeHost, 1, 75));
                                    setWindowText (crtWindow, tituloJan);

                                    if keypressed then
                                        begin
                                            c := readkey;
                                            case c of
                                               #$1b:  if enviaComando ('ABOR') then
                                                           begin
                                                               mostraRespostas (codigo);
                                                               fechaConexaoArq;
                                                               exit;
                                                           end;
                                            else
                                                mostraTransmitidos;
                                            end;
                                            limpaBufTec;
                                        end;

                                    while pins <> pret do
                                        begin
                                            pegaResposta (s, codigo, continua);
                                            if (codigo <> 226) and (codigo <> 250) then
                                                begin
                                                    sintBip;
                                                    textColor (RED);
                                                    mensagem ('FTERRENV', 1);  {'Erro no envio dos dados, código'}
                                                    sintWriteln (s);
                                                    textColor (WHITE);
                                                    goto fim;
                                                end;
                                        end;

                                end;

                            result := true;
                        end;
                end;

        end;

    if not pegouAreaTransf then
        mensagem ('FTFIMENV', 1);  {'Envio completado'}
    strPCopy (tituloJan, 'FTPVOX ' + nomeHost);
    setWindowText (crtWindow, tituloJan);

fim:
    fechaConexaoArq;

    processaRede;
    mostraRespostas (codigo);

cancelaTudo:
    {$I-}  close (arqLocal);  {$I+}
    if ioresult <> 0 then;
end;

{--------------------------------------------------------}
{                   Transmite arquivos com nome na área de transferência.
{--------------------------------------------------------}

procedure iniciaEnvioAreaTransf;
var
    i: integer;
    s: string;
    buf: PChar;
    hmem: THandle;
    totalEnviados: integer;
Begin
    if not openClipboard (crtWindow) then exit;
    hmem := getClipboardData (CF_TEXT);
    if hmem = 0 then
        begin
            closeClipboard;
            exit;
        end;

    limpaBufTec;
    sintclek; sintclek;
    buf := globalLock (hmem);

    totalEnviados := 0;
    i := 0;
    while i < length(buf) do
        begin
            s := '';

            while (buf[i] <> #$0a) and (buf[i] <> #$0) do
                begin
                    if buf[i] <> #$0d then
                        s := s + buf[i];
                    inc(i);
                    if (buf[i] = #$0d) or (buf[i] = #$0a) then break;
                end;

            s := trim (s);
            if s <> '' then
                if not iniciaEnvio (s) then break
                else inc(totalEnviados);

            inc(i);
        end;

    globalUnlock (hmem);
    closeClipboard;

    limpaBufTec;
    if totalEnviados > 0 then
        begin
            mensagem ('FTFIMENV', 0);  {'Envio completado'}
            if totalEnviados > 1 then sintWrite (' ' + intToStr(totalEnviados));
            writeln;
        end;
end;

{--------------------------------------------------------}
{                   seleciona diretório preferido
{--------------------------------------------------------}

function selecDirPreferido (var diretorio: string): boolean;
const
    MAXPREFERIDOS = 50;
var
    n, i, p, nprefs: integer;
    s: string;
    dir: array [1..MAXPREFERIDOS] of string;
    np: integer;

begin
    diretorio := '';
    writeln;
    nprefs := 0;
    for i := 1 to MAXPREFERIDOS do
        if sintAmbiente ('PREFERIDOS', 'DIRPREF' + intToStr (i)) <> '' then
            inc(nprefs);

    popupMenuCria (49, wherey, 30, nprefs, RED);
    np := 0;
    for i := 1 to MAXPREFERIDOS do
        begin
            s := sintAmbiente ('PREFERIDOS', 'DIRPREF' + intToStr (i));
            if s <> '' then
                begin
                    inc(np);
                    p := pos (',', s);
                    dir [np] := copy (s, 1, p-1);
                    popupMenuAdiciona ('', copy (s, p+1, length(s)));
                end;
        end;

    popupMenuOrdena;
    n := popupMenuSeleciona;

    if n > 0 then
        begin
            diretorio := dir [n];
            if diretorio[length(diretorio)] <> '\' then diretorio := diretorio + '\';
            result := true;
        end
    else
        result := false;
end;

{-------------------------------------------------------------}
{                 inicia recepcao de arquivo
{-------------------------------------------------------------}

procedure iniciaRecepcao (nomeDesejado: string);
var
    c: char;
    i, ev, codigo: integer;
    s: string;
    tituloJan: array [0..144] of char;

label ok, fim;
begin
    textBackGround (MAGENTA);
    mensagem ('FTRECEBE', 0);  {'Receber'}
    textBackground (BLACK);
    writeln;

    if nomeDesejado = '' then
        begin
            mensagem ('FTNOMREM', 0);  {'Qual o nome do arquivo remoto ? '}
            sintReadln (nomeArqHost);
            if nomeArqHost = '' then exit;
        end
    else
        nomeArqHost := nomeDesejado;

    mensagem ('FTNOMLOC', 0);  {'Qual o nome do arquivo local ? '}
    nomeArqLocal := nomeArqHost;
    c := sintEdita (nomeArqLocal, 1, wherey, 250, true);

    if c = ESC then exit;
    if (c = CIMA) or (c = BAIX) then
        if selecDirPreferido (s) then
            begin
                nomeArqLocal := s + nomeArqHost;
                writeln ('(Assumindo nomes idênticos)');
            end;

    if nomeArqLocal = '' then
        begin
            nomeArqLocal := nomeArqHost;
            writeln ('(Assumindo nomes idênticos)');
        end;
    assign (arqLocal, nomeArqLocal);

    {$I-}  rewrite (arqLocal, 1);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('FTNAOCRI', 1);  {'Não consegui criar o arquivo local'}
            exit;
        end;

    if not selModo (false) then exit;

    if not modoPassivo then
        trocaPortaLocal
    else
        if not trocaPortaPassiva then exit;

    if abreConexaoArq then
        begin
            totalTransmitido := 0;
            if enviaComando ('RETR ' + ansiToUtf8(nomeArqHost)) then
                begin
                    mostraRespostas (codigo);
                    if (codigo = 125) or (codigo = 150) then
                        goto ok;
                end;
        end;

    if codigo = 550 then
        begin
            mensagem ('FTARQNAO', 1);  {'Arquivo não existe...'}
            close (arqLocal);
            erase (arqLocal);
        end;

    mensagem ('FTTRAREC', 1);  {'Transferência de arquivo foi recusada'}
    goto fim;

ok:
    while processaTransf (ev) do
        begin
            str ((totalTransmitido+1023) div 1024, s);
            strPCopy (tituloJan, 'FTPVOX ' + nomeHost + ' ' + s + 'K');
            setWindowText (crtWindow, tituloJan);

            if pins <> pret then
                mostraRespostas (codigo);

            if keypressed then
                case upcase (readkey) of
                   #$1b:  if enviaComando ('ABOR') then
                               begin
                                   mostraRespostas (codigo);
                                   exit;
                               end;
                else
                    begin
                         mostraTransmitidos;
                         while keypressed do readkey;
                    end;
                end;

            if ev = -1 then delay (100);   {deixa maquina mais leve}
        end;

    i := 0;
    repeat
         delay (500);
         processaTransf (ev);
         i := i + 1;
         if pins <> pret then
             mostraRespostas (codigo);
    until (pins <> pret) or (i > 10) or (codigo = 226) or (codigo = 250) or (codigo = 425);

    if (codigo <> 226) and (codigo <> 250) then
        begin
            sintBip;
            textColor (RED);
            mensagem ('FTERRENV', 1);  {'Erro no envio dos dados, código'}
            sintWriteln (s);
            textColor (WHITE);
            goto fim;
        end;

    mensagem ('FTFIMREC', 1);  {'Recepção completada'}
fim:
    strPCopy (tituloJan, 'FTPVOX ' + nomeHost);
    setWindowText (crtWindow, tituloJan);
    fechaConexaoArq;
end;

{-------------------------------------------------------------}
{                         apaga um arquivo
{-------------------------------------------------------------}

procedure apagaArquivo;
var nome: string;
    codigo: integer;
begin
    mensagem ('FTAPAGA', 1);  {'Apagar'}
    mensagem ('FTNOMAPA', 0);  {'Qual o nome do arquivo remoto a apagar ? '}
    sintReadln (nome);
    if nome = '' then
        begin
            mensagem ('FTDESIS', 1);   { desistiu }
            exit;
        end;

    if enviaComando ('DELE ' + ansiToUtf8(nome)) then
        begin
            mostraRespostas (codigo);
            if (codigo = 125) or (codigo = 150) or (codigo = 250) then
                mensagem ('FTOKAPAG', 1)  {'Ok, apagado'}
            else
                mensagem ('FTNAOAPA', 1);  {'Não consegui apagar este arquivo'}
        end;
end;

{-------------------------------------------------------------}

begin
end.
