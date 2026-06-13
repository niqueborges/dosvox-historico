{--------------------------------------------------------}
{                                                        }
{   Sistema de síntese de fala para português            }
{                                                        }
{   Rotinas utilitárias                                  }
{                                                        }
{   Autor: Patrick Barboza                               }
{                                                        }
{    Código adaptado a partir de mbrola.pas              }
{                                                        }
{   Em Abril/2024                                        }
{                                                        }
{--------------------------------------------------------}

unit uttsUtils;

interface

uses windows, sysUtils, messages;

function getDLLPath_MBR: string;

implementation

function getDLLPath_MBR: string;
var
    TheFileName : array[0..MAX_PATH] of char;
    dir: string;
begin
    FillChar(TheFileName, sizeof(TheFileName), #0);
    GetModuleFileName(hInstance, TheFileName, sizeof(TheFileName));
    dir := strPas (TheFileName);
    delete (dir, lastDelimiter ('\', dir), 999);
    if not fileExists (dir + '\mbrola.dll') then
        dir := dir + '\lianetts';
    if not fileExists (dir + '\mbrola.dll') then
        dir := '\winvox\lianetts';
    result := dir;
end;

begin
end.
