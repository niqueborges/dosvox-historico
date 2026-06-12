{-------------------------------------------------------------}
{       papovox - tratamento do envio e recepcao de som
{-------------------------------------------------------------}

unit ppsom;
interface
uses dvwin, dvcrt, dvwav, winsock, dvinet, mmsystem,
     winprocs, wintypes, dvgrav, sysUtils,
     ppvars, ppmsg, pprede;

procedure inicioEnvioSom;
procedure monitoraBuffersSom;
procedure trataInicioSom;
procedure trataRecebeSom (bufao: pchar; lidos: integer);
procedure trataFimSom;
procedure terminaEnvioSom;

implementation

{--------------------------------------------------------}
{                inicia envio do som
{--------------------------------------------------------}

procedure inicioEnvioSom;
begin
    bipSpeaker (47);
    bipSpeaker (40);

    if not preparaGravacao ('c:\$envsom.wav', 8000, 8, 1, 12, 4096) = 0 then
        begin
            mensagem ('PPERRGRV', 1);   {Erro no módulo de som}
            exit;
        end;

    iniciaGravacao;

    if not enviaRede (INICIOSOM, NIL, 0) then
        conversando := false;

    enviandoSom := true;
    enviouTodoSom := false;
    tamSomEnviado := 0;
end;

{--------------------------------------------------------}
{      ve se ja tem informacao sonora a transferir
{--------------------------------------------------------}

procedure monitoraBuffersSom;
var lidos: integer;
begin
    if enviandoSom then
        if not monitoraGravacao then
            begin
                mensagem ('PPERRGRV', 1);   {Erro no módulo de som, verifique espaço em disco}
                terminaGravacao;
                enviandoSom := false;
            end;

    if tamSomEnviado < tamGravado then
         begin
             seek (arqGravador, tamSomEnviado+44);
             {$I-}  blockRead (arqGravador, bufSom, 512, lidos);  {$I+}
             if ioresult <> 0 then
                 ;  {depois tratar}

            if not enviaRede (DADOSOM, @bufSom, lidos) then
                 conversando := false;

            tamSomEnviado := tamSomEnviado + lidos;
         end;
end;

{--------------------------------------------------------}
{                descarrega buffers
{--------------------------------------------------------}

procedure terminaEnvioSom;
begin
    close (arqGravador);
    bipSpeaker (40);
    bipSpeaker (47);
    if not enviaRede (FIMSOM, NIL, 0) then
         conversando := false;

    enviouTodoSom := true;
end;

{--------------------------------------------------------}
{               abre arquivo para som remoto
{--------------------------------------------------------}

procedure trataInicioSom;
begin
    bipSpeaker (47);

    assign (arqSom, 'c:\$recsom.wav');

    {$I-} rewrite (arqSom, 1);  {$I+}
    if ioresult <> 0 then
        begin
            writeln ('Não consegui criar o arquivo de som');
            sintBip;
            sintBip;
            sintBip;
            readln;
        end;

    blockWrite (arqSom, bufSom, 44);   {reserva espaco para cabecalho wav}
    if ioresult <> 0 then
        ;  {depois tratar}

    recebendoSom := true;
end;

{--------------------------------------------------------}
{                guarda som recebido
{--------------------------------------------------------}

procedure trataRecebeSom (bufao: pchar; lidos: integer);
begin
    {$I-}  blockWrite (arqSom, bufao^, lidos);   {$I+}
    if ioresult <> 0 then
        writeln ('problemas na gravacao');  {depois tratar}
end;

{-------------------------------------------------------------}
{             gera um cabecalho de arquivo .WAV
{-------------------------------------------------------------}

procedure genWavHdr (pvet: pchar; veloc: longint; bits, channels: word; size: longint);
const
    wavHdr: array [0..43] of byte = (
        $52, $49, $46, $46,    {'RIFF'}
        $ff, $ff, $ff, $ff,    {riff size}
        $57, $41, $56, $45, $66, $6d, $74, $20,    {'WAVEFMT '}
        $10, $00, $00, $00,    {hdr size}
        $01, $00, $01, $00, $11, $2b, $00, $00, $11, $2b, $00, $00, $01, $00, $08, $00,  {reg}
        $64, $61, $74, $61,    {'data'}
        $ff, $ff, $ff, $ff);   {data size}

var l: longint;
    lpFormat: PPCMWAVEFORMAT;
    p: pointer;
begin
    new (lpFormat);
    with lpFormat^, lpFormat^.wf do
        begin
            wFormatTag := WAVE_FORMAT_PCM;
            nSamplesPerSec := veloc;
            wBitsPerSample := bits;
            nChannels := channels;
            nBlockAlign := (wBitsPerSample div 8) * nChannels;
            nAvgBytesPerSec := nBlockAlign * nSamplesPerSec;
        end;

    p := @wavHdr[20];
    move (lpFormat^, p^, sizeof (lpFormat^));
    l := size + 36;
    p := @wavHdr[4];
    move (l, p^, sizeof (l));
    p := @wavHdr[40];
    move (size, p^, sizeof (size));

    move (wavHdr, pvet^, sizeof (wavHdr));
    dispose (lpFormat);
end;

{--------------------------------------------------------}
{             trata fim da recepcao do som
{--------------------------------------------------------}

procedure trataFimSom;
begin
    {$I-} close (arqSom);   {$I+}
    if ioresult <> 0 then
        ;  {depois tratar}

    reset (arqSom, 1);
    genWavHdr (@bufSom, 8000, 8, 1, fileSize (arqSom)-44);
    blockWrite (arqSom, bufSom, 44);
    close (arqSom);

    recebendoSom := false;

    bipSpeaker (47);
    bipSpeaker (40);
    bipSpeaker (44);
    delay (500);

    while keypressed do;
    wavePlayFile ('c:\$recsom.wav');
end;

end.
