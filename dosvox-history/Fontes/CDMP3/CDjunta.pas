Unit cdJunta;

interface

uses dvcrt, dvwin, dvgrav, dvForm, dvarq, dvwav, grAmost,
    sysUtils, mmsystem,
    cdVars;

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

procedure juntaSom (som: string; posicao: integer);

implementation

{--------------------------------------------------------}

{--------------------------------------------------------}

procedure converteArquivo (s: string);
var som, som2: TAmostras;
begin

    som := TAmostras.Create;
    som.leArquivo(s);

    som2:= TAmostras.Create;
    som2.reAmostra (som, velocDest);
    som2.bitsPorAmostra:= bitsDest;
    som2.canais:= canaisDest;
    som.Free;
    som := som2;
//    som2 := NIL;

    if not som.gravaArquivo(s) then
        begin
            sintWriteln ('Erro de gravação : ' + s);
        end;

end;

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
{                    abre arquivo destino
{-------------------------------------------------------------}

function abreArqDest: boolean;
label erro;
begin

    abreArqDest:= false;

    nomeDest:= 'ARQ_WAV.$$$';

    assign (arqDest, nomeDest);
    {I-}  rewrite (arqDest, 1);  {$I+}
    if ioresult <> 0 then
        goto erro;
    {$I-} blockWrite (arqDest, cabecWav, sizeof (cabecWav)); {$I+}
    if ioresult <> 0 then
        goto erro;

    velocDest := 0;
    bitsDest := 0;
    canaisDest := 0;
    tamSomDest := 0;

    abreArqDest:= true;
    exit;

erro:
    writeln;
    sintWriteln ('Desculpe, não pude inserir o efeito desejado');
    writeln;

end;

{-------------------------------------------------------------}
{                       finalizacao
{-------------------------------------------------------------}

procedure fechaArqDest;
begin

    genWavHdr (@cabecWav, velocDest, bitsDest, canaisDest, tamSomDest);

    {I-}  close (arqDest);  {$I+}
    if ioresult <> 0 then
        sintWriteln ('Não consegui fechar o arquivo destino');

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
        sintWriteln ('Não consegui fechar o arquivo destino');

end;

{-------------------------------------------------------------}
{                     processa arquivos
{-------------------------------------------------------------}

procedure processa (nomeOrig: string);
var
    aler: longint;
    hdrSize: integer;
    pcmFormat: TPCMWaveFormat;
label inicio;
begin

inicio:

                    wavefileParse (nomeOrig, @pcmFormat, tamSomOrig, hdrSize);
    velocOrig := pcmFormat.wf.nSamplesPerSec;
    bitsOrig := pcmFormat.wBitsPerSample;
    canaisOrig := pcmFormat.wf.nChannels;

    if velocDest = 0 then
        begin
            velocDest := velocOrig;
            bitsDest := bitsOrig;
            canaisDest := canaisOrig;
            tamSomDest := 0;
        end;

    assign (arqOrig, nomeOrig);
    {$I-}  reset (arqOrig, 1);  {$I+}
    if ioresult <> 0 then
        begin
            sintWrite ('Arquivo não encontrado: ');
            sintWriteln (nomeOrig);
            exit;
        end;

    if (velocDest <> velocOrig) or
       (bitsDest <> bitsOrig) or
       (canaisDest <> canaisOrig) then
           begin
//               sintWriteln ('Arquivo incompatível com anterior, irei converter');
               close (arqOrig);
               converteArquivo (nomeOrig);
               goto inicio;
           end;

    seek (arqOrig, hdrSize);
    while tamSomOrig <> 0 do
        begin
            if tamSomOrig > TAMBUF then
                aler := TAMBUF
            else
                aler := tamSomOrig;

            {$I-}  blockRead (arqOrig, buffer, aler); {$I+}
            if ioresult <> 0 then
                 sintWriteln ('Arquivo original danificado');

            {$I-} blockWrite (arqDest, buffer, aler); {$I+}
            if ioresult <> 0 then
                 begin
                     sintWriteln ('Erro ao gravar arquivo, programa cancelado');
                     close (arqOrig);
                     close (arqDest);
                     sintFim;
                     doneWinCrt;
                 end;

            tamSomOrig := tamSomOrig - aler;
            tamSomDest := tamSomDest + aler;
        end;

    close (arqOrig);
    //sintWriteln ('Ok');
end;

{--------------------------------------------------------}

procedure juntaSom (som: string; posicao: integer);
begin

    if not abreArqDest then
        exit;

    if posicao = 1 then
    begin
        nomeOrig := som;
//sintWriteln (nomeorig);
        if nomeOrig <> '' then
            processa (nomeOrig);
    end;

    nomeOrig:= nomeBackUpWav;
//sintWriteln (nomeorig);
    if nomeOrig <> '' then
    processa (nomeOrig);

    if posicao = 2 then
    begin
        nomeOrig := som;
//sintWriteln (nomeorig);
        if nomeOrig <> '' then
            processa (nomeOrig);
    end;

    fechaArqDest;

    deleteFile (nomeBackUpWav);
    renameFile (nomeDest, nomeBackUpWav);

end;

end.
