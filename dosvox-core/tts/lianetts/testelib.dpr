{-------------------------------------------------------------}
{     Serviço Federal de Processamento de Dados               }
{     LianeTTS.dll is covered by the                          }
{        GNU Lesser General Public License                    }
{     This test program is covered by the                     }
{        GNU Public License                                   }
{     Author: José Antonio Borges                             }
{     2006-2007 Serpro - Brazil                               }
{-------------------------------------------------------------}

program testelib;

{$APPTYPE CONSOLE}

uses windows, shellapi;

type
    procCallback = procedure;
    
(* lianelib.dll routines*)

function lianeTTS_open (mbrola_db,
                        arq_regras, arq_excessoes, arq_abrev,
                        arq_prosodia, arq_listadif: pchar): boolean;
    stdcall external 'lianelib.dll' Name 'lianeTTS_open';
procedure lianeTTS_setOutputFile (filename: pchar);
    stdcall external 'lianelib.dll' Name 'lianeTTS_setOutputFile';
procedure lianeTTS_config (duration, pitch: integer);
    stdcall external 'lianelib.dll' Name 'lianeTTS_config';
procedure lianeTTS_close;
    stdcall external 'lianelib.dll' Name 'lianeTTS_close';
procedure lianeTTS_stop;
    stdcall external 'lianelib.dll' Name 'lianeTTS_stop';
function lianeTTS_speak (toSpeak: pchar): boolean;
    stdcall external 'lianelib.dll' Name 'lianeTTS_speak';
function lianeTTS_isSpeaking: boolean;
    stdcall external 'lianelib.dll' Name 'lianeTTS_isSpeaking';
procedure lianeTTS_wait;
    stdcall external 'lianelib.dll' Name 'lianeTTS_wait';
function lianeTTS_add (toSpeak: pchar; bookmark: integer): boolean;
    stdcall external 'lianelib.dll' Name 'lianeTTS_add';
function lianeTTS_getFilesize: integer;
    stdcall external 'lianelib.dll' Name 'lianeTTS_getFilesize';
procedure lianeTTS_prepareCallback (_rotCallback: procCallback);
    stdcall external 'lianelib.dll' Name 'lianeTTS_prepareCallback';
procedure lianeTTS_killCallback;
    stdcall external 'lianelib.dll' Name 'lianeTTS_killCallback';


(* teste da lianelib.dll *)

var dir: string;
    ok: boolean;

    procedure minhaRot;
    begin
        ok := true;
        writeln;
        writeln ('Rotina de callback foi chamada');
    end;

begin
    dir := 'c:\winvox\lianetts\';
    if not lianeTTS_open (pchar(dir+'br4'),
                          pchar(dir+'portug.nrl'),
                          pchar(dir+'portug.exc'),
                          pchar(dir+'portug.abr'),
                          pchar(dir+'portug.pro'),
                          pchar(dir+'portug.dfn')) then
       begin
           writeln ('Não achei os arquivos br4 ou portug.*');
           readln;
           halt;
       end;

    lianeTTS_config (70, 50);

    writeln ('Este e'' um teste do sintetizador Serpro Liane TTS');
    writeln;

    writeln        ('Este e'' um teste do sintetizador Serpro Liane TTS');
    lianeTTS_speak ('Este é um teste do sintetizador Serpro Liane TTS');
    lianeTTS_wait;

    writeln        ('Este e'' um teste interrompido do sintetizador Serpro Liane TTS');
    lianeTTS_speak ('Este é um teste interrompido do sintetizador Serpro Liane TTS');
    sleep (2000);
    lianeTTS_stop;

    writeln        ('Este e'' outro teste do sintetizador Serpro Liane TTS');
    lianeTTS_speak ('Este é outro teste do sintetizador Serpro Liane TTS');
    while lianeTTS_isSpeaking do
        begin
            write ('*');
            sleep (10);
        end;
    writeln ('Terminou de falar');

    writeln        ('Este e'' um teste de callback do sintetizador Serpro Liane TTS');
    lianeTTS_speak ('Este é um teste de callback do sintetizador Serpro Liane TTS');
    ok := false;
    lianeTTS_prepareCallback (@minhaRot);
    while not ok do
        begin
            write ('$');
            sleep (10);
        end;
    writeln ('Terminou de falar.');

    lianeTTS_config(80, 25);
    lianeTTS_speak ('Este e'' um teste rápido e grosseiro do sintetizador Serpro Liane TTS');
    lianeTTS_speak ('Este é um teste rápido e grosso do sintetizador Serpro Liane TTS');
    lianeTTS_wait;

    lianeTTS_close;

    lianeTTS_setOutputFile('teste.wav');
    if not lianeTTS_open ('\winvox\lianetts\br4',
                          '\winvox\lianetts\portug.nrl',
                          '\winvox\lianetts\portug.exc',
                          '\winvox\lianetts\portug.abr',
                          '\winvox\lianetts\portug.pro',
                          '\winvox\lianetts\portug.dfn') then
       begin
           writeln ('mifu');
           halt;
       end;

    lianeTTS_config(70, 50);
    lianeTTS_speak ('Este é um teste do sintetizador Serpro Liane TTS,');
    lianeTTS_speak ('Gravando mais');
    lianeTTS_speak ('e muito mais ainda, incansavelmente.');
    lianeTTS_close;

    writeln ('arquivo teste.wav gerado com tamanho ', lianeTTS_getFilesize, ', aperte enter');
    readln;
end.

