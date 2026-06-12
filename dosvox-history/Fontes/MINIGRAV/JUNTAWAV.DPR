{-------------------------------------------------------------}
{     Programa para juntar arquivos WAV
{     Autor:  Antonio Borges
{     Em 24/07/1999
{-------------------------------------------------------------}

program juntawav;
uses
    dvcrt, dvwin, dvgrav, dvForm, dvarq, dvwav, sysUtils, mmsystem;

const
    TAMBUF = 16384;
var
    dirTrab, nomeOrig, nomeDest: string;
    arqOrig, arqDest: file;

    velocOrig, velocDest: longint;
    bitsOrig, bitsDest: word;
    canaisOrig, canaisDest: word;
    tamSomOrig, tamSomDest: longint;
    cabecWav: array [0..43] of byte;
    buffer: array [0..TAMBUF-1] of byte;

{-------------------------------------------------------------}
{                     normaliza o nome dado
{-------------------------------------------------------------}

procedure normalizaNome (var nomeArq: string);
begin
    if (pos ('\', nomeArq) = 0) and (pos (':', nomeArq) = 0) then
        nomeArq := dirTrab + nomeArq;
    if pos ('.', nomeArq) = 0 then
        nomeArq := nomeArq + '.WAV';
end;

{-------------------------------------------------------------}
{                    abre arquivos
{-------------------------------------------------------------}

procedure inicializa;
var
    nomeDirAtual: string;
    c, c2: char;
label erro;
begin
    sintInic (0, '');
    sintWriteln ('Juntador de arquivos WAV');
    writeln;

    getDir (0, dirTrab);
    if dirTrab [length (dirTrab)] <> '\' then dirTrab := dirTrab + '\';

    sintWriteln ('Informe o nome do arquivo WAV de destino');
    garanteEspacoTela (11);
    nomeDest := obtemNomeArqMasc (10, '*.WAV');
    if nomeDest = '' then doneWinCrt;
    writeln (nomeDest);

    normalizaNome (nomeDest);

    assign (arqDest, nomeDest);
    {$I-}  reset (arqDest);  {$I+}
    if ioresult = 0 then
        begin
            close (arqDest);
            sintWrite ('Arquivo já existia, posso apagar ? ');
            sintLeTecla (c, c2);
            writeln;
            if upcase(c) = 'S' then
                begin
                    {$I-}  erase (arqDest);  {$I+}
                    if ioresult <> 0 then
                        begin
                            sintWriteln ('Não consegui apagar, programa cancelado');
                            sintFim;
                            doneWinCrt;
                        end;
                end
            else
                begin
                    sintWriteln ('Programa cancelado');
                    sintFim;
                    doneWinCrt;
                end;
        end;

    {I-}  rewrite (arqDest, 1);  {$I+}
    if ioresult <> 0 then goto erro;

    {$I-} blockWrite (arqDest, cabecWav, sizeof (cabecWav)); {$I+}
    if ioresult <> 0 then
        begin
            {$I-} close (arqDest); {$I+}
            if ioresult <> 0 then;
            goto erro;
        end;

    velocDest := 0;
    bitsDest := 0;
    canaisDest := 0;
    tamSomDest := 0;

    sintWriteln ('Nome do diretório que contém os arquivos');
    sintReadln (nomeDirAtual);
    nomeDirAtual := trim (nomeDirAtual);
    if nomeDirAtual <> '' then
        begin
            {$I-}  chDir (nomeDirAtual);  {$i+}
            if ioresult <> 0 then
                 sintWriteln ('Diretório não foi achado, assumido o diretório atual');
        end;

    exit;
erro:
    sintWriteln ('Não consegui criar arquivo, programa cancelado');
    sintFim;
    doneWinCrt;
end;

{-------------------------------------------------------------}
{                       finalizacao
{-------------------------------------------------------------}

procedure finaliza;
begin
    genWavHdr (@cabecWav, velocDest, bitsDest, canaisDest, tamSomDest);

    {I-}  close (arqDest);  {$I+}
    if ioresult <> 0 then
        sintWriteln ('Não consegui fechar o arquivo final');

    FileMode := 2;
    {$I-}  reset (arqDest, 1);  {$I+}
    if ioresult = 0 then
        begin
            seek (arqDest, 0);
            {$I-} blockWrite (arqDest, cabecWav, sizeof (cabecWav));  {$I+}
            if ioresult <> 0 then
               sintWriteln ('Não consegui gravar tamanho do arquivo');
        end;

    {I-}  close (arqDest);  {$I+}
    if ioresult <> 0 then
        sintWriteln ('Não consegui fechar o arquivo final');

    sintWriteln ('Fim do programa');
    sintFim;
    doneWinCrt;
end;

{-------------------------------------------------------------}
{                     processa arquivos
{-------------------------------------------------------------}

procedure processa (nomeOrig: string);
var
    aler: longint;
    hdrSize: integer;
    pcmFormat: TPCMWaveFormat;
begin
    wavefileParse (nomeOrig, @pcmFormat, tamSomOrig, hdrSize);
    velocOrig := pcmFormat.wf.nSamplesPerSec;
    bitsOrig := pcmFormat.wBitsPerSample;
    canaisOrig := pcmFormat.wf.nChannels;

    assign (arqOrig, nomeOrig);
    {$I-}  reset (arqOrig, 1);  {$I+}
    if ioresult <> 0 then
        begin
            sintWriteln ('Arquivo não encontrado');
            exit;
        end;

    seek (arqOrig, hdrSize);

    if velocDest = 0 then
        begin
            velocDest := velocOrig;
            bitsDest := bitsOrig;
            canaisDest := canaisOrig;
            tamSomDest := tamSomOrig;
        end
    else
        begin
            if (velocDest <> velocOrig) or
               (bitsDest <> bitsOrig) or
               (canaisDest <> canaisOrig) then
                   begin
                       sintWriteln ('Arquivo incompatível com anterior');
                       close (arqOrig);
                       exit;
                   end
            else
                tamSomDest := tamSomDest + tamSomOrig;
        end;

    while tamSomOrig <> 0 do
        begin
            if tamSomOrig > TAMBUF then
                aler := TAMBUF
            else
                aler := tamSomOrig;
            tamSomOrig := tamSomOrig - aler;

            {$I-}  blockRead (arqOrig, buffer, aler); {$I+}
            if ioresult <> 0 then
                 sintWriteln ('Arquivo original danificado');

            {$I-} blockWrite (arqDest, buffer, aler); {$I+}
            if ioresult <> 0 then
                 begin
                     writeln ('Erro ao gravar arquivo, programa cancelado');
                     close (arqOrig);
                     close (arqDest);
                     sintFim;
                     doneWinCrt;
                 end;
        end;

    close (arqOrig);
    sintWriteln ('Ok');
end;

{-------------------------------------------------------------}
{                    programa principal
{-------------------------------------------------------------}

begin
    inicializa;

    repeat
        sintWrite ('Nome do arquivo a juntar: ');
        garanteEspacoTela(11);
        nomeOrig := obtemNomeArqMasc (11, '*.WAV');
        writeln (nomeOrig);
        if nomeOrig <> '' then
            processa (nomeOrig);
    until teclaObtemNomeArq = ESC;

    finaliza;
end.
