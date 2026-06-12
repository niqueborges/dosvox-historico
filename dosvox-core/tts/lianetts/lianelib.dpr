{--------------------------------------------------------}
{                                                        }
{   Sistema de síntese de fala para português            }
{   Copyright (c) Serpro - 2007                          }
{                                                        }
{   Autor: José Antonio Borges                           }
{   Em junho/2007                                        }
{                                                        }
{   Este sintetizador usa partes do sintetizador do      }
{        NCE/UFRJ, criado por J. A. Borges em 1994       }
{   Tradutor de Português originalmente criado por       }
{       . Alexandre Plastino de Carvalho                 }
{       . Sylvia de Oliveira e Cruz                      }
{       . Veronica Lourenco de Herval Costa              }
{   Em Julho de 1987                                     }
{                                                        }
{--------------------------------------------------------}

{$R-}
library lianelib;
uses
  uttsPortug,
  uttsPreproc,
  uttsProsodia,
  mbrola,
  minireg,
  windows,
  classes,
  sysutils,
  mmsystem;

const
    BSIZE = 16000;  // words
    waveBufferSize = 2000000;
var
    output_filename: string;
    lastError: array [0..255] of char;
    liane_file: file;
    writingToFile: boolean;
    tickMax: cardinal;

    liane_pitchRate: integer;
    liane_speedRate: integer;
    liane_filesize: integer;
    outBuffer: array [0..BSIZE*2] of byte;
    waveBuffer: packed array [0..waveBufferSize] of byte;

{--------------------------------------------------------}

function lianeTTS_open (mbrola_db,
                        arq_regras, arq_excessoes, arq_abrev,
                        arq_prosodia, arq_listadif: pchar): boolean; stdcall;
var mbr_db, dir: string;

