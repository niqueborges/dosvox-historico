{--------------------------------------------------------}
{
{     Manipulação do áudio em baixo nível
{     Autor: Antonio Borges
{     Em 31/5/2003
{
{--------------------------------------------------------}

unit uaudio;

interface
uses dvcrt, windows, mmsystem;

function initWaveRecording (veloc: longint; bits, canais: word;
                            bufsize: integer): integer;
function isWaveBufferReady: boolean;
procedure waitWaveBufferReady;
function getWaveBuffer (pbuf: pointer): integer;
procedure terminateWaveRecording;

implementation

const
    maxBuf = 8;

var
    hWavIn: HWaveIn;

    hbuf: array [0..maxBuf-1] of THandle;
    pBuf: array [0..maxBuf-1] of pChar;
    hhdr: array [0..maxBuf-1] of THandle;
    lpWaveInHdr: array [0..maxBuf-1] of PWaveHdr;
    pin: integer;
    size: integer;

{-------------------------------------------------------------}
{                    abre o dispositivo de áudio
{-------------------------------------------------------------}

function openWaveDevice (uDeviceId: UINT;
         veloc: longint; bits, channels: integer): word;
var
    lpFormat: PPcmWaveFormat;
    dwCallback, dwInstance, dwFlags: longint;
    status: word;
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

    dwCallBack := crtWindow;
    dwInstance := 0;
    dwFlags := CALLBACK_WINDOW;

    status := waveInOpen(@hWavIn, uDeviceID, @lpFormat^,
                          dwCallback, dwInstance, dwFlags);

    openWaveDevice := status;    {zero significa ok}

    dispose (lpformat);
end;

{--------------------------------------------------------}
{                    prepara buffer de áudio
{--------------------------------------------------------}

procedure PrepareWaveBuffer (i: integer);
begin
    fillChar (lpWaveInHdr [i]^, sizeof (TWaveHdr), 0);
    with lpWaveInHdr [i]^ do
        begin
            lpData := pBuf[i];       { pointer to locked data buffer }
            dwBufferLength := size;
        end;

    waveInPrepareHeader(hWavIn, lpWaveInHdr [i], sizeof (TWaveHdr));
    waveInAddBuffer (hWavIn, lpWaveInHdr [i], sizeof (TWaveHdr));
end;

{--------------------------------------------------------}
{                    inicia gravação
{--------------------------------------------------------}

function initWaveRecording (veloc: longint; bits, canais: word;
                            bufsize: integer): integer;
label fim, erro;
var i, status: integer;
begin
    size := bufsize;
    status := openWaveDevice (WAVE_MAPPER, veloc, bits, canais);
    initWaveRecording := status;
    if status <> 0 then exit;

    for i := 0 to maxBuf-1 do
        begin
            hbuf[i] := globalAlloc (GMEM_MOVEABLE or GMEM_SHARE, size);
            pBuf[i] := globalLock (hbuf[i]);
            hhdr[i] := globalAlloc (GMEM_MOVEABLE or GMEM_SHARE, sizeof (TWaveHdr));
            lpWaveInHdr [i] := globalLock (hhdr[i]);

            prepareWaveBuffer (i);
        end;

    waveInStart (hWavIn);
end;

{-------------------------------------------------------------}
{                 monitoração do buffer
{-------------------------------------------------------------}

function isWaveBufferReady: boolean;
begin
    isWaveBufferReady := (lpWaveInHdr [pin]^.dwFlags and WHDR_DONE) <> 0;
end;

{-------------------------------------------------------------}

procedure waitWaveBufferReady;
begin
    while not isWaveBufferReady do
        waitMessage;
end;

{-------------------------------------------------------------}
{                 espera um buffer pronto
{-------------------------------------------------------------}

function getWaveBuffer (pbuf: pointer): integer;
begin
    waitWaveBufferReady;
    getWaveBuffer := 0;

    with lpWaveInHdr [pin]^ do
        begin
            if (dwFlags and WHDR_DONE) <> 0 then
                begin
                    move (lpdata^, pbuf^, dwBytesRecorded);
                    getWaveBuffer := dwBytesRecorded;
                    waveInUnPrepareHeader(hWavIn, lpWaveInHdr [pin], sizeof (TWaveHdr));
                    prepareWaveBuffer (pin);
                    pin := (pin + 1) mod maxBuf;
               end;
        end;
end;

{--------------------------------------------------------}
{                  termina gracação
{--------------------------------------------------------}

procedure terminateWaveRecording;
begin
    waveInStop (hWavIn);
    waveInReset (hWavIn);

    while lpWaveInHdr [pin] <> NIL do
        begin
            globalUnlock (hbuf[pin]);  globalFree (hbuf[pin]);
            globalUnlock (hhdr[pin]);  globalFree (hhdr[pin]);
            lpWaveInHdr [pin] := NIL;
            pin := (pin + 1) mod maxBuf;
        end;

    waveInClose (hWavIn);
end;

end.
