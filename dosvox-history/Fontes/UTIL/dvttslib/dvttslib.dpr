{--------------------------------------------------------}
{                                                        }
{   Sistema de síntese de fala para português            }
{   Copyright (c) NCE/UFRJ - 2007                        }
{                                                        }
{   Autor: José Antonio Borges                           }
{   Em agosto/2007                                       }
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
library dvttslib;
uses
    dvwin, sysUtils;

var
    dv_pitchRate: integer;
    dv_speedRate: integer;

{--------------------------------------------------------}

function dvTTS_open (): boolean; stdcall;
var mbr_db: string;
begin
    sintInic (0, '');
    dv_speedRate := 50;
    dv_pitchRate := 50;
end;

{--------------------------------------------------------}

procedure dvTTS_config (speed, pitch: integer); stdcall;
begin
    dv_speedRate := speed;
    dv_pitchRate := pitch;
    if (dv_speedRate <= 0) or (dv_speedRate > 100) then
        dv_speedRate := 50;
    if (dv_pitchRate <= 0) or (dv_pitchRate > 100) then
        dv_pitchRate := 50;

    sintVeloc (speed div 25);
end;

{--------------------------------------------------------}

procedure dvTTS_close; stdcall;
begin
    sintFim;
end;

{--------------------------------------------------------}

procedure dvTTS_stop; stdcall;
begin
    sintPara;
end;

{--------------------------------------------------------}

function dvTTS_speak (toSpeak: pchar): boolean; stdcall;
var s: string;
begin
    dvTTS_speak := true;
    sintetiza (strPas(toSpeak));
end;

{--------------------------------------------------------}

function dvTTS_utfSpeak (toSpeak: pchar): boolean; stdcall;
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

    dvTTS_utfSpeak := dvTTS_speak (@translation);
end;

{--------------------------------------------------------}

function dvTTS_isSpeaking: boolean; stdcall;
begin
    dvTTS_isSpeaking := sintFalando;
end;

{--------------------------------------------------------}

procedure dvTTS_wait; stdcall;
begin
    while sintFalando do sleep (50);
end;

{--------------------------------------------------------}

exports
    dvTTS_open,
    dvTTS_config,
    dvTTS_close,
    dvTTS_speak,
    dvTTS_utfSpeak,
    dvTTS_stop,
    dvTTS_isSpeaking,
    dvTTS_wait;

begin
end.

