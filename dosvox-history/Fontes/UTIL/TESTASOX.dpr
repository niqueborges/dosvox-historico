program TESTASOX;

uses
  SysUtils,
  DvCrt,
  DvWin,
  ShellAPI,
  Windows;

var
    comando: string;
    c: char;
begin
   { repeat
        Writeln('Digite o comando: ');
        sintreadln(comando);       }
        ShellExecute(crtWindow, 'open','c:\winvox\sox\sox.exe', 'c:\temp\sox\musica.wav c:\temp\musicaTeste.wav reverse', 'c:\winvox\sox\', SW_MINIMIZE);
 //   until c = ESC;
end.