begin
    lianeTTS_open := false;

    liane_filesize := 0;
    liane_speedRate := 70;
    liane_pitchRate := 50;
    tickMax := 0;

    if not load_MBR then exit;

    mbr_db := strPas(mbrola_db);

    if pos ('\', mbr_db) <= 0 then
        begin
            RegGetString(HKEY_LOCAL_MACHINE, 'SOFTWARE\TCTS\Mbrola\databases\'+ mbrola_db+'\', mbr_db);
            getDir (0, dir);
            if dir[length(dir)] <> '\' then dir := dir + '\';
            if mbr_db = '' then mbr_db := dir + 'lianetts\br4';
        end;

    dir := extractFilePath (mbr_db);
    if dir[length(dir)] <> '\' then dir := dir + '\';

    if arq_regras    = '' then arq_regras    := pchar(dir + 'portug.nrl');
    if arq_excessoes = '' then arq_excessoes := pchar(dir + 'portug.exc');
    if arq_abrev     = '' then arq_abrev     := pchar(dir + 'portug.abr');
    if arq_prosodia  = '' then arq_prosodia  := pchar(dir + 'portug.pro');
    if arq_listadif  = '' then arq_listadif  := pchar(dir + 'portug.dfn');

    if init_MBR (@mbr_db[1]) < 0 then
	begin
            unload_MBR;
            exit;
	end;

    setNoError_MBR (1);

    fimTradutor;
    fimProsodia;

    if not inicTradutor (strPas(arq_regras), strPas(arq_excessoes)) then
        lastError := 'Erro na base de dados de português'
    else
    if not inicAbrev(strPas(arq_abrev)) then
        lastError := 'Erro no arquivo de abreviaturas'
    else
    if not inicProsodia(strPas(arq_prosodia)) then
        lastError := 'Erro no arquivo de prosódia'
    else
    if not inicListaDifones (strPas(arq_listadif)) then
        lastError := 'Erro no arquivo de prosódia'
    else
        begin
            if output_filename = '' then
                lianeTTS_open := true
            else
                begin
                    assignFile (liane_file, output_filename);
                    {$I-} rewrite (liane_file, 1);  {$I-}
                    if ioresult = 0 then
                        begin        // Abre espaço para WAV header
                            {$I-} blockwrite (liane_file, outbuffer, 44); {$I+}
                            if ioresult = 0 then
                                begin
                                    writingToFile := true;
                                    lianeTTS_open := true;
                                end;
                        end;
                end;
        end;
end;

{--------------------------------------------------------}

procedure lianeTTS_setOutputFile (filename: pchar); stdcall;
begin
    output_filename := strPas(filename);
end;

{--------------------------------------------------------}

procedure lianeTTS_config (speed, pitch: integer); stdcall;
begin
    liane_speedRate := speed;
    liane_pitchRate := pitch;
    if (liane_speedRate <= 0) or (liane_speedRate > 100) then
        liane_speedRate := 35;
    if (liane_pitchRate <= 0) or (liane_pitchRate > 100) then
        liane_pitchRate := 50;
end;

{--------------------------------------------------------}

procedure lianeTTS_stop; stdcall;
begin
    if not writingToFile then
        begin
            playSound (NIL, 0, SND_SYNC);
            tickMax := 0;
        end;
end;

{--------------------------------------------------------}

procedure lianeTTS_close; stdcall;
begin
    if writingToFile then
        closeFile (liane_file)
    else
        lianeTTS_stop;

    fimTradutor;
    fimProsodia;

    close_MBR;
    unload_MBR;
end;

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
    p: pointer;
    lpFormat: PPCMWAVEFORMAT;

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

function lianeTTS_speak (toSpeak: pchar): boolean; stdcall;
var
    i, n: integer;
    fonemas, palavrasComCodigos, palavrasComProsodia, mbrolaCmd: TStringList;
    s, dif: string;
    p: pointer;
    tam: integer;
    waveHdr: array [0..43] of byte;
    salvaFileMode: byte;

begin
    lianeTTS_speak := true;

    s := strPas(toSpeak);
    if trim (s) = '' then exit;

    s := preProcessa(s);
    palavrasComCodigos := preProsodia(s);

    palavrasComProsodia := calculaCurvaProsodia (palavrasComCodigos, true);
    palavrasComCodigos.free;

    compilaFonemas (palavrasComProsodia, fonemas);
    palavrasComProsodia.free;

    aplicaProsodia (fonemas, mbrolaCmd, (102-liane_speedRate) / 50.0, liane_pitchRate / 50.0);
    fonemas.free;

    tam := 44;

    if not writingToFile then  // space for wave header
        lianeTTS_stop;

    for i := 0 to mbrolaCmd.count-1 do
        begin
            dif := mbrolaCmd[i];
            if (dif = '') and (i <> mbrolaCmd.count-1) then
                continue;

            dif := dif + #$0d#$0a;
            write_MBR (@dif[1]);
            if lastError_MBR <> 0 then
                begin
                    reset_MBR;
                    lianeTTS_speak := false;
                end;

            if i = mbrolaCmd.count-1 then
                flush_MBR;

            n := read_MBR (@outBuffer[0], BSIZE);
            if lastError_MBR <> 0 then
                begin
                    reset_MBR;
                    lianeTTS_speak := false;
                end;

            while n > 0 do
                begin
                    p := @outbuffer[0];
                    if writingToFile then
                        begin
                            {$I-} blockwrite (liane_file, p^, n*2); {$I+}
                            if ioresult <> 0 then
                                lianeTTS_speak := false;
                        end
                    else
                        if (tam+n*2) < waveBufferSize then  // evita estouros de fala
                            begin
                                move (p^, waveBuffer[tam], n*2);
                                tam := tam + n*2;
                            end;

                    n := read_MBR (@outBuffer[0], BSIZE);
                end;
        end;

    mbrolaCmd.free;

    if writingToFile then
        begin
            CloseFile (liane_file);
            salvaFilemode := filemode;
            FileMode := 2;
            reset (liane_file, 1);
            liane_filesize := filesize (liane_file);
            genWavHdr (@waveHdr, 16000, 16, 1, liane_filesize - 44);
            blockWrite (liane_file, waveHdr, 44);
            seek (liane_file, liane_filesize);
            FileMode := salvaFileMode;
        end
    else
        begin
            liane_filesize := tam;
            tam := tam - 44;
            genWavHdr (@waveHdr, 16000, 16, 1, tam);
            move (waveHdr, waveBuffer, 44);
            playSound (@waveBuffer, 0, SND_ASYNC+SND_MEMORY);

            // 1 tick = 1 ms = 16 samples de 2 bytes = 32 bytes
            // playSound é assíncrona e demora cerca de 200 ms para iniciar
            tickMax := GetTickCount + cardinal(tam div 32) + 200;
        end;
end;

{--------------------------------------------------------}

function lianeTTS_utfSpeak (toSpeak: pchar): boolean; stdcall;
var translation: array [0..4095] of char;
    pt: pchar;
    b, b2: byte;
    i: integer;
    len: integer;
begin
    len := strlen (toSpeak);
    if len > 4095 then len := 4095;

    pt := @translation;
    i := 0;
    while i < len do
        begin
            b := ord(toSpeak[i]);
            if (b < $80) or ((b and $e0) <> $c0)then
                begin
                    pt^ := toSpeak[i];
                    pt := pt + 1;
                end
            else
                begin
                    b2 := ord (toSpeak[i+1]) and $3f;
                    b := (b and $03) shl 6;
                    pt^ := chr(b or b2);
                    pt := pt + 1;
                    i := i + 1;
                end;
            i := i + 1;
        end;
    pt^ := #$0;

    lianeTTS_utfSpeak := lianeTTS_speak (@translation);
end;

{--------------------------------------------------------}

function lianeTTS_isSpeaking: integer; stdcall;
begin
    if writingToFile then
        result := 0
    else
        if GetTickCount > tickMax then
             result := 0
        else
             result := 1;
end;

{--------------------------------------------------------}

procedure lianeTTS_wait; stdcall;
begin
    if not writingToFile then
       while lianeTTS_isSpeaking = 1 do
           sleep(10);
end;

{--------------------------------------------------------}

function lianeTTS_getFilesize: integer; stdcall;
begin
    result := liane_filesize;
end;

{--------------------------------------------------------}

type
    TThreadCallback = class (TThread)
        procedure execute;  override;
    end;

type
    procCallback = procedure;
var
    th: TThreadCallback;
    rotCallback: procCallback;

procedure TThreadCallback.execute;
begin
    while (not terminated) and (lianeTTS_isSpeaking = 1) do
        sleep(10);
    if not terminated then
        rotCallback;
end;

procedure lianeTTS_killCallback;  stdcall;
begin
    th.Terminate;
    th.WaitFor;
    th.Free;
    th := NIL;
end;

procedure lianeTTS_prepareCallback (_rotCallback: procCallback);  stdcall;
begin
    if th <> NIL then
        lianeTTS_killCallback;

    rotCallback := _rotCallback;
    th := TThreadCallback.Create (false);
end;

{--------------------------------------------------------}

exports
    lianeTTS_open,
    lianeTTS_setOutputFile,
    lianeTTS_config,
    lianeTTS_close,
    lianeTTS_speak,
    lianeTTS_utfSpeak,
    lianeTTS_stop,
    lianeTTS_isSpeaking,
    lianeTTS_wait,
    lianeTTS_prepareCallback,
    lianeTTS_getFilesize,
    lianeTTS_prepareCallback,
    lianeTTS_killCallback;

begin
end.

